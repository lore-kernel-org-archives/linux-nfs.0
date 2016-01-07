Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34016 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcAGTuD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:50:03 -0500
Subject: [PATCH v5 09/10] svcrdma: Define maximum number of backchannel
 requests
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:50:02 -0500
Message-ID: <20160107195001.2662.81055.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extra resources for handling backchannel requests have to be
pre-allocated when a transport instance is created. Set up
additional fields in svcxprt_rdma to track these resources.

The max_requests fields are elements of the RPC-over-RDMA
protocol, so they should be u32. To ensure that unsigned
arithmetic is used everywhere, some other fields in the
svcxprt_rdma struct are updated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 include/linux/sunrpc/svc_rdma.h          |   13 ++++++++++---
 net/sunrpc/xprtrdma/svc_rdma.c           |    6 ++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   24 ++++++++++++++----------
 3 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index aeffa30..9a2c418 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -51,6 +51,7 @@
 /* RPC/RDMA parameters and stats */
 extern unsigned int svcrdma_ord;
 extern unsigned int svcrdma_max_requests;
+extern unsigned int svcrdma_max_bc_requests;
 extern unsigned int svcrdma_max_req_size;
 
 extern atomic_t rdma_stat_recv;
@@ -134,10 +135,11 @@ struct svcxprt_rdma {
 	int                  sc_max_sge;
 	int                  sc_max_sge_rd;	/* max sge for read target */
 
-	int                  sc_sq_depth;	/* Depth of SQ */
 	atomic_t             sc_sq_count;	/* Number of SQ WR on queue */
-
-	int                  sc_max_requests;	/* Depth of RQ */
+	unsigned int	     sc_sq_depth;	/* Depth of SQ */
+	unsigned int	     sc_rq_depth;	/* Depth of RQ */
+	u32		     sc_max_requests;	/* Forward credits */
+	u32		     sc_max_bc_requests;/* Backward credits */
 	int                  sc_max_req_size;	/* Size of each RQ WR buf */
 
 	struct ib_pd         *sc_pd;
@@ -186,6 +188,11 @@ struct svcxprt_rdma {
 #define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
+/* Typical ULP usage of BC requests is NFSv4.1 backchannel. Our
+ * current NFSv4.1 implementation supports one backchannel slot.
+ */
+#define RPCRDMA_MAX_BC_REQUESTS	2
+
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
 /* svc_rdma_marshal.c */
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index e894e06..c846ca9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -55,6 +55,7 @@ unsigned int svcrdma_ord = RPCRDMA_ORD;
 static unsigned int min_ord = 1;
 static unsigned int max_ord = 4096;
 unsigned int svcrdma_max_requests = RPCRDMA_MAX_REQUESTS;
+unsigned int svcrdma_max_bc_requests = RPCRDMA_MAX_BC_REQUESTS;
 static unsigned int min_max_requests = 4;
 static unsigned int max_max_requests = 16384;
 unsigned int svcrdma_max_req_size = RPCRDMA_MAX_REQ_SIZE;
@@ -245,9 +246,10 @@ int svc_rdma_init(void)
 {
 	dprintk("SVCRDMA Module Init, register RPC RDMA transport\n");
 	dprintk("\tsvcrdma_ord      : %d\n", svcrdma_ord);
-	dprintk("\tmax_requests     : %d\n", svcrdma_max_requests);
-	dprintk("\tsq_depth         : %d\n",
+	dprintk("\tmax_requests     : %u\n", svcrdma_max_requests);
+	dprintk("\tsq_depth         : %u\n",
 		svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT);
+	dprintk("\tmax_bc_requests  : %u\n", svcrdma_max_bc_requests);
 	dprintk("\tmax_inline       : %d\n", svcrdma_max_req_size);
 
 	svc_rdma_wq = alloc_workqueue("svc_rdma", 0, 0);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 8b3ee04..af86dfe 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -169,12 +169,12 @@ static struct svc_rdma_op_ctxt *alloc_ctxt(struct svcxprt_rdma *xprt,
 
 static bool svc_rdma_prealloc_ctxts(struct svcxprt_rdma *xprt)
 {
-	int i;
+	unsigned int i;
 
 	/* Each RPC/RDMA credit can consume a number of send
 	 * and receive WQEs. One ctxt is allocated for each.
 	 */
-	i = xprt->sc_sq_depth + xprt->sc_max_requests;
+	i = xprt->sc_sq_depth + xprt->sc_rq_depth;
 
 	while (i--) {
 		struct svc_rdma_op_ctxt *ctxt;
@@ -285,7 +285,7 @@ static struct svc_rdma_req_map *alloc_req_map(gfp_t flags)
 
 static bool svc_rdma_prealloc_maps(struct svcxprt_rdma *xprt)
 {
-	int i;
+	unsigned int i;
 
 	/* One for each receive buffer on this connection. */
 	i = xprt->sc_max_requests;
@@ -1016,8 +1016,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct ib_device *dev;
 	int uninitialized_var(dma_mr_acc);
 	int need_dma_mr = 0;
+	unsigned int i;
 	int ret = 0;
-	int i;
 
 	listen_rdma = container_of(xprt, struct svcxprt_rdma, sc_xprt);
 	clear_bit(XPT_CONN, &xprt->xpt_flags);
@@ -1046,9 +1046,13 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_max_sge_rd = min_t(size_t, dev->attrs.max_sge_rd,
 				       RPCSVC_MAXPAGES);
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
-	newxprt->sc_max_requests = min((size_t)dev->attrs.max_qp_wr,
-				   (size_t)svcrdma_max_requests);
-	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
+	newxprt->sc_max_requests = min_t(u32, dev->attrs.max_qp_wr,
+					 svcrdma_max_requests);
+	newxprt->sc_max_bc_requests = min_t(u32, dev->attrs.max_qp_wr,
+					    svcrdma_max_bc_requests);
+	newxprt->sc_rq_depth = newxprt->sc_max_requests +
+			       newxprt->sc_max_bc_requests;
+	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_rq_depth;
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
@@ -1077,7 +1081,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
 	}
-	cq_attr.cqe = newxprt->sc_max_requests;
+	cq_attr.cqe = newxprt->sc_rq_depth;
 	newxprt->sc_rq_cq = ib_create_cq(dev,
 					 rq_comp_handler,
 					 cq_event_handler,
@@ -1092,7 +1096,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
 	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
-	qp_attr.cap.max_recv_wr = newxprt->sc_max_requests;
+	qp_attr.cap.max_recv_wr = newxprt->sc_rq_depth;
 	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
 	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
 	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -1183,7 +1187,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt->sc_dma_lkey = dev->local_dma_lkey;
 
 	/* Post receive buffers */
-	for (i = 0; i < newxprt->sc_max_requests; i++) {
+	for (i = 0; i < newxprt->sc_rq_depth; i++) {
 		ret = svc_rdma_post_recv(newxprt, GFP_KERNEL);
 		if (ret) {
 			dprintk("svcrdma: failure posting receive buffers\n");

