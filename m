Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35762 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032635AbdAGRSB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:18:01 -0500
Subject: [PATCH v1 20/22] svcrdma: Clean-up in svc_rdma_post_recv
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:17:59 -0500
Message-ID: <20170107171759.14126.66039.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Micro-optimization: Use cached copies of lkey and device instead
of chasing pointers in the RDMA layer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index b357bb2..9b60740 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -405,6 +405,14 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	return cma_xprt;
 }
 
+/**
+ * svc_rdma_post_recv - Post a receive WR
+ * @xprt: RPC-over-RDMA transport control block
+ * @flags: GFP flags
+ *
+ * Returns zero if receive WR was posted successfully, or
+ * a negative errno if nothing could be posted.
+ */
 int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 {
 	struct ib_recv_wr recv_wr, *bad_recv_wr;
@@ -416,9 +424,10 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	int ret;
 
 	ctxt = svc_rdma_get_context(xprt);
-	buflen = 0;
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->cqe.done = svc_rdma_wc_receive;
+
+	buflen = 0;
 	for (sge_no = 0; buflen < xprt->sc_max_req_size; sge_no++) {
 		if (sge_no >= xprt->sc_max_sge) {
 			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
@@ -428,15 +437,14 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 		if (!page)
 			goto err_put_ctxt;
 		ctxt->pages[sge_no] = page;
-		pa = ib_dma_map_page(xprt->sc_cm_id->device,
-				     page, 0, PAGE_SIZE,
-				     DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
+		pa = ib_dma_map_page(xprt->sc_device, page, 0,
+				     PAGE_SIZE, DMA_FROM_DEVICE);
+		if (ib_dma_mapping_error(xprt->sc_device, pa))
 			goto err_put_ctxt;
 		svc_rdma_count_mappings(xprt, ctxt);
 		ctxt->sge[sge_no].addr = pa;
 		ctxt->sge[sge_no].length = PAGE_SIZE;
-		ctxt->sge[sge_no].lkey = xprt->sc_pd->local_dma_lkey;
+		ctxt->sge[sge_no].lkey = xprt->sc_lkey;
 		ctxt->count = sge_no + 1;
 		buflen += PAGE_SIZE;
 	}

