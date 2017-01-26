Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33454 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754117AbdAZR4g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 12:56:36 -0500
Subject: [PATCH v1 7/7] sunrpc: Allow keepalive ping on a credit-full
 transport
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 26 Jan 2017 12:56:28 -0500
Message-ID: <20170126175628.5794.56813.stgit@manet.1015granger.net>
In-Reply-To: <20170126174806.5794.14678.stgit@manet.1015granger.net>
References: <20170126174806.5794.14678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow RPC-over-RDMA to send NULL pings even when the transport has
hit its credit limit.

One credit is reserved. It may be used only to send a keepalive
ping.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/sched.h    |    2 ++
 net/sunrpc/xprt.c               |    4 ++++
 net/sunrpc/xprtrdma/transport.c |    4 +++-
 net/sunrpc/xprtrdma/verbs.c     |   13 ++++++++-----
 4 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7ba040c..a65278e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -127,6 +127,7 @@ struct rpc_task_setup {
 #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
 #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
 #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
+#define RPC_TASK_PRIORITY	0x8000		/* skip congestion control */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -135,6 +136,7 @@ struct rpc_task_setup {
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
+#define RPC_HAS_PRIORITY(t)	((t)->tk_flags & RPC_TASK_PRIORITY)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b530a28..e8b7b9f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -392,6 +392,10 @@ static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *ta
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
+	if (RPC_HAS_PRIORITY(task)) {
+		req->rq_cong = 0;
+		return 1;
+	}
 	if (req->rq_cong)
 		return 1;
 	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index f97c851..e43cc85 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -538,7 +538,9 @@ static void rpcrdma_keepalive_release(void *calldata)
 
 	data = xprt_get(xprt);
 	null_task = rpc_call_null_helper(task->tk_client, xprt, NULL,
-					 RPC_TASK_SOFT | RPC_TASK_ASYNC,
+					 RPC_TASK_SOFT |
+					 RPC_TASK_ASYNC |
+					 RPC_TASK_PRIORITY,
 					 &rpcrdma_keepalive_call_ops, data);
 	if (!IS_ERR(null_task))
 		rpc_put_task(null_task);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7e14b73..3e218dd 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -136,19 +136,20 @@
 static void
 rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
 {
-	struct rpcrdma_msg *rmsgp = rdmab_to_msg(rep->rr_rdmabuf);
 	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
+	__be32 *p = rep->rr_rdmabuf->rg_base;
 	u32 credits;
 
 	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
 		return;
 
-	credits = be32_to_cpu(rmsgp->rm_credit);
+	credits = be32_to_cpup(p + 2);
+	if (credits > buffer->rb_max_requests)
+		credits = buffer->rb_max_requests;
+	/* Reserve one credit for keepalive ping */
+	credits--;
 	if (credits == 0)
 		credits = 1;	/* don't deadlock */
-	else if (credits > buffer->rb_max_requests)
-		credits = buffer->rb_max_requests;
-
 	atomic_set(&buffer->rb_credits, credits);
 }
 
@@ -914,6 +915,8 @@ struct rpcrdma_rep *
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	int i, rc;
 
+	if (r_xprt->rx_data.max_requests < 2)
+		return -EINVAL;
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
 	atomic_set(&buf->rb_credits, 1);

