Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:54306 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUFU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:05:20 -0400
Subject: [PATCH v1 21/22] xprtrdma: Clean up xprt_rdma_disconnect_inject
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:46 -0400
Message-ID: <20180910151046.10564.27607.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use the appropriate C macro instead of open-coding
container_of() .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 67eb900..afc8fad 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -266,8 +266,7 @@
 static void
 xprt_rdma_inject_disconnect(struct rpc_xprt *xprt)
 {
-	struct rpcrdma_xprt *r_xprt = container_of(xprt, struct rpcrdma_xprt,
-						   rx_xprt);
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
 	trace_xprtrdma_inject_dsc(r_xprt);
 	rdma_disconnect(r_xprt->rx_ia.ri_id);
