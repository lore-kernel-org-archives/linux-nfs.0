Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:56085 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbaFFS4o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 14:56:44 -0400
Received: by mail-qa0-f49.google.com with SMTP id cm18so4470675qab.36
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2014 11:56:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSd: nfs4_preprocess_seqid_op should only set *stpp on success
Date: Fri,  6 Jun 2014 14:56:34 -0400
Message-Id: <1402080994-23737-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f429883fb4bb..f8c61c2a0a9e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3897,6 +3897,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 {
 	__be32 status;
 	struct nfs4_stid *s;
+	struct nfs4_ol_stateid *stp = NULL;
 
 	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
 		seqid, STATEID_VAL(stateid));
@@ -3906,11 +3907,14 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 				      cstate->minorversion, nn);
 	if (status)
 		return status;
-	*stpp = openlockstateid(s);
+	stp = openlockstateid(s);
 	if (!nfsd4_has_session(cstate))
-		cstate->replay_owner = (*stpp)->st_stateowner;
+		cstate->replay_owner = stp->st_stateowner;
 
-	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
+	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
+	if (!status)
+		*stpp = stp;
+	return status;
 }
 
 static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
-- 
1.9.3

