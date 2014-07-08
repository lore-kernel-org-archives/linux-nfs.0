Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:46468 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaGHSGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:38 -0400
Received: by mail-qc0-f178.google.com with SMTP id i17so1303289qcy.37
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 091/100] nfsd: Remove nfs4_lock_state(): nfsd4_open_downgrade + nfsd4_close
Date: Tue,  8 Jul 2014 14:04:19 -0400
Message-Id: <1404842668-22521-92-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f184503b42e..46d3c13f7d94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4708,7 +4708,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4755,7 +4754,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		dprintk("NFSD: %s: od_deleg_want=0x%x ignored\n", __func__,
 			od->od_deleg_want);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
 					&od->od_stateid, &stp, nn);
 	if (status)
@@ -4821,7 +4819,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dprintk("NFSD: nfsd4_close on file %pd\n", 
 			cstate->current_fh.fh_dentry);
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
@@ -4837,7 +4834,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* put reference from nfs4_preprocess_seqid_op */
 	put_generic_stateid(stp);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

