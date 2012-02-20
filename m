Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41263 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574Ab2BTTHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 14:07:42 -0500
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH] xprtrdma: The transport should not bug-check when a dup reply
	is received
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Mon, 20 Feb 2012 13:07:42 -0600
Message-ID: <20120220190742.7986.54225.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client side RDMA transport will bug check if it receives a duplicate
reply, instead we should simply drop the duplicate reply.

Signed-off-by: Tom Tucker <tom@ogc.us>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 554d081..12de982 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -771,13 +771,18 @@ repost:
 
 	/* get request object */
 	req = rpcr_to_rdmar(rqst);
+	if (req->rl_reply) {
+		spin_unlock(&xprt->transport_lock);
+		dprintk("RPC:       %s: duplicate reply 0x%p to RPC "
+			"request 0x%p: xid 0x%08x\n", __func__, rep, req,
+			headerp->rm_xid);
+		goto repost;
+	}
 
 	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
 		"                   RPC request 0x%p xid 0x%08x\n",
 			__func__, rep, req, rqst, headerp->rm_xid);
 
-	BUG_ON(!req || req->rl_reply);
-
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;
 

