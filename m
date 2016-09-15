Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36601 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751966AbcIOO43 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:56:29 -0400
Subject: [PATCH v3 11/22] xprtrdma: Eliminate "ia" argument in
 rpcrdma_{alloc, free}_regbuf
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:56:26 -0400
Message-ID: <20160915145626.11080.61304.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. The "ia" argument is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    7 +++----
 net/sunrpc/xprtrdma/transport.c   |   11 +++++------
 net/sunrpc/xprtrdma/verbs.c       |   28 ++++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    8 +++-----
 4 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 8bc249e..a19530d 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -27,7 +27,7 @@ static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
 	list_del(&req->rl_all);
 	spin_unlock(&buf->rb_reqslock);
 
-	rpcrdma_destroy_req(&r_xprt->rx_ia, req);
+	rpcrdma_destroy_req(req);
 
 	kfree(rqst);
 }
@@ -35,7 +35,6 @@ static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
 static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 				 struct rpc_rqst *rqst)
 {
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 	size_t size;
@@ -45,14 +44,14 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 		return PTR_ERR(req);
 	req->rl_backchannel = true;
 
-	rb = rpcrdma_alloc_regbuf(ia, RPCRDMA_HDRBUF_SIZE,
+	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
 				  DMA_TO_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_rdmabuf = rb;
 
 	size = r_xprt->rx_data.inline_rsize;
-	rb = rpcrdma_alloc_regbuf(ia, size, DMA_TO_DEVICE, GFP_KERNEL);
+	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_sendbuf = rb;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3424691..5adaa1d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -490,7 +490,7 @@ rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	if (req->rl_rdmabuf)
 		return true;
 
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, DMA_TO_DEVICE, flags);
+	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb))
 		return false;
 
@@ -517,12 +517,11 @@ rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		return true;
 
 	min_size = max_t(size_t, size, r_xprt->rx_data.inline_wsize);
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size,
-				  DMA_TO_DEVICE, flags);
+	rb = rpcrdma_alloc_regbuf(min_size, DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb))
 		return false;
 
-	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_sendbuf);
+	rpcrdma_free_regbuf(req->rl_sendbuf);
 	r_xprt->rx_stats.hardway_register_count += min_size;
 	req->rl_sendbuf = rb;
 	return true;
@@ -548,11 +547,11 @@ rpcrdma_get_recvbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	if (req->rl_recvbuf && rdmab_length(req->rl_recvbuf) >= size)
 		return true;
 
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, DMA_NONE, flags);
+	rb = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
 	if (IS_ERR(rb))
 		return false;
 
-	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_recvbuf);
+	rpcrdma_free_regbuf(req->rl_recvbuf);
 	r_xprt->rx_stats.hardway_register_count += size;
 	req->rl_recvbuf = rb;
 	return true;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 09346cd..1f7f4a9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -865,7 +865,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 	if (rep == NULL)
 		goto out;
 
-	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(ia, cdata->inline_rsize,
+	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(cdata->inline_rsize,
 					       DMA_FROM_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rep->rr_rdmabuf)) {
 		rc = PTR_ERR(rep->rr_rdmabuf);
@@ -966,18 +966,18 @@ rpcrdma_buffer_get_rep_locked(struct rpcrdma_buffer *buf)
 }
 
 static void
-rpcrdma_destroy_rep(struct rpcrdma_ia *ia, struct rpcrdma_rep *rep)
+rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
 {
-	rpcrdma_free_regbuf(ia, rep->rr_rdmabuf);
+	rpcrdma_free_regbuf(rep->rr_rdmabuf);
 	kfree(rep);
 }
 
 void
-rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
+rpcrdma_destroy_req(struct rpcrdma_req *req)
 {
-	rpcrdma_free_regbuf(ia, req->rl_recvbuf);
-	rpcrdma_free_regbuf(ia, req->rl_sendbuf);
-	rpcrdma_free_regbuf(ia, req->rl_rdmabuf);
+	rpcrdma_free_regbuf(req->rl_recvbuf);
+	rpcrdma_free_regbuf(req->rl_sendbuf);
+	rpcrdma_free_regbuf(req->rl_rdmabuf);
 	kfree(req);
 }
 
@@ -1010,15 +1010,13 @@ rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf)
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
-	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
-
 	cancel_delayed_work_sync(&buf->rb_recovery_worker);
 
 	while (!list_empty(&buf->rb_recv_bufs)) {
 		struct rpcrdma_rep *rep;
 
 		rep = rpcrdma_buffer_get_rep_locked(buf);
-		rpcrdma_destroy_rep(ia, rep);
+		rpcrdma_destroy_rep(rep);
 	}
 	buf->rb_send_count = 0;
 
@@ -1031,7 +1029,7 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		list_del(&req->rl_all);
 
 		spin_unlock(&buf->rb_reqslock);
-		rpcrdma_destroy_req(ia, req);
+		rpcrdma_destroy_req(req);
 		spin_lock(&buf->rb_reqslock);
 	}
 	spin_unlock(&buf->rb_reqslock);
@@ -1174,7 +1172,6 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 
 /**
  * rpcrdma_alloc_regbuf - allocate and DMA-map memory for SEND/RECV buffers
- * @ia: controlling rpcrdma_ia
  * @size: size of buffer to be allocated, in bytes
  * @direction: direction of data movement
  * @flags: GFP flags
@@ -1187,8 +1184,8 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
  * or Replies they may be registered externally via ro_map.
  */
 struct rpcrdma_regbuf *
-rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size,
-		     enum dma_data_direction direction, gfp_t flags)
+rpcrdma_alloc_regbuf(size_t size, enum dma_data_direction direction,
+		     gfp_t flags)
 {
 	struct rpcrdma_regbuf *rb;
 
@@ -1239,11 +1236,10 @@ rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb)
 
 /**
  * rpcrdma_free_regbuf - deregister and free registered buffer
- * @ia: controlling rpcrdma_ia
  * @rb: regbuf to be deregistered and freed
  */
 void
-rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+rpcrdma_free_regbuf(struct rpcrdma_regbuf *rb)
 {
 	if (!rb)
 		return;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d37ee24..4875af7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -465,7 +465,7 @@ int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
  */
 struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
 struct rpcrdma_rep *rpcrdma_create_rep(struct rpcrdma_xprt *);
-void rpcrdma_destroy_req(struct rpcrdma_ia *, struct rpcrdma_req *);
+void rpcrdma_destroy_req(struct rpcrdma_req *);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 
@@ -478,12 +478,10 @@ void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 
 void rpcrdma_defer_mr_recovery(struct rpcrdma_mw *);
 
-struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
-					    size_t, enum dma_data_direction,
+struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 					    gfp_t);
 bool __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *, struct rpcrdma_regbuf *);
-void rpcrdma_free_regbuf(struct rpcrdma_ia *,
-			 struct rpcrdma_regbuf *);
+void rpcrdma_free_regbuf(struct rpcrdma_regbuf *);
 
 static inline bool
 rpcrdma_regbuf_is_mapped(struct rpcrdma_regbuf *rb)

