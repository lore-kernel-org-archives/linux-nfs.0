Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:33287 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbbEKSCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:02:48 -0400
Subject: [PATCH v2 03/16] xprtrdma: Replace rpcrdma_rep::rr_buffer with
 rr_rxprt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:02:45 -0400
Message-ID: <20150511180245.31263.47481.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Instead of carrying a pointer to the buffer pool and
the rpc_xprt, carry a pointer to the controlling rpcrdma_xprt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ++--
 net/sunrpc/xprtrdma/transport.c |    7 ++-----
 net/sunrpc/xprtrdma/verbs.c     |    8 +++++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 2c53ea9..98a3b95 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -732,8 +732,8 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpcrdma_msg *headerp;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
-	struct rpc_xprt *xprt = rep->rr_xprt;
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	__be32 *iptr;
 	int rdmalen, status;
 	unsigned long cwnd;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index dfcd52e..25f7a6e 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -627,12 +627,9 @@ xprt_rdma_send_request(struct rpc_task *task)
 
 	if (req->rl_reply == NULL) 		/* e.g. reconnection */
 		rpcrdma_recv_buffer_get(req);
-
-	if (req->rl_reply) {
+	/* rpcrdma_recv_buffer_get may have set rl_reply, so check again */
+	if (req->rl_reply)
 		req->rl_reply->rr_func = rpcrdma_reply_handler;
-		/* this need only be done once, but... */
-		req->rl_reply->rr_xprt = xprt;
-	}
 
 	/* Must suppress retransmit to maintain credits */
 	if (req->rl_connect_cookie == xprt->connect_cookie)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 51900e6..c55bfbc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -278,6 +278,7 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 {
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
+	struct rpcrdma_ia *ia;
 
 	/* WARNING: Only wr_id and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS)
@@ -290,8 +291,9 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 	dprintk("RPC:       %s: rep %p opcode 'recv', length %u: success\n",
 		__func__, rep, wc->byte_len);
 
+	ia = &rep->rr_rxprt->rx_ia;
 	rep->rr_len = wc->byte_len;
-	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
+	ib_dma_sync_single_for_cpu(ia->ri_id->device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
 	prefetch(rdmab_to_msg(rep->rr_rdmabuf));
@@ -1053,7 +1055,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 		goto out_free;
 	}
 
-	rep->rr_buffer = &r_xprt->rx_buf;
+	rep->rr_rxprt = r_xprt;
 	return rep;
 
 out_free:
@@ -1423,7 +1425,7 @@ rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
 void
 rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 {
-	struct rpcrdma_buffer *buffers = rep->rr_buffer;
+	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
 	unsigned long flags;
 
 	rep->rr_func = NULL;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 78e0b8b..c3d57c0 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -173,8 +173,7 @@ struct rpcrdma_buffer;
 
 struct rpcrdma_rep {
 	unsigned int		rr_len;
-	struct rpcrdma_buffer	*rr_buffer;
-	struct rpc_xprt		*rr_xprt;
+	struct rpcrdma_xprt	*rr_rxprt;
 	void			(*rr_func)(struct rpcrdma_rep *);
 	struct list_head	rr_list;
 	struct rpcrdma_regbuf	*rr_rdmabuf;

