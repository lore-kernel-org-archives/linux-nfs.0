Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:35923 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbcEBSmX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:42:23 -0400
Subject: [PATCH v3 15/20] xprtrdma: Refactor the FRWR recovery worker
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:42:21 -0400
Message-ID: <20160502184221.10798.36610.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maintain the order of invalidation and DMA unmapping when doing
a background MR reset.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index ce245dc..4e0a5c1 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -124,6 +124,21 @@ __frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 	return 0;
 }
 
+static void
+__frwr_reset_and_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_frmr *f = &mw->frmr;
+	int rc;
+
+	rc = __frwr_reset_mr(ia, mw);
+	ib_dma_unmap_sg(ia->ri_device, f->fr_sg, f->fr_nents, f->fr_dir);
+	if (rc)
+		return;
+
+	rpcrdma_put_mw(r_xprt, mw);
+}
+
 /* Deferred reset of a single FRMR. Generate a fresh rkey by
  * replacing the MR.
  *
@@ -136,15 +151,8 @@ __frwr_recovery_worker(struct work_struct *work)
 {
 	struct rpcrdma_mw *r = container_of(work, struct rpcrdma_mw,
 					    frmr.fr_work);
-	struct rpcrdma_xprt *r_xprt = r->frmr.fr_xprt;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	int rc;
-
-	rc = __frwr_reset_mr(ia, r);
-	if (rc)
-		return;
 
-	rpcrdma_put_mw(r_xprt, r);
+	__frwr_reset_and_unmap(r->frmr.fr_xprt, r);
 	return;
 }
 
@@ -483,7 +491,6 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 
 out_senderr:
 	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
-	ib_dma_unmap_sg(device, frmr->fr_sg, dma_nents, direction);
 	__frwr_queue_recovery(mw);
 	return rc;
 }

