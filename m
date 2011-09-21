Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab1IUO62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] leases: break read leases on rename
Date: Wed, 21 Sep 2011 10:58:15 -0400
Message-Id: <1316617097-21384-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To rely on the i_mutex for exclusion between setlease and rename, we
need rename to take the i_mutex on the source as well as on any possible
target.

I suspect this is deadlock-free, but I need to think this proof through
again.  And I'm not sure what to do about lockdep.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/directory-locking |   11 ++++++-----
 fs/namei.c                                  |   17 +++++++++++++++--
 2 files changed, 21 insertions(+), 7 deletions(-)

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
index 5c78f72..c0220f7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3058,6 +3058,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 			    struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *target = new_dentry->d_inode;
+	struct inode *source = old_dentry->d_inode;
 	int error;
 
 	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
@@ -3065,13 +3066,23 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	dget(new_dentry);
-	if (target)
+	mutex_lock(&source->i_mutex);
+	error = break_lease(source, O_WRONLY);
+	if (error)
+		goto out_unlock_source;
+	if (target) {
 		mutex_lock(&target->i_mutex);
-
+		error = break_lease(target, O_WRONLY);
+		if (error)
+			goto out;
+	}
 	error = -EBUSY;
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
 		goto out;
 
+	error = break_lease(old_dentry->d_inode, O_WRONLY);
+	if (error)
+		goto out;
 	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
 	if (error)
 		goto out;
@@ -3083,6 +3094,8 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 out:
 	if (target)
 		mutex_unlock(&target->i_mutex);
+out_unlock_source:
+	mutex_unlock(&source->i_mutex);
 	dput(new_dentry);
 	return error;
 }
-- 
1.7.4.1

