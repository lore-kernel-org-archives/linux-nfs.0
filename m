Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44598 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932515AbbAHSfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:35:01 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so3710885qcz.5
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:35:00 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        hch@infradead.org
Subject: [PATCH v2 08/10] locks: add a dedicated spinlock to protect i_flctx lists
Date: Thu,  8 Jan 2015 10:34:23 -0800
Message-Id: <1420742065-28423-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can now add a dedicated spinlock without expanding struct inode.
Change to using that to protect the various i_flctx lists. We do still
use the i_lock to protect the i_flctx pointer itself, but once the
context is assigned to the inode we no longer need it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/ceph/locks.c     |  8 +++---
 fs/cifs/file.c      |  8 +++---
 fs/lockd/svcsubs.c  | 12 ++++----
 fs/locks.c          | 81 +++++++++++++++++++++++++++--------------------------
 fs/nfs/delegation.c |  8 +++---
 fs/nfs/nfs4state.c  |  8 +++---
 fs/nfs/write.c      |  4 +--
 fs/nfsd/nfs4state.c |  4 +--
 include/linux/fs.h  |  1 +
 9 files changed, 68 insertions(+), 66 deletions(-)

diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index 4ee44165f10c..3f225c61024f 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -255,12 +255,12 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 
 	ctx = inode->i_flctx;
 	if (ctx) {
-		spin_lock(&inode->i_lock);
+		spin_lock(&ctx->flc_lock);
 		list_for_each_entry(lock, &ctx->flc_posix, fl_list)
 			++(*fcntl_count);
 		list_for_each_entry(lock, &ctx->flc_flock, fl_list)
 			++(*flock_count);
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&ctx->flc_lock);
 	}
 
 	dout("counted %d flock locks and %d fcntl locks",
@@ -289,7 +289,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 	if (!ctx)
 		return 0;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	list_for_each_entry(lock, &ctx->flc_flock, fl_list) {
 		++seen_fcntl;
 		if (seen_fcntl > num_fcntl_locks) {
@@ -313,7 +313,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 		++l;
 	}
 fail:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	return err;
 }
 
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index ea78f6f81ce2..b65166eb111e 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1136,11 +1136,11 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	if (!flctx)
 		goto out;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 	list_for_each(el, &flctx->flc_posix) {
 		count++;
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 
 	INIT_LIST_HEAD(&locks_to_send);
 
@@ -1159,7 +1159,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	}
 
 	el = locks_to_send.next;
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 	list_for_each_entry(flock, &flctx->flc_posix, fl_list) {
 		if (el == &locks_to_send) {
 			/*
@@ -1181,7 +1181,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 		lck->type = type;
 		lck->offset = flock->fl_start;
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 
 	list_for_each_entry_safe(lck, tmp, &locks_to_send, llist) {
 		int stored_rc;
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 34567b22dff0..aaa5e2600e01 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -171,7 +171,7 @@ nlm_traverse_locks(struct nlm_host *host, struct nlm_file *file,
 		return 0;
 again:
 	file->f_locks = 0;
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 	list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
 		if (fl->fl_lmops != &nlmsvc_lock_operations)
 			continue;
@@ -183,7 +183,7 @@ again:
 		if (match(lockhost, host)) {
 			struct file_lock lock = *fl;
 
-			spin_unlock(&inode->i_lock);
+			spin_unlock(&flctx->flc_lock);
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
@@ -195,7 +195,7 @@ again:
 			goto again;
 		}
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 
 	return 0;
 }
@@ -232,14 +232,14 @@ nlm_file_inuse(struct nlm_file *file)
 		return 1;
 
 	if (flctx && !list_empty(&flctx->flc_posix)) {
-		spin_lock(&inode->i_lock);
+		spin_lock(&flctx->flc_lock);
 		list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
 			if (fl->fl_lmops == &nlmsvc_lock_operations) {
-				spin_unlock(&inode->i_lock);
+				spin_unlock(&flctx->flc_lock);
 				return 1;
 			}
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&flctx->flc_lock);
 	}
 	file->f_locks = 0;
 	return 0;
diff --git a/fs/locks.c b/fs/locks.c
index acfad02bc136..2cded21b99ac 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -161,7 +161,7 @@ int lease_break_time = 45;
  * The global file_lock_list is only used for displaying /proc/locks, so we
  * keep a list on each CPU, with each list protected by its own spinlock via
  * the file_lock_lglock. Note that alterations to the list also require that
- * the relevant i_lock is held.
+ * the relevant flc_lock is held.
  */
 DEFINE_STATIC_LGLOCK(file_lock_lglock);
 static DEFINE_PER_CPU(struct hlist_head, file_lock_list);
@@ -189,12 +189,12 @@ static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
  * contrast to those that are acting as records of acquired locks).
  *
  * Note that when we acquire this lock in order to change the above fields,
- * we often hold the i_lock as well. In certain cases, when reading the fields
+ * we often hold the flc_lock as well. In certain cases, when reading the fields
  * protected by this lock, we can skip acquiring it iff we already hold the
- * i_lock.
+ * flc_lock.
  *
  * In particular, adding an entry to the fl_block list requires that you hold
- * both the i_lock and the blocked_lock_lock (acquired in that order). Deleting
+ * both the flc_lock and the blocked_lock_lock (acquired in that order). Deleting
  * an entry from the list however only requires the file_lock_lock.
  */
 static DEFINE_SPINLOCK(blocked_lock_lock);
@@ -214,6 +214,7 @@ locks_get_lock_context(struct inode *inode)
 	if (!new)
 		goto out;
 
+	spin_lock_init(&new->flc_lock);
 	INIT_LIST_HEAD(&new->flc_flock);
 	INIT_LIST_HEAD(&new->flc_posix);
 	INIT_LIST_HEAD(&new->flc_lease);
@@ -550,7 +551,7 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 	return fl1->fl_owner == fl2->fl_owner;
 }
 
-/* Must be called with the i_lock held! */
+/* Must be called with the flc_lock held! */
 static void locks_insert_global_locks(struct file_lock *fl)
 {
 	lg_local_lock(&file_lock_lglock);
@@ -559,12 +560,12 @@ static void locks_insert_global_locks(struct file_lock *fl)
 	lg_local_unlock(&file_lock_lglock);
 }
 
-/* Must be called with the i_lock held! */
+/* Must be called with the flc_lock held! */
 static void locks_delete_global_locks(struct file_lock *fl)
 {
 	/*
 	 * Avoid taking lock if already unhashed. This is safe since this check
-	 * is done while holding the i_lock, and new insertions into the list
+	 * is done while holding the flc_lock, and new insertions into the list
 	 * also require that it be held.
 	 */
 	if (hlist_unhashed(&fl->fl_link))
@@ -616,9 +617,9 @@ static void locks_delete_block(struct file_lock *waiter)
  * the order they blocked. The documentation doesn't require this but
  * it seems like the reasonable thing to do.
  *
- * Must be called with both the i_lock and blocked_lock_lock held. The fl_block
+ * Must be called with both the flc_lock and blocked_lock_lock held. The fl_block
  * list itself is protected by the blocked_lock_lock, but by ensuring that the
- * i_lock is also held on insertions we can avoid taking the blocked_lock_lock
+ * flc_lock is also held on insertions we can avoid taking the blocked_lock_lock
  * in some cases when we see that the fl_block list is empty.
  */
 static void __locks_insert_block(struct file_lock *blocker,
@@ -631,7 +632,7 @@ static void __locks_insert_block(struct file_lock *blocker,
 		locks_insert_global_blocked(waiter);
 }
 
-/* Must be called with i_lock held. */
+/* Must be called with flc_lock held. */
 static void locks_insert_block(struct file_lock *blocker,
 					struct file_lock *waiter)
 {
@@ -643,15 +644,15 @@ static void locks_insert_block(struct file_lock *blocker,
 /*
  * Wake up processes blocked waiting for blocker.
  *
- * Must be called with the inode->i_lock held!
+ * Must be called with the inode->flc_lock held!
  */
 static void locks_wake_up_blocks(struct file_lock *blocker)
 {
 	/*
 	 * Avoid taking global lock if list is empty. This is safe since new
-	 * blocked requests are only added to the list under the i_lock, and
-	 * the i_lock is always held here. Note that removal from the fl_block
-	 * list does not require the i_lock, so we must recheck list_empty()
+	 * blocked requests are only added to the list under the flc_lock, and
+	 * the flc_lock is always held here. Note that removal from the fl_block
+	 * list does not require the flc_lock, so we must recheck list_empty()
 	 * after acquiring the blocked_lock_lock.
 	 */
 	if (list_empty(&blocker->fl_block))
@@ -761,7 +762,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 		return;
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
 		if (posix_locks_conflict(fl, cfl)) {
 			locks_copy_conflock(fl, cfl);
@@ -772,7 +773,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 	}
 	fl->fl_type = F_UNLCK;
 out:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	return;
 }
 EXPORT_SYMBOL(posix_test_lock);
@@ -873,7 +874,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 			return -ENOMEM;
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	if (request->fl_flags & FL_ACCESS)
 		goto find_conflict;
 
@@ -898,9 +899,9 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 	 * give it the opportunity to lock the file.
 	 */
 	if (found) {
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&ctx->flc_lock);
 		cond_resched();
-		spin_lock(&inode->i_lock);
+		spin_lock(&ctx->flc_lock);
 	}
 
 find_conflict:
@@ -922,7 +923,7 @@ find_conflict:
 	error = 0;
 
 out:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	if (new_fl)
 		locks_free_lock(new_fl);
 	locks_dispose_list(&dispose);
@@ -958,7 +959,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		new_fl2 = locks_alloc_lock();
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	/*
 	 * New lock request. Walk all POSIX locks and look for conflicts. If
 	 * there are any, either return error or put the request on the
@@ -1129,7 +1130,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		locks_wake_up_blocks(left);
 	}
  out:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	/*
 	 * Free any unused locks.
 	 */
@@ -1211,7 +1212,7 @@ int locks_mandatory_locked(struct file *file)
 	/*
 	 * Search the lock list for this inode for any POSIX locks.
 	 */
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	ret = 0;
 	list_for_each_entry(fl, &ctx->flc_posix, fl_list) {
 		if (fl->fl_owner != current->files &&
@@ -1220,7 +1221,7 @@ int locks_mandatory_locked(struct file *file)
 			break;
 		}
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	return ret;
 }
 
@@ -1339,7 +1340,7 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 	struct file_lock_context *ctx = inode->i_flctx;
 	struct file_lock *fl, *tmp;
 
-	lockdep_assert_held(&inode->i_lock);
+	lockdep_assert_held(&ctx->flc_lock);
 
 	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list) {
 		trace_time_out_leases(inode, fl);
@@ -1363,7 +1364,7 @@ any_leases_conflict(struct inode *inode, struct file_lock *breaker)
 	struct file_lock_context *ctx = inode->i_flctx;
 	struct file_lock *fl;
 
-	lockdep_assert_held(&inode->i_lock);
+	lockdep_assert_held(&ctx->flc_lock);
 
 	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 		if (leases_conflict(fl, breaker))
@@ -1406,7 +1407,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 		return error;
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 
 	time_out_leases(inode, &dispose);
 
@@ -1456,11 +1457,11 @@ restart:
 		break_time++;
 	locks_insert_block(fl, new_fl);
 	trace_break_lease_block(inode, new_fl);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 	error = wait_event_interruptible_timeout(new_fl->fl_wait,
 						!new_fl->fl_next, break_time);
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	trace_break_lease_unblock(inode, new_fl);
 	locks_delete_block(new_fl);
 	if (error >= 0) {
@@ -1475,7 +1476,7 @@ restart:
 		error = 0;
 	}
 out:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 	locks_free_lock(new_fl);
 	return error;
@@ -1499,13 +1500,13 @@ void lease_get_mtime(struct inode *inode, struct timespec *time)
 	struct file_lock *fl;
 
 	if (ctx) {
-		spin_lock(&inode->i_lock);
+		spin_lock(&ctx->flc_lock);
 		if (!list_empty(&ctx->flc_lease)) {
 			fl = list_first_entry(&ctx->flc_lease, struct file_lock, fl_list);
 			if (fl->fl_type == F_WRLCK)
 				has_lease = true;
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&ctx->flc_lock);
 	}
 
 	if (has_lease)
@@ -1548,7 +1549,7 @@ int fcntl_getlease(struct file *filp)
 	LIST_HEAD(dispose);
 
 	if (ctx) {
-		spin_lock(&inode->i_lock);
+		spin_lock(&ctx->flc_lock);
 		time_out_leases(file_inode(filp), &dispose);
 		list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 			if (fl->fl_file != filp)
@@ -1556,7 +1557,7 @@ int fcntl_getlease(struct file *filp)
 			type = target_leasetype(fl);
 			break;
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&ctx->flc_lock);
 		locks_dispose_list(&dispose);
 	}
 	return type;
@@ -1624,7 +1625,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 		return -EINVAL;
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	time_out_leases(inode, &dispose);
 	error = check_conflicting_open(dentry, arg);
 	if (error)
@@ -1691,7 +1692,7 @@ out_setup:
 	if (lease->fl_lmops->lm_setup)
 		lease->fl_lmops->lm_setup(lease, priv);
 out:
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
@@ -1714,7 +1715,7 @@ static int generic_delete_lease(struct file *filp)
 		return error;
 	}
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
 		if (fl->fl_file == filp) {
 			victim = fl;
@@ -1724,7 +1725,7 @@ static int generic_delete_lease(struct file *filp)
 	trace_generic_delete_lease(inode, fl);
 	if (victim)
 		error = fl->fl_lmops->lm_change(&victim, F_UNLCK, &dispose);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 	return error;
 }
@@ -2414,10 +2415,10 @@ locks_remove_lease(struct file *filp)
 	if (!ctx)
 		return;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&ctx->flc_lock);
 	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list)
 		lease_modify(&fl, F_UNLCK, &dispose);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 }
 
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 3fb1caa3874d..8cdb2b28a104 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -93,22 +93,22 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 		goto out;
 
 	list = &flctx->flc_posix;
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 restart:
 	list_for_each_entry(fl, list, fl_list) {
 		if (nfs_file_open_context(fl->fl_file) != ctx)
 			continue;
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&flctx->flc_lock);
 		status = nfs4_lock_delegation_recall(fl, state, stateid);
 		if (status < 0)
 			goto out;
-		spin_lock(&inode->i_lock);
+		spin_lock(&flctx->flc_lock);
 	}
 	if (list == &flctx->flc_posix) {
 		list = &flctx->flc_flock;
 		goto restart;
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d0a2bd1ecb1..2f4515bd2c7b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1377,12 +1377,12 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	/* Guard against delegation returns and new lock/unlock calls */
 	down_write(&nfsi->rwsem);
 	/* Protect inode->i_flock using the BKL */
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 restart:
 	list_for_each_entry(fl, list, fl_list) {
 		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&flctx->flc_lock);
 		status = ops->recover_lock(state, fl);
 		switch (status) {
 			case 0:
@@ -1409,13 +1409,13 @@ restart:
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
 				status = 0;
 		}
-		spin_lock(&inode->i_lock);
+		spin_lock(&flctx->flc_lock);
 	}
 	if (list == &flctx->flc_posix) {
 		list = &flctx->flc_flock;
 		goto restart;
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 out:
 	up_write(&nfsi->rwsem);
 	return status;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ee43aad0fb4e..df245bccd10a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1204,7 +1204,7 @@ static int nfs_can_extend_write(struct file *file, struct page *page, struct ino
 
 	/* Check to see if there are whole file write locks */
 	ret = 0;
-	spin_lock(&inode->i_lock);
+	spin_lock(&flctx->flc_lock);
 	if (!list_empty(&flctx->flc_posix)) {
 		fl = list_first_entry(&flctx->flc_posix, struct file_lock, fl_list);
 		if (is_whole_file_wrlock(fl))
@@ -1214,7 +1214,7 @@ static int nfs_can_extend_write(struct file *file, struct page *page, struct ino
 		if (fl->fl_type == F_WRLCK)
 			ret = 1;
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&flctx->flc_lock);
 	return ret;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ee4c660b2e47..159a3a79df83 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5572,14 +5572,14 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 	flctx = inode->i_flctx;
 
 	if (flctx && !list_empty(&flctx->flc_posix)) {
-		spin_lock(&inode->i_lock);
+		spin_lock(&flctx->flc_lock);
 		list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
 			if (fl->fl_owner == (fl_owner_t)lowner) {
 				status = true;
 				break;
 			}
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&flctx->flc_lock);
 	}
 	fput(filp);
 	return status;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7da02cb90b30..cbf89d9085a5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -968,6 +968,7 @@ struct file_lock {
 };
 
 struct file_lock_context {
+	spinlock_t		flc_lock;
 	struct list_head	flc_flock;
 	struct list_head	flc_posix;
 	struct list_head	flc_lease;
-- 
2.1.0

