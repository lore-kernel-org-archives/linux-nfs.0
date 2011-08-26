Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53260 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/15] nfsd4: centralize handling of replay owners
Date: Fri, 26 Aug 2011 18:28:35 -0400
Message-Id: <1314397716-18602-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Set the stateowner associated with a replay in one spot in
nfs4_preprocess_seqid_op() and keep it in cstate.  This allows removing
a few lines of boilerplate from all the nfs4_preprocess_seqid_op()
callers.

Also turn ENCODE_SEQID_OP_TAIL into a function while we're here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   25 ++++---------------------
 fs/nfsd/nfs4xdr.c   |   34 +++++++++++++++++++---------------
 2 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dc08ca7..65e9da9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3433,12 +3433,15 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		/* It's not stale; let's assume it's expired: */
 		if (sop == NULL)
 			return nfserr_expired;
-		*sopp = sop;
+		nfs4_get_stateowner(sop);
+		cstate->replay_owner = sop;
 		goto check_replay;
 	}
 
 	*stpp = stp;
 	*sopp = sop = stp->st_stateowner;
+	nfs4_get_stateowner(sop);
+	cstate->replay_owner = sop;
 
 	if (nfs4_check_fh(current_fh, stp)) {
 		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
@@ -3509,10 +3512,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_create_clid_dir(sop->so_client);
 out:
-	if (oc->oc_stateowner) {
-		nfs4_get_stateowner(oc->oc_stateowner);
-		cstate->replay_owner = oc->oc_stateowner;
-	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -3582,10 +3581,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
-	if (od->od_stateowner) {
-		nfs4_get_stateowner(od->od_stateowner);
-		cstate->replay_owner = od->od_stateowner;
-	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -3626,10 +3621,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (list_empty(&close->cl_stateowner->so_stateids))
 		move_to_close_lru(close->cl_stateowner);
 out:
-	if (close->cl_stateowner) {
-		nfs4_get_stateowner(close->cl_stateowner);
-		cstate->replay_owner = close->cl_stateowner;
-	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -4093,10 +4084,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (status && lock->lk_is_new && lock_sop)
 		release_lockowner(lock_sop);
-	if (lock->lk_replay_owner) {
-		nfs4_get_stateowner(lock->lk_replay_owner);
-		cstate->replay_owner = lock->lk_replay_owner;
-	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -4251,10 +4238,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 out:
-	if (locku->lu_stateowner) {
-		nfs4_get_stateowner(locku->lu_stateowner);
-		cstate->replay_owner = locku->lu_stateowner;
-	}
 	nfs4_unlock_state();
 	return status;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 04ad9a2..4b0b0d5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1630,15 +1630,19 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
  * we know whether the error to be returned is a sequence id mutating error.
  */
 
-#define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
-	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) { 	\
-		stateowner->so_seqid++;				\
-		stateowner->so_replay.rp_status = nfserr;   	\
-		stateowner->so_replay.rp_buflen = 		\
-			  (((char *)(resp)->p - (char *)save)); \
-		memcpy(stateowner->so_replay.rp_buf, save,      \
- 			stateowner->so_replay.rp_buflen); 	\
-	} } while (0);
+static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, __be32 nfserr)
+{
+	struct nfs4_stateowner *stateowner = resp->cstate.replay_owner;
+
+	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) {
+		stateowner->so_seqid++;
+		stateowner->so_replay.rp_status = nfserr;
+		stateowner->so_replay.rp_buflen =
+			  (char *)resp->p - (char *)save;
+		memcpy(stateowner->so_replay.rp_buf, save,
+			stateowner->so_replay.rp_buflen);
+	}
+}
 
 /* Encode as an array of strings the string given with components
  * separated @sep.
@@ -2495,7 +2499,7 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &close->cl_stateid);
 
-	ENCODE_SEQID_OP_TAIL(close->cl_stateowner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2599,7 +2603,7 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 	else if (nfserr == nfserr_denied)
 		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
 
-	ENCODE_SEQID_OP_TAIL(lock->lk_replay_owner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2619,7 +2623,7 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &locku->lu_stateid);
 
-	ENCODE_SEQID_OP_TAIL(locku->lu_stateowner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2700,7 +2704,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	}
 	/* XXX save filehandle here */
 out:
-	ENCODE_SEQID_OP_TAIL(open->op_stateowner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2712,7 +2716,7 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
 
-	ENCODE_SEQID_OP_TAIL(oc->oc_stateowner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2724,7 +2728,7 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &od->od_stateid);
 
-	ENCODE_SEQID_OP_TAIL(od->od_stateowner);
+	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
-- 
1.7.4.1

