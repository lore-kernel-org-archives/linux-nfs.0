Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33182 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668AbbK3WYv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:24:51 -0500
Subject: [PATCH v2 3/7] svcrdma: Define maximum number of backchannel
 requests
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:24:49 -0500
Message-ID: <20151130222449.13029.35573.stgit@klimt.1015granger.net>
In-Reply-To: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extra resources for handling backchannel requests have to be
pre-allocated when a transport instance is created. Set a limit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   14 +++++++++-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index cc69551..c189fbd 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -137,6 +137,7 @@ struct svcxprt_rdma {
 
 	int                  sc_max_requests;	/* Depth of RQ */
 	int                  sc_max_req_size;	/* Size of each RQ WR buf */
+	int                  sc_max_bc_requests;
 
 	struct ib_pd         *sc_pd;
 
@@ -178,6 +179,7 @@ struct svcxprt_rdma {
 #define RPCRDMA_SQ_DEPTH_MULT   8
 #define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
+#define RPCRDMA_MAX_BC_REQUESTS	2
 
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 94b8d4c..643402e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -541,6 +541,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 
 	cma_xprt->sc_max_req_size = svcrdma_max_req_size;
 	cma_xprt->sc_max_requests = svcrdma_max_requests;
+	cma_xprt->sc_max_bc_requests = RPCRDMA_MAX_BC_REQUESTS;
 	cma_xprt->sc_sq_depth = svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT;
 	atomic_set(&cma_xprt->sc_sq_count, 0);
 	atomic_set(&cma_xprt->sc_ctxt_used, 0);
@@ -897,6 +898,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct ib_device_attr devattr;
 	int uninitialized_var(dma_mr_acc);
 	int need_dma_mr = 0;
+	int total_reqs;
 	int ret;
 	int i;
 
@@ -932,8 +934,10 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_max_sge_rd = min_t(size_t, devattr.max_sge_rd,
 				       RPCSVC_MAXPAGES);
 	newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
-				   (size_t)svcrdma_max_requests);
-	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
+				       (size_t)svcrdma_max_requests);
+	newxprt->sc_max_bc_requests = RPCRDMA_MAX_BC_REQUESTS;
+	total_reqs = newxprt->sc_max_requests + newxprt->sc_max_bc_requests;
+	newxprt->sc_sq_depth = total_reqs * RPCRDMA_SQ_DEPTH_MULT;
 
 	/*
 	 * Limit ORD based on client limit, local device limit, and
@@ -957,7 +961,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
 	}
-	cq_attr.cqe = newxprt->sc_max_requests;
+	cq_attr.cqe = total_reqs;
 	newxprt->sc_rq_cq = ib_create_cq(newxprt->sc_cm_id->device,
 					 rq_comp_handler,
 					 cq_event_handler,
@@ -972,7 +976,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
 	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
-	qp_attr.cap.max_recv_wr = newxprt->sc_max_requests;
+	qp_attr.cap.max_recv_wr = total_reqs;
 	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
 	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
 	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -1068,7 +1072,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			newxprt->sc_cm_id->device->local_dma_lkey;
 
 	/* Post receive buffers */
-	for (i = 0; i < newxprt->sc_max_requests; i++) {
+	for (i = 0; i < total_reqs; i++) {
 		ret = svc_rdma_post_recv(newxprt);
 		if (ret) {
 			dprintk("svcrdma: failure posting receive buffers\n");

