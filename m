Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35153 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbcFODQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:16:24 -0400
Subject: [PATCH v2 08/24] xprtrdma: Do not leak an MW during a DMA map
 failure
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:16:22 -0400
Message-ID: <20160615031622.14794.49525.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Based on code audit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    1 +
 net/sunrpc/xprtrdma/frwr_ops.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 43bfb5d..eb42d7f 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -258,6 +258,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 out_dmamap_err:
 	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
 	       mw->mw_sg, mw->mw_nents);
+	rpcrdma_defer_mr_recovery(mw);
 	return -ENOMEM;
 
 out_maperr:
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index cbb2d05..c9ead2b 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -438,6 +438,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 out_dmamap_err:
 	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
 	       mw->mw_sg, mw->mw_nents);
+	rpcrdma_defer_mr_recovery(mw);
 	return -ENOMEM;
 
 out_mapmr_err:

