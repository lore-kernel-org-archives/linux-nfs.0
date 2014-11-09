Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:51220 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKIBOz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:14:55 -0500
Subject: [PATCH v2 06/10] xprtrdma: Enable pad optimization
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:14:53 -0500
Message-ID: <20141109011453.8806.31817.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux NFS/RDMA server used to reject NFSv3 WRITE requests when
pad optimization was enabled. That bug was fixed by commit
e560e3b510d2 ("svcrdma: Add zero padding if the client doesn't send
it").

We can now enable pad optimization on the client, which helps
performance and is supported now by both Linux and Solaris servers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index cfe9a81..8ed2576 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -73,7 +73,7 @@ static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
-                int xprt_rdma_pad_optimize = 0;
+		int xprt_rdma_pad_optimize = 1;
 
 #ifdef RPC_DEBUG
 

