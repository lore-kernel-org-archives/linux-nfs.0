From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 09/09] svcrdma: Update svc_rdma_send_error to use DMA
 LKEY
Date: Wed, 13 Aug 2008 11:16:45 -0500
Message-ID: <48A308ED.40900@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36755 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbYHMQQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:16:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the svc_rdma_send_error code to use the DMA LKEY which is valid
regardless of the memory registration strategy in use.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
  1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index e75cb96..94f51da 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1331,10 +1331,14 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
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
@@ -1355,6 +1359,9 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
  	if (ret) {
  		dprintk("svcrdma: Error %d posting send for protocol error\n",
  			ret);
+		ib_dma_unmap_page(xprt->sc_cm_id->device,
+				  sge.addr, PAGE_SIZE,
+				  DMA_FROM_DEVICE);
  		svc_rdma_put_context(ctxt, 1);
  	}
  }
