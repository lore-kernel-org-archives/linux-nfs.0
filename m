Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34899 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945930AbcBRRbe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:31:34 -0500
Subject: [PATCH v2 12/12] xprtrdma: Use new CQ API for RPC-over-RDMA client
 send CQs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:31:32 -0500
Message-ID: <20160218173132.14009.677.stgit@manet.1015granger.net>
In-Reply-To: <20160218172449.14009.47311.stgit@manet.1015granger.net>
References: <20160218172449.14009.47311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling ib_poll_cq() to sort through WCs during a completion is a
common pattern amongst RDMA consumers. Since commit 14d3a3b2498e
("IB: add a proper completion queue abstraction"), WC sorting can
be handled by the IB core.

By converting to this new API, xprtrdma is made a better neighbor to
other RDMA consumers, as it allows the core to schedule the delivery
of completions more fairly amongst all active consumers.

Because each ib_cqe carries a pointer to a completion method, the
core can now post its own operations on a consumer's QP, and handle
the completions itself, without changes to the consumer.

Send completions were previously handled entirely in the completion
upcall handler (ie, deferring to a process context is unneeded).
Thus IB_POLL_SOFTIRQ is a direct replacement for the current
xprtrdma send code path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   99 +++++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/verbs.c     |  107 +++++++--------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 +---
 3 files changed, 91 insertions(+), 125 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 0cb9efa..83c4015 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -158,6 +158,8 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
 
 	sg_init_table(f->sg, depth);
 
+	init_completion(&f->fr_linv_done);
+
 	return 0;
 
 out_mr_err:
@@ -244,39 +246,76 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
 }
 
-/* If FAST_REG or LOCAL_INV failed, indicate the frmr needs
- * to be reset.
+static void
+__frwr_sendcompletion_flush(struct ib_wc *wc, struct rpcrdma_frmr *frmr,
+			    const char *wr)
+{
+	frmr->fr_state = FRMR_IS_STALE;
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("RPC:       %s: %s %s (%u, vendor %u)\n",
+		       __func__, ib_wc_status_msg(wc->status),
+		       wr, wc->status, wc->vendor_err);
+}
+
+/**
+ * frwr_wc_fastreg - Invoked by RDMA provider for each polled FastReg WC
+ * @cq:	completion queue (ignored)
+ * @wc:	completed WR
  *
- * WARNING: Only wr_id and status are reliable at this point
  */
 static void
-__frwr_sendcompletion_flush(struct ib_wc *wc, struct rpcrdma_mw *r)
+frwr_wc_fastreg(struct ib_cq *cq, struct ib_wc *wc)
 {
-	if (likely(wc->status == IB_WC_SUCCESS))
-		return;
-
-	/* WARNING: Only wr_id and status are reliable at this point */
-	r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-	if (wc->status == IB_WC_WR_FLUSH_ERR)
-		dprintk("RPC:       %s: frmr %p flushed\n", __func__, r);
-	else
-		pr_warn("RPC:       %s: frmr %p error, status %s (%d)\n",
-			__func__, r, ib_wc_status_msg(wc->status), wc->status);
+	struct rpcrdma_frmr *frmr;
+	struct ib_cqe *cqe;
 
-	r->frmr.fr_state = FRMR_IS_STALE;
+	/* WARNING: Only wr_cqe and status are reliable at this point */
+	if (wc->status != IB_WC_SUCCESS) {
+		cqe = wc->wr_cqe;
+		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
+		__frwr_sendcompletion_flush(wc, frmr, "fastreg");
+	}
 }
 
+/**
+ * frwr_wc_localinv - Invoked by RDMA provider for each polled LocalInv WC
+ * @cq:	completion queue (ignored)
+ * @wc:	completed WR
+ *
+ */
 static void
-frwr_sendcompletion(struct ib_wc *wc)
+frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
 {
-	struct rpcrdma_mw *r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-	struct rpcrdma_frmr *f = &r->frmr;
+	struct rpcrdma_frmr *frmr;
+	struct ib_cqe *cqe;
 
-	if (unlikely(wc->status != IB_WC_SUCCESS))
-		__frwr_sendcompletion_flush(wc, r);
+	/* WARNING: Only wr_cqe and status are reliable at this point */
+	if (wc->status != IB_WC_SUCCESS) {
+		cqe = wc->wr_cqe;
+		frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
+		__frwr_sendcompletion_flush(wc, frmr, "localinv");
+	}
+}
 
-	if (f->fr_waiter)
-		complete(&f->fr_linv_done);
+/**
+ * frwr_wc_localinv - Invoked by RDMA provider for each polled LocalInv WC
+ * @cq:	completion queue (ignored)
+ * @wc:	completed WR
+ *
+ * Awaken anyone waiting for an MR to finish being fenced.
+ */
+static void
+frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
+{
+	struct rpcrdma_frmr *frmr;
+	struct ib_cqe *cqe;
+
+	/* WARNING: Only wr_cqe and status are reliable at this point */
+	cqe = wc->wr_cqe;
+	frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
+	if (wc->status != IB_WC_SUCCESS)
+		__frwr_sendcompletion_flush(wc, frmr, "localinv");
+	complete_all(&frmr->fr_linv_done);
 }
 
 static int
@@ -313,7 +352,6 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
-		r->mw_sendcompletion = frwr_sendcompletion;
 		r->frmr.fr_xprt = r_xprt;
 	}
 
@@ -350,7 +388,6 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	} while (mw->frmr.fr_state != FRMR_IS_INVALID);
 	frmr = &mw->frmr;
 	frmr->fr_state = FRMR_IS_VALID;
-	frmr->fr_waiter = false;
 	mr = frmr->fr_mr;
 	reg_wr = &frmr->fr_regwr;
 
@@ -400,7 +437,8 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 
 	reg_wr->wr.next = NULL;
 	reg_wr->wr.opcode = IB_WR_REG_MR;
-	reg_wr->wr.wr_id = (uintptr_t)mw;
+	frmr->fr_cqe.done = frwr_wc_fastreg;
+	reg_wr->wr.wr_cqe = &frmr->fr_cqe;
 	reg_wr->wr.num_sge = 0;
 	reg_wr->wr.send_flags = 0;
 	reg_wr->mr = mr;
@@ -437,12 +475,12 @@ __frwr_prepare_linv_wr(struct rpcrdma_mr_seg *seg)
 	struct rpcrdma_frmr *f = &mw->frmr;
 	struct ib_send_wr *invalidate_wr;
 
-	f->fr_waiter = false;
 	f->fr_state = FRMR_IS_INVALID;
 	invalidate_wr = &f->fr_invwr;
 
 	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
-	invalidate_wr->wr_id = (unsigned long)(void *)mw;
+	f->fr_cqe.done = frwr_wc_localinv;
+	invalidate_wr->wr_cqe = &f->fr_cqe;
 	invalidate_wr->opcode = IB_WR_LOCAL_INV;
 	invalidate_wr->ex.invalidate_rkey = f->fr_mr->rkey;
 
@@ -511,8 +549,8 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * are complete.
 	 */
 	f->fr_invwr.send_flags = IB_SEND_SIGNALED;
-	f->fr_waiter = true;
-	init_completion(&f->fr_linv_done);
+	f->fr_cqe.done = frwr_wc_localinv_wake;
+	reinit_completion(&f->fr_linv_done);
 	INIT_CQCOUNT(&r_xprt->rx_ep);
 
 	/* Transport disconnect drains the receive CQ before it
@@ -564,7 +602,8 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	invalidate_wr = &mw->frmr.fr_invwr;
 
 	memset(invalidate_wr, 0, sizeof(*invalidate_wr));
-	invalidate_wr->wr_id = (uintptr_t)mw;
+	frmr->fr_cqe.done = frwr_wc_localinv;
+	invalidate_wr->wr_cqe = &frmr->fr_cqe;
 	invalidate_wr->opcode = IB_WR_LOCAL_INV;
 	invalidate_wr->ex.invalidate_rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9533b5f..6a8d4d3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -112,73 +112,20 @@ rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 	}
 }
 
-static void
-rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
-{
-	struct rpcrdma_ep *ep = context;
-
-	pr_err("RPC:       %s: %s on device %s ep %p\n",
-	       __func__, ib_event_msg(event->event),
-		event->device->name, context);
-	if (ep->rep_connected == 1) {
-		ep->rep_connected = -EIO;
-		rpcrdma_conn_func(ep);
-		wake_up_all(&ep->rep_connect_wait);
-	}
-}
-
-static void
-rpcrdma_sendcq_process_wc(struct ib_wc *wc)
-{
-	/* WARNING: Only wr_id and status are reliable at this point */
-	if (wc->wr_id == RPCRDMA_IGNORE_COMPLETION) {
-		if (wc->status != IB_WC_SUCCESS &&
-		    wc->status != IB_WC_WR_FLUSH_ERR)
-			pr_err("RPC:       %s: SEND: %s\n",
-			       __func__, ib_wc_status_msg(wc->status));
-	} else {
-		struct rpcrdma_mw *r;
-
-		r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-		r->mw_sendcompletion(wc);
-	}
-}
-
-/* The common case is a single send completion is waiting. By
- * passing two WC entries to ib_poll_cq, a return code of 1
- * means there is exactly one WC waiting and no more. We don't
- * have to invoke ib_poll_cq again to know that the CQ has been
- * properly drained.
- */
-static void
-rpcrdma_sendcq_poll(struct ib_cq *cq)
-{
-	struct ib_wc *pos, wcs[2];
-	int count, rc;
-
-	do {
-		pos = wcs;
-
-		rc = ib_poll_cq(cq, ARRAY_SIZE(wcs), pos);
-		if (rc < 0)
-			break;
-
-		count = rc;
-		while (count-- > 0)
-			rpcrdma_sendcq_process_wc(pos++);
-	} while (rc == ARRAY_SIZE(wcs));
-	return;
-}
-
-/* Handle provider send completion upcalls.
+/**
+ * rpcrdma_wc_send - Invoked by RDMA provider for each polled Send WC
+ * @cq:	completion queue (ignored)
+ * @wc:	completed WR
+ *
  */
 static void
-rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
+rpcrdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 {
-	do {
-		rpcrdma_sendcq_poll(cq);
-	} while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
-				  IB_CQ_REPORT_MISSED_EVENTS) > 0);
+	/* WARNING: Only wr_cqe and status are reliable at this point */
+	if (wc->status != IB_WC_SUCCESS && wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("RPC:       %s: Send: %s (%u, vendor %u)\n",
+		       __func__, ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
 }
 
 static void
@@ -263,8 +210,6 @@ rpcrdma_flush_cqs(struct rpcrdma_ep *ep)
 
 	while (ib_poll_cq(ep->rep_attr.recv_cq, 1, &wc) > 0)
 		rpcrdma_receive_wc(NULL, &wc);
-	while (ib_poll_cq(ep->rep_attr.send_cq, 1, &wc) > 0)
-		rpcrdma_sendcq_process_wc(&wc);
 }
 
 static int
@@ -556,9 +501,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 				struct rpcrdma_create_data_internal *cdata)
 {
 	struct ib_cq *sendcq, *recvcq;
-	struct ib_cq_init_attr cq_attr = {};
 	unsigned int max_qp_wr;
-	int rc, err;
+	int rc;
 
 	if (ia->ri_device->attrs.max_sge < RPCRDMA_MAX_IOVS) {
 		dprintk("RPC:       %s: insufficient sge's available\n",
@@ -610,9 +554,9 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
-	cq_attr.cqe = ep->rep_attr.cap.max_send_wr + 1;
-	sendcq = ib_create_cq(ia->ri_device, rpcrdma_sendcq_upcall,
-			      rpcrdma_cq_async_error_upcall, NULL, &cq_attr);
+	sendcq = ib_alloc_cq(ia->ri_device, NULL,
+			     ep->rep_attr.cap.max_send_wr + 1,
+			     0, IB_POLL_SOFTIRQ);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
@@ -620,13 +564,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 		goto out1;
 	}
 
-	rc = ib_req_notify_cq(sendcq, IB_CQ_NEXT_COMP);
-	if (rc) {
-		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
-			__func__, rc);
-		goto out2;
-	}
-
 	recvcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_recv_wr + 1,
 			     0, IB_POLL_SOFTIRQ);
@@ -661,10 +598,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	return 0;
 
 out2:
-	err = ib_destroy_cq(sendcq);
-	if (err)
-		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
-			__func__, err);
+	ib_free_cq(sendcq);
 out1:
 	if (ia->ri_dma_mr)
 		ib_dereg_mr(ia->ri_dma_mr);
@@ -700,11 +634,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	}
 
 	ib_free_cq(ep->rep_attr.recv_cq);
-
-	rc = ib_destroy_cq(ep->rep_attr.send_cq);
-	if (rc)
-		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
-			__func__, rc);
+	ib_free_cq(ep->rep_attr.send_cq);
 
 	if (ia->ri_dma_mr) {
 		rc = ib_dereg_mr(ia->ri_dma_mr);
@@ -883,6 +813,7 @@ rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 	spin_lock(&buffer->rb_reqslock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_reqslock);
+	req->rl_cqe.done = rpcrdma_wc_send;
 	req->rl_buffer = &r_xprt->rx_buf;
 	return req;
 }
@@ -1246,7 +1177,7 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 	}
 
 	send_wr.next = NULL;
-	send_wr.wr_id = RPCRDMA_IGNORE_COMPLETION;
+	send_wr.wr_cqe = &req->rl_cqe;
 	send_wr.sg_list = iov;
 	send_wr.num_sge = req->rl_niovs;
 	send_wr.opcode = IB_WR_SEND;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b3c4472..2ebc743 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -95,10 +95,6 @@ struct rpcrdma_ep {
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
 #define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
 
-/* Force completion handler to ignore the signal
- */
-#define RPCRDMA_IGNORE_COMPLETION	(0ULL)
-
 /* Pre-allocate extra Work Requests for handling backward receives
  * and sends. This is a fixed value because the Work Queues are
  * allocated when the forward channel is set up.
@@ -205,11 +201,11 @@ struct rpcrdma_frmr {
 	struct scatterlist		*sg;
 	int				sg_nents;
 	struct ib_mr			*fr_mr;
+	struct ib_cqe			fr_cqe;
 	enum rpcrdma_frmr_state		fr_state;
+	struct completion		fr_linv_done;
 	struct work_struct		fr_work;
 	struct rpcrdma_xprt		*fr_xprt;
-	bool				fr_waiter;
-	struct completion		fr_linv_done;;
 	union {
 		struct ib_reg_wr	fr_regwr;
 		struct ib_send_wr	fr_invwr;
@@ -226,7 +222,6 @@ struct rpcrdma_mw {
 		struct rpcrdma_fmr	fmr;
 		struct rpcrdma_frmr	frmr;
 	};
-	void			(*mw_sendcompletion)(struct ib_wc *);
 	struct list_head	mw_list;
 	struct list_head	mw_all;
 };
@@ -282,6 +277,7 @@ struct rpcrdma_req {
 	struct rpcrdma_regbuf	*rl_sendbuf;
 	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
 
+	struct ib_cqe		rl_cqe;
 	struct list_head	rl_all;
 	bool			rl_backchannel;
 };

