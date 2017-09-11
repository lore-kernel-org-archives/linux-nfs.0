Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38351 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdIKPQ5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Sep 2017 11:16:57 -0400
Subject: [PATCH v1 5/7] xprtrdma: Manage RDMA Send arguments via lock-free
 circular queue
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Sep 2017 11:18:49 -0400
Message-ID: <150514312482.1307.8481866545401169354.stgit@lebasque.1015granger.net>
In-Reply-To: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
References: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than using the SGE array in struct rpcrdma_req, use a sendctx
to manage Send SGEs. Unmap these SGEs in the Send completion handler
instead of in xprt_rdma_free.  This allows Send WRs to outlive RPCs.

Reported-by: Sagi Grimberg <sagi@grimberg.me>
Suggested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   31 ++++++++++++-------------------
 net/sunrpc/xprtrdma/transport.c |    1 -
 net/sunrpc/xprtrdma/verbs.c     |   24 ++++++++++++++++--------
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +-----
 4 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 545f5d0..8e71d03 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -517,8 +517,9 @@ static bool
 rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			u32 len)
 {
+	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
-	struct ib_sge *sge = &req->rl_send_sge[0];
+	struct ib_sge *sge = sc->sc_sges;
 
 	if (!rpcrdma_dma_map_regbuf(ia, rb))
 		goto out_regbuf;
@@ -528,7 +529,7 @@ rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 
 	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr,
 				      sge->length, DMA_TO_DEVICE);
-	req->rl_send_wr.num_sge++;
+	sc->sc_wr.num_sge++;
 	return true;
 
 out_regbuf:
@@ -543,10 +544,11 @@ static bool
 rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			 struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
 {
+	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	unsigned int sge_no, page_base, len, remaining;
 	struct rpcrdma_regbuf *rb = req->rl_sendbuf;
 	struct ib_device *device = ia->ri_device;
-	struct ib_sge *sge = req->rl_send_sge;
+	struct ib_sge *sge = sc->sc_sges;
 	u32 lkey = ia->ri_pd->local_dma_lkey;
 	struct page *page, **ppages;
 
@@ -637,8 +639,9 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	}
 
 out:
-	req->rl_send_wr.num_sge += sge_no;
-	req->rl_mapped_sges = sge_no - 1;
+	sc->sc_wr.num_sge += sge_no;
+	sc->sc_unmap_count = sge_no - 1;
+	sc->sc_device = device;
 	return true;
 
 out_regbuf:
@@ -669,8 +672,11 @@ rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			  struct rpcrdma_req *req, u32 hdrlen,
 			  struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
 {
-	req->rl_send_wr.num_sge = 0;
+	req->rl_sendctx = rpcrdma_sendctx_get_locked(&r_xprt->rx_buf);
+	if (!req->rl_sendctx)
+		return -ENOBUFS;
 
+	req->rl_sendctx->sc_wr.num_sge = 0;
 	if (!rpcrdma_prepare_hdr_sge(&r_xprt->rx_ia, req, hdrlen))
 		return -EIO;
 
@@ -681,19 +687,6 @@ rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 	return 0;
 }
 
-void
-rpcrdma_unmap_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
-{
-	struct ib_device *device = ia->ri_device;
-	struct ib_sge *sge;
-	int count;
-
-	sge = &req->rl_send_sge[2];
-	for (count = req->rl_mapped_sges; count--; sge++)
-		ib_dma_unmap_page(device, sge->addr, sge->length,
-				  DMA_TO_DEVICE);
-}
-
 /**
  * __rpcrdma_unmap_send_sges - DMA-unmap Send buffers
  * @sc: send_ctx containing SGEs to unmap
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 18cb8b4..4cca4a7 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -688,7 +688,6 @@ xprt_rdma_free(struct rpc_task *task)
 	rpcrdma_remove_req(&r_xprt->rx_buf, req);
 	if (!list_empty(&req->rl_registered))
 		ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
-	rpcrdma_unmap_sges(ia, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 219f2d8..3409de8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -128,11 +128,17 @@ rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 static void
 rpcrdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 {
+	struct ib_cqe *cqe = wc->wr_cqe;
+	struct rpcrdma_sendctx *sc =
+		container_of(cqe, struct rpcrdma_sendctx, sc_cqe);
+
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS && wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("rpcrdma: Send: %s (%u/0x%x)\n",
 		       ib_wc_status_msg(wc->status),
 		       wc->status, wc->vendor_err);
+
+	rpcrdma_sendctx_put_locked(sc);
 }
 
 /* Perform basic sanity checking to avoid using garbage
@@ -1104,13 +1110,8 @@ rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 	spin_lock(&buffer->rb_reqslock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_reqslock);
-	req->rl_cqe.done = rpcrdma_wc_send;
 	req->rl_buffer = &r_xprt->rx_buf;
 	INIT_LIST_HEAD(&req->rl_registered);
-	req->rl_send_wr.next = NULL;
-	req->rl_send_wr.wr_cqe = &req->rl_cqe;
-	req->rl_send_wr.sg_list = req->rl_send_sge;
-	req->rl_send_wr.opcode = IB_WR_SEND;
 	return req;
 }
 
@@ -1401,7 +1402,6 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	struct rpcrdma_rep *rep = req->rl_reply;
 
-	req->rl_send_wr.num_sge = 0;
 	req->rl_reply = NULL;
 
 	spin_lock(&buffers->rb_lock);
@@ -1533,7 +1533,8 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		struct rpcrdma_ep *ep,
 		struct rpcrdma_req *req)
 {
-	struct ib_send_wr *send_wr = &req->rl_send_wr;
+	struct rpcrdma_sendctx *sc = req->rl_sendctx;
+	struct ib_send_wr *send_wr = &sc->sc_wr;
 	struct ib_send_wr *send_wr_fail;
 	int rc;
 
@@ -1547,10 +1548,17 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 	dprintk("RPC:       %s: posting %d s/g entries\n",
 		__func__, send_wr->num_sge);
 
-	rpcrdma_set_signaled(ep, send_wr);
+	if (!ep->rep_send_count) {
+		send_wr->send_flags |= IB_SEND_SIGNALED;
+		ep->rep_send_count = ep->rep_send_batch;
+	} else {
+		send_wr->send_flags &= ~IB_SEND_SIGNALED;
+		--ep->rep_send_count;
+	}
 	rc = ib_post_send(ia->ri_id->qp, send_wr, &send_wr_fail);
 	if (rc)
 		goto out_postsend_err;
+
 	return 0;
 
 out_postsend_err:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f9ac1fd..64cfc11 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -367,19 +367,16 @@ struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
 	__be32			rl_xid;
-	unsigned int		rl_mapped_sges;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
 	struct xdr_stream	rl_stream;
 	struct xdr_buf		rl_hdrbuf;
-	struct ib_send_wr	rl_send_wr;
-	struct ib_sge		rl_send_sge[RPCRDMA_MAX_SEND_SGES];
+	struct rpcrdma_sendctx	*rl_sendctx;
 	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */
 	struct rpcrdma_regbuf	*rl_sendbuf;	/* rq_snd_buf */
 	struct rpcrdma_regbuf	*rl_recvbuf;	/* rq_rcv_buf */
 
-	struct ib_cqe		rl_cqe;
 	struct list_head	rl_all;
 	bool			rl_backchannel;
 
@@ -678,7 +675,6 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			      struct rpcrdma_req *req, u32 hdrlen,
 			      struct xdr_buf *xdr,
 			      enum rpcrdma_chunktype rtype);
-void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 void __rpcrdma_unmap_send_sges(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);

