Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:38023 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbaGVOxq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:53:46 -0400
Subject: [PATCH v4 19/21] xprtrdma: Make rpcrdma_ep_disconnect() return void
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:53:44 -0400
Message-ID: <20140722145344.6010.33311.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The return code is used only for dprintk's that are
already redundant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |   14 ++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index f6d280b..2faac49 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -414,7 +414,7 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	if (r_xprt->rx_ep.rep_connected > 0)
 		xprt->reestablish_timeout = 0;
 	xprt_disconnect_done(xprt);
-	(void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3563467..e62b1fe 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -830,10 +830,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	cancel_delayed_work_sync(&ep->rep_connect_worker);
 
 	if (ia->ri_id->qp) {
-		rc = rpcrdma_ep_disconnect(ep, ia);
-		if (rc)
-			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
-				" returned %i\n", __func__, rc);
+		rpcrdma_ep_disconnect(ep, ia);
 		rdma_destroy_qp(ia->ri_id);
 		ia->ri_id->qp = NULL;
 	}
@@ -871,10 +868,8 @@ rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		struct rpcrdma_xprt *xprt;
 retry:
 		dprintk("RPC:       %s: reconnecting...\n", __func__);
-		rc = rpcrdma_ep_disconnect(ep, ia);
-		if (rc && rc != -ENOTCONN)
-			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
-				" status %i\n", __func__, rc);
+
+		rpcrdma_ep_disconnect(ep, ia);
 		rpcrdma_flush_cqs(ep);
 
 		if (ia->ri_memreg_strategy == RPCRDMA_FRMR)
@@ -984,7 +979,7 @@ out:
  * This call is not reentrant, and must not be made in parallel
  * on the same endpoint.
  */
-int
+void
 rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
 	int rc;
@@ -1001,7 +996,6 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		dprintk("RPC:       %s: rdma_disconnect %i\n", __func__, rc);
 		ep->rep_connected = rc;
 	}
-	return rc;
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 1ee6db3..c419498 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -341,7 +341,7 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 				struct rpcrdma_create_data_internal *);
 void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
-int rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
+void rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 				struct rpcrdma_req *);

