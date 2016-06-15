Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33341 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539AbcFODRU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:17:20 -0400
Subject: [PATCH v2 15/24] xprtrdma: Release orphaned MRs immediately
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:17:18 -0400
Message-ID: <20160615031718.14794.26381.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of leaving orphaned MRs to be released when the transport
is destroyed, release them immediately. The MR free list can now be
replenished if it becomes exhausted.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |   19 +++++++++++++------
 net/sunrpc/xprtrdma/frwr_ops.c |   19 +++++++++++++------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 840479f..2ad117f 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -124,15 +124,22 @@ fmr_op_recover_mr(struct rpcrdma_mw *mw)
 	/* ORDER: then DMA unmap */
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mw->mw_sg, mw->mw_nents, mw->mw_dir);
-	if (rc) {
-		pr_err("rpcrdma: FMR reset status %d, %p orphaned\n",
-		       rc, mw);
-		r_xprt->rx_stats.mrs_orphaned++;
-		return;
-	}
+	if (rc)
+		goto out_release;
 
 	rpcrdma_put_mw(r_xprt, mw);
 	r_xprt->rx_stats.mrs_recovered++;
+	return;
+
+out_release:
+	pr_err("rpcrdma: FMR reset failed (%d), %p released\n", rc, mw);
+	r_xprt->rx_stats.mrs_orphaned++;
+
+	spin_lock(&r_xprt->rx_buf.rb_mwlock);
+	list_del(&mw->mw_all);
+	spin_unlock(&r_xprt->rx_buf.rb_mwlock);
+
+	fmr_op_release_mr(mw);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f603c3a..38de90c 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -160,15 +160,22 @@ frwr_op_recover_mr(struct rpcrdma_mw *mw)
 
 	rc = __frwr_reset_mr(ia, mw);
 	ib_dma_unmap_sg(ia->ri_device, mw->mw_sg, mw->mw_nents, mw->mw_dir);
-	if (rc) {
-		pr_err("rpcrdma: FRMR reset status %d, %p orphaned\n",
-		       rc, mw);
-		r_xprt->rx_stats.mrs_orphaned++;
-		return;
-	}
+	if (rc)
+		goto out_release;
 
 	rpcrdma_put_mw(r_xprt, mw);
 	r_xprt->rx_stats.mrs_recovered++;
+	return;
+
+out_release:
+	pr_err("rpcrdma: FRMR reset failed %d, %p release\n", rc, mw);
+	r_xprt->rx_stats.mrs_orphaned++;
+
+	spin_lock(&r_xprt->rx_buf.rb_mwlock);
+	list_del(&mw->mw_all);
+	spin_unlock(&r_xprt->rx_buf.rb_mwlock);
+
+	frwr_op_release_mr(mw);
 }
 
 static int

