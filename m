Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35755 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbcBLVGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 16:06:45 -0500
Subject: [PATCH v1 6/8] xprtrdma: Use new CQ API for RPC-over-RDMA client
 receive CQs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 12 Feb 2016 16:06:43 -0500
Message-ID: <20160212210643.5278.97996.stgit@manet.1015granger.net>
In-Reply-To: <20160212205107.5278.55938.stgit@manet.1015granger.net>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net>
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

xprtrdma's receive processing is already handled in a worker thread,
but there is some initial order-dependent processing that is done
in the soft IRQ context before the worker thread is scheduled.
IB_POLL_SOFTIRQ is a direct replacement for the current xprtrdma
receive code path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   68 ++++++++++-----------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 19 insertions(+), 50 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fc1ef5f..53c30e2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -215,8 +215,9 @@ rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
 static void
 rpcrdma_recvcq_process_wc(struct ib_wc *wc)
 {
-	struct rpcrdma_rep *rep =
-			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct rpcrdma_rep *rep = container_of(cqe, struct rpcrdma_rep,
+					       rr_cqe);
 
 	/* WARNING: Only wr_id and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS)
@@ -242,46 +243,23 @@ out_schedule:
 
 out_fail:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("RPC:       %s: rep %p: %s\n",
-		       __func__, rep, ib_wc_status_msg(wc->status));
+		pr_err("RPC:       %s: Recv: %s (%u, vendor %u)\n",
+		       __func__, ib_wc_status_msg(wc->status),
+		       wc->status, wc->vendor_err);
 	rep->rr_len = RPCRDMA_BAD_LEN;
 	goto out_schedule;
 }
 
-/* The wc array is on stack: automatic memory is always CPU-local.
+/**
+ * rpcrdma_receive_wc - Invoked by RDMA provider for each polled Receive WC
+ * @cq:	completion queue (ignored)
+ * @wc:	completed WR
  *
- * struct ib_wc is 64 bytes, making the poll array potentially
- * large. But this is at the bottom of the call chain. Further
- * substantial work is done in another thread.
- */
-static void
-rpcrdma_recvcq_poll(struct ib_cq *cq)
-{
-	struct ib_wc *pos, wcs[4];
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
-			rpcrdma_recvcq_process_wc(pos++);
-	} while (rc == ARRAY_SIZE(wcs));
-}
-
-/* Handle provider receive completion upcalls.
  */
 static void
-rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
+rpcrdma_receive_wc(struct ib_cq *cq, struct ib_wc *wc)
 {
-	do {
-		rpcrdma_recvcq_poll(cq);
-	} while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
-				  IB_CQ_REPORT_MISSED_EVENTS) > 0);
+	rpcrdma_recvcq_process_wc(wc);
 }
 
 static void
@@ -655,9 +633,9 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 		goto out2;
 	}
 
-	cq_attr.cqe = ep->rep_attr.cap.max_recv_wr + 1;
-	recvcq = ib_create_cq(ia->ri_device, rpcrdma_recvcq_upcall,
-			      rpcrdma_cq_async_error_upcall, NULL, &cq_attr);
+	recvcq = ib_alloc_cq(ia->ri_device, NULL,
+			     ep->rep_attr.cap.max_recv_wr + 1,
+			     0, IB_POLL_SOFTIRQ);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
 		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
@@ -665,14 +643,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 		goto out2;
 	}
 
-	rc = ib_req_notify_cq(recvcq, IB_CQ_NEXT_COMP);
-	if (rc) {
-		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
-			__func__, rc);
-		ib_destroy_cq(recvcq);
-		goto out2;
-	}
-
 	ep->rep_attr.send_cq = sendcq;
 	ep->rep_attr.recv_cq = recvcq;
 
@@ -735,10 +705,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		ia->ri_id->qp = NULL;
 	}
 
-	rc = ib_destroy_cq(ep->rep_attr.recv_cq);
-	if (rc)
-		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
-			__func__, rc);
+	ib_free_cq(ep->rep_attr.recv_cq);
 
 	rc = ib_destroy_cq(ep->rep_attr.send_cq);
 	if (rc)
@@ -947,6 +914,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 	}
 
 	rep->rr_device = ia->ri_device;
+	rep->rr_cqe.done = rpcrdma_receive_wc;
 	rep->rr_rxprt = r_xprt;
 	INIT_WORK(&rep->rr_work, rpcrdma_receive_worker);
 	return rep;
@@ -1322,7 +1290,7 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 	int rc;
 
 	recv_wr.next = NULL;
-	recv_wr.wr_id = (u64) (unsigned long) rep;
+	recv_wr.wr_cqe = &rep->rr_cqe;
 	recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	recv_wr.num_sge = 1;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index efd6fa7..7d87cdc 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -171,6 +171,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
 struct rpcrdma_buffer;
 
 struct rpcrdma_rep {
+	struct ib_cqe		rr_cqe;
 	unsigned int		rr_len;
 	struct ib_device	*rr_device;
 	struct rpcrdma_xprt	*rr_rxprt;

