Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:40430 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbbAMQ0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:26:00 -0500
Subject: [PATCH v2 09/20] xprtrdma: Remove rpcrdma_ep::rep_func and
 ::rep_xprt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:25:58 -0500
Message-ID: <20150113162557.14086.75865.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The rep_func field always refers to rpcrdma_conn_func().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +++-
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtrdma/verbs.c     |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 --
 4 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d731010..f2eda15 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -695,7 +695,9 @@ rpcrdma_connect_worker(struct work_struct *work)
 {
 	struct rpcrdma_ep *ep =
 		container_of(work, struct rpcrdma_ep, rep_connect_worker.work);
-	struct rpc_xprt *xprt = ep->rep_xprt;
+	struct rpcrdma_xprt *r_xprt =
+		container_of(ep, struct rpcrdma_xprt, rx_ep);
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (++xprt->connect_cookie == 0)	/* maintain a reserved value */
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ee57513..a487bde 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -376,8 +376,6 @@ xprt_setup_rdma(struct xprt_create *args)
 	 */
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
-	new_ep->rep_func = rpcrdma_conn_func;
-	new_ep->rep_xprt = xprt;
 
 	xprt_rdma_format_addresses(xprt);
 	xprt->max_payload = rpcrdma_max_payload(new_xprt);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 71a071a..c61bb61 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -154,7 +154,7 @@ rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 		event->device->name, context);
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
-		ep->rep_func(ep);
+		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
 	}
 }
@@ -169,7 +169,7 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
 		event->device->name, context);
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
-		ep->rep_func(ep);
+		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
 	}
 }
@@ -474,7 +474,7 @@ connected:
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
 		ep->rep_connected = connstate;
-		ep->rep_func(ep);
+		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
 		/*FALLTHROUGH*/
 	default:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3fcc92b..657c370 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -87,8 +87,6 @@ struct rpcrdma_ep {
 	wait_queue_head_t 	rep_connect_wait;
 	struct ib_sge		rep_pad;	/* holds zeroed pad */
 	struct ib_mr		*rep_pad_mr;	/* holds zeroed pad */
-	void			(*rep_func)(struct rpcrdma_ep *);
-	struct rpc_xprt		*rep_xprt;	/* for rep_func */
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;

