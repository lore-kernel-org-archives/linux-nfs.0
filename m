From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 2/2-v2] NFS: use new LSM interfaces to explicitly set mount
	options
Date: Wed, 05 Mar 2008 14:20:18 -0500
Message-ID: <1204744818.3216.254.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: steved@redhat.com, jlayton@redhat.com, sds@tycho.nsa.gov,
	jmorris@namei.org, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com,
	hch@infradead.org, akpm@linux-foundation.org
To: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbYCETVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 14:21:23 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS and SELinux worked together previously because SELinux had NFS
specific knowledge built in.  This design was approved by both groups
back in 2004 but the recent NFS changes to use nfs_parsed_mount_data and
the usage of nfs_clone_mount_data showed this to be a poor fragile
solution.  This patch fixes the NFS functionality regression by making
use of the new LSM interfaces to allow an FS to explicitly set its own
mount options.

The explicit setting of mount options is done in the nfs get_sb
functions which are called before the generic vfs hooks try to set mount
options for filesystems which use text mount data.

This does not currently support NFSv4 as that functionality did not
exist in previous kernels and thus there is no regression.  I will be
adding the needed code, which I believe to be the exact same as the v3
code, in nfs4_get_sb for 2.6.26.

Signed-off-by: Eric Paris <eparis@redhat.com>

---

 fs/nfs/internal.h |    3 ++
 fs/nfs/super.c    |   64 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0f56196..9319927 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -3,6 +3,7 @@
  */
 
 #include <linux/mount.h>
+#include <linux/security.h>
 
 struct nfs_string;
 
@@ -57,6 +58,8 @@ struct nfs_parsed_mount_data {
 		char			*export_path;
 		int			protocol;
 	} nfs_server;
+
+	struct security_mnt_opts lsm_opts;
 };
 
 /* client.c */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1fb3818..fcf4b98 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -684,8 +684,9 @@ static void nfs_parse_server_address(char *value,
 static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
-	char *p, *string;
+	char *p, *string, *secdata;
 	unsigned short port = 0;
+	int rc;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -693,6 +694,20 @@ static int nfs_parse_mount_options(char *raw,
 	}
 	dfprintk(MOUNT, "NFS: nfs mount opts='%s'\n", raw);
 
+	secdata = alloc_secdata();
+	if (!secdata)
+		goto out_nomem;
+
+	rc = security_sb_copy_data(raw, secdata);
+	if (rc)
+		goto out_security_failure;
+
+	rc = security_sb_parse_opts_str(secdata, &mnt->lsm_opts);
+	if (rc)
+		goto out_security_failure;
+
+	free_secdata(secdata);
+
 	while ((p = strsep(&raw, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
 		int option, token;
@@ -1042,7 +1057,10 @@ static int nfs_parse_mount_options(char *raw,
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
-
+out_security_failure:
+	free_secdata(secdata);
+	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
+	return 0;
 out_unrec_vers:
 	printk(KERN_INFO "NFS: unrecognized NFS version number\n");
 	return 0;
@@ -1214,6 +1232,33 @@ static int nfs_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 		args->auth_flavors[0]	= data->pseudoflavor;
+
+		/*
+		 * The legacy version 6 binary mount data from userspace has a
+		 * field used only to transport selinux information into the
+		 * the kernel.  To continue to support that functionality we
+		 * have a touch of selinux knowledge here in the NFS code. The
+		 * userspace code converted context=blah to just blah so we are
+		 * converting back to the full string selinux understands.
+		 */
+		if (data->context[0]){
+#ifdef CONFIG_SECURITY_SELINUX
+			int rc;
+			char *opts_str = kmalloc(sizeof(data->context) + 8, GFP_KERNEL);
+			if (!opts_str)
+				return -ENOMEM;
+			strcpy(opts_str, "context=");
+			data->context[NFS_MAX_CONTEXT_LEN] = '\0';
+			strcat(opts_str, &data->context[0]);
+			rc = security_sb_parse_opts_str(opts_str, &args->lsm_opts);
+			kfree(opts_str);
+			if (rc)
+				return rc;
+#else
+			return -EINVAL;
+#endif
+		}
+
 		break;
 	default: {
 		unsigned int len;
@@ -1476,6 +1521,8 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	};
 	int error;
 
+	security_init_mnt_opts(&data.lsm_opts);
+
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(raw_data, &data, &mntfh, dev_name);
 	if (error < 0)
@@ -1515,6 +1562,10 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
+	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	if (error)
+		goto error_splat_root;
+
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
@@ -1523,12 +1574,15 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 out:
 	kfree(data.nfs_server.hostname);
 	kfree(data.mount_server.hostname);
+	security_free_mnt_opts(&data.lsm_opts);
 	return error;
 
 out_err_nosb:
 	nfs_free_server(server);
 	goto out;
 
+error_splat_root:
+	dput(mntroot);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -1608,6 +1662,9 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	/* clone any lsm security options from the parent to the new sb */
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs_xdev_get_sb() = 0\n");
 	return 0;
 
@@ -1850,6 +1907,8 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	};
 	int error;
 
+	security_init_mnt_opts(&data.lsm_opts);
+
 	/* Validate the mount data */
 	error = nfs4_validate_mount_data(raw_data, &data, dev_name);
 	if (error < 0)
@@ -1898,6 +1957,7 @@ out:
 	kfree(data.client_address);
 	kfree(data.nfs_server.export_path);
 	kfree(data.nfs_server.hostname);
+	security_free_mnt_opts(&data.lsm_opts);
 	return error;
 
 out_free:


