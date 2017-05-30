Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36807 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdE3SOU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 14:14:20 -0400
Subject: [PATCH v1 02/17] svcrdma: Squelch disconnection messages
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 30 May 2017 14:14:18 -0400
Message-ID: <20170530181418.2992.1551.stgit@klimt.1015granger.net>
In-Reply-To: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
References: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server displays "svcrdma: failed to post Send WR (-107)" in the
kernel log when the client disconnects. This could flood the server's
log, so remove the message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 1736337..5ba6d91 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -313,13 +313,17 @@ static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
 	dma_addr = ib_dma_map_page(dev, virt_to_page(base),
 				   offset, len, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(dev, dma_addr))
-		return -EIO;
+		goto out_maperr;
 
 	ctxt->sge[sge_no].addr = dma_addr;
 	ctxt->sge[sge_no].length = len;
 	ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
 	svc_rdma_count_mappings(rdma, ctxt);
 	return 0;
+
+out_maperr:
+	pr_err("svcrdma: failed to map buffer\n");
+	return -EIO;
 }
 
 static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
@@ -334,13 +338,17 @@ static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 
 	dma_addr = ib_dma_map_page(dev, page, offset, len, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(dev, dma_addr))
-		return -EIO;
+		goto out_maperr;
 
 	ctxt->sge[sge_no].addr = dma_addr;
 	ctxt->sge[sge_no].length = len;
 	ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
 	svc_rdma_count_mappings(rdma, ctxt);
 	return 0;
+
+out_maperr:
+	pr_err("svcrdma: failed to map page\n");
+	return -EIO;
 }
 
 /**
@@ -547,7 +555,6 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 	return 0;
 
 err:
-	pr_err("svcrdma: failed to post Send WR (%d)\n", ret);
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
 	return ret;

