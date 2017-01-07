Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34156 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964931AbdAGRR3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:17:29 -0500
Subject: [PATCH v1 16/22] svcrdma: Use generic RDMA R/W API in RPC Call path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:17:27 -0500
Message-ID: <20170107171727.14126.2446.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current svcrdma recvfrom code path has a lot of detail about
registration mode and the type of port (iWARP, IB, etc).

Instead, use the RDMA core's generic R/W API. This shares code with
other RDMA-enabled ULPs that manages the gory details of buffer
registration and the posting of RDMA Read Work Requests.

Some design notes:

 o Since the Read list marshaling code is being
   replaced, I took the opportunity to replace some of the C
   structure-based XDR encoding code with more portable code that
   uses pointer arithmetic. C compilers don't provide a guarantee of
   field location in structures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   13 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  477 ++++--------------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   30 --
 3 files changed, 65 insertions(+), 455 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 9866e94..95a3720 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -82,8 +82,6 @@ struct svc_rdma_op_ctxt {
 	int hdr_count;
 	struct xdr_buf arg;
 	struct ib_cqe cqe;
-	struct ib_cqe reg_cqe;
-	struct ib_cqe inv_cqe;
 	u32 byte_len;
 	u32 position;
 	struct svcxprt_rdma *xprt;
@@ -116,7 +114,6 @@ struct svcxprt_rdma {
 	struct list_head     sc_accept_q;	/* Conn. waiting accept */
 	int		     sc_ord;		/* RDMA read limit */
 	int                  sc_max_sge;
-	int                  sc_max_sge_rd;	/* max sge for read target */
 	bool		     sc_snd_w_inv;	/* OK to use Send With Invalidate */
 
 	atomic_t             sc_sq_avail;	/* SQEs ready to be consumed */
@@ -143,10 +140,6 @@ struct svcxprt_rdma {
 	struct ib_qp         *sc_qp;
 	struct ib_cq         *sc_rq_cq;
 	struct ib_cq         *sc_sq_cq;
-	int		     (*sc_reader)(struct svcxprt_rdma *,
-					  struct svc_rqst *,
-					  struct svc_rdma_op_ctxt *,
-					  int *, u32 *, u32, u32, u64, bool);
 	u32		     sc_dev_caps;	/* distilled device caps */
 	unsigned int	     sc_frmr_pg_list_len;
 	struct list_head     sc_frmr_q;
@@ -205,12 +198,6 @@ extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *rdma,
 
 /* svc_rdma_recvfrom.c */
 extern int svc_rdma_recvfrom(struct svc_rqst *);
-extern int rdma_read_chunk_lcl(struct svcxprt_rdma *, struct svc_rqst *,
-			       struct svc_rdma_op_ctxt *, int *, u32 *,
-			       u32, u32, u64, bool);
-extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
-				struct svc_rdma_op_ctxt *, int *, u32 *,
-				u32, u32, u64, bool);
 
 /* svc_rdma_rw.c */
 extern void svc_rdma_destroy_rw_ctxts(struct svcxprt_rdma *rdma);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index c9ea2e9..f99f0d7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2016 Oracle. All rights reserved.
  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
@@ -40,6 +41,39 @@
  * Author: Tom Tucker <tom@opengridcomputing.com>
  */
 
+/* Operation
+ *
+ * The main entry point is svc_rdma_recvfrom. This is called by the
+ * RPC server when the transport indicates there is incoming data to
+ * be read. This occurs when each RDMA Receive completes.
+ *
+ * The passed-in svc_rqst contains a struct xdr_buf which will hold
+ * the incoming XDR-encoded RPC Call message, and a set of pages that
+ * can be used as Read sink buffers.
+ *
+ * Short messages are moved directly into the xdr_buf and the RPC Call
+ * is ready to be processed by the Upper Layer.
+ *
+ * When an incoming message has Read chunks, recvfrom must post RDMA
+ * Reads to pull the chunk payloads to the server. recvfrom returns,
+ * and the svc_rqst is recycled, before the Read I/O is complete.  A
+ * second completion and svc_xprt_enqueue are done after the chunk
+ * payloads have become available on the server.
+ *
+ * Page Management
+ *
+ * Pages under I/O must be removed from the svc_rqst before recvfrom
+ * returns.
+ *
+ * The logic here depends on Send Queue and completion ordering. Pages
+ * under I/O are moved from the provided svc_rqst to an svc_rdma_op_ctxt.
+ * The final RDMA Read completion points to this op_ctxt, which is
+ * enqueued on the svc_xprt during that completion.
+ *
+ * A second call to svc_rdma_recvfrom is done to perform final assembly
+ * of the RPC Call message, using the pages in the op_ctxt.
+ */
+
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/spinlock.h>
@@ -115,410 +149,6 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	rqstp->rq_arg.tail[0].iov_len = 0;
 }
 
-/* Issue an RDMA_READ using the local lkey to map the data sink */
-int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
-			struct svc_rqst *rqstp,
-			struct svc_rdma_op_ctxt *head,
-			int *page_no,
-			u32 *page_offset,
-			u32 rs_handle,
-			u32 rs_length,
-			u64 rs_offset,
-			bool last)
-{
-	struct ib_rdma_wr read_wr;
-	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
-	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
-	int ret, read, pno;
-	u32 pg_off = *page_offset;
-	u32 pg_no = *page_no;
-
-	ctxt->direction = DMA_FROM_DEVICE;
-	ctxt->read_hdr = head;
-	pages_needed = min_t(int, pages_needed, xprt->sc_max_sge_rd);
-	read = min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
-		     rs_length);
-
-	for (pno = 0; pno < pages_needed; pno++) {
-		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
-
-		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
-		head->arg.page_len += len;
-
-		head->arg.len += len;
-		if (!pg_off)
-			head->count++;
-		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
-		rqstp->rq_next_page = rqstp->rq_respages + 1;
-		ctxt->sge[pno].addr =
-			ib_dma_map_page(xprt->sc_cm_id->device,
-					head->arg.pages[pg_no], pg_off,
-					PAGE_SIZE - pg_off,
-					DMA_FROM_DEVICE);
-		ret = ib_dma_mapping_error(xprt->sc_cm_id->device,
-					   ctxt->sge[pno].addr);
-		if (ret)
-			goto err;
-		svc_rdma_count_mappings(xprt, ctxt);
-
-		ctxt->sge[pno].lkey = xprt->sc_pd->local_dma_lkey;
-		ctxt->sge[pno].length = len;
-		ctxt->count++;
-
-		/* adjust offset and wrap to next page if needed */
-		pg_off += len;
-		if (pg_off == PAGE_SIZE) {
-			pg_off = 0;
-			pg_no++;
-		}
-		rs_length -= len;
-	}
-
-	if (last && rs_length == 0)
-		set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-	else
-		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-
-	memset(&read_wr, 0, sizeof(read_wr));
-	ctxt->cqe.done = svc_rdma_wc_read;
-	read_wr.wr.wr_cqe = &ctxt->cqe;
-	read_wr.wr.opcode = IB_WR_RDMA_READ;
-	read_wr.wr.send_flags = IB_SEND_SIGNALED;
-	read_wr.rkey = rs_handle;
-	read_wr.remote_addr = rs_offset;
-	read_wr.wr.sg_list = ctxt->sge;
-	read_wr.wr.num_sge = pages_needed;
-
-	ret = svc_rdma_send(xprt, &read_wr.wr);
-	if (ret) {
-		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
-		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-		goto err;
-	}
-
-	/* return current location in page array */
-	*page_no = pg_no;
-	*page_offset = pg_off;
-	ret = read;
-	atomic_inc(&rdma_stat_read);
-	return ret;
- err:
-	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_context(ctxt, 0);
-	return ret;
-}
-
-/* Issue an RDMA_READ using an FRMR to map the data sink */
-int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
-			 struct svc_rqst *rqstp,
-			 struct svc_rdma_op_ctxt *head,
-			 int *page_no,
-			 u32 *page_offset,
-			 u32 rs_handle,
-			 u32 rs_length,
-			 u64 rs_offset,
-			 bool last)
-{
-	struct ib_rdma_wr read_wr;
-	struct ib_send_wr inv_wr;
-	struct ib_reg_wr reg_wr;
-	u8 key;
-	int nents = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
-	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
-	struct svc_rdma_fastreg_mr *frmr = svc_rdma_get_frmr(xprt);
-	int ret, read, pno, dma_nents, n;
-	u32 pg_off = *page_offset;
-	u32 pg_no = *page_no;
-
-	if (IS_ERR(frmr))
-		return -ENOMEM;
-
-	ctxt->direction = DMA_FROM_DEVICE;
-	ctxt->frmr = frmr;
-	nents = min_t(unsigned int, nents, xprt->sc_frmr_pg_list_len);
-	read = min_t(int, (nents << PAGE_SHIFT) - *page_offset, rs_length);
-
-	frmr->direction = DMA_FROM_DEVICE;
-	frmr->access_flags = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
-	frmr->sg_nents = nents;
-
-	for (pno = 0; pno < nents; pno++) {
-		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
-
-		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
-		head->arg.page_len += len;
-		head->arg.len += len;
-		if (!pg_off)
-			head->count++;
-
-		sg_set_page(&frmr->sg[pno], rqstp->rq_arg.pages[pg_no],
-			    len, pg_off);
-
-		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
-		rqstp->rq_next_page = rqstp->rq_respages + 1;
-
-		/* adjust offset and wrap to next page if needed */
-		pg_off += len;
-		if (pg_off == PAGE_SIZE) {
-			pg_off = 0;
-			pg_no++;
-		}
-		rs_length -= len;
-	}
-
-	if (last && rs_length == 0)
-		set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-	else
-		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
-
-	dma_nents = ib_dma_map_sg(xprt->sc_cm_id->device,
-				  frmr->sg, frmr->sg_nents,
-				  frmr->direction);
-	if (!dma_nents) {
-		pr_err("svcrdma: failed to dma map sg %p\n",
-		       frmr->sg);
-		return -ENOMEM;
-	}
-
-	n = ib_map_mr_sg(frmr->mr, frmr->sg, frmr->sg_nents, NULL, PAGE_SIZE);
-	if (unlikely(n != frmr->sg_nents)) {
-		pr_err("svcrdma: failed to map mr %p (%d/%d elements)\n",
-		       frmr->mr, n, frmr->sg_nents);
-		return n < 0 ? n : -EINVAL;
-	}
-
-	/* Bump the key */
-	key = (u8)(frmr->mr->lkey & 0x000000FF);
-	ib_update_fast_reg_key(frmr->mr, ++key);
-
-	ctxt->sge[0].addr = frmr->mr->iova;
-	ctxt->sge[0].lkey = frmr->mr->lkey;
-	ctxt->sge[0].length = frmr->mr->length;
-	ctxt->count = 1;
-	ctxt->read_hdr = head;
-
-	/* Prepare REG WR */
-	ctxt->reg_cqe.done = svc_rdma_wc_reg;
-	reg_wr.wr.wr_cqe = &ctxt->reg_cqe;
-	reg_wr.wr.opcode = IB_WR_REG_MR;
-	reg_wr.wr.send_flags = IB_SEND_SIGNALED;
-	reg_wr.wr.num_sge = 0;
-	reg_wr.mr = frmr->mr;
-	reg_wr.key = frmr->mr->lkey;
-	reg_wr.access = frmr->access_flags;
-	reg_wr.wr.next = &read_wr.wr;
-
-	/* Prepare RDMA_READ */
-	memset(&read_wr, 0, sizeof(read_wr));
-	ctxt->cqe.done = svc_rdma_wc_read;
-	read_wr.wr.wr_cqe = &ctxt->cqe;
-	read_wr.wr.send_flags = IB_SEND_SIGNALED;
-	read_wr.rkey = rs_handle;
-	read_wr.remote_addr = rs_offset;
-	read_wr.wr.sg_list = ctxt->sge;
-	read_wr.wr.num_sge = 1;
-	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_READ_W_INV) {
-		read_wr.wr.opcode = IB_WR_RDMA_READ_WITH_INV;
-		read_wr.wr.ex.invalidate_rkey = ctxt->frmr->mr->lkey;
-	} else {
-		read_wr.wr.opcode = IB_WR_RDMA_READ;
-		read_wr.wr.next = &inv_wr;
-		/* Prepare invalidate */
-		memset(&inv_wr, 0, sizeof(inv_wr));
-		ctxt->inv_cqe.done = svc_rdma_wc_inv;
-		inv_wr.wr_cqe = &ctxt->inv_cqe;
-		inv_wr.opcode = IB_WR_LOCAL_INV;
-		inv_wr.send_flags = IB_SEND_SIGNALED | IB_SEND_FENCE;
-		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
-	}
-
-	/* Post the chain */
-	ret = svc_rdma_send(xprt, &reg_wr.wr);
-	if (ret) {
-		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
-		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-		goto err;
-	}
-
-	/* return current location in page array */
-	*page_no = pg_no;
-	*page_offset = pg_off;
-	ret = read;
-	atomic_inc(&rdma_stat_read);
-	return ret;
- err:
-	ib_dma_unmap_sg(xprt->sc_cm_id->device,
-			frmr->sg, frmr->sg_nents, frmr->direction);
-	svc_rdma_put_context(ctxt, 0);
-	svc_rdma_put_frmr(xprt, frmr);
-	return ret;
-}
-
-static unsigned int
-rdma_rcl_chunk_count(struct rpcrdma_read_chunk *ch)
-{
-	unsigned int count;
-
-	for (count = 0; ch->rc_discrim != xdr_zero; ch++)
-		count++;
-	return count;
-}
-
-/* If there was additional inline content, append it to the end of arg.pages.
- * Tail copy has to be done after the reader function has determined how many
- * pages are needed for RDMA READ.
- */
-static int
-rdma_copy_tail(struct svc_rqst *rqstp, struct svc_rdma_op_ctxt *head,
-	       u32 position, u32 byte_count, u32 page_offset, int page_no)
-{
-	char *srcp, *destp;
-
-	srcp = head->arg.head[0].iov_base + position;
-	byte_count = head->arg.head[0].iov_len - position;
-	if (byte_count > PAGE_SIZE) {
-		dprintk("svcrdma: large tail unsupported\n");
-		return 0;
-	}
-
-	/* Fit as much of the tail on the current page as possible */
-	if (page_offset != PAGE_SIZE) {
-		destp = page_address(rqstp->rq_arg.pages[page_no]);
-		destp += page_offset;
-		while (byte_count--) {
-			*destp++ = *srcp++;
-			page_offset++;
-			if (page_offset == PAGE_SIZE && byte_count)
-				goto more;
-		}
-		goto done;
-	}
-
-more:
-	/* Fit the rest on the next page */
-	page_no++;
-	destp = page_address(rqstp->rq_arg.pages[page_no]);
-	while (byte_count--)
-		*destp++ = *srcp++;
-
-	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
-
-done:
-	byte_count = head->arg.head[0].iov_len - position;
-	head->arg.page_len += byte_count;
-	head->arg.len += byte_count;
-	head->arg.buflen += byte_count;
-	return 1;
-}
-
-/* Returns the address of the first read chunk or <nul> if no read chunk
- * is present
- */
-static struct rpcrdma_read_chunk *
-svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
-{
-	struct rpcrdma_read_chunk *ch =
-		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
-
-	if (ch->rc_discrim == xdr_zero)
-		return NULL;
-	return ch;
-}
-
-static int rdma_read_chunks(struct svcxprt_rdma *xprt,
-			    struct rpcrdma_msg *rmsgp,
-			    struct svc_rqst *rqstp,
-			    struct svc_rdma_op_ctxt *head)
-{
-	int page_no, ret;
-	struct rpcrdma_read_chunk *ch;
-	u32 handle, page_offset, byte_count;
-	u32 position;
-	u64 rs_offset;
-	bool last;
-
-	/* If no read list is present, return 0 */
-	ch = svc_rdma_get_read_chunk(rmsgp);
-	if (!ch)
-		return 0;
-
-	if (rdma_rcl_chunk_count(ch) > RPCSVC_MAXPAGES)
-		return -EINVAL;
-
-	/* The request is completed when the RDMA_READs complete. The
-	 * head context keeps all the pages that comprise the
-	 * request.
-	 */
-	head->arg.head[0] = rqstp->rq_arg.head[0];
-	head->arg.tail[0] = rqstp->rq_arg.tail[0];
-	head->hdr_count = head->count;
-	head->arg.page_base = 0;
-	head->arg.page_len = 0;
-	head->arg.len = rqstp->rq_arg.len;
-	head->arg.buflen = rqstp->rq_arg.buflen;
-
-	/* RDMA_NOMSG: RDMA READ data should land just after RDMA RECV data */
-	position = be32_to_cpu(ch->rc_position);
-	if (position == 0) {
-		head->arg.pages = &head->pages[0];
-		page_offset = head->byte_len;
-	} else {
-		head->arg.pages = &head->pages[head->count];
-		page_offset = 0;
-	}
-
-	ret = 0;
-	page_no = 0;
-	for (; ch->rc_discrim != xdr_zero; ch++) {
-		if (be32_to_cpu(ch->rc_position) != position)
-			goto err;
-
-		handle = be32_to_cpu(ch->rc_target.rs_handle),
-		byte_count = be32_to_cpu(ch->rc_target.rs_length);
-		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
-				 &rs_offset);
-
-		while (byte_count > 0) {
-			last = (ch + 1)->rc_discrim == xdr_zero;
-			ret = xprt->sc_reader(xprt, rqstp, head,
-					      &page_no, &page_offset,
-					      handle, byte_count,
-					      rs_offset, last);
-			if (ret < 0)
-				goto err;
-			byte_count -= ret;
-			rs_offset += ret;
-			head->arg.buflen += ret;
-		}
-	}
-
-	/* Read list may need XDR round-up (see RFC 5666, s. 3.7) */
-	if (page_offset & 3) {
-		u32 pad = 4 - (page_offset & 3);
-
-		head->arg.tail[0].iov_len += pad;
-		head->arg.len += pad;
-		head->arg.buflen += pad;
-		page_offset += pad;
-	}
-
-	ret = 1;
-	if (position && position < head->arg.head[0].iov_len)
-		ret = rdma_copy_tail(rqstp, head, position,
-				     byte_count, page_offset, page_no);
-	head->arg.head[0].iov_len = position;
-	head->position = position;
-
- err:
-	/* Detach arg pages. svc_recv will replenish them */
-	for (page_no = 0;
-	     &rqstp->rq_pages[page_no] < rqstp->rq_respages; page_no++)
-		rqstp->rq_pages[page_no] = NULL;
-
-	return ret;
-}
-
 static void rdma_read_complete(struct svc_rqst *rqstp,
 			       struct svc_rdma_op_ctxt *head)
 {
@@ -594,10 +224,18 @@ static bool svc_rdma_is_backchannel_reply(struct svc_xprt *xprt,
 	return true;
 }
 
-/*
+/**
+ * svc_rdma_recvfrom - xprt switch API: Receive an RPC call
+ * @rqstp: request structure into which to receive the call
+ *
  * Set up the rqstp thread context to point to the RQ buffer. If
- * necessary, pull additional data from the client with an RDMA_READ
+ * necessary, pull additional data from the client with an RDMA Read
  * request.
+ *
+ * Returns the number of bytes in the RPC call on success; returns
+ * zero if the incoming RPC call is somehow invalid; or a negative
+ * errno is returned if a problem with the underlying xprt occurred
+ * while receiving the RPC.
  */
 int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 {
@@ -605,11 +243,12 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	struct svcxprt_rdma *rdma_xprt =
 		container_of(xprt, struct svcxprt_rdma, sc_xprt);
 	struct svc_rdma_op_ctxt *ctxt = NULL;
-	struct rpcrdma_msg *rmsgp;
-	int ret = 0;
+	__be32 *rdma_argp, *ch;
+	int ret;
 
 	dprintk("svcrdma: rqstp=%p\n", rqstp);
 
+	ret = 0;
 	spin_lock(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
 		ctxt = list_first_entry(&rdma_xprt->sc_read_complete_q,
@@ -638,6 +277,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 			goto defer;
 		goto out;
 	}
+
 	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p\n",
 		ctxt, rdma_xprt, rqstp);
 	atomic_inc(&rdma_stat_recv);
@@ -646,7 +286,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	rdma_build_arg_xdr(rqstp, ctxt, ctxt->byte_len);
 
 	/* Decode the RDMA header. */
-	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
+	rdma_argp = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	ret = svc_rdma_xdr_decode_req(&rqstp->rq_arg);
 	if (ret < 0)
 		goto out_err;
@@ -654,9 +294,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		goto out_drop;
 	rqstp->rq_xprt_hlen = ret;
 
-	if (svc_rdma_is_backchannel_reply(xprt, (__be32 *)rmsgp)) {
-		ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt,
-					       (__be32 *)rmsgp,
+	if (svc_rdma_is_backchannel_reply(xprt, rdma_argp)) {
+		ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, rdma_argp,
 					       &rqstp->rq_arg);
 		svc_rdma_put_context(ctxt, 0);
 		if (ret)
@@ -664,13 +303,17 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		return ret;
 	}
 
-	/* Read read-list data. */
-	ret = rdma_read_chunks(rdma_xprt, rmsgp, rqstp, ctxt);
+	/* check for Read list */
+	ch = rdma_argp + rpcrdma_fixed_maxsz;
+	if (*ch == xdr_zero)
+		goto complete;
+
+	ret = svc_rdma_recv_read_list(rdma_xprt, ch, ctxt, rqstp);
 	if (ret > 0) {
-		/* read-list posted, defer until data received from client. */
+		/* Read list posted, defer until data received from client. */
 		goto defer;
 	} else if (ret < 0) {
-		/* Post of read-list failed, free context. */
+		/* Post of Read list failed, free context. */
 		svc_rdma_put_context(ctxt, 1);
 		return 0;
 	}
@@ -691,7 +334,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	return ret;
 
 out_err:
-	svc_rdma_send_error(rdma_xprt, (__be32 *)rmsgp, ret);
+	svc_rdma_send_error(rdma_xprt, rdma_argp, ret);
 	svc_rdma_put_context(ctxt, 0);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 01119ba..bb0281f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -851,28 +851,13 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 	}
 }
 
-static unsigned int svc_rdma_read_sqes_per_credit(struct svcxprt_rdma *newxprt)
-{
-	struct ib_device_attr *attrs = &newxprt->sc_cm_id->device->attrs;
-
-	if (!(attrs->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
-		return DIV_ROUND_UP(RPCSVC_MAXPAGES, newxprt->sc_max_sge_rd);
-
-	/* FRWR: reg, read, inv */
-	return DIV_ROUND_UP(RPCSVC_MAXPAGES,
-			    attrs->max_fast_reg_page_list_len) * 3;
-}
-
+/* This is the number of RDMA Send operations that can be
+ * outstanding at one time. Forechannel and backchannel
+ * Sends are included.
+ */
 static unsigned int svc_rdma_sq_depth(struct svcxprt_rdma *newxprt)
 {
-	unsigned int sqes_per_credit;
-
-	sqes_per_credit = svc_rdma_read_sqes_per_credit(newxprt);
-
-	/* RDMA Sends per credit */
-	sqes_per_credit += 1;
-
-	return sqes_per_credit * newxprt->sc_rq_depth;
+	return newxprt->sc_rq_depth;
 }
 
 /* Estimate ctxs per credit assuming a full Read chunk payload
@@ -951,8 +936,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 * capabilities of this particular device */
 	newxprt->sc_max_sge = min((size_t)dev->attrs.max_sge,
 				  (size_t)RPCSVC_MAXPAGES);
-	newxprt->sc_max_sge_rd = min_t(size_t, dev->attrs.max_sge_rd,
-				       RPCSVC_MAXPAGES);
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
 	newxprt->sc_max_requests = min_t(u32, dev->attrs.max_qp_wr,
 					 svcrdma_max_requests);
@@ -1043,12 +1026,10 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 * NB:	iWARP requires remote write access for the data sink
 	 *	of an RDMA_READ. IB does not.
 	 */
-	newxprt->sc_reader = rdma_read_chunk_lcl;
 	if (dev->attrs.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
 		newxprt->sc_frmr_pg_list_len =
 			dev->attrs.max_fast_reg_page_list_len;
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
-		newxprt->sc_reader = rdma_read_chunk_frmr;
 	} else
 		newxprt->sc_snd_w_inv = false;
 
@@ -1101,7 +1082,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	sap = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
 	dprintk("    remote address  : %pIS:%u\n", sap, rpc_get_port(sap));
 	dprintk("    max_sge         : %d\n", newxprt->sc_max_sge);
-	dprintk("    max_sge_rd      : %d\n", newxprt->sc_max_sge_rd);
 	dprintk("    sq_depth        : %d\n", newxprt->sc_sq_depth);
 	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
 	dprintk("    ord             : %d\n", newxprt->sc_ord);

