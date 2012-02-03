Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51025 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757777Ab2BCVKC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 16:10:02 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] locks: break delegations on unlink
Date: Fri,  3 Feb 2012 16:09:54 -0500
Message-Id: <1328303397-3872-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20120203205818.GE2999@fieldses.org>
References: <20120203205818.GE2999@fieldses.org>
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

Start with unlink.

The simplest thing to do is just to use the fact that unlink always
takes the i_mutex to prevent new delegations from being acquired while
the unlink is in progress.

The delegation is generally just an optimization--it's always OK not to
give one out.  So we can just do a mutex_trylock() in setlease() and
fail the setlease if we don't get the lock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   42 ++++++++++++++++++++++++++++++++++--------
 fs/namei.c |    3 +++
 2 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 5f9ae63..fce9760 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1185,6 +1185,13 @@ static void time_out_leases(struct inode *inode)
 	}
 }
 
+static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
+{
+	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
+		return false;
+	return locks_conflict(breaker, lease);
+}
+
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
@@ -1202,11 +1209,13 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	struct file_lock *fl;
 	unsigned long break_time;
 	int i_have_this_lease = 0;
+	bool lease_conflict = false;
 	int want_write = (mode & BREAK_RW_MASK) != BREAK_W_LEASES;
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
+	new_fl->fl_flags = mode & BREAK_ONLY_DELEGS ? FL_DELEG : FL_LEASE;
 
 	lock_flocks();
 
@@ -1216,13 +1225,16 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	if ((flock == NULL) || !IS_LEASE(flock))
 		goto out;
 
-	if (!locks_conflict(flock, new_fl))
+	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (leases_conflict(fl, new_fl)) {
+			lease_conflict = true;
+			if (fl->fl_owner == current->files)
+				i_have_this_lease = 1;
+		}
+	}
+	if (!lease_conflict)
 		goto out;
 
-	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next)
-		if (fl->fl_owner == current->files)
-			i_have_this_lease = 1;
-
 	break_time = 0;
 	if (lease_break_time > 0) {
 		break_time = jiffies + lease_break_time * HZ;
@@ -1231,6 +1243,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	}
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (!leases_conflict(fl, new_fl))
+			continue;
 		if (want_write) {
 			if (fl->fl_flags & FL_UNLOCK_PENDING)
 				continue;
@@ -1272,7 +1286,7 @@ restart:
 		 */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (locks_conflict(new_fl, flock))
+			if (leases_conflict(new_fl, flock))
 				goto restart;
 		}
 		error = 0;
@@ -1352,9 +1366,20 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	bool is_deleg = (*flp)->fl_flags & FL_DELEG;
 	int error;
 
 	lease = *flp;
+	/*
+	 * In the delegation case we need mutual exclusion with
+	 * a number of operations that take the i_mutex.  We trylock
+	 * because delegations are an optional optimization, and if
+	 * there's some chance of a conflict--we'd rather not
+	 * bother, maybe that's a sign this just isn't a good file to
+	 * hand out a delegation on.
+	 */
+	if (is_deleg && !mutex_trylock(&inode->i_mutex))
+		return -EAGAIN;
 
 	error = -EAGAIN;
 	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
@@ -1406,9 +1431,10 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 		goto out;
 
 	locks_insert_lock(before, lease);
-	return 0;
-
+	error = 0;
 out:
+	if (is_deleg)
+		mutex_unlock(&inode->i_mutex);
 	return error;
 }
 
diff --git a/fs/namei.c b/fs/namei.c
index 208c6aa..4516958 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2788,6 +2788,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 		error = security_path_unlink(&nd.path, dentry);
 		if (error)
 			goto exit3;
+		error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_R_AND_W_LEASES);
+		if (error)
+			goto exit3;
 		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
 exit3:
 		mnt_drop_write(nd.path.mnt);
-- 
1.7.5.4

