Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36365 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753085AbdC0Ntw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:49:52 -0400
Subject: [PATCH v2 05/13] svcrdma: Introduce local rdma_rw API helpers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:48:35 -0400
Message-ID: <20170327134835.5585.76603.stgit@klimt.1015granger.net>
In-Reply-To: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The plan is to replace the local bespoke code that constructs and
posts RDMA Read and Write Work Requests with calls to the rdma_rw
API. This shares code with other RDMA-enabled ULPs that manages the
gory details of buffer registration and posting Work Requests.

Some design notes:

 o svc_xprt reference counting is modified, since one rdma_rw_ctx
   generates one completion, no matter how many Write WRs are
   posted. To accommodate the new reference counting scheme, a new
   version of svc_rdma_send() is introduced.

 o The structure of RPC-over-RDMA transport headers is flexible,
   allowing multiple segments per Reply with arbitrary alignment.
   Thus I did not take the further step of chaining Write WRs with
   the Send WR containing the RPC Reply message. The Write and Send
   WRs continue to be built by separate pieces of code.

 o The current code builds the transport header as it is construct-
   ing Write WRs. I've replaced that with marshaling of transport
   header data items in a separate step. This is because the exact
   structure of client-provided segments may not align with the
   components of the server's reply xdr_buf, or the pages in the
   page list. Thus parts of each client-provided segment may be
   written at different points in the send path.

 o Since the Write list and Reply chunk marshaling code is being
   replaced, I took the opportunity to replace some of the C
   structure-based XDR encoding code with more portable code that
   instead uses pointer arithmetic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   11 +
 net/sunrpc/xprtrdma/Makefile             |    2 
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |  463 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 
 4 files changed, 479 insertions(+), 1 deletion(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f066349..acbf0b5 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -145,12 +145,15 @@ struct svcxprt_rdma {
 	u32		     sc_max_requests;	/* Max requests */
 	u32		     sc_max_bc_requests;/* Backward credits */
 	int                  sc_max_req_size;	/* Size of each RQ WR buf */
+	u8		     sc_port_num;
 
 	struct ib_pd         *sc_pd;
 
 	spinlock_t	     sc_ctxt_lock;
 	struct list_head     sc_ctxts;
 	int		     sc_ctxt_used;
+	spinlock_t	     sc_rw_ctxt_lock;
+	struct list_head     sc_rw_ctxts;
 	spinlock_t	     sc_map_lock;
 	struct list_head     sc_maps;
 
@@ -224,6 +227,14 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 				struct svc_rdma_op_ctxt *, int *, u32 *,
 				u32, u32, u64, bool);
 
+/* svc_rdma_rw.c */
+extern void svc_rdma_destroy_rw_ctxts(struct svcxprt_rdma *rdma);
+extern int svc_rdma_send_write_chunk(struct svcxprt_rdma *rdma,
+				     __be32 *wr_ch, struct xdr_buf *xdr);
+extern int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
+				     __be32 *rp_ch, bool writelist,
+				     struct xdr_buf *xdr);
+
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index ef19fa4..c1ae814 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -4,5 +4,5 @@ rpcrdma-y := transport.o rpc_rdma.o verbs.o \
 	fmr_ops.o frwr_ops.o \
 	svc_rdma.o svc_rdma_backchannel.o svc_rdma_transport.o \
 	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o \
-	module.o
+	svc_rdma_rw.o module.o
 rpcrdma-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel.o
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
new file mode 100644
index 0000000..a672537
--- /dev/null
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -0,0 +1,463 @@
+/*
+ * Copyright (c) 2016 Oracle.  All rights reserved.
+ *
+ * Use the core R/W API to move RPC-over-RDMA Read and Write chunks.
+ */
+
+#include <linux/sunrpc/rpc_rdma.h>
+#include <linux/sunrpc/svc_rdma.h>
+#include <linux/sunrpc/debug.h>
+
+#include <rdma/rw.h>
+
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+
+/* Each R/W context contains state for one chain of RDMA Read or
+ * Write Work Requests (one RDMA segment to be read from or written
+ * back to the client).
+ *
+ * Each WR chain handles a single contiguous server-side buffer,
+ * because some registration modes (eg. FRWR) do not support a
+ * discontiguous scatterlist.
+ *
+ * Each WR chain handles only one R_key. Each RPC-over-RDMA segment
+ * from a client may contain a unique R_key, so each WR chain moves
+ * one segment (or less) at a time.
+ */
+struct svc_rdma_rw_ctxt {
+	struct list_head	rw_list;
+	struct ib_cqe		rw_cqe;
+	struct svcxprt_rdma	*rw_rdma;
+	int			rw_nents;
+	int			rw_wrcount;
+	struct rdma_rw_ctx	rw_ctx;
+	struct sg_table		rw_sg_table;
+};
+
+
+static struct svc_rdma_rw_ctxt *
+svc_rdma_get_rw_ctxt(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_rw_ctxt *ctxt;
+
+	svc_xprt_get(&rdma->sc_xprt);
+
+	spin_lock(&rdma->sc_rw_ctxt_lock);
+	if (list_empty(&rdma->sc_rw_ctxts))
+		goto out_empty;
+
+	ctxt = list_first_entry(&rdma->sc_rw_ctxts,
+				struct svc_rdma_rw_ctxt, rw_list);
+	list_del(&ctxt->rw_list);
+	spin_unlock(&rdma->sc_rw_ctxt_lock);
+
+out:
+	return ctxt;
+
+out_empty:
+	spin_unlock(&rdma->sc_rw_ctxt_lock);
+
+	ctxt = kzalloc(sizeof(*ctxt), GFP_KERNEL);
+	if (!ctxt)
+		goto out_fail;
+	if (sg_alloc_table(&ctxt->rw_sg_table, RPCSVC_MAXPAGES, GFP_KERNEL)) {
+		kfree(ctxt);
+		goto out_fail;
+	}
+	ctxt->rw_rdma = rdma;
+	INIT_LIST_HEAD(&ctxt->rw_list);
+	goto out;
+
+out_fail:
+	svc_xprt_put(&rdma->sc_xprt);
+	return NULL;
+}
+
+static void svc_rdma_put_rw_ctxt(struct svc_rdma_rw_ctxt *ctxt)
+{
+	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
+
+	spin_lock(&rdma->sc_rw_ctxt_lock);
+	list_add(&ctxt->rw_list, &rdma->sc_rw_ctxts);
+	spin_unlock(&rdma->sc_rw_ctxt_lock);
+
+	svc_xprt_put(&rdma->sc_xprt);
+}
+
+/**
+ * svc_rdma_destroy_rw_ctxts - Free write contexts
+ * @rdma: transport about to be destroyed
+ *
+ */
+void svc_rdma_destroy_rw_ctxts(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_rw_ctxt *ctxt;
+
+	while (!list_empty(&rdma->sc_rw_ctxts)) {
+		ctxt = list_first_entry(&rdma->sc_rw_ctxts,
+					struct svc_rdma_rw_ctxt, rw_list);
+		list_del(&ctxt->rw_list);
+
+		sg_free_table(&ctxt->rw_sg_table);
+		kfree(ctxt);
+	}
+}
+
+/**
+ * svc_rdma_wc_write_ctx - Handle completion of an RDMA Write ctx
+ * @cq: controlling Completion Queue
+ * @wc: Work Completion
+ *
+ * Write completion is not responsible for freeing pages under I/O.
+ */
+static void svc_rdma_wc_write_ctx(struct ib_cq *cq, struct ib_wc *wc)
+{
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_rw_ctxt *ctxt =
+			container_of(cqe, struct svc_rdma_rw_ctxt, rw_cqe);
+	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
+
+	atomic_add(ctxt->rw_wrcount, &rdma->sc_sq_avail);
+	wake_up(&rdma->sc_send_wait);
+
+	if (wc->status != IB_WC_SUCCESS)
+		goto flush;
+
+out:
+	rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp, rdma->sc_port_num,
+			    ctxt->rw_sg_table.sgl, ctxt->rw_nents,
+			    DMA_TO_DEVICE);
+	svc_rdma_put_rw_ctxt(ctxt);
+	return;
+
+flush:
+	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("svcrdma: write ctx: %s (%u/0x%x)\n",
+		       ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
+	goto out;
+}
+
+/* This function sleeps when the transport's Send Queue is congested.
+ *
+ * Assumptions:
+ * - If ib_post_send() succeeds, only one completion is expected,
+ *   even if one or more WRs are flushed. This is true when posting
+ *   an rdma_rw_ctx or when posting a single signaled WR.
+ */
+static int svc_rdma_post_send(struct svcxprt_rdma *rdma,
+			      struct ib_send_wr *first_wr,
+			      int num_wrs)
+{
+	struct svc_xprt *xprt = &rdma->sc_xprt;
+	struct ib_send_wr *bad_wr;
+	int ret;
+
+	do {
+		if ((atomic_sub_return(num_wrs, &rdma->sc_sq_avail) > 0)) {
+			ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
+			if (ret)
+				break;
+			return 0;
+		}
+
+		atomic_inc(&rdma_stat_sq_starve);
+		atomic_add(num_wrs, &rdma->sc_sq_avail);
+		wait_event(rdma->sc_send_wait,
+			   atomic_read(&rdma->sc_sq_avail) > num_wrs);
+	} while (1);
+
+	pr_err("svcrdma: ib_post_send failed (%d)\n", ret);
+	set_bit(XPT_CLOSE, &xprt->xpt_flags);
+
+	/* If even one was posted, there will be a completion. */
+	if (bad_wr != first_wr)
+		return 0;
+
+	atomic_add(num_wrs, &rdma->sc_sq_avail);
+	wake_up(&rdma->sc_send_wait);
+	return -ENOTCONN;
+}
+
+static int svc_rdma_send_rw_ctx(struct svcxprt_rdma *rdma,
+				struct svc_rdma_rw_ctxt *ctxt,
+				u64 offset, u32 rkey,
+				enum dma_data_direction dir)
+{
+	struct ib_send_wr *first_wr;
+	int ret;
+
+	ret = rdma_rw_ctx_init(&ctxt->rw_ctx,
+			       rdma->sc_qp, rdma->sc_port_num,
+			       ctxt->rw_sg_table.sgl, ctxt->rw_nents,
+			       0, offset, rkey, dir);
+	if (ret < 0)
+		goto out_init;
+
+	ctxt->rw_wrcount = ret;
+	first_wr = rdma_rw_ctx_wrs(&ctxt->rw_ctx,
+				   rdma->sc_qp, rdma->sc_port_num,
+				   &ctxt->rw_cqe, NULL);
+	ret = svc_rdma_post_send(rdma, first_wr, ret);
+	if (ret < 0)
+		goto out_destroy;
+
+	return 0;
+
+out_destroy:
+	rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp, rdma->sc_port_num,
+			    ctxt->rw_sg_table.sgl, ctxt->rw_nents, dir);
+out_init:
+	return -EIO;
+}
+
+/* Common information for sending a Write chunk.
+ *  - Tracks progress of writing one chunk
+ *  - Stores arguments for the SGL constructor function
+ */
+struct svc_rdma_write_info {
+	struct svcxprt_rdma	*wi_rdma;
+
+	/* write state of this chunk */
+	unsigned int		wi_bytes_consumed;
+	unsigned int		wi_seg_off;
+	unsigned int		wi_seg_no;
+	unsigned int		wi_nsegs;
+	__be32			*wi_segs;
+
+	/* SGL constructor arguments */
+	struct xdr_buf		*wi_xdr;
+	unsigned char		*wi_base;
+	unsigned int		wi_next_off;
+};
+
+static void svc_rdma_init_write_info(struct svcxprt_rdma *rdma, __be32 *chunk,
+				     struct svc_rdma_write_info *info)
+{
+	info->wi_rdma = rdma;
+	info->wi_bytes_consumed = 0;
+	info->wi_seg_off = 0;
+	info->wi_seg_no = 0;
+	info->wi_nsegs = be32_to_cpup(chunk + 1);
+	info->wi_segs = chunk + 2;
+}
+
+/* Build and DMA-map an SGL that covers one kvec in an xdr_buf
+ */
+static void svc_rdma_vec_to_sg(struct svc_rdma_write_info *info,
+			       unsigned int len,
+			       struct svc_rdma_rw_ctxt *ctxt)
+{
+	struct scatterlist *sg = ctxt->rw_sg_table.sgl;
+
+	sg_set_buf(&sg[0], info->wi_base, len);
+	info->wi_base += len;
+
+	ctxt->rw_nents = 1;
+}
+
+/* Build and DMA-map an SGL that covers part of an xdr_buf's pagelist.
+ */
+static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
+				    unsigned int remaining,
+				    struct svc_rdma_rw_ctxt *ctxt)
+{
+	unsigned int sge_no, sge_bytes, page_off, page_no;
+	struct xdr_buf *xdr = info->wi_xdr;
+	struct scatterlist *sg;
+	struct page **page;
+
+	page_off = (info->wi_next_off + xdr->page_base) & ~PAGE_MASK;
+	page_no = (info->wi_next_off + xdr->page_base) >> PAGE_SHIFT;
+	page = xdr->pages + page_no;
+	info->wi_next_off += remaining;
+	sg = ctxt->rw_sg_table.sgl;
+	sge_no = 0;
+	do {
+		sge_bytes = min_t(unsigned int, remaining,
+				  PAGE_SIZE - page_off);
+		sg_set_page(sg, *page, sge_bytes, page_off);
+
+		remaining -= sge_bytes;
+		sg = sg_next(sg);
+		page_off = 0;
+		sge_no++;
+		page++;
+	} while (remaining);
+
+	ctxt->rw_nents = sge_no;
+}
+
+/* Post RDMA Write WRs to send a portion of an xdr_buf containing
+ * an RPC Reply.
+ */
+static int
+svc_rdma_send_writes(struct svc_rdma_write_info *info,
+		     void (*constructor)(struct svc_rdma_write_info *info,
+					 unsigned int len,
+					 struct svc_rdma_rw_ctxt *ctxt),
+		     unsigned int total)
+{
+	struct svcxprt_rdma *rdma = info->wi_rdma;
+	unsigned int remaining, seg_no, seg_off;
+	struct svc_rdma_rw_ctxt *ctxt;
+	__be32 *seg;
+	int ret;
+
+	if (total == 0)
+		return 0;
+
+	remaining = total;
+	seg_no = info->wi_seg_no;
+	seg_off = info->wi_seg_off;
+	seg = info->wi_segs + seg_no * rpcrdma_segment_maxsz;
+	do {
+		unsigned int write_len;
+		u32 rs_length, rs_handle;
+		u64 rs_offset;
+
+		if (seg_no >= info->wi_nsegs)
+			goto out_overflow;
+
+		ctxt = svc_rdma_get_rw_ctxt(rdma);
+		if (!ctxt)
+			goto out_noctx;
+
+		rs_handle = be32_to_cpu(*seg++);
+		rs_length = be32_to_cpu(*seg++);
+		seg = xdr_decode_hyper(seg, &rs_offset);
+
+		write_len = min(remaining, rs_length - seg_off);
+		constructor(info, write_len, ctxt);
+
+		ctxt->rw_cqe.done = svc_rdma_wc_write_ctx;
+		ret = svc_rdma_send_rw_ctx(rdma, ctxt, rs_offset + seg_off,
+					   rs_handle, DMA_TO_DEVICE);
+		if (ret < 0)
+			goto out_senderr;
+
+		if (write_len == rs_length - seg_off) {
+			seg_no++;
+			seg_off = 0;
+		} else {
+			seg_off += write_len;
+		}
+		remaining -= write_len;
+	} while (remaining);
+
+	info->wi_bytes_consumed += total;
+	info->wi_seg_no = seg_no;
+	info->wi_seg_off = seg_off;
+	return 0;
+
+out_overflow:
+	dprintk("svcrdma: inadequate space in Write chunk (%u)\n",
+		info->wi_nsegs);
+	return -E2BIG;
+
+out_noctx:
+	dprintk("svcrdma: no R/W ctxs available\n");
+	return -ENOMEM;
+
+out_senderr:
+	svc_rdma_put_rw_ctxt(ctxt);
+	pr_err("svcrdma: failed to write pagelist (%d)\n", ret);
+	return ret;
+}
+
+/* Send one of an xdr_buf's kvecs by itself. To send a Reply
+ * chunk, the whole RPC Reply is written back to the client.
+ * This function writes either the head or tail of the xdr_buf
+ * containing the Reply.
+ */
+static int svc_rdma_send_xdr_kvec(struct svc_rdma_write_info *info,
+				  struct kvec *vec)
+{
+	info->wi_base = vec->iov_base;
+
+	return svc_rdma_send_writes(info, svc_rdma_vec_to_sg,
+				    vec->iov_len);
+}
+
+/* Send an xdr_buf's page list by itself. A Write chunk is
+ * just the page list. a Reply chunk is the head, page list,
+ * and tail. This function is shared between the two types
+ * of chunk.
+ */
+static int svc_rdma_send_xdr_pagelist(struct svc_rdma_write_info *info,
+				      struct xdr_buf *xdr)
+{
+	info->wi_xdr = xdr;
+	info->wi_next_off = 0;
+
+	return svc_rdma_send_writes(info, svc_rdma_pagelist_to_sg,
+				    xdr->page_len);
+}
+
+/**
+ * svc_rdma_send_write_chunk - Write all segments in a Write chunk
+ * @rdma: controlling RDMA transport
+ * @wr_ch: Write chunk provided by client
+ * @xdr: xdr_buf containing the data payload
+ *
+ * Returns a non-negative number of bytes the chunk consumed, or
+ *	%-E2BIG if the payload was larger than the Write chunk,
+ *	%-ENOMEM if rdma_rw context pool was exhausted,
+ *	%-ENOTCONN if posting failed (connection is lost),
+ *	%-EIO if rdma_rw initialization failed (DMA mapping, etc).
+ */
+int svc_rdma_send_write_chunk(struct svcxprt_rdma *rdma, __be32 *wr_ch,
+			      struct xdr_buf *xdr)
+{
+	struct svc_rdma_write_info info;
+	int ret;
+
+	svc_rdma_init_write_info(rdma, wr_ch, &info);
+	ret = svc_rdma_send_xdr_pagelist(&info, xdr);
+	if (ret < 0)
+		return ret;
+	return info.wi_bytes_consumed;
+}
+
+/**
+ * svc_rdma_send_reply_chunk - Write all segments in the Reply chunk
+ * @rdma: controlling RDMA transport
+ * @rp_ch: Reply chunk provided by client
+ * @writelist: true if client provided a Write list
+ * @xdr: xdr_buf containing an RPC Reply
+ *
+ * Returns a non-negative number of bytes the chunk consumed, or
+ *	%0 if all needed RDMA Writes were posted successfully,
+ *	%-E2BIG if the payload was larger than the Reply chunk,
+ *	%-ENOMEM if rdma_rw context pool was exhausted,
+ *	%-ENOTCONN if posting failed (connection is lost),
+ *	%-EIO if rdma_rw initialization failed (DMA mapping, etc).
+ */
+int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma, __be32 *rp_ch,
+			      bool writelist, struct xdr_buf *xdr)
+{
+	struct svc_rdma_write_info info;
+	int ret;
+
+	svc_rdma_init_write_info(rdma, rp_ch, &info);
+
+	ret = svc_rdma_send_xdr_kvec(&info, &xdr->head[0]);
+	if (ret < 0)
+		return ret;
+
+	/* When Write list entries are present, server has already
+	 * transmitted the pagelist payload via a Write chunk. Thus
+	 * we can skip the pagelist here.
+	 */
+	if (!writelist) {
+		ret = svc_rdma_send_xdr_pagelist(&info, xdr);
+		if (ret < 0)
+			return ret;
+	}
+
+	ret = svc_rdma_send_xdr_kvec(&info, &xdr->tail[0]);
+	if (ret < 0)
+		return ret;
+	return info.wi_bytes_consumed;
+}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index b84cd53..90fabad 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -560,6 +560,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_ctxts);
+	INIT_LIST_HEAD(&cma_xprt->sc_rw_ctxts);
 	INIT_LIST_HEAD(&cma_xprt->sc_maps);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
@@ -567,6 +568,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 	spin_lock_init(&cma_xprt->sc_ctxt_lock);
+	spin_lock_init(&cma_xprt->sc_rw_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_map_lock);
 
 	/*
@@ -998,6 +1000,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt, newxprt->sc_cm_id);
 
 	dev = newxprt->sc_cm_id->device;
+	newxprt->sc_port_num = newxprt->sc_cm_id->port_num;
 
 	/* Qualify the transport resource defaults with the
 	 * capabilities of this particular device */
@@ -1247,6 +1250,7 @@ static void __svc_rdma_free(struct work_struct *work)
 	}
 
 	rdma_dealloc_frmr_q(rdma);
+	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_destroy_ctxts(rdma);
 	svc_rdma_destroy_maps(rdma);
 

