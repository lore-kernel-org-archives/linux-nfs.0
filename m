From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 2/2] NFSv4: Use vfs_path_lookup() instead of
 nfs4_path_walk()
Date: Mon, 09 Feb 2009 13:45:34 -0500
Message-ID: <20090209184534.23040.52359.stgit@heimdal.trondhjem.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869AbZBITT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 14:19:56 -0500
In-Reply-To: <20090209184534.23040.82605.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 mount code currently has several limitations which we really
don't want to keep. For one thing, it will not follow symlinks, and neither
will it follow referrals.
The correct approach here should be to reuse the existing VFS and NFS path
lookup code instead of duplicating it inside nfs4_path_walk().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |  149 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 129 insertions(+), 20 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d6686f4..b75e551 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -42,6 +42,7 @@
 #include <linux/smp_lock.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
+#include <linux/namei.h>
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
@@ -264,10 +265,14 @@ static const struct super_operations nfs_sops = {
 #ifdef CONFIG_NFS_V4
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static int nfs4_remote_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_xdev_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_referral_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs4_kill_super(struct super_block *sb);
 
 static struct file_system_type nfs4_fs_type = {
@@ -278,6 +283,14 @@ static struct file_system_type nfs4_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
+static struct file_system_type nfs4_remote_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs4_remote_get_sb,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
 struct file_system_type nfs4_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
@@ -286,6 +299,14 @@ struct file_system_type nfs4_xdev_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
+static struct file_system_type nfs4_remote_referral_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs4_remote_referral_get_sb,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
 struct file_system_type nfs4_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
@@ -2330,12 +2351,12 @@ out_no_client_address:
 }
 
 /*
- * Get the superblock for an NFS4 mountpoint
+ * Get the superblock for the NFS4 root partition
  */
-static int nfs4_get_sb(struct file_system_type *fs_type,
+static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
-	struct nfs_parsed_mount_data *data;
+	struct nfs_parsed_mount_data *data = raw_data;
 	struct super_block *s;
 	struct nfs_server *server;
 	struct nfs_fh *mntfh;
@@ -2346,18 +2367,12 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	};
 	int error = -ENOMEM;
 
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	mntfh = kzalloc(sizeof(*mntfh), GFP_KERNEL);
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;
 
 	security_init_mnt_opts(&data->lsm_opts);
 
-	/* Validate the mount data */
-	error = nfs4_validate_mount_data(raw_data, data, dev_name);
-	if (error < 0)
-		goto out;
-
 	/* Get a volume representation */
 	server = nfs4_create_server(data, mntfh);
 	if (IS_ERR(server)) {
@@ -2370,7 +2385,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_free;
@@ -2406,13 +2421,9 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	error = 0;
 
 out:
-	kfree(data->client_address);
-	kfree(data->nfs_server.export_path);
-	kfree(data->nfs_server.hostname);
 	security_free_mnt_opts(&data->lsm_opts);
 out_free_fh:
 	kfree(mntfh);
-	kfree(data);
 	return error;
 
 out_free:
@@ -2427,6 +2438,75 @@ error_splat_super:
 	goto out;
 }
 
+static int nfs_follow_remote_path(struct vfsmount *root_mnt,
+		const char *export_path, struct vfsmount *mnt_target)
+{
+	struct nameidata nd;
+	struct super_block *s;
+	int error;
+
+	error = vfs_remote_path_lookup(root_mnt->mnt_root, root_mnt,
+			export_path, LOOKUP_FOLLOW, &nd);
+
+	mntput(root_mnt);
+	if (error)
+		return error;
+
+	s = nd.path.mnt->mnt_sb;
+	down_write(&s->s_umount);
+	if (s->s_root) {
+		atomic_inc(&s->s_active);
+		mnt_target->mnt_root = dget(nd.path.dentry);
+		mnt_target->mnt_sb = s;
+		s->s_flags |= MS_ACTIVE;
+	}
+
+	path_put(&nd.path);
+	return 0;
+}
+
+/*
+ * Get the superblock for an NFS4 mountpoint
+ */
+static int nfs4_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	struct nfs_parsed_mount_data *data;
+	char *export_path;
+	struct vfsmount *root_mnt;
+	int error = -ENOMEM;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (data == NULL)
+		goto out_free_data;
+
+	/* Validate the mount data */
+	error = nfs4_validate_mount_data(raw_data, data, dev_name);
+	if (error < 0)
+		goto out;
+
+	export_path = data->nfs_server.export_path;
+	data->nfs_server.export_path = "/";
+	root_mnt = vfs_kern_mount(&nfs4_remote_fs_type, flags, dev_name, data);
+	data->nfs_server.export_path = export_path;
+
+	error = PTR_ERR(root_mnt);
+	if (IS_ERR(root_mnt))
+		goto out;
+
+	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
+
+out:
+	kfree(data->client_address);
+	kfree(data->nfs_server.export_path);
+	kfree(data->nfs_server.hostname);
+out_free_data:
+	kfree(data);
+	dprintk("<-- nfs4_referral_get_sb() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+	return error;
+}
+
 static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
@@ -2522,12 +2602,9 @@ error_splat_super:
 	return error;
 }
 
-/*
- * Create an NFS4 server record on referral traversal
- */
-static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
-				const char *dev_name, void *raw_data,
-				struct vfsmount *mnt)
+static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data,
+		struct vfsmount *mnt)
 {
 	struct nfs_clone_mount *data = raw_data;
 	struct super_block *s;
@@ -2607,4 +2684,36 @@ error_splat_super:
 	return error;
 }
 
+/*
+ * Create an NFS4 server record on referral traversal
+ */
+static int nfs4_referral_get_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data,
+		struct vfsmount *mnt)
+{
+	struct nfs_clone_mount *data = raw_data;
+	char *export_path;
+	struct vfsmount *root_mnt;
+	int error;
+
+	dprintk("--> nfs4_referral_get_sb()\n");
+
+	export_path = data->mnt_path;
+	data->mnt_path = "/";
+
+	root_mnt = vfs_kern_mount(&nfs4_remote_referral_fs_type,
+			flags, dev_name, data);
+	data->mnt_path = export_path;
+
+	error = PTR_ERR(root_mnt);
+	if (IS_ERR(root_mnt))
+		goto out;
+
+	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
+out:
+	dprintk("<-- nfs4_referral_get_sb() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+	return error;
+}
+
 #endif /* CONFIG_NFS_V4 */

