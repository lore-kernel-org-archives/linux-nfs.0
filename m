From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/5] NFSv4: Replace nfs4_path_walk() with VFS path lookup
 in a private namespace
Date: Mon, 22 Jun 2009 15:09:14 -0400
Message-ID: <20090622190913.27923.97876.stgit@heimdal.trondhjem.org>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As noted in the previous patch, the NFSv4 client mount code currently
has several limitations. If the mount path contains symlinks, or
referrals, or even if it just contains a '..', then the client code in
nfs4_path_walk() will fail with an error.

This patch replaces the nfs4_path_walk()-based lookup with a helper
function that sets up a private namespace to represent the namespace on the
server, then uses the ordinary VFS and NFS path lookup code to walk down the
mount path in that namespace.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |  178 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 157 insertions(+), 21 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b798ed1..8da7e59 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -42,6 +42,8 @@
 #include <linux/smp_lock.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
+#include <linux/mnt_namespace.h>
+#include <linux/namei.h>
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
@@ -270,10 +272,14 @@ static const struct super_operations nfs_sops = {
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
@@ -284,6 +290,14 @@ static struct file_system_type nfs4_fs_type = {
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
@@ -292,6 +306,14 @@ struct file_system_type nfs4_xdev_fs_type = {
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
@@ -2422,12 +2444,12 @@ out_no_client_address:
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
@@ -2438,18 +2460,12 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
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
@@ -2462,7 +2478,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_free;
@@ -2499,14 +2515,9 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	error = 0;
 
 out:
-	kfree(data->client_address);
-	kfree(data->nfs_server.export_path);
-	kfree(data->nfs_server.hostname);
-	kfree(data->fscache_uniq);
 	security_free_mnt_opts(&data->lsm_opts);
 out_free_fh:
 	kfree(mntfh);
-	kfree(data);
 	return error;
 
 out_free:
@@ -2520,6 +2531,102 @@ error_splat_super:
 	goto out;
 }
 
+static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
+		int flags, void *data, const char *hostname)
+{
+	struct vfsmount *root_mnt;
+	char *root_devname;
+	size_t len;
+
+	len = strlen(hostname) + 3;
+	root_devname = kmalloc(len, GFP_KERNEL);
+	if (root_devname == NULL)
+		return ERR_PTR(-ENOMEM);
+	snprintf(root_devname, len, "%s:/", hostname);
+	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
+	kfree(root_devname);
+	return root_mnt;
+}
+
+static int nfs_follow_remote_path(struct vfsmount *root_mnt,
+		const char *export_path, struct vfsmount *mnt_target)
+{
+	struct mnt_namespace *ns_private;
+	struct nameidata nd;
+	struct super_block *s;
+	int ret;
+
+	ns_private = create_mnt_ns(root_mnt);
+	ret = PTR_ERR(ns_private);
+	if (IS_ERR(ns_private))
+		goto out_mntput;
+
+	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt,
+			export_path, LOOKUP_FOLLOW, &nd);
+
+	put_mnt_ns(ns_private);
+
+	if (ret != 0)
+		goto out_err;
+
+	s = nd.path.mnt->mnt_sb;
+	atomic_inc(&s->s_active);
+	mnt_target->mnt_sb = s;
+	mnt_target->mnt_root = dget(nd.path.dentry);
+
+	path_put(&nd.path);
+	down_write(&s->s_umount);
+	return 0;
+out_mntput:
+	mntput(root_mnt);
+out_err:
+	return ret;
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
+	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
+			data->nfs_server.hostname);
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
+	kfree(data->fscache_uniq);
+out_free_data:
+	kfree(data);
+	dprintk("<-- nfs4_get_sb() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+	return error;
+}
+
 static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
@@ -2615,12 +2722,9 @@ error_splat_super:
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
@@ -2699,4 +2803,36 @@ error_splat_super:
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
+	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
+			flags, data, data->hostname);
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

