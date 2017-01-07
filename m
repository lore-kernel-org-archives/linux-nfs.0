Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33972 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941503AbdAGRQd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:16:33 -0500
Subject: [PATCH v1 09/22] svcrdma: Use rdma_rw API in RPC reply path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:16:30 -0500
Message-ID: <20170107171630.14126.97768.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current svcrdma sendto code path posts one RDMA Write WR at a
time. Each of these Writes typically carries a small number of pages
(for instance, up to 30 pages for mlx4 devices). That means a 1MB
NFS READ reply requires 9 ib_post_send() calls for the Write WRs,
and one for the Send WR carrying the actual RPC Reply message.

Instead, use the new rdma_rw API. This gives two main benefits:

1. All Write WRs for one RDMA segment are posted in a single chain.
Just one doorbell for each RPC's Write chunk data.

2. The Write path can now use FRWR to register the Write buffers.
If the device's maximum page list depth is large, this means a
single Write WR is needed for each RPC's Write chunk data.

But also, the details of Write WR chain construction and memory
registration are taken care of elsewhere. svcrdma can focus on
RPC-over-RDMA protocol details.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   12 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   39 --
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  675 +++++++++++++-----------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   52 +-
 4 files changed, 336 insertions(+), 442 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index e6eca34..765f91b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -85,6 +85,7 @@ struct svc_rdma_op_ctxt {
 	enum dma_data_direction direction;
 	int count;
 	unsigned int mapped_sges;
+	struct ib_send_wr send_wr;
 	struct ib_sge sge[RPCSVC_MAXPAGES];
 	struct page *pages[RPCSVC_MAXPAGES];
 };
@@ -145,6 +146,8 @@ struct svcxprt_rdma {
 	u32		     sc_max_bc_requests;/* Backward credits */
 	int                  sc_max_req_size;	/* Size of each RQ WR buf */
 	u8		     sc_port_num;
+	struct ib_device     *sc_device;
+	u32		     sc_lkey;
 
 	struct ib_pd         *sc_pd;
 
@@ -211,10 +214,6 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
 				     enum rpcrdma_errcode, __be32 *);
-extern void svc_rdma_old_encode_write_list(struct rpcrdma_msg *, int);
-extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
-extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
-					    __be32, __be64, u32);
 extern void svc_rdma_xdr_encode_write_list(__be32 *rdma_resp, __be32 *wr_ch,
 					   unsigned int consumed);
 extern void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
@@ -249,6 +248,11 @@ extern int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
+extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
+				  struct svc_rdma_op_ctxt *ctxt,
+				  __be32 *rdma_resp, unsigned int len);
+extern void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt,
+				   int num_sge);
 extern int svc_rdma_sendto(struct svc_rqst *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 01cb4e1..6ba2fb6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -217,45 +217,6 @@ unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp)
 	return (unsigned long)p - (unsigned long)rdma_resp;
 }
 
-void svc_rdma_old_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
-{
-	struct rpcrdma_write_array *ary;
-
-	/* no read-list */
-	rmsgp->rm_body.rm_chunks[0] = xdr_zero;
-
-	/* write-array discrim */
-	ary = (struct rpcrdma_write_array *)
-		&rmsgp->rm_body.rm_chunks[1];
-	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = cpu_to_be32(chunks);
-
-	/* write-list terminator */
-	ary->wc_array[chunks].wc_target.rs_handle = xdr_zero;
-
-	/* reply-array discriminator */
-	ary->wc_array[chunks].wc_target.rs_length = xdr_zero;
-}
-
-void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *ary,
-				 int chunks)
-{
-	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = cpu_to_be32(chunks);
-}
-
-void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
-				     int chunk_no,
-				     __be32 rs_handle,
-				     __be64 rs_offset,
-				     u32 write_len)
-{
-	struct rpcrdma_segment *seg = &ary->wc_array[chunk_no].wc_target;
-	seg->rs_handle = rs_handle;
-	seg->rs_offset = rs_offset;
-	seg->rs_length = cpu_to_be32(write_len);
-}
-
 /* Write chunk is copied from Call header to Reply header. Length
  * fields are updated to reflect number of bytes consumed in each
  * segment.
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index ba43f75..555daef 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2016 Oracle. All rights reserved.
  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
@@ -40,6 +41,61 @@
  * Author: Tom Tucker <tom@opengridcomputing.com>
  */
 
+/* Operation
+ *
+ * The main entry point is svc_rdma_sendto. This is called by the
+ * RPC server when an RPC Reply is ready to be transmitted to a client.
+ *
+ * The passed-in svc_rqst contains a struct xdr_buf which holds the
+ * XDR-encoded RPC Reply message. sendto must construct the RPC-over-RDMA
+ * transport header, post all Write WRs needed for this message, then post
+ * a Send WR conveying the transport header and the RPC message itself to
+ * the client.
+ *
+ * svc_rdma_sendto must fully transmit the Reply before returning, as
+ * the svc_rqst will be recycled as soon as sendto returns. Remaining
+ * resources referred to by the svc_rqst are also recycled at that time.
+ *
+ * Page Management
+ *
+ * The I/O that performs Reply transmission is asynchronous, and may
+ * complete well after sendto returns. Thus pages under I/O must be
+ * removed from the svc_rqst before sendto returns.
+ *
+ * The logic here depends on Send Queue and completion ordering. Since
+ * the Send WR is always posted last, it will always complete last. Thus
+ * when it completes, it is guaranteed that all previous Write WRs have
+ * also completed.
+ *
+ * Write WRs are constructed and posted. Each Write segment gets its own
+ * svc_rdma_rw_ctxt, allowing the Write completion handler to find and
+ * DMA-unmap the pages under I/O for that Write segment. The Write
+ * completion handler does not release any pages.
+ *
+ * When the Send WR is constructed, it also gets its own svc_rdma_op_ctxt.
+ * The Reply's pages are transferred into that ctxt, the Send WR is
+ * posted, and sendto returns.
+ *
+ * The svc_rdma_op_ctxt is presented when the Send WR completes. The
+ * Send completion handler finally releases the Reply's pages.
+ *
+ * This mechanism also assumes that completions on the transport's Send
+ * Completion Queue do not run in parallel. Otherwise a Write completion
+ * and Send completion running at the same time could release pages that
+ * are still DMA-mapped.
+ *
+ * Error Handling
+ *
+ * - If the Send WR is posted successfully, it will either complete
+ *   successfully, or get flushed; either way, the Send completion handler
+ *   releases the Reply's pages.
+ * - If the Send WR cannot be not posted, the forward path releases the
+ *   Reply's pages.
+ *
+ * This handles the case, without the use of page reference counting,
+ * where two different Write segments send portions of the same page.
+ */
+
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/spinlock.h>
@@ -123,45 +179,14 @@ int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
 	return 0;
 }
 
-static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
-			      struct xdr_buf *xdr,
-			      u32 xdr_off, size_t len, int dir)
-{
-	struct page *page;
-	dma_addr_t dma_addr;
-	if (xdr_off < xdr->head[0].iov_len) {
-		/* This offset is in the head */
-		xdr_off += (unsigned long)xdr->head[0].iov_base & ~PAGE_MASK;
-		page = virt_to_page(xdr->head[0].iov_base);
-	} else {
-		xdr_off -= xdr->head[0].iov_len;
-		if (xdr_off < xdr->page_len) {
-			/* This offset is in the page list */
-			xdr_off += xdr->page_base;
-			page = xdr->pages[xdr_off >> PAGE_SHIFT];
-			xdr_off &= ~PAGE_MASK;
-		} else {
-			/* This offset is in the tail */
-			xdr_off -= xdr->page_len;
-			xdr_off += (unsigned long)
-				xdr->tail[0].iov_base & ~PAGE_MASK;
-			page = virt_to_page(xdr->tail[0].iov_base);
-		}
-	}
-	dma_addr = ib_dma_map_page(xprt->sc_cm_id->device, page, xdr_off,
-				   min_t(size_t, PAGE_SIZE, len), dir);
-	return dma_addr;
-}
-
 /* Parse the RPC Call's transport header.
  */
-static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
-				      struct rpcrdma_write_array **write,
-				      struct rpcrdma_write_array **reply)
+static void svc_rdma_get_write_arrays(__be32 *rdma_argp,
+				      __be32 **write, __be32 **reply)
 {
 	__be32 *p;
 
-	p = (__be32 *)&rmsgp->rm_body.rm_chunks[0];
+	p = rdma_argp + rpcrdma_fixed_maxsz;
 
 	/* Read list */
 	while (*p++ != xdr_zero)
@@ -169,7 +194,7 @@ static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
 
 	/* Write list */
 	if (*p != xdr_zero) {
-		*write = (struct rpcrdma_write_array *)p;
+		*write = p;
 		while (*p++ != xdr_zero)
 			p += 1 + be32_to_cpu(*p) * 4;
 	} else {
@@ -179,7 +204,7 @@ static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
 
 	/* Reply chunk */
 	if (*p != xdr_zero)
-		*reply = (struct rpcrdma_write_array *)p;
+		*reply = p;
 	else
 		*reply = NULL;
 }
@@ -189,360 +214,268 @@ static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
  * Invalidate, and responder chooses one rkey to invalidate.
  *
  * Find a candidate rkey to invalidate when sending a reply.  Picks the
- * first rkey it finds in the chunks lists.
+ * first R_key it finds in the chunk lists.
  *
  * Returns zero if RPC's chunk lists are empty.
  */
-static u32 svc_rdma_get_inv_rkey(struct rpcrdma_msg *rdma_argp,
-				 struct rpcrdma_write_array *wr_ary,
-				 struct rpcrdma_write_array *rp_ary)
+static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
+				 __be32 *wr_ch, __be32 *rp_ch)
 {
-	struct rpcrdma_read_chunk *rd_ary;
-	struct rpcrdma_segment *arg_ch;
+	__be32 *p;
 
-	rd_ary = (struct rpcrdma_read_chunk *)&rdma_argp->rm_body.rm_chunks[0];
-	if (rd_ary->rc_discrim != xdr_zero)
-		return be32_to_cpu(rd_ary->rc_target.rs_handle);
+	p = rdma_argp + rpcrdma_fixed_maxsz;
+	if (*p != xdr_zero) {
+		p += 2;
+	} else if (wr_ch && be32_to_cpup(wr_ch + 1)) {
+		p = wr_ch + 2;
+	} else if (rp_ch && be32_to_cpup(rp_ch + 1)) {
+		p = rp_ch + 2;
+	} else
+		return 0;
+	return be32_to_cpup(p);
+}
 
-	if (wr_ary && be32_to_cpu(wr_ary->wc_nchunks)) {
-		arg_ch = &wr_ary->wc_array[0].wc_target;
-		return be32_to_cpu(arg_ch->rs_handle);
-	}
+/* ib_dma_map_page() is used here because svc_rdma_dma_unmap()
+ * is used during completion to DMA-unmap this memory, and
+ * it uses ib_dma_unmap_page() exclusively.
+ */
+static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
+				struct svc_rdma_op_ctxt *ctxt,
+				unsigned int sge_no,
+				unsigned char *base,
+				unsigned int len)
+{
+	unsigned long offset = (unsigned long)base & ~PAGE_MASK;
+	struct ib_device *dev = rdma->sc_device;
+	dma_addr_t dma_addr;
 
-	if (rp_ary && be32_to_cpu(rp_ary->wc_nchunks)) {
-		arg_ch = &rp_ary->wc_array[0].wc_target;
-		return be32_to_cpu(arg_ch->rs_handle);
-	}
+	dma_addr = ib_dma_map_page(dev, virt_to_page(base),
+				   offset, len, DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(dev, dma_addr))
+		return -EIO;
 
+	ctxt->sge[sge_no].addr = dma_addr;
+	ctxt->sge[sge_no].length = len;
+	ctxt->sge[sge_no].lkey = rdma->sc_lkey;
+	svc_rdma_count_mappings(rdma, ctxt);
 	return 0;
 }
 
-/* Assumptions:
- * - The specified write_len can be represented in sc_max_sge * PAGE_SIZE
- */
-static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
-		      u32 rmr, u64 to,
-		      u32 xdr_off, int write_len,
-		      struct svc_rdma_req_map *vec)
+static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
+				 struct svc_rdma_op_ctxt *ctxt,
+				 unsigned int sge_no,
+				 struct page *page,
+				 unsigned int offset,
+				 unsigned int len)
 {
-	struct ib_rdma_wr write_wr;
-	struct ib_sge *sge;
-	int xdr_sge_no;
-	int sge_no;
-	int sge_bytes;
-	int sge_off;
-	int bc;
-	struct svc_rdma_op_ctxt *ctxt;
+	struct ib_device *dev = rdma->sc_device;
+	dma_addr_t dma_addr;
 
-	if (vec->count > RPCSVC_MAXPAGES) {
-		pr_err("svcrdma: Too many pages (%lu)\n", vec->count);
+	dma_addr = ib_dma_map_page(dev, page, offset, len, DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(dev, dma_addr))
 		return -EIO;
-	}
 
-	dprintk("svcrdma: RDMA_WRITE rmr=%x, to=%llx, xdr_off=%d, "
-		"write_len=%d, vec->sge=%p, vec->count=%lu\n",
-		rmr, (unsigned long long)to, xdr_off,
-		write_len, vec->sge, vec->count);
+	ctxt->sge[sge_no].addr = dma_addr;
+	ctxt->sge[sge_no].length = len;
+	ctxt->sge[sge_no].lkey = rdma->sc_lkey;
+	svc_rdma_count_mappings(rdma, ctxt);
+	return 0;
+}
 
-	ctxt = svc_rdma_get_context(xprt);
+/**
+ * svc_rdma_map_reply_hdr - Map a RPC-over-RDMA transport header for a reply
+ * @rdma: controlling transport
+ * @ctxt: op_ctxt for the Send WR
+ * @rdma_resp: buffer containing transport header
+ * @len: length of transport header
+ *
+ * Returns 0 if successful, or a negative errno if a problem occurs.
+ */
+int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
+			   struct svc_rdma_op_ctxt *ctxt,
+			   __be32 *rdma_resp,
+			   unsigned int len)
+{
 	ctxt->direction = DMA_TO_DEVICE;
-	sge = ctxt->sge;
-
-	/* Find the SGE associated with xdr_off */
-	for (bc = xdr_off, xdr_sge_no = 1; bc && xdr_sge_no < vec->count;
-	     xdr_sge_no++) {
-		if (vec->sge[xdr_sge_no].iov_len > bc)
-			break;
-		bc -= vec->sge[xdr_sge_no].iov_len;
-	}
-
-	sge_off = bc;
-	bc = write_len;
-	sge_no = 0;
-
-	/* Copy the remaining SGE */
-	while (bc != 0) {
-		sge_bytes = min_t(size_t,
-			  bc, vec->sge[xdr_sge_no].iov_len-sge_off);
-		sge[sge_no].length = sge_bytes;
-		sge[sge_no].addr =
-			dma_map_xdr(xprt, &rqstp->rq_res, xdr_off,
-				    sge_bytes, DMA_TO_DEVICE);
-		xdr_off += sge_bytes;
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
-					 sge[sge_no].addr))
-			goto err;
-		svc_rdma_count_mappings(xprt, ctxt);
-		sge[sge_no].lkey = xprt->sc_pd->local_dma_lkey;
-		ctxt->count++;
-		sge_off = 0;
-		sge_no++;
-		xdr_sge_no++;
-		if (xdr_sge_no > vec->count) {
-			pr_err("svcrdma: Too many sges (%d)\n", xdr_sge_no);
-			goto err;
-		}
-		bc -= sge_bytes;
-		if (sge_no == xprt->sc_max_sge)
-			break;
-	}
-
-	/* Prepare WRITE WR */
-	memset(&write_wr, 0, sizeof write_wr);
-	ctxt->cqe.done = svc_rdma_wc_write;
-	write_wr.wr.wr_cqe = &ctxt->cqe;
-	write_wr.wr.sg_list = &sge[0];
-	write_wr.wr.num_sge = sge_no;
-	write_wr.wr.opcode = IB_WR_RDMA_WRITE;
-	write_wr.wr.send_flags = IB_SEND_SIGNALED;
-	write_wr.rkey = rmr;
-	write_wr.remote_addr = to;
-
-	/* Post It */
-	atomic_inc(&rdma_stat_write);
-	if (svc_rdma_send(xprt, &write_wr.wr))
-		goto err;
-	return write_len - bc;
- err:
-	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_context(ctxt, 0);
-	return -EIO;
+	ctxt->pages[0] = virt_to_page(rdma_resp);
+	ctxt->count = 1;
+	return svc_rdma_dma_map_page(rdma, ctxt, 0, ctxt->pages[0], 0, len);
 }
 
-noinline
-static int send_write_chunks(struct svcxprt_rdma *xprt,
-			     struct rpcrdma_write_array *wr_ary,
-			     struct rpcrdma_msg *rdma_resp,
-			     struct svc_rqst *rqstp,
-			     struct svc_rdma_req_map *vec)
+/* Load the xdr_buf into the ctxt's sge array, and DMA map each
+ * element as it is added.
+ *
+ * Returns the number of sge elements loaded on success, or
+ * a negative errno on failure.
+ */
+static int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
+				  struct svc_rdma_op_ctxt *ctxt,
+				  struct xdr_buf *xdr, __be32 *wr_ch)
 {
-	u32 xfer_len = rqstp->rq_res.page_len;
-	int write_len;
-	u32 xdr_off;
-	int chunk_off;
-	int chunk_no;
-	int nchunks;
-	struct rpcrdma_write_array *res_ary;
+	unsigned int len, sge_no, remaining, page_off;
+	struct page **ppages;
+	unsigned char *base;
+	u32 xdr_pad;
 	int ret;
 
-	res_ary = (struct rpcrdma_write_array *)
-		&rdma_resp->rm_body.rm_chunks[1];
-
-	/* Write chunks start at the pagelist */
-	nchunks = be32_to_cpu(wr_ary->wc_nchunks);
-	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
-	     xfer_len && chunk_no < nchunks;
-	     chunk_no++) {
-		struct rpcrdma_segment *arg_ch;
-		u64 rs_offset;
-
-		arg_ch = &wr_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, be32_to_cpu(arg_ch->rs_length));
-
-		/* Prepare the response chunk given the length actually
-		 * written */
-		xdr_decode_hyper((__be32 *)&arg_ch->rs_offset, &rs_offset);
-		svc_rdma_xdr_encode_array_chunk(res_ary, chunk_no,
-						arg_ch->rs_handle,
-						arg_ch->rs_offset,
-						write_len);
-		chunk_off = 0;
-		while (write_len) {
-			ret = send_write(xprt, rqstp,
-					 be32_to_cpu(arg_ch->rs_handle),
-					 rs_offset + chunk_off,
-					 xdr_off,
-					 write_len,
-					 vec);
-			if (ret <= 0)
-				goto out_err;
-			chunk_off += ret;
-			xdr_off += ret;
-			xfer_len -= ret;
-			write_len -= ret;
+	sge_no = 1;
+
+	ret = svc_rdma_dma_map_buf(rdma, ctxt, sge_no++,
+				   xdr->head[0].iov_base,
+				   xdr->head[0].iov_len);
+	if (ret < 0)
+		return ret;
+
+	/* If a Write chunk is present, the xdr_buf's page list
+	 * is not included inline. However the Upper Layer may
+	 * have added XDR padding in the tail buffer, and that
+	 * should not be included inline.
+	 */
+	if (wr_ch) {
+		base = xdr->tail[0].iov_base;
+		len = xdr->tail[0].iov_len;
+		xdr_pad = xdr_padsize(xdr->page_len);
+
+		if (len && xdr_pad) {
+			base += xdr_pad;
+			len -= xdr_pad;
 		}
+
+		goto tail;
 	}
-	/* Update the req with the number of chunks actually used */
-	svc_rdma_old_encode_write_list(rdma_resp, chunk_no);
 
-	return rqstp->rq_res.page_len;
+	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
+	page_off = xdr->page_base & ~PAGE_MASK;
+	remaining = xdr->page_len;
+	while (remaining) {
+		len = min_t(u32, PAGE_SIZE - page_off, remaining);
+
+		ret = svc_rdma_dma_map_page(rdma, ctxt, sge_no++,
+					    *ppages++, page_off, len);
+		if (ret < 0)
+			return 0;
+
+		remaining -= len;
+		page_off = 0;
+	}
+
+	base = xdr->tail[0].iov_base;
+	len = xdr->tail[0].iov_len;
+tail:
+	if (len) {
+		ret = svc_rdma_dma_map_buf(rdma, ctxt, sge_no++, base, len);
+		if (ret < 0)
+			return ret;
+	}
 
-out_err:
-	pr_err("svcrdma: failed to send write chunks, rc=%d\n", ret);
-	return -EIO;
+	return sge_no - 1;
 }
 
-noinline
-static int send_reply_chunks(struct svcxprt_rdma *xprt,
-			     struct rpcrdma_write_array *rp_ary,
-			     struct rpcrdma_msg *rdma_resp,
-			     struct svc_rqst *rqstp,
-			     struct svc_rdma_req_map *vec)
+/* The svc_rqst and all resources it owns are released as soon as
+ * svc_rdma_sendto returns. Transfer pages under I/O to the ctxt
+ * so they are released by the Send completion handler.
+ */
+static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
+				   struct svc_rdma_op_ctxt *ctxt)
 {
-	u32 xfer_len = rqstp->rq_res.len;
-	int write_len;
-	u32 xdr_off;
-	int chunk_no;
-	int chunk_off;
-	int nchunks;
-	struct rpcrdma_segment *ch;
-	struct rpcrdma_write_array *res_ary;
-	int ret;
+	int i, pages = rqstp->rq_next_page - rqstp->rq_respages;
 
-	/* XXX: need to fix when reply lists occur with read-list and or
-	 * write-list */
-	res_ary = (struct rpcrdma_write_array *)
-		&rdma_resp->rm_body.rm_chunks[2];
-
-	/* xdr offset starts at RPC message */
-	nchunks = be32_to_cpu(rp_ary->wc_nchunks);
-	for (xdr_off = 0, chunk_no = 0;
-	     xfer_len && chunk_no < nchunks;
-	     chunk_no++) {
-		u64 rs_offset;
-		ch = &rp_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, be32_to_cpu(ch->rs_length));
-
-		/* Prepare the reply chunk given the length actually
-		 * written */
-		xdr_decode_hyper((__be32 *)&ch->rs_offset, &rs_offset);
-		svc_rdma_xdr_encode_array_chunk(res_ary, chunk_no,
-						ch->rs_handle, ch->rs_offset,
-						write_len);
-		chunk_off = 0;
-		while (write_len) {
-			ret = send_write(xprt, rqstp,
-					 be32_to_cpu(ch->rs_handle),
-					 rs_offset + chunk_off,
-					 xdr_off,
-					 write_len,
-					 vec);
-			if (ret <= 0)
-				goto out_err;
-			chunk_off += ret;
-			xdr_off += ret;
-			xfer_len -= ret;
-			write_len -= ret;
-		}
+	ctxt->count += pages;
+	for (i = 0; i < pages; i++) {
+		ctxt->pages[i + 1] = rqstp->rq_respages[i];
+		rqstp->rq_respages[i] = NULL;
 	}
-	/* Update the req with the number of chunks actually used */
-	svc_rdma_xdr_encode_reply_array(res_ary, chunk_no);
+	rqstp->rq_next_page = rqstp->rq_respages + 1;
+}
 
-	return rqstp->rq_res.len;
+/**
+ * svc_rdma_build_send_wr - Set up a Send Work Request
+ * @ctxt: op_ctxt for transmitting the Send WR
+ *
+ */
+void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt, int num_sge)
+{
+	struct ib_send_wr *send_wr;
 
-out_err:
-	pr_err("svcrdma: failed to send reply chunks, rc=%d\n", ret);
-	return -EIO;
+	send_wr = &ctxt->send_wr;
+	send_wr->next = NULL;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	send_wr->wr_cqe = &ctxt->cqe;
+	send_wr->sg_list = ctxt->sge;
+	send_wr->num_sge = num_sge;
+	send_wr->opcode = IB_WR_SEND;
+	send_wr->send_flags = IB_SEND_SIGNALED;
+
+	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
+		send_wr->num_sge);
 }
 
-/* This function prepares the portion of the RPCRDMA message to be
- * sent in the RDMA_SEND. This function is called after data sent via
- * RDMA has already been transmitted. There are three cases:
- * - The RPCRDMA header, RPC header, and payload are all sent in a
- *   single RDMA_SEND. This is the "inline" case.
- * - The RPCRDMA header and some portion of the RPC header and data
- *   are sent via this RDMA_SEND and another portion of the data is
- *   sent via RDMA.
- * - The RPCRDMA header [NOMSG] is sent in this RDMA_SEND and the RPC
- *   header and data are all transmitted via RDMA.
- * In all three cases, this function prepares the RPCRDMA header in
- * sge[0], the 'type' parameter indicates the type to place in the
- * RPCRDMA header, and the 'byte_count' field indicates how much of
- * the XDR to include in this RDMA_SEND. NB: The offset of the payload
- * to send is zero in the XDR.
+/* Prepare the portion of the RPC Reply that will be transmitted
+ * via RDMA Send. The RPC-over-RDMA transport header is prepared
+ * in sge[0], and the RPC xdr_buf is prepared in following sges.
+ *
+ * Depending on whether a Write list or Reply chunk is present,
+ * the server may send all, a portion of, or none of the xdr_buf.
+ * In the latter case, only the transport header (sge[0]) is
+ * transmitted.
+ *
+ * RDMA Send is the last step of transmitting an RPC reply. Pages
+ * involved in the earlier RDMA Writes are here transferred out
+ * of the rqstp and into the ctxt's page array. These pages are
+ * DMA unmapped by each Write completion, but the subsequent Send
+ * completion finally releases these pages.
+ *
+ * Returns zero or a negative errno.
+ *
+ * Assumptions:
+ * - The Reply's transport header will never be larger than a page.
  */
-static int send_reply(struct svcxprt_rdma *rdma,
-		      struct svc_rqst *rqstp,
-		      struct page *page,
-		      struct rpcrdma_msg *rdma_resp,
-		      struct svc_rdma_req_map *vec,
-		      int byte_count,
-		      u32 inv_rkey)
+static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
+				   __be32 *rdma_argp, __be32 *rdma_resp,
+				   struct svc_rqst *rqstp,
+				   __be32 *wr_ch, __be32 *rp_ch)
 {
 	struct svc_rdma_op_ctxt *ctxt;
-	struct ib_send_wr send_wr;
-	u32 xdr_off;
-	int sge_no;
-	int sge_bytes;
-	int page_no;
-	int pages;
-	int ret = -EIO;
+	struct ib_send_wr *send_wr;
+	int ret;
+
+	dprintk("svcrdma: sending %s reply: head=%zu, pagelen=%u, tail=%zu\n",
+		(rp_ch ? "RDMA_NOMSG" : "RDMA_MSG"),
+		rqstp->rq_res.head[0].iov_len,
+		rqstp->rq_res.page_len,
+		rqstp->rq_res.tail[0].iov_len);
 
-	/* Prepare the context */
 	ctxt = svc_rdma_get_context(rdma);
-	ctxt->direction = DMA_TO_DEVICE;
-	ctxt->pages[0] = page;
-	ctxt->count = 1;
 
-	/* Prepare the SGE for the RPCRDMA Header */
-	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
-	ctxt->sge[0].length =
-	    svc_rdma_xdr_get_reply_hdr_len((__be32 *)rdma_resp);
-	ctxt->sge[0].addr =
-	    ib_dma_map_page(rdma->sc_cm_id->device, page, 0,
-			    ctxt->sge[0].length, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr))
+	ret = svc_rdma_map_reply_hdr(rdma, ctxt, rdma_resp,
+				     svc_rdma_xdr_get_reply_hdr_len(rdma_resp));
+	if (ret < 0)
 		goto err;
-	svc_rdma_count_mappings(rdma, ctxt);
-
-	ctxt->direction = DMA_TO_DEVICE;
 
-	/* Map the payload indicated by 'byte_count' */
-	xdr_off = 0;
-	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
-		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
-		byte_count -= sge_bytes;
-		ctxt->sge[sge_no].addr =
-			dma_map_xdr(rdma, &rqstp->rq_res, xdr_off,
-				    sge_bytes, DMA_TO_DEVICE);
-		xdr_off += sge_bytes;
-		if (ib_dma_mapping_error(rdma->sc_cm_id->device,
-					 ctxt->sge[sge_no].addr))
+	if (!rp_ch) {
+		ret = svc_rdma_map_reply_msg(rdma, ctxt, &rqstp->rq_res, wr_ch);
+		if (ret < 0)
 			goto err;
-		svc_rdma_count_mappings(rdma, ctxt);
-		ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
-		ctxt->sge[sge_no].length = sge_bytes;
-	}
-	if (byte_count != 0) {
-		pr_err("svcrdma: Could not map %d bytes\n", byte_count);
-		goto err;
 	}
 
-	/* Save all respages in the ctxt and remove them from the
-	 * respages array. They are our pages until the I/O
-	 * completes.
-	 */
-	pages = rqstp->rq_next_page - rqstp->rq_respages;
-	for (page_no = 0; page_no < pages; page_no++) {
-		ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
-		ctxt->count++;
-		rqstp->rq_respages[page_no] = NULL;
-	}
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
+	svc_rdma_save_io_pages(rqstp, ctxt);
 
-	if (sge_no > rdma->sc_max_sge) {
-		pr_err("svcrdma: Too many sges (%d)\n", sge_no);
-		goto err;
+	svc_rdma_build_send_wr(ctxt, 1 + ret);
+	send_wr = &ctxt->send_wr;
+	if (rdma->sc_snd_w_inv) {
+		send_wr->ex.invalidate_rkey =
+			svc_rdma_get_inv_rkey(rdma_argp, wr_ch, rp_ch);
+		if (send_wr->ex.invalidate_rkey)
+			send_wr->opcode = IB_WR_SEND_WITH_INV;
 	}
-	memset(&send_wr, 0, sizeof send_wr);
-	ctxt->cqe.done = svc_rdma_wc_send;
-	send_wr.wr_cqe = &ctxt->cqe;
-	send_wr.sg_list = ctxt->sge;
-	send_wr.num_sge = sge_no;
-	if (inv_rkey) {
-		send_wr.opcode = IB_WR_SEND_WITH_INV;
-		send_wr.ex.invalidate_rkey = inv_rkey;
-	} else
-		send_wr.opcode = IB_WR_SEND;
-	send_wr.send_flags =  IB_SEND_SIGNALED;
-
-	ret = svc_rdma_send(rdma, &send_wr);
+	ret = svc_rdma_send(rdma, send_wr);
 	if (ret)
 		goto err;
 
 	return 0;
 
- err:
+err:
+	pr_err("svcrdma: failed to post Send WR (%d)\n", ret);
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
 	return ret;
@@ -552,38 +485,31 @@ void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
 {
 }
 
+/**
+ * svc_rdma_sendto - Transmit an RPC reply
+ * @rqstp: processed RPC request, reply XDR already in ::rq_res
+ *
+ * Returns zero if the RPC reply and results have been successfully
+ * posted, or a negative errno is returned and the connection is
+ * terminated.
+ */
 int svc_rdma_sendto(struct svc_rqst *rqstp)
 {
 	struct svc_xprt *xprt = rqstp->rq_xprt;
 	struct svcxprt_rdma *rdma =
 		container_of(xprt, struct svcxprt_rdma, sc_xprt);
-	struct rpcrdma_msg *rdma_argp;
-	struct rpcrdma_msg *rdma_resp;
-	struct rpcrdma_write_array *wr_ary, *rp_ary;
-	int ret;
-	int inline_bytes;
+	__be32 *rdma_argp, *rdma_resp, *wr_ch, *rp_ch;
 	struct page *res_page;
-	struct svc_rdma_req_map *vec;
-	u32 inv_rkey;
-
-	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
+	int ret;
 
-	/* Get the RDMA request header. The receive logic always
-	 * places this at the start of page 0.
+	/* Find the call's chunk lists to decide how to send the reply.
+	 * Receive places the Call's xprt header at the start of page 0.
 	 */
 	rdma_argp = page_address(rqstp->rq_pages[0]);
-	svc_rdma_get_write_arrays(rdma_argp, &wr_ary, &rp_ary);
+	svc_rdma_get_write_arrays(rdma_argp, &wr_ch, &rp_ch);
 
-	inv_rkey = 0;
-	if (rdma->sc_snd_w_inv)
-		inv_rkey = svc_rdma_get_inv_rkey(rdma_argp, wr_ary, rp_ary);
-
-	/* Build an req vec for the XDR */
-	vec = svc_rdma_get_req_map(rdma);
-	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec, wr_ary != NULL);
-	if (ret)
-		goto err0;
-	inline_bytes = rqstp->rq_res.len;
+	dprintk("svcrdma: preparing response for XID 0x%08x\n",
+		be32_to_cpup(rdma_argp));
 
 	/* Create the RDMA response header. xprt->xpt_mutex,
 	 * acquired in svc_send(), serializes RPC replies. The
@@ -596,44 +522,33 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	if (!res_page)
 		goto err0;
 	rdma_resp = page_address(res_page);
-	svc_rdma_xdr_encode_reply_header(rdma, (__be32 *)rdma_argp,
-					 (__be32 *)rdma_resp,
-					 rp_ary ? rdma_nomsg : rdma_msg);
-
-	/* Send any write-chunk data and build resp write-list */
-	if (wr_ary) {
-		ret = send_write_chunks(rdma, wr_ary, rdma_resp, rqstp, vec);
+	svc_rdma_xdr_encode_reply_header(rdma, rdma_argp, rdma_resp,
+					 rp_ch ? rdma_nomsg : rdma_msg);
+	if (wr_ch) {
+		ret = svc_rdma_send_write_list(rdma, wr_ch, rdma_resp,
+					       &rqstp->rq_res);
 		if (ret < 0)
 			goto err1;
-		inline_bytes -= ret + xdr_padsize(ret);
 	}
-
-	/* Send any reply-list data and update resp reply-list */
-	if (rp_ary) {
-		ret = send_reply_chunks(rdma, rp_ary, rdma_resp, rqstp, vec);
+	if (rp_ch) {
+		ret = svc_rdma_send_reply_chunk(rdma, rp_ch, rdma_resp,
+					        &rqstp->rq_res);
 		if (ret < 0)
 			goto err1;
-		inline_bytes -= ret;
 	}
 
-	/* Post a fresh Receive buffer _before_ sending the reply */
 	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
 	if (ret)
 		goto err1;
-
-	ret = send_reply(rdma, rqstp, res_page, rdma_resp, vec,
-			 inline_bytes, inv_rkey);
+	ret = svc_rdma_send_reply_msg(rdma, rdma_argp, rdma_resp, rqstp,
+				      wr_ch, rp_ch);
 	if (ret < 0)
 		goto err0;
-
-	svc_rdma_put_req_map(rdma, vec);
-	dprintk("svcrdma: send_reply returns %d\n", ret);
 	return ret;
 
  err1:
 	put_page(res_page);
  err0:
-	svc_rdma_put_req_map(rdma, vec);
 	pr_err("svcrdma: Could not send reply, err=%d. Closing transport.\n",
 	       ret);
 	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 14ecac4..a6ddd8f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -962,29 +962,11 @@ static unsigned int svc_rdma_read_sqes_per_credit(struct svcxprt_rdma *newxprt)
 			    attrs->max_fast_reg_page_list_len) * 3;
 }
 
-static unsigned int svc_rdma_write_sqes_per_credit(struct svcxprt_rdma *newxprt)
-{
-	return DIV_ROUND_UP(RPCSVC_MAXPAGES, newxprt->sc_max_sge);
-}
-
 static unsigned int svc_rdma_sq_depth(struct svcxprt_rdma *newxprt)
 {
 	unsigned int sqes_per_credit;
 
-	/* Estimate SQEs per credit assuming a full Read chunk payload
-	 * and a full Write chunk payload (possible with krb5i/p). Each
-	 * credit will consume Read WRs then Write WRs, serially, so
-	 * we need just the larger of the two, not the sum.
-	 *
-	 * This is not an upper bound. Clients can break chunks into
-	 * arbitrarily many segments. However, if more SQEs are needed
-	 * then are available, the server has Send Queue accounting to
-	 * wait until enough SQEs are ready. But we want that waiting
-	 * to be very rare.
-	 */
-	sqes_per_credit = max_t(unsigned int,
-				svc_rdma_read_sqes_per_credit(newxprt),
-				svc_rdma_write_sqes_per_credit(newxprt));
+	sqes_per_credit = svc_rdma_read_sqes_per_credit(newxprt);
 
 	/* RDMA Sends per credit */
 	sqes_per_credit += 1;
@@ -992,6 +974,33 @@ static unsigned int svc_rdma_sq_depth(struct svcxprt_rdma *newxprt)
 	return sqes_per_credit * newxprt->sc_rq_depth;
 }
 
+/* Estimate ctxs per credit assuming a full Read chunk payload
+ * and a full Write chunk payload (possible with krb5i/p). Each
+ * credit will consume Read WRs then Write WRs serially.
+ *
+ * Unfortunately we have no idea exactly how many ctxs will be
+ * needed.
+ *
+ * The RPC-over-RDMA protocol doesn't provide a way for a client
+ * to inform servers about how many segments it may send per RPC.
+ * Clients can break chunks into arbitrarily many segments. We
+ * need more than one ctx per credit when the client can send
+ * only small segments, or uses multi-segment Reply chunks.
+ *
+ * If more ctxs are needed then are available, the server has
+ * Send Queue accounting to wait until enough ctxs are available.
+ * We want that waiting to be very rare.
+ *
+ * For the moment, allocate one ctx per credit.
+ *
+ * Send Queue resources for these ctxs are provisioned by
+ * rdma_create_qp().
+ */
+static unsigned int svc_rdma_max_rdma_ctxs(struct svcxprt_rdma *newxprt)
+{
+	return newxprt->sc_max_requests;
+}
+
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -1034,6 +1043,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt, newxprt->sc_cm_id);
 
 	dev = newxprt->sc_cm_id->device;
+	newxprt->sc_device = dev;
 	newxprt->sc_port_num = newxprt->sc_cm_id->port_num;
 
 	/* Qualify the transport resource defaults with the
@@ -1070,6 +1080,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		dprintk("svcrdma: error creating PD for connect request\n");
 		goto errout;
 	}
+	newxprt->sc_lkey = newxprt->sc_pd->local_dma_lkey;
+
 	newxprt->sc_sq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_sq_depth,
 					0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(newxprt->sc_sq_cq)) {
@@ -1086,6 +1098,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	memset(&qp_attr, 0, sizeof qp_attr);
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
+	qp_attr.port_num = newxprt->sc_cm_id->port_num;
+	qp_attr.cap.max_rdma_ctxs = svc_rdma_max_rdma_ctxs(newxprt);
 	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
 	qp_attr.cap.max_recv_wr = newxprt->sc_rq_depth;
 	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;

