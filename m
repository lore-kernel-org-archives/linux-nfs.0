Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34437 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550AbbGVNEF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 09:04:05 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, samba-technical@lists.samba.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v5 02/39] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR permission flags
Date: Wed, 22 Jul 2015 15:02:52 +0200
Message-Id: <1437570209-29832-3-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Richacls distinguish between creating non-directories and directories. To
support that, add an isdir parameter to may_create(). When checking
inode_permission() for create permission, pass in an additional MAY_CREATE_FILE
or MAY_CREATE_DIR mask flag.

To allow checking for delete *and* create access when replacing an existing
file via vfs_rename(), add a replace parameter to may_delete().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c         | 42 ++++++++++++++++++++++++------------------
 include/linux/fs.h |  2 ++
 2 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 23dfaae..1e2b1fa 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -453,7 +453,8 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * this, letting us set arbitrary permissions for filesystem access without
  * changing the "normal" UIDs which are used for other things.
  *
- * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
+ * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
+ * MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2517,10 +2518,11 @@ EXPORT_SYMBOL(__check_sticky);
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      bool isdir, bool replace)
 {
 	struct inode *inode = d_backing_inode(victim);
-	int error;
+	int error, mask = MAY_WRITE | MAY_EXEC;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2529,7 +2531,9 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
-	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	if (replace)
+		mask |= isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
+	error = inode_permission(dir, mask);
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
@@ -2560,14 +2564,16 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
  *  3. We should have write and exec permissions on dir
  *  4. We can't do it if dir is immutable (done in permission())
  */
-static inline int may_create(struct inode *dir, struct dentry *child)
+static inline int may_create(struct inode *dir, struct dentry *child, bool isdir)
 {
+	int mask = isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
+
 	audit_inode_child(dir, child, AUDIT_TYPE_CHILD_CREATE);
 	if (child->d_inode)
 		return -EEXIST;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
-	return inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	return inode_permission(dir, MAY_WRITE | MAY_EXEC | mask);
 }
 
 /*
@@ -2617,7 +2623,7 @@ EXPORT_SYMBOL(unlock_rename);
 int vfs_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 		bool want_excl)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 	if (error)
 		return error;
 
@@ -3462,7 +3468,7 @@ EXPORT_SYMBOL(user_path_create);
 
 int vfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 
 	if (error)
 		return error;
@@ -3554,7 +3560,7 @@ SYSCALL_DEFINE3(mknod, const char __user *, filename, umode_t, mode, unsigned, d
 
 int vfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, true);
 	unsigned max_links = dir->i_sb->s_max_links;
 
 	if (error)
@@ -3635,7 +3641,7 @@ EXPORT_SYMBOL(dentry_unhash);
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, true, false);
 
 	if (error)
 		return error;
@@ -3757,7 +3763,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
 {
 	struct inode *target = dentry->d_inode;
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, false, false);
 
 	if (error)
 		return error;
@@ -3891,7 +3897,7 @@ SYSCALL_DEFINE1(unlink, const char __user *, pathname)
 
 int vfs_symlink(struct inode *dir, struct dentry *dentry, const char *oldname)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 
 	if (error)
 		return error;
@@ -3974,7 +3980,7 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	if (!inode)
 		return -ENOENT;
 
-	error = may_create(dir, new_dentry);
+	error = may_create(dir, new_dentry, false);
 	if (error)
 		return error;
 
@@ -4162,19 +4168,19 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (source == target)
 		return 0;
 
-	error = may_delete(old_dir, old_dentry, is_dir);
+	error = may_delete(old_dir, old_dentry, is_dir, false);
 	if (error)
 		return error;
 
 	if (!target) {
-		error = may_create(new_dir, new_dentry);
+		error = may_create(new_dir, new_dentry, is_dir);
 	} else {
 		new_is_dir = d_is_dir(new_dentry);
 
 		if (!(flags & RENAME_EXCHANGE))
-			error = may_delete(new_dir, new_dentry, is_dir);
+			error = may_delete(new_dir, new_dentry, is_dir, true);
 		else
-			error = may_delete(new_dir, new_dentry, new_is_dir);
+			error = may_delete(new_dir, new_dentry, new_is_dir, true);
 	}
 	if (error)
 		return error;
@@ -4437,7 +4443,7 @@ SYSCALL_DEFINE2(rename, const char __user *, oldname, const char __user *, newna
 
 int vfs_whiteout(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 	if (error)
 		return error;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 44e696e..9c44f27 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -81,6 +81,8 @@ typedef void (dax_iodone_t)(struct buffer_head *bh_map, int uptodate);
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+#define MAY_CREATE_FILE		0x00000100
+#define MAY_CREATE_DIR		0x00000200
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.4.3

