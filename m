Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33123 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967105AbdEWOxt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:53:49 -0400
Subject: [PATCH v1 01/12] xprtrdma: Don't defer MR recovery if ro_map fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:53:46 -0400
Message-ID: <20170523145346.961.93720.stgit@manet.1015granger.net>
In-Reply-To: <20170523142629.961.81233.stgit@manet.1015granger.net>
References: <20170523142629.961.81233.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Deferred MR recovery does a DMA-unmapping of the MW. However, ro_map
invokes rpcrdma_defer_mr_recovery in some error cases where the MW
has not even been DMA-mapped yet.

Avoid a DMA-unmapping error replacing rpcrdma_defer_mr_recovery.

Also note that if ib_dma_map_sg is asked to map 0 nents, it will
return 0. So the extra "if (i == 0)" check is no longer needed.

Fixes: 42fe28f60763 ("xprtrdma: Do not leak an MW during a DMA ...")
Fixes: 505bbe64dd04 ("xprtrdma: Refactor MR recovery work queues")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |   18 +++++++++---------
 net/sunrpc/xprtrdma/frwr_ops.c |   19 ++++++++-----------
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 59e6402..9ee573f 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -213,13 +213,11 @@ enum {
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
-	mw->mw_nents = i;
 	mw->mw_dir = rpcrdma_data_dir(writing);
-	if (i == 0)
-		goto out_dmamap_err;
 
-	if (!ib_dma_map_sg(r_xprt->rx_ia.ri_device,
-			   mw->mw_sg, mw->mw_nents, mw->mw_dir))
+	mw->mw_nents = ib_dma_map_sg(r_xprt->rx_ia.ri_device,
+				     mw->mw_sg, i, mw->mw_dir);
+	if (!mw->mw_nents)
 		goto out_dmamap_err;
 
 	for (i = 0, dma_pages = mw->fmr.fm_physaddrs; i < mw->mw_nents; i++)
@@ -237,16 +235,18 @@ enum {
 	return mw->mw_nents;
 
 out_dmamap_err:
-	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
-	       mw->mw_sg, mw->mw_nents);
-	rpcrdma_defer_mr_recovery(mw);
+	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
+	       mw->mw_sg, i);
+	rpcrdma_put_mw(r_xprt, mw);
 	return -EIO;
 
 out_maperr:
 	pr_err("rpcrdma: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
 	       len, (unsigned long long)dma_pages[0],
 	       pageoff, mw->mw_nents, rc);
-	rpcrdma_defer_mr_recovery(mw);
+	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+			mw->mw_sg, mw->mw_nents, mw->mw_dir);
+	rpcrdma_put_mw(r_xprt, mw);
 	return -EIO;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f81dd93..33ede72 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -355,7 +355,7 @@
 	struct ib_mr *mr;
 	struct ib_reg_wr *reg_wr;
 	struct ib_send_wr *bad_wr;
-	int rc, i, n, dma_nents;
+	int rc, i, n;
 	u8 key;
 
 	mw = NULL;
@@ -391,14 +391,10 @@
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
-	mw->mw_nents = i;
 	mw->mw_dir = rpcrdma_data_dir(writing);
-	if (i == 0)
-		goto out_dmamap_err;
 
-	dma_nents = ib_dma_map_sg(ia->ri_device,
-				  mw->mw_sg, mw->mw_nents, mw->mw_dir);
-	if (!dma_nents)
+	mw->mw_nents = ib_dma_map_sg(ia->ri_device, mw->mw_sg, i, mw->mw_dir);
+	if (!mw->mw_nents)
 		goto out_dmamap_err;
 
 	n = ib_map_mr_sg(mr, mw->mw_sg, mw->mw_nents, NULL, PAGE_SIZE);
@@ -436,13 +432,14 @@
 	return mw->mw_nents;
 
 out_dmamap_err:
-	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
-	       mw->mw_sg, mw->mw_nents);
-	rpcrdma_defer_mr_recovery(mw);
+	pr_err("rpcrdma: failed to DMA map sg %p sg_nents %d\n",
+	       mw->mw_sg, i);
+	frmr->fr_state = FRMR_IS_INVALID;
+	rpcrdma_put_mw(r_xprt, mw);
 	return -EIO;
 
 out_mapmr_err:
-	pr_err("rpcrdma: failed to map mr %p (%u/%u)\n",
+	pr_err("rpcrdma: failed to map mr %p (%d/%d)\n",
 	       frmr->fr_mr, n, mw->mw_nents);
 	rpcrdma_defer_mr_recovery(mw);
 	return -EIO;

