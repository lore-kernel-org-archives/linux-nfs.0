Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33267 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932275AbcHOUvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:51:37 -0400
Subject: [PATCH v1 10/22] xprtrdma: Delay DMA mapping Send and Receive
 buffers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:51:35 -0400
Message-ID: <20160815205135.11652.11596.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, each regbuf is allocated and DMA mapped at the same time.
This is done during transport creation.

When a device driver is unloaded, every DMA-mapped buffer in use by
a transport has to be unmapped, and then remapped to the new
device if the driver is loaded again. Remapping will have to be done
_after_ the connect worker has set up the new device.

But there's an ordering problem:

call_allocate, which invokes xprt_rdma_allocate which calls
rpcrdma_alloc_regbuf to allocate Send buffers, happens _before_
the connect worker can run to set up the new device.

Instead, at transport creation, allocate each buffer, but leave it
unmapped. Once the RPC carries these buffers into ->send_request, by
which time a transport connection should have been established,
check to see that the RPC's buffers have been DMA mapped. If not,
map them there.

When device driver unplug support is added, it will simply unmap all
the transport's regbufs, but it doesn't have to deallocate the
underlying memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    8 ++++
 net/sunrpc/xprtrdma/rpc_rdma.c    |    9 +++++
 net/sunrpc/xprtrdma/verbs.c       |   71 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |   16 ++++++++
 4 files changed, 78 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ceae872..8bc249e 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -230,16 +230,24 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 		__func__, (int)rpclen, rqst->rq_svec[0].iov_base);
 #endif
 
+	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_rdmabuf))
+		goto out_map;
 	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
 	req->rl_send_iov[0].length = RPCRDMA_HDRLEN_MIN;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
 
+	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_sendbuf))
+		goto out_map;
 	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
 	req->rl_niovs = 2;
 	return 0;
+
+out_map:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return -EIO;
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 845586f..68a39c0 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -681,6 +681,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		transfertypes[rtype], transfertypes[wtype],
 		hdrlen, rpclen);
 
+	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_rdmabuf))
+		goto out_map;
 	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
@@ -689,6 +691,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (rtype == rpcrdma_areadch)
 		return 0;
 
+	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_sendbuf))
+		goto out_map;
 	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
@@ -704,6 +708,11 @@ out_overflow:
 out_unmap:
 	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 	return PTR_ERR(iptr);
+
+out_map:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	iptr = ERR_PTR(-EIO);
+	goto out_unmap;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0bd2ace..b88bcf4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1160,9 +1160,8 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
  * @direction: direction of data movement
  * @flags: GFP flags
  *
- * Returns an ERR_PTR, or a pointer to a regbuf, which is a
- * contiguous memory region that is DMA mapped persistently, and
- * is registered for local I/O.
+ * Returns an ERR_PTR, or a pointer to a regbuf, a buffer that
+ * can be persistently DMA-mapped for I/O.
  *
  * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
  * receiving the payload of RDMA RECV operations. During Long Calls
@@ -1173,32 +1172,50 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size,
 		     enum dma_data_direction direction, gfp_t flags)
 {
 	struct rpcrdma_regbuf *rb;
-	struct ib_sge *iov;
 
 	rb = kmalloc(sizeof(*rb) + size, flags);
 	if (rb == NULL)
-		goto out;
+		return ERR_PTR(-ENOMEM);
 
+	rb->rg_device = NULL;
 	rb->rg_direction = direction;
-	iov = &rb->rg_iov;
-	iov->length = size;
-	iov->lkey = ia->ri_pd->local_dma_lkey;
-
-	if (direction != DMA_NONE) {
-		iov->addr = ib_dma_map_single(ia->ri_device,
-					      (void *)rb->rg_base,
-					      rdmab_length(rb),
-					      rb->rg_direction);
-		if (ib_dma_mapping_error(ia->ri_device, iov->addr))
-			goto out_free;
-	}
+	rb->rg_iov.length = size;
 
 	return rb;
+}
 
-out_free:
-	kfree(rb);
-out:
-	return ERR_PTR(-ENOMEM);
+/**
+ * __rpcrdma_map_regbuf - DMA-map a regbuf
+ * @ia: controlling rpcrdma_ia
+ * @rb: regbuf to be mapped
+ */
+bool
+__rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+{
+	if (rb->rg_direction == DMA_NONE)
+		return false;
+
+	rb->rg_iov.addr = ib_dma_map_single(ia->ri_device,
+					    (void *)rb->rg_base,
+					    rdmab_length(rb),
+					    rb->rg_direction);
+	if (ib_dma_mapping_error(ia->ri_device, rdmab_addr(rb)))
+		return false;
+
+	rb->rg_device = ia->ri_device;
+	rb->rg_iov.lkey = ia->ri_pd->local_dma_lkey;
+	return true;
+}
+
+static void
+rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb)
+{
+	if (!rpcrdma_regbuf_is_mapped(rb))
+		return;
+
+	ib_dma_unmap_single(rb->rg_device, rdmab_addr(rb),
+			    rdmab_length(rb), rb->rg_direction);
+	rb->rg_device = NULL;
 }
 
 /**
@@ -1212,11 +1229,7 @@ rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
 	if (!rb)
 		return;
 
-	if (rb->rg_direction != DMA_NONE) {
-		ib_dma_unmap_single(ia->ri_device, rdmab_addr(rb),
-				    rdmab_length(rb), rb->rg_direction);
-	}
-
+	rpcrdma_dma_unmap_regbuf(rb);
 	kfree(rb);
 }
 
@@ -1288,11 +1301,17 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 	recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	recv_wr.num_sge = 1;
 
+	if (!rpcrdma_dma_map_regbuf(ia, rep->rr_rdmabuf))
+		goto out_map;
 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
 	if (rc)
 		goto out_postrecv;
 	return 0;
 
+out_map:
+	pr_err("rpcrdma: failed to DMA map the Receive buffer\n");
+	return -EIO;
+
 out_postrecv:
 	pr_err("rpcrdma: ib_post_recv returned %i\n", rc);
 	return -ENOTCONN;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c6861ab..a8eb270 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -113,6 +113,7 @@ struct rpcrdma_ep {
 
 struct rpcrdma_regbuf {
 	struct ib_sge		rg_iov;
+	struct ib_device	*rg_device;
 	enum dma_data_direction	rg_direction;
 	__be32			rg_base[0] __attribute__ ((aligned(256)));
 };
@@ -479,9 +480,24 @@ void rpcrdma_defer_mr_recovery(struct rpcrdma_mw *);
 struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(struct rpcrdma_ia *,
 					    size_t, enum dma_data_direction,
 					    gfp_t);
+bool __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *, struct rpcrdma_regbuf *);
 void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 
+static inline bool
+rpcrdma_regbuf_is_mapped(struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_device != NULL;
+}
+
+static inline bool
+rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+{
+	if (!rpcrdma_regbuf_is_mapped(rb))
+		return __rpcrdma_dma_map_regbuf(ia, rb);
+	return true;
+}
+
 int rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *, unsigned int);
 
 int rpcrdma_alloc_wq(void);

