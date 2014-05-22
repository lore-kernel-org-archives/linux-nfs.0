Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43423 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbaEVTcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 29/52] nfsd4: more precise nfsd4_max_reply
Date: Thu, 22 May 2014 15:32:04 -0400
Message-Id: <1400787148-25941-30-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It will turn out to be useful to have a more accurate estimate of reply
size; so, piggyback on the existing op reply-size estimators.

Also move nfsd4_max_reply to nfs4proc.c to get easier access to struct
nfsd4_operation and friends.  (Thanks to Christoph Hellwig for pointing
out that simplification.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 12 ++++++++++++
 fs/nfsd/nfs4xdr.c  | 35 ++++-------------------------------
 fs/nfsd/xdr4.h     |  1 +
 3 files changed, 17 insertions(+), 31 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1326a0b..e1196ed 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1856,6 +1856,18 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
+int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	struct nfsd4_operation *opdesc;
+	nfsd4op_rsize estimator;
+
+	if (op->opnum == OP_ILLEGAL)
+		return op_encode_hdr_size;
+	opdesc = OPDESC(op);
+	estimator = opdesc->op_rsize_bop;
+	return estimator ? estimator(rqstp, op) : PAGE_SIZE;
+}
+
 void warn_on_nonidempotent_op(struct nfsd4_op *op)
 {
 	if (OPDESC(op)->op_flags & OP_MODIFIES_SOMETHING) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4c2f866..4877abb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1605,40 +1605,13 @@ nfsd4_opnum_in_range(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
 	return true;
 }
 
-/*
- * Return a rough estimate of the maximum possible reply size.  Note the
- * estimate includes rpc headers so is meant to be passed to
- * svc_reserve, not svc_reserve_auth.
- *
- * Also note the current compound encoding permits only one operation to
- * use pages beyond the first one, so the maximum possible length is the
- * maximum over these values, not the sum.
- */
-static int nfsd4_max_reply(u32 opnum)
-{
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
-}
-
 static __be32
 nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 {
 	DECODE_HEAD;
 	struct nfsd4_op *op;
 	bool cachethis = false;
-	int max_reply = PAGE_SIZE;
+	int max_reply = 2 * RPC_MAX_AUTH_SIZE + 8; /* opcnt, status */
 	int i;
 
 	READ_BUF(4);
@@ -1647,6 +1620,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	SAVEMEM(argp->tag, argp->taglen);
 	READ32(argp->minorversion);
 	READ32(argp->opcnt);
+	max_reply += 4 + (XDR_QUADLEN(argp->taglen) << 2);
 
 	if (argp->taglen > NFSD4_MAX_TAGLEN)
 		goto xdr_error;
@@ -1684,7 +1658,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		 */
 		cachethis |= nfsd4_cache_this_op(op);
 
-		max_reply = max(max_reply, nfsd4_max_reply(op->opnum));
+		max_reply += nfsd4_max_reply(argp->rqstp, op);
 
 		if (op->status) {
 			argp->opcnt = i+1;
@@ -1694,8 +1668,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
 		cachethis = false;
-	if (max_reply != INT_MAX)
-		svc_reserve(argp->rqstp, max_reply);
+	svc_reserve(argp->rqstp, max_reply);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
 	DECODE_TAIL;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ee9ffdc..41e5229 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -536,6 +536,7 @@ static inline bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
 	return argp->opcnt == resp->opcnt;
 }
 
+int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op);
 void warn_on_nonidempotent_op(struct nfsd4_op *op);
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.9.0

