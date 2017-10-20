Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:56521 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751830AbdJTOrt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:47:49 -0400
Subject: [PATCH 2/9] xprtrdma: Fix error handling in
 rpcrdma_prepare_msg_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:47:47 -0400
Message-ID: <20171020144747.14869.77935.stgit@manet.1015granger.net>
In-Reply-To: <20171020143635.14869.15714.stgit@manet.1015granger.net>
References: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When this function fails, it needs to undo the DMA mappings it's
done so far. Otherwise these are leaked.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 3c92558..4f6c539 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -511,6 +511,28 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return 0;
 }
 
+/**
+ * rpcrdma_unmap_sges - DMA-unmap Send buffers
+ * @ia: interface adapter (device)
+ * @req: req with possibly some SGEs to be DMA unmapped
+ *
+ */
+void
+rpcrdma_unmap_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
+{
+	struct ib_sge *sge;
+	unsigned int count;
+
+	/* The first two SGEs contain the transport header and
+	 * the inline buffer. These are always left mapped so
+	 * they can be cheaply re-used.
+	 */
+	sge = &req->rl_send_sge[2];
+	for (count = req->rl_mapped_sges; count--; sge++)
+		ib_dma_unmap_page(ia->ri_device,
+				  sge->addr, sge->length, DMA_TO_DEVICE);
+}
+
 /* Prepare the RPC-over-RDMA header SGE.
  */
 static bool
@@ -641,10 +663,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return true;
 
 out_mapping_overflow:
+	rpcrdma_unmap_sges(ia, req);
 	pr_err("rpcrdma: too many Send SGEs (%u)\n", sge_no);
 	return false;
 
 out_mapping_err:
+	rpcrdma_unmap_sges(ia, req);
 	pr_err("rpcrdma: Send mapping error\n");
 	return false;
 }
@@ -671,20 +695,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return false;
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
  * rpcrdma_marshal_req - Marshal and send one RPC request
  * @r_xprt: controlling transport

