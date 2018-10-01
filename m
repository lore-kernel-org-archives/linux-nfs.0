Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:38061 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726351AbeJBBFO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:14 -0400
Subject: [PATCH v2 12/20] xprtrdma: Simplify RPC wake-ups on connect
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:08 -0400
Message-ID: <20181001182608.18578.38615.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when a connection is established, rpcrdma_conn_upcall
invokes rpcrdma_conn_func and then
wake_up_all(&ep->rep_connect_wait). The former wakes waiting RPCs,
but the connect worker is not done yet, and that leads to races,
double wakes, and difficulty understanding how this logic is
supposed to work.

Instead, collect all the "connection established" logic in the
connect worker (xprt_rdma_connect_worker). A disconnect worker is
retained to handle provider upcalls safely.

Fixes: 254f91e2fa1f ("xprtrdma: RPC/RDMA must invoke ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   54 +++++++++++++--------------------------
 net/sunrpc/xprtrdma/verbs.c     |   42 ++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 +--
 3 files changed, 52 insertions(+), 48 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 289d13c..d7c4255 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -225,51 +225,35 @@
 		}
 }
 
-void
-rpcrdma_conn_func(struct rpcrdma_ep *ep)
-{
-	schedule_delayed_work(&ep->rep_connect_worker, 0);
-}
-
-void
-rpcrdma_connect_worker(struct work_struct *work)
+/**
+ * xprt_rdma_connect_worker - establish connection in the background
+ * @work: worker thread context
+ *
+ * Requester holds the xprt's send lock to prevent activity on this
+ * transport while a fresh connection is being established. RPC tasks
+ * sleep on the xprt's pending queue waiting for connect to complete.
+ */
+static void
+xprt_rdma_connect_worker(struct work_struct *work)
 {
-	struct rpcrdma_ep *ep =
-		container_of(work, struct rpcrdma_ep, rep_connect_worker.work);
-	struct rpcrdma_xprt *r_xprt =
-		container_of(ep, struct rpcrdma_xprt, rx_ep);
+	struct rpcrdma_xprt *r_xprt = container_of(work, struct rpcrdma_xprt,
+						   rx_connect_worker.work);
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	int rc;
 
-	spin_lock_bh(&xprt->transport_lock);
-	if (ep->rep_connected > 0) {
+	rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	xprt_clear_connecting(xprt);
+	if (r_xprt->rx_ep.rep_connected > 0) {
 		if (!xprt_test_and_set_connected(xprt)) {
 			xprt->stat.connect_count++;
 			xprt->stat.connect_time += (long)jiffies -
 						   xprt->stat.connect_start;
-			xprt_wake_pending_tasks(xprt, 0);
+			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
 	} else {
 		if (xprt_test_and_clear_connected(xprt))
-			xprt_wake_pending_tasks(xprt, -ENOTCONN);
+			xprt_wake_pending_tasks(xprt, rc);
 	}
-	spin_unlock_bh(&xprt->transport_lock);
-}
-
-static void
-xprt_rdma_connect_worker(struct work_struct *work)
-{
-	struct rpcrdma_xprt *r_xprt = container_of(work, struct rpcrdma_xprt,
-						   rx_connect_worker.work);
-	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
-	int rc = 0;
-
-	xprt_clear_connected(xprt);
-
-	rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
-	if (rc)
-		xprt_wake_pending_tasks(xprt, rc);
-
-	xprt_clear_connecting(xprt);
 }
 
 static void
@@ -302,8 +286,6 @@
 
 	cancel_delayed_work_sync(&r_xprt->rx_connect_worker);
 
-	xprt_clear_connected(xprt);
-
 	rpcrdma_ep_destroy(&r_xprt->rx_ep, &r_xprt->rx_ia);
 	rpcrdma_buffer_destroy(&r_xprt->rx_buf);
 	rpcrdma_ia_close(&r_xprt->rx_ia);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c60172f..abbd3cd 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -108,6 +108,25 @@
 	}
 }
 
+/**
+ * rpcrdma_disconnect_worker - Force a disconnect
+ * @work: endpoint to be disconnected
+ *
+ * Provider callbacks can possibly run in an IRQ context. This function
+ * is invoked in a worker thread to guarantee that disconnect wake-up
+ * calls are always done in process context.
+ */
+static void
+rpcrdma_disconnect_worker(struct work_struct *work)
+{
+	struct rpcrdma_ep *ep = container_of(work, struct rpcrdma_ep,
+					     rep_disconnect_worker.work);
+	struct rpcrdma_xprt *r_xprt =
+		container_of(ep, struct rpcrdma_xprt, rx_ep);
+
+	xprt_force_disconnect(&r_xprt->rx_xprt);
+}
+
 static void
 rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
@@ -121,7 +140,7 @@
 
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
-		rpcrdma_conn_func(ep);
+		schedule_delayed_work(&ep->rep_disconnect_worker, 0);
 		wake_up_all(&ep->rep_connect_wait);
 	}
 }
@@ -271,13 +290,14 @@
 		++xprt->connect_cookie;
 		ep->rep_connected = 1;
 		rpcrdma_update_connect_private(r_xprt, &event->param.conn);
-		goto connected;
+		wake_up_all(&ep->rep_connect_wait);
+		break;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
 		ep->rep_connected = -ENOTCONN;
-		goto connected;
+		goto disconnected;
 	case RDMA_CM_EVENT_UNREACHABLE:
 		ep->rep_connected = -ENETUNREACH;
-		goto connected;
+		goto disconnected;
 	case RDMA_CM_EVENT_REJECTED:
 		dprintk("rpcrdma: connection to %s:%s rejected: %s\n",
 			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
@@ -285,12 +305,12 @@
 		ep->rep_connected = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
 			ep->rep_connected = -EAGAIN;
-		goto connected;
+		goto disconnected;
 	case RDMA_CM_EVENT_DISCONNECTED:
 		++xprt->connect_cookie;
 		ep->rep_connected = -ECONNABORTED;
-connected:
-		rpcrdma_conn_func(ep);
+disconnected:
+		xprt_force_disconnect(xprt);
 		wake_up_all(&ep->rep_connect_wait);
 		break;
 	default:
@@ -550,7 +570,8 @@
 				   cdata->max_requests >> 2);
 	ep->rep_send_count = ep->rep_send_batch;
 	init_waitqueue_head(&ep->rep_connect_wait);
-	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
+	INIT_DELAYED_WORK(&ep->rep_disconnect_worker,
+			  rpcrdma_disconnect_worker);
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
@@ -623,7 +644,7 @@
 void
 rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	cancel_delayed_work_sync(&ep->rep_connect_worker);
+	cancel_delayed_work_sync(&ep->rep_disconnect_worker);
 
 	if (ia->ri_id && ia->ri_id->qp) {
 		rpcrdma_ep_disconnect(ep, ia);
@@ -736,6 +757,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = container_of(ia, struct rpcrdma_xprt,
 						   rx_ia);
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	int rc;
 
 retry:
@@ -762,6 +784,8 @@
 	}
 
 	ep->rep_connected = 0;
+	xprt_clear_connected(xprt);
+
 	rpcrdma_post_recvs(r_xprt, true);
 
 	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index eae2166..a13ccb6 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -101,7 +101,7 @@ struct rpcrdma_ep {
 	wait_queue_head_t 	rep_connect_wait;
 	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
-	struct delayed_work	rep_connect_worker;
+	struct delayed_work	rep_disconnect_worker;
 };
 
 /* Pre-allocate extra Work Requests for handling backward receives
@@ -556,7 +556,6 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 				struct rpcrdma_create_data_internal *);
 void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
-void rpcrdma_conn_func(struct rpcrdma_ep *ep);
 void rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
@@ -654,7 +653,6 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 extern unsigned int xprt_rdma_max_inline_read;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
-void rpcrdma_connect_worker(struct work_struct *work);
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);
