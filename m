Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43479 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbaEVTcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Date: Thu, 22 May 2014 15:32:16 -0400
Message-Id: <1400787148-25941-42-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We currently allow only one read per compound, with operations before
and after whose responses will require no more than about a page to
encode.

While we don't expect clients to violate those limits any time soon,
this limitation isn't really condoned by the spec, so to future proof
the server we should lift the limitation.

At the same time we'd like to continue to support zero-copy reads.

Supporting multiple zero-copy-reads per compound would require a new
data structure to replace struct xdr_buf, which can represent only one
set of included pages.

So for now we plan to modify encode_read() to support either zero-copy
or non-zero-copy reads, and use some heuristics at the start of the
compound processing to decide whether a zero-copy read will work.

This will allow us to support more exotic compounds without introducing
a performance regression in the normal case.

Later patches handle those "exotic compounds", this one just makes sure
zero-copy is turned off in those cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a3cfb89..1ca547d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1612,6 +1612,8 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	struct nfsd4_op *op;
 	bool cachethis = false;
 	int max_reply = 2 * RPC_MAX_AUTH_SIZE + 8; /* opcnt, status */
+	int readcount = 0;
+	int readbytes = 0;
 	int i;
 
 	READ_BUF(4);
@@ -1658,7 +1660,11 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		 */
 		cachethis |= nfsd4_cache_this_op(op);
 
-		max_reply += nfsd4_max_reply(argp->rqstp, op);
+		if (op->opnum == OP_READ) {
+			readcount++;
+			readbytes += nfsd4_max_reply(argp->rqstp, op);
+		} else
+			max_reply += nfsd4_max_reply(argp->rqstp, op);
 
 		if (op->status) {
 			argp->opcnt = i+1;
@@ -1668,9 +1674,12 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
 		cachethis = false;
-	svc_reserve(argp->rqstp, max_reply);
+	svc_reserve(argp->rqstp, max_reply + readbytes);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
+	if (readcount > 1 || max_reply > PAGE_SIZE - 2*RPC_MAX_AUTH_SIZE)
+		argp->rqstp->rq_splice_ok = false;
+
 	DECODE_TAIL;
 }
 
@@ -3078,15 +3087,19 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		return nfserr;
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
-	if (!p)
+	if (!p) {
+		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
 		return nfserr_resource;
+	}
 
 	/* Make sure there will be room for padding if needed: */
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
-	if (resp->xdr.buf->page_len)
+	if (resp->xdr.buf->page_len) {
+		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
 		return nfserr_resource;
+	}
 
 	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > read->rd_length)
-- 
1.9.0

