Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35034 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbIQUqI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 16:46:08 -0400
Subject: [PATCH v1 14/18] svcrdma: Define maximum number of backchannel
 requests
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 17 Sep 2015 16:46:06 -0400
Message-ID: <20150917204606.19671.5961.stgit@manet.1015granger.net>
In-Reply-To: <20150917202829.19671.90044.stgit@manet.1015granger.net>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extra resources for handling backchannel requests have to be
pre-allocated when a transport instance is created. Set a limit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    5 +++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index fb4013e..6ce7495 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -180,6 +180,11 @@ struct svcxprt_rdma {
 #define RPCRDMA_SQ_DEPTH_MULT   8
 #define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+#define RPCRDMA_MAX_BC_REQUESTS	8
+#else
+#define RPCRDMA_MAX_BC_REQUESTS	0
+#endif
 
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index a133b1e..23aba30 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -935,8 +935,10 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 				  (size_t)RPCSVC_MAXPAGES);
 	newxprt->sc_max_sge_rd = min_t(size_t, devattr.max_sge_rd,
 				       RPCSVC_MAXPAGES);
+	/* XXX: what if HCA can't support enough WRs for bc operation? */
 	newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
-				   (size_t)svcrdma_max_requests);
+				       (size_t)(svcrdma_max_requests +
+				       RPCRDMA_MAX_BC_REQUESTS));
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
 
 	/*
@@ -976,7 +978,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
 	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
+	qp_attr.cap.max_send_wr += RPCRDMA_MAX_BC_REQUESTS;
 	qp_attr.cap.max_recv_wr = newxprt->sc_max_requests;
+	qp_attr.cap.max_recv_wr += RPCRDMA_MAX_BC_REQUESTS;
 	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
 	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
 	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;

