Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35958 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754178AbdFWVTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:19:31 -0400
Subject: [PATCH v3 18/18] svcrdma: Remove svc_rdma_chunk_ctxt::cc_dir field
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 23 Jun 2017 17:19:29 -0400
Message-ID: <20170623211929.5162.23620.stgit@klimt.1015granger.net>
In-Reply-To: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: No need to save the I/O direction. The functions that
release svc_rdma_chunk_ctxt already know what direction to use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 9859736..933f79b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -116,22 +116,20 @@ struct svc_rdma_chunk_ctxt {
 	struct svcxprt_rdma	*cc_rdma;
 	struct list_head	cc_rwctxts;
 	int			cc_sqecount;
-	enum dma_data_direction cc_dir;
 };
 
 static void svc_rdma_cc_init(struct svcxprt_rdma *rdma,
-			     struct svc_rdma_chunk_ctxt *cc,
-			     enum dma_data_direction dir)
+			     struct svc_rdma_chunk_ctxt *cc)
 {
 	cc->cc_rdma = rdma;
 	svc_xprt_get(&rdma->sc_xprt);
 
 	INIT_LIST_HEAD(&cc->cc_rwctxts);
 	cc->cc_sqecount = 0;
-	cc->cc_dir = dir;
 }
 
-static void svc_rdma_cc_release(struct svc_rdma_chunk_ctxt *cc)
+static void svc_rdma_cc_release(struct svc_rdma_chunk_ctxt *cc,
+				enum dma_data_direction dir)
 {
 	struct svcxprt_rdma *rdma = cc->cc_rdma;
 	struct svc_rdma_rw_ctxt *ctxt;
@@ -141,7 +139,7 @@ static void svc_rdma_cc_release(struct svc_rdma_chunk_ctxt *cc)
 
 		rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp,
 				    rdma->sc_port_num, ctxt->rw_sg_table.sgl,
-				    ctxt->rw_nents, cc->cc_dir);
+				    ctxt->rw_nents, dir);
 		svc_rdma_put_rw_ctxt(rdma, ctxt);
 	}
 	svc_xprt_put(&rdma->sc_xprt);
@@ -179,14 +177,14 @@ struct svc_rdma_write_info {
 	info->wi_seg_no = 0;
 	info->wi_nsegs = be32_to_cpup(++chunk);
 	info->wi_segs = ++chunk;
-	svc_rdma_cc_init(rdma, &info->wi_cc, DMA_TO_DEVICE);
+	svc_rdma_cc_init(rdma, &info->wi_cc);
 	info->wi_cc.cc_cqe.done = svc_rdma_write_done;
 	return info;
 }
 
 static void svc_rdma_write_info_free(struct svc_rdma_write_info *info)
 {
-	svc_rdma_cc_release(&info->wi_cc);
+	svc_rdma_cc_release(&info->wi_cc, DMA_TO_DEVICE);
 	kfree(info);
 }
 
@@ -241,14 +239,14 @@ struct svc_rdma_read_info {
 	if (!info)
 		return info;
 
-	svc_rdma_cc_init(rdma, &info->ri_cc, DMA_FROM_DEVICE);
+	svc_rdma_cc_init(rdma, &info->ri_cc);
 	info->ri_cc.cc_cqe.done = svc_rdma_wc_read_done;
 	return info;
 }
 
 static void svc_rdma_read_info_free(struct svc_rdma_read_info *info)
 {
-	svc_rdma_cc_release(&info->ri_cc);
+	svc_rdma_cc_release(&info->ri_cc, DMA_FROM_DEVICE);
 	kfree(info);
 }
 

