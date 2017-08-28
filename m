Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33497 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdH1TGH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 15:06:07 -0400
Subject: [PATCH 1/3] svcrdma: Limit RQ depth
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 15:06:06 -0400
Message-ID: <20170828190605.13285.56173.stgit@klimt.1015granger.net>
In-Reply-To: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
References: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the chosen Receive Queue depth for a newly created
transport does not overrun the QP WR limit of the underlying device.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 2aa8473..cdb04f8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -167,8 +167,8 @@ static bool svc_rdma_prealloc_ctxts(struct svcxprt_rdma *xprt)
 {
 	unsigned int i;
 
-	/* Each RPC/RDMA credit can consume a number of send
-	 * and receive WQEs. One ctxt is allocated for each.
+	/* Each RPC/RDMA credit can consume one Receive and
+	 * one Send WQE at the same time.
 	 */
 	i = xprt->sc_sq_depth + xprt->sc_rq_depth;
 
@@ -742,13 +742,18 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_max_sge = min((size_t)dev->attrs.max_sge,
 				  (size_t)RPCSVC_MAXPAGES);
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
-	newxprt->sc_max_requests = min_t(u32, dev->attrs.max_qp_wr,
-					 svcrdma_max_requests);
-	newxprt->sc_fc_credits = cpu_to_be32(newxprt->sc_max_requests);
-	newxprt->sc_max_bc_requests = min_t(u32, dev->attrs.max_qp_wr,
-					    svcrdma_max_bc_requests);
+	newxprt->sc_max_requests = svcrdma_max_requests;
+	newxprt->sc_max_bc_requests = svcrdma_max_bc_requests;
 	newxprt->sc_rq_depth = newxprt->sc_max_requests +
 			       newxprt->sc_max_bc_requests;
+	if (newxprt->sc_rq_depth > dev->attrs.max_qp_wr) {
+		pr_warn("svcrdma: reducing receive depth to %d\n",
+			dev->attrs.max_qp_wr);
+		newxprt->sc_rq_depth = dev->attrs.max_qp_wr;
+		newxprt->sc_max_requests = newxprt->sc_rq_depth - 2;
+		newxprt->sc_max_bc_requests = 2;
+	}
+	newxprt->sc_fc_credits = cpu_to_be32(newxprt->sc_max_requests);
 	newxprt->sc_sq_depth = newxprt->sc_rq_depth;
 	atomic_set(&newxprt->sc_sq_avail, newxprt->sc_sq_depth);
 

