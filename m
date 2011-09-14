Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60165 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/25] nfsd4: move double-confirm test to open_confirm
Date: Wed, 14 Sep 2011 07:45:05 -0400
Message-Id: <1316000721-3289-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I don't see the point of having this check in nfs4_preprocess_seqid_op()
when it's only needed by the one caller.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8694e60..9c44630 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3434,11 +3434,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (status)
 		return status;
 
-	if (sop->so_confirmed && flags & CONFIRM) {
-		dprintk("NFSD: preprocess_seqid_op: expected"
-				" unconfirmed stateowner!\n");
-		return nfserr_bad_stateid;
-	}
 	if (!sop->so_confirmed && !(flags & CONFIRM)) {
 		dprintk("NFSD: preprocess_seqid_op: stateowner not"
 				" confirmed yet!\n");
@@ -3473,9 +3468,11 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					CONFIRM | OPEN_STATE, &stp);
 	if (status)
-		goto out; 
-
+		goto out;
 	sop = stp->st_stateowner;
+	status = nfserr_bad_stateid;
+	if (sop->so_confirmed)
+		goto out;
 	sop->so_confirmed = 1;
 	update_stateid(&stp->st_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stateid, sizeof(stateid_t));
@@ -3483,6 +3480,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stateid));
 
 	nfsd4_create_clid_dir(sop->so_client);
+	status = nfs_ok;
 out:
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.7.4.1

