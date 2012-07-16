Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2020 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab2GPUjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:25 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/12] NFS: Split out NFS v3 inode operations
Date: Mon, 16 Jul 2012 16:39:11 -0400
Message-Id: <1342471161-22452-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch moves the NFS v3 file and directory inode functions into
files that are only compiled whet CONFIG_NFS_V3 is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c           | 21 ---------------------
 fs/nfs/file.c          | 12 ------------
 fs/nfs/nfs3proc.c      | 29 +++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |  6 ------
 4 files changed, 29 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9ae329d..e75f2aa 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -63,27 +63,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V3
-const struct inode_operations nfs3_dir_inode_operations = {
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
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_V3 */
-
 #ifdef CONFIG_NFS_V4
 
 static int nfs_atomic_open(struct inode *, struct dentry *,
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7da8745..7623917 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -41,18 +41,6 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-#ifdef CONFIG_NFS_V3
-const struct inode_operations nfs3_file_inode_operations = {
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_v3 */
-
 /* Hack for future NFS swap support */
 #ifndef IS_SWAPFILE
 # define IS_SWAPFILE(inode)	(0)
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index f580358..65d23eb 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -888,6 +888,35 @@ static int nfs3_return_delegation(struct inode *inode)
 	return 0;
 }
 
+static const struct inode_operations nfs3_dir_inode_operations = {
+	.create		= nfs_create,
+	.lookup		= nfs_lookup,
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
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
+static const struct inode_operations nfs3_file_inode_operations = {
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
 const struct nfs_rpc_ops nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6c38bc9..4b6043c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -427,9 +427,6 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
 /*
  * linux/fs/nfs/file.c
  */
-#ifdef CONFIG_NFS_V3
-extern const struct inode_operations nfs3_file_inode_operations;
-#endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
 #ifdef CONFIG_NFS_V4
 extern const struct file_operations nfs4_file_operations;
@@ -484,9 +481,6 @@ extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
 /*
  * linux/fs/nfs/dir.c
  */
-#ifdef CONFIG_NFS_V3
-extern const struct inode_operations nfs3_dir_inode_operations;
-#endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_dir_operations;
 extern const struct dentry_operations nfs_dentry_operations;
 
-- 
1.7.11.2

