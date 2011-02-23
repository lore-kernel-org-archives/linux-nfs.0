Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:53140 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530Ab1BWNxY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:53:24 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 08/24] vfs: Add delete child and delete self permission flags
Date: Wed, 23 Feb 2011 19:21:55 +0530
Message-Id: <1298469131-16555-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

Normally, deleting a file requires write access to the parent directory.
Some permission models use a different permission on the parent
directory to indicate delete access.  In addition, a process can have
per-file delete access even without delete access on the parent
directory.

Introduce two new inode_permission() mask flags and use them in
may_delete()

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c         |   40 ++++++++++++++++++++++++++--------------
 include/linux/fs.h |    2 ++
 2 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b4f7198..1b6dbc9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -253,7 +253,7 @@ int generic_permission(struct inode *inode, int mask, unsigned int flags,
  * are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -1944,7 +1944,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
 		return 0;
 	if (dir->i_uid == fsuid)
 		return 0;
-	return !capable(CAP_FOWNER);
+	return 1;
 }
 
 /*
@@ -1966,30 +1966,42 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      int isdir, int replace)
 {
-	int error;
+	int mask, error, is_sticky;
+	struct inode *inode = victim->d_inode;
 
-	if (!victim->d_inode)
+	if (!inode)
 		return -ENOENT;
 
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(victim, dir);
 
-	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
+	if (replace)
+		mask |= S_ISDIR(inode->i_mode) ?
+			MAY_CREATE_DIR : MAY_CREATE_FILE;
+	is_sticky = check_sticky(dir, inode);
+	error = inode_permission(dir, mask);
+	if ((error || is_sticky) && IS_RICHACL(inode) &&
+	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
+	    !inode_permission(inode, MAY_DELETE_SELF))
+		error = 0;
+	else if (!error && is_sticky && !capable(CAP_FOWNER))
+		error = -EPERM;
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
 		return -EPERM;
-	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
-	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
+	if (IS_APPEND(inode) || IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
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
@@ -2824,7 +2836,7 @@ void dentry_unhash(struct dentry *dentry)
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, 1, 0);
 
 	if (error)
 		return error;
@@ -2911,7 +2923,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 
 int vfs_unlink(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, 0, 0);
 
 	if (error)
 		return error;
@@ -3304,14 +3316,14 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
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
index a86afc0..6a6e017 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -64,6 +64,8 @@ struct inodes_stat_t {
 #define MAY_CHDIR 64
 #define MAY_CREATE_FILE 128
 #define MAY_CREATE_DIR 256
+#define MAY_DELETE_CHILD 512
+#define MAY_DELETE_SELF 1024
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.1

