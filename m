Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33756 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbcBLVGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 16:06:37 -0500
Subject: [PATCH v1 5/8] xprtrdma: Serialize credit accounting again
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 12 Feb 2016 16:06:35 -0500
Message-ID: <20160212210635.5278.72709.stgit@manet.1015granger.net>
In-Reply-To: <20160212205107.5278.55938.stgit@manet.1015granger.net>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fe97b47cd623 ("xprtrdma: Use workqueue to process RPC/RDMA
replies") replaced the reply tasklet with a workqueue that allows
RPC replies to be processed in parallel. Thus the credit values in
RPC-over-RDMA replies can applied in a different order than in
which the server sent them.

To fix this, revert commit eba8ff660b2d ("xprtrdma: Move credit
update to RPC reply handler"). Done by hand to accommodate code
changes that have occurred since then.

Fixes: fe97b47cd623 ("xprtrdma: Use workqueue to process . . .")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    9 +--------
 net/sunrpc/xprtrdma/verbs.c     |   27 ++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 3 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c341225..0c45288 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -797,7 +797,6 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	__be32 *iptr;
 	int rdmalen, status, rmerr;
 	unsigned long cwnd;
-	u32 credits;
 
 	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
 
@@ -930,15 +929,9 @@ out:
 	if (req->rl_nchunks)
 		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, req);
 
-	credits = be32_to_cpu(headerp->rm_credit);
-	if (credits == 0)
-		credits = 1;	/* don't deadlock */
-	else if (credits > r_xprt->rx_buf.rb_max_requests)
-		credits = r_xprt->rx_buf.rb_max_requests;
-
 	spin_lock_bh(&xprt->transport_lock);
 	cwnd = xprt->cwnd;
-	xprt->cwnd = credits << RPC_CWNDSHIFT;
+	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)
 		xprt_release_rqst_cong(rqst->rq_task);
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 878f1bf..fc1ef5f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -190,6 +190,28 @@ rpcrdma_receive_worker(struct work_struct *work)
 	rpcrdma_reply_handler(rep);
 }
 
+/* Perform basic sanity checking to avoid using garbage
+ * to update the credit grant value.
+ */
+static void
+rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
+{
+	struct rpcrdma_msg *rmsgp = rdmab_to_msg(rep->rr_rdmabuf);
+	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
+	u32 credits;
+
+	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
+		return;
+
+	credits = be32_to_cpu(rmsgp->rm_credit);
+	if (credits == 0)
+		credits = 1;	/* don't deadlock */
+	else if (credits > buffer->rb_max_requests)
+		credits = buffer->rb_max_requests;
+
+	atomic_set(&buffer->rb_credits, credits);
+}
+
 static void
 rpcrdma_recvcq_process_wc(struct ib_wc *wc)
 {
@@ -211,7 +233,8 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc)
 	ib_dma_sync_single_for_cpu(rep->rr_device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
-	prefetch(rdmab_to_msg(rep->rr_rdmabuf));
+
+	rpcrdma_update_granted_credits(rep);
 
 out_schedule:
 	queue_work(rpcrdma_receive_wq, &rep->rr_work);
@@ -330,6 +353,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 connected:
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
+		atomic_set(&xprt->rx_buf.rb_credits, 1);
 		ep->rep_connected = connstate;
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
@@ -943,6 +967,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_lock);
+	atomic_set(&buf->rb_credits, 1);
 
 	rc = ia->ri_ops->ro_init(r_xprt);
 	if (rc)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index bf98c67..efd6fa7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -312,6 +312,7 @@ struct rpcrdma_buffer {
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
+	atomic_t		rb_credits;	/* most recent credit grant */
 
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */

