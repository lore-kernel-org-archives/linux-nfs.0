Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:47734 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755697AbdJPTBd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:01:33 -0400
Subject: [PATCH 1 4/5] xprtrdma: Invoke rpcrdma_reply_handler directly from
 RECV completion
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 16 Oct 2017 15:01:30 -0400
Message-ID: <20171016190130.13594.93106.stgit@manet.1015granger.net>
In-Reply-To: <20171016185641.13594.5374.stgit@manet.1015granger.net>
References: <20171016185641.13594.5374.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed that the soft IRQ thread looked pretty busy under heavy
I/O workloads. perf suggested one area that was expensive was the
queue_work() call in rpcrdma_wc_receive. That gave me some ideas.

Instead of scheduling a separate worker to process RPC Replies,
promote the Receive completion handler to IB_POLL_WORKQUEUE, and
invoke rpcrdma_reply_handler directly.

Note that the poll workqueue is single-threaded. In order to keep
memory invalidation from serializing all RPC Replies, handle any
necessary invalidation tasks in a separate multi-threaded workqueue.

This provides a two-tier scheme, similar to OS I/O interrupt
handlers: A fast interrupt handler that schedules the slow handler
and re-enables the interrupt, and a slower handler that is invoked
for any needed heavy lifting.

Benefits include:
- One less context switch for RPCs that don't register memory
- Receive completion handling is moved out of soft IRQ context to
  make room for other users of soft IRQ
- The same CPU core now DMA syncs and XDR decodes the Receive buffer

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   46 ++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/verbs.c     |    8 +++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++-
 3 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 418bcc6..430f8b5 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1265,16 +1265,36 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	goto out;
 }
 
+/* Reply handling runs in the poll worker thread. Anything that
+ * might wait is deferred to a separate workqueue.
+ */
+void rpcrdma_deferred_completion(struct work_struct *work)
+{
+	struct rpcrdma_rep *rep =
+			container_of(work, struct rpcrdma_rep, rr_work);
+	struct rpcrdma_req *req = rpcr_to_rdmar(rep->rr_rqst);
+	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
+
+	/* Invalidate and unmap the data payloads before waking
+	 * the waiting application. This guarantees the memory
+	 * regions are properly fenced from the server before the
+	 * application accesses the data. It also ensures proper
+	 * send flow control: waking the next RPC waits until this
+	 * RPC has relinquished all its Send Queue entries.
+	 */
+	rpcrdma_mark_remote_invalidation(&req->rl_registered, rep);
+	r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, &req->rl_registered);
+
+	rpcrdma_complete_rqst(rep);
+}
+
 /* Process received RPC/RDMA messages.
  *
  * Errors must result in the RPC task either being awakened, or
  * allowed to timeout, to discover the errors at that time.
  */
-void
-rpcrdma_reply_handler(struct work_struct *work)
+void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 {
-	struct rpcrdma_rep *rep =
-			container_of(work, struct rpcrdma_rep, rr_work);
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	struct rpcrdma_req *req;
@@ -1320,20 +1340,10 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
 		__func__, rep, req, be32_to_cpu(rep->rr_xid));
 
-	/* Invalidate and unmap the data payloads before waking the
-	 * waiting application. This guarantees the memory regions
-	 * are properly fenced from the server before the application
-	 * accesses the data. It also ensures proper send flow control:
-	 * waking the next RPC waits until this RPC has relinquished
-	 * all its Send Queue entries.
-	 */
-	if (!list_empty(&req->rl_registered)) {
-		rpcrdma_mark_remote_invalidation(&req->rl_registered, rep);
-		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
-						    &req->rl_registered);
-	}
-
-	rpcrdma_complete_rqst(rep);
+	if (list_empty(&req->rl_registered))
+		rpcrdma_complete_rqst(rep);
+	else
+		queue_work(rpcrdma_receive_wq, &rep->rr_work);
 	return;
 
 out_badstatus:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 11a1fbf..d456954 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -73,7 +73,7 @@
 static void rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 
-static struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
+struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
 
 int
 rpcrdma_alloc_wq(void)
@@ -185,7 +185,7 @@
 		rpcrdma_update_granted_credits(rep);
 
 out_schedule:
-	queue_work(rpcrdma_receive_wq, &rep->rr_work);
+	rpcrdma_reply_handler(rep);
 	return;
 
 out_fail:
@@ -583,7 +583,7 @@
 
 	recvcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_recv_wr + 1,
-			     0, IB_POLL_SOFTIRQ);
+			     0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
 		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
@@ -974,7 +974,7 @@ struct rpcrdma_rep *
 
 	rep->rr_cqe.done = rpcrdma_wc_receive;
 	rep->rr_rxprt = r_xprt;
-	INIT_WORK(&rep->rr_work, rpcrdma_reply_handler);
+	INIT_WORK(&rep->rr_work, rpcrdma_deferred_completion);
 	rep->rr_recv_wr.next = NULL;
 	rep->rr_recv_wr.wr_cqe = &rep->rr_cqe;
 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d68a1351..a85bcd1 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -533,6 +533,8 @@ struct rpcrdma_xprt {
 bool frwr_is_supported(struct rpcrdma_ia *);
 bool fmr_is_supported(struct rpcrdma_ia *);
 
+extern struct workqueue_struct *rpcrdma_receive_wq;
+
 /*
  * Endpoint calls - xprtrdma/verbs.c
  */
@@ -617,7 +619,8 @@ bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_complete_rqst(struct rpcrdma_rep *rep);
-void rpcrdma_reply_handler(struct work_struct *work);
+void rpcrdma_reply_handler(struct rpcrdma_rep *rep);
+void rpcrdma_deferred_completion(struct work_struct *work);
 
 static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 {

