Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932200Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/25] nfsd4: share common seqid checks
Date: Wed, 14 Sep 2011 07:45:03 -0400
Message-Id: <1316000721-3289-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a47bf88..8edc9ad 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2456,6 +2456,16 @@ static const struct lock_manager_operations nfsd_lease_mng_ops = {
 	.lm_change = nfsd_change_deleg_cb,
 };
 
+static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4_stateowner *so, u32 seqid)
+{
+	if (nfsd4_has_session(cstate))
+		return nfs_ok;
+	if (seqid == so->so_seqid - 1)
+		return nfserr_replay_me;
+	if (seqid == so->so_seqid)
+		return nfs_ok;
+	return nfserr_bad_seqid;
+}
 
 __be32
 nfsd4_process_open1(struct nfsd4_compound_state *cstate,
@@ -2465,6 +2475,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_stateowner *sop = NULL;
+	__be32 status;
 
 	if (!check_name(open->op_owner))
 		return nfserr_inval;
@@ -2482,9 +2493,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 			return nfserr_expired;
 		goto renew;
 	}
-	/* When sessions are used, skip open sequenceid processing */
-	if (nfsd4_has_session(cstate))
-		goto renew;
 	if (!sop->so_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = sop->so_client;
@@ -2492,10 +2500,9 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		open->op_stateowner = NULL;
 		goto renew;
 	}
-	if (open->op_seqid == sop->so_seqid - 1)
-		return nfserr_replay_me;
-	if (open->op_seqid != sop->so_seqid)
-		return nfserr_bad_seqid;
+	status = nfsd4_check_seqid(cstate, sop, open->op_seqid);
+	if (status)
+		return status;
 renew:
 	if (open->op_stateowner == NULL) {
 		sop = alloc_init_open_stateowner(strhashval, clp, open);
@@ -3411,7 +3418,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		if (sop == NULL)
 			return nfserr_expired;
 		cstate->replay_owner = sop;
-		goto check_replay;
+		status = nfsd4_check_seqid(cstate, sop, seqid);
+		if (status)
+			return status;
+		return nfserr_bad_seqid;
 	}
 
 	*stpp = stp;
@@ -3423,8 +3433,9 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		return nfserr_bad_stateid;
 	}
 
-	if (!nfsd4_has_session(cstate) && seqid != sop->so_seqid)
-		goto check_replay;
+	status = nfsd4_check_seqid(cstate, sop, seqid);
+	if (status)
+		return status;
 
 	if (sop->so_confirmed && flags & CONFIRM) {
 		dprintk("NFSD: preprocess_seqid_op: expected"
@@ -3441,16 +3452,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		return status;
 	renew_client(sop->so_client);
 	return nfs_ok;
-
-check_replay:
-	if (seqid == sop->so_seqid - 1) {
-		dprintk("NFSD: preprocess_seqid_op: retransmission?\n");
-		/* indicate replay to calling function */
-		return nfserr_replay_me;
-	}
-	dprintk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d)\n",
-			sop->so_seqid, seqid);
-	return nfserr_bad_seqid;
 }
 
 __be32
-- 
1.7.4.1

