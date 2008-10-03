From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 09/12] svcrdma: Update svc_rdma_send_error to use DMA LKEY
Date: Fri,  3 Oct 2008 16:33:46 -0500
Message-ID: <1223069629-5267-10-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-7-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-8-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-9-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40990 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbYJCVdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:51 -0400
In-Reply-To: <1223069629-5267-9-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the svc_rdma_send_error code to use the DMA LKEY which is valid
regardless of the memory registration strategy in use.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 360ff97..36e2cc4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1320,10 +1320,14 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
 
 	/* Prepare SGE for local address */
-	atomic_inc(&xprt->sc_dma_used);
 	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
 				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
-	sge.lkey = xprt->sc_phys_mr->lkey;
+	if (ib_dma_mapping_error(xprt->sc_cm_id->device, sge.addr)) {
+		put_page(p);
+		return;
+	}
+	atomic_inc(&xprt->sc_dma_used);
+	sge.lkey = xprt->sc_dma_lkey;
 	sge.length = length;
 
 	ctxt = svc_rdma_get_context(xprt);
@@ -1344,6 +1348,9 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);
+		ib_dma_unmap_page(xprt->sc_cm_id->device,
+				  sge.addr, PAGE_SIZE,
+				  DMA_FROM_DEVICE);
 		svc_rdma_put_context(ctxt, 1);
 	}
 }
