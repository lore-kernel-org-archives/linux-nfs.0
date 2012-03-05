Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42055 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757290Ab2CEWit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 17:38:49 -0500
Date: Mon, 5 Mar 2012 17:38:47 -0500
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] vfs: take i_mutex on renamed file
Message-ID: <20120305223847.GA16444@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A read delegation is used by NFSv4 as a guarantee that a client can
perform local read opens without informing the server.

The open operation takes the last component of the pathname as an
argument, thus is also a lookup operation, and giving the client the
above guarantee means informing the client before we allow anything that
would change the set of names pointing to the inode.

Therefore, we need to break delegations on rename, link, and unlink.

We also need to prevent new delegations from being acquired while one of
these operations is in progress.

We could add some completely new locking for that purpose, but it's
simpler to use the i_mutex, since that's already taken by all the
operations we care about.

The single exception is rename.  So, modify rename to take the i_mutex
on the file that is being renamed.

Also fix up lockdep and Documentation/filesystems/directory-locking to
reflect the change.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/directory-locking |   11 ++++++-----
 fs/namei.c                                  |    3 +++
 include/linux/fs.h                          |    9 ++++++---
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/directory-locking b/Documentation/filesystems/directory-locking
index ff7b611..9edbcd2 100644
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
+    on their parents (which remain their parents until all locks are
+    acquired, by (1) and (2)).  (Proof: see descriptions of operations).
 
 	Now consider the minimal deadlock.  Each process is blocked on
 attempt to acquire some lock and already holds at least one lock.  Let's
diff --git a/fs/namei.c b/fs/namei.c
index 208c6aa..d29b3c4 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3073,6 +3073,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 			    struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *target = new_dentry->d_inode;
+	struct inode *source = old_dentry->d_inode;
 	int error;
 
 	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
@@ -3080,6 +3081,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	dget(new_dentry);
+	mutex_lock_nested(&source->i_mutex, I_MUTEX_RENAME_SOURCE);
 	if (target)
 		mutex_lock(&target->i_mutex);
 
@@ -3098,6 +3100,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 out:
 	if (target)
 		mutex_unlock(&target->i_mutex);
+	mutex_unlock(&source->i_mutex);
 	dput(new_dentry);
 	return error;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 386da09..e537b67 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -855,10 +855,12 @@ static inline int inode_unhashed(struct inode *inode)
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
@@ -866,7 +868,8 @@ enum inode_i_mutex_lock_class
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

