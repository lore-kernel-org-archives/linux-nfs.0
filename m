Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33413 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032635AbdAGRSJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:18:09 -0500
Subject: [PATCH v1 21/22] svcrdma: Clean-up svc_rdma_unmap_dma
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:18:07 -0500
Message-ID: <20170107171807.14126.25561.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcrdma no longer manages FRMRs, so there's no need to compare each
SGE's lkey with the PD's local_dma_lkey.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9b60740..4500000 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -223,23 +223,13 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 {
 	struct svcxprt_rdma *xprt = ctxt->xprt;
-	struct ib_device *device = xprt->sc_cm_id->device;
-	u32 lkey = xprt->sc_pd->local_dma_lkey;
 	unsigned int i;
 
-	for (i = 0; i < ctxt->mapped_sges; i++) {
-		/*
-		 * Unmap the DMA addr in the SGE if the lkey matches
-		 * the local_dma_lkey, otherwise, ignore it since it is
-		 * an FRMR lkey and will be unmapped later when the
-		 * last WR that uses it completes.
-		 */
-		if (ctxt->sge[i].lkey == lkey)
-			ib_dma_unmap_page(device,
-					    ctxt->sge[i].addr,
-					    ctxt->sge[i].length,
-					    ctxt->direction);
-	}
+	for (i = 0; i < ctxt->mapped_sges; i++)
+		ib_dma_unmap_page(xprt->sc_device,
+				  ctxt->sge[i].addr,
+				  ctxt->sge[i].length,
+				  ctxt->direction);
 	ctxt->mapped_sges = 0;
 }
 

