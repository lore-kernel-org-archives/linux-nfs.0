Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36293 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752408AbdIERAs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:00:48 -0400
Subject: [PATCH RFC 4/5] xprtrdma: Manage RDMA Send arguments via lock-free
 circular queue
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 05 Sep 2017 13:00:46 -0400
Message-ID: <20170905170046.11106.41992.stgit@manet.1015granger.net>
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hook rpcrdma_ep_post and the send completion handler up with the new
send ctxs, and remove Send buffer DMA unmapping from xprt_rdma_free.

Care must be taken if an error occurs before the Send is posted.
In this case, the send_ctx has to be popped back onto the circular
queue, since it will never be completed or flushed. This is done
before send_request's call allows another RPC Call to proceed.

Reported-by: Sagi Grimberg <sagi@grimberg.me>
Suggested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   40 +++++++++++++++------------------------
 net/sunrpc/xprtrdma/transport.c |    1 -
 net/sunrpc/xprtrdma/verbs.c     |   28 ++++++++++++++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +-----
 4 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 63461bd..d074da2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -517,20 +517,20 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			u32 len)
 {
+	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
-	struct ib_sge *sge = &req->rl_send_sge[0];
+	struct ib_sge *sge = sc->sc_sges;
 
-	if (unlikely(!rpcrdma_regbuf_is_mapped(rb))) {
+	if (unlikely(!rpcrdma_regbuf_is_mapped(rb)))
 		if (!__rpcrdma_dma_map_regbuf(ia, rb))
 			goto out_regbuf;
-		sge->addr = rdmab_addr(rb);
-		sge->lkey = rdmab_lkey(rb);
-	}
+	sge->addr = rdmab_addr(rb);
+	sge->lkey = rdmab_lkey(rb);
 	sge->length = len;
 
 	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr,
 				      sge->length, DMA_TO_DEVICE);
-	req->rl_send_wr.num_sge++;
+	sc->sc_wr.num_sge++;
 	return true;
 
 out_regbuf:
@@ -545,13 +545,16 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
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
 
+	sc->sc_device = device;
+
 	/* The head iovec is straightforward, as it is already
 	 * DMA-mapped. Sync the content that has changed.
 	 */
@@ -639,8 +642,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	}
 
 out:
-	req->rl_send_wr.num_sge += sge_no;
-	req->rl_mapped_sges += sge_no - 1;
+	sc->sc_wr.num_sge += sge_no;
+	sc->sc_unmap_count += sge_no - 1;
 	return true;
 
 out_regbuf:
@@ -671,8 +674,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			  struct rpcrdma_req *req, u32 hdrlen,
 			  struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
 {
-	req->rl_send_wr.num_sge = 0;
-	req->rl_mapped_sges = 0;
+	req->rl_sendctx = rpcrdma_sendctx_get_locked(&r_xprt->rx_buf);
+	if (!req->rl_sendctx)
+		return -ENOBUFS;
 
 	if (!rpcrdma_prepare_hdr_sge(&r_xprt->rx_ia, req, hdrlen))
 		return -EIO;
@@ -684,20 +688,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
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
-	req->rl_mapped_sges = 0;
-}
-
 /**
  * rpcrdma_unmap_send_sges - DMA-unmap Send buffers
  * @sc: send_ctx containing SGEs to unmap
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 18cb8b4..4cca4a7 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -688,7 +688,6 @@
 	rpcrdma_remove_req(&r_xprt->rx_buf, req);
 	if (!list_empty(&req->rl_registered))
 		ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
-	rpcrdma_unmap_sges(ia, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 81d081d..75899ba 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -128,11 +128,17 @@
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
@@ -1113,13 +1119,8 @@ struct rpcrdma_req *
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
 
@@ -1410,7 +1411,6 @@ struct rpcrdma_req *
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	struct rpcrdma_rep *rep = req->rl_reply;
 
-	req->rl_send_wr.num_sge = 0;
 	req->rl_reply = NULL;
 
 	spin_lock(&buffers->rb_lock);
@@ -1542,7 +1542,7 @@ struct rpcrdma_regbuf *
 		struct rpcrdma_ep *ep,
 		struct rpcrdma_req *req)
 {
-	struct ib_send_wr *send_wr = &req->rl_send_wr;
+	struct ib_send_wr *send_wr = &req->rl_sendctx->sc_wr;
 	struct ib_send_wr *send_wr_fail;
 	int rc;
 
@@ -1556,10 +1556,22 @@ struct rpcrdma_regbuf *
 	dprintk("RPC:       %s: posting %d s/g entries\n",
 		__func__, send_wr->num_sge);
 
-	rpcrdma_set_signaled(ep, send_wr);
+	/* Signal Send once every "rep_send_batch" WRs:
+	 * - Mitigate interrupts due to Send completions
+	 * - Batch up DMA unmapping send buffers
+	 * - Allow verbs provider housekeeping on the Send Queue
+	 */
+	if (ep->rep_send_count) {
+		send_wr->send_flags &= ~IB_SEND_SIGNALED;
+		--ep->rep_send_count;
+	} else {
+		send_wr->send_flags |= IB_SEND_SIGNALED;
+		ep->rep_send_count = ep->rep_send_batch;
+	}
 	rc = ib_post_send(ia->ri_id->qp, send_wr, &send_wr_fail);
 	if (rc)
 		goto out_postsend_err;
+
 	return 0;
 
 out_postsend_err:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 1967e7a..8f8e2dd 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -365,19 +365,16 @@ enum {
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
 
@@ -676,7 +673,6 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			      struct rpcrdma_req *req, u32 hdrlen,
 			      struct xdr_buf *xdr,
 			      enum rpcrdma_chunktype rtype);
-void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 void rpcrdma_unmap_send_sges(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);

