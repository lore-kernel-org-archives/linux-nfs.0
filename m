Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:35359 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbaD0QPb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:31 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:29 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 06/22] vfs: Add delete child and delete self permission flags
Date: Sun, 27 Apr 2014 21:44:37 +0530
Message-Id: <1398615293-22931-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         | 45 ++++++++++++++++++++++++++++++++++-----------
 include/linux/fs.h |  2 ++
 2 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 028bc8bcf77c..56ac7613fbca 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -446,7 +446,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * changing the "normal" UIDs which are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2366,11 +2366,25 @@ kern_path_mountpoint(int dfd, const char *name, struct path *path,
 }
 EXPORT_SYMBOL(kern_path_mountpoint);
 
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
 	kuid_t fsuid = current_fsuid();
 
@@ -2380,6 +2394,8 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
 		return 0;
 	if (uid_eq(dir->i_uid, fsuid))
 		return 0;
+	if (richacl_may_selfdelete(dir, inode, replace_mask))
+		return 0;
 	return !inode_capable(inode, CAP_FOWNER);
 }
 
@@ -2402,10 +2418,11 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      bool isdir, bool replace)
 {
 	struct inode *inode = victim->d_inode;
-	int error;
+	int error, mask, replace_mask = 0;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2414,13 +2431,19 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
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
 
-	if (check_sticky(dir, inode) || IS_APPEND(inode) ||
+	if (check_sticky(dir, inode, replace_mask) || IS_APPEND(inode) ||
 	    IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
 		return -EPERM;
 	if (isdir) {
@@ -3539,7 +3562,7 @@ EXPORT_SYMBOL(dentry_unhash);
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, 1, 0);
 
 	if (error)
 		return error;
@@ -3658,7 +3681,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
 {
 	struct inode *target = dentry->d_inode;
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, 0, 0);
 
 	if (error)
 		return error;
@@ -4060,7 +4083,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (source == target)
 		return 0;
 
-	error = may_delete(old_dir, old_dentry, is_dir);
+	error = may_delete(old_dir, old_dentry, is_dir, 0);
 	if (error)
 		return error;
 
@@ -4070,9 +4093,9 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		new_is_dir = d_is_dir(new_dentry);
 
 		if (!(flags & RENAME_EXCHANGE))
-			error = may_delete(new_dir, new_dentry, is_dir);
+			error = may_delete(new_dir, new_dentry, is_dir, 1);
 		else
-			error = may_delete(new_dir, new_dentry, new_is_dir);
+			error = may_delete(new_dir, new_dentry, new_is_dir, 1);
 	}
 	if (error)
 		return error;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index da5521de04ab..3f0ad0f2bce8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -79,6 +79,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.9.1

