Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34680 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424839AbcBRRpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:45:00 -0500
Subject: [PATCH v3 09/10] svcrdma: Use new CQ API for RPC-over-RDMA server
 receive CQs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:44:59 -0500
Message-ID: <20160218174459.12825.55534.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling ib_poll_cq() to sort through WCs during a completion is a
common pattern amongst RDMA consumers. Since commit 14d3a3b2498e
("IB: add a proper completion queue abstraction"), WC sorting can
be handled by the IB core.

By converting to this new API, svcrdma is made a better neighbor to
other RDMA consumers, as it allows the core to schedule the delivery
of completions more fairly amongst all active consumers.

Because each ib_cqe carries a pointer to a completion method, the
core can now post operations on a consumer's QP, and handle the
completions itself.

svcrdma receive completions no longer use the dto_tasklet. Each
polled Receive WC is now handled individually in soft IRQ context.

The server transport's rdma_stat_rq_poll and rdma_stat_rq_prod
metrics are no longer updated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  129 +++++++++---------------------
 2 files changed, 40 insertions(+), 91 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 4ce7b74..7de9cbb 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -75,6 +75,7 @@ struct svc_rdma_op_ctxt {
 	struct svc_rdma_fastreg_mr *frmr;
 	int hdr_count;
 	struct xdr_buf arg;
+	struct ib_cqe cqe;
 	struct list_head dto_q;
 	enum ib_wr_opcode wr_op;
 	enum ib_wc_status wc_status;
@@ -174,7 +175,6 @@ struct svcxprt_rdma {
 	struct work_struct   sc_work;
 };
 /* sc_flags */
-#define RDMAXPRT_RQ_PENDING	1
 #define RDMAXPRT_SQ_PENDING	2
 #define RDMAXPRT_CONN_PENDING	3
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 15c8fa3e..5dfa1b6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -68,7 +68,6 @@ static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
 static int svc_rdma_has_wspace(struct svc_xprt *xprt);
 static int svc_rdma_secure_port(struct svc_rqst *);
-static void rq_cq_reap(struct svcxprt_rdma *xprt);
 static void sq_cq_reap(struct svcxprt_rdma *xprt);
 
 static DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
@@ -413,7 +412,6 @@ static void dto_tasklet_func(unsigned long data)
 		list_del_init(&xprt->sc_dto_q);
 		spin_unlock_irqrestore(&dto_lock, flags);
 
-		rq_cq_reap(xprt);
 		sq_cq_reap(xprt);
 
 		svc_xprt_put(&xprt->sc_xprt);
@@ -422,93 +420,48 @@ static void dto_tasklet_func(unsigned long data)
 	spin_unlock_irqrestore(&dto_lock, flags);
 }
 
-/*
- * Receive Queue Completion Handler
- *
- * Since an RQ completion handler is called on interrupt context, we
- * need to defer the handling of the I/O to a tasklet
- */
-static void rq_comp_handler(struct ib_cq *cq, void *cq_context)
-{
-	struct svcxprt_rdma *xprt = cq_context;
-	unsigned long flags;
-
-	/* Guard against unconditional flush call for destroyed QP */
-	if (atomic_read(&xprt->sc_xprt.xpt_ref.refcount)==0)
-		return;
-
-	/*
-	 * Set the bit regardless of whether or not it's on the list
-	 * because it may be on the list already due to an SQ
-	 * completion.
-	 */
-	set_bit(RDMAXPRT_RQ_PENDING, &xprt->sc_flags);
-
-	/*
-	 * If this transport is not already on the DTO transport queue,
-	 * add it
-	 */
-	spin_lock_irqsave(&dto_lock, flags);
-	if (list_empty(&xprt->sc_dto_q)) {
-		svc_xprt_get(&xprt->sc_xprt);
-		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
-	}
-	spin_unlock_irqrestore(&dto_lock, flags);
-
-	/* Tasklet does all the work to avoid irqsave locks. */
-	tasklet_schedule(&dto_tasklet);
-}
-
-/*
- * rq_cq_reap - Process the RQ CQ.
+/**
+ * svc_rdma_wc_receive - Invoked by RDMA provider for each polled Receive WC
+ * @cq:        completion queue
+ * @wc:        completed WR
  *
- * Take all completing WC off the CQE and enqueue the associated DTO
- * context on the dto_q for the transport.
- *
- * Note that caller must hold a transport reference.
  */
-static void rq_cq_reap(struct svcxprt_rdma *xprt)
+static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 {
-	int ret;
-	struct ib_wc wc;
-	struct svc_rdma_op_ctxt *ctxt = NULL;
-
-	if (!test_and_clear_bit(RDMAXPRT_RQ_PENDING, &xprt->sc_flags))
-		return;
+	struct svcxprt_rdma *xprt = cq->cq_context;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct svc_rdma_op_ctxt *ctxt;
 
-	ib_req_notify_cq(xprt->sc_rq_cq, IB_CQ_NEXT_COMP);
-	atomic_inc(&rdma_stat_rq_poll);
+	/* WARNING: Only wc->wr_cqe and wc->status are reliable */
+	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
+	ctxt->wc_status = wc->status;
+	svc_rdma_unmap_dma(ctxt);
 
-	while ((ret = ib_poll_cq(xprt->sc_rq_cq, 1, &wc)) > 0) {
-		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
-		ctxt->wc_status = wc.status;
-		ctxt->byte_len = wc.byte_len;
-		svc_rdma_unmap_dma(ctxt);
-		if (wc.status != IB_WC_SUCCESS) {
-			/* Close the transport */
-			dprintk("svcrdma: transport closing putting ctxt %p\n", ctxt);
-			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-			svc_rdma_put_context(ctxt, 1);
-			svc_xprt_put(&xprt->sc_xprt);
-			continue;
-		}
-		spin_lock_bh(&xprt->sc_rq_dto_lock);
-		list_add_tail(&ctxt->dto_q, &xprt->sc_rq_dto_q);
-		spin_unlock_bh(&xprt->sc_rq_dto_lock);
-		svc_xprt_put(&xprt->sc_xprt);
-	}
+	if (wc->status != IB_WC_SUCCESS)
+		goto flushed;
 
-	if (ctxt)
-		atomic_inc(&rdma_stat_rq_prod);
+	/* All wc fields are now known to be valid */
+	ctxt->byte_len = wc->byte_len;
+	spin_lock(&xprt->sc_rq_dto_lock);
+	list_add_tail(&ctxt->dto_q, &xprt->sc_rq_dto_q);
+	spin_unlock(&xprt->sc_rq_dto_lock);
 
 	set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-	/*
-	 * If data arrived before established event,
-	 * don't enqueue. This defers RPC I/O until the
-	 * RDMA connection is complete.
-	 */
-	if (!test_bit(RDMAXPRT_CONN_PENDING, &xprt->sc_flags))
-		svc_xprt_enqueue(&xprt->sc_xprt);
+	if (test_bit(RDMAXPRT_CONN_PENDING, &xprt->sc_flags))
+		goto out;
+	svc_xprt_enqueue(&xprt->sc_xprt);
+	goto out;
+
+flushed:
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_warn("svcrdma: receive: %s (%u/0x%x)\n",
+			ib_wc_status_msg(wc->status),
+			wc->status, wc->vendor_err);
+	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+	svc_rdma_put_context(ctxt, 1);
+
+out:
+	svc_xprt_put(&xprt->sc_xprt);
 }
 
 /*
@@ -681,6 +634,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	ctxt = svc_rdma_get_context(xprt);
 	buflen = 0;
 	ctxt->direction = DMA_FROM_DEVICE;
+	ctxt->cqe.done = svc_rdma_wc_receive;
 	for (sge_no = 0; buflen < xprt->sc_max_req_size; sge_no++) {
 		if (sge_no >= xprt->sc_max_sge) {
 			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
@@ -705,7 +659,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	recv_wr.next = NULL;
 	recv_wr.sg_list = &ctxt->sge[0];
 	recv_wr.num_sge = ctxt->count;
-	recv_wr.wr_id = (u64)(unsigned long)ctxt;
+	recv_wr.wr_cqe = &ctxt->cqe;
 
 	svc_xprt_get(&xprt->sc_xprt);
 	ret = ib_post_recv(xprt->sc_qp, &recv_wr, &bad_recv_wr);
@@ -1094,12 +1048,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
 	}
-	cq_attr.cqe = newxprt->sc_rq_depth;
-	newxprt->sc_rq_cq = ib_create_cq(dev,
-					 rq_comp_handler,
-					 cq_event_handler,
-					 newxprt,
-					 &cq_attr);
+	newxprt->sc_rq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_rq_depth,
+					0, IB_POLL_SOFTIRQ);
 	if (IS_ERR(newxprt->sc_rq_cq)) {
 		dprintk("svcrdma: error creating RQ CQ for connect request\n");
 		goto errout;
@@ -1193,7 +1143,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 * miss the first message
 	 */
 	ib_req_notify_cq(newxprt->sc_sq_cq, IB_CQ_NEXT_COMP);
-	ib_req_notify_cq(newxprt->sc_rq_cq, IB_CQ_NEXT_COMP);
 
 	/* Accept Connection */
 	set_bit(RDMAXPRT_CONN_PENDING, &newxprt->sc_flags);
@@ -1337,7 +1286,7 @@ static void __svc_rdma_free(struct work_struct *work)
 		ib_destroy_cq(rdma->sc_sq_cq);
 
 	if (rdma->sc_rq_cq && !IS_ERR(rdma->sc_rq_cq))
-		ib_destroy_cq(rdma->sc_rq_cq);
+		ib_free_cq(rdma->sc_rq_cq);
 
 	if (rdma->sc_pd && !IS_ERR(rdma->sc_pd))
 		ib_dealloc_pd(rdma->sc_pd);

