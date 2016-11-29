Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35979 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755045AbcK2Pxb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 10:53:31 -0500
Subject: [PATCH v3 11/12] xprtrdma: Update dprintk in rpcrdma_count_chunks
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 10:53:29 -0500
Message-ID: <20161129155329.23061.92044.stgit@manet.1015granger.net>
In-Reply-To: <20161129154845.23061.29385.stgit@manet.1015granger.net>
References: <20161129154845.23061.29385.stgit@manet.1015granger.net>
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

