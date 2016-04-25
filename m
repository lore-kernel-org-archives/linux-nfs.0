Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34908 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933240AbcDYTWx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 15:22:53 -0400
Subject: [PATCH v2 15/18] xprtrdma: Refactor __fmr_dma_unmap()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 15:22:51 -0400
Message-ID: <20160425192251.3566.35007.stgit@manet.1015granger.net>
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate the DMA unmap operation from freeing the MW. In a
subsequent patch they will not always be done at the same time,
and they are not related operations (except by order; freeing
the MW must be the last step during invalidation).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 009694b..9d50f3a 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -186,15 +186,10 @@ static void
 __fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	struct rpcrdma_mw *mw = seg->rl_mw;
 	int nsegs = seg->mr_nsegs;
 
-	seg->rl_mw = NULL;
-
 	while (nsegs--)
 		rpcrdma_unmap_one(device, seg++);
-
-	rpcrdma_put_mw(r_xprt, mw);
 }
 
 /* Invalidate all memory regions that were registered for "req".
@@ -237,9 +232,11 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 
 		__fmr_dma_unmap(r_xprt, seg);
+		rpcrdma_put_mw(r_xprt, seg->rl_mw);
 
 		i += seg->mr_nsegs;
 		seg->mr_nsegs = 0;
+		seg->rl_mw = NULL;
 	}
 
 	req->rl_nchunks = 0;

