Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36641 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753173AbcKRPA1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:00:27 -0500
Subject: [PATCH v2 11/12] xprtrdma: Update dprintk in rpcrdma_count_chunks
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:00:25 -0500
Message-ID: <20161118150025.10592.50789.stgit@manet.1015granger.net>
In-Reply-To: <20161118145547.10592.66470.stgit@manet.1015granger.net>
References: <20161118145547.10592.66470.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: offset and handle should be zero-filled, just like in the
chunk encoders.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d987c2d..01f5cbc 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -786,7 +786,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		ifdebug(FACILITY) {
 			u64 off;
 			xdr_decode_hyper((__be32 *)&seg->rs_offset, &off);
-			dprintk("RPC:       %s: chunk %d@0x%llx:0x%x\n",
+			dprintk("RPC:       %s: chunk %d@0x%016llx:0x%08x\n",
 				__func__,
 				be32_to_cpu(seg->rs_length),
 				(unsigned long long)off,

