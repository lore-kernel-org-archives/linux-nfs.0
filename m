Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:42438 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaHWOlm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:42 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so12191475qcr.34
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:41 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] locks: move freeing of leases outside of i_lock
Date: Sat, 23 Aug 2014 10:41:17 -0400
Message-Id: <1408804878-1331-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There was only one place where we still could free a file_lock while
holding the i_lock -- lease_modify. Add a new list_head argument to the
lm_change operation, pass in a private list when calling it, and fix
those callers to dispose of the list once the lock has been dropped.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c          | 35 ++++++++++++++++++++++-------------
 fs/nfsd/nfs4state.c |  6 +++---
 include/linux/fs.h  |  7 ++++---
 3 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 49210d5cbf41..98907cecaa44 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1297,7 +1297,7 @@ static void lease_clear_pending(struct file_lock *fl, int arg)
 }
 
 /* We already had a lease on this file; just change its type */
-int lease_modify(struct file_lock **before, int arg)
+int lease_modify(struct file_lock **before, int arg, struct list_head *dispose)
 {
 	struct file_lock *fl = *before;
 	int error = assign_type(fl, arg);
@@ -1316,7 +1316,7 @@ int lease_modify(struct file_lock **before, int arg)
 			printk(KERN_ERR "locks_delete_lock: fasync == %p\n", fl->fl_fasync);
 			fl->fl_fasync = NULL;
 		}
-		locks_delete_lock(before, NULL);
+		locks_delete_lock(before, dispose);
 	}
 	return 0;
 }
@@ -1330,7 +1330,7 @@ static bool past_time(unsigned long then)
 	return time_after(jiffies, then);
 }
 
-static void time_out_leases(struct inode *inode)
+static void time_out_leases(struct inode *inode, struct list_head *dispose)
 {
 	struct file_lock **before;
 	struct file_lock *fl;
@@ -1341,9 +1341,9 @@ static void time_out_leases(struct inode *inode)
 	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
 		trace_time_out_leases(inode, fl);
 		if (past_time(fl->fl_downgrade_time))
-			lease_modify(before, F_RDLCK);
+			lease_modify(before, F_RDLCK, dispose);
 		if (past_time(fl->fl_break_time))
-			lease_modify(before, F_UNLCK);
+			lease_modify(before, F_UNLCK, dispose);
 		if (fl == *before)	/* lease_modify may have freed fl */
 			before = &fl->fl_next;
 	}
@@ -1378,6 +1378,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	int i_have_this_lease = 0;
 	bool lease_conflict = false;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
+	LIST_HEAD(dispose);
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
 	if (IS_ERR(new_fl))
@@ -1386,7 +1387,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 
 	spin_lock(&inode->i_lock);
 
-	time_out_leases(inode);
+	time_out_leases(inode, &dispose);
 
 	flock = inode->i_flock;
 	if ((flock == NULL) || !IS_LEASE(flock))
@@ -1441,6 +1442,7 @@ restart:
 	locks_insert_block(flock, new_fl);
 	trace_break_lease_block(inode, new_fl);
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 	error = wait_event_interruptible_timeout(new_fl->fl_wait,
 						!new_fl->fl_next, break_time);
 	spin_lock(&inode->i_lock);
@@ -1448,7 +1450,7 @@ restart:
 	locks_delete_block(new_fl);
 	if (error >= 0) {
 		if (error == 0)
-			time_out_leases(inode);
+			time_out_leases(inode, &dispose);
 		/*
 		 * Wait for the next conflicting lease that has not been
 		 * broken yet
@@ -1463,6 +1465,7 @@ restart:
 
 out:
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 	locks_free_lock(new_fl);
 	return error;
 }
@@ -1527,9 +1530,10 @@ int fcntl_getlease(struct file *filp)
 	struct file_lock *fl;
 	struct inode *inode = file_inode(filp);
 	int type = F_UNLCK;
+	LIST_HEAD(dispose);
 
 	spin_lock(&inode->i_lock);
-	time_out_leases(file_inode(filp));
+	time_out_leases(file_inode(filp), &dispose);
 	for (fl = file_inode(filp)->i_flock; fl && IS_LEASE(fl);
 			fl = fl->fl_next) {
 		if (fl->fl_file == filp) {
@@ -1538,6 +1542,7 @@ int fcntl_getlease(struct file *filp)
 		}
 	}
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 	return type;
 }
 
@@ -1575,6 +1580,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 	struct inode *inode = dentry->d_inode;
 	bool is_deleg = (*flp)->fl_flags & FL_DELEG;
 	int error;
+	LIST_HEAD(dispose);
 
 	lease = *flp;
 	trace_generic_add_lease(inode, lease);
@@ -1598,7 +1604,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 	}
 
 	spin_lock(&inode->i_lock);
-	time_out_leases(inode);
+	time_out_leases(inode, &dispose);
 
 	error = check_conflicting_open(dentry, arg);
 	if (error)
@@ -1636,7 +1642,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 
 	if (my_before != NULL) {
 		lease = *my_before;
-		error = lease->fl_lmops->lm_change(my_before, arg);
+		error = lease->fl_lmops->lm_change(my_before, arg, &dispose);
 		if (error)
 			goto out;
 		goto out_setup;
@@ -1666,6 +1672,7 @@ out_setup:
 		lease->fl_lmops->lm_setup(lease, aux);
 out:
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
 	if (!error && !my_before)
@@ -1682,17 +1689,19 @@ static int generic_delete_lease(struct file *filp)
 	struct file_lock *fl, **before;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	LIST_HEAD(dispose);
 
 	spin_lock(&inode->i_lock);
-	time_out_leases(inode);
+	time_out_leases(inode, &dispose);
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
 		if (fl->fl_file != filp)
 			continue;
-		error = fl->fl_lmops->lm_change(before, F_UNLCK);
+		error = fl->fl_lmops->lm_change(before, F_UNLCK, &dispose);
 	}
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 	return error;
 }
 
@@ -2388,7 +2397,7 @@ void locks_remove_file(struct file *filp)
 	while ((fl = *before) != NULL) {
 		if (fl->fl_file == filp) {
 			if (IS_LEASE(fl)) {
-				lease_modify(before, F_UNLCK);
+				lease_modify(before, F_UNLCK, &dispose);
 				continue;
 			}
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6af5d0890373..623576301e38 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3423,11 +3423,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	spin_unlock(&fp->fi_lock);
 }
 
-static
-int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
+static int
+nfsd_change_deleg_cb(struct file_lock **onlist, int arg, struct list_head *dispose)
 {
 	if (arg & F_UNLCK)
-		return lease_modify(onlist, arg);
+		return lease_modify(onlist, arg, dispose);
 	else
 		return -EAGAIN;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 70d22c12924f..e3dbcf269cd2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -873,7 +873,7 @@ struct lock_manager_operations {
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
 	int (*lm_grant)(struct file_lock *, int);
 	void (*lm_break)(struct file_lock *);
-	int (*lm_change)(struct file_lock **, int);
+	int (*lm_change)(struct file_lock **, int, struct list_head *);
 	void (*lm_setup)(struct file_lock *, void **);
 };
 
@@ -985,7 +985,7 @@ extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int t
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void **aux);
 extern int vfs_setlease(struct file *, long, struct file_lock **, void **aux);
-extern int lease_modify(struct file_lock **, int);
+extern int lease_modify(struct file_lock **, int, struct list_head *);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, unsigned int cmd,
 			      struct flock __user *user)
@@ -1112,7 +1112,8 @@ static inline int vfs_setlease(struct file *filp, long arg,
 	return -EINVAL;
 }
 
-static inline int lease_modify(struct file_lock **before, int arg)
+static inline int lease_modify(struct file_lock **before, int arg,
+			       struct list_head *dispose)
 {
 	return -EINVAL;
 }
-- 
1.9.3

