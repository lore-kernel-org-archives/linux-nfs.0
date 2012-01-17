Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50556 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754729Ab2AQQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 3/6] locks: break delegations on unlink
Date: Tue, 17 Jan 2012 11:00:26 -0500
Message-Id: <1326816029-13913-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
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
 fs/locks.c |   39 +++++++++++++++++++++++++++++++--------
 fs/namei.c |    3 +++
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d6661a6..d746a6e 100644
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
@@ -1202,9 +1209,11 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	struct file_lock *fl;
 	unsigned long break_time;
 	int i_have_this_lease = 0;
+	bool lease_conflict = false;
 	int want_write = break_all_leases(mode);
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	new_fl->fl_flags = mode & BREAK_ONLY_DELEGS ? FL_DELEG : FL_LEASE;
 
 	lock_flocks();
 
@@ -1214,13 +1223,16 @@ int __break_lease(struct inode *inode, unsigned int mode)
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
 	if (IS_ERR(new_fl) && !i_have_this_lease
 			&& ((mode & O_NONBLOCK) == 0)) {
 		error = PTR_ERR(new_fl);
@@ -1235,6 +1247,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	}
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (!leases_conflict(fl, new_fl))
+			continue;
 		if (want_write) {
 			if (fl->fl_flags & FL_UNLOCK_PENDING)
 				continue;
@@ -1276,7 +1290,7 @@ restart:
 		 */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (locks_conflict(new_fl, flock))
+			if (leases_conflict(new_fl, flock))
 				goto restart;
 		}
 		error = 0;
@@ -1357,10 +1371,18 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	bool is_deleg = (*flp)->fl_flags & FL_DELEG;
 	int error;
 
 	lease = *flp;
 
+	/*
+	 * In the delegation case we need mutual exclusion with
+	 * a number of operations that take the i_mutex:
+	 */
+	if (is_deleg && !mutex_trylock(&inode->i_mutex))
+		return -EAGAIN;
+
 	error = -EAGAIN;
 	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 		goto out;
@@ -1411,9 +1433,10 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
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
index 5008f01..7182209 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2787,6 +2787,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 		error = security_path_unlink(&nd.path, dentry);
 		if (error)
 			goto exit3;
+		error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+		if (error)
+			goto exit3;
 		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
 exit3:
 		mnt_drop_write(nd.path.mnt);
-- 
1.7.5.4

