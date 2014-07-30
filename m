Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:41168 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbaG3M2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:25 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so1277053qgf.21
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 28/37] nfsd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
Date: Wed, 30 Jul 2014 08:27:29 -0400
Message-Id: <1406723258-8512-29-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index de3bb633d96b..eba119a46add 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4709,7 +4709,6 @@ put_stateid:
 	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4756,7 +4755,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		dprintk("NFSD: %s: od_deleg_want=0x%x ignored\n", __func__,
 			od->od_deleg_want);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
 					&od->od_stateid, &stp, nn);
 	if (status)
@@ -4822,7 +4820,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dprintk("NFSD: nfsd4_close on file %pd\n", 
 			cstate->current_fh.fh_dentry);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
@@ -4838,7 +4835,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* put reference from nfs4_preprocess_seqid_op */
 	nfs4_put_stid(&stp->st_stid);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

