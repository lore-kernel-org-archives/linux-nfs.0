Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:61829 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757862AbaFSOvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:03 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so2217641qgf.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 003/104] NFSd: nfs4_preprocess_seqid_op should only set *stpp on success
Date: Thu, 19 Jun 2014 10:49:09 -0400
Message-Id: <1403189450-18729-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 42c6d6ecc77d..d18fd8c7691c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3891,6 +3891,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 {
 	__be32 status;
 	struct nfs4_stid *s;
+	struct nfs4_ol_stateid *stp = NULL;
 
 	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
 		seqid, STATEID_VAL(stateid));
@@ -3900,11 +3901,14 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
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

