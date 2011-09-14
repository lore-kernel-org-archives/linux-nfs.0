Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60151 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/25] nfsd4: cleanup seqid op stateowner usage
Date: Wed, 14 Sep 2011 07:44:58 -0400
Message-Id: <1316000721-3289-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now that the replay owner is in the cstate we can remove it from a lot
of other individual operations and further simplify
nfs4_preprocess_seqid_op().

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   57 +++++++++++++++++++++-----------------------------
 fs/nfsd/nfs4xdr.c   |    5 ----
 fs/nfsd/xdr4.h      |    7 ------
 3 files changed, 24 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e4535ff..bc1a9db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3388,7 +3388,6 @@ setlkflg (int type)
 static __be32
 nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, int flags,
-			 struct nfs4_stateowner **sopp,
 			 struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *stp;
@@ -3400,7 +3399,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	*sopp = NULL;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
 		dprintk("NFSD: preprocess_seqid_op: magic stateid!\n");
@@ -3431,7 +3429,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	}
 
 	*stpp = stp;
-	*sopp = sop = stp->st_stateowner;
+	sop = stp->st_stateowner;
 	nfs4_get_stateowner(sop);
 	cstate->replay_owner = sop;
 
@@ -3467,7 +3465,6 @@ check_replay:
 	}
 	dprintk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d)\n",
 			sop->so_seqid, seqid);
-	*sopp = NULL;
 	return nfserr_bad_seqid;
 }
 
@@ -3489,13 +3486,13 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	if ((status = nfs4_preprocess_seqid_op(cstate,
+	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
-					CONFIRM | OPEN_STATE,
-					&oc->oc_stateowner, &stp)))
+					CONFIRM | OPEN_STATE, &stp);
+	if (status)
 		goto out; 
 
-	sop = oc->oc_stateowner;
+	sop = stp->st_stateowner;
 	sop->so_confirmed = 1;
 	update_stateid(&stp->st_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stateid, sizeof(stateid_t));
@@ -3547,11 +3544,9 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	if ((status = nfs4_preprocess_seqid_op(cstate,
-					od->od_seqid,
-					&od->od_stateid, 
-					OPEN_STATE,
-					&od->od_stateowner, &stp)))
+	status = nfs4_preprocess_seqid_op(cstate, od->od_seqid,
+					&od->od_stateid, OPEN_STATE, &stp);
+	if (status)
 		goto out; 
 
 	status = nfserr_inval;
@@ -3586,6 +3581,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfs4_stateid *stp;
+	struct nfs4_stateowner *so;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3593,12 +3589,12 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 	/* check close_lru for replay */
-	if ((status = nfs4_preprocess_seqid_op(cstate,
-					close->cl_seqid,
+	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid, 
-					OPEN_STATE | CLOSE_STATE,
-					&close->cl_stateowner, &stp)))
+					OPEN_STATE | CLOSE_STATE, &stp);
+	if (status)
 		goto out; 
+	so = stp->st_stateowner;
 	status = nfs_ok;
 	update_stateid(&stp->st_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
@@ -3610,8 +3606,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * released by the laundromat service after the lease period
 	 * to enable us to handle CLOSE replay
 	 */
-	if (list_empty(&close->cl_stateowner->so_stateids))
-		move_to_close_lru(close->cl_stateowner);
+	if (list_empty(&so->so_stateids))
+		move_to_close_lru(so);
 out:
 	nfs4_unlock_state();
 	return status;
@@ -3962,12 +3958,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_preprocess_seqid_op(cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
-					OPEN_STATE,
-		                        &lock->lk_replay_owner, &open_stp);
+					OPEN_STATE, &open_stp);
 		if (status)
 			goto out;
 		status = nfserr_bad_stateid;
-		open_sop = lock->lk_replay_owner;
+		open_sop = open_stp->st_stateowner;
 		if (!nfsd4_has_session(cstate) &&
 				!same_clid(&open_sop->so_client->cl_clientid,
 						&lock->v.new.clientid))
@@ -3993,14 +3988,13 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
-				       LOCK_STATE,
-				       &lock->lk_replay_owner, &lock_stp);
+				       LOCK_STATE, &lock_stp);
 		if (status)
 			goto out;
-		lock_sop = lock->lk_replay_owner;
+		lock_sop = lock_stp->st_stateowner;
 		fp = lock_stp->st_file;
 	}
-	/* lock->lk_replay_owner and lock_stp have been created or found */
+	/* lock_sop and lock_stp have been created or found */
 
 	lkflg = setlkflg(lock->lk_type);
 	status = nfs4_check_openmode(lock_stp, lkflg);
@@ -4191,13 +4185,10 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 									        
-	if ((status = nfs4_preprocess_seqid_op(cstate,
-					locku->lu_seqid, 
-					&locku->lu_stateid, 
-					LOCK_STATE,
-					&locku->lu_stateowner, &stp)))
+	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
+					&locku->lu_stateid, LOCK_STATE, &stp);
+	if (status)
 		goto out;
-
 	filp = find_any_file(stp->st_file);
 	if (!filp) {
 		status = nfserr_lock_range;
@@ -4206,7 +4197,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	BUG_ON(!filp);
 	locks_init_lock(&file_lock);
 	file_lock.fl_type = F_UNLCK;
-	file_lock.fl_owner = (fl_owner_t) locku->lu_stateowner;
+	file_lock.fl_owner = (fl_owner_t) stp->st_stateowner;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX; 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ee12678..462c6ef 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -456,7 +456,6 @@ nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 {
 	DECODE_HEAD;
 
-	close->cl_stateowner = NULL;
 	READ_BUF(4);
 	READ32(close->cl_seqid);
 	return nfsd4_decode_stateid(argp, &close->cl_stateid);
@@ -551,7 +550,6 @@ nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
 {
 	DECODE_HEAD;
 
-	lock->lk_replay_owner = NULL;
 	/*
 	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
 	*/
@@ -611,7 +609,6 @@ nfsd4_decode_locku(struct nfsd4_compoundargs *argp, struct nfsd4_locku *locku)
 {
 	DECODE_HEAD;
 
-	locku->lu_stateowner = NULL;
 	READ_BUF(8);
 	READ32(locku->lu_type);
 	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
@@ -739,7 +736,6 @@ nfsd4_decode_open_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_open_con
 {
 	DECODE_HEAD;
 		    
-	open_conf->oc_stateowner = NULL;
 	status = nfsd4_decode_stateid(argp, &open_conf->oc_req_stateid);
 	if (status)
 		return status;
@@ -754,7 +750,6 @@ nfsd4_decode_open_downgrade(struct nfsd4_compoundargs *argp, struct nfsd4_open_d
 {
 	DECODE_HEAD;
 		    
-	open_down->od_stateowner = NULL;
 	status = nfsd4_decode_stateid(argp, &open_down->od_stateid);
 	if (status)
 		return status;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 663193b..341f0a1 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -81,7 +81,6 @@ struct nfsd4_access {
 struct nfsd4_close {
 	u32		cl_seqid;           /* request */
 	stateid_t	cl_stateid;         /* request+response */
-	struct nfs4_stateowner * cl_stateowner;	/* response */
 };
 
 struct nfsd4_commit {
@@ -165,9 +164,6 @@ struct nfsd4_lock {
 		} ok;
 		struct nfsd4_lock_denied        denied;
 	} u;
-	/* The lk_replay_owner is the open owner in the open_to_lock_owner
-	 * case and the lock owner otherwise: */
-	struct nfs4_stateowner *lk_replay_owner;
 };
 #define lk_new_open_seqid       v.new.open_seqid
 #define lk_new_open_stateid     v.new.open_stateid
@@ -199,7 +195,6 @@ struct nfsd4_locku {
 	stateid_t       lu_stateid;
 	u64             lu_offset;
 	u64             lu_length;
-	struct nfs4_stateowner  *lu_stateowner;
 };
 
 
@@ -243,7 +238,6 @@ struct nfsd4_open_confirm {
 	stateid_t	oc_req_stateid		/* request */;
 	u32		oc_seqid    		/* request */;
 	stateid_t	oc_resp_stateid		/* response */;
-	struct nfs4_stateowner * oc_stateowner;	/* response */
 };
 
 struct nfsd4_open_downgrade {
@@ -251,7 +245,6 @@ struct nfsd4_open_downgrade {
 	u32             od_seqid;
 	u32             od_share_access;
 	u32             od_share_deny;
-	struct nfs4_stateowner *od_stateowner;
 };
 
 
-- 
1.7.4.1

