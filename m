Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38592 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757651AbaEKUxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 24/43] nfsd4: more precise nfsd4_max_reply
Date: Sun, 11 May 2014 16:52:29 -0400
Message-Id: <1399841568-19716-25-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

---
 fs/nfsd/nfs4xdr.c |   27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d418d7e..19071d7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1614,22 +1614,12 @@ nfsd4_opnum_in_range(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
  * use pages beyond the first one, so the maximum possible length is the
  * maximum over these values, not the sum.
  */
-static int nfsd4_max_reply(u32 opnum)
+static int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
-	switch (opnum) {
-	case OP_READLINK:
-	case OP_READDIR:
-		/*
-		 * Both of these ops take a single page for data and put
-		 * the head and tail in another page:
-		 */
-		return 2 * PAGE_SIZE;
-	case OP_GETATTR:
-	case OP_READ:
-		return INT_MAX;
-	default:
-		return PAGE_SIZE;
-	}
+	struct nfsd4_operation *opdesc = OPDESC(op);
+	nfsd4op_rsize estimator = opdesc->op_rsize_bop;
+
+	return estimator ? estimator(rqstp, op) : PAGE_SIZE;
 }
 
 static __be32
@@ -1638,7 +1628,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_HEAD;
 	struct nfsd4_op *op;
 	bool cachethis = false;
-	int max_reply = PAGE_SIZE;
+	int max_reply = 2 * RPC_MAX_AUTH_SIZE; /* uh, kind of a guess */
 	int i;
 
 	READ_BUF(4);
@@ -1689,13 +1679,12 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		 */
 		cachethis |= nfsd4_cache_this_op(op);
 
-		max_reply = max(max_reply, nfsd4_max_reply(op->opnum));
+		max_reply += nfsd4_max_reply(argp->rqstp, op);
 	}
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
 		cachethis = false;
-	if (max_reply != INT_MAX)
-		svc_reserve(argp->rqstp, max_reply);
+	svc_reserve(argp->rqstp, max_reply);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
 	DECODE_TAIL;
-- 
1.7.9.5

