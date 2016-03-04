Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36492 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760177AbcCDQ1q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 11:27:46 -0500
Subject: [PATCH v3 03/11] xprtrdma: Clean up dprintk format string
 containing a newline
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 Mar 2016 11:27:43 -0500
Message-ID: <20160304162743.13590.23268.stgit@oracle120-ib.cthon.org>
In-Reply-To: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
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

