Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862Ab2CIW3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:29:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/7] locks: implement delegations
Date: Fri,  9 Mar 2012 17:29:30 -0500
Message-Id: <1331332174-22621-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20120309222114.GA22423@fieldses.org>
References: <20120309222114.GA22423@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Implement NFSv4 delegations at the vfs level using the new FL_DELEG lock
type.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c         |   49 +++++++++++++++++++++++++++++++++++++++----------
 include/linux/fs.h |   18 +++++++++++++++---
 2 files changed, 54 insertions(+), 13 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ea07a98..29f911c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1185,28 +1185,40 @@ static void time_out_leases(struct inode *inode)
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
- *	@mode: the open mode (read or write)
+ *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
+ *	    break all leases
+ *	@type: FL_LEASE: break leases and delegations; FL_DELEG: break
+ *	    only delegations
  *
  *	break_lease (inlined for speed) has checked there already is at least
  *	some kind of lock (maybe a lease) on this file.  Leases are broken on
  *	a call to open() or truncate().  This function can sleep unless you
  *	specified %O_NONBLOCK to your open().
  */
-int __break_lease(struct inode *inode, unsigned int mode)
+int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	int error = 0;
 	struct file_lock *new_fl, *flock;
 	struct file_lock *fl;
 	unsigned long break_time;
 	int i_have_this_lease = 0;
+	bool lease_conflict = false;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
+	new_fl->fl_flags = type;
 
 	lock_flocks();
 
@@ -1216,13 +1228,16 @@ int __break_lease(struct inode *inode, unsigned int mode)
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
@@ -1231,6 +1246,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	}
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (!leases_conflict(fl, new_fl))
+			continue;
 		if (want_write) {
 			if (fl->fl_flags & FL_UNLOCK_PENDING)
 				continue;
@@ -1272,7 +1289,7 @@ restart:
 		 */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (locks_conflict(new_fl, flock))
+			if (leases_conflict(new_fl, flock))
 				goto restart;
 		}
 		error = 0;
@@ -1352,9 +1369,20 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
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
@@ -1406,9 +1434,10 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
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
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9d7446e..2cc1adf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1207,7 +1207,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
-extern int __break_lease(struct inode *inode, unsigned int flags);
+extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **);
 extern int vfs_setlease(struct file *, long, struct file_lock **);
@@ -1319,7 +1319,7 @@ static inline int flock_lock_file_wait(struct file *filp,
 	return -ENOLCK;
 }
 
-static inline int __break_lease(struct inode *inode, unsigned int mode)
+static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	return 0;
 }
@@ -1972,9 +1972,17 @@ static inline int locks_verify_truncate(struct inode *inode,
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
 	if (inode->i_flock)
-		return __break_lease(inode, mode);
+		return __break_lease(inode, mode, FL_LEASE);
 	return 0;
 }
+
+static inline int break_deleg(struct inode *inode, unsigned int mode)
+{
+	if (inode->i_flock)
+		return __break_lease(inode, mode, FL_DELEG);
+	return 0;
+}
+
 #else /* !CONFIG_FILE_LOCKING */
 static inline int locks_mandatory_locked(struct inode *inode)
 {
@@ -2014,6 +2022,10 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
+static inline int break_deleg(struct inode *inode, unsigned int mode)
+{
+	return 0;
+}
 #endif /* CONFIG_FILE_LOCKING */
 
 /* fs/open.c */
-- 
1.7.5.4

