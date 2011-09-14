Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932226Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/25] nfsd4: move CLOSE_STATE special case to caller
Date: Wed, 14 Sep 2011 07:45:06 -0400
Message-Id: <1316000721-3289-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move the CLOSE_STATE case into the unique caller that cares about it
rather than putting it in preprocess_seqid_op.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   56 ++++++++++++++++++++++++--------------------------
 fs/nfsd/state.h     |    1 -
 2 files changed, 27 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c44630..eb11626 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3070,15 +3070,13 @@ laundromat_main(struct work_struct *not_used)
 }
 
 static struct nfs4_stateowner *
-search_close_lru(u32 st_id, int flags)
+search_close_lru(u32 st_id)
 {
-	struct nfs4_stateowner *local = NULL;
+	struct nfs4_stateowner *local;
 
-	if (flags & CLOSE_STATE) {
-		list_for_each_entry(local, &close_lru, so_close_lru) {
-			if (local->so_id == st_id)
-				return local;
-		}
+	list_for_each_entry(local, &close_lru, so_close_lru) {
+		if (local->so_id == st_id)
+			return local;
 	}
 	return NULL;
 }
@@ -3381,7 +3379,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, int flags,
 			 struct nfs4_stateid **stpp)
 {
-	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	__be32 status;
@@ -3404,28 +3401,14 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	* the confirmed flag is incorrecly set, or the generation 
 	* number is incorrect.  
 	*/
-	stp = find_stateid(stateid, flags);
-	if (stp == NULL) {
-		/*
-		 * Also, we should make sure this isn't just the result of
-		 * a replayed close:
-		 */
-		sop = search_close_lru(stateid->si_stateownerid, flags);
-		/* It's not stale; let's assume it's expired: */
-		if (sop == NULL)
-			return nfserr_expired;
-		cstate->replay_owner = sop;
-		status = nfsd4_check_seqid(cstate, sop, seqid);
-		if (status)
-			return status;
-		return nfserr_bad_seqid;
-	}
+	*stpp = find_stateid(stateid, flags);
+	if (*stpp == NULL)
+		return nfserr_expired;
 
-	*stpp = stp;
-	sop = stp->st_stateowner;
+	sop = (*stpp)->st_stateowner;
 	cstate->replay_owner = sop;
 
-	if (nfs4_check_fh(current_fh, stp)) {
+	if (nfs4_check_fh(current_fh, *stpp)) {
 		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
 		return nfserr_bad_stateid;
 	}
@@ -3439,7 +3422,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
 	}
-	status = check_stateid_generation(stateid, &stp->st_stateid, nfsd4_has_session(cstate));
+	status = check_stateid_generation(stateid, &(*stpp)->st_stateid, nfsd4_has_session(cstate));
 	if (status)
 		return status;
 	renew_client(sop->so_client);
@@ -3574,7 +3557,22 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* check close_lru for replay */
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid, 
-					OPEN_STATE | CLOSE_STATE, &stp);
+					OPEN_STATE, &stp);
+	if (stp == NULL && status == nfserr_expired) {
+		/*
+		 * Also, we should make sure this isn't just the result of
+		 * a replayed close:
+		 */
+		so = search_close_lru(close->cl_stateid.si_stateownerid);
+		/* It's not stale; let's assume it's expired: */
+		if (so == NULL)
+			goto out;
+		cstate->replay_owner = so;
+		status = nfsd4_check_seqid(cstate, so, close->cl_seqid);
+		if (status)
+			goto out;
+		status = nfserr_bad_seqid;
+	}
 	if (status)
 		goto out; 
 	so = stp->st_stateowner;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f7114fc2..0d88000 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -448,7 +448,6 @@ struct nfs4_stateid {
 #define LOCK_STATE              0x00000008
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
-#define CLOSE_STATE             0x00000040
 
 struct nfsd4_compound_state;
 
-- 
1.7.4.1

