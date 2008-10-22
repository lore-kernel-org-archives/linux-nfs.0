From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/3] locks: really move grace checks into common code
Date: Wed, 22 Oct 2008 17:03:20 -0400
Message-ID: <1224709402-6976-2-git-send-email-bfields@citi.umich.edu>
References: <1224709402-6976-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbYJVVDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 17:03:24 -0400
In-Reply-To: <1224709402-6976-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to have a pointer to the filesystem in question when we do the
grace checks, to (after further patches) allow per-filesystem grace
periods.

The locking functions already take a filp with the information we need,
so it seems convenient to wrap them in functions that do these checks,
and it removes the need for some redundant code.

But there may always be a few other places where we need
locks_in_grace() checks, so we're probably not going to make everything
go through these wrappers.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/grace.c    |   30 ++++++++++++++++++++++++++++++
 fs/lockd/svc4proc.c |   24 ------------------------
 fs/lockd/svclock.c  |   27 ++++++++++++---------------
 fs/lockd/svcproc.c  |   24 ------------------------
 fs/lockd/svcshare.c |    7 +++++++
 fs/nfsd/nfs4state.c |   20 +++++++-------------
 fs/nfsd/nfsproc.c   |    1 +
 include/linux/fs.h  |    3 +++
 8 files changed, 60 insertions(+), 76 deletions(-)

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..773ffe0 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -57,3 +57,33 @@ int locks_in_grace(void)
 	return !list_empty(&grace_list);
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
+
+int vfs_lm_lock_file(struct file *filp, unsigned int cmd,
+		struct file_lock *fl, struct file_lock *conf, int reclaim)
+{
+	if (fl->fl_type == F_UNLCK)
+		goto skip_grace_checks;
+	if (locks_in_grace() && !reclaim)
+		return -EBUSY;
+	if (reclaim && !locks_in_grace())
+		return -EBUSY;
+skip_grace_checks:
+	return vfs_lock_file(filp, cmd, fl, conf);
+}
+EXPORT_SYMBOL(vfs_lm_lock_file);
+
+int vfs_lm_test_lock(struct file *filp, struct file_lock *fl)
+{
+	if (locks_in_grace())
+		return -EBUSY;
+	return vfs_test_lock(filp, fl);
+}
+EXPORT_SYMBOL(vfs_lm_test_lock);
+
+int vfs_lm_cancel_lock(struct file *filp, struct file_lock *fl)
+{
+	if (locks_in_grace())
+		return -EBUSY;
+	return vfs_cancel_lock(filp, fl);
+}
+EXPORT_SYMBOL(vfs_lm_cancel_lock);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 014f6ce..7dacc72 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -157,12 +157,6 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -190,12 +184,6 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -329,12 +317,6 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -362,12 +344,6 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 6063a8e..9539535 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -406,18 +406,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace() && !reclaim) {
-		ret = nlm_lck_denied_grace_period;
-		goto out;
-	}
-	if (reclaim && !locks_in_grace()) {
-		ret = nlm_lck_denied_grace_period;
-		goto out;
-	}
-
 	if (!wait)
 		lock->fl.fl_flags &= ~FL_SLEEP;
-	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl, NULL);
+	error = vfs_lm_lock_file(file->f_file, F_SETLK, &lock->fl, NULL,
+								reclaim);
 	lock->fl.fl_flags &= ~FL_SLEEP;
 
 	dprintk("lockd: vfs_lock_file returned %d\n", error);
@@ -425,6 +417,9 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		case 0:
 			ret = nlm_granted;
 			goto out;
+		case -EBUSY:
+			ret = nlm_lck_denied_grace_period;
+			goto out;
 		case -EAGAIN:
 			ret = nlm_lck_denied;
 			goto out;
@@ -511,15 +506,15 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace()) {
-		ret = nlm_lck_denied_grace_period;
-		goto out;
-	}
-	error = vfs_test_lock(file->f_file, &lock->fl);
+	error = vfs_lm_test_lock(file->f_file, &lock->fl);
 	if (error == FILE_LOCK_DEFERRED) {
 		ret = nlmsvc_defer_lock_rqst(rqstp, block);
 		goto out;
 	}
+	if (error == -EBUSY) {
+		ret = nlm_lck_denied_grace_period;
+		goto out;
+	}
 	if (error) {
 		ret = nlm_lck_denied_nolocks;
 		goto out;
@@ -566,6 +561,7 @@ nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
+	/* XXX: Do we need a grace check?? */
 	/* First, cancel any lock that might be there */
 	nlmsvc_cancel_blocked(file, lock);
 
@@ -595,6 +591,7 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
+	/* XXX: ? */
 	if (locks_in_grace())
 		return nlm_lck_denied_grace_period;
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 548b0bb..d42c0bf 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -187,12 +187,6 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -220,12 +214,6 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -361,12 +349,6 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -394,12 +376,6 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
index b0ae070..cbbc38d 100644
--- a/fs/lockd/svcshare.c
+++ b/fs/lockd/svcshare.c
@@ -31,6 +31,9 @@ nlmsvc_share_file(struct nlm_host *host, struct nlm_file *file,
 	struct xdr_netobj	*oh = &argp->lock.oh;
 	u8			*ohdata;
 
+	/* XXX: also check for converse */
+	if (locks_in_grace() && !argp->reclaim)
+		return nlm_lck_denied_grace_period;
 	for (share = file->f_shares; share; share = share->s_next) {
 		if (share->s_host == host && nlm_cmp_owner(share, oh))
 			goto update;
@@ -71,6 +74,10 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
 	struct nlm_share	*share, **shpp;
 	struct xdr_netobj	*oh = &argp->lock.oh;
 
+	/* XXX: Why not allow unshares during grace? */
+	if (locks_in_grace())
+		return nlm_lck_denied_grace_period;
+
 	for (shpp = &file->f_shares; (share = *shpp) != NULL;
 					shpp = &share->s_next) {
 		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0cc7ff5..7ef42f4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2694,13 +2694,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* lock->lk_replay_owner and lock_stp have been created or found */
 	filp = lock_stp->st_vfs_file;
 
-	status = nfserr_grace;
-	if (locks_in_grace() && !lock->lk_reclaim)
-		goto out;
-	status = nfserr_no_grace;
-	if (!locks_in_grace() && lock->lk_reclaim)
-		goto out;
-
 	locks_init_lock(&file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
@@ -2736,7 +2729,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	* Note: locks.c uses the BKL to protect the inode's lock list.
 	*/
 
-	err = vfs_lock_file(filp, cmd, &file_lock, &conflock);
+	err = vfs_lm_lock_file(filp, cmd, &file_lock, &conflock,
+					lock->lk_reclaim);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);
@@ -2744,6 +2738,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				sizeof(stateid_t));
 		status = 0;
 		break;
+	case EBUSY:
+		status = lock->lk_reclaim ? nfserr_no_grace : nfserr_grace;
+		break;
 	case (EAGAIN):		/* conflock holds conflicting lock */
 		status = nfserr_denied;
 		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
@@ -2781,9 +2778,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int error;
 	__be32 status;
 
-	if (locks_in_grace())
-		return nfserr_grace;
-
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
@@ -2843,7 +2837,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	file.f_path.dentry = cstate->current_fh.fh_dentry;
 
 	status = nfs_ok;
-	error = vfs_test_lock(&file, &file_lock);
+	error = vfs_lm_test_lock(&file, &file_lock);
 	if (error) {
 		status = nfserrno(error);
 		goto out;
@@ -2903,7 +2897,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/*
 	*  Try to unlock the file in the VFS.
 	*/
-	err = vfs_lock_file(filp, F_SETLK, &file_lock, NULL);
+	err = vfs_lm_lock_file(filp, F_SETLK, &file_lock, NULL, 0);
 	if (err) {
 		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 5cffeca..ade85f9 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -598,6 +598,7 @@ nfserrno (int errno)
 		{ nfserr_io, -EIO },
 		{ nfserr_nxio, -ENXIO },
 		{ nfserr_acces, -EACCES },
+		{ nfserr_grace, -EBUSY }, /* XXX ? */
 		{ nfserr_exist, -EEXIST },
 		{ nfserr_xdev, -EXDEV },
 		{ nfserr_mlink, -EMLINK },
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 27cfa72..2f05755 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1024,6 +1024,9 @@ extern int posix_unblock_lock(struct file *, struct file_lock *);
 extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
+extern int vfs_lm_test_lock(struct file *, struct file_lock *);
+extern int vfs_lm_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *, int reclaim);
+extern int vfs_lm_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
-- 
1.5.5.rc1

