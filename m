Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:62266 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaG3M21 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:27 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so1176806qac.26
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 30/37] nfsd: Remove nfs4_lock_state(): nfsd4_open and nfsd4_open_confirm
Date: Wed, 30 Jul 2014 08:27:31 -0400
Message-Id: <1406723258-8512-31-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 3 ---
 fs/nfsd/nfs4state.c | 6 ------
 2 files changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 29cf395b694e..5e0dc528a0e8 100644
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
@@ -471,7 +469,6 @@ out:
 	}
 	nfsd4_cleanup_open_state(cstate, open, status);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ae261d0e62e1..02caef874d67 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4003,9 +4003,6 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
 	 */
 }
 
-/*
- * called with nfs4_lock_state() held.
- */
 __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -4686,8 +4683,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	nfs4_lock_state();
-
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					NFS4_OPEN_STID, &stp, nn);
@@ -4781,7 +4776,6 @@ put_stateid:
 	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

