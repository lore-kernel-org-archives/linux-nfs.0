Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34559 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755971AbdAGRQZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:16:25 -0500
Subject: [PATCH v1 08/22] svcrdma: Introduce local rdma_rw API helpers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:16:22 -0500
Message-ID: <20170107171622.14126.52988.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The plan is to replace the bespoke code that constructs and posts
RDMA Read and Write Work Requests with calls to the core rdma_rw
API. This shares code with other RDMA-enabled ULPs that manages the
gory details of buffer registration and posting Work Requests.

Some design notes:

 o svc_xprt reference counting is modified, since one rdma_rw_ctx
   equals one completion, no matter how many Write WRs are posted.
   To accomodate the new reference counting scheme, a new version
   of svc_rdma_send() is introduced.

 o The structure of RPC-over-RDMA transport headers is flexible,
   allowing multiple segments per Reply with arbitrary alignment.
   Thus I did not take the further step of chaining Write WRs with
   the Send WR containing the RPC Reply message. The Write and Send
   WRs continue to be built by separate pieces of code.

 o The current code builds the transport header as it is construct-
   ing Write WRs. I've replaced that with marshaling of transport
   header data items in a separate step. This is because the exact
   structure of client-provided segments may not align with the
   components of the reply xdr_buf, or pages in the page list. Thus
   parts of each client-provided segment may be written at different
   points in the send path.

 o Since the Write list and Reply chunk marshaling code is being
   replaced, I took the opportunity to replace some of the C
   structure-based XDR encoding code with more portable code that
   uses pointer arithmetic instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   23 +
 net/sunrpc/xprtrdma/Makefile             |    2 
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  110 ++++-
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |  731 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   56 ++
 6 files changed, 920 insertions(+), 4 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 61cfee8..e6eca34 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -144,12 +144,15 @@ struct svcxprt_rdma {
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
 
@@ -208,10 +211,14 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
 				     struct rpcrdma_msg *,
 				     enum rpcrdma_errcode, __be32 *);
-extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
+extern void svc_rdma_old_encode_write_list(struct rpcrdma_msg *, int);
 extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
 extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
 					    __be32, __be64, u32);
+extern void svc_rdma_xdr_encode_write_list(__be32 *rdma_resp, __be32 *wr_ch,
+					   unsigned int consumed);
+extern void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
+					    unsigned int consumed);
 extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *rdma,
 					     __be32 *rdma_argp,
 					     __be32 *rdma_resp,
@@ -227,6 +234,18 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 				struct svc_rdma_op_ctxt *, int *, u32 *,
 				u32, u32, u64, bool);
 
+/* svc_rdma_rw.c */
+extern void svc_rdma_destroy_rw_ctxts(struct svcxprt_rdma *rdma);
+extern int svc_rdma_recv_read_list(struct svcxprt_rdma *rdma, __be32 *ch,
+				   struct svc_rdma_op_ctxt *head,
+				   struct svc_rqst *rqstp);
+extern int svc_rdma_send_write_list(struct svcxprt_rdma *rdma,
+				    __be32 *wr_ch, __be32 *rdma_resp,
+				    struct xdr_buf *xdr);
+extern int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
+				     __be32 *rp_ch, __be32 *rdma_resp,
+				     struct xdr_buf *xdr);
+
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
@@ -241,6 +260,8 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 extern void svc_rdma_wc_read(struct ib_cq *, struct ib_wc *);
 extern void svc_rdma_wc_inv(struct ib_cq *, struct ib_wc *);
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
+extern int svc_rdma_post_send(struct svcxprt_rdma *rdma,
+			      struct ib_send_wr *first_wr, int num_wrs);
 extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
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
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 7c8d60f..01cb4e1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -217,7 +217,7 @@ unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp)
 	return (unsigned long)p - (unsigned long)rdma_resp;
 }
 
-void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
+void svc_rdma_old_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
 {
 	struct rpcrdma_write_array *ary;
 
@@ -256,6 +256,114 @@ void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
 	seg->rs_length = cpu_to_be32(write_len);
 }
 
+/* Write chunk is copied from Call header to Reply header. Length
+ * fields are updated to reflect number of bytes consumed in each
+ * segment.
+ *
+ * Returns number of segments in this chunk.
+ */
+static unsigned int xdr_encode_write_chunk( __be32 *dst, __be32 *src,
+					   unsigned int remaining)
+{
+	unsigned int i, nsegs;
+	u32 seg_len;
+
+	/* Write list discriminator */
+	*dst++ = *src++;
+
+	/* number of segments in this chunk */
+	nsegs = be32_to_cpup(src);
+	*dst++ = *src++;
+
+	for (i = nsegs; i; i--) {
+		/* segment's RDMA handle */
+		*dst++ = *src++;
+
+		/* bytes returned in this segment */
+		seg_len = be32_to_cpu(*src);
+		if (remaining >= seg_len) {
+			/* entire segment was consumed */
+			*dst = *src;
+			remaining -= seg_len;
+		} else {
+			/* segment only partly filled */
+			*dst = cpu_to_be32(remaining);
+			remaining = 0;
+		}
+		dst++; src++;
+
+		/* segment's RDMA offset */
+		*dst++ = *src++;
+		*dst++ = *src++;
+	}
+
+	return nsegs;
+}
+
+/**
+ * svc_rdma_xdr_encode_write_list - Encode Reply's Write list
+ * @rdma_resp: Reply's transport header
+ * @wr_ch: Write list in Call's transport header
+ * @consumed: total Write chunk bytes consumed in Reply
+ *
+ * The client provided a Write list in the Call message. Fill in
+ * the segments in the first Write chunk in the Reply message with
+ * the number of bytes consumed in each segment. Remaining chunks
+ * are returned unused.
+ *
+ * Assumptions:
+ *  - Server can return only one Write chunk.
+ */
+void svc_rdma_xdr_encode_write_list(__be32 *rdma_resp, __be32 *wr_ch,
+				    unsigned int consumed)
+{
+	unsigned int nsegs;
+	__be32 *p, *q;
+
+	/* RPC-over-RDMA V1 replies never have a Read list. */
+	p = rdma_resp + rpcrdma_fixed_maxsz + 1;
+
+	q = wr_ch;
+	while (*q != xdr_zero) {
+		nsegs = xdr_encode_write_chunk(p, q, consumed);
+		q += 2 + nsegs * rpcrdma_segment_maxsz;
+		p += 2 + nsegs * rpcrdma_segment_maxsz;
+	}
+
+	/* Terminate Write list */
+	*p++ = xdr_zero;
+
+	/* Reply chunk discriminator; may be replaced later */
+	*p = xdr_zero;
+}
+
+/**
+ * svc_rdma_xdr_encode_reply_chunk - Encode Reply's Reply chunk
+ * @rdma_resp: Reply's transport header
+ * @rp_ch: Reply chunk in Call's transport header
+ * @consumed: total Reply chunk bytes consumed in Reply
+ *
+ * The client provided a Reply chunk in the Call message. Fill in
+ * the segments in the Reply chunk in the Reply message with the
+ * number of bytes consumed in each segment.
+ */
+void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
+				     unsigned int consumed)
+{
+	__be32 *p;
+
+	/* Find the Reply chunk in the Reply's xprt header.
+	 * RPC-over-RDMA V1 replies never have a Read list.
+	 */
+	p = rdma_resp + rpcrdma_fixed_maxsz + 1;
+
+	/* Skip past Write list */
+	while (*p++ != xdr_zero)
+		p += 1 + be32_to_cpup(p) * rpcrdma_segment_maxsz;
+
+	xdr_encode_write_chunk(p, rp_ch, consumed);
+}
+
 /**
  * svc_rdma_xdr_encode_reply_header - Encode Reply's fixed header fields
  * @rdma: controlling transport
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
new file mode 100644
index 0000000..38876f5
--- /dev/null
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -0,0 +1,731 @@
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
+ *
+ * The scatterlist makes this data structure just over 8KB in size
+ * on 4KB-page platforms. As the size of this structure increases
+ * past one page, it becomes more likely that allocating one of these
+ * will fail. Therefore, these contexts are created on demand, but
+ * cached and reused until the controlling svcxprt_rdma is destroyed.
+ */
+struct svc_rdma_rw_ctxt {
+	struct list_head	rw_list;
+	struct ib_cqe		rw_cqe;
+	struct svcxprt_rdma	*rw_rdma;
+	int			rw_nents;
+	int			rw_wrcount;
+	enum dma_data_direction	rw_dir;
+	struct svc_rdma_op_ctxt	*rw_readctxt;
+	struct rdma_rw_ctx	rw_ctx;
+	struct scatterlist	rw_sg[RPCSVC_MAXPAGES];
+};
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
+	list_del_init(&ctxt->rw_list);
+	spin_unlock(&rdma->sc_rw_ctxt_lock);
+
+out:
+	ctxt->rw_dir = DMA_NONE;
+	return ctxt;
+
+out_empty:
+	spin_unlock(&rdma->sc_rw_ctxt_lock);
+
+	ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
+	if (!ctxt) {
+		svc_xprt_put(&rdma->sc_xprt);
+		return NULL;
+	}
+
+	ctxt->rw_rdma = rdma;
+	INIT_LIST_HEAD(&ctxt->rw_list);
+	sg_init_table(ctxt->rw_sg, ARRAY_SIZE(ctxt->rw_sg));
+	goto out;
+}
+
+static void svc_rdma_put_rw_ctxt(struct svc_rdma_rw_ctxt *ctxt)
+{
+	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
+
+	if (ctxt->rw_dir != DMA_NONE)
+		rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp,
+				    rdma->sc_port_num,
+				    ctxt->rw_sg, ctxt->rw_nents,
+				    ctxt->rw_dir);
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
+ * @rdma: xprt about to be destroyed
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
+		kfree(ctxt);
+	}
+}
+
+/**
+ * svc_rdma_wc_write_ctx - Handle completion of an RDMA Write ctx
+ * @cq: controlling Completion Queue
+ * @wc: Work Completion
+ *
+ * Invoked in soft IRQ context.
+ *
+ * Assumptions:
+ * - Write completion is not responsible for freeing pages under
+ *   I/O.
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
+/**
+ * svc_rdma_wc_read_ctx - Handle completion of an RDMA Read ctx
+ * @cq: controlling Completion Queue
+ * @wc: Work Completion
+ *
+ * Invoked in soft IRQ context.
+ */
+static void svc_rdma_wc_read_ctx(struct ib_cq *cq, struct ib_wc *wc)
+{
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_rw_ctxt *ctxt =
+			container_of(cqe, struct svc_rdma_rw_ctxt, rw_cqe);
+	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
+	struct svc_rdma_op_ctxt *head;
+
+	atomic_add(ctxt->rw_wrcount, &rdma->sc_sq_avail);
+	wake_up(&rdma->sc_send_wait);
+
+	if (wc->status != IB_WC_SUCCESS)
+		goto flush;
+
+	head = ctxt->rw_readctxt;
+	if (!head)
+		goto out;
+
+	spin_lock(&rdma->sc_rq_dto_lock);
+	list_add_tail(&head->list, &rdma->sc_read_complete_q);
+	spin_unlock(&rdma->sc_rq_dto_lock);
+	set_bit(XPT_DATA, &rdma->sc_xprt.xpt_flags);
+	svc_xprt_enqueue(&rdma->sc_xprt);
+
+out:
+	svc_rdma_put_rw_ctxt(ctxt);
+	return;
+
+flush:
+	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("svcrdma: read ctx: %s (%u/0x%x)\n",
+		       ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
+	goto out;
+}
+
+static int svc_rdma_send_write_ctx(struct svcxprt_rdma *rdma,
+				   struct svc_rdma_rw_ctxt *ctxt,
+				   u64 offset, u32 rkey)
+{
+	struct ib_send_wr *first_wr;
+	int ret;
+
+	ret = rdma_rw_ctx_init(&ctxt->rw_ctx,
+			       rdma->sc_qp, rdma->sc_port_num,
+			       ctxt->rw_sg, ctxt->rw_nents,
+			       0, offset, rkey, DMA_TO_DEVICE);
+	if (ret < 0)
+		return ret;
+
+	ctxt->rw_wrcount = ret;
+	ctxt->rw_dir = DMA_TO_DEVICE;
+	ctxt->rw_cqe.done = svc_rdma_wc_write_ctx;
+	first_wr = rdma_rw_ctx_wrs(&ctxt->rw_ctx,
+				   rdma->sc_qp, rdma->sc_port_num,
+				   &ctxt->rw_cqe, NULL);
+	atomic_add(ret, &rdma_stat_write);
+	return svc_rdma_post_send(rdma, first_wr, ret);
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
+	sg_set_buf(&ctxt->rw_sg[0], info->wi_base, len);
+	info->wi_base += len;
+
+	ctxt->rw_nents = 1;
+}
+
+/* Build and DMA-map an SGL that covers the pagelist of an xdr_buf
+ */
+static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
+				    unsigned int remaining,
+				    struct svc_rdma_rw_ctxt *ctxt)
+{
+	unsigned int sge_no, sge_bytes, page_off, page_no;
+	struct scatterlist *sg = ctxt->rw_sg;
+	struct xdr_buf *xdr = info->wi_xdr;
+
+	page_no = (info->wi_next_off + xdr->page_base) >> PAGE_SHIFT;
+	page_off = (info->wi_next_off + xdr->page_base) & ~PAGE_MASK;
+	info->wi_next_off += remaining;
+
+	sge_no = 0;
+	do {
+		sge_bytes = min_t(unsigned int, remaining,
+				  PAGE_SIZE - page_off);
+
+		sg_set_page(&sg[sge_no++], xdr->pages[page_no],
+			    sge_bytes, page_off);
+
+		remaining -= sge_bytes;
+		page_no++;
+		page_off = 0;
+	} while (remaining);
+
+	ctxt->rw_nents = sge_no;
+}
+
+/* Post Write WRs to send a portion of an xdr_buf containing
+ * an RPC Reply.
+ *
+ * If successful:
+ *  - chunk/segment position are updated
+ *  - Returns 0
+ *
+ * Otherwise a negative errno is returned.
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
+	if (!total)
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
+		ret = svc_rdma_send_write_ctx(rdma, ctxt, rs_offset + seg_off,
+					      rs_handle);
+		if (ret < 0)
+			goto out_senderr;
+
+		if (write_len == rs_length - seg_off) {
+			seg_no++;
+			seg_off = 0;
+		} else
+			seg_off += write_len;
+		remaining -= write_len;
+	} while (remaining);
+
+	info->wi_bytes_consumed += total;
+	info->wi_seg_no = seg_no;
+	info->wi_seg_off = seg_off;
+	return 0;
+
+out_overflow:
+	pr_err("svcrdma: inadequate space in Write chunk (%u)\n",
+	       info->wi_nsegs);
+	return -EIO;
+
+out_noctx:
+	pr_err("svcrdma: no R/W ctxs available\n");
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
+ *
+ * If successful:
+ *  - chunk/segment position are updated
+ *  - Returns 0
+ *
+ * Otherwise a negative errno is returned.
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
+ *
+ * If successful:
+ *  - chunk/segment position are updated
+ *  - Returns 0
+ *
+ * Otherwise a negative errno is returned.
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
+ * svc_rdma_send_write_list - Write all chunks in the Write list
+ * @rdma: controlling RDMA transport
+ * @wr_ch: Write list provided by client
+ * @rdma_resp: buffer containing transport header under construction
+ * @xdr: xdr_buf carrying an RPC Reply
+ *
+ * Returns zero on success, or a negative errno.
+ *
+ * Assumptions:
+ *  - Only one Write chunk, and it's the xdr_buf's entire pagelist
+ */
+int svc_rdma_send_write_list(struct svcxprt_rdma *rdma,
+			     __be32 *wr_ch, __be32 *rdma_resp,
+			     struct xdr_buf *xdr)
+{
+	struct svc_rdma_write_info info;
+	int ret;
+
+	svc_rdma_init_write_info(rdma, wr_ch, &info);
+
+	ret = svc_rdma_send_xdr_pagelist(&info, xdr);
+
+	svc_rdma_xdr_encode_write_list(rdma_resp, wr_ch,
+				       info.wi_bytes_consumed);
+	return ret;
+}
+
+/**
+ * svc_rdma_send_reply_chunk - Write all segments in the Reply chunk
+ * @rdma: controlling RDMA transport
+ * @rp_ch: Reply chunk provided by client
+ * @rdma_resp: buffer containing transport header for Reply
+ * @xdr: xdr_buf carrying an RPC Reply
+ *
+ * Returns zero if all consumed segments have been posted successfully,
+ * or a negative errno.
+ *
+ * Assumptions:
+ *  - The Reply chunk always carries the whole xdr_buf
+ */
+int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
+			      __be32 *rp_ch, __be32 *rdma_resp,
+			      struct xdr_buf *xdr)
+{
+	struct svc_rdma_write_info info;
+	int ret;
+
+	svc_rdma_init_write_info(rdma, rp_ch, &info);
+
+	ret = svc_rdma_send_xdr_kvec(&info, &xdr->head[0]);
+	if (ret < 0)
+		goto out;
+	ret = svc_rdma_send_xdr_pagelist(&info, xdr);
+	if (ret < 0)
+		goto out;
+	ret = svc_rdma_send_xdr_kvec(&info, &xdr->tail[0]);
+
+out:
+	svc_rdma_xdr_encode_reply_chunk(rdma_resp, rp_ch,
+					info.wi_bytes_consumed);
+	return ret;
+}
+
+/* Pull one Read chunk (segment) from the client.
+ *
+ * Returns zero if one or more RDMA Reads have been posted.  Otherwise,
+ * returns a negative errno if there is a Read list present but RDMA
+ * Reads could not be posted.
+ *
+ * For incoming Reads, @rqstp provides a page list containing sink pages.
+ * As pages are prepared for I/O, they are transferred to @head. After
+ * all Reads in the list have completed, svc_rdma_recvfrom builds an
+ * xdr_buf from the page list in @head.
+ *
+ * On entry, *page_no and *page_offset point into the rqstp's page list.
+ * On return, *page_no and *page_offset are updated to point to the next
+ * position in the page list.
+ */
+static int svc_rdma_recv_read_segment(struct svcxprt_rdma *rdma,
+				      struct svc_rdma_op_ctxt *head,
+				      struct svc_rqst *rqstp,
+				      unsigned int *page_no,
+				      unsigned int *page_offset,
+				      u32 rkey, u32 len, u64 offset,
+				      bool last)
+{
+	struct svc_rdma_rw_ctxt *ctxt;
+	struct ib_send_wr *first_wr;
+	unsigned int pg_no, seg_no;
+	u32 pg_off;
+	int ret;
+
+	dprintk("svcrdma: reading segment %u@0x%016llx:0x%08x\n",
+		len, offset, rkey);
+
+	ctxt = svc_rdma_get_rw_ctxt(rdma);
+	if (!ctxt)
+		return -ENOMEM;
+
+	pg_off = *page_offset;
+	pg_no = *page_no;
+	ctxt->rw_nents = PAGE_ALIGN(*page_offset + len) >> PAGE_SHIFT;
+	for (seg_no = 0; seg_no < ctxt->rw_nents; seg_no++) {
+		unsigned int seg_len = min_t(unsigned int, len, PAGE_SIZE - pg_off);
+
+		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
+		head->arg.page_len += seg_len;
+		head->arg.len += seg_len;
+		if (!pg_off)
+			head->count++;
+
+		sg_set_page(&ctxt->rw_sg[seg_no], rqstp->rq_arg.pages[pg_no],
+			    seg_len, pg_off);
+
+		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no + 1];
+		rqstp->rq_next_page = rqstp->rq_respages + 1;
+
+		pg_off += seg_len;
+		if (pg_off == PAGE_SIZE) {
+			pg_off = 0;
+			pg_no++;
+		}
+		len -= seg_len;
+	}
+
+	ret = rdma_rw_ctx_init(&ctxt->rw_ctx,
+			       rdma->sc_qp, rdma->sc_port_num,
+			       ctxt->rw_sg, ctxt->rw_nents,
+			       0, offset, rkey, DMA_FROM_DEVICE);
+	if (ret < 0)
+		goto out_err;
+
+	ctxt->rw_wrcount = ret;
+	ctxt->rw_dir = DMA_FROM_DEVICE;
+	ctxt->rw_cqe.done = svc_rdma_wc_read_ctx;
+	ctxt->rw_readctxt = last ? head : NULL;
+	first_wr = rdma_rw_ctx_wrs(&ctxt->rw_ctx,
+				   rdma->sc_qp, rdma->sc_port_num,
+				   &ctxt->rw_cqe, NULL);
+	atomic_add(ret, &rdma_stat_read);
+	ret = svc_rdma_post_send(rdma, first_wr, ret);
+	if (ret)
+		goto out_err;
+
+	*page_no = pg_no;
+	*page_offset = pg_off;
+	return 0;
+
+out_err:
+	svc_rdma_put_rw_ctxt(ctxt);
+	pr_err("svcrdma: failed to map read segment (%d)\n", ret);
+	return ret;
+}
+
+/* If there was additional inline content, append it to the end of arg.pages.
+ * Tail copy has to be done after the reader function has determined how many
+ * pages were consumed for RDMA Read.
+ */
+static int svc_rdma_copy_tail(struct svc_rqst *rqstp,
+			      struct svc_rdma_op_ctxt *head, u32 position,
+			      unsigned int page_offset, unsigned int page_no)
+{
+	char *srcp, *destp;
+	u32 byte_count;
+
+	srcp = head->arg.head[0].iov_base + position;
+	byte_count = head->arg.head[0].iov_len - position;
+	if (byte_count > PAGE_SIZE) {
+		dprintk("svcrdma: large tail unsupported\n");
+		return 0;
+	}
+
+	/* Fit as much of the tail on the current page as possible */
+	if (page_offset != PAGE_SIZE) {
+		destp = page_address(rqstp->rq_arg.pages[page_no]);
+		destp += page_offset;
+		while (byte_count--) {
+			*destp++ = *srcp++;
+			page_offset++;
+			if (page_offset == PAGE_SIZE && byte_count)
+				goto more;
+		}
+		goto done;
+	}
+
+more:
+	/* Fit the rest on the next page */
+	page_no++;
+	destp = page_address(rqstp->rq_arg.pages[page_no]);
+	while (byte_count--)
+		*destp++ = *srcp++;
+
+	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
+	rqstp->rq_next_page = rqstp->rq_respages + 1;
+
+done:
+	byte_count = head->arg.head[0].iov_len - position;
+	head->arg.page_len += byte_count;
+	head->arg.len += byte_count;
+	head->arg.buflen += byte_count;
+	return 1;
+}
+
+static unsigned int svc_rdma_read_chunk_count(__be32 *p)
+{
+	unsigned int nsegs;
+
+	for (nsegs = 0; *p != xdr_zero; p += rpcrdma_readchunk_maxsz)
+		nsegs++;
+	return nsegs;
+}
+
+/**
+ * svc_rdma_recv_read_list - Pull read chunks from the client
+ * @rdma: controlling RDMA transport
+ * @ch: pointer to Read list in the incoming transport header
+ * @head: pages under I/O collect here
+ * @rqstp: set of pages to use as Read sink buffers
+ *
+ * Returns one if RDMA Reads were posted successfully; returns
+ * zero if there was no Read list; or negative errno if there
+ * was a Read list present but Reads could not be posted.
+ *
+ * Assumptions:
+ * - Clients can send multiple Read chunks in a Read list, but
+ *   the chunks must all have the same value in their Position
+ *   field.
+ */
+int svc_rdma_recv_read_list(struct svcxprt_rdma *rdma, __be32 *ch,
+			    struct svc_rdma_op_ctxt *head,
+			    struct svc_rqst *rqstp)
+{
+	unsigned int page_no, page_offset;
+	u32 position;
+	__be32 *p;
+	bool last;
+	int ret;
+
+	p = ch;
+
+	/* Sanity check */
+	if (svc_rdma_read_chunk_count(p++) > RPCSVC_MAXPAGES)
+		return -EINVAL;
+
+	/* "head" keeps all the pages that comprise the request.
+	 */
+	head->arg.head[0] = rqstp->rq_arg.head[0];
+	head->arg.tail[0] = rqstp->rq_arg.tail[0];
+	head->hdr_count = head->count;
+	head->arg.page_base = 0;
+	head->arg.page_len = 0;
+	head->arg.len = rqstp->rq_arg.len;
+	head->arg.buflen = rqstp->rq_arg.buflen;
+
+	/* RDMA_NOMSG: RDMA Read data should land just after Receive data.
+	 */
+	position = be32_to_cpu(*p++);
+	if (position == 0) {
+		head->arg.pages = &head->pages[0];
+		page_offset = head->byte_len;
+	} else {
+		head->arg.pages = &head->pages[head->count];
+		page_offset = 0;
+	}
+
+	/* This server implementation supports only one Read chunk (of one
+	 * or more segments) per message. The list walk is terminated once
+	 * "position" changes.
+	 */
+	page_no = 0;
+	last = false;
+	while (!last) {
+		u32 rs_handle, rs_length;
+		u64 rs_offset;
+
+		rs_handle = be32_to_cpu(*p++),
+		rs_length = be32_to_cpu(*p++);
+		p = xdr_decode_hyper(p, &rs_offset);
+
+		/* Examine next read segment */
+		if (*p == xdr_zero ||
+		    ((*p != xdr_zero) && (be32_to_cpu(*(p + 1)) != position)))
+			last = true;
+
+		ret = svc_rdma_recv_read_segment(rdma, head, rqstp,
+					         &page_no, &page_offset,
+						 rs_handle, rs_length,
+						 rs_offset, last);
+		if (ret < 0)
+			goto out;
+
+		p += 2;
+	}
+
+	/* Read list may need XDR round-up (see RFC 5666, s. 3.7) */
+	if (page_offset & 3) {
+		u32 pad = 4 - (page_offset & 3);
+
+		head->arg.tail[0].iov_len += pad;
+		head->arg.len += pad;
+		head->arg.buflen += pad;
+		page_offset += pad;
+	}
+
+	ret = 1;
+	if (position && position < head->arg.head[0].iov_len)
+		ret = svc_rdma_copy_tail(rqstp, head, position,
+					 page_offset, page_no);
+	head->arg.head[0].iov_len = position;
+	head->position = position;
+
+ out:
+	/* Detach arg pages. svc_recv will replenish them */
+	for (page_no = 0;
+	     &rqstp->rq_pages[page_no] < rqstp->rq_respages; page_no++)
+		rqstp->rq_pages[page_no] = NULL;
+	return ret;
+}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 7150201..ba43f75 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -363,7 +363,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		}
 	}
 	/* Update the req with the number of chunks actually used */
-	svc_rdma_xdr_encode_write_list(rdma_resp, chunk_no);
+	svc_rdma_old_encode_write_list(rdma_resp, chunk_no);
 
 	return rqstp->rq_res.page_len;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3258af7..14ecac4 100644
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
 
 	if (listener)
@@ -1032,6 +1034,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt, newxprt->sc_cm_id);
 
 	dev = newxprt->sc_cm_id->device;
+	newxprt->sc_port_num = newxprt->sc_cm_id->port_num;
 
 	/* Qualify the transport resource defaults with the
 	 * capabilities of this particular device */
@@ -1281,6 +1284,7 @@ static void __svc_rdma_free(struct work_struct *work)
 	}
 
 	rdma_dealloc_frmr_q(rdma);
+	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_destroy_ctxts(rdma);
 	svc_rdma_destroy_maps(rdma);
 
@@ -1383,3 +1387,55 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 	}
 	return ret;
 }
+
+/**
+ * svc_rdma_post_send - Post a chain of send WRs
+ * @rdma: RPC-over-RDMA transport control block
+ * @first_wr: chain of WRs to be posted
+ * @num_wrs: number of WRs to be posted
+ *
+ * Returns zero if one or more WRs were posted successfully, or
+ * a negative errno if none could be posted.
+ *
+ * Sleeps if transport's Send Queue is congested. If the connection
+ * closes, posts are still allowed, but they just flush through.
+ *
+ * Assumptions:
+ * - If ib_post_send() succeeds, only one completion is expected,
+ *   even if one or more WRs are flushed. This is true when posting
+ *   an rdma_rw_ctx or when posting a single signaled WR.
+ */
+int svc_rdma_post_send(struct svcxprt_rdma *rdma,
+		       struct ib_send_wr *first_wr,
+		       int num_wrs)
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
+		} else {
+			atomic_inc(&rdma_stat_sq_starve);
+			atomic_add(num_wrs, &rdma->sc_sq_avail);
+			wait_event(rdma->sc_send_wait,
+				   atomic_read(&rdma->sc_sq_avail) > num_wrs);
+		}
+	} while (1);
+
+	pr_err("svcrdma: post_send rc=%d; SQ avail=%d/%u\n",
+	       ret, atomic_read(&rdma->sc_sq_avail), rdma->sc_sq_depth);
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

