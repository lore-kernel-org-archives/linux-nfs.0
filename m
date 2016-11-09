Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35792 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752325AbcKITGM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:06:12 -0500
Subject: [PATCH v1 10/14] xprtrdma: Update dprintk in rpcrdma_count_chunks
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:06:11 -0500
Message-ID: <20161109190610.15007.32365.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
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

