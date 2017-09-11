Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32772 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdIKPPm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Sep 2017 11:15:42 -0400
Subject: [PATCH v1 1/7] xprtrdma: Clean up SGE accounting in
 rpcrdma_prepare_msg_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Sep 2017 11:17:33 -0400
Message-ID: <150514304843.1307.4296160808115155073.stgit@lebasque.1015granger.net>
In-Reply-To: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
References: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_prepare_hdr_sges() sets num_sge to one, then
rpcrdma_prepare_msg_sges() sets num_sge again to the count of SGEs
it added, plus one for the header SGE just mapped in
rpcrdma_prepare_hdr_sges().

Instead, maintain a running count that both functions can update as
needed. Also, simplify mapped SGE counting by just setting the count
of SGEs in the tail of rpcrdma_prepare_msg_sges(), which is the
only function that sets that field to a non-zero value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 84584ca..bc464b1 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -607,7 +607,6 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			sge[sge_no].length = len;
 			sge[sge_no].lkey = lkey;
 
-			req->rl_mapped_sges++;
 			ppages++;
 			remaining -= len;
 			page_base = 0;
@@ -633,11 +632,11 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			goto out_mapping_err;
 		sge[sge_no].length = len;
 		sge[sge_no].lkey = lkey;
-		req->rl_mapped_sges++;
 	}
 
 out:
-	req->rl_send_wr.num_sge = sge_no + 1;
+	req->rl_send_wr.num_sge += sge_no;
+	req->rl_mapped_sges = sge_no - 1;
 	return true;
 
 out_mapping_overflow:
@@ -655,7 +654,6 @@ rpcrdma_prepare_send_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 			  enum rpcrdma_chunktype rtype)
 {
 	req->rl_send_wr.num_sge = 0;
-	req->rl_mapped_sges = 0;
 
 	if (!rpcrdma_prepare_hdr_sge(ia, req, hdrlen))
 		goto out_map;
@@ -682,7 +680,6 @@ rpcrdma_unmap_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 	for (count = req->rl_mapped_sges; count--; sge++)
 		ib_dma_unmap_page(device, sge->addr, sge->length,
 				  DMA_TO_DEVICE);
-	req->rl_mapped_sges = 0;
 }
 
 /**

