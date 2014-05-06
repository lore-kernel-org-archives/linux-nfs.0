Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:54122 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750857AbaEFRqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2014 13:46:38 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V2 RFC 3/3] svcrdma: Sendto changes
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Date: Tue, 06 May 2014 12:46:37 -0500
Message-ID: <20140506174637.18208.61344.stgit@build.ogc.int>
In-Reply-To: <20140506174621.18208.24242.stgit@build.ogc.int>
References: <20140506174621.18208.24242.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Don't use fast-register mrs for the source of RDMA writes and sends.
Instead, use either a local dma lkey or a dma_mr lkey based on what the
device supports.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |  230 +++------------------------------
 1 files changed, 22 insertions(+), 208 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 7e024a5..49fd21a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
@@ -49,152 +50,6 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
-/* Encode an XDR as an array of IB SGE
- *
- * Assumptions:
- * - head[0] is physically contiguous.
- * - tail[0] is physically contiguous.
- * - pages[] is not physically or virtually contiguous and consists of
- *   PAGE_SIZE elements.
- *
- * Output:
- * SGE[0]              reserved for RCPRDMA header
- * SGE[1]              data from xdr->head[]
- * SGE[2..sge_count-2] data from xdr->pages[]
- * SGE[sge_count-1]    data from xdr->tail.
- *
- * The max SGE we need is the length of the XDR / pagesize + one for
- * head + one for tail + one for RPCRDMA header. Since RPCSVC_MAXPAGES
- * reserves a page for both the request and the reply header, and this
- * array is only concerned with the reply we are assured that we have
- * on extra page for the RPCRMDA header.
- */
-static int fast_reg_xdr(struct svcxprt_rdma *xprt,
-			struct xdr_buf *xdr,
-			struct svc_rdma_req_map *vec)
-{
-	int sge_no;
-	u32 sge_bytes;
-	u32 page_bytes;
-	u32 page_off;
-	int page_no = 0;
-	u8 *frva;
-	struct svc_rdma_fastreg_mr *frmr;
-
-	frmr = svc_rdma_get_frmr(xprt);
-	if (IS_ERR(frmr))
-		return -ENOMEM;
-	vec->frmr = frmr;
-
-	/* Skip the RPCRDMA header */
-	sge_no = 1;
-
-	/* Map the head. */
-	frva = (void *)((unsigned long)(xdr->head[0].iov_base) & PAGE_MASK);
-	vec->sge[sge_no].iov_base = xdr->head[0].iov_base;
-	vec->sge[sge_no].iov_len = xdr->head[0].iov_len;
-	vec->count = 2;
-	sge_no++;
-
-	/* Map the XDR head */
-	frmr->kva = frva;
-	frmr->direction = DMA_TO_DEVICE;
-	frmr->access_flags = 0;
-	frmr->map_len = PAGE_SIZE;
-	frmr->page_list_len = 1;
-	page_off = (unsigned long)xdr->head[0].iov_base & ~PAGE_MASK;
-	frmr->page_list->page_list[page_no] =
-		ib_dma_map_page(xprt->sc_cm_id->device,
-				virt_to_page(xdr->head[0].iov_base),
-				page_off,
-				PAGE_SIZE - page_off,
-				DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(xprt->sc_cm_id->device,
-				 frmr->page_list->page_list[page_no]))
-		goto fatal_err;
-	atomic_inc(&xprt->sc_dma_used);
-
-	/* Map the XDR page list */
-	page_off = xdr->page_base;
-	page_bytes = xdr->page_len + page_off;
-	if (!page_bytes)
-		goto encode_tail;
-
-	/* Map the pages */
-	vec->sge[sge_no].iov_base = frva + frmr->map_len + page_off;
-	vec->sge[sge_no].iov_len = page_bytes;
-	sge_no++;
-	while (page_bytes) {
-		struct page *page;
-
-		page = xdr->pages[page_no++];
-		sge_bytes = min_t(u32, page_bytes, (PAGE_SIZE - page_off));
-		page_bytes -= sge_bytes;
-
-		frmr->page_list->page_list[page_no] =
-			ib_dma_map_page(xprt->sc_cm_id->device,
-					page, page_off,
-					sge_bytes, DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
-					 frmr->page_list->page_list[page_no]))
-			goto fatal_err;
-
-		atomic_inc(&xprt->sc_dma_used);
-		page_off = 0; /* reset for next time through loop */
-		frmr->map_len += PAGE_SIZE;
-		frmr->page_list_len++;
-	}
-	vec->count++;
-
- encode_tail:
-	/* Map tail */
-	if (0 == xdr->tail[0].iov_len)
-		goto done;
-
-	vec->count++;
-	vec->sge[sge_no].iov_len = xdr->tail[0].iov_len;
-
-	if (((unsigned long)xdr->tail[0].iov_base & PAGE_MASK) ==
-	    ((unsigned long)xdr->head[0].iov_base & PAGE_MASK)) {
-		/*
-		 * If head and tail use the same page, we don't need
-		 * to map it again.
-		 */
-		vec->sge[sge_no].iov_base = xdr->tail[0].iov_base;
-	} else {
-		void *va;
-
-		/* Map another page for the tail */
-		page_off = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
-		va = (void *)((unsigned long)xdr->tail[0].iov_base & PAGE_MASK);
-		vec->sge[sge_no].iov_base = frva + frmr->map_len + page_off;
-
-		frmr->page_list->page_list[page_no] =
-		    ib_dma_map_page(xprt->sc_cm_id->device, virt_to_page(va),
-				    page_off,
-				    PAGE_SIZE,
-				    DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
-					 frmr->page_list->page_list[page_no]))
-			goto fatal_err;
-		atomic_inc(&xprt->sc_dma_used);
-		frmr->map_len += PAGE_SIZE;
-		frmr->page_list_len++;
-	}
-
- done:
-	if (svc_rdma_fastreg(xprt, frmr))
-		goto fatal_err;
-
-	return 0;
-
- fatal_err:
-	printk("svcrdma: Error fast registering memory for xprt %p\n", xprt);
-	vec->frmr = NULL;
-	svc_rdma_put_frmr(xprt, frmr);
-	return -EIO;
-}
-
 static int map_xdr(struct svcxprt_rdma *xprt,
 		   struct xdr_buf *xdr,
 		   struct svc_rdma_req_map *vec)
@@ -208,9 +63,6 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 	BUG_ON(xdr->len !=
 	       (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len));
 
-	if (xprt->sc_frmr_pg_list_len)
-		return fast_reg_xdr(xprt, xdr, vec);
-
 	/* Skip the first sge, this is for the RPCRDMA header */
 	sge_no = 1;
 
@@ -282,8 +134,6 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
 }
 
 /* Assumptions:
- * - We are using FRMR
- *     - or -
  * - The specified write_len can be represented in sc_max_sge * PAGE_SIZE
  */
 static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
@@ -327,23 +177,16 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		sge_bytes = min_t(size_t,
 			  bc, vec->sge[xdr_sge_no].iov_len-sge_off);
 		sge[sge_no].length = sge_bytes;
-		if (!vec->frmr) {
-			sge[sge_no].addr =
-				dma_map_xdr(xprt, &rqstp->rq_res, xdr_off,
-					    sge_bytes, DMA_TO_DEVICE);
-			xdr_off += sge_bytes;
-			if (ib_dma_mapping_error(xprt->sc_cm_id->device,
-						 sge[sge_no].addr))
-				goto err;
-			atomic_inc(&xprt->sc_dma_used);
-			sge[sge_no].lkey = xprt->sc_dma_lkey;
-		} else {
-			sge[sge_no].addr = (unsigned long)
-				vec->sge[xdr_sge_no].iov_base + sge_off;
-			sge[sge_no].lkey = vec->frmr->mr->lkey;
-		}
+		sge[sge_no].addr =
+			dma_map_xdr(xprt, &rqstp->rq_res, xdr_off,
+				    sge_bytes, DMA_TO_DEVICE);
+		xdr_off += sge_bytes;
+		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
+					 sge[sge_no].addr))
+			goto err;
+		atomic_inc(&xprt->sc_dma_used);
+		sge[sge_no].lkey = xprt->sc_dma_lkey;
 		ctxt->count++;
-		ctxt->frmr = vec->frmr;
 		sge_off = 0;
 		sge_no++;
 		xdr_sge_no++;
@@ -369,7 +212,6 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	return 0;
  err:
 	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_frmr(xprt, vec->frmr);
 	svc_rdma_put_context(ctxt, 0);
 	/* Fatal error, close transport */
 	return -EIO;
@@ -397,10 +239,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[1];
 
-	if (vec->frmr)
-		max_write = vec->frmr->map_len;
-	else
-		max_write = xprt->sc_max_sge * PAGE_SIZE;
+	max_write = xprt->sc_max_sge * PAGE_SIZE;
 
 	/* Write chunks start at the pagelist */
 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
@@ -472,10 +311,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[2];
 
-	if (vec->frmr)
-		max_write = vec->frmr->map_len;
-	else
-		max_write = xprt->sc_max_sge * PAGE_SIZE;
+	max_write = xprt->sc_max_sge * PAGE_SIZE;
 
 	/* xdr offset starts at RPC message */
 	nchunks = ntohl(arg_ary->wc_nchunks);
@@ -545,7 +381,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		      int byte_count)
 {
 	struct ib_send_wr send_wr;
-	struct ib_send_wr inv_wr;
 	int sge_no;
 	int sge_bytes;
 	int page_no;
@@ -559,7 +394,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		       "svcrdma: could not post a receive buffer, err=%d."
 		       "Closing transport %p.\n", ret, rdma);
 		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
-		svc_rdma_put_frmr(rdma, vec->frmr);
 		svc_rdma_put_context(ctxt, 0);
 		return -ENOTCONN;
 	}
@@ -567,11 +401,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	/* Prepare the context */
 	ctxt->pages[0] = page;
 	ctxt->count = 1;
-	ctxt->frmr = vec->frmr;
-	if (vec->frmr)
-		set_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
-	else
-		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
 
 	/* Prepare the SGE for the RPCRDMA Header */
 	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
@@ -590,21 +419,15 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		int xdr_off = 0;
 		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
 		byte_count -= sge_bytes;
-		if (!vec->frmr) {
-			ctxt->sge[sge_no].addr =
-				dma_map_xdr(rdma, &rqstp->rq_res, xdr_off,
-					    sge_bytes, DMA_TO_DEVICE);
-			xdr_off += sge_bytes;
-			if (ib_dma_mapping_error(rdma->sc_cm_id->device,
-						 ctxt->sge[sge_no].addr))
-				goto err;
-			atomic_inc(&rdma->sc_dma_used);
-			ctxt->sge[sge_no].lkey = rdma->sc_dma_lkey;
-		} else {
-			ctxt->sge[sge_no].addr = (unsigned long)
-				vec->sge[sge_no].iov_base;
-			ctxt->sge[sge_no].lkey = vec->frmr->mr->lkey;
-		}
+		ctxt->sge[sge_no].addr =
+			dma_map_xdr(rdma, &rqstp->rq_res, xdr_off,
+				    sge_bytes, DMA_TO_DEVICE);
+		xdr_off += sge_bytes;
+		if (ib_dma_mapping_error(rdma->sc_cm_id->device,
+					 ctxt->sge[sge_no].addr))
+			goto err;
+		atomic_inc(&rdma->sc_dma_used);
+		ctxt->sge[sge_no].lkey = rdma->sc_dma_lkey;
 		ctxt->sge[sge_no].length = sge_bytes;
 	}
 	BUG_ON(byte_count != 0);
@@ -627,6 +450,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 			ctxt->sge[page_no+1].length = 0;
 	}
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
+
 	BUG_ON(sge_no > rdma->sc_max_sge);
 	memset(&send_wr, 0, sizeof send_wr);
 	ctxt->wr_op = IB_WR_SEND;
@@ -635,15 +459,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	send_wr.num_sge = sge_no;
 	send_wr.opcode = IB_WR_SEND;
 	send_wr.send_flags =  IB_SEND_SIGNALED;
-	if (vec->frmr) {
-		/* Prepare INVALIDATE WR */
-		memset(&inv_wr, 0, sizeof inv_wr);
-		inv_wr.opcode = IB_WR_LOCAL_INV;
-		inv_wr.send_flags = IB_SEND_SIGNALED;
-		inv_wr.ex.invalidate_rkey =
-			vec->frmr->mr->lkey;
-		send_wr.next = &inv_wr;
-	}
 
 	ret = svc_rdma_send(rdma, &send_wr);
 	if (ret)
@@ -653,7 +468,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 
  err:
 	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_frmr(rdma, vec->frmr);
 	svc_rdma_put_context(ctxt, 1);
 	return -EIO;
 }

