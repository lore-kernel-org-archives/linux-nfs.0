Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:54199 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470Ab1BITp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 14:45:29 -0500
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 1/2] RPCRDMA: Fix to XDR page base interpretation in
	marshalling logic.
To: Trond.Myklebust@netapp.com
Cc: spelic@shiftmail.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Wed, 09 Feb 2011 13:45:28 -0600
Message-ID: <20110209194528.22358.14221.stgit@build.ogc.int>
In-Reply-To: <20110209194430.22358.46254.stgit@build.ogc.int>
References: <20110209194430.22358.46254.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The RPCRDMA marshalling logic assumed that xdr->page_base was an
offset into the first page of xdr->page_list. It is in fact an
offset into the xdr->page_list itself, that is, it selects the
first page in the page_list and the offset into that page.

The symptom depended in part on the rpc_memreg_strategy, if it was
FRMR, or some other one-shot mapping mode, the connection would get
torn down on a base and bounds error. When the badly marshalled RPC
was retransmitted it would reconnect, get the error, and tear down the
connection again in a loop forever. This resulted in a hung-mount. For
the other modes, it would result in silent data corruption. This bug is
most easily reproduced by writing more data than the filesystem
has space for.

This fix corrects the page_base assumption and otherwise simplifies
the iov mapping logic.

Signed-off-by: Tom Tucker <tom@ogc.us>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |   86 ++++++++++++++++++++--------------------
 1 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 2ac3f6e..554d081 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -87,6 +87,8 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg, int nsegs)
 {
 	int len, n = 0, p;
+	int page_base;
+	struct page **ppages;
 
 	if (pos == 0 && xdrbuf->head[0].iov_len) {
 		seg[n].mr_page = NULL;
@@ -95,34 +97,32 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 		++n;
 	}
 
-	if (xdrbuf->page_len && (xdrbuf->pages[0] != NULL)) {
-		if (n == nsegs)
-			return 0;
-		seg[n].mr_page = xdrbuf->pages[0];
-		seg[n].mr_offset = (void *)(unsigned long) xdrbuf->page_base;
-		seg[n].mr_len = min_t(u32,
-			PAGE_SIZE - xdrbuf->page_base, xdrbuf->page_len);
-		len = xdrbuf->page_len - seg[n].mr_len;
+	len = xdrbuf->page_len;
+	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
+	page_base = xdrbuf->page_base & ~PAGE_MASK;
+	p = 0;
+	while (len && n < nsegs) {
+		seg[n].mr_page = ppages[p];
+		seg[n].mr_offset = (void *)(unsigned long) page_base;
+		seg[n].mr_len = min_t(u32, PAGE_SIZE - page_base, len);
+		BUG_ON(seg[n].mr_len > PAGE_SIZE);
+		len -= seg[n].mr_len;
 		++n;
-		p = 1;
-		while (len > 0) {
-			if (n == nsegs)
-				return 0;
-			seg[n].mr_page = xdrbuf->pages[p];
-			seg[n].mr_offset = NULL;
-			seg[n].mr_len = min_t(u32, PAGE_SIZE, len);
-			len -= seg[n].mr_len;
-			++n;
-			++p;
-		}
+		++p;
+		page_base = 0;	/* page offset only applies to first page */
 	}
 
+	/* Message overflows the seg array */
+	if (len && n == nsegs)
+		return 0;
+
 	if (xdrbuf->tail[0].iov_len) {
 		/* the rpcrdma protocol allows us to omit any trailing
 		 * xdr pad bytes, saving the server an RDMA operation. */
 		if (xdrbuf->tail[0].iov_len < 4 && xprt_rdma_pad_optimize)
 			return n;
 		if (n == nsegs)
+			/* Tail remains, but we're out of segments */
 			return 0;
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = xdrbuf->tail[0].iov_base;
@@ -296,6 +296,8 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 	int copy_len;
 	unsigned char *srcp, *destp;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
+	int page_base;
+	struct page **ppages;
 
 	destp = rqst->rq_svec[0].iov_base;
 	curlen = rqst->rq_svec[0].iov_len;
@@ -324,28 +326,25 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 			__func__, destp + copy_len, curlen);
 		rqst->rq_svec[0].iov_len += curlen;
 	}
-
 	r_xprt->rx_stats.pullup_copy_count += copy_len;
-	npages = PAGE_ALIGN(rqst->rq_snd_buf.page_base+copy_len) >> PAGE_SHIFT;
+
+	page_base = rqst->rq_snd_buf.page_base;
+	ppages = rqst->rq_snd_buf.pages + (page_base >> PAGE_SHIFT);
+	page_base &= ~PAGE_MASK;
+	npages = PAGE_ALIGN(page_base+copy_len) >> PAGE_SHIFT;
 	for (i = 0; copy_len && i < npages; i++) {
-		if (i == 0)
-			curlen = PAGE_SIZE - rqst->rq_snd_buf.page_base;
-		else
-			curlen = PAGE_SIZE;
+		curlen = PAGE_SIZE - page_base;
 		if (curlen > copy_len)
 			curlen = copy_len;
 		dprintk("RPC:       %s: page %d destp 0x%p len %d curlen %d\n",
 			__func__, i, destp, copy_len, curlen);
-		srcp = kmap_atomic(rqst->rq_snd_buf.pages[i],
-					KM_SKB_SUNRPC_DATA);
-		if (i == 0)
-			memcpy(destp, srcp+rqst->rq_snd_buf.page_base, curlen);
-		else
-			memcpy(destp, srcp, curlen);
+		srcp = kmap_atomic(ppages[i], KM_SKB_SUNRPC_DATA);
+		memcpy(destp, srcp+page_base, curlen);
 		kunmap_atomic(srcp, KM_SKB_SUNRPC_DATA);
 		rqst->rq_svec[0].iov_len += curlen;
 		destp += curlen;
 		copy_len -= curlen;
+		page_base = 0;
 	}
 	/* header now contains entire send message */
 	return pad;
@@ -606,6 +605,8 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 {
 	int i, npages, curlen, olen;
 	char *destp;
+	struct page **ppages;
+	int page_base;
 
 	curlen = rqst->rq_rcv_buf.head[0].iov_len;
 	if (curlen > copy_len) {	/* write chunk header fixup */
@@ -624,32 +625,29 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	olen = copy_len;
 	i = 0;
 	rpcx_to_rdmax(rqst->rq_xprt)->rx_stats.fixup_copy_count += olen;
+	page_base = rqst->rq_rcv_buf.page_base;
+	ppages = rqst->rq_rcv_buf.pages + (page_base >> PAGE_SHIFT);
+	page_base &= ~PAGE_MASK;
+
 	if (copy_len && rqst->rq_rcv_buf.page_len) {
-		npages = PAGE_ALIGN(rqst->rq_rcv_buf.page_base +
+		npages = PAGE_ALIGN(page_base +
 			rqst->rq_rcv_buf.page_len) >> PAGE_SHIFT;
 		for (; i < npages; i++) {
-			if (i == 0)
-				curlen = PAGE_SIZE - rqst->rq_rcv_buf.page_base;
-			else
-				curlen = PAGE_SIZE;
+			curlen = PAGE_SIZE - page_base;
 			if (curlen > copy_len)
 				curlen = copy_len;
 			dprintk("RPC:       %s: page %d"
 				" srcp 0x%p len %d curlen %d\n",
 				__func__, i, srcp, copy_len, curlen);
-			destp = kmap_atomic(rqst->rq_rcv_buf.pages[i],
-						KM_SKB_SUNRPC_DATA);
-			if (i == 0)
-				memcpy(destp + rqst->rq_rcv_buf.page_base,
-						srcp, curlen);
-			else
-				memcpy(destp, srcp, curlen);
-			flush_dcache_page(rqst->rq_rcv_buf.pages[i]);
+			destp = kmap_atomic(ppages[i], KM_SKB_SUNRPC_DATA);
+			memcpy(destp + page_base, srcp, curlen);
+			flush_dcache_page(ppages[i]);
 			kunmap_atomic(destp, KM_SKB_SUNRPC_DATA);
 			srcp += curlen;
 			copy_len -= curlen;
 			if (copy_len == 0)
 				break;
+			page_base = 0;
 		}
 		rqst->rq_rcv_buf.page_len = olen - copy_len;
 	} else

