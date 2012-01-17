Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754969Ab2AQQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 4/6] locks: break delegations on rename
Date: Tue, 17 Jan 2012 11:00:27 -0500
Message-Id: <1326816029-13913-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

To rely on the i_mutex for exclusion between setlease and rename, we
need rename to take the i_mutex on the source as well as on any possible
target.

Also fix up lockdep and the Documentation/filesystems/directory-locking
documentation.  (I need to review the latter one more time to make sure
I've got it right.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/directory-locking |   11 ++++++-----
 fs/namei.c                                  |   17 +++++++++++++++--
 include/linux/fs.h                          |    9 ++++++---
 3 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/directory-locking b/Documentation/filesystems/directory-locking
index ff7b611..c51cbed 100644
--- a/Documentation/filesystems/directory-locking
+++ b/Documentation/filesystems/directory-locking
@@ -12,8 +12,8 @@ kinds of locks - per-inode (->i_mutex) and per-filesystem
 locks victim and calls the method.
 
 4) rename() that is _not_ cross-directory.  Locking rules: caller locks
-the parent, finds source and target, if target already exists - locks it
-and then calls the method.
+the parent, finds source and target, locks source, also locks target if
+it already exists, and then calls the method.
 
 5) link creation.  Locking rules:
 	* lock parent
@@ -30,6 +30,7 @@ rules:
 		fail with -ENOTEMPTY
 	* if new parent is equal to or is a descendent of source
 		fail with -ELOOP
+	* lock source if it is not a directory.
 	* if target exists - lock it.
 	* call the method.
 
@@ -56,9 +57,9 @@ objects - A < B iff A is an ancestor of B.
     renames will be blocked on filesystem lock and we don't start changing
     the order until we had acquired all locks).
 
-(3) any operation holds at most one lock on non-directory object and
-    that lock is acquired after all other locks.  (Proof: see descriptions
-    of operations).
+(3) locks on non-directory objects are acquired only after taking locks
+    on their parents (which remain their parents by (1) and (2)).
+    (Proof: see descriptions of operations).
 
 	Now consider the minimal deadlock.  Each process is blocked on
 attempt to acquire some lock and already holds at least one lock.  Let's
diff --git a/fs/namei.c b/fs/namei.c
index 7182209..facf295 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3075,6 +3075,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 			    struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *target = new_dentry->d_inode;
+	struct inode *source = old_dentry->d_inode;
 	int error;
 
 	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
@@ -3082,13 +3083,23 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	dget(new_dentry);
-	if (target)
+	mutex_lock_nested(&source->i_mutex, I_MUTEX_RENAME_SOURCE);
+	error = break_lease(source, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+	if (error)
+		goto out_unlock_source;
+	if (target) {
 		mutex_lock(&target->i_mutex);
-
+		error = break_lease(target, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+		if (error)
+			goto out;
+	}
 	error = -EBUSY;
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
 		goto out;
 
+	error = break_lease(old_dentry->d_inode, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+	if (error)
+		goto out;
 	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
 	if (error)
 		goto out;
@@ -3100,6 +3111,8 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 out:
 	if (target)
 		mutex_unlock(&target->i_mutex);
+out_unlock_source:
+	mutex_unlock(&source->i_mutex);
 	dput(new_dentry);
 	return error;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 939cb3b..dccec8c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -848,10 +848,12 @@ static inline int inode_unhashed(struct inode *inode)
  * 0: the object of the current VFS operation
  * 1: parent
  * 2: child/target
- * 3: quota file
+ * 3: xattr
+ * 4: quota file
+ * 5: the file being renamed (used only in rename of a non-directory)
  *
  * The locking order between these classes is
- * parent -> child -> normal -> xattr -> quota
+ * parent -> child -> rename_source -> normal -> xattr -> quota
  */
 enum inode_i_mutex_lock_class
 {
@@ -859,7 +861,8 @@ enum inode_i_mutex_lock_class
 	I_MUTEX_PARENT,
 	I_MUTEX_CHILD,
 	I_MUTEX_XATTR,
-	I_MUTEX_QUOTA
+	I_MUTEX_QUOTA,
+	I_MUTEX_RENAME_SOURCE
 };
 
 /*
-- 
1.7.5.4

