Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33342 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754564AbdFWVTQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:19:16 -0400
Subject: [PATCH v3 15/18] svcrdma: Clean-up svc_rdma_unmap_dma
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 23 Jun 2017 17:19:05 -0400
Message-ID: <20170623211905.5162.48422.stgit@klimt.1015granger.net>
In-Reply-To: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no longer a need to compare each SGE's lkey with the PD's
local_dma_lkey. Now that FRWR is gone, all DMA mappings are for
pages that were registered with this key.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 8864105..75bd11f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -225,22 +225,13 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 {
 	struct svcxprt_rdma *xprt = ctxt->xprt;
 	struct ib_device *device = xprt->sc_cm_id->device;
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
+		ib_dma_unmap_page(device,
+				  ctxt->sge[i].addr,
+				  ctxt->sge[i].length,
+				  ctxt->direction);
 	ctxt->mapped_sges = 0;
 }
 

