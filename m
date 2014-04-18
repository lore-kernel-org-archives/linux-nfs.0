Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:51108 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbaDRSqy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:54 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so441698igd.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 67/70] NFSd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
Date: Fri, 18 Apr 2014 14:45:01 -0400
Message-Id: <1397846704-14567-68-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-67-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-60-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-61-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-62-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-63-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-64-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-65-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-66-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-67-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 3 ---
 fs/nfsd/nfs4state.c | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1101bf6b63c8..47aa08ed92aa 100644
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
@@ -474,7 +472,6 @@ out:
 		nfsd4_cstate_assign_replay(cstate,
 				&open->op_openowner->oo_owner);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f0facdde981..188eb4cbea95 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3494,9 +3494,6 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
 	 */
 }
 
-/*
- * called with nfs4_lock_state() held.
- */
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -4208,8 +4205,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	nfs4_lock_state();
-
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					NFS4_OPEN_STID, &stp, nn);
@@ -4231,7 +4226,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.0

