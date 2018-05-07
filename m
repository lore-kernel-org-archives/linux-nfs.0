Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35089 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbeEGT1z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:55 -0400
Subject: [PATCH v1 12/19] svcrdma: Refactor svc_rdma_dma_map_buf
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:53 -0400
Message-ID: <20180507192753.4608.12841.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: svc_rdma_dma_map_buf does mostly the same thing as
svc_rdma_dma_map_page, so let's fold these together.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h       |    7 -----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   50 +++++++++++----------------------
 2 files changed, 17 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 27cf59c..95530bc 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -158,13 +158,6 @@ struct svc_rdma_recv_ctxt {
 	struct page		*rc_pages[RPCSVC_MAXPAGES];
 };
 
-/* Track DMA maps for this transport and context */
-static inline void svc_rdma_count_mappings(struct svcxprt_rdma *rdma,
-					   struct svc_rdma_op_ctxt *ctxt)
-{
-	ctxt->mapped_sges++;
-}
-
 /* svc_rdma_backchannel.c */
 extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 				    __be32 *rdma_resp,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index b27b597..ee9ba07 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -302,41 +302,11 @@ static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
 	return be32_to_cpup(p);
 }
 
-/* ib_dma_map_page() is used here because svc_rdma_dma_unmap()
- * is used during completion to DMA-unmap this memory, and
- * it uses ib_dma_unmap_page() exclusively.
- */
-static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
-				struct svc_rdma_op_ctxt *ctxt,
-				unsigned int sge_no,
-				unsigned char *base,
-				unsigned int len)
-{
-	unsigned long offset = (unsigned long)base & ~PAGE_MASK;
-	struct ib_device *dev = rdma->sc_cm_id->device;
-	dma_addr_t dma_addr;
-
-	dma_addr = ib_dma_map_page(dev, virt_to_page(base),
-				   offset, len, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(dev, dma_addr))
-		goto out_maperr;
-
-	ctxt->sge[sge_no].addr = dma_addr;
-	ctxt->sge[sge_no].length = len;
-	ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
-	svc_rdma_count_mappings(rdma, ctxt);
-	return 0;
-
-out_maperr:
-	pr_err("svcrdma: failed to map buffer\n");
-	return -EIO;
-}
-
 static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 				 struct svc_rdma_op_ctxt *ctxt,
 				 unsigned int sge_no,
 				 struct page *page,
-				 unsigned int offset,
+				 unsigned long offset,
 				 unsigned int len)
 {
 	struct ib_device *dev = rdma->sc_cm_id->device;
@@ -349,7 +319,7 @@ static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 	ctxt->sge[sge_no].addr = dma_addr;
 	ctxt->sge[sge_no].length = len;
 	ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
-	svc_rdma_count_mappings(rdma, ctxt);
+	ctxt->mapped_sges++;
 	return 0;
 
 out_maperr:
@@ -357,6 +327,19 @@ static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 	return -EIO;
 }
 
+/* ib_dma_map_page() is used here because svc_rdma_dma_unmap()
+ * handles DMA-unmap and it uses ib_dma_unmap_page() exclusively.
+ */
+static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
+				struct svc_rdma_op_ctxt *ctxt,
+				unsigned int sge_no,
+				unsigned char *base,
+				unsigned int len)
+{
+	return svc_rdma_dma_map_page(rdma, ctxt, sge_no, virt_to_page(base),
+				     offset_in_page(base), len);
+}
+
 /**
  * svc_rdma_map_reply_hdr - DMA map the transport header buffer
  * @rdma: controlling transport
@@ -389,7 +372,8 @@ static int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_op_ctxt *ctxt,
 				  struct xdr_buf *xdr, __be32 *wr_lst)
 {
-	unsigned int len, sge_no, remaining, page_off;
+	unsigned int len, sge_no, remaining;
+	unsigned long page_off;
 	struct page **ppages;
 	unsigned char *base;
 	u32 xdr_pad;

