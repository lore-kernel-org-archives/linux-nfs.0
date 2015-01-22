Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.231]:16302 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753069AbbAVO2D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:28:03 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 05/13] locks: move flock locks to file_lock_context
Date: Thu, 22 Jan 2015 09:27:49 -0500
Message-Id: <1421936877-27529-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/locks.c     | 23 ++++++++++++++++-------
 fs/locks.c          | 54 ++++++++++++++++++++++++++++++++++-------------------
 fs/nfs/delegation.c | 19 +++++++++++++++++--
 fs/nfs/nfs4state.c  | 42 +++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pagelist.c   |  6 ++++++
 fs/nfs/write.c      | 43 +++++++++++++++++++++++++++++++++++++-----
 6 files changed, 152 insertions(+), 35 deletions(-)

diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index 366dc2412605..917656ea8dcf 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -239,14 +239,16 @@ int ceph_flock(struct file *file, int cmd, struct file_lock *fl)
 	return err;
 }
 
-/**
- * Must be called with lock_flocks() already held. Fills in the passed
- * counter variables, so you can prepare pagelist metadata before calling
- * ceph_encode_locks.
+/*
+ * Fills in the passed counter variables, so you can prepare pagelist metadata
+ * before calling ceph_encode_locks.
+ *
+ * FIXME: add counters to struct file_lock_context so we don't need to do this?
  */
 void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 {
 	struct file_lock *lock;
+	struct file_lock_context *ctx;
 
 	*fcntl_count = 0;
 	*flock_count = 0;
@@ -255,7 +257,11 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
 		if (lock->fl_flags & FL_POSIX)
 			++(*fcntl_count);
-		else if (lock->fl_flags & FL_FLOCK)
+	}
+
+	ctx = inode->i_flctx;
+	if (ctx) {
+		list_for_each_entry(lock, &ctx->flc_flock, fl_list)
 			++(*flock_count);
 	}
 	spin_unlock(&inode->i_lock);
@@ -273,6 +279,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 				int num_fcntl_locks, int num_flock_locks)
 {
 	struct file_lock *lock;
+	struct file_lock_context *ctx;
 	int err = 0;
 	int seen_fcntl = 0;
 	int seen_flock = 0;
@@ -295,8 +302,10 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 			++l;
 		}
 	}
-	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
-		if (lock->fl_flags & FL_FLOCK) {
+
+	ctx = inode->i_flctx;
+	if (ctx) {
+		list_for_each_entry(lock, &ctx->flc_flock, fl_list) {
 			++seen_flock;
 			if (seen_flock > num_flock_locks) {
 				err = -ENOSPC;
diff --git a/fs/locks.c b/fs/locks.c
index 526d5fca67c8..055df53f19de 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -694,6 +694,14 @@ static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 	locks_insert_global_locks(fl);
 }
 
+static void
+locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
+{
+	fl->fl_nspid = get_pid(task_tgid(current));
+	list_add_tail(&fl->fl_list, before);
+	locks_insert_global_locks(fl);
+}
+
 /**
  * locks_delete_lock - Delete a lock and then free it.
  * @thisfl_p: pointer that points to the fl_next field of the previous
@@ -739,6 +747,18 @@ static void locks_delete_lock(struct file_lock **thisfl_p,
 		locks_free_lock(fl);
 }
 
+static void
+locks_delete_lock_ctx(struct file_lock *fl, struct list_head *dispose)
+{
+	locks_delete_global_locks(fl);
+	if (fl->fl_nspid) {
+		put_pid(fl->fl_nspid);
+		fl->fl_nspid = NULL;
+	}
+	locks_wake_up_blocks(fl);
+	list_move(&fl->fl_list, dispose);
+}
+
 /* Determine if lock sys_fl blocks lock caller_fl. Common functionality
  * checks for shared/exclusive status of overlapping locks.
  */
@@ -888,12 +908,17 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
 static int flock_lock_file(struct file *filp, struct file_lock *request)
 {
 	struct file_lock *new_fl = NULL;
-	struct file_lock **before;
-	struct inode * inode = file_inode(filp);
+	struct file_lock *fl;
+	struct file_lock_context *ctx;
+	struct inode *inode = file_inode(filp);
 	int error = 0;
-	int found = 0;
+	bool found = false;
 	LIST_HEAD(dispose);
 
+	ctx = locks_get_lock_context(inode);
+	if (!ctx)
+		return -ENOMEM;
+
 	if (!(request->fl_flags & FL_ACCESS) && (request->fl_type != F_UNLCK)) {
 		new_fl = locks_alloc_lock();
 		if (!new_fl)
@@ -904,18 +929,13 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 	if (request->fl_flags & FL_ACCESS)
 		goto find_conflict;
 
-	for_each_lock(inode, before) {
-		struct file_lock *fl = *before;
-		if (IS_POSIX(fl))
-			break;
-		if (IS_LEASE(fl))
-			continue;
+	list_for_each_entry(fl, &ctx->flc_flock, fl_list) {
 		if (filp != fl->fl_file)
 			continue;
 		if (request->fl_type == fl->fl_type)
 			goto out;
-		found = 1;
-		locks_delete_lock(before, &dispose);
+		found = true;
+		locks_delete_lock_ctx(fl, &dispose);
 		break;
 	}
 
@@ -936,12 +956,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 	}
 
 find_conflict:
-	for_each_lock(inode, before) {
-		struct file_lock *fl = *before;
-		if (IS_POSIX(fl))
-			break;
-		if (IS_LEASE(fl))
-			continue;
+	list_for_each_entry(fl, &ctx->flc_flock, fl_list) {
 		if (!flock_locks_conflict(request, fl))
 			continue;
 		error = -EAGAIN;
@@ -954,7 +969,7 @@ find_conflict:
 	if (request->fl_flags & FL_ACCESS)
 		goto out;
 	locks_copy_lock(new_fl, request);
-	locks_insert_lock(before, new_fl);
+	locks_insert_lock_ctx(new_fl, &ctx->flc_flock);
 	new_fl = NULL;
 	error = 0;
 
@@ -2412,8 +2427,9 @@ locks_remove_flock(struct file *filp)
 		.fl_type = F_UNLCK,
 		.fl_end = OFFSET_MAX,
 	};
+	struct file_lock_context *flctx = file_inode(filp)->i_flctx;
 
-	if (!file_inode(filp)->i_flock)
+	if (!flctx || list_empty(&flctx->flc_flock))
 		return;
 
 	if (filp->f_op->flock)
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7f3f60641344..9f9f67b17e2b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -85,15 +85,16 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
+	struct file_lock_context *flctx;
 	int status = 0;
 
-	if (inode->i_flock == NULL)
+	if (inode->i_flock == NULL && inode->i_flctx == NULL)
 		goto out;
 
 	/* Protect inode->i_flock using the i_lock */
 	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
+		if (!(fl->fl_flags & (FL_POSIX)))
 			continue;
 		if (nfs_file_open_context(fl->fl_file) != ctx)
 			continue;
@@ -103,6 +104,20 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 			goto out;
 		spin_lock(&inode->i_lock);
 	}
+
+	flctx = inode->i_flctx;
+	if (flctx) {
+		list_for_each_entry(fl, &flctx->flc_flock, fl_list) {
+			if (nfs_file_open_context(fl->fl_file) != ctx)
+				continue;
+			spin_unlock(&inode->i_lock);
+			status = nfs4_lock_delegation_recall(fl, state,
+								stateid);
+			if (status < 0)
+				goto out;
+			spin_lock(&inode->i_lock);
+		}
+	}
 	spin_unlock(&inode->i_lock);
 out:
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5194933ed419..65c404bf61ae 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1366,8 +1366,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct file_lock *fl;
 	int status = 0;
+	struct file_lock_context *flctx = inode->i_flctx;
 
-	if (inode->i_flock == NULL)
+	if (inode->i_flock == NULL && flctx == NULL)
 		return 0;
 
 	/* Guard against delegation returns and new lock/unlock calls */
@@ -1375,7 +1376,7 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	/* Protect inode->i_flock using the BKL */
 	spin_lock(&inode->i_lock);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
+		if (!(fl->fl_flags & FL_POSIX))
 			continue;
 		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
@@ -1408,6 +1409,43 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 		}
 		spin_lock(&inode->i_lock);
 	}
+
+	if (!flctx)
+		goto out_unlock;
+
+	list_for_each_entry(fl, &flctx->flc_flock, fl_list) {
+		if (nfs_file_open_context(fl->fl_file)->state != state)
+			continue;
+		spin_unlock(&inode->i_lock);
+		status = ops->recover_lock(state, fl);
+		switch (status) {
+		case 0:
+			break;
+		case -ESTALE:
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_STALE_STATEID:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_NO_GRACE:
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+			goto out;
+		default:
+			pr_err("NFS: %s: unhandled error %d\n",
+					__func__, status);
+		case -ENOMEM:
+		case -NFS4ERR_DENIED:
+		case -NFS4ERR_RECLAIM_BAD:
+		case -NFS4ERR_RECLAIM_CONFLICT:
+			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
+			status = 0;
+		}
+		spin_lock(&inode->i_lock);
+	}
+out_unlock:
 	spin_unlock(&inode->i_lock);
 out:
 	up_write(&nfsi->rwsem);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2b5e769beb16..a3b62e15b444 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -826,6 +826,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 				      struct nfs_pageio_descriptor *pgio)
 {
 	size_t size;
+	struct file_lock_context *flctx;
 
 	if (prev) {
 		if (!nfs_match_open_context(req->wb_context, prev->wb_context))
@@ -834,6 +835,11 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		    !nfs_match_lock_context(req->wb_lock_context,
 					    prev->wb_lock_context))
 			return false;
+		flctx = req->wb_context->dentry->d_inode->i_flctx;
+		if (flctx != NULL && !list_empty_careful(&flctx->flc_flock) &&
+		    !nfs_match_lock_context(req->wb_lock_context,
+					    prev->wb_lock_context))
+			return false;
 		if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 			return false;
 		if (req->wb_page == prev->wb_page) {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af3af685a9e3..e072aeb34195 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1113,6 +1113,11 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 			do_flush |= l_ctx->lockowner.l_owner != current->files
 				|| l_ctx->lockowner.l_pid != current->tgid;
 		}
+		if (l_ctx && ctx->dentry->d_inode->i_flctx &&
+		    !list_empty_careful(&ctx->dentry->d_inode->i_flctx->flc_flock)) {
+			do_flush |= l_ctx->lockowner.l_owner != current->files
+				|| l_ctx->lockowner.l_pid != current->tgid;
+		}
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
@@ -1170,6 +1175,13 @@ out:
 	return PageUptodate(page) != 0;
 }
 
+static bool
+is_whole_file_wrlock(struct file_lock *fl)
+{
+	return fl->fl_start == 0 && fl->fl_end == OFFSET_MAX &&
+			fl->fl_type == F_WRLCK;
+}
+
 /* If we know the page is up to date, and we're not using byte range locks (or
  * if we have the whole file locked for writing), it may be more efficient to
  * extend the write to cover the entire page in order to avoid fragmentation
@@ -1180,17 +1192,38 @@ out:
  */
 static int nfs_can_extend_write(struct file *file, struct page *page, struct inode *inode)
 {
+	int ret;
+	struct file_lock_context *flctx = inode->i_flctx;
+	struct file_lock *fl;
+
 	if (file->f_flags & O_DSYNC)
 		return 0;
 	if (!nfs_write_pageuptodate(page, inode))
 		return 0;
 	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
 		return 1;
-	if (inode->i_flock == NULL || (inode->i_flock->fl_start == 0 &&
-			inode->i_flock->fl_end == OFFSET_MAX &&
-			inode->i_flock->fl_type != F_RDLCK))
-		return 1;
-	return 0;
+	if (!inode->i_flock && !flctx)
+		return 0;
+
+	/* Check to see if there are whole file write locks */
+	spin_lock(&inode->i_lock);
+	ret = 0;
+
+	fl = inode->i_flock;
+	if (fl && is_whole_file_wrlock(fl)) {
+		ret = 1;
+		goto out;
+	}
+
+	if (!list_empty(&flctx->flc_flock)) {
+		fl = list_first_entry(&flctx->flc_flock, struct file_lock,
+					fl_list);
+		if (fl->fl_type == F_WRLCK)
+			ret = 1;
+	}
+out:
+	spin_unlock(&inode->i_lock);
+	return ret;
 }
 
 /*
-- 
2.1.0

