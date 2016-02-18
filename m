Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35544 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946429AbcBRRa3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:30:29 -0500
Subject: [PATCH v2 04/12] xprtrdma: Clean up dprintk format string
 containing a newline
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:30:27 -0500
Message-ID: <20160218173027.14009.26305.stgit@manet.1015granger.net>
In-Reply-To: <20160218172449.14009.47311.stgit@manet.1015granger.net>
References: <20160218172449.14009.47311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 0f28f2d..e9dfd6a 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -809,10 +809,8 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	 */
 	list_del_init(&rqst->rq_list);
 	spin_unlock_bh(&xprt->transport_lock);
-	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
-		"                   RPC request 0x%p xid 0x%08x\n",
-			__func__, rep, req, rqst,
-			be32_to_cpu(headerp->rm_xid));
+	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
+		__func__, rep, req, be32_to_cpu(headerp->rm_xid));
 
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;

