Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab2AMULS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:18 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 13/44] NFS: Remove unused code
Date: Fri, 13 Jan 2012 15:10:22 -0500
Message-Id: <1326485453-1350-14-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These structures and functions are no longer needed in the generic
client since they are defined in the NFS v2 and v3 modules.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c        |    8 --------
 fs/nfs/dir.c           |   23 -----------------------
 fs/nfs/file.c          |   19 -------------------
 include/linux/nfs_fs.h |   26 --------------------------
 4 files changed, 0 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ffb5994..1e1bbf8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -803,19 +803,11 @@ static int nfs_start_lockd(struct nfs_server *server)
 /*
  * Initialise an NFSv3 ACL client connection
  */
-#ifdef CONFIG_NFS_V3_ACL
 static void nfs_init_server_aclclient(struct nfs_server *server)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
 	server->caps &= ~NFS_CAP_ACLS;
 }
-#else
-static inline void nfs_init_server_aclclient(struct nfs_server *server)
-{
-	server->flags &= ~NFS_MOUNT_NOACL;
-	server->caps &= ~NFS_CAP_ACLS;
-}
-#endif
 
 /*
  * Create a general RPC client
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 41a5161..0348727 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -61,21 +61,6 @@ const struct file_operations nfs_dir_operations = {
 	.fsync		= nfs_fsync_dir,
 };
 
-const struct inode_operations nfs_dir_inode_operations = {
-	.create		= nfs_create,
-	.lookup		= nfs_lookup,
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
-};
-
 const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
@@ -1230,14 +1215,6 @@ void nfs_d_release(struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(nfs_d_release);
 
-const struct dentry_operations nfs_dentry_operations = {
-	.d_revalidate	= nfs_lookup_revalidate,
-	.d_delete	= nfs_dentry_delete,
-	.d_iput		= nfs_dentry_iput,
-	.d_automount	= nfs_d_automount,
-	.d_release	= nfs_d_release,
-};
-
 struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 74c47eb..d9f11c5 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -845,25 +845,6 @@ int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 }
 EXPORT_SYMBOL_GPL(nfs_setlease);
 
-const struct file_operations nfs_file_operations = {
-	.llseek		= nfs_file_llseek,
-	.read		= do_sync_read,
-	.write		= do_sync_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
-	.mmap		= nfs_file_mmap,
-	.open		= nfs_file_open,
-	.flush		= nfs_file_flush,
-	.release	= nfs_file_release,
-	.fsync		= nfs_file_fsync,
-	.lock		= nfs_lock,
-	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= nfs_file_splice_write,
-	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
-};
-
 #ifdef CONFIG_NFS_V4
 static int
 nfs4_file_open(struct inode *inode, struct file *filp)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 666ebea..4814fcc 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -405,11 +405,6 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
 /*
  * linux/fs/nfs/file.c
  */
-extern const struct inode_operations nfs_file_inode_operations;
-#if IS_ENABLED(CONFIG_NFS_V3)
-extern const struct inode_operations nfs3_file_inode_operations;
-#endif /* CONFIG_NFS_V3 */
-extern const struct file_operations nfs_file_operations;
 #ifdef CONFIG_NFS_V4
 extern const struct file_operations nfs4_file_operations;
 #endif /* CONFIG_NFS_V4 */
@@ -433,22 +428,6 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
 }
 
 /*
- * linux/fs/nfs/xattr.c
- */
-#ifdef CONFIG_NFS_V3_ACL
-extern ssize_t nfs3_listxattr(struct dentry *, char *, size_t);
-extern ssize_t nfs3_getxattr(struct dentry *, const char *, void *, size_t);
-extern int nfs3_setxattr(struct dentry *, const char *,
-			const void *, size_t, int);
-extern int nfs3_removexattr (struct dentry *, const char *name);
-#else
-# define nfs3_listxattr NULL
-# define nfs3_getxattr NULL
-# define nfs3_setxattr NULL
-# define nfs3_removexattr NULL
-#endif
-
-/*
  * linux/fs/nfs/direct.c
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, const struct iovec *, loff_t,
@@ -463,12 +442,7 @@ extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
 /*
  * linux/fs/nfs/dir.c
  */
-extern const struct inode_operations nfs_dir_inode_operations;
-#if IS_ENABLED(CONFIG_NFS_V3)
-extern const struct inode_operations nfs3_dir_inode_operations;
-#endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_dir_operations;
-extern const struct dentry_operations nfs_dentry_operations;
 
 extern void nfs_force_lookup_revalidate(struct inode *dir);
 extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr);
-- 
1.7.8.3

