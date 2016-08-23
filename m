Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33604 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753517AbcHWRy3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 13:54:29 -0400
Subject: [PATCH v2 17/22] xprtrdma: Basic support for Remote Invalidation
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:54:22 -0400
Message-ID: <20160823175422.13038.39238.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have frwr's ro_unmap_sync recognize an invalidated rkey that appears
as part of a Receive completion. Local invalidation can be skipped
for that rkey.

Use an out-of-band signaling mechanism to indicate to the server
that the client is prepared to receive RDMA Send With Invalidate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    2 ++
 net/sunrpc/xprtrdma/frwr_ops.c  |   13 +++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c  |   18 ++++++++++++++----
 net/sunrpc/xprtrdma/transport.c |    5 +++--
 net/sunrpc/xprtrdma/verbs.c     |    8 +++++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++++
 6 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 16690a1..1ebb09e 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -273,6 +273,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 */
 	list_for_each_entry(mw, &req->rl_registered, mw_list)
 		list_add_tail(&mw->fmr.fm_mr->list, &unmap_list);
+	r_xprt->rx_stats.local_inv_needed++;
 	rc = ib_unmap_fmr(&unmap_list);
 	if (rc)
 		goto out_reset;
@@ -330,4 +331,5 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_init_mr			= fmr_op_init_mr,
 	.ro_release_mr			= fmr_op_release_mr,
 	.ro_displayname			= "fmr",
+	.ro_send_w_inv_ok		= 0,
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fcfcf3a..e82d5cf 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -67,6 +67,8 @@
  * pending send queue WRs before the transport is reconnected.
  */
 
+#include <linux/sunrpc/rpc_rdma.h>
+
 #include "xprt_rdma.h"
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
@@ -471,6 +473,7 @@ static void
 frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
 	struct ib_send_wr *invalidate_wrs, *pos, *prev, *bad_wr;
+	struct rpcrdma_rep *rep = req->rl_reply;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mw *mw, *tmp;
 	struct rpcrdma_frmr *f;
@@ -486,6 +489,12 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	f = NULL;
 	invalidate_wrs = pos = prev = NULL;
 	list_for_each_entry(mw, &req->rl_registered, mw_list) {
+		if ((rep->rr_wc_flags & IB_WC_WITH_INVALIDATE) &&
+		    (mw->mw_handle == rep->rr_inv_rkey)) {
+			mw->frmr.fr_state = FRMR_IS_INVALID;
+			continue;
+		}
+
 		pos = __frwr_prepare_linv_wr(mw);
 
 		if (!invalidate_wrs)
@@ -495,6 +504,8 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		prev = pos;
 		f = &mw->frmr;
 	}
+	if (!f)
+		goto unmap;
 
 	/* Strong send queue ordering guarantees that when the
 	 * last WR in the chain completes, all WRs in the chain
@@ -509,6 +520,7 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * replaces the QP. The RPC reply handler won't call us
 	 * unless ri_id->qp is a valid pointer.
 	 */
+	r_xprt->rx_stats.local_inv_needed++;
 	rc = ib_post_send(ia->ri_id->qp, invalidate_wrs, &bad_wr);
 	if (rc)
 		goto reset_mrs;
@@ -575,4 +587,5 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_init_mr			= frwr_op_init_mr,
 	.ro_release_mr			= frwr_op_release_mr,
 	.ro_displayname			= "frwr",
+	.ro_send_w_inv_ok		= RPCRDMA_CMP_F_SND_W_INV_OK,
 };
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index ea734c2..31a434d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -231,7 +231,8 @@ rpcrdma_convert_kvec(struct kvec *vec, struct rpcrdma_mr_seg *seg, int n)
 
 static int
 rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
-	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg)
+	enum rpcrdma_chunktype type, struct rpcrdma_mr_seg *seg,
+	bool reminv_expected)
 {
 	int len, n, p, page_base;
 	struct page **ppages;
@@ -273,6 +274,13 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	if (type == rpcrdma_readch)
 		return n;
 
+	/* When encoding the Write list, some servers need to see an extra
+	 * segment for odd-length Write chunks. The upper layer provides
+	 * space in the tail iovec for this purpose.
+	 */
+	if (type == rpcrdma_writech && reminv_expected)
+		return n;
+
 	if (xdrbuf->tail[0].iov_len) {
 		/* the rpcrdma protocol allows us to omit any trailing
 		 * xdr pad bytes, saving the server an RDMA operation. */
@@ -329,7 +337,7 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 	if (rtype == rpcrdma_areadch)
 		pos = 0;
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(&rqst->rq_snd_buf, pos, rtype, seg);
+	nsegs = rpcrdma_convert_iovs(&rqst->rq_snd_buf, pos, rtype, seg, false);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
@@ -393,7 +401,8 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	seg = req->rl_segments;
 	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf,
 				     rqst->rq_rcv_buf.head[0].iov_len,
-				     wtype, seg);
+				     wtype, seg,
+				     r_xprt->rx_ia.ri_reminv_expected);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
@@ -458,7 +467,8 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 	}
 
 	seg = req->rl_segments;
-	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf, 0, wtype, seg);
+	nsegs = rpcrdma_convert_iovs(&rqst->rq_rcv_buf, 0, wtype, seg,
+				     r_xprt->rx_ia.ri_reminv_expected);
 	if (nsegs < 0)
 		return ERR_PTR(nsegs);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5adaa1d..7e11d71 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -730,10 +730,11 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   r_xprt->rx_stats.failed_marshal_count,
 		   r_xprt->rx_stats.bad_reply_count,
 		   r_xprt->rx_stats.nomsg_call_count);
-	seq_printf(seq, "%lu %lu %lu\n",
+	seq_printf(seq, "%lu %lu %lu %lu\n",
 		   r_xprt->rx_stats.mrs_recovered,
 		   r_xprt->rx_stats.mrs_orphaned,
-		   r_xprt->rx_stats.mrs_allocated);
+		   r_xprt->rx_stats.mrs_allocated,
+		   r_xprt->rx_stats.local_inv_needed);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7cdfa2a..03ba529 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -184,6 +184,9 @@ rpcrdma_receive_wc(struct ib_cq *cq, struct ib_wc *wc)
 		__func__, rep, wc->byte_len);
 
 	rep->rr_len = wc->byte_len;
+	rep->rr_wc_flags = wc->wc_flags;
+	rep->rr_inv_rkey = wc->ex.invalidate_rkey;
+
 	ib_dma_sync_single_for_cpu(rep->rr_device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
@@ -211,12 +214,15 @@ rpcrdma_update_connect_private(struct rpcrdma_xprt *r_xprt,
 	const struct rpcrdma_connect_private *pmsg = param->private_data;
 	unsigned int rsize, wsize;
 
+	/* Default settings for RPC-over-RDMA Version One */
+	r_xprt->rx_ia.ri_reminv_expected = false;
 	rsize = RPCRDMA_V1_DEF_INLINE_SIZE;
 	wsize = RPCRDMA_V1_DEF_INLINE_SIZE;
 
 	if (pmsg &&
 	    pmsg->cp_magic == rpcrdma_cmp_magic &&
 	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
+		r_xprt->rx_ia.ri_reminv_expected = true;
 		rsize = rpcrdma_decode_buffer_size(pmsg->cp_send_size);
 		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
 	}
@@ -567,7 +573,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	/* Prepare RDMA-CM private message */
 	pmsg->cp_magic = rpcrdma_cmp_magic;
 	pmsg->cp_version = RPCRDMA_CMP_VERSION;
-	pmsg->cp_flags = 0;
+	pmsg->cp_flags |= ia->ri_ops->ro_send_w_inv_ok;
 	pmsg->cp_send_size = rpcrdma_encode_buffer_size(cdata->inline_wsize);
 	pmsg->cp_recv_size = rpcrdma_encode_buffer_size(cdata->inline_rsize);
 	ep->rep_remote_cma.private_data = pmsg;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f108518..84cbbe9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -74,6 +74,7 @@ struct rpcrdma_ia {
 	unsigned int		ri_max_frmr_depth;
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
+	bool			ri_reminv_expected;
 	struct ib_qp_attr	ri_qp_attr;
 	struct ib_qp_init_attr	ri_qp_init_attr;
 };
@@ -187,6 +188,8 @@ enum {
 struct rpcrdma_rep {
 	struct ib_cqe		rr_cqe;
 	unsigned int		rr_len;
+	int			rr_wc_flags;
+	u32			rr_inv_rkey;
 	struct ib_device	*rr_device;
 	struct rpcrdma_xprt	*rr_rxprt;
 	struct work_struct	rr_work;
@@ -384,6 +387,7 @@ struct rpcrdma_stats {
 	unsigned long		mrs_recovered;
 	unsigned long		mrs_orphaned;
 	unsigned long		mrs_allocated;
+	unsigned long		local_inv_needed;
 };
 
 /*
@@ -407,6 +411,7 @@ struct rpcrdma_memreg_ops {
 				      struct rpcrdma_mw *);
 	void		(*ro_release_mr)(struct rpcrdma_mw *);
 	const char	*ro_displayname;
+	const int	ro_send_w_inv_ok;
 };
 
 extern const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops;

