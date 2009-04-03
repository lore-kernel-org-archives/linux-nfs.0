From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 23/35] nfsd41: stateid handling
Date: Fri,  3 Apr 2009 08:28:45 +0300
Message-ID: <1238736525-17798-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26230 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756200AbZDCF2u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:50 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
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
[nfsd41: pass nfsd4_compoundres * to nfsd4_process_open1]
[nfsd41: calculate HAS_SESSION in nfs4_preprocess_stateid_op]
[nfsd41: calculate HAS_SESSION in nfs4_preprocess_seqid_op]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |    5 +++-
 fs/nfsd/nfs4state.c        |   47 ++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c          |    2 +-
 include/linux/nfsd/state.h |    1 +
 include/linux/nfsd/xdr4.h  |    8 ++++++-
 5 files changed, 52 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e6a0f31..aeb4888 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -168,6 +168,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_open *open)
 {
 	__be32 status;
+	struct nfsd4_compoundres *resp;
+
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_stateowner);
@@ -179,7 +181,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	/* check seqid for replay. set nfs4_owner */
-	status = nfsd4_process_open1(open);
+	resp = rqstp->rq_resp;
+	status = nfsd4_process_open1(&resp->cstate, open);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_stateowner->so_replay;
 		fh_put(&cstate->current_fh);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f49f305..bbaf3c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2183,7 +2183,8 @@ static struct lock_manager_operations nfsd_lease_mng_ops = {
 
 
 __be32
-nfsd4_process_open1(struct nfsd4_open *open)
+nfsd4_process_open1(struct nfsd4_compound_state *cstate,
+		    struct nfsd4_open *open)
 {
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
@@ -2206,6 +2207,9 @@ nfsd4_process_open1(struct nfsd4_open *open)
 			return nfserr_expired;
 		goto renew;
 	}
+	/* When sessions are used, skip open sequenceid processing */
+	if (nfsd4_has_session(cstate))
+		goto renew;
 	if (!sop->so_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = sop->so_client;
@@ -2483,6 +2487,7 @@ out:
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_stateid *stp = NULL;
@@ -2541,9 +2546,14 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
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
@@ -2564,7 +2574,8 @@ out:
 	* To finish the open response, we just need to set the rflags.
 	*/
 	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
-	if (!open->op_stateowner->so_confirmed)
+	if (!open->op_stateowner->so_confirmed &&
+	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
 	return status;
@@ -2781,8 +2792,15 @@ grace_disallows_io(struct inode *inode)
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
@@ -2798,6 +2816,7 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref)
 	 */
 	if (in->si_generation < ref->si_generation)
 		return nfserr_old_stateid;
+out:
 	return nfs_ok;
 }
 
@@ -2825,6 +2844,9 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
+
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
@@ -2837,7 +2859,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
 			goto out;
-		status = check_stateid_generation(stateid, &dp->dl_stateid);
+		status = check_stateid_generation(stateid, &dp->dl_stateid,
+						  flags);
 		if (status)
 			goto out;
 		status = nfs4_check_delegmode(dp, flags);
@@ -2854,7 +2877,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
-		status = check_stateid_generation(stateid, &stp->st_stateid);
+		status = check_stateid_generation(stateid, &stp->st_stateid,
+						  flags);
 		if (status)
 			goto out;
 		status = nfs4_check_openmode(stp, flags);
@@ -2905,6 +2929,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 
 	if (STALE_STATEID(stateid))
 		return nfserr_stale_stateid;
+
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
+
 	/*
 	* We return BAD_STATEID if filehandle doesn't match stateid, 
 	* the confirmed flag is incorrecly set, or the generation 
@@ -2961,7 +2989,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	*  For the moment, we ignore the possibility of 
 	*  generation number wraparound.
 	*/
-	if (seqid != sop->so_seqid)
+	if (!(flags & HAS_SESSION) && seqid != sop->so_seqid)
 		goto check_replay;
 
 	if (sop->so_confirmed && flags & CONFIRM) {
@@ -2974,7 +3002,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
 	}
-	status = check_stateid_generation(stateid, &stp->st_stateid);
+	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
 	if (status)
 		return status;
 	renew_client(sop->so_client);
@@ -3169,11 +3197,14 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -3187,7 +3218,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = find_delegation_stateid(inode, stateid);
 	if (!dp)
 		goto out;
-	status = check_stateid_generation(stateid, &dp->dl_stateid);
+	status = check_stateid_generation(stateid, &dp->dl_stateid, flags);
 	if (status)
 		goto out;
 	renew_client(dp->dl_client);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6a726d..dd81ac1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3194,7 +3194,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (resp->cstate.slot != NULL) {
+	if (nfsd4_has_session(&resp->cstate)) {
 		if (resp->cstate.status == nfserr_replay_cache &&
 				!nfsd4_not_cached(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 836c0d6..4d61c87 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -320,6 +320,7 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
+#define HAS_SESSION             0x00000001
 #define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index a0a2e83..b8b3dcb 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -56,6 +56,11 @@ struct nfsd4_compound_state {
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
@@ -536,7 +541,8 @@ extern __be32 nfsd4_sequence(struct svc_rqst *,
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
-extern __be32 nfsd4_process_open1(struct nfsd4_open *open);
+extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
+		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
-- 
1.6.2.1

