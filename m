Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38988 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756589AbdLTVbb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:31 -0500
Subject: [PATCH v1 09/12] xprtrdma: Add trace points for connect events
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:29 -0500
Message-ID: <20171220213129.29321.8071.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |   75 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c |   12 ++----
 net/sunrpc/xprtrdma/verbs.c     |   33 +++++++----------
 3 files changed, 92 insertions(+), 28 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index d4dad18..79cc487 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -267,6 +267,81 @@
 				TP_ARGS(mr))
 
 /**
+ ** Connection events
+ **/
+
+TRACE_EVENT(xprtrdma_conn_upcall,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		struct rdma_cm_event *event
+	),
+
+	TP_ARGS(r_xprt, event),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(unsigned int, event)
+		__field(int, status)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->event = event->event;
+		__entry->status = event->status;
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p: %s (%u/%d)",
+		__get_str(addr), __get_str(port),
+		__entry->r_xprt, rdma_show_cm_event(__entry->event),
+		__entry->event, __entry->status
+	)
+);
+
+TRACE_EVENT(xprtrdma_disconnect,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		int status
+	),
+
+	TP_ARGS(r_xprt, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(int, status)
+		__field(int, connected)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->status = status;
+		__entry->connected = r_xprt->rx_ep.rep_connected;
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p: status=%d %sconnected",
+		__get_str(addr), __get_str(port),
+		__entry->r_xprt, __entry->status,
+		__entry->connected == 1 ? "still " : "dis"
+	)
+);
+
+DEFINE_RXPRT_EVENT(xprtrdma_conn_start);
+DEFINE_RXPRT_EVENT(xprtrdma_conn_tout);
+DEFINE_RXPRT_EVENT(xprtrdma_create);
+DEFINE_RXPRT_EVENT(xprtrdma_destroy);
+DEFINE_RXPRT_EVENT(xprtrdma_remove);
+DEFINE_RXPRT_EVENT(xprtrdma_reinsert);
+DEFINE_RXPRT_EVENT(xprtrdma_reconnect);
+DEFINE_RXPRT_EVENT(xprtrdma_inject_dsc);
+
+/**
  ** Call events
  **/
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ddf0d87..25d1160 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -259,13 +259,10 @@
 
 	xprt_clear_connected(xprt);
 
-	dprintk("RPC:       %s: %sconnect\n", __func__,
-			r_xprt->rx_ep.rep_connected != 0 ? "re" : "");
 	rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
 	if (rc)
 		xprt_wake_pending_tasks(xprt, rc);
 
-	dprintk("RPC:       %s: exit\n", __func__);
 	xprt_clear_connecting(xprt);
 }
 
@@ -275,7 +272,7 @@
 	struct rpcrdma_xprt *r_xprt = container_of(xprt, struct rpcrdma_xprt,
 						   rx_xprt);
 
-	pr_info("rpcrdma: injecting transport disconnect on xprt=%p\n", xprt);
+	trace_xprtrdma_inject_dsc(r_xprt);
 	rdma_disconnect(r_xprt->rx_ia.ri_id);
 }
 
@@ -295,7 +292,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
-	dprintk("RPC:       %s: called\n", __func__);
+	trace_xprtrdma_destroy(r_xprt);
 
 	cancel_delayed_work_sync(&r_xprt->rx_connect_worker);
 
@@ -306,11 +303,8 @@
 	rpcrdma_ia_close(&r_xprt->rx_ia);
 
 	xprt_rdma_free_addresses(xprt);
-
 	xprt_free(xprt);
 
-	dprintk("RPC:       %s: returning\n", __func__);
-
 	module_put(THIS_MODULE);
 }
 
@@ -430,6 +424,7 @@
 	dprintk("RPC:       %s: %s:%s\n", __func__,
 		xprt->address_strings[RPC_DISPLAY_ADDR],
 		xprt->address_strings[RPC_DISPLAY_PORT]);
+	trace_xprtrdma_create(new_xprt);
 	return xprt;
 
 out4:
@@ -440,6 +435,7 @@
 out2:
 	rpcrdma_ia_close(&new_xprt->rx_ia);
 out1:
+	trace_xprtrdma_destroy(new_xprt);
 	xprt_rdma_free_addresses(xprt);
 	xprt_free(xprt);
 	return ERR_PTR(rc);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1addcc9..7f9e902 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -220,6 +220,7 @@
 	struct rpcrdma_ep *ep = &xprt->rx_ep;
 	int connstate = 0;
 
+	trace_xprtrdma_conn_upcall(xprt, event);
 	switch (event->event) {
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
@@ -228,14 +229,10 @@
 		break;
 	case RDMA_CM_EVENT_ADDR_ERROR:
 		ia->ri_async_rc = -EHOSTUNREACH;
-		dprintk("RPC:       %s: CM address resolution error, ep 0x%p\n",
-			__func__, ep);
 		complete(&ia->ri_done);
 		break;
 	case RDMA_CM_EVENT_ROUTE_ERROR:
 		ia->ri_async_rc = -ENETUNREACH;
-		dprintk("RPC:       %s: CM route resolution error, ep 0x%p\n",
-			__func__, ep);
 		complete(&ia->ri_done);
 		break;
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
@@ -299,6 +296,8 @@
 	struct rdma_cm_id *id;
 	int rc;
 
+	trace_xprtrdma_conn_start(xprt);
+
 	init_completion(&ia->ri_done);
 	init_completion(&ia->ri_remove_done);
 
@@ -322,8 +321,7 @@
 	}
 	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
 	if (rc < 0) {
-		dprintk("RPC:       %s: wait() exited: %i\n",
-			__func__, rc);
+		trace_xprtrdma_conn_tout(xprt);
 		goto out;
 	}
 
@@ -340,8 +338,7 @@
 	}
 	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
 	if (rc < 0) {
-		dprintk("RPC:       %s: wait() exited: %i\n",
-			__func__, rc);
+		trace_xprtrdma_conn_tout(xprt);
 		goto out;
 	}
 	rc = ia->ri_async_rc;
@@ -461,6 +458,8 @@
 
 	/* Allow waiters to continue */
 	complete(&ia->ri_remove_done);
+
+	trace_xprtrdma_remove(r_xprt);
 }
 
 /**
@@ -471,7 +470,6 @@
 void
 rpcrdma_ia_close(struct rpcrdma_ia *ia)
 {
-	dprintk("RPC:       %s: entering\n", __func__);
 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
 		if (ia->ri_id->qp)
 			rdma_destroy_qp(ia->ri_id);
@@ -625,9 +623,6 @@
 void
 rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	dprintk("RPC:       %s: entering, connected is %d\n",
-		__func__, ep->rep_connected);
-
 	cancel_delayed_work_sync(&ep->rep_connect_worker);
 
 	if (ia->ri_id->qp) {
@@ -650,7 +645,7 @@
 {
 	int rc, err;
 
-	pr_info("%s: r_xprt = %p\n", __func__, r_xprt);
+	trace_xprtrdma_reinsert(r_xprt);
 
 	rc = -EHOSTUNREACH;
 	if (rpcrdma_ia_open(r_xprt))
@@ -688,7 +683,7 @@
 	struct rdma_cm_id *id, *old;
 	int err, rc;
 
-	dprintk("RPC:       %s: reconnecting...\n", __func__);
+	trace_xprtrdma_reconnect(r_xprt);
 
 	rpcrdma_ep_disconnect(ep, ia);
 
@@ -810,16 +805,14 @@
 	int rc;
 
 	rc = rdma_disconnect(ia->ri_id);
-	if (!rc) {
+	if (!rc)
 		/* returns without wait if not connected */
 		wait_event_interruptible(ep->rep_connect_wait,
 							ep->rep_connected != 1);
-		dprintk("RPC:       %s: after wait, %sconnected\n", __func__,
-			(ep->rep_connected == 1) ? "still " : "dis");
-	} else {
-		dprintk("RPC:       %s: rdma_disconnect %i\n", __func__, rc);
+	else
 		ep->rep_connected = rc;
-	}
+	trace_xprtrdma_disconnect(container_of(ep, struct rpcrdma_xprt,
+					       rx_ep), rc);
 
 	ib_drain_qp(ia->ri_id->qp);
 }

