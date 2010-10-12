Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55055 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754247Ab0JLUd6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 16:33:58 -0400
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 2/2] svcrdma: Cleanup DMA unmapping in error paths.
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 12 Oct 2010 15:33:57 -0500
Message-ID: <20101012203357.22154.95700.stgit@build.ogc.int>
In-Reply-To: <20101012203332.22154.37230.stgit@build.ogc.int>
References: <20101012203332.22154.37230.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There are several error paths in the code that do not unmap DMA. This
patch adds calls to svc_rdma_unmap_dma to free these DMA contexts.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 ++++++++++++++---------------
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 926bdb4..df67211 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -495,6 +495,7 @@ next_sge:
 			printk(KERN_ERR "svcrdma: Error %d posting RDMA_READ\n",
 			       err);
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+			svc_rdma_unmap_dma(ctxt);
 			svc_rdma_put_context(ctxt, 0);
 			goto out;
 		}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index d4f5e0e..249a835 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -367,6 +367,8 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		goto err;
 	return 0;
  err:
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_frmr(xprt, vec->frmr);
 	svc_rdma_put_context(ctxt, 0);
 	/* Fatal error, close transport */
 	return -EIO;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 23f90c3..d22a44d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -511,9 +511,9 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		ctxt->sge[sge_no].addr = pa;
 		ctxt->sge[sge_no].length = PAGE_SIZE;
 		ctxt->sge[sge_no].lkey = xprt->sc_dma_lkey;
+		ctxt->count = sge_no + 1;
 		buflen += PAGE_SIZE;
 	}
-	ctxt->count = sge_no;
 	recv_wr.next = NULL;
 	recv_wr.sg_list = &ctxt->sge[0];
 	recv_wr.num_sge = ctxt->count;
@@ -529,6 +529,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 	return ret;
 
  err_put_ctxt:
+	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
 	return -ENOMEM;
 }
@@ -1306,7 +1307,6 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 			 enum rpcrdma_errcode err)
 {
 	struct ib_send_wr err_wr;
-	struct ib_sge sge;
 	struct page *p;
 	struct svc_rdma_op_ctxt *ctxt;
 	u32 *va;
@@ -1319,26 +1319,27 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	/* XDR encode error */
 	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
 
+	ctxt = svc_rdma_get_context(xprt);
+	ctxt->direction = DMA_FROM_DEVICE;
+	ctxt->count = 1;
+	ctxt->pages[0] = p;
+
 	/* Prepare SGE for local address */
-	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
-				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
-	if (ib_dma_mapping_error(xprt->sc_cm_id->device, sge.addr)) {
+	ctxt->sge[0].addr = ib_dma_map_page(xprt->sc_cm_id->device,
+					    p, 0, length, DMA_FROM_DEVICE);
+	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
 		put_page(p);
 		return;
 	}
 	atomic_inc(&xprt->sc_dma_used);
-	sge.lkey = xprt->sc_dma_lkey;
-	sge.length = length;
-
-	ctxt = svc_rdma_get_context(xprt);
-	ctxt->count = 1;
-	ctxt->pages[0] = p;
+	ctxt->sge[0].lkey = xprt->sc_dma_lkey;
+	ctxt->sge[0].length = length;
 
 	/* Prepare SEND WR */
 	memset(&err_wr, 0, sizeof err_wr);
 	ctxt->wr_op = IB_WR_SEND;
 	err_wr.wr_id = (unsigned long)ctxt;
-	err_wr.sg_list = &sge;
+	err_wr.sg_list = ctxt->sge;
 	err_wr.num_sge = 1;
 	err_wr.opcode = IB_WR_SEND;
 	err_wr.send_flags = IB_SEND_SIGNALED;
@@ -1348,9 +1349,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);
-		ib_dma_unmap_page(xprt->sc_cm_id->device,
-				  sge.addr, PAGE_SIZE,
-				  DMA_FROM_DEVICE);
+		svc_rdma_unmap_dma(ctxt);
 		svc_rdma_put_context(ctxt, 1);
 	}
 }

