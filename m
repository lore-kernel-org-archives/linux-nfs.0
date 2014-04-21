Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f41.google.com ([209.85.213.41]:59911 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbaDUWCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 18:02:34 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V2 12/17] xprtrdma: Make rpcrdma_ep_destroy() return void
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Apr 2014 18:02:32 -0400
Message-ID: <20140421220232.12569.35964.stgit@manet.1015granger.net>
In-Reply-To: <20140421214442.12569.8950.stgit@manet.1015granger.net>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rpcrdma_ep_destroy() returns a value that is used
only to print a debugging message. rpcrdma_ep_destroy() already
prints debugging messages in all error cases.

Make rpcrdma_ep_destroy() return void instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/transport.c |    8 ++------
 net/sunrpc/xprtrdma/verbs.c     |    7 +------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6a47193..44004eb 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -229,7 +229,6 @@ static void
 xprt_rdma_destroy(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	int rc;
 
 	dprintk("RPC:       %s: called\n", __func__);
 
@@ -238,10 +237,7 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
 	xprt_clear_connected(xprt);
 
 	rpcrdma_buffer_destroy(&r_xprt->rx_buf);
-	rc = rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
-	if (rc)
-		dprintk("RPC:       %s: rpcrdma_ep_destroy returned %i\n",
-			__func__, rc);
+	rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
 	rpcrdma_ia_close(&r_xprt->rx_ia);
 
 	xprt_rdma_free_addresses(xprt);
@@ -391,7 +387,7 @@ out4:
 	xprt_rdma_free_addresses(xprt);
 	rc = -EINVAL;
 out3:
-	(void) rpcrdma_ep_destroy(new_ep, &new_xprt->rx_ia);
+	rpcrdma_ep_destroy(new_ep, &new_xprt->rx_ia);
 out2:
 	rpcrdma_ia_close(&new_xprt->rx_ia);
 out1:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7a8a1bf..a60bf15 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -748,11 +748,8 @@ out1:
  * Disconnect and destroy endpoint. After this, the only
  * valid operations on the ep are to free it (if dynamically
  * allocated) or re-create it.
- *
- * The caller's error handling must be sure to not leak the endpoint
- * if this function fails.
  */
-int
+void
 rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
 	int rc;
@@ -782,8 +779,6 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	if (rc)
 		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
 			__func__, rc);
-
-	return rc;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3f44d6a..362a19d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -301,7 +301,7 @@ void rpcrdma_ia_close(struct rpcrdma_ia *);
  */
 int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 				struct rpcrdma_create_data_internal *);
-int rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
+void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 int rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 

