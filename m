Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:59675 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbbAUQCj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:02:39 -0500
Subject: [PATCH v3 05/20] xprtrdma: Rename "xprt" and "rdma_connect" fields
 in struct rpcrdma_xprt
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:02:37 -0500
Message-ID: <20150121160237.17297.88251.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use consistent field names in struct rpcrdma_xprt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/transport.c |   19 ++++++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +++---
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index bbd6155..ee57513 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -200,9 +200,9 @@ xprt_rdma_free_addresses(struct rpc_xprt *xprt)
 static void
 xprt_rdma_connect_worker(struct work_struct *work)
 {
-	struct rpcrdma_xprt *r_xprt =
-		container_of(work, struct rpcrdma_xprt, rdma_connect.work);
-	struct rpc_xprt *xprt = &r_xprt->xprt;
+	struct rpcrdma_xprt *r_xprt = container_of(work, struct rpcrdma_xprt,
+						   rx_connect_worker.work);
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	int rc = 0;
 
 	xprt_clear_connected(xprt);
@@ -235,7 +235,7 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
 
 	dprintk("RPC:       %s: called\n", __func__);
 
-	cancel_delayed_work_sync(&r_xprt->rdma_connect);
+	cancel_delayed_work_sync(&r_xprt->rx_connect_worker);
 
 	xprt_clear_connected(xprt);
 
@@ -374,7 +374,8 @@ xprt_setup_rdma(struct xprt_create *args)
 	 * connection loss notification is async. We also catch connection loss
 	 * when reaping receives.
 	 */
-	INIT_DELAYED_WORK(&new_xprt->rdma_connect, xprt_rdma_connect_worker);
+	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
+			  xprt_rdma_connect_worker);
 	new_ep->rep_func = rpcrdma_conn_func;
 	new_ep->rep_xprt = xprt;
 
@@ -434,17 +435,17 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 
 	if (r_xprt->rx_ep.rep_connected != 0) {
 		/* Reconnect */
-		schedule_delayed_work(&r_xprt->rdma_connect,
-			xprt->reestablish_timeout);
+		schedule_delayed_work(&r_xprt->rx_connect_worker,
+				      xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
 		if (xprt->reestablish_timeout > RPCRDMA_MAX_REEST_TO)
 			xprt->reestablish_timeout = RPCRDMA_MAX_REEST_TO;
 		else if (xprt->reestablish_timeout < RPCRDMA_INIT_REEST_TO)
 			xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
 	} else {
-		schedule_delayed_work(&r_xprt->rdma_connect, 0);
+		schedule_delayed_work(&r_xprt->rx_connect_worker, 0);
 		if (!RPC_IS_ASYNC(task))
-			flush_delayed_work(&r_xprt->rdma_connect);
+			flush_delayed_work(&r_xprt->rx_connect_worker);
 	}
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b799041..9a7aab3 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -318,16 +318,16 @@ struct rpcrdma_stats {
  * during unmount.
  */
 struct rpcrdma_xprt {
-	struct rpc_xprt		xprt;
+	struct rpc_xprt		rx_xprt;
 	struct rpcrdma_ia	rx_ia;
 	struct rpcrdma_ep	rx_ep;
 	struct rpcrdma_buffer	rx_buf;
 	struct rpcrdma_create_data_internal rx_data;
-	struct delayed_work	rdma_connect;
+	struct delayed_work	rx_connect_worker;
 	struct rpcrdma_stats	rx_stats;
 };
 
-#define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, xprt)
+#define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, rx_xprt)
 #define rpcx_to_rdmad(x) (rpcx_to_rdmax(x)->rx_data)
 
 /* Setting this to 0 ensures interoperability with early servers.

