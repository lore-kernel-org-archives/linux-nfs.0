Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:42729 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932579AbaFSOxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:16 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2285489qcz.14
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:16 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 097/104] NFSd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
Date: Thu, 19 Jun 2014 10:50:43 -0400
Message-Id: <1403189450-18729-98-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 3 ---
 fs/nfsd/nfs4state.c | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 833c753e4775..0b718f545785 100644
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
index e19a5961bf62..0dfe24e0aa61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3809,9 +3809,6 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
 	 */
 }
 
-/*
- * called with nfs4_lock_state() held.
- */
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -4519,8 +4516,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	nfs4_lock_state();
-
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					NFS4_OPEN_STID, &stp, nn);
@@ -4542,7 +4537,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

