Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36520 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbdHNTiY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 15:38:24 -0400
Received: by mail-it0-f66.google.com with SMTP id o72so3897092ita.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 12:38:23 -0700 (PDT)
Subject: [PATCH v1 1/2] xprtrdma: Remove imul instructions from
 rpcrdma_convert_iovs()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Aug 2017 15:38:22 -0400
Message-ID: <20170814193822.25033.1091.stgit@manet.1015granger.net>
In-Reply-To: <20170814192946.25033.43917.stgit@manet.1015granger.net>
References: <20170814192946.25033.43917.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Re-arrange the pointer arithmetic in rpcrdma_convert_iovs() to
eliminate several integer multiplication instructions during
Transport Header encoding.

Also, array overflow does not occur outside development
environments, so replace overflow checking with one spot check
at the end. This reduces the number of conditional branches in
the common case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |  105 ++++++++++++++++++----------------------
 1 file changed, 48 insertions(+), 57 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f27dbfd..211ac4b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -169,40 +169,41 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return rqst->rq_rcv_buf.buflen <= ia->ri_max_inline_read;
 }
 
-/* Split "vec" on page boundaries into segments. FMR registers pages,
- * not a byte range. Other modes coalesce these segments into a single
- * MR when they can.
+/* Split @vec on page boundaries into SGEs. FMR registers pages, not
+ * a byte range. Other modes coalesce these SGEs into a single MR
+ * when they can.
+ *
+ * Returns pointer to next available SGE, and bumps the total number
+ * of SGEs consumed.
  */
-static int
-rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg, int n)
+static struct rpcrdma_mr_seg *
+rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg,
+		     unsigned int *n)
 {
-	size_t page_offset;
-	u32 remaining;
+	u32 remaining, page_offset;
 	char *base;
 
 	base = vec->iov_base;
 	page_offset = offset_in_page(base);
 	remaining = vec->iov_len;
-	while (remaining && n < RPCRDMA_MAX_SEGS) {
-		seg[n].mr_page = NULL;
-		seg[n].mr_offset = base;
-		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_offset, remaining);
-		remaining -= seg[n].mr_len;
-		base += seg[n].mr_len;
-		++n;
+	while (remaining) {
+		seg->mr_page = NULL;
+		seg->mr_offset = base;
+		seg->mr_len = min_t(u32, PAGE_SIZE - page_offset, remaining);
+		remaining -= seg->mr_len;
+		base += seg->mr_len;
+		++seg;
+		++(*n);
 		page_offset = 0;
 	}
-	return n;
+	return seg;
 }
 
-/*
- * Chunk assembly from upper layer xdr_buf.
- *
- * Prepare the passed-in xdr_buf into representation as RPC/RDMA chunk
- * elements. Segments are then coalesced when registered, if possible
- * within the selected memreg mode.
+/* Convert @xdrbuf into SGEs no larger than a page each. As they
+ * are registered, these SGEs are then coalesced into RDMA segments
+ * when the selected memreg mode supports it.
  *
- * Returns positive number of segments converted, or a negative errno.
+ * Returns positive number of SGEs consumed, or a negative errno.
  */
 
 static int
@@ -210,47 +211,41 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		     unsigned int pos, enum rpcrdma_chunktype type,
 		     struct rpcrdma_mr_seg *seg)
 {
-	int len, n, p, page_base;
+	unsigned long page_base;
+	unsigned int len, n;
 	struct page **ppages;
 
 	n = 0;
-	if (pos == 0) {
-		n = rpcrdma_convert_kvec(&xdrbuf->head[0], seg, n);
-		if (n == RPCRDMA_MAX_SEGS)
-			goto out_overflow;
-	}
+	if (pos == 0)
+		seg = rpcrdma_convert_kvec(&xdrbuf->head[0], seg, &n);
 
 	len = xdrbuf->page_len;
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = offset_in_page(xdrbuf->page_base);
-	p = 0;
-	while (len && n < RPCRDMA_MAX_SEGS) {
-		if (!ppages[p]) {
-			/* alloc the pagelist for receiving buffer */
-			ppages[p] = alloc_page(GFP_ATOMIC);
-			if (!ppages[p])
+	while (len) {
+		if (unlikely(!*ppages)) {
+			/* XXX: Certain upper layer operations do
+			 *	not provide receive buffer pages.
+			 */
+			*ppages = alloc_page(GFP_ATOMIC);
+			if (!*ppages)
 				return -EAGAIN;
 		}
-		seg[n].mr_page = ppages[p];
-		seg[n].mr_offset = (void *)(unsigned long) page_base;
-		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_base, len);
-		if (seg[n].mr_len > PAGE_SIZE)
-			goto out_overflow;
-		len -= seg[n].mr_len;
+		seg->mr_page = *ppages;
+		seg->mr_offset = (char *)page_base;
+		seg->mr_len = min_t(u32, PAGE_SIZE - page_base, len);
+		len -= seg->mr_len;
+		++ppages;
+		++seg;
 		++n;
-		++p;
-		page_base = 0;	/* page offset only applies to first page */
+		page_base = 0;
 	}
 
-	/* Message overflows the seg array */
-	if (len && n == RPCRDMA_MAX_SEGS)
-		goto out_overflow;
-
 	/* When encoding a Read chunk, the tail iovec contains an
 	 * XDR pad and may be omitted.
 	 */
 	if (type == rpcrdma_readch && r_xprt->rx_ia.ri_implicit_roundup)
-		return n;
+		goto out;
 
 	/* When encoding a Write chunk, some servers need to see an
 	 * extra segment for non-XDR-aligned Write chunks. The upper
@@ -258,19 +253,15 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * for this purpose.
 	 */
 	if (type == rpcrdma_writech && r_xprt->rx_ia.ri_implicit_roundup)
-		return n;
+		goto out;
 
-	if (xdrbuf->tail[0].iov_len) {
-		n = rpcrdma_convert_kvec(&xdrbuf->tail[0], seg, n);
-		if (n == RPCRDMA_MAX_SEGS)
-			goto out_overflow;
-	}
+	if (xdrbuf->tail[0].iov_len)
+		seg = rpcrdma_convert_kvec(&xdrbuf->tail[0], seg, &n);
 
+out:
+	if (unlikely(n > RPCRDMA_MAX_SEGS))
+		return -EIO;
 	return n;
-
-out_overflow:
-	pr_err("rpcrdma: segment array overflow\n");
-	return -EIO;
 }
 
 static inline int

