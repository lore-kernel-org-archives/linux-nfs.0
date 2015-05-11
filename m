Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34305 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533AbbEKSC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:02:57 -0400
Subject: [PATCH v2 04/16] xprtrdma: Remove rr_func
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:02:54 -0400
Message-ID: <20150511180254.31263.63182.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A posted rpcrdma_rep never has rr_func set to anything but
rpcrdma_reply_handler.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    1 -
 net/sunrpc/xprtrdma/transport.c |    3 ---
 net/sunrpc/xprtrdma/verbs.c     |   10 +---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 4 files changed, 1 insertion(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 98a3b95..3f422ca 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -770,7 +770,6 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 			rep->rr_len);
 repost:
 		r_xprt->rx_stats.bad_reply_count++;
-		rep->rr_func = rpcrdma_reply_handler;
 		if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, &r_xprt->rx_ep, rep))
 			rpcrdma_recv_buffer_put(rep);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 25f7a6e..7c12556 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -627,9 +627,6 @@ xprt_rdma_send_request(struct rpc_task *task)
 
 	if (req->rl_reply == NULL) 		/* e.g. reconnection */
 		rpcrdma_recv_buffer_get(req);
-	/* rpcrdma_recv_buffer_get may have set rl_reply, so check again */
-	if (req->rl_reply)
-		req->rl_reply->rr_func = rpcrdma_reply_handler;
 
 	/* Must suppress retransmit to maintain credits */
 	if (req->rl_connect_cookie == xprt->connect_cookie)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c55bfbc..8e0bd84 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -80,7 +80,6 @@ static void
 rpcrdma_run_tasklet(unsigned long data)
 {
 	struct rpcrdma_rep *rep;
-	void (*func)(struct rpcrdma_rep *);
 	unsigned long flags;
 
 	data = data;
@@ -89,14 +88,9 @@ rpcrdma_run_tasklet(unsigned long data)
 		rep = list_entry(rpcrdma_tasklets_g.next,
 				 struct rpcrdma_rep, rr_list);
 		list_del(&rep->rr_list);
-		func = rep->rr_func;
-		rep->rr_func = NULL;
 		spin_unlock_irqrestore(&rpcrdma_tk_lock_g, flags);
 
-		if (func)
-			func(rep);
-		else
-			rpcrdma_recv_buffer_put(rep);
+		rpcrdma_reply_handler(rep);
 
 		spin_lock_irqsave(&rpcrdma_tk_lock_g, flags);
 	}
@@ -1213,7 +1207,6 @@ rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	req->rl_niovs = 0;
 	if (req->rl_reply) {
 		buf->rb_recv_bufs[--buf->rb_recv_index] = req->rl_reply;
-		req->rl_reply->rr_func = NULL;
 		req->rl_reply = NULL;
 	}
 }
@@ -1428,7 +1421,6 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
 	unsigned long flags;
 
-	rep->rr_func = NULL;
 	spin_lock_irqsave(&buffers->rb_lock, flags);
 	buffers->rb_recv_bufs[--buffers->rb_recv_index] = rep;
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c3d57c0..230e7fe 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -174,7 +174,6 @@ struct rpcrdma_buffer;
 struct rpcrdma_rep {
 	unsigned int		rr_len;
 	struct rpcrdma_xprt	*rr_rxprt;
-	void			(*rr_func)(struct rpcrdma_rep *);
 	struct list_head	rr_list;
 	struct rpcrdma_regbuf	*rr_rdmabuf;
 };

