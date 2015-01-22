Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.229]:21450 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753357AbbAVO3R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:29:17 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 07/13] locks: convert lease handling to file_lock_context
Date: Thu, 22 Jan 2015 09:27:51 -0500
Message-Id: <1421936877-27529-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c         | 252 +++++++++++++++++++++--------------------------------
 include/linux/fs.h |   5 +-
 2 files changed, 102 insertions(+), 155 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index e50bb4d9e757..d46e70567b99 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -216,6 +216,7 @@ locks_get_lock_context(struct inode *inode)
 
 	INIT_LIST_HEAD(&new->flc_flock);
 	INIT_LIST_HEAD(&new->flc_posix);
+	INIT_LIST_HEAD(&new->flc_lease);
 
 	/*
 	 * Assign the pointer if it's not already assigned. If it is, then
@@ -240,6 +241,7 @@ locks_free_lock_context(struct file_lock_context *ctx)
 	if (ctx) {
 		WARN_ON_ONCE(!list_empty(&ctx->flc_flock));
 		WARN_ON_ONCE(!list_empty(&ctx->flc_posix));
+		WARN_ON_ONCE(!list_empty(&ctx->flc_lease));
 		kmem_cache_free(flctx_cache, ctx);
 	}
 }
@@ -677,22 +679,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 	spin_unlock(&blocked_lock_lock);
 }
 
-/* Insert file lock fl into an inode's lock list at the position indicated
- * by pos. At the same time add the lock to the global file lock list.
- *
- * Must be called with the i_lock held!
- */
-static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
-{
-	fl->fl_nspid = get_pid(task_tgid(current));
-
-	/* insert into file's list */
-	fl->fl_next = *pos;
-	*pos = fl;
-
-	locks_insert_global_locks(fl);
-}
-
 static void
 locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 {
@@ -701,63 +687,28 @@ locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 	locks_insert_global_locks(fl);
 }
 
-/**
- * locks_delete_lock - Delete a lock and then free it.
- * @thisfl_p: pointer that points to the fl_next field of the previous
- * 	      inode->i_flock list entry
- *
- * Unlink a lock from all lists and free the namespace reference, but don't
- * free it yet. Wake up processes that are blocked waiting for this lock and
- * notify the FS that the lock has been cleared.
- *
- * Must be called with the i_lock held!
- */
-static void locks_unlink_lock(struct file_lock **thisfl_p)
+static void
+locks_unlink_lock_ctx(struct file_lock *fl)
 {
-	struct file_lock *fl = *thisfl_p;
-
 	locks_delete_global_locks(fl);
-
-	*thisfl_p = fl->fl_next;
-	fl->fl_next = NULL;
-
+	list_del_init(&fl->fl_list);
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
 		fl->fl_nspid = NULL;
 	}
-
 	locks_wake_up_blocks(fl);
 }
 
-/*
- * Unlink a lock from all lists and free it.
- *
- * Must be called with i_lock held!
- */
-static void locks_delete_lock(struct file_lock **thisfl_p,
-			      struct list_head *dispose)
+static void
+locks_delete_lock_ctx(struct file_lock *fl, struct list_head *dispose)
 {
-	struct file_lock *fl = *thisfl_p;
-
-	locks_unlink_lock(thisfl_p);
+	locks_unlink_lock_ctx(fl);
 	if (dispose)
 		list_add(&fl->fl_list, dispose);
 	else
 		locks_free_lock(fl);
 }
 
-static void
-locks_delete_lock_ctx(struct file_lock *fl, struct list_head *dispose)
-{
-	locks_delete_global_locks(fl);
-	if (fl->fl_nspid) {
-		put_pid(fl->fl_nspid);
-		fl->fl_nspid = NULL;
-	}
-	locks_wake_up_blocks(fl);
-	list_move(&fl->fl_list, dispose);
-}
-
 /* Determine if lock sys_fl blocks lock caller_fl. Common functionality
  * checks for shared/exclusive status of overlapping locks.
  */
@@ -1376,7 +1327,7 @@ int lease_modify(struct file_lock **before, int arg, struct list_head *dispose)
 			printk(KERN_ERR "locks_delete_lock: fasync == %p\n", fl->fl_fasync);
 			fl->fl_fasync = NULL;
 		}
-		locks_delete_lock(before, dispose);
+		locks_delete_lock_ctx(fl, dispose);
 	}
 	return 0;
 }
@@ -1392,20 +1343,17 @@ static bool past_time(unsigned long then)
 
 static void time_out_leases(struct inode *inode, struct list_head *dispose)
 {
-	struct file_lock **before;
-	struct file_lock *fl;
+	struct file_lock_context *ctx = inode->i_flctx;
+	struct file_lock *fl, *tmp;
 
 	lockdep_assert_held(&inode->i_lock);
 
-	before = &inode->i_flock;
-	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
+	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list) {
 		trace_time_out_leases(inode, fl);
 		if (past_time(fl->fl_downgrade_time))
-			lease_modify(before, F_RDLCK, dispose);
+			lease_modify(&fl, F_RDLCK, dispose);
 		if (past_time(fl->fl_break_time))
-			lease_modify(before, F_UNLCK, dispose);
-		if (fl == *before)	/* lease_modify may have freed fl */
-			before = &fl->fl_next;
+			lease_modify(&fl, F_UNLCK, dispose);
 	}
 }
 
@@ -1419,11 +1367,12 @@ static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 static bool
 any_leases_conflict(struct inode *inode, struct file_lock *breaker)
 {
+	struct file_lock_context *ctx = inode->i_flctx;
 	struct file_lock *fl;
 
 	lockdep_assert_held(&inode->i_lock);
 
-	for (fl = inode->i_flock ; fl && IS_LEASE(fl); fl = fl->fl_next) {
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 		if (leases_conflict(fl, breaker))
 			return true;
 	}
@@ -1447,7 +1396,8 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	int error = 0;
 	struct file_lock *new_fl;
-	struct file_lock *fl, **before;
+	struct file_lock_context *ctx = inode->i_flctx;
+	struct file_lock *fl;
 	unsigned long break_time;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
@@ -1457,6 +1407,12 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags = type;
 
+	/* typically we will check that ctx is non-NULL before calling */
+	if (!ctx) {
+		WARN_ON_ONCE(1);
+		return error;
+	}
+
 	spin_lock(&inode->i_lock);
 
 	time_out_leases(inode, &dispose);
@@ -1471,9 +1427,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			break_time++;	/* so that 0 means no break time */
 	}
 
-	for (before = &inode->i_flock;
-			((fl = *before) != NULL) && IS_LEASE(fl);
-			before = &fl->fl_next) {
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 		if (!leases_conflict(fl, new_fl))
 			continue;
 		if (want_write) {
@@ -1482,17 +1436,16 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			fl->fl_flags |= FL_UNLOCK_PENDING;
 			fl->fl_break_time = break_time;
 		} else {
-			if (lease_breaking(inode->i_flock))
+			if (lease_breaking(fl))
 				continue;
 			fl->fl_flags |= FL_DOWNGRADE_PENDING;
 			fl->fl_downgrade_time = break_time;
 		}
 		if (fl->fl_lmops->lm_break(fl))
-			locks_delete_lock(before, &dispose);
+			locks_delete_lock_ctx(fl, &dispose);
 	}
 
-	fl = inode->i_flock;
-	if (!fl || !IS_LEASE(fl))
+	if (list_empty(&ctx->flc_lease))
 		goto out;
 
 	if (mode & O_NONBLOCK) {
@@ -1502,12 +1455,13 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	}
 
 restart:
-	break_time = inode->i_flock->fl_break_time;
+	fl = list_first_entry(&ctx->flc_lease, struct file_lock, fl_list);
+	break_time = fl->fl_break_time;
 	if (break_time != 0)
 		break_time -= jiffies;
 	if (break_time == 0)
 		break_time++;
-	locks_insert_block(inode->i_flock, new_fl);
+	locks_insert_block(fl, new_fl);
 	trace_break_lease_block(inode, new_fl);
 	spin_unlock(&inode->i_lock);
 	locks_dispose_list(&dispose);
@@ -1525,10 +1479,8 @@ restart:
 			time_out_leases(inode, &dispose);
 		if (any_leases_conflict(inode, new_fl))
 			goto restart;
-
 		error = 0;
 	}
-
 out:
 	spin_unlock(&inode->i_lock);
 	locks_dispose_list(&dispose);
@@ -1550,13 +1502,17 @@ EXPORT_SYMBOL(__break_lease);
 void lease_get_mtime(struct inode *inode, struct timespec *time)
 {
 	bool has_lease = false;
-	struct file_lock *flock;
+	struct file_lock_context *ctx = inode->i_flctx;
+	struct file_lock *fl;
 
-	if (inode->i_flock) {
+	if (ctx && !list_empty_careful(&ctx->flc_lease)) {
 		spin_lock(&inode->i_lock);
-		flock = inode->i_flock;
-		if (flock && IS_LEASE(flock) && (flock->fl_type == F_WRLCK))
-			has_lease = true;
+		if (!list_empty(&ctx->flc_lease)) {
+			fl = list_first_entry(&ctx->flc_lease,
+						struct file_lock, fl_list);
+			if (fl->fl_type == F_WRLCK)
+				has_lease = true;
+		}
 		spin_unlock(&inode->i_lock);
 	}
 
@@ -1595,20 +1551,22 @@ int fcntl_getlease(struct file *filp)
 {
 	struct file_lock *fl;
 	struct inode *inode = file_inode(filp);
+	struct file_lock_context *ctx = inode->i_flctx;
 	int type = F_UNLCK;
 	LIST_HEAD(dispose);
 
-	spin_lock(&inode->i_lock);
-	time_out_leases(file_inode(filp), &dispose);
-	for (fl = file_inode(filp)->i_flock; fl && IS_LEASE(fl);
-			fl = fl->fl_next) {
-		if (fl->fl_file == filp) {
+	if (ctx && !list_empty_careful(&ctx->flc_lease)) {
+		spin_lock(&inode->i_lock);
+		time_out_leases(file_inode(filp), &dispose);
+		list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
+			if (fl->fl_file != filp)
+				continue;
 			type = target_leasetype(fl);
 			break;
 		}
+		spin_unlock(&inode->i_lock);
+		locks_dispose_list(&dispose);
 	}
-	spin_unlock(&inode->i_lock);
-	locks_dispose_list(&dispose);
 	return type;
 }
 
@@ -1641,9 +1599,10 @@ check_conflicting_open(const struct dentry *dentry, const long arg)
 static int
 generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **priv)
 {
-	struct file_lock *fl, **before, **my_before = NULL, *lease;
+	struct file_lock *fl, *my_fl = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	struct file_lock_context *ctx;
 	bool is_deleg = (*flp)->fl_flags & FL_DELEG;
 	int error;
 	LIST_HEAD(dispose);
@@ -1651,6 +1610,10 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	lease = *flp;
 	trace_generic_add_lease(inode, lease);
 
+	ctx = locks_get_lock_context(inode);
+	if (!ctx)
+		return -ENOMEM;
+
 	/*
 	 * In the delegation case we need mutual exclusion with
 	 * a number of operations that take the i_mutex.  We trylock
@@ -1684,13 +1647,12 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	 * except for this filp.
 	 */
 	error = -EAGAIN;
-	for (before = &inode->i_flock;
-			((fl = *before) != NULL) && IS_LEASE(fl);
-			before = &fl->fl_next) {
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 		if (fl->fl_file == filp) {
-			my_before = before;
+			my_fl = fl;
 			continue;
 		}
+
 		/*
 		 * No exclusive leases if someone else has a lease on
 		 * this file:
@@ -1705,9 +1667,8 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 			goto out;
 	}
 
-	if (my_before != NULL) {
-		lease = *my_before;
-		error = lease->fl_lmops->lm_change(my_before, arg, &dispose);
+	if (my_fl != NULL) {
+		error = lease->fl_lmops->lm_change(&my_fl, arg, &dispose);
 		if (error)
 			goto out;
 		goto out_setup;
@@ -1717,7 +1678,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	if (!leases_enable)
 		goto out;
 
-	locks_insert_lock(before, lease);
+	locks_insert_lock_ctx(lease, &ctx->flc_lease);
 	/*
 	 * The check in break_lease() is lockless. It's possible for another
 	 * open to race in after we did the earlier check for a conflicting
@@ -1729,8 +1690,10 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	 */
 	smp_mb();
 	error = check_conflicting_open(dentry, arg);
-	if (error)
-		goto out_unlink;
+	if (error) {
+		locks_unlink_lock_ctx(lease);
+		goto out;
+	}
 
 out_setup:
 	if (lease->fl_lmops->lm_setup)
@@ -1740,33 +1703,35 @@ out:
 	locks_dispose_list(&dispose);
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
-	if (!error && !my_before)
+	if (!error && !my_fl)
 		*flp = NULL;
 	return error;
-out_unlink:
-	locks_unlink_lock(before);
-	goto out;
 }
 
 static int generic_delete_lease(struct file *filp)
 {
 	int error = -EAGAIN;
-	struct file_lock *fl, **before;
+	struct file_lock *fl, *victim = NULL;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	struct file_lock_context *ctx = inode->i_flctx;
 	LIST_HEAD(dispose);
 
+	if (!ctx) {
+		trace_generic_delete_lease(inode, NULL);
+		return error;
+	}
+
 	spin_lock(&inode->i_lock);
-	time_out_leases(inode, &dispose);
-	for (before = &inode->i_flock;
-			((fl = *before) != NULL) && IS_LEASE(fl);
-			before = &fl->fl_next) {
-		if (fl->fl_file == filp)
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
+		if (fl->fl_file == filp) {
+			victim = fl;
 			break;
+		}
 	}
 	trace_generic_delete_lease(inode, fl);
-	if (fl && IS_LEASE(fl))
-		error = fl->fl_lmops->lm_change(before, F_UNLCK, &dispose);
+	if (victim)
+		error = fl->fl_lmops->lm_change(&victim, F_UNLCK, &dispose);
 	spin_unlock(&inode->i_lock);
 	locks_dispose_list(&dispose);
 	return error;
@@ -2447,56 +2412,37 @@ locks_remove_flock(struct file *filp)
 		fl.fl_ops->fl_release_private(&fl);
 }
 
+static void
+locks_remove_lease(struct file *filp)
+{
+	struct inode *inode = file_inode(filp);
+	struct file_lock_context *ctx = inode->i_flctx;
+	struct file_lock *fl, *tmp;
+	LIST_HEAD(dispose);
+
+	if (!ctx || list_empty(&ctx->flc_lease))
+		return;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list)
+		lease_modify(&fl, F_UNLCK, &dispose);
+	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
+}
+
 /*
  * This function is called on the last close of an open file.
  */
 void locks_remove_file(struct file *filp)
 {
-	struct inode * inode = file_inode(filp);
-	struct file_lock *fl;
-	struct file_lock **before;
-	LIST_HEAD(dispose);
-
 	/* remove any OFD locks */
 	locks_remove_posix(filp, filp);
 
 	/* remove flock locks */
 	locks_remove_flock(filp);
 
-	if (!inode->i_flock)
-		return;
-
-	spin_lock(&inode->i_lock);
-	before = &inode->i_flock;
-
-	while ((fl = *before) != NULL) {
-		if (fl->fl_file == filp) {
-			if (IS_LEASE(fl)) {
-				lease_modify(before, F_UNLCK, &dispose);
-				continue;
-			}
-
-			/*
-			 * There's a leftover lock on the list of a type that
-			 * we didn't expect to see. Most likely a classic
-			 * POSIX lock that ended up not getting released
-			 * properly, or that raced onto the list somehow. Log
-			 * some info about it and then just remove it from
-			 * the list.
-			 */
-			WARN(1, "leftover lock: dev=%u:%u ino=%lu type=%hhd flags=0x%x start=%lld end=%lld\n",
-				MAJOR(inode->i_sb->s_dev),
-				MINOR(inode->i_sb->s_dev), inode->i_ino,
-				fl->fl_type, fl->fl_flags,
-				fl->fl_start, fl->fl_end);
-
-			locks_delete_lock(before, &dispose);
-			continue;
- 		}
-		before = &fl->fl_next;
-	}
-	spin_unlock(&inode->i_lock);
-	locks_dispose_list(&dispose);
+	/* remove any leases */
+	locks_remove_lease(filp);
 }
 
 /**
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 571f113588e9..2ddec3cf81b9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -969,6 +969,7 @@ struct file_lock {
 struct file_lock_context {
 	struct list_head	flc_flock;
 	struct list_head	flc_posix;
+	struct list_head	flc_lease;
 };
 
 /* The following constant reflects the upper bound of the file/locking space */
@@ -1990,7 +1991,7 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 	 * end up racing with tasks trying to set a new lease on this file.
 	 */
 	smp_mb();
-	if (inode->i_flock)
+	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
 		return __break_lease(inode, mode, FL_LEASE);
 	return 0;
 }
@@ -2003,7 +2004,7 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 	 * end up racing with tasks trying to set a new lease on this file.
 	 */
 	smp_mb();
-	if (inode->i_flock)
+	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
 		return __break_lease(inode, mode, FL_DELEG);
 	return 0;
 }
-- 
2.1.0

