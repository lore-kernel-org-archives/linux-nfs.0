Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46489 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960Ab3BCQbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Feb 2013 11:31:35 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/12] vfs: take i_mutex on renamed file
Date: Sun,  3 Feb 2013 11:31:24 -0500
Message-Id: <1359909092-24857-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1359909092-24857-1-git-send-email-bfields@redhat.com>
References: <1359909092-24857-1-git-send-email-bfields@redhat.com>
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
 Documentation/filesystems/directory-locking |   31 +++++++++++++++++++--------
 fs/namei.c                                  |   12 ++++++++---
 2 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/directory-locking b/Documentation/filesystems/directory-locking
index ff7b611..09bbf9a 100644
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
+the parent and finds source and target.  If target already exists, lock
+it.  If source is a non-directory, lock it.  If that means we need to
+lock both, lock them in inode pointer order.
 
 5) link creation.  Locking rules:
 	* lock parent
@@ -30,7 +35,9 @@ rules:
 		fail with -ENOTEMPTY
 	* if new parent is equal to or is a descendent of source
 		fail with -ELOOP
-	* if target exists - lock it.
+	* If target exists, lock it.  If source is a non-directory, lock
+	  it.  In case that means we need to lock both source and target,
+	  do so in inode pointer order.
 	* call the method.
 
 
@@ -56,9 +63,11 @@ objects - A < B iff A is an ancestor of B.
     renames will be blocked on filesystem lock and we don't start changing
     the order until we had acquired all locks).
 
-(3) any operation holds at most one lock on non-directory object and
-    that lock is acquired after all other locks.  (Proof: see descriptions
-    of operations).
+(3) locks on non-directory objects are acquired only after locks on
+    directory objects, and are acquired in inode pointer order.
+    (Proof: all operations but renames take lock on at most one
+    non-directory object, except renames, which take locks on source and
+    target in inode pointer order in the case they are not directories.)
 
 	Now consider the minimal deadlock.  Each process is blocked on
 attempt to acquire some lock and already holds at least one lock.  Let's
@@ -66,9 +75,13 @@ consider the set of contended locks.  First of all, filesystem lock is
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
index 43a97ee..6ca5b11 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3688,7 +3688,8 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
  *	   That's where 4.4 screws up. Current fix: serialization on
  *	   sb->s_vfs_rename_mutex. We might be more accurate, but that's another
  *	   story.
- *	c) we have to lock _three_ objects - parents and victim (if it exists).
+ *	c) we have to lock _four_ objects - parents and victim (if it exists),
+ *	   and source (if it is not a directory).
  *	   And that - after we got ->i_mutex on parents (until then we don't know
  *	   whether the target exists).  Solution: try to be smart with locking
  *	   order for inodes.  We rely on the fact that tree topology may change
@@ -3764,6 +3765,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 			    struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *target = new_dentry->d_inode;
+	struct inode *source = old_dentry->d_inode;
 	int error;
 
 	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
@@ -3772,7 +3774,9 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 
 	dget(new_dentry);
 	if (target)
-		mutex_lock(&target->i_mutex);
+		lock_two_nondirectories(source, target);
+	else
+		mutex_lock(&source->i_mutex);
 
 	error = -EBUSY;
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
@@ -3788,7 +3792,9 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		d_move(old_dentry, new_dentry);
 out:
 	if (target)
-		mutex_unlock(&target->i_mutex);
+		unlock_two_nondirectories(source, target);
+	else
+		mutex_unlock(&source->i_mutex);
 	dput(new_dentry);
 	return error;
 }
-- 
1.7.9.5

