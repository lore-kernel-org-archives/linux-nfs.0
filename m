Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55053 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754247Ab0JLUdw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 16:33:52 -0400
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 1/2] svcrdma: Change DMA mapping logic to avoid the
	page_address kernel API
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 12 Oct 2010 15:33:52 -0500
Message-ID: <20101012203351.22154.42528.stgit@build.ogc.int>
In-Reply-To: <20101012203332.22154.37230.stgit@build.ogc.int>
References: <20101012203332.22154.37230.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There was logic in the send path that assumed that a page containing data
to send to the client has a KVA. This is not always the case and can result
in data corruption when page_address returns zero and we end up DMA mapping
zero.

This patch changes the bus mapping logic to avoid page_address() where
necessary and converts all calls from ib_dma_map_single to ib_dma_map_page
in order to keep the map/unmap calls symmetric.

Signed-off-by: Tom Tucker <tom@ogc.us>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   18 ++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   80 ++++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   18 +++----
 3 files changed, 78 insertions(+), 38 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 0194de8..926bdb4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -263,9 +263,9 @@ static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
 	frmr->page_list_len = PAGE_ALIGN(byte_count) >> PAGE_SHIFT;
 	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
 		frmr->page_list->page_list[page_no] =
-			ib_dma_map_single(xprt->sc_cm_id->device,
-					  page_address(rqstp->rq_arg.pages[page_no]),
-					  PAGE_SIZE, DMA_FROM_DEVICE);
+			ib_dma_map_page(xprt->sc_cm_id->device,
+					rqstp->rq_arg.pages[page_no], 0,
+					PAGE_SIZE, DMA_FROM_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 					 frmr->page_list->page_list[page_no]))
 			goto fatal_err;
@@ -309,17 +309,21 @@ static int rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 			     int count)
 {
 	int i;
+	unsigned long off;
 
 	ctxt->count = count;
 	ctxt->direction = DMA_FROM_DEVICE;
 	for (i = 0; i < count; i++) {
 		ctxt->sge[i].length = 0; /* in case map fails */
 		if (!frmr) {
+			BUG_ON(0 == virt_to_page(vec[i].iov_base));
+			off = (unsigned long)vec[i].iov_base & ~PAGE_MASK;
 			ctxt->sge[i].addr =
-				ib_dma_map_single(xprt->sc_cm_id->device,
-						  vec[i].iov_base,
-						  vec[i].iov_len,
-						  DMA_FROM_DEVICE);
+				ib_dma_map_page(xprt->sc_cm_id->device,
+						virt_to_page(vec[i].iov_base),
+						off,
+						vec[i].iov_len,
+						DMA_FROM_DEVICE);
 			if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 						 ctxt->sge[i].addr))
 				return -EINVAL;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index b15e1eb..d4f5e0e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -70,8 +70,8 @@
  * on extra page for the RPCRMDA header.
  */
 static int fast_reg_xdr(struct svcxprt_rdma *xprt,
-		 struct xdr_buf *xdr,
-		 struct svc_rdma_req_map *vec)
+			struct xdr_buf *xdr,
+			struct svc_rdma_req_map *vec)
 {
 	int sge_no;
 	u32 sge_bytes;
@@ -96,21 +96,25 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
 	vec->count = 2;
 	sge_no++;
 
-	/* Build the FRMR */
+	/* Map the XDR head */
 	frmr->kva = frva;
 	frmr->direction = DMA_TO_DEVICE;
 	frmr->access_flags = 0;
 	frmr->map_len = PAGE_SIZE;
 	frmr->page_list_len = 1;
+	page_off = (unsigned long)xdr->head[0].iov_base & ~PAGE_MASK;
 	frmr->page_list->page_list[page_no] =
-		ib_dma_map_single(xprt->sc_cm_id->device,
-				  (void *)xdr->head[0].iov_base,
-				  PAGE_SIZE, DMA_TO_DEVICE);
+		ib_dma_map_page(xprt->sc_cm_id->device,
+				virt_to_page(xdr->head[0].iov_base),
+				page_off,
+				PAGE_SIZE - page_off,
+				DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 				 frmr->page_list->page_list[page_no]))
 		goto fatal_err;
 	atomic_inc(&xprt->sc_dma_used);
 
+	/* Map the XDR page list */
 	page_off = xdr->page_base;
 	page_bytes = xdr->page_len + page_off;
 	if (!page_bytes)
@@ -128,9 +132,9 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
 		page_bytes -= sge_bytes;
 
 		frmr->page_list->page_list[page_no] =
-			ib_dma_map_single(xprt->sc_cm_id->device,
-					  page_address(page),
-					  PAGE_SIZE, DMA_TO_DEVICE);
+			ib_dma_map_page(xprt->sc_cm_id->device,
+					page, page_off,
+					sge_bytes, DMA_TO_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 					 frmr->page_list->page_list[page_no]))
 			goto fatal_err;
@@ -166,8 +170,10 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
 		vec->sge[sge_no].iov_base = frva + frmr->map_len + page_off;
 
 		frmr->page_list->page_list[page_no] =
-			ib_dma_map_single(xprt->sc_cm_id->device, va, PAGE_SIZE,
-					  DMA_TO_DEVICE);
+		    ib_dma_map_page(xprt->sc_cm_id->device, virt_to_page(va),
+				    page_off,
+				    PAGE_SIZE,
+				    DMA_TO_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 					 frmr->page_list->page_list[page_no]))
 			goto fatal_err;
@@ -245,6 +251,35 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 	return 0;
 }
 
+static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
+			      struct xdr_buf *xdr,
+			      u32 xdr_off, size_t len, int dir)
+{
+	struct page *page;
+	dma_addr_t dma_addr;
+	if (xdr_off < xdr->head[0].iov_len) {
+		/* This offset is in the head */
+		xdr_off += (unsigned long)xdr->head[0].iov_base & ~PAGE_MASK;
+		page = virt_to_page(xdr->head[0].iov_base);
+	} else {
+		xdr_off -= xdr->head[0].iov_len;
+		if (xdr_off < xdr->page_len) {
+			/* This offset is in the page list */
+			page = xdr->pages[xdr_off >> PAGE_SHIFT];
+			xdr_off &= ~PAGE_MASK;
+		} else {
+			/* This offset is in the tail */
+			xdr_off -= xdr->page_len;
+			xdr_off += (unsigned long)
+				xdr->tail[0].iov_base & ~PAGE_MASK;
+			page = virt_to_page(xdr->tail[0].iov_base);
+		}
+	}
+	dma_addr = ib_dma_map_page(xprt->sc_cm_id->device, page, xdr_off,
+				   min_t(size_t, PAGE_SIZE, len), dir);
+	return dma_addr;
+}
+
 /* Assumptions:
  * - We are using FRMR
  *     - or -
@@ -293,10 +328,9 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		sge[sge_no].length = sge_bytes;
 		if (!vec->frmr) {
 			sge[sge_no].addr =
-				ib_dma_map_single(xprt->sc_cm_id->device,
-						  (void *)
-						  vec->sge[xdr_sge_no].iov_base + sge_off,
-						  sge_bytes, DMA_TO_DEVICE);
+				dma_map_xdr(xprt, &rqstp->rq_res, xdr_off,
+					    sge_bytes, DMA_TO_DEVICE);
+			xdr_off += sge_bytes;
 			if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 						 sge[sge_no].addr))
 				goto err;
@@ -494,7 +528,8 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
  * In all three cases, this function prepares the RPCRDMA header in
  * sge[0], the 'type' parameter indicates the type to place in the
  * RPCRDMA header, and the 'byte_count' field indicates how much of
- * the XDR to include in this RDMA_SEND.
+ * the XDR to include in this RDMA_SEND. NB: The offset of the payload
+ * to send is zero in the XDR.
  */
 static int send_reply(struct svcxprt_rdma *rdma,
 		      struct svc_rqst *rqstp,
@@ -536,23 +571,24 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
 	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
 	ctxt->sge[0].addr =
-		ib_dma_map_single(rdma->sc_cm_id->device, page_address(page),
-				  ctxt->sge[0].length, DMA_TO_DEVICE);
+	    ib_dma_map_page(rdma->sc_cm_id->device, page, 0,
+			    ctxt->sge[0].length, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr))
 		goto err;
 	atomic_inc(&rdma->sc_dma_used);
 
 	ctxt->direction = DMA_TO_DEVICE;
 
-	/* Determine how many of our SGE are to be transmitted */
+	/* Map the payload indicated by 'byte_count' */
 	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
+		int xdr_off = 0;
 		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
 		byte_count -= sge_bytes;
 		if (!vec->frmr) {
 			ctxt->sge[sge_no].addr =
-				ib_dma_map_single(rdma->sc_cm_id->device,
-						  vec->sge[sge_no].iov_base,
-						  sge_bytes, DMA_TO_DEVICE);
+				dma_map_xdr(rdma, &rqstp->rq_res, xdr_off,
+					    sge_bytes, DMA_TO_DEVICE);
+			xdr_off += sge_bytes;
 			if (ib_dma_mapping_error(rdma->sc_cm_id->device,
 						 ctxt->sge[sge_no].addr))
 				goto err;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index edea15a..23f90c3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -120,7 +120,7 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 		 */
 		if (ctxt->sge[i].lkey == xprt->sc_dma_lkey) {
 			atomic_dec(&xprt->sc_dma_used);
-			ib_dma_unmap_single(xprt->sc_cm_id->device,
+			ib_dma_unmap_page(xprt->sc_cm_id->device,
 					    ctxt->sge[i].addr,
 					    ctxt->sge[i].length,
 					    ctxt->direction);
@@ -502,8 +502,8 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		BUG_ON(sge_no >= xprt->sc_max_sge);
 		page = svc_rdma_get_page();
 		ctxt->pages[sge_no] = page;
-		pa = ib_dma_map_single(xprt->sc_cm_id->device,
-				     page_address(page), PAGE_SIZE,
+		pa = ib_dma_map_page(xprt->sc_cm_id->device,
+				     page, 0, PAGE_SIZE,
 				     DMA_FROM_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
 			goto err_put_ctxt;
@@ -798,8 +798,8 @@ static void frmr_unmap_dma(struct svcxprt_rdma *xprt,
 		if (ib_dma_mapping_error(frmr->mr->device, addr))
 			continue;
 		atomic_dec(&xprt->sc_dma_used);
-		ib_dma_unmap_single(frmr->mr->device, addr, PAGE_SIZE,
-				    frmr->direction);
+		ib_dma_unmap_page(frmr->mr->device, addr, PAGE_SIZE,
+				  frmr->direction);
 	}
 }
 
@@ -1274,7 +1274,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 				   atomic_read(&xprt->sc_sq_count) <
 				   xprt->sc_sq_depth);
 			if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
-				return 0;
+				return -ENOTCONN;
 			continue;
 		}
 		/* Take a transport ref for each WR posted */
@@ -1320,8 +1320,8 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
 
 	/* Prepare SGE for local address */
-	sge.addr = ib_dma_map_single(xprt->sc_cm_id->device,
-				   page_address(p), PAGE_SIZE, DMA_FROM_DEVICE);
+	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
+				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
 	if (ib_dma_mapping_error(xprt->sc_cm_id->device, sge.addr)) {
 		put_page(p);
 		return;
@@ -1348,7 +1348,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);
-		ib_dma_unmap_single(xprt->sc_cm_id->device,
+		ib_dma_unmap_page(xprt->sc_cm_id->device,
 				  sge.addr, PAGE_SIZE,
 				  DMA_FROM_DEVICE);
 		svc_rdma_put_context(ctxt, 1);

