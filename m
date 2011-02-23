Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:52542 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1BWNxi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:53:38 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 07/24] vfs: Add new file and directory create permission flags
Date: Wed, 23 Feb 2011 19:21:54 +0530
Message-Id: <1298469131-16555-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

Some permission models distinguish between the permission to create a
non-directory and a directory.  Pass this information down to
inode_permission() as mask flags

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |   26 +++++++++++++++-----------
 include/linux/fs.h |    2 ++
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b1e5104..b4f7198 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -252,7 +252,8 @@ int generic_permission(struct inode *inode, int mask, unsigned int flags,
  * for filesystem access without changing the "normal" uids which
  * are used for other things.
  *
- * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
+ * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
+ * MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2005,13 +2006,15 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
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
@@ -2059,7 +2062,7 @@ void unlock_rename(struct dentry *p1, struct dentry *p2)
 int vfs_create(struct inode *dir, struct dentry *dentry, int mode,
 		struct nameidata *nd)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -2629,7 +2632,7 @@ EXPORT_SYMBOL_GPL(lookup_create);
 
 int vfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -2733,7 +2736,7 @@ SYSCALL_DEFINE3(mknod, const char __user *, filename, int, mode, unsigned, dev)
 
 int vfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 1);
 
 	if (error)
 		return error;
@@ -3016,7 +3019,7 @@ SYSCALL_DEFINE1(unlink, const char __user *, pathname)
 
 int vfs_symlink(struct inode *dir, struct dentry *dentry, const char *oldname)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, 0);
 
 	if (error)
 		return error;
@@ -3089,7 +3092,10 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	if (!inode)
 		return -ENOENT;
 
-	error = may_create(dir, new_dentry);
+	if (S_ISDIR(inode->i_mode))
+		return -EPERM;
+
+	error = may_create(dir, new_dentry, 0);
 	if (error)
 		return error;
 
@@ -3103,8 +3109,6 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 		return -EPERM;
 	if (!dir->i_op->link)
 		return -EPERM;
-	if (S_ISDIR(inode->i_mode))
-		return -EPERM;
 
 	error = security_inode_link(old_dentry, dir, new_dentry);
 	if (error)
@@ -3305,7 +3309,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	if (!new_dentry->d_inode)
-		error = may_create(new_dir, new_dentry);
+		error = may_create(new_dir, new_dentry, is_dir);
 	else
 		error = may_delete(new_dir, new_dentry, is_dir);
 	if (error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1dc6e72..a86afc0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -62,6 +62,8 @@ struct inodes_stat_t {
 #define MAY_ACCESS 16
 #define MAY_OPEN 32
 #define MAY_CHDIR 64
+#define MAY_CREATE_FILE 128
+#define MAY_CREATE_DIR 256
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.1

