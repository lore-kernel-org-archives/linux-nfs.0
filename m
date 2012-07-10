Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869Ab2GJQQV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:16:21 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/12] NFS: Split out NFS v4 inode operations
Date: Tue, 10 Jul 2012 12:16:08 -0400
Message-Id: <1341936977-21186-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
References: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The NFS v4 file inode operations are already already in nfs4proc.c, so
this patch just needs to move the directory operations to the same file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c      | 29 ++---------------------------
 fs/nfs/nfs4_fs.h  |  5 ++++-
 fs/nfs/nfs4proc.c | 19 +++++++++++++++++++
 3 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index df78921..207cb18 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -63,31 +63,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V4
-
-static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
-static int nfs_open_create(struct inode *dir, struct dentry *dentry, umode_t mode, struct nameidata *nd);
-const struct inode_operations nfs4_dir_inode_operations = {
-	.create		= nfs_open_create,
-	.lookup		= nfs_atomic_lookup,
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
@@ -1380,7 +1355,7 @@ out:
 	return ret;
 }
 
-static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
 	struct nfs_open_context *ctx;
 	struct iattr attr;
@@ -1520,7 +1495,7 @@ no_open:
 	return nfs_lookup_revalidate(dentry, nd);
 }
 
-static int nfs_open_create(struct inode *dir, struct dentry *dentry,
+int nfs_open_create(struct inode *dir, struct dentry *dentry,
 		umode_t mode, struct nameidata *nd)
 {
 	struct nfs_open_context *ctx = NULL;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3696ca7..b610c7e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -200,7 +200,10 @@ struct nfs4_state_maintenance_ops {
 };
 
 extern const struct dentry_operations nfs4_dentry_operations;
-extern const struct inode_operations nfs4_dir_inode_operations;
+
+/* dir.c */
+struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_open_create(struct inode *, struct dentry *, umode_t, struct nameidata *);
 
 /* write.c */
 int nfs4_write_inode(struct inode *, struct writeback_control *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7d387cb..f8ab633 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6748,6 +6748,25 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 #endif
 };
 
+static const struct inode_operations nfs4_dir_inode_operations = {
+	.create		= nfs_open_create,
+	.lookup		= nfs_atomic_lookup,
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
1.7.11.1

