From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 05/12] svcrdma: Modify post recv path to use local dma key
Date: Fri,  3 Oct 2008 16:33:42 -0500
Message-ID: <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40980 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbYJCVdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:50 -0400
In-Reply-To: <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the svc_rdma_post_recv routine to use the adapter's global LKEY
instead of sc_phys_mr which is only valid when using a DMA MR.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4b70282..a144fab 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -483,7 +483,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 	struct ib_recv_wr recv_wr, *bad_recv_wr;
 	struct svc_rdma_op_ctxt *ctxt;
 	struct page *page;
-	unsigned long pa;
+	dma_addr_t pa;
 	int sge_no;
 	int buflen;
 	int ret;
@@ -495,13 +495,15 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		BUG_ON(sge_no >= xprt->sc_max_sge);
 		page = svc_rdma_get_page();
 		ctxt->pages[sge_no] = page;
-		atomic_inc(&xprt->sc_dma_used);
 		pa = ib_dma_map_page(xprt->sc_cm_id->device,
 				     page, 0, PAGE_SIZE,
 				     DMA_FROM_DEVICE);
+		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
+			goto err_put_ctxt;
+		atomic_inc(&xprt->sc_dma_used);
 		ctxt->sge[sge_no].addr = pa;
 		ctxt->sge[sge_no].length = PAGE_SIZE;
-		ctxt->sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
+		ctxt->sge[sge_no].lkey = xprt->sc_dma_lkey;
 		buflen += PAGE_SIZE;
 	}
 	ctxt->count = sge_no;
@@ -517,6 +519,10 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		svc_rdma_put_context(ctxt, 1);
 	}
 	return ret;
+
+ err_put_ctxt:
+	svc_rdma_put_context(ctxt, 1);
+	return -ENOMEM;
 }
 
 /*
