From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 27/47] nfsd41: stateid handling
Date: Sat, 28 Mar 2009 11:33:31 +0300
Message-ID: <1238229211-11111-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:18369 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756260AbZC1Idk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:33:40 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When sessions are used, stateful operation sequenceid and stateid handling
are not used. When sessions are used,  on the first open set the seqid to 1,
mark state confirmed and skip seqid processing.

When sessionas are used the stateid generation number is ignored when it is zero
whereas without sessions bad_stateid or stale stateid is returned.

Add flags to propagate session use to all stateful ops and down to
check_stateid_generation.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfsd4_has_session should return a boolean, not u32]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |   17 ++++++++--
 fs/nfsd/nfs4state.c        |   70 ++++++++++++++++++++++++++++++++++---------
 fs/nfsd/nfs4xdr.c          |    2 +-
 include/linux/nfsd/state.h |    1 +
 include/linux/nfsd/xdr4.h  |    8 ++++-
 5 files changed, 77 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a273023..1d4b2b5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -179,7 +179,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	/* check seqid for replay. set nfs4_owner */
-	status = nfsd4_process_open1(open);
+	status = nfsd4_process_open1(rqstp, open);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_stateowner->so_replay;
 		fh_put(&cstate->current_fh);
@@ -504,6 +504,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_read *read)
 {
 	__be32 status;
+	int flags = RD_STATE;
 
 	/* no need to check permission - this will be done in nfsd_read() */
 
@@ -511,11 +512,13 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(&cstate->current_fh,
 				&read->rd_stateid,
-				RD_STATE, &read->rd_filp))) {
+				flags, &read->rd_filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -643,11 +646,14 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_setattr *setattr)
 {
 	__be32 status = nfs_ok;
+	int flags = WR_STATE;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
 		status = nfs4_preprocess_stateid_op(&cstate->current_fh,
-			&setattr->sa_stateid, WR_STATE, NULL);
+			&setattr->sa_stateid, flags, NULL);
 		nfs4_unlock_state();
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
@@ -679,15 +685,18 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	u32 *p;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
+	int flags = WR_STATE;
 
 	/* no need to check permission - this will be done in nfsd_write() */
 
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	status = nfs4_preprocess_stateid_op(&cstate->current_fh, stateid,
-					WR_STATE, &filp);
+					    flags, &filp);
 	if (filp)
 		get_file(filp);
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c93f96..bf5b214 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2199,12 +2199,13 @@ static struct lock_manager_operations nfsd_lease_mng_ops = {
 
 
 __be32
-nfsd4_process_open1(struct nfsd4_open *open)
+nfsd4_process_open1(struct svc_rqst *rqstp, struct nfsd4_open *open)
 {
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_stateowner *sop = NULL;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 
 	if (!check_name(open->op_owner))
 		return nfserr_inval;
@@ -2222,6 +2223,9 @@ nfsd4_process_open1(struct nfsd4_open *open)
 			return nfserr_expired;
 		goto renew;
 	}
+	/* When sessions are used, skip open sequenceid processing */
+	if (nfsd4_has_session(&resp->cstate))
+		goto renew;
 	if (!sop->so_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = sop->so_client;
@@ -2499,6 +2503,7 @@ out:
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_stateid *stp = NULL;
@@ -2557,9 +2562,14 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			release_open_stateid(stp);
 			goto out;
 		}
+		if (nfsd4_has_session(&resp->cstate))
+			update_stateid(&stp->st_stateid);
 	}
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
+	if (nfsd4_has_session(&resp->cstate))
+		open->op_stateowner->so_confirmed = 1;
+
 	/*
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
@@ -2580,7 +2590,8 @@ out:
 	* To finish the open response, we just need to set the rflags.
 	*/
 	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
-	if (!open->op_stateowner->so_confirmed)
+	if (!open->op_stateowner->so_confirmed &&
+	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
 	return status;
@@ -2797,8 +2808,15 @@ grace_disallows_io(struct inode *inode)
 	return locks_in_grace() && mandatory_lock(inode);
 }
 
-static int check_stateid_generation(stateid_t *in, stateid_t *ref)
+static int check_stateid_generation(stateid_t *in, stateid_t *ref, int flags)
 {
+	/*
+	 * When sessions are used the stateid generation number is ignored
+	 * when it is zero.
+	 */
+	if ((flags & HAS_SESSION) && in->si_generation == 0)
+		goto out;
+
 	/* If the client sends us a stateid from the future, it's buggy: */
 	if (in->si_generation > ref->si_generation)
 		return nfserr_bad_stateid;
@@ -2814,6 +2832,7 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref)
 	 */
 	if (in->si_generation < ref->si_generation)
 		return nfserr_old_stateid;
+out:
 	return nfs_ok;
 }
 
@@ -2851,7 +2870,8 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
 			goto out;
-		status = check_stateid_generation(stateid, &dp->dl_stateid);
+		status = check_stateid_generation(stateid, &dp->dl_stateid,
+						  flags);
 		if (status)
 			goto out;
 		status = nfs4_check_delegmode(dp, flags);
@@ -2868,7 +2888,8 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
-		status = check_stateid_generation(stateid, &stp->st_stateid);
+		status = check_stateid_generation(stateid, &stp->st_stateid,
+						  flags);
 		if (status)
 			goto out;
 		status = nfs4_check_openmode(stp, flags);
@@ -2971,7 +2992,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 	*  For the moment, we ignore the possibility of 
 	*  generation number wraparound.
 	*/
-	if (seqid != sop->so_seqid)
+	if (!(flags & HAS_SESSION) && seqid != sop->so_seqid)
 		goto check_replay;
 
 	if (sop->so_confirmed && flags & CONFIRM) {
@@ -2984,7 +3005,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
 	}
-	status = check_stateid_generation(stateid, &stp->st_stateid);
+	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
 	if (status)
 		return status;
 	renew_client(sop->so_client);
@@ -3080,6 +3101,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	__be32 status;
 	struct nfs4_stateid *stp;
 	unsigned int share_access;
+	int flags = OPEN_STATE;
 
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3089,11 +3111,13 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			|| !deny_valid(od->od_share_deny))
 		return nfserr_inval;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
 					od->od_seqid,
 					&od->od_stateid, 
-					OPEN_STATE,
+					flags,
 					&od->od_stateowner, &stp, NULL)))
 		goto out; 
 
@@ -3136,17 +3160,20 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfs4_stateid *stp;
+	int flags = OPEN_STATE | CLOSE_STATE;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	/* check close_lru for replay */
 	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
 					close->cl_seqid,
 					&close->cl_stateid, 
-					OPEN_STATE | CLOSE_STATE,
+					flags,
 					&close->cl_stateowner, &stp, NULL)))
 		goto out; 
 	status = nfs_ok;
@@ -3179,11 +3206,14 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &dr->dr_stateid;
 	struct inode *inode;
 	__be32 status;
+	int flags = 0;
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
 	inode = cstate->current_fh.fh_dentry->d_inode;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	status = nfserr_bad_stateid;
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
@@ -3197,7 +3227,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = find_delegation_stateid(inode, stateid);
 	if (!dp)
 		goto out;
-	status = check_stateid_generation(stateid, &dp->dl_stateid);
+	status = check_stateid_generation(stateid, &dp->dl_stateid, flags);
 	if (status)
 		goto out;
 	renew_client(dp->dl_client);
@@ -3459,7 +3489,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = 0;
 	unsigned int strhashval;
 	unsigned int cmd;
-	int err;
+	int err, flags = 0;
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
 		(long long) lock->lk_offset,
@@ -3489,11 +3519,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (STALE_CLIENTID(&lock->lk_new_clientid))
 			goto out;
 
+		flags = OPEN_STATE;
+		if (nfsd4_has_session(cstate))
+			flags |= HAS_SESSION;
+
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(&cstate->current_fh,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
-					OPEN_STATE,
+					flags,
 		                        &lock->lk_replay_owner, &open_stp,
 					lock);
 		if (status)
@@ -3516,11 +3550,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (lock_stp == NULL)
 			goto out;
 	} else {
+		flags = LOCK_STATE;
+		if (nfsd4_has_session(cstate))
+			flags |= HAS_SESSION;
+
 		/* lock (lock owner + lock stateid) already exists */
 		status = nfs4_preprocess_seqid_op(&cstate->current_fh,
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
-				       LOCK_STATE,
+				       flags,
 				       &lock->lk_replay_owner, &lock_stp, lock);
 		if (status)
 			goto out;
@@ -3702,7 +3740,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file *filp = NULL;
 	struct file_lock file_lock;
 	__be32 status;
-	int err;
+	int err, flags = LOCK_STATE;
 						        
 	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
 		(long long) locku->lu_offset,
@@ -3711,12 +3749,14 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
 	nfs4_lock_state();
 									        
 	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
 					locku->lu_seqid, 
 					&locku->lu_stateid, 
-					LOCK_STATE,
+					flags,
 					&locku->lu_stateowner, &stp, NULL)))
 		goto out;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5720aab..a2682e8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3206,7 +3206,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 #ifdef CONFIG_NFSD_V4_1
-	if (resp->cstate.slot != NULL) {
+	if (nfsd4_has_session(&resp->cstate)) {
 		if (resp->cstate.status == nfserr_replay_cache &&
 				!nfsd4_no_page_in_cache(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 47c7836..302557d 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -323,6 +323,7 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
+#define HAS_SESSION             0x00000001
 #define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 37a7c51..aafbfdc 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -55,6 +55,11 @@ struct nfsd4_compound_state {
 	u32			status;
 };
 
+static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
+{
+	return cs->slot != NULL;
+}
+
 struct nfsd4_change_info {
 	u32		atomic;
 	u32		before_ctime_sec;
@@ -540,7 +545,8 @@ extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
 #endif /* CONFIG_NFSD_V4_1 */
-extern __be32 nfsd4_process_open1(struct nfsd4_open *open);
+extern __be32 nfsd4_process_open1(struct svc_rqst *rqstp,
+		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
-- 
1.6.2.1

