Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869Ab2GJQQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:16:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/12] NFS: Split out NFS v2 inode operations
Date: Tue, 10 Jul 2012 12:16:06 -0400
Message-Id: <1341936977-21186-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
References: <1341936977-21186-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch moves the NFS v2 file and directory inode functions into
files that are only compiled whet CONFIG_NFS_V2 is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c           | 43 +++++++++----------------------------------
 fs/nfs/file.c          |  6 ------
 fs/nfs/internal.h      |  9 +++++++++
 fs/nfs/proc.c          | 21 +++++++++++++++++++++
 include/linux/nfs_fs.h |  2 --
 5 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 68e451f..42fa02d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -46,16 +46,6 @@
 static int nfs_opendir(struct inode *, struct file *);
 static int nfs_closedir(struct inode *, struct file *);
 static int nfs_readdir(struct file *, void *, filldir_t);
-static struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
-static int nfs_create(struct inode *, struct dentry *, umode_t, struct nameidata *);
-static int nfs_mkdir(struct inode *, struct dentry *, umode_t);
-static int nfs_rmdir(struct inode *, struct dentry *);
-static int nfs_unlink(struct inode *, struct dentry *);
-static int nfs_symlink(struct inode *, struct dentry *, const char *);
-static int nfs_link(struct dentry *, struct inode *, struct dentry *);
-static int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
-static int nfs_rename(struct inode *, struct dentry *,
-		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, loff_t, loff_t, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static void nfs_readdir_clear_array(struct page*);
@@ -69,21 +59,6 @@ const struct file_operations nfs_dir_operations = {
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
@@ -1286,7 +1261,7 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_release	= nfs_d_release,
 };
 
-static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
+struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
 	struct dentry *parent;
@@ -1657,7 +1632,7 @@ out_error:
  * that the operation succeeded on the server, but an error in the
  * reply path made it appear to have failed.
  */
-static int nfs_create(struct inode *dir, struct dentry *dentry,
+int nfs_create(struct inode *dir, struct dentry *dentry,
 		umode_t mode, struct nameidata *nd)
 {
 	struct iattr attr;
@@ -1685,7 +1660,7 @@ out_err:
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int
+int
 nfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t rdev)
 {
 	struct iattr attr;
@@ -1712,7 +1687,7 @@ out_err:
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int nfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
+int nfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	struct iattr attr;
 	int error;
@@ -1738,7 +1713,7 @@ static void nfs_dentry_handle_enoent(struct dentry *dentry)
 		d_delete(dentry);
 }
 
-static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
+int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 
@@ -1797,7 +1772,7 @@ out:
  *
  *  If sillyrename() returns 0, we do nothing, otherwise we unlink.
  */
-static int nfs_unlink(struct inode *dir, struct dentry *dentry)
+int nfs_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 	int need_rehash = 0;
@@ -1841,7 +1816,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
  * now have a new file handle and can instantiate an in-core NFS inode
  * and move the raw page into its mapping.
  */
-static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct pagevec lru_pvec;
 	struct page *page;
@@ -1896,7 +1871,7 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	return 0;
 }
 
-static int 
+int
 nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = old_dentry->d_inode;
@@ -1941,7 +1916,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
  * If these conditions are met, we can drop the dentries before doing
  * the rename.
  */
-static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
+int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		      struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *old_inode = old_dentry->d_inode;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 57a22a1..7da8745 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -41,12 +41,6 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-const struct inode_operations nfs_file_inode_operations = {
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-};
-
 #ifdef CONFIG_NFS_V3
 const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7edc172..6640c27 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -247,6 +247,15 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
 					struct shrink_control *sc);
+struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_create(struct inode *, struct dentry *, umode_t, struct nameidata *);
+int nfs_mkdir(struct inode *, struct dentry *, umode_t);
+int nfs_rmdir(struct inode *, struct dentry *);
+int nfs_unlink(struct inode *, struct dentry *);
+int nfs_symlink(struct inode *, struct dentry *, const char *);
+int nfs_link(struct dentry *, struct inode *, struct dentry *);
+int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
+int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index cf64997..5a01929 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -745,6 +745,27 @@ static int nfs_return_delegation(struct inode *inode)
 	return 0;
 }
 
+static const struct inode_operations nfs_dir_inode_operations = {
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
+};
+
+static const struct inode_operations nfs_file_inode_operations = {
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+};
+
 const struct nfs_rpc_ops nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b23cfc1..6c38bc9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -427,7 +427,6 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
 /*
  * linux/fs/nfs/file.c
  */
-extern const struct inode_operations nfs_file_inode_operations;
 #ifdef CONFIG_NFS_V3
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
@@ -485,7 +484,6 @@ extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
 /*
  * linux/fs/nfs/dir.c
  */
-extern const struct inode_operations nfs_dir_inode_operations;
 #ifdef CONFIG_NFS_V3
 extern const struct inode_operations nfs3_dir_inode_operations;
 #endif /* CONFIG_NFS_V3 */
-- 
1.7.11.1

