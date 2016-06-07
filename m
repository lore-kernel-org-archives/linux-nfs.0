Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35958 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbcFGTsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:48:15 -0400
Subject: [PATCH v1 14/20] xprtrdma: Clean up fixup_copy_count accounting
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:48:13 -0400
Message-ID: <20160607194813.18401.34276.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fixup_copy_count should count only the number of bytes copied to the
page list. The head and tail are now always handled without a data
copy.

And the debugging at the end of rpcrdma_inline_fixup() is also no
longer necessary, since copy_len will be non-zero when there is reply
data in the tail (a normal and valid case).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b763f49..34a5df9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -758,11 +758,14 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, int wrchunk, __be32 **iptrp)
  * many cases this function simply updates iov_base pointers in
  * rq_rcv_buf to point directly to the received reply data, to
  * avoid copying reply data.
+ *
+ * Returns the count of bytes which had to be memcopied.
  */
-static void
+static unsigned long
 rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 {
-	int i, npages, curlen, olen;
+	unsigned long fixup_copy_count;
+	int i, npages, curlen;
 	char *destp;
 	struct page **ppages;
 	int page_base;
@@ -784,13 +787,10 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	srcp += curlen;
 	copy_len -= curlen;
 
-	olen = copy_len;
-	i = 0;
-	rpcx_to_rdmax(rqst->rq_xprt)->rx_stats.fixup_copy_count += olen;
 	page_base = rqst->rq_rcv_buf.page_base;
 	ppages = rqst->rq_rcv_buf.pages + (page_base >> PAGE_SHIFT);
 	page_base &= ~PAGE_MASK;
-
+	fixup_copy_count = 0;
 	if (copy_len && rqst->rq_rcv_buf.page_len) {
 		int pagelist_len;
 
@@ -798,7 +798,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 		if (pagelist_len > copy_len)
 			pagelist_len = copy_len;
 		npages = PAGE_ALIGN(page_base + pagelist_len) >> PAGE_SHIFT;
-		for (; i < npages; i++) {
+		for (i = 0; i < npages; i++) {
 			curlen = PAGE_SIZE - page_base;
 			if (curlen > pagelist_len)
 				curlen = pagelist_len;
@@ -812,6 +812,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			kunmap_atomic(destp);
 			srcp += curlen;
 			copy_len -= curlen;
+			fixup_copy_count += curlen;
 			pagelist_len -= curlen;
 			if (!pagelist_len)
 				break;
@@ -836,10 +837,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 		rqst->rq_private_buf.tail[0].iov_base = srcp;
 	}
 
-	if (copy_len)
-		dprintk("RPC:       %s: %d bytes in"
-			" %d extra segments (%d lost)\n",
-			__func__, olen, i, copy_len);
+	return fixup_copy_count;
 }
 
 void
@@ -1002,8 +1000,10 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 			rep->rr_len -= RPCRDMA_HDRLEN_MIN;
 			status = rep->rr_len;
 		}
-		/* Fix up the rpc results for upper layer */
-		rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len, rdmalen);
+
+		r_xprt->rx_stats.fixup_copy_count +=
+			rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len,
+					     rdmalen);
 		break;
 
 	case rdma_nomsg:

