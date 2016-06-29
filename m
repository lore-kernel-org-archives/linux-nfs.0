Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33315 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbcF2SMc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 14:12:32 -0400
Received: by mail-it0-f68.google.com with SMTP id y93so6182573ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2016 11:12:32 -0700 (PDT)
Subject: [PATCH v4 13/24] xprtrdma: Chunk list encoders must not return zero
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2016 13:53:52 -0400
Message-ID: <20160629175352.15094.15885.stgit@manet.1015granger.net>
In-Reply-To: <20160629173231.15094.52660.stgit@manet.1015granger.net>
References: <20160629173231.15094.52660.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up, based on code audit: Remove the possibility that the
chunk list XDR encoders can return zero, which would be interpreted
as a NULL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    2 ++
 net/sunrpc/xprtrdma/frwr_ops.c |    2 ++
 net/sunrpc/xprtrdma/rpc_rdma.c |    6 +++---
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index aae4c37..bc5f4a1 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -246,6 +246,8 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	}
 	mw->mw_nents = i;
 	mw->mw_dir = rpcrdma_data_dir(writing);
+	if (i == 0)
+		goto out_dmamap_err;
 
 	if (!ib_dma_map_sg(r_xprt->rx_ia.ri_device,
 			   mw->mw_sg, mw->mw_nents, mw->mw_dir))
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index d7613db9..f3a06fa 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -411,6 +411,8 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	}
 	mw->mw_nents = i;
 	mw->mw_dir = rpcrdma_data_dir(writing);
+	if (i == 0)
+		goto out_dmamap_err;
 
 	dma_nents = ib_dma_map_sg(ia->ri_device,
 				  mw->mw_sg, mw->mw_nents, mw->mw_dir);
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 77e002f..8fde0ab 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -329,7 +329,7 @@ rpcrdma_encode_read_list(struct rpcrdma_xprt *r_xprt,
 
 	do {
 		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, false);
-		if (n <= 0)
+		if (n < 0)
 			return ERR_PTR(n);
 
 		*iptr++ = xdr_one;	/* item present */
@@ -397,7 +397,7 @@ rpcrdma_encode_write_list(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	nchunks = 0;
 	do {
 		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, true);
-		if (n <= 0)
+		if (n < 0)
 			return ERR_PTR(n);
 
 		iptr = xdr_encode_rdma_segment(iptr, seg);
@@ -462,7 +462,7 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 	nchunks = 0;
 	do {
 		n = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs, true);
-		if (n <= 0)
+		if (n < 0)
 			return ERR_PTR(n);
 
 		iptr = xdr_encode_rdma_segment(iptr, seg);

