Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:54205 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470Ab1BITpe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 14:45:34 -0500
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 2/2] RPCRDMA: Fix FRMR registration/invalidate handling.
To: Trond.Myklebust@netapp.com
Cc: spelic@shiftmail.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Wed, 09 Feb 2011 13:45:34 -0600
Message-ID: <20110209194533.22358.37966.stgit@build.ogc.int>
In-Reply-To: <20110209194430.22358.46254.stgit@build.ogc.int>
References: <20110209194430.22358.46254.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When the rpc_memreg_strategy is 5, FRMR are used to map RPC data.
This mode uses an FRMR to map the RPC data, then invalidates
(i.e. unregisers) the data in xprt_rdma_free. These FRMR are used
across connections on the same mount, i.e. if the connection goes
away on an idle timeout and reconnects later, the FRMR are not
destroyed and recreated.

This creates a problem for transport errors because the WR that
invalidate an FRMR may be flushed (i.e. fail) leaving the
FRMR valid. When the FRMR is later used to map an RPC it will fail,
tearing down the transport and starting over. Over time, more and
more of the FRMR pool end up in the wrong state resulting in
seemingly random disconnects.

This fix keeps track of the FRMR state explicitly by setting it's
state based on the successful completion of a reg/inv WR. If the FRMR
is ever used and found to be in the wrong state, an invalidate WR
is prepended, re-syncing the FRMR state and avoiding the connection loss.

Signed-off-by: Tom Tucker <tom@ogc.us>
---

 net/sunrpc/xprtrdma/verbs.c     |   52 +++++++++++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 45 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5f4c7b3..570f08d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -144,6 +144,7 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
 static inline
 void rpcrdma_event_process(struct ib_wc *wc)
 {
+	struct rpcrdma_mw *frmr;
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long) wc->wr_id;
 
@@ -154,15 +155,23 @@ void rpcrdma_event_process(struct ib_wc *wc)
 		return;
 
 	if (IB_WC_SUCCESS != wc->status) {
-		dprintk("RPC:       %s: %s WC status %X, connection lost\n",
-			__func__, (wc->opcode & IB_WC_RECV) ? "recv" : "send",
-			 wc->status);
+		dprintk("RPC:       %s: WC opcode %d status %X, connection lost\n",
+			__func__, wc->opcode, wc->status);
 		rep->rr_len = ~0U;
-		rpcrdma_schedule_tasklet(rep);
+		if (wc->opcode != IB_WC_FAST_REG_MR && wc->opcode != IB_WC_LOCAL_INV)
+			rpcrdma_schedule_tasklet(rep);
 		return;
 	}
 
 	switch (wc->opcode) {
+	case IB_WC_FAST_REG_MR:
+		frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+		frmr->r.frmr.state = FRMR_IS_VALID;
+		break;
+	case IB_WC_LOCAL_INV:
+		frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+		frmr->r.frmr.state = FRMR_IS_INVALID;
+		break;
 	case IB_WC_RECV:
 		rep->rr_len = wc->byte_len;
 		ib_dma_sync_single_for_cpu(
@@ -1450,6 +1459,11 @@ rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, int writing)
 		seg->mr_dma = ib_dma_map_single(ia->ri_id->device,
 				seg->mr_offset,
 				seg->mr_dmalen, seg->mr_dir);
+	if (ib_dma_mapping_error(ia->ri_id->device, seg->mr_dma)) {
+		dprintk("RPC:       %s: mr_dma %llx mr_offset %p mr_dma_len %zu\n",
+			__func__,
+			seg->mr_dma, seg->mr_offset, seg->mr_dmalen);
+	}
 }
 
 static void
@@ -1469,7 +1483,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_send_wr frmr_wr, *bad_wr;
+	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
+
 	u8 key;
 	int len, pageoff;
 	int i, rc;
@@ -1484,6 +1499,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		rpcrdma_map_one(ia, seg, writing);
 		seg1->mr_chunk.rl_mw->r.frmr.fr_pgl->page_list[i] = seg->mr_dma;
 		len += seg->mr_len;
+		BUG_ON(seg->mr_len > PAGE_SIZE);
 		++seg;
 		++i;
 		/* Check for holes */
@@ -1494,26 +1510,45 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, seg1->mr_chunk.rl_mw, i);
 
+	if (unlikely(seg1->mr_chunk.rl_mw->r.frmr.state == FRMR_IS_VALID)) {
+		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
+			__func__,
+			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey);
+		/* Invalidate before using. */
+		memset(&invalidate_wr, 0, sizeof invalidate_wr);
+		invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
+		invalidate_wr.next = &frmr_wr;
+		invalidate_wr.opcode = IB_WR_LOCAL_INV;
+		invalidate_wr.send_flags = IB_SEND_SIGNALED;
+		invalidate_wr.ex.invalidate_rkey =
+			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+		DECR_CQCOUNT(&r_xprt->rx_ep);
+		post_wr = &invalidate_wr;
+	} else
+		post_wr = &frmr_wr;
+
 	/* Bump the key */
 	key = (u8)(seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(seg1->mr_chunk.rl_mw->r.frmr.fr_mr, ++key);
 
 	/* Prepare FRMR WR */
 	memset(&frmr_wr, 0, sizeof frmr_wr);
+	frmr_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
-	frmr_wr.send_flags = 0;			/* unsignaled */
+	frmr_wr.send_flags = IB_SEND_SIGNALED;
 	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
 	frmr_wr.wr.fast_reg.page_list = seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
 	frmr_wr.wr.fast_reg.page_list_len = i;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = i << PAGE_SHIFT;
+	BUG_ON(frmr_wr.wr.fast_reg.length < len);
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	rc = ib_post_send(ia->ri_id->qp, &frmr_wr, &bad_wr);
+	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
 
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
@@ -1542,8 +1577,9 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 		rpcrdma_unmap_one(ia, seg++);
 
 	memset(&invalidate_wr, 0, sizeof invalidate_wr);
+	invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.send_flags = 0;			/* unsignaled */
+	invalidate_wr.send_flags = IB_SEND_SIGNALED;
 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c7a7eba..cae761a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -164,6 +164,7 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 				struct {
 					struct ib_fast_reg_page_list *fr_pgl;
 					struct ib_mr *fr_mr;
+					enum { FRMR_IS_INVALID, FRMR_IS_VALID  } state;
 				} frmr;
 			} r;
 			struct list_head mw_list;

