Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:47610 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbaF3PzQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:16 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so6671521qaj.9
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:16 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 105/114] nfsd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
Date: Mon, 30 Jun 2014 11:54:52 -0400
Message-Id: <1404143701-24740-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ba42aa4e4b51..7910c9b1dc3f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4672,7 +4672,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4719,7 +4718,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		dprintk("NFSD: %s: od_deleg_want=0x%x ignored\n", __func__,
 			od->od_deleg_want);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
 					&od->od_stateid, &stp, nn);
 	if (status)
@@ -4785,7 +4783,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dprintk("NFSD: nfsd4_close on file %pd\n", 
 			cstate->current_fh.fh_dentry);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
@@ -4801,7 +4798,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* put reference from nfs4_preprocess_seqid_op */
 	put_generic_stateid(stp);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

