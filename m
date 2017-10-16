Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:56802 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752929AbdJPTBl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:01:41 -0400
Subject: [PATCH 1 5/5] xprtrdma: Decode credits field in
 rpcrdma_reply_handler
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 16 Oct 2017 15:01:39 -0400
Message-ID: <20171016190139.13594.63804.stgit@manet.1015granger.net>
In-Reply-To: <20171016185641.13594.5374.stgit@manet.1015granger.net>
References: <20171016185641.13594.5374.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to decode and save the incoming rdma_credits field _after_
we know that the direction of the message is "forward direction
Reply". Otherwise, the credits value in reverse direction Calls is
also used to update the forward direction credits.

It is safe to decode the rdma_credits field in rpcrdma_reply_handler
now that rpcrdma_reply_handler is single-threaded. Receives complete
in the same order as they were sent on the NFS server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   14 ++++++++++++--
 net/sunrpc/xprtrdma/verbs.c     |   25 +------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 430f8b5..b8818c09 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1244,7 +1244,7 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 out:
 	spin_lock(&xprt->recv_lock);
 	cwnd = xprt->cwnd;
-	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
+	xprt->cwnd = r_xprt->rx_buf.rb_credits << RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)
 		xprt_release_rqst_cong(rqst->rq_task);
 
@@ -1297,8 +1297,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 {
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
+	u32 credits;
 	__be32 *p;
 
 	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
@@ -1315,7 +1317,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		goto out_shortreply;
 	rep->rr_xid = *p++;
 	rep->rr_vers = *p++;
-	p++;	/* credits */
+	credits = be32_to_cpu(*p++);
 	rep->rr_proc = *p++;
 
 	if (rep->rr_vers != rpcrdma_version)
@@ -1332,7 +1334,15 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	if (!rqst)
 		goto out_norqst;
 	xprt_pin_rqst(rqst);
+
+	if (credits == 0)
+		credits = 1;	/* don't deadlock */
+	else if (credits > buf->rb_max_requests)
+		credits = buf->rb_max_requests;
+	buf->rb_credits = credits;
+
 	spin_unlock(&xprt->recv_lock);
+
 	req = rpcr_to_rdmar(rqst);
 	req->rl_reply = rep;
 	rep->rr_rqst = rqst;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d456954..247b00b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -133,25 +133,6 @@
 		       wc->status, wc->vendor_err);
 }
 
-/* Perform basic sanity checking to avoid using garbage
- * to update the credit grant value.
- */
-static void
-rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
-{
-	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
-	__be32 *p = rep->rr_rdmabuf->rg_base;
-	u32 credits;
-
-	credits = be32_to_cpup(p + 2);
-	if (credits == 0)
-		credits = 1;	/* don't deadlock */
-	else if (credits > buffer->rb_max_requests)
-		credits = buffer->rb_max_requests;
-
-	atomic_set(&buffer->rb_credits, credits);
-}
-
 /**
  * rpcrdma_wc_receive - Invoked by RDMA provider for each polled Receive WC
  * @cq:	completion queue (ignored)
@@ -181,9 +162,6 @@
 				   rdmab_addr(rep->rr_rdmabuf),
 				   wc->byte_len, DMA_FROM_DEVICE);
 
-	if (wc->byte_len >= RPCRDMA_HDRLEN_ERR)
-		rpcrdma_update_granted_credits(rep);
-
 out_schedule:
 	rpcrdma_reply_handler(rep);
 	return;
@@ -295,7 +273,7 @@
 	case RDMA_CM_EVENT_DISCONNECTED:
 		connstate = -ECONNABORTED;
 connected:
-		atomic_set(&xprt->rx_buf.rb_credits, 1);
+		xprt->rx_buf.rb_credits = 1;
 		ep->rep_connected = connstate;
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
@@ -995,7 +973,6 @@ struct rpcrdma_rep *
 
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
-	atomic_set(&buf->rb_credits, 1);
 	spin_lock_init(&buf->rb_mwlock);
 	spin_lock_init(&buf->rb_lock);
 	spin_lock_init(&buf->rb_recovery_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a85bcd1..0e0ae61 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -407,7 +407,7 @@ struct rpcrdma_buffer {
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
-	atomic_t		rb_credits;	/* most recent credit grant */
+	u32			rb_credits;	/* most recent credit grant */
 
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */

