Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41203 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932448AbbCQWlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:13 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 01/10] NFS return the root_mnt via the raw data in nfs_fs_mount
Date: Tue, 17 Mar 2015 18:31:29 -0400
Message-ID: <1426631498-14772-2-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We need the vfsmount to construct the NFS READ request from the
destination server to the source server.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h               |  2 ++
 fs/nfs/nfs4super.c              |  2 ++
 fs/nfs/super.c                  | 27 +++++++++++++++++++++++++++
 include/uapi/linux/nfs4_mount.h |  1 +
 4 files changed, 32 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9e6475b..473e241 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -115,6 +115,7 @@ struct nfs_parsed_mount_data {
 
 	struct security_mnt_opts lsm_opts;
 	struct net		*net;
+	struct vfsmount		*root_mnt;
 };
 
 /* mount_clnt.c */
@@ -373,6 +374,7 @@ extern struct file_system_type nfs_xdev_fs_type;
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
+extern struct vfsmount *nfs_get_root_mnt(int vers, char *raw_data);
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
 struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
 			struct nfs_subversion *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 75090fe..d2c1883 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -252,6 +252,8 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	res = nfs_follow_remote_path(root_mnt, export_path);
 
+	data->root_mnt = root_mnt;
+
 	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
 		 PTR_ERR_OR_ZERO(res),
 		 IS_ERR(res) ? " [error]" : "");
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 322b2de02..1b61e58 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2608,6 +2608,32 @@ error_splat_super:
 }
 EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
 
+static void nfs_set_root_mnt(struct file_system_type *fs_type, void *raw_data,
+			     struct nfs_parsed_mount_data *pdata)
+{
+	if (fs_type == &nfs4_fs_type) {
+		struct nfs4_mount_data *data =
+					(struct nfs4_mount_data *)raw_data;
+		dprintk("%s pdata->root_mnt %p\n", __func__, pdata->root_mnt);
+		data->root_mnt = pdata->root_mnt;
+	}
+}
+
+struct vfsmount *nfs_get_root_mnt(int vers, char *raw_data)
+{
+	struct vfsmount *mnt = ERR_PTR(-EINVAL);
+
+	if (vers == 4) {
+		struct nfs4_mount_data *data =
+					(struct nfs4_mount_data *)raw_data;
+
+		dprintk("%s data->root_mnt %p\n", __func__, data->root_mnt);
+		mnt = data->root_mnt;
+	}
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(nfs_get_root_mnt);
+
 struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
@@ -2640,6 +2666,7 @@ struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	}
 
 	mntroot = nfs_mod->rpc_ops->try_mount(flags, dev_name, &mount_info, nfs_mod);
+	nfs_set_root_mnt(nfs_mod->nfs_fs, raw_data, mount_info.parsed);
 
 	put_nfs_version(nfs_mod);
 out:
diff --git a/include/uapi/linux/nfs4_mount.h b/include/uapi/linux/nfs4_mount.h
index a0dcf66..91c9539 100644
--- a/include/uapi/linux/nfs4_mount.h
+++ b/include/uapi/linux/nfs4_mount.h
@@ -53,6 +53,7 @@ struct nfs4_mount_data {
 	/* Pseudo-flavours to use for authentication. See RFC2623 */
 	int auth_flavourlen;			/* 1 */
 	int __user *auth_flavours;		/* 1 */
+	struct vfsmount *root_mnt;		/* 2 */
 };
 
 /* bits in the flags field */
-- 
1.8.3.1

