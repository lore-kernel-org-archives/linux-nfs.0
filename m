Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:38610 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab1JWRoo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2011 13:44:44 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V8 08/26] vfs: Add new file and directory create permission flags
Date: Sun, 23 Oct 2011 23:13:37 +0530
Message-Id: <1319391835-5829-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Some permission models distinguish between the permission to create a
non-directory and a directory.  Pass this information down to
inode_permission() as mask flags

Acked-by: J. Bruce Fields <bfields@redhat.com>
Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |   26 +++++++++++++++-----------
 include/linux/fs.h |    2 ++
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index cf8b2f0..f6184b8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -336,7 +336,8 @@ static inline int do_inode_permission(struct inode *inode, int mask)
  * for filesystem access without changing the "normal" uids which
  * are used for other things.
  *
- * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
+ * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
+ * MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -1914,13 +1915,15 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
  *  3. We should have write and exec permissions on dir
  *  4. We can't do it if dir is immutable (done in permission())
  */
-static inline int may_create(struct inode *dir, struct dentry *child)
+static inline int may_create(struct inode *dir, struct dentry *child, int isdir)
 {
+	int mask = isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
+
 	if (child->d_inode)
 		return -EEXIST;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
-	return inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	return inode_permission(dir, MAY_WRITE | MAY_EXEC | mask);
 }
 
 /*
@@ -1968,7 +1971,7 @@ void unlock_rename(struct dentry *p1, struct dentry *p2)
 int vfs_create(struct inode *dir, struct dentry *dentry, int mode,
 		struct nameidata *nd)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -2427,7 +2430,7 @@ EXPORT_SYMBOL(user_path_create);
 
 int vfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -2524,7 +2527,7 @@ SYSCALL_DEFINE3(mknod, const char __user *, filename, int, mode, unsigned, dev)
 
 int vfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 1);
 
 	if (error)
 		return error;
@@ -2806,7 +2809,7 @@ SYSCALL_DEFINE1(unlink, const char __user *, pathname)
 
 int vfs_symlink(struct inode *dir, struct dentry *dentry, const char *oldname)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -2872,7 +2875,10 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	if (!inode)
 		return -ENOENT;
 
-	error = may_create(dir, new_dentry);
+	if (S_ISDIR(inode->i_mode))
+		return -EPERM;
+
+	error = may_create(dir, new_dentry, 0);
 	if (error)
 		return error;
 
@@ -2886,8 +2892,6 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 		return -EPERM;
 	if (!dir->i_op->link)
 		return -EPERM;
-	if (S_ISDIR(inode->i_mode))
-		return -EPERM;
 
 	error = security_inode_link(old_dentry, dir, new_dentry);
 	if (error)
@@ -3097,7 +3101,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	if (!new_dentry->d_inode)
-		error = may_create(new_dir, new_dentry);
+		error = may_create(new_dir, new_dentry, is_dir);
 	else
 		error = may_delete(new_dir, new_dentry, is_dir);
 	if (error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f3ebf86..60361c6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -67,6 +67,8 @@ struct inodes_stat_t {
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+#define MAY_CREATE_FILE		0x00000100
+#define MAY_CREATE_DIR		0x00000200
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.5.4

