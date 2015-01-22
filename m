Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.229]:37279 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753418AbbAVO3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:29:16 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 06/13] locks: convert posix locks to file_lock_context
Date: Thu, 22 Jan 2015 09:27:50 -0500
Message-Id: <1421936877-27529-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/locks.c     |  58 +++++++++++++---------------
 fs/cifs/file.c      |  26 +++++--------
 fs/lockd/svcsubs.c  |  20 ++++++----
 fs/locks.c          | 108 +++++++++++++++++++++++++++-------------------------
 fs/nfs/delegation.c |  28 +++++---------
 fs/nfs/nfs4state.c  |  52 +++++--------------------
 fs/nfs/pagelist.c   |   8 ++--
 fs/nfs/write.c      |  30 +++++++--------
 fs/nfsd/nfs4state.c |  18 +++++----
 fs/read_write.c     |   2 +-
 include/linux/fs.h  |   3 +-
 11 files changed, 155 insertions(+), 198 deletions(-)

diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index 917656ea8dcf..19beeed83233 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -253,18 +253,15 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 	*fcntl_count = 0;
 	*flock_count = 0;
 
-	spin_lock(&inode->i_lock);
-	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
-		if (lock->fl_flags & FL_POSIX)
-			++(*fcntl_count);
-	}
-
 	ctx = inode->i_flctx;
 	if (ctx) {
+		spin_lock(&inode->i_lock);
+		list_for_each_entry(lock, &ctx->flc_posix, fl_list)
+			++(*fcntl_count);
 		list_for_each_entry(lock, &ctx->flc_flock, fl_list)
 			++(*flock_count);
+		spin_unlock(&inode->i_lock);
 	}
-	spin_unlock(&inode->i_lock);
 	dout("counted %d flock locks and %d fcntl locks",
 	     *flock_count, *fcntl_count);
 }
@@ -279,7 +276,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 				int num_fcntl_locks, int num_flock_locks)
 {
 	struct file_lock *lock;
-	struct file_lock_context *ctx;
+	struct file_lock_context *ctx = inode->i_flctx;
 	int err = 0;
 	int seen_fcntl = 0;
 	int seen_flock = 0;
@@ -288,34 +285,31 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 	dout("encoding %d flock and %d fcntl locks", num_flock_locks,
 	     num_fcntl_locks);
 
+	if (!ctx)
+		return 0;
+
 	spin_lock(&inode->i_lock);
-	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
-		if (lock->fl_flags & FL_POSIX) {
-			++seen_fcntl;
-			if (seen_fcntl > num_fcntl_locks) {
-				err = -ENOSPC;
-				goto fail;
-			}
-			err = lock_to_ceph_filelock(lock, &flocks[l]);
-			if (err)
-				goto fail;
-			++l;
+	list_for_each_entry(lock, &ctx->flc_flock, fl_list) {
+		++seen_fcntl;
+		if (seen_fcntl > num_fcntl_locks) {
+			err = -ENOSPC;
+			goto fail;
 		}
+		err = lock_to_ceph_filelock(lock, &flocks[l]);
+		if (err)
+			goto fail;
+		++l;
 	}
-
-	ctx = inode->i_flctx;
-	if (ctx) {
-		list_for_each_entry(lock, &ctx->flc_flock, fl_list) {
-			++seen_flock;
-			if (seen_flock > num_flock_locks) {
-				err = -ENOSPC;
-				goto fail;
-			}
-			err = lock_to_ceph_filelock(lock, &flocks[l]);
-			if (err)
-				goto fail;
-			++l;
+	list_for_each_entry(lock, &ctx->flc_flock, fl_list) {
+		++seen_flock;
+		if (seen_flock > num_flock_locks) {
+			err = -ENOSPC;
+			goto fail;
 		}
+		err = lock_to_ceph_filelock(lock, &flocks[l]);
+		if (err)
+			goto fail;
+		++l;
 	}
 fail:
 	spin_unlock(&inode->i_lock);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 96b7e9b7706d..ea78f6f81ce2 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1109,11 +1109,6 @@ cifs_push_mandatory_locks(struct cifsFileInfo *cfile)
 	return rc;
 }
 
-/* copied from fs/locks.c with a name change */
-#define cifs_for_each_lock(inode, lockp) \
-	for (lockp = &inode->i_flock; *lockp != NULL; \
-	     lockp = &(*lockp)->fl_next)
-
 struct lock_to_push {
 	struct list_head llist;
 	__u64 offset;
@@ -1128,8 +1123,9 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 {
 	struct inode *inode = cfile->dentry->d_inode;
 	struct cifs_tcon *tcon = tlink_tcon(cfile->tlink);
-	struct file_lock *flock, **before;
-	unsigned int count = 0, i = 0;
+	struct file_lock *flock;
+	struct file_lock_context *flctx = inode->i_flctx;
+	unsigned int count = 0, i;
 	int rc = 0, xid, type;
 	struct list_head locks_to_send, *el;
 	struct lock_to_push *lck, *tmp;
@@ -1137,10 +1133,12 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 
 	xid = get_xid();
 
+	if (!flctx)
+		goto out;
+
 	spin_lock(&inode->i_lock);
-	cifs_for_each_lock(inode, before) {
-		if ((*before)->fl_flags & FL_POSIX)
-			count++;
+	list_for_each(el, &flctx->flc_posix) {
+		count++;
 	}
 	spin_unlock(&inode->i_lock);
 
@@ -1151,7 +1149,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	 * added to the list while we are holding cinode->lock_sem that
 	 * protects locking operations of this inode.
 	 */
-	for (; i < count; i++) {
+	for (i = 0; i < count; i++) {
 		lck = kmalloc(sizeof(struct lock_to_push), GFP_KERNEL);
 		if (!lck) {
 			rc = -ENOMEM;
@@ -1162,10 +1160,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 
 	el = locks_to_send.next;
 	spin_lock(&inode->i_lock);
-	cifs_for_each_lock(inode, before) {
-		flock = *before;
-		if ((flock->fl_flags & FL_POSIX) == 0)
-			continue;
+	list_for_each_entry(flock, &flctx->flc_posix, fl_list) {
 		if (el == &locks_to_send) {
 			/*
 			 * The list ended. We don't have enough allocated
@@ -1185,7 +1180,6 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 		lck->length = length;
 		lck->type = type;
 		lck->offset = flock->fl_start;
-		el = el->next;
 	}
 	spin_unlock(&inode->i_lock);
 
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index d12ff4e2dbe7..5300bb53835f 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -164,12 +164,15 @@ nlm_traverse_locks(struct nlm_host *host, struct nlm_file *file,
 {
 	struct inode	 *inode = nlmsvc_file_inode(file);
 	struct file_lock *fl;
+	struct file_lock_context *flctx = inode->i_flctx;
 	struct nlm_host	 *lockhost;
 
+	if (!flctx || list_empty_careful(&flctx->flc_posix))
+		return 0;
 again:
 	file->f_locks = 0;
 	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
+	list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
 		if (fl->fl_lmops != &nlmsvc_lock_operations)
 			continue;
 
@@ -223,18 +226,21 @@ nlm_file_inuse(struct nlm_file *file)
 {
 	struct inode	 *inode = nlmsvc_file_inode(file);
 	struct file_lock *fl;
+	struct file_lock_context *flctx = inode->i_flctx;
 
 	if (file->f_count || !list_empty(&file->f_blocks) || file->f_shares)
 		return 1;
 
-	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
-		if (fl->fl_lmops == &nlmsvc_lock_operations) {
-			spin_unlock(&inode->i_lock);
-			return 1;
+	if (flctx && !list_empty_careful(&flctx->flc_posix)) {
+		spin_lock(&inode->i_lock);
+		list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
+			if (fl->fl_lmops == &nlmsvc_lock_operations) {
+				spin_unlock(&inode->i_lock);
+				return 1;
+			}
 		}
+		spin_unlock(&inode->i_lock);
 	}
-	spin_unlock(&inode->i_lock);
 	file->f_locks = 0;
 	return 0;
 }
diff --git a/fs/locks.c b/fs/locks.c
index 055df53f19de..e50bb4d9e757 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -157,9 +157,6 @@ static int target_leasetype(struct file_lock *fl)
 int leases_enable = 1;
 int lease_break_time = 45;
 
-#define for_each_lock(inode, lockp) \
-	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
-
 /*
  * The global file_lock_list is only used for displaying /proc/locks, so we
  * keep a list on each CPU, with each list protected by its own spinlock via
@@ -218,6 +215,7 @@ locks_get_lock_context(struct inode *inode)
 		goto out;
 
 	INIT_LIST_HEAD(&new->flc_flock);
+	INIT_LIST_HEAD(&new->flc_posix);
 
 	/*
 	 * Assign the pointer if it's not already assigned. If it is, then
@@ -241,6 +239,7 @@ locks_free_lock_context(struct file_lock_context *ctx)
 {
 	if (ctx) {
 		WARN_ON_ONCE(!list_empty(&ctx->flc_flock));
+		WARN_ON_ONCE(!list_empty(&ctx->flc_posix));
 		kmem_cache_free(flctx_cache, ctx);
 	}
 }
@@ -809,21 +808,26 @@ void
 posix_test_lock(struct file *filp, struct file_lock *fl)
 {
 	struct file_lock *cfl;
+	struct file_lock_context *ctx;
 	struct inode *inode = file_inode(filp);
 
+	ctx = inode->i_flctx;
+	if (!ctx || list_empty_careful(&ctx->flc_posix)) {
+		fl->fl_type = F_UNLCK;
+		return;
+	}
+
 	spin_lock(&inode->i_lock);
-	for (cfl = file_inode(filp)->i_flock; cfl; cfl = cfl->fl_next) {
-		if (!IS_POSIX(cfl))
-			continue;
-		if (posix_locks_conflict(fl, cfl))
-			break;
+	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
+		if (posix_locks_conflict(fl, cfl)) {
+			locks_copy_conflock(fl, cfl);
+			if (cfl->fl_nspid)
+				fl->fl_pid = pid_vnr(cfl->fl_nspid);
+			goto out;
+		}
 	}
-	if (cfl) {
-		locks_copy_conflock(fl, cfl);
-		if (cfl->fl_nspid)
-			fl->fl_pid = pid_vnr(cfl->fl_nspid);
-	} else
-		fl->fl_type = F_UNLCK;
+	fl->fl_type = F_UNLCK;
+out:
 	spin_unlock(&inode->i_lock);
 	return;
 }
@@ -983,16 +987,20 @@ out:
 
 static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
 {
-	struct file_lock *fl;
+	struct file_lock *fl, *tmp;
 	struct file_lock *new_fl = NULL;
 	struct file_lock *new_fl2 = NULL;
 	struct file_lock *left = NULL;
 	struct file_lock *right = NULL;
-	struct file_lock **before;
+	struct file_lock_context *ctx;
 	int error;
 	bool added = false;
 	LIST_HEAD(dispose);
 
+	ctx = locks_get_lock_context(inode);
+	if (!ctx)
+		return -ENOMEM;
+
 	/*
 	 * We may need two file_lock structures for this operation,
 	 * so we get them in advance to avoid races.
@@ -1013,8 +1021,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	 * blocker's list of waiters and the global blocked_hash.
 	 */
 	if (request->fl_type != F_UNLCK) {
-		for_each_lock(inode, before) {
-			fl = *before;
+		list_for_each_entry(fl, &ctx->flc_posix, fl_list) {
 			if (!IS_POSIX(fl))
 				continue;
 			if (!posix_locks_conflict(request, fl))
@@ -1044,29 +1051,25 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	if (request->fl_flags & FL_ACCESS)
 		goto out;
 
-	/*
-	 * Find the first old lock with the same owner as the new lock.
-	 */
-	
-	before = &inode->i_flock;
-
-	/* First skip locks owned by other processes.  */
-	while ((fl = *before) && (!IS_POSIX(fl) ||
-				  !posix_same_owner(request, fl))) {
-		before = &fl->fl_next;
+	/* Find the first old lock with the same owner as the new lock */
+	list_for_each_entry(fl, &ctx->flc_posix, fl_list) {
+		if (posix_same_owner(request, fl))
+			break;
 	}
 
 	/* Process locks with this owner. */
-	while ((fl = *before) && posix_same_owner(request, fl)) {
-		/* Detect adjacent or overlapping regions (if same lock type)
-		 */
+	list_for_each_entry_safe_from(fl, tmp, &ctx->flc_posix, fl_list) {
+		if (!posix_same_owner(request, fl))
+			break;
+
+		/* Detect adjacent or overlapping regions (if same lock type) */
 		if (request->fl_type == fl->fl_type) {
 			/* In all comparisons of start vs end, use
 			 * "start - 1" rather than "end + 1". If end
 			 * is OFFSET_MAX, end + 1 will become negative.
 			 */
 			if (fl->fl_end < request->fl_start - 1)
-				goto next_lock;
+				continue;
 			/* If the next lock in the list has entirely bigger
 			 * addresses than the new one, insert the lock here.
 			 */
@@ -1087,18 +1090,17 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			else
 				request->fl_end = fl->fl_end;
 			if (added) {
-				locks_delete_lock(before, &dispose);
+				locks_delete_lock_ctx(fl, &dispose);
 				continue;
 			}
 			request = fl;
 			added = true;
-		}
-		else {
+		} else {
 			/* Processing for different lock types is a bit
 			 * more complex.
 			 */
 			if (fl->fl_end < request->fl_start)
-				goto next_lock;
+				continue;
 			if (fl->fl_start > request->fl_end)
 				break;
 			if (request->fl_type == F_UNLCK)
@@ -1117,7 +1119,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				 * one (This may happen several times).
 				 */
 				if (added) {
-					locks_delete_lock(before, &dispose);
+					locks_delete_lock_ctx(fl, &dispose);
 					continue;
 				}
 				/*
@@ -1133,15 +1135,11 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				locks_copy_lock(new_fl, request);
 				request = new_fl;
 				new_fl = NULL;
-				locks_delete_lock(before, &dispose);
-				locks_insert_lock(before, request);
+				locks_insert_lock_ctx(request, &fl->fl_list);
+				locks_delete_lock_ctx(fl, &dispose);
 				added = true;
 			}
 		}
-		/* Go on to next lock.
-		 */
-	next_lock:
-		before = &fl->fl_next;
 	}
 
 	/*
@@ -1166,7 +1164,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			goto out;
 		}
 		locks_copy_lock(new_fl, request);
-		locks_insert_lock(before, new_fl);
+		locks_insert_lock_ctx(new_fl, &fl->fl_list);
 		new_fl = NULL;
 	}
 	if (right) {
@@ -1177,7 +1175,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			left = new_fl2;
 			new_fl2 = NULL;
 			locks_copy_lock(left, right);
-			locks_insert_lock(before, left);
+			locks_insert_lock_ctx(left, &fl->fl_list);
 		}
 		right->fl_start = request->fl_end + 1;
 		locks_wake_up_blocks(right);
@@ -1257,22 +1255,29 @@ EXPORT_SYMBOL(posix_lock_file_wait);
  */
 int locks_mandatory_locked(struct file *file)
 {
+	int ret;
 	struct inode *inode = file_inode(file);
+	struct file_lock_context *ctx;
 	struct file_lock *fl;
 
+	ctx = inode->i_flctx;
+	if (!ctx || list_empty_careful(&ctx->flc_posix))
+		return 0;
+
 	/*
 	 * Search the lock list for this inode for any POSIX locks.
 	 */
 	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (!IS_POSIX(fl))
-			continue;
+	ret = 0;
+	list_for_each_entry(fl, &ctx->flc_posix, fl_list) {
 		if (fl->fl_owner != current->files &&
-		    fl->fl_owner != file)
+		    fl->fl_owner != file) {
+			ret = -EAGAIN;
 			break;
+		}
 	}
 	spin_unlock(&inode->i_lock);
-	return fl ? -EAGAIN : 0;
+	return ret;
 }
 
 /**
@@ -2389,13 +2394,14 @@ out:
 void locks_remove_posix(struct file *filp, fl_owner_t owner)
 {
 	struct file_lock lock;
+	struct file_lock_context *ctx = file_inode(filp)->i_flctx;
 
 	/*
 	 * If there are no locks held on this file, we don't need to call
 	 * posix_lock_file().  Another process could be setting a lock on this
 	 * file at the same time, but we wouldn't remove that lock anyway.
 	 */
-	if (!file_inode(filp)->i_flock)
+	if (!ctx || list_empty(&ctx->flc_posix))
 		return;
 
 	lock.fl_type = F_UNLCK;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 9f9f67b17e2b..3fb1caa3874d 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -85,17 +85,17 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
-	struct file_lock_context *flctx;
+	struct file_lock_context *flctx = inode->i_flctx;
+	struct list_head *list;
 	int status = 0;
 
-	if (inode->i_flock == NULL && inode->i_flctx == NULL)
+	if (flctx == NULL)
 		goto out;
 
-	/* Protect inode->i_flock using the i_lock */
+	list = &flctx->flc_posix;
 	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (!(fl->fl_flags & (FL_POSIX)))
-			continue;
+restart:
+	list_for_each_entry(fl, list, fl_list) {
 		if (nfs_file_open_context(fl->fl_file) != ctx)
 			continue;
 		spin_unlock(&inode->i_lock);
@@ -104,19 +104,9 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 			goto out;
 		spin_lock(&inode->i_lock);
 	}
-
-	flctx = inode->i_flctx;
-	if (flctx) {
-		list_for_each_entry(fl, &flctx->flc_flock, fl_list) {
-			if (nfs_file_open_context(fl->fl_file) != ctx)
-				continue;
-			spin_unlock(&inode->i_lock);
-			status = nfs4_lock_delegation_recall(fl, state,
-								stateid);
-			if (status < 0)
-				goto out;
-			spin_lock(&inode->i_lock);
-		}
+	if (list == &flctx->flc_posix) {
+		list = &flctx->flc_flock;
+		goto restart;
 	}
 	spin_unlock(&inode->i_lock);
 out:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 65c404bf61ae..6084c267f3a0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1367,53 +1367,18 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	struct file_lock *fl;
 	int status = 0;
 	struct file_lock_context *flctx = inode->i_flctx;
+	struct list_head *list;
 
-	if (inode->i_flock == NULL && flctx == NULL)
+	if (flctx == NULL)
 		return 0;
 
+	list = &flctx->flc_posix;
+
 	/* Guard against delegation returns and new lock/unlock calls */
 	down_write(&nfsi->rwsem);
-	/* Protect inode->i_flock using the BKL */
 	spin_lock(&inode->i_lock);
-	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (!(fl->fl_flags & FL_POSIX))
-			continue;
-		if (nfs_file_open_context(fl->fl_file)->state != state)
-			continue;
-		spin_unlock(&inode->i_lock);
-		status = ops->recover_lock(state, fl);
-		switch (status) {
-			case 0:
-				break;
-			case -ESTALE:
-			case -NFS4ERR_ADMIN_REVOKED:
-			case -NFS4ERR_STALE_STATEID:
-			case -NFS4ERR_BAD_STATEID:
-			case -NFS4ERR_EXPIRED:
-			case -NFS4ERR_NO_GRACE:
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_BADSESSION:
-			case -NFS4ERR_BADSLOT:
-			case -NFS4ERR_BAD_HIGH_SLOT:
-			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
-				goto out;
-			default:
-				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
-					 __func__, status);
-			case -ENOMEM:
-			case -NFS4ERR_DENIED:
-			case -NFS4ERR_RECLAIM_BAD:
-			case -NFS4ERR_RECLAIM_CONFLICT:
-				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
-				status = 0;
-		}
-		spin_lock(&inode->i_lock);
-	}
-
-	if (!flctx)
-		goto out_unlock;
-
-	list_for_each_entry(fl, &flctx->flc_flock, fl_list) {
+restart:
+	list_for_each_entry(fl, list, fl_list) {
 		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
 		spin_unlock(&inode->i_lock);
@@ -1445,7 +1410,10 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 		}
 		spin_lock(&inode->i_lock);
 	}
-out_unlock:
+	if (list == &flctx->flc_posix) {
+		list = &flctx->flc_flock;
+		goto restart;
+	}
 	spin_unlock(&inode->i_lock);
 out:
 	up_write(&nfsi->rwsem);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a3b62e15b444..29c7f33c9cf1 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -831,12 +831,10 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 	if (prev) {
 		if (!nfs_match_open_context(req->wb_context, prev->wb_context))
 			return false;
-		if (req->wb_context->dentry->d_inode->i_flock != NULL &&
-		    !nfs_match_lock_context(req->wb_lock_context,
-					    prev->wb_lock_context))
-			return false;
 		flctx = req->wb_context->dentry->d_inode->i_flctx;
-		if (flctx != NULL && !list_empty_careful(&flctx->flc_flock) &&
+		if (flctx != NULL &&
+		    !(list_empty_careful(&flctx->flc_posix) &&
+		      list_empty_careful(&flctx->flc_flock)) &&
 		    !nfs_match_lock_context(req->wb_lock_context,
 					    prev->wb_lock_context))
 			return false;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e072aeb34195..784c13485b3f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1091,6 +1091,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct nfs_lock_context *l_ctx;
+	struct file_lock_context *flctx = file_inode(file)->i_flctx;
 	struct nfs_page	*req;
 	int do_flush, status;
 	/*
@@ -1109,12 +1110,9 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		do_flush = req->wb_page != page || req->wb_context != ctx;
 		/* for now, flush if more than 1 request in page_group */
 		do_flush |= req->wb_this_page != req;
-		if (l_ctx && ctx->dentry->d_inode->i_flock != NULL) {
-			do_flush |= l_ctx->lockowner.l_owner != current->files
-				|| l_ctx->lockowner.l_pid != current->tgid;
-		}
-		if (l_ctx && ctx->dentry->d_inode->i_flctx &&
-		    !list_empty_careful(&ctx->dentry->d_inode->i_flctx->flc_flock)) {
+		if (l_ctx && flctx &&
+		    !(list_empty_careful(&flctx->flc_posix) &&
+		      list_empty_careful(&flctx->flc_flock))) {
 			do_flush |= l_ctx->lockowner.l_owner != current->files
 				|| l_ctx->lockowner.l_pid != current->tgid;
 		}
@@ -1202,26 +1200,24 @@ static int nfs_can_extend_write(struct file *file, struct page *page, struct ino
 		return 0;
 	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
 		return 1;
-	if (!inode->i_flock && !flctx)
+	if (!flctx || (list_empty_careful(&flctx->flc_flock) &&
+		       list_empty_careful(&flctx->flc_posix)))
 		return 0;
 
 	/* Check to see if there are whole file write locks */
-	spin_lock(&inode->i_lock);
 	ret = 0;
-
-	fl = inode->i_flock;
-	if (fl && is_whole_file_wrlock(fl)) {
-		ret = 1;
-		goto out;
-	}
-
-	if (!list_empty(&flctx->flc_flock)) {
+	spin_lock(&inode->i_lock);
+	if (!list_empty(&flctx->flc_posix)) {
+		fl = list_first_entry(&flctx->flc_posix, struct file_lock,
+					fl_list);
+		if (is_whole_file_wrlock(fl))
+			ret = 1;
+	} else if (!list_empty(&flctx->flc_flock)) {
 		fl = list_first_entry(&flctx->flc_flock, struct file_lock,
 					fl_list);
 		if (fl->fl_type == F_WRLCK)
 			ret = 1;
 	}
-out:
 	spin_unlock(&inode->i_lock);
 	return ret;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c06a1ba80d73..fad821991369 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5556,10 +5556,11 @@ out_nfserr:
 static bool
 check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 {
-	struct file_lock **flpp;
+	struct file_lock *fl;
 	int status = false;
 	struct file *filp = find_any_file(fp);
 	struct inode *inode;
+	struct file_lock_context *flctx;
 
 	if (!filp) {
 		/* Any valid lock stateid should have some sort of access */
@@ -5568,15 +5569,18 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 	}
 
 	inode = file_inode(filp);
+	flctx = inode->i_flctx;
 
-	spin_lock(&inode->i_lock);
-	for (flpp = &inode->i_flock; *flpp != NULL; flpp = &(*flpp)->fl_next) {
-		if ((*flpp)->fl_owner == (fl_owner_t)lowner) {
-			status = true;
-			break;
+	if (flctx && !list_empty_careful(&flctx->flc_posix)) {
+		spin_lock(&inode->i_lock);
+		list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
+			if (fl->fl_owner == (fl_owner_t)lowner) {
+				status = true;
+				break;
+			}
 		}
+		spin_unlock(&inode->i_lock);
 	}
-	spin_unlock(&inode->i_lock);
 	fput(filp);
 	return status;
 }
diff --git a/fs/read_write.c b/fs/read_write.c
index c0805c93b6fa..4060691e78f7 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -358,7 +358,7 @@ int rw_verify_area(int read_write, struct file *file, const loff_t *ppos, size_t
 			return retval;
 	}
 
-	if (unlikely(inode->i_flock && mandatory_lock(inode))) {
+	if (unlikely(inode->i_flctx && mandatory_lock(inode))) {
 		retval = locks_mandatory_area(
 			read_write == READ ? FLOCK_VERIFY_READ : FLOCK_VERIFY_WRITE,
 			inode, file, pos, count);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dec0d38b05de..571f113588e9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -968,6 +968,7 @@ struct file_lock {
 
 struct file_lock_context {
 	struct list_head	flc_flock;
+	struct list_head	flc_posix;
 };
 
 /* The following constant reflects the upper bound of the file/locking space */
@@ -1971,7 +1972,7 @@ static inline int locks_verify_truncate(struct inode *inode,
 				    struct file *filp,
 				    loff_t size)
 {
-	if (inode->i_flock && mandatory_lock(inode))
+	if (inode->i_flctx && mandatory_lock(inode))
 		return locks_mandatory_area(
 			FLOCK_VERIFY_WRITE, inode, filp,
 			size < inode->i_size ? size : inode->i_size,
-- 
2.1.0

