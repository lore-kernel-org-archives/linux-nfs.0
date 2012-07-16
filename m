Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2020 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab2GPUj0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:26 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/12] NFS: Split out NFS v4 inode operations
Date: Mon, 16 Jul 2012 16:39:12 -0400
Message-Id: <1342471161-22452-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The NFS v4 file inode operations are already already in nfs4proc.c, so
this patch just needs to move the directory operations to the same file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c      | 33 +++------------------------------
 fs/nfs/nfs4_fs.h  |  5 ++++-
 fs/nfs/nfs4proc.c | 20 ++++++++++++++++++++
 3 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e75f2aa..d49f1b9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -63,33 +63,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V4
-
-static int nfs_atomic_open(struct inode *, struct dentry *,
-			   struct file *, unsigned, umode_t,
-			   int *);
-const struct inode_operations nfs4_dir_inode_operations = {
-	.create		= nfs_create,
-	.lookup		= nfs_lookup,
-	.atomic_open	= nfs_atomic_open,
-	.link		= nfs_link,
-	.unlink		= nfs_unlink,
-	.symlink	= nfs_symlink,
-	.mkdir		= nfs_mkdir,
-	.rmdir		= nfs_rmdir,
-	.mknod		= nfs_mknod,
-	.rename		= nfs_rename,
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.getxattr	= generic_getxattr,
-	.setxattr	= generic_setxattr,
-	.listxattr	= generic_listxattr,
-	.removexattr	= generic_removexattr,
-};
-
-#endif /* CONFIG_NFS_V4 */
-
 static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir, struct rpc_cred *cred)
 {
 	struct nfs_open_dir_context *ctx;
@@ -1352,9 +1325,9 @@ out:
 	return err;
 }
 
-static int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
-			    struct file *file, unsigned open_flags,
-			    umode_t mode, int *opened)
+int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
+		    struct file *file, unsigned open_flags,
+		    umode_t mode, int *opened)
 {
 	struct nfs_open_context *ctx;
 	struct dentry *res;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3696ca7..e2c4c72 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -200,7 +200,10 @@ struct nfs4_state_maintenance_ops {
 };
 
 extern const struct dentry_operations nfs4_dentry_operations;
-extern const struct inode_operations nfs4_dir_inode_operations;
+
+/* dir.c */
+int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
+		    unsigned, umode_t, int *);
 
 /* write.c */
 int nfs4_write_inode(struct inode *, struct writeback_control *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 80bb505..689cb43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6813,6 +6813,26 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 #endif
 };
 
+const struct inode_operations nfs4_dir_inode_operations = {
+	.create		= nfs_create,
+	.lookup		= nfs_lookup,
+	.atomic_open	= nfs_atomic_open,
+	.link		= nfs_link,
+	.unlink		= nfs_unlink,
+	.symlink	= nfs_symlink,
+	.mkdir		= nfs_mkdir,
+	.rmdir		= nfs_rmdir,
+	.mknod		= nfs_mknod,
+	.rename		= nfs_rename,
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.listxattr	= generic_listxattr,
+	.removexattr	= generic_removexattr,
+};
+
 static const struct inode_operations nfs4_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
-- 
1.7.11.2

