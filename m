Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:55292 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751844AbdJTOsF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:48:05 -0400
Subject: [PATCH 4/9] xprtrdma: "Unoptimize" rpcrdma_prepare_hdr_sge()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:48:03 -0400
Message-ID: <20171020144803.14869.67223.stgit@manet.1015granger.net>
In-Reply-To: <20171020143635.14869.15714.stgit@manet.1015granger.net>
References: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 655fec6987be ("xprtrdma: Use gathered Send for large inline
messages") assumed that, since the zeroeth element of the Send SGE
array always pointed to req->rl_rdmabuf, it needed to be initialized
just once. This was a valid assumption because the Send SGE array
and rl_rdmabuf both live in the same rpcrdma_req.

In a subsequent patch, the Send SGE array will be separated from the
rpcrdma_req, so the zeroeth element of the SGE array needs to be
initialized every time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e3ece98..7fd1029 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -533,7 +533,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 				  sge->addr, sge->length, DMA_TO_DEVICE);
 }
 
-/* Prepare the RPC-over-RDMA header SGE.
+/* Prepare an SGE for the RPC-over-RDMA transport header.
  */
 static bool
 rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
@@ -542,13 +542,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
 	struct ib_sge *sge = &req->rl_send_sge[0];
 
-	if (unlikely(!rpcrdma_regbuf_is_mapped(rb))) {
-		if (!__rpcrdma_dma_map_regbuf(ia, rb))
-			goto out_regbuf;
-		sge->addr = rdmab_addr(rb);
-		sge->lkey = rdmab_lkey(rb);
-	}
+	if (!rpcrdma_dma_map_regbuf(ia, rb))
+		goto out_regbuf;
+	sge->addr = rdmab_addr(rb);
 	sge->length = len;
+	sge->lkey = rdmab_lkey(rb);
 
 	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr,
 				      sge->length, DMA_TO_DEVICE);

