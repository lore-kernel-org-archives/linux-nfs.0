Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759386Ab2IEUzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 16:55:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Date: Wed,  5 Sep 2012 16:55:15 -0400
Message-Id: <1346878524-10585-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1346878524-10585-1-git-send-email-bfields@redhat.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
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
 Documentation/filesystems/directory-locking |   30 +++++++++++++++++++--------
 fs/namei.c                                  |    7 +++----
 2 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/Documentation/filesystems/directory-locking b/Documentation/filesystems/directory-locking
index ff7b611..9e8a629 100644
--- a/Documentation/filesystems/directory-locking
+++ b/Documentation/filesystems/directory-locking
@@ -2,6 +2,10 @@
 kinds of locks - per-inode (->i_mutex) and per-filesystem
 (->s_vfs_rename_mutex).
 
+	When taking the i_mutex on multiple non-directory objects, we
+always acquire the locks in order by increasing address.  We'll call
+that "inode pointer" order in the following.
+
 	For our purposes all operations fall in 5 classes:
 
 1) read access.  Locking rules: caller locks directory we are accessing.
@@ -12,8 +16,9 @@ kinds of locks - per-inode (->i_mutex) and per-filesystem
 locks victim and calls the method.
 
 4) rename() that is _not_ cross-directory.  Locking rules: caller locks
-the parent, finds source and target, if target already exists - locks it
-and then calls the method.
+the parent and finds source and target.  If source and target both
+exist, they are locked in inode pointer order.  Otherwise lock just
+source.  Then call method.
 
 5) link creation.  Locking rules:
 	* lock parent
@@ -30,7 +35,8 @@ rules:
 		fail with -ENOTEMPTY
 	* if new parent is equal to or is a descendent of source
 		fail with -ELOOP
-	* if target exists - lock it.
+	* If target exists, lock both source and target, in inode
+	  pointer order.  Otherwise lock just source.
 	* call the method.
 
 
@@ -56,9 +62,11 @@ objects - A < B iff A is an ancestor of B.
     renames will be blocked on filesystem lock and we don't start changing
     the order until we had acquired all locks).
 
-(3) any operation holds at most one lock on non-directory object and
-    that lock is acquired after all other locks.  (Proof: see descriptions
-    of operations).
+(3) locks on non-directory objects are acquired only after locks on
+    directory objects, and are acquired in inode pointer order.
+    (Proof: all operations but renames take lock on at most one
+    non-directory object, except renames, which take locks on source and
+    target in inode pointer order.)
 
 	Now consider the minimal deadlock.  Each process is blocked on
 attempt to acquire some lock and already holds at least one lock.  Let's
@@ -66,9 +74,13 @@ consider the set of contended locks.  First of all, filesystem lock is
 not contended, since any process blocked on it is not holding any locks.
 Thus all processes are blocked on ->i_mutex.
 
-	Non-directory objects are not contended due to (3).  Thus link
-creation can't be a part of deadlock - it can't be blocked on source
-and it means that it doesn't hold any locks.
+	By (3), any process holding a non-directory lock can only be
+waiting on another non-directory lock with a larger address.  Therefore
+the process holding the "largest" such lock can always make progress, and
+non-directory objects are not included in the set of contended locks.
+
+	Thus link creation can't be a part of deadlock - it can't be
+blocked on source and it means that it doesn't hold any locks.
 
 	Any contended object is either held by cross-directory rename or
 has a child that is also contended.  Indeed, suppose that it is held by
diff --git a/fs/namei.c b/fs/namei.c
index 1b46439..6156135 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3658,6 +3658,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 			    struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *target = new_dentry->d_inode;
+	struct inode *source = old_dentry->d_inode;
 	int error;
 
 	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
@@ -3665,8 +3666,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	dget(new_dentry);
-	if (target)
-		mutex_lock(&target->i_mutex);
+	lock_two_nondirectories(source, target);
 
 	error = -EBUSY;
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
@@ -3681,8 +3681,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 	if (!(old_dir->i_sb->s_type->fs_flags & FS_RENAME_DOES_D_MOVE))
 		d_move(old_dentry, new_dentry);
 out:
-	if (target)
-		mutex_unlock(&target->i_mutex);
+	unlock_two_nondirectories(source, target);
 	dput(new_dentry);
 	return error;
 }
-- 
1.7.9.5

