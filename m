Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36229 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752977AbcKIRq4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 12:46:56 -0500
Subject: [PATCH v1 5/7] svcrdma: Remove DMA map accounting
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 12:34:18 -0500
Message-ID: <20161109173418.15735.63913.stgit@klimt.1015granger.net>
In-Reply-To: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
References: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: sc_dma_used is not required for correct operation. It is
simply a debugging tool to report when svcrdma has leaked DMA maps.

However, manipulating an atomic has a measurable CPU cost, and DMA
map accounting specific to svcrdma will be meaningless once svcrdma
is converted to use the new generic r/w API.

A similar kind of debug accounting can be done simply by enabling
the IOMMU or by using CONFIG_DMA_API_DEBUG, CONFIG_IOMMU_DEBUG, and
CONFIG_IOMMU_LEAK.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 --
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   13 +++----------
 3 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 601cb07..43d7c70 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -148,7 +148,6 @@ struct svcxprt_rdma {
 
 	struct ib_pd         *sc_pd;
 
-	atomic_t	     sc_dma_used;
 	spinlock_t	     sc_ctxt_lock;
 	struct list_head     sc_ctxts;
 	int		     sc_ctxt_used;
@@ -200,7 +199,6 @@ static inline void svc_rdma_count_mappings(struct svcxprt_rdma *rdma,
 					   struct svc_rdma_op_ctxt *ctxt)
 {
 	ctxt->mapped_sges++;
-	atomic_inc(&rdma->sc_dma_used);
 }
 
 /* svc_rdma_backchannel.c */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 5ac93cb..bf18811 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -279,7 +279,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 		       frmr->sg);
 		return -ENOMEM;
 	}
-	atomic_inc(&xprt->sc_dma_used);
 
 	n = ib_map_mr_sg(frmr->mr, frmr->sg, frmr->sg_nents, NULL, PAGE_SIZE);
 	if (unlikely(n != frmr->sg_nents)) {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f7dd6494..ceff814 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -224,25 +224,22 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 	struct svcxprt_rdma *xprt = ctxt->xprt;
 	struct ib_device *device = xprt->sc_cm_id->device;
 	u32 lkey = xprt->sc_pd->local_dma_lkey;
-	unsigned int i, count;
+	unsigned int i;
 
-	for (count = 0, i = 0; i < ctxt->mapped_sges; i++) {
+	for (i = 0; i < ctxt->mapped_sges; i++) {
 		/*
 		 * Unmap the DMA addr in the SGE if the lkey matches
 		 * the local_dma_lkey, otherwise, ignore it since it is
 		 * an FRMR lkey and will be unmapped later when the
 		 * last WR that uses it completes.
 		 */
-		if (ctxt->sge[i].lkey == lkey) {
-			count++;
+		if (ctxt->sge[i].lkey == lkey)
 			ib_dma_unmap_page(device,
 					    ctxt->sge[i].addr,
 					    ctxt->sge[i].length,
 					    ctxt->direction);
-		}
 	}
 	ctxt->mapped_sges = 0;
-	atomic_sub(count, &xprt->sc_dma_used);
 }
 
 void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
@@ -944,7 +941,6 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 	if (frmr) {
 		ib_dma_unmap_sg(rdma->sc_cm_id->device,
 				frmr->sg, frmr->sg_nents, frmr->direction);
-		atomic_dec(&rdma->sc_dma_used);
 		spin_lock_bh(&rdma->sc_frmr_q_lock);
 		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
 		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
@@ -1256,9 +1252,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	if (rdma->sc_ctxt_used != 0)
 		pr_err("svcrdma: ctxt still in use? (%d)\n",
 		       rdma->sc_ctxt_used);
-	if (atomic_read(&rdma->sc_dma_used) != 0)
-		pr_err("svcrdma: dma still in use? (%d)\n",
-		       atomic_read(&rdma->sc_dma_used));
 
 	/* Final put of backchannel client transport */
 	if (xprt->xpt_bc_xprt) {

