Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35385 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbbKWWOY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 17:14:24 -0500
Subject: [PATCH v1 4/9] xprtrdma: Add ro_unmap_sync method for FRWR
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Nov 2015 17:14:22 -0500
Message-ID: <20151123221422.32702.25360.stgit@manet.1015granger.net>
In-Reply-To: <20151123220627.32702.62667.stgit@manet.1015granger.net>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FRWR's ro_unmap is asynchronous. The new ro_unmap_sync posts
LOCAL_INV Work Requests and waits for them to complete before
returning.

Note also, DMA unmapping is now done _after_ invalidation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |  137 ++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 2 files changed, 135 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 31a4578..5d58008 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -245,12 +245,14 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
 }
 
-/* If FAST_REG or LOCAL_INV failed, indicate the frmr needs to be reset. */
+/* If FAST_REG or LOCAL_INV failed, indicate the frmr needs
+ * to be reset.
+ *
+ * WARNING: Only wr_id and status are reliable at this point
+ */
 static void
-frwr_sendcompletion(struct ib_wc *wc)
+__frwr_sendcompletion_flush(struct ib_wc *wc, struct rpcrdma_mw *r)
 {
-	struct rpcrdma_mw *r;
-
 	if (likely(wc->status == IB_WC_SUCCESS))
 		return;
 
@@ -261,9 +263,23 @@ frwr_sendcompletion(struct ib_wc *wc)
 	else
 		pr_warn("RPC:       %s: frmr %p error, status %s (%d)\n",
 			__func__, r, ib_wc_status_msg(wc->status), wc->status);
+
 	r->r.frmr.fr_state = FRMR_IS_STALE;
 }
 
+static void
+frwr_sendcompletion(struct ib_wc *wc)
+{
+	struct rpcrdma_mw *r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+	struct rpcrdma_frmr *f = &r->r.frmr;
+
+	if (unlikely(wc->status != IB_WC_SUCCESS))
+		__frwr_sendcompletion_flush(wc, r);
+
+	if (f->fr_waiter)
+		complete(&f->fr_linv_done);
+}
+
 static int
 frwr_op_init(struct rpcrdma_xprt *r_xprt)
 {
@@ -335,6 +351,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	} while (mw->r.frmr.fr_state != FRMR_IS_INVALID);
 	frmr = &mw->r.frmr;
 	frmr->fr_state = FRMR_IS_VALID;
+	frmr->fr_waiter = false;
 	mr = frmr->fr_mr;
 	reg_wr = &frmr->fr_regwr;
 
@@ -414,6 +431,117 @@ out_senderr:
 	return rc;
 }
 
+static struct ib_send_wr *
+__frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
+{
+	struct rpcrdma_mw *mw = seg->rl_mw;
+	struct rpcrdma_frmr *f = &mw->r.frmr;
+	struct ib_send_wr *invalidate_wr;
+
+	f->fr_waiter = false;
+	f->fr_state = FRMR_IS_INVALID;
+	invalidate_wr = &f->fr_invwr;
+
+	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
+	invalidate_wr->wr_id = (unsigned long)(void *)mw;
+	invalidate_wr->opcode = IB_WR_LOCAL_INV;
+	invalidate_wr->ex.invalidate_rkey = f->fr_mr->rkey;
+
+	return invalidate_wr;
+}
+
+static void
+__frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
+		 int rc)
+{
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
+	struct rpcrdma_mw *mw = seg->rl_mw;
+	int nsegs = seg->mr_nsegs;
+
+	seg->rl_mw = NULL;
+
+	while (nsegs--)
+		rpcrdma_unmap_one(device, seg++);
+
+	if (!rc)
+		rpcrdma_put_mw(r_xprt, mw);
+	else
+		__frwr_queue_recovery(mw);
+}
+
+/* Invalidate all memory regions that were registered for "req".
+ *
+ * Sleeps until it is safe for the host CPU to access the
+ * previously mapped memory regions.
+ */
+static void
+frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+{
+	struct ib_send_wr *invalidate_wrs, *pos, *prev, *bad_wr;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_mr_seg *seg;
+	unsigned int i, nchunks;
+	struct rpcrdma_frmr *f;
+	int rc;
+
+	dprintk("RPC:       %s: req %p\n", __func__, req);
+
+	/* ORDER: Invalidate all of the req's MRs first
+	 *
+	 * Chain the LOCAL_INV Work Requests and post them with
+	 * a single ib_post_send() call.
+	 */
+	invalidate_wrs = pos = prev = NULL;
+	seg = NULL;
+	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
+		seg = &req->rl_segments[i];
+
+		pos = __frwr_prepare_linv_wr(seg);
+
+		if (!invalidate_wrs)
+			invalidate_wrs = pos;
+		else
+			prev->next = pos;
+		prev = pos;
+
+		i += seg->mr_nsegs;
+	}
+	f = &seg->rl_mw->r.frmr;
+
+	/* Strong send queue ordering guarantees that when the
+	 * last WR in the chain completes, all WRs in the chain
+	 * are complete.
+	 */
+	f->fr_invwr.send_flags = IB_SEND_SIGNALED;
+	f->fr_waiter = true;
+	init_completion(&f->fr_linv_done);
+	INIT_CQCOUNT(&r_xprt->rx_ep);
+
+	/* Transport disconnect drains the receive CQ before it
+	 * replaces the QP. The RPC reply handler won't call us
+	 * unless ri_id->qp is a valid pointer.
+	 */
+	rc = ib_post_send(ia->ri_id->qp, invalidate_wrs, &bad_wr);
+	if (rc)
+		pr_warn("%s: ib_post_send failed %i\n", __func__, rc);
+
+	wait_for_completion(&f->fr_linv_done);
+
+	/* ORDER: Now DMA unmap all of the req's MRs, and return
+	 * them to the free MW list.
+	 */
+	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
+		seg = &req->rl_segments[i];
+
+		__frwr_dma_unmap(r_xprt, seg, rc);
+
+		i += seg->mr_nsegs;
+		seg->mr_nsegs = 0;
+	}
+
+	req->rl_nchunks = 0;
+}
+
 /* Post a LOCAL_INV Work Request to prevent further remote access
  * via RDMA READ or RDMA WRITE.
  */
@@ -473,6 +601,7 @@ frwr_op_destroy(struct rpcrdma_buffer *buf)
 
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
+	.ro_unmap_sync			= frwr_op_unmap_sync,
 	.ro_unmap			= frwr_op_unmap,
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index bd2022e..45dd0b7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -207,6 +207,8 @@ struct rpcrdma_frmr {
 	enum rpcrdma_frmr_state		fr_state;
 	struct work_struct		fr_work;
 	struct rpcrdma_xprt		*fr_xprt;
+	bool				fr_waiter;
+	struct completion		fr_linv_done;;
 	struct ib_reg_wr		fr_regwr;
 	struct ib_send_wr		fr_invwr;
 };

