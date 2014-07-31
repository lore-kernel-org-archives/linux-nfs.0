Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:58371 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751541AbaGaU0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2014 16:26:07 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] svcrdma: remove rdma_create_qp() failure recovery logic
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 31 Jul 2014 15:26:07 -0500
Message-ID: <20140731202606.12144.2363.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In svc_rdma_accept(), if rdma_create_qp() fails, there is useless
logic to try and call rdma_create_qp() again with reduced sge depths.
The assumption, I guess, was that perhaps the initial sge depths
chosen were too big.  However they initial depths are selected based
on the rdma device attribute max_sge returned from ib_query_device().
If rdma_create_qp() fails, it would not be because the max_send_sge and
max_recv_sge values passed in exceed the device's max.  So just remove
this code.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index e7323fb..282a43b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -942,23 +942,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
 	if (ret) {
-		/*
-		 * XXX: This is a hack. We need a xx_request_qp interface
-		 * that will adjust the qp_attr's with a best-effort
-		 * number
-		 */
-		qp_attr.cap.max_send_sge -= 2;
-		qp_attr.cap.max_recv_sge -= 2;
-		ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd,
-				     &qp_attr);
-		if (ret) {
-			dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
-			goto errout;
-		}
-		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
-		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
-		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
-		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
+		dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
+		goto errout;
 	}
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 

