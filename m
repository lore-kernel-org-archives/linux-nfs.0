Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34374 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcF2RxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 13:53:04 -0400
Subject: [PATCH v4 07/24] xprtrdma: Do not leak an MW during a DMA map
 failure
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2016 13:53:02 -0400
Message-ID: <20160629175302.15094.25978.stgit@manet.1015granger.net>
In-Reply-To: <20160629173231.15094.52660.stgit@manet.1015granger.net>
References: <20160629173231.15094.52660.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Based on code audit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    1 +
 net/sunrpc/xprtrdma/frwr_ops.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 4837ced..6c4527b 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -257,6 +257,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
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

