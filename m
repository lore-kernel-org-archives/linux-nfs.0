Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:45039 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaFZTOC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:02 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so3516806qcx.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 011/117] nfsd: nfs4_preprocess_seqid_op should only set *stpp on success
Date: Thu, 26 Jun 2014 15:11:51 -0400
Message-Id: <1403810017-16062-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Not technically a bugfix, since nothing tries to use the return pointer
if this function doesn't return success, but it could be a problem
with some coming changes.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 461229a01963..3ce5dc30f767 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3964,6 +3964,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 {
 	__be32 status;
 	struct nfs4_stid *s;
+	struct nfs4_ol_stateid *stp = NULL;
 
 	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
 		seqid, STATEID_VAL(stateid));
@@ -3973,11 +3974,14 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
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

