Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36507 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753359AbcIOO4M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:56:12 -0400
Subject: [PATCH v3 09/22] xprtrdma: Replace DMA_BIDIRECTIONAL
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:56:10 -0400
Message-ID: <20160915145610.11080.38581.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of DMA_BIDIRECTIONAL is discouraged by DMA-API.txt.
Fortunately, xprtrdma now knows which direction I/O is going as
soon as it allocates each regbuf.

The RPC Call and Reply buffers are no longer the same regbuf. They
can each be labeled correctly now. The RPC Reply buffer is never
part of either a Send or Receive WR, but it can be part of Reply
chunk, which is mapped and registered via ->ro_map . So it is not
DMA mapped when it is allocated (DMA_NONE), to avoid a double-
mapping.

Since Receive buffers are no longer DMA_BIDIRECTIONAL and their
contents are never modified by the host CPU, DMA-API-HOWTO.txt
suggests that a DMA sync before posting each buffer should be
unnecessary. (See my_card_interrupt_handler).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    5 ++-
 net/sunrpc/xprtrdma/transport.c   |    7 +++--
 net/sunrpc/xprtrdma/verbs.c       |   55 +++++++++++++++++--------------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 ++-
 4 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 60fc991..ceae872 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -45,13 +45,14 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 		return PTR_ERR(req);
 	req->rl_backchannel = true;
 
-	rb = rpcrdma_alloc_regbuf(ia, RPCRDMA_HDRBUF_SIZE, GFP_KERNEL);
+	rb = rpcrdma_alloc_regbuf(ia, RPCRDMA_HDRBUF_SIZE,
+				  DMA_TO_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_rdmabuf = rb;
 
 	size = r_xprt->rx_data.inline_rsize;
-	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
+	rb = rpcrdma_alloc_regbuf(ia, size, DMA_TO_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_sendbuf = rb;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 94dbfd3..3424691 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -490,7 +490,7 @@ rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	if (req->rl_rdmabuf)
 		return true;
 
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb))
 		return false;
 
@@ -517,7 +517,8 @@ rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		return true;
 
 	min_size = max_t(size_t, size, r_xprt->rx_data.inline_wsize);
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size, flags);
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size,
+				  DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb))
 		return false;
 
@@ -547,7 +548,7 @@ rpcrdma_get_recvbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	if (req->rl_recvbuf && rdmab_length(req->rl_recvbuf) >= size)
 		return true;
 
-	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, DMA_NONE, flags);
 	if (IS_ERR(rb))
 		return false;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fc6b4ea..9edea34 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -866,7 +866,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 		goto out;
 
 	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(ia, cdata->inline_rsize,
-					       GFP_KERNEL);
+					       DMA_FROM_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rep->rr_rdmabuf)) {
 		rc = PTR_ERR(rep->rr_rdmabuf);
 		goto out_free;
@@ -1172,27 +1172,24 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 	spin_unlock(&buffers->rb_lock);
 }
 
-/*
- * Wrappers for internal-use kmalloc memory registration, used by buffer code.
- */
-
 /**
- * rpcrdma_alloc_regbuf - kmalloc and register memory for SEND/RECV buffers
+ * rpcrdma_alloc_regbuf - allocate and DMA-map memory for SEND/RECV buffers
  * @ia: controlling rpcrdma_ia
  * @size: size of buffer to be allocated, in bytes
+ * @direction: direction of data movement
  * @flags: GFP flags
  *
- * Returns pointer to private header of an area of internally
- * registered memory, or an ERR_PTR. The registered buffer follows
- * the end of the private header.
+ * Returns an ERR_PTR, or a pointer to a regbuf, which is a
+ * contiguous memory region that is DMA mapped persistently, and
+ * is registered for local I/O.
  *
  * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
- * receiving the payload of RDMA RECV operations. regbufs are not
- * used for RDMA READ/WRITE operations, thus are registered only for
- * LOCAL access.
+ * receiving the payload of RDMA RECV operations. During Long Calls
+ * or Replies they may be registered externally via ro_map.
  */
 struct rpcrdma_regbuf *
-rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
+rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size,
+		     enum dma_data_direction direction, gfp_t flags)
 {
 	struct rpcrdma_regbuf *rb;
 	struct ib_sge *iov;
@@ -1201,15 +1198,20 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
 	if (rb == NULL)
 		goto out;
 
+	rb->rg_direction = direction;
 	iov = &rb->rg_iov;
-	iov->addr = ib_dma_map_single(ia->ri_device,
-				      (void *)rb->rg_base, size,
-				      DMA_BIDIRECTIONAL);
-	if (ib_dma_mapping_error(ia->ri_device, iov->addr))
-		goto out_free;
-
 	iov->length = size;
 	iov->lkey = ia->ri_pd->local_dma_lkey;
+
+	if (direction != DMA_NONE) {
+		iov->addr = ib_dma_map_single(ia->ri_device,
+					      (void *)rb->rg_base,
+					      rdmab_length(rb),
+					      rb->rg_direction);
+		if (ib_dma_mapping_error(ia->ri_device, iov->addr))
+			goto out_free;
+	}
+
 	return rb;
 
 out_free:
@@ -1226,14 +1228,14 @@ out:
 void
 rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
 {
-	struct ib_sge *iov;
-
 	if (!rb)
 		return;
 
-	iov = &rb->rg_iov;
-	ib_dma_unmap_single(ia->ri_device,
-			    iov->addr, iov->length, DMA_BIDIRECTIONAL);
+	if (rb->rg_direction != DMA_NONE) {
+		ib_dma_unmap_single(ia->ri_device, rdmab_addr(rb),
+				    rdmab_length(rb), rb->rg_direction);
+	}
+
 	kfree(rb);
 }
 
@@ -1305,11 +1307,6 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 	recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	recv_wr.num_sge = 1;
 
-	ib_dma_sync_single_for_cpu(ia->ri_device,
-				   rdmab_addr(rep->rr_rdmabuf),
-				   rdmab_length(rep->rr_rdmabuf),
-				   DMA_BIDIRECTIONAL);
-
 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
 	if (rc)
 		goto out_postrecv;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index cc426b1..9569b21 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -113,6 +113,7 @@ struct rpcrdma_ep {
 
 struct rpcrdma_regbuf {
 	struct ib_sge		rg_iov;
+	enum dma_data_direction	rg_direction;
 	__be32			rg_base[0] __attribute__ ((aligned(256)));
 };
 
@@ -477,7 +478,8 @@ void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 void rpcrdma_defer_mr_recovery(struct rpcrdma_mw *);
 
 struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
-					    size_t, gfp_t);
+					    size_t, enum dma_data_direction,
+					    gfp_t);
 void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 

