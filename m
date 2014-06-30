Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:49503 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbaF3PzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:19 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so2078760qge.18
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 107/114] nfsd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
Date: Mon, 30 Jun 2014 11:54:54 -0400
Message-Id: <1404143701-24740-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 3 ---
 fs/nfsd/nfs4state.c | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cdce2f39b09c..8381f9429340 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -385,8 +385,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (nfsd4_has_session(cstate))
 		copy_clientid(&open->op_clientid, cstate->session);
 
-	nfs4_lock_state();
-
 	/* check seqid for replay. set nfs4_owner */
 	resp = rqstp->rq_resp;
 	status = nfsd4_process_open1(&resp->cstate, open, nn);
@@ -469,7 +467,6 @@ out:
 	}
 	nfsd4_cleanup_open_state(cstate, open, status);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 952aca4d3b2d..13615fe64b48 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3969,9 +3969,6 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
 	 */
 }
 
-/*
- * called with nfs4_lock_state() held.
- */
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -4649,8 +4646,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	nfs4_lock_state();
-
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					NFS4_OPEN_STID, &stp, nn);
@@ -4744,7 +4739,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

