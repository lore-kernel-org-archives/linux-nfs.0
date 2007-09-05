From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] 2/2 NFS/SELinux: Make NFSv3 explicitly set its
	superblock	security options
Date: Wed, 05 Sep 2007 18:16:05 -0400
Message-ID: <1189030570.3460.42.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, sds@tycho.nsa.gov, steved@redhat.com
To: selinux@tycho.nsa.gov, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IT3B6-0003BA-HA
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 15:17:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IT3BA-0008B4-Qz
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 15:16:57 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Allow NFSv3 to cleanly support the context= mount option.  Currently the
SELinux code directly looks at the struct nfs_mount_data to get the
context information for an nfs mount.  This code makes NFS explicitly
set security information whenever it gets a new superblock.  It also
clones the security information from the 'parent' superblock to the new
superblock in the case of a nohide mount.

This also removes the NFS specific information inside SELinux code.

Signed-off-by: Eric Paris <eparis@redhat.com>

---
 fs/nfs/super.c           |   15 +++++++++++++++
 security/selinux/hooks.c |   25 +++----------------------
 2 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8ed5937..b3baa1f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -46,6 +46,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
+#include <linux/security.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -1429,6 +1430,16 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
+
+	/* explicitly set lsm options, all we know is context= */
+	if (data->context[0]) {
+		char *opt = data->context;
+		int opt_num = CONTEXT_MNT;
+		error = security_sb_set_mnt_opts(s, &opt, &opt_num, 1);
+		if (error)
+			goto error_splat_root;
+	}
+
 	error = 0;
 
 out:
@@ -1440,6 +1451,8 @@ out_err_nosb:
 	nfs_free_server(server);
 	goto out;
 
+error_splat_root:
+	dput(mnt->mnt_root);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -1514,6 +1527,8 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs_xdev_get_sb() = 0\n");
 	return 0;
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5ebe30b..13cf4f1 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -62,7 +62,6 @@
 #include <linux/un.h>		/* for Unix socket types */
 #include <net/af_unix.h>	/* for Unix socket types */
 #include <linux/parser.h>
-#include <linux/nfs_mount.h>
 #include <net/ipv6.h>
 #include <linux/hugetlb.h>
 #include <linux/personality.h>
@@ -736,27 +735,12 @@ static int try_context_mount(struct super_block *sb, void *data)
 	/* selinux only know about 4 mount options */
 	char *mnt_opts[4];
 	int mnt_opts_flags[4], num_mnt_opts = 0;
-	int con_from_nfs = 0;
 
 	if (!data)
 		goto out;
 
-	/* with the nfs patch this will become a goto out; */
-	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
-		const char *name = sb->s_type->name;
-		/* NFS we understand. */
-		if (!strcmp(name, "nfs")) {
-			struct nfs_mount_data *d = data;
-
-			if (d->version !=  NFS_MOUNT_VERSION)
-				goto out;
-
-			if (d->context[0])
-				context = d->context;
-			con_from_nfs = 1;
-		} else
-			goto out;
-	} else {
+	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
+		goto out;
 
 	/* Standard string-based options. */
 	while ((p = strsep(&options, "|")) != NULL) {
@@ -828,7 +812,6 @@ static int try_context_mount(struct super_block *sb, void *data)
 
 		}
 	}
-	} // else for binary mount data.  delete with nfs patch
 
 	if(fscontext){
 		mnt_opts[num_mnt_opts] = fscontext;
@@ -850,9 +833,7 @@ static int try_context_mount(struct super_block *sb, void *data)
 out:
 	rc = selinux_set_mnt_opts(sb, mnt_opts, mnt_opts_flags, num_mnt_opts);
 out_err:
-	/* remove conditional when we remove nfs */
-	if (!con_from_nfs)
-		kfree(context);
+	kfree(context);
 	kfree(defcontext);
 	kfree(fscontext);
 	kfree(rootcontext);



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
