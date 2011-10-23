Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:38625 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294Ab1JWRot (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2011 13:44:49 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V8 09/26] vfs: Add delete child and delete self permission flags
Date: Sun, 23 Oct 2011 23:13:38 +0530
Message-Id: <1319391835-5829-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Normally, deleting a file requires write access to the parent directory.
Some permission models use a different permission on the parent
directory to indicate delete access.  In addition, a process can have
per-file delete access even without delete access on the parent
directory.

Introduce two new inode_permission() mask flags and use them in
may_delete()

Acked-by: J. Bruce Fields <bfields@redhat.com>
Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |   53 +++++++++++++++++++++++++++++++++++++--------------
 include/linux/fs.h |    2 +
 2 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index f6184b8..044b6d1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
  * are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -1835,11 +1835,25 @@ static int user_path_parent(int dfd, const char __user *path,
 	return error;
 }
 
+
+/*
+ * We should have exec permission on directory and MAY_DELETE_SELF
+ * on the object being deleted.
+ */
+static int richacl_may_selfdelete(struct inode *dir,
+				  struct inode *inode, int replace_mask)
+{
+	return (IS_RICHACL(inode) &&
+		(inode_permission(dir, MAY_EXEC | replace_mask) == 0) &&
+		(inode_permission(inode, MAY_DELETE_SELF) == 0));
+}
+
 /*
  * It's inline, so penalty for filesystems that don't use sticky bit is
  * minimal.
  */
-static inline int check_sticky(struct inode *dir, struct inode *inode)
+static inline int check_sticky(struct inode *dir,
+			       struct inode *inode, int replace_mask)
 {
 	uid_t fsuid = current_fsuid();
 
@@ -1851,7 +1865,8 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
 		return 0;
 	if (dir->i_uid == fsuid)
 		return 0;
-
+	if (richacl_may_selfdelete(dir, inode, replace_mask))
+		return 0;
 other_userns:
 	return !ns_capable(inode_userns(inode), CAP_FOWNER);
 }
@@ -1875,30 +1890,38 @@ other_userns:
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      int isdir, int replace)
 {
-	int error;
+	int mask, replace_mask = 0, error;
+	struct inode *inode = victim->d_inode;
 
-	if (!victim->d_inode)
+	if (!inode)
 		return -ENOENT;
 
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(victim, dir);
 
-	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
+	if (replace)
+		replace_mask = S_ISDIR(inode->i_mode) ?
+				MAY_CREATE_DIR : MAY_CREATE_FILE;
+	error = inode_permission(dir, mask | replace_mask);
+	if (error && richacl_may_selfdelete(dir, inode, replace_mask))
+		error = 0;
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
 		return -EPERM;
-	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
-	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
+	if (check_sticky(dir, inode, replace_mask) || IS_APPEND(inode) ||
+	    IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
 		return -EPERM;
 	if (isdir) {
-		if (!S_ISDIR(victim->d_inode->i_mode))
+		if (!S_ISDIR(inode->i_mode))
 			return -ENOTDIR;
 		if (IS_ROOT(victim))
 			return -EBUSY;
-	} else if (S_ISDIR(victim->d_inode->i_mode))
+	} else if (S_ISDIR(inode->i_mode))
 		return -EISDIR;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
@@ -2605,7 +2628,7 @@ void dentry_unhash(struct dentry *dentry)
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, 1, 0);
 
 	if (error)
 		return error;
@@ -2700,7 +2723,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 
 int vfs_unlink(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, 0, 0);
 
 	if (error)
 		return error;
@@ -3096,14 +3119,14 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (old_dentry->d_inode == new_dentry->d_inode)
  		return 0;
  
-	error = may_delete(old_dir, old_dentry, is_dir);
+	error = may_delete(old_dir, old_dentry, is_dir, 0);
 	if (error)
 		return error;
 
 	if (!new_dentry->d_inode)
 		error = may_create(new_dir, new_dentry, is_dir);
 	else
-		error = may_delete(new_dir, new_dentry, is_dir);
+		error = may_delete(new_dir, new_dentry, is_dir, 1);
 	if (error)
 		return error;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 60361c6..ccece40 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -69,6 +69,8 @@ struct inodes_stat_t {
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.5.4

