Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60177 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240Ab1INLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 15/25] nfsd4: split preprocess_seqid, cleanup
Date: Wed, 14 Sep 2011 07:45:11 -0400
Message-Id: <1316000721-3289-16-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move most of this into helper functions.  Also move the non-CONFIRM case
into caller, providing a helper function for that purpose.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   87 ++++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |    1 -
 2 files changed, 45 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa088bc..ad20bbf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3253,7 +3253,6 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 	if (!stp)
 		goto out;
 	status = nfserr_bad_stateid;
-
 	if (stp->st_stateowner->so_is_open_owner
 	    && !openowner(stp->st_stateowner)->oo_confirmed)
 		goto out;
@@ -3418,6 +3417,29 @@ setlkflg (int type)
 		RD_STATE : WR_STATE;
 }
 
+static __be32 nfs4_nospecial_stateid_checks(stateid_t *stateid)
+{
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+		return nfserr_bad_stateid;
+	if (STALE_STATEID(stateid))
+		return nfserr_stale_stateid;
+	return nfs_ok;
+}
+
+static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_t *stateid, u32 seqid, struct nfs4_stateid *stp)
+{
+	struct svc_fh *current_fh = &cstate->current_fh;
+	struct nfs4_stateowner *sop = stp->st_stateowner;
+	__be32 status;
+
+	if (nfs4_check_fh(current_fh, stp))
+		return nfserr_bad_stateid;
+	status = nfsd4_check_seqid(cstate, sop, seqid);
+	if (status)
+		return status;
+	return check_stateid_generation(stateid, &stp->st_stateid, nfsd4_has_session(cstate));
+}
+
 /* 
  * Checks for sequence id mutating operations. 
  */
@@ -3426,54 +3448,36 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, int flags,
 			 struct nfs4_stateid **stpp)
 {
-	struct nfs4_stateowner *sop;
-	struct svc_fh *current_fh = &cstate->current_fh;
 	__be32 status;
 
 	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
-		dprintk("NFSD: preprocess_seqid_op: magic stateid!\n");
-		return nfserr_bad_stateid;
-	}
-
-	if (STALE_STATEID(stateid))
-		return nfserr_stale_stateid;
-
-	/*
-	* We return BAD_STATEID if filehandle doesn't match stateid, 
-	* the confirmed flag is incorrecly set, or the generation 
-	* number is incorrect.  
-	*/
+	status = nfs4_nospecial_stateid_checks(stateid);
+	if (status)
+		return status;
 	*stpp = find_stateid_by_type(stateid, flags);
 	if (*stpp == NULL)
 		return nfserr_expired;
+	cstate->replay_owner = (*stpp)->st_stateowner;
+	renew_client((*stpp)->st_stateowner->so_client);
 
-	sop = (*stpp)->st_stateowner;
-	cstate->replay_owner = sop;
+	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
+}
 
-	if (nfs4_check_fh(current_fh, *stpp)) {
-		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
-		return nfserr_bad_stateid;
-	}
+static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid, stateid_t *stateid, struct nfs4_stateid **stpp)
+{
+	__be32 status;
+	struct nfs4_openowner *oo;
 
-	status = nfsd4_check_seqid(cstate, sop, seqid);
+	status = nfs4_preprocess_seqid_op(cstate, seqid, stateid,
+						OPEN_STATE, stpp);
 	if (status)
 		return status;
-
-	if (sop->so_is_open_owner && !openowner(sop)->oo_confirmed
-			&& !(flags & CONFIRM)) {
-		dprintk("NFSD: preprocess_seqid_op: stateowner not"
-				" confirmed yet!\n");
+	oo = openowner((*stpp)->st_stateowner);
+	if (!oo->oo_confirmed)
 		return nfserr_bad_stateid;
-	}
-	status = check_stateid_generation(stateid, &(*stpp)->st_stateid, nfsd4_has_session(cstate));
-	if (status)
-		return status;
-	renew_client(sop->so_client);
 	return nfs_ok;
 }
 
@@ -3497,7 +3501,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
-					CONFIRM | OPEN_STATE, &stp);
+					OPEN_STATE, &stp);
 	if (status)
 		goto out;
 	oo = openowner(stp->st_stateowner);
@@ -3557,8 +3561,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	status = nfs4_preprocess_seqid_op(cstate, od->od_seqid,
-					&od->od_stateid, OPEN_STATE, &stp);
+	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
+					&od->od_stateid, &stp);
 	if (status)
 		goto out; 
 	status = nfserr_inval;
@@ -3602,9 +3606,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 	/* check close_lru for replay */
-	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
-					&close->cl_stateid, 
-					OPEN_STATE, &stp);
+	status = nfs4_preprocess_confirmed_seqid_op(cstate, close->cl_seqid,
+					&close->cl_stateid, &stp);
 	if (stp == NULL && status == nfserr_expired) {
 		/*
 		 * Also, we should make sure this isn't just the result of
@@ -3963,10 +3966,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 
 		/* validate and update open stateid and open seqid */
-		status = nfs4_preprocess_seqid_op(cstate,
+		status = nfs4_preprocess_confirmed_seqid_op(cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
-					OPEN_STATE, &open_stp);
+					&open_stp);
 		if (status)
 			goto out;
 		open_sop = openowner(open_stp->st_stateowner);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7994ed9..9745cc7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -463,7 +463,6 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
-#define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
 #define RD_STATE	        0x00000010
-- 
1.7.4.1

