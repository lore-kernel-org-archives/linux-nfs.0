Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:34005 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUEc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:32 -0400
Subject: [PATCH v1 11/22] xprtrdma: Conventional variable names in
 rpcrdma_conn_upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:54 -0400
Message-ID: <20180910150954.10564.82019.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The convention throughout other parts of xprtrdma is to
name variables of type struct rpcrdma_xprt "r_xprt", not "xprt".
This convention enables the use of the name "xprt" for a "struct
rpc_xprt" type variable, as in other parts of the RPC client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7bf0e65..f2c8c3c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -230,14 +230,15 @@
 static int
 rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 {
-	struct rpcrdma_xprt *xprt = id->context;
-	struct rpcrdma_ia *ia = &xprt->rx_ia;
-	struct rpcrdma_ep *ep = &xprt->rx_ep;
+	struct rpcrdma_xprt *r_xprt = id->context;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	int connstate = 0;
 
 	might_sleep();
 
-	trace_xprtrdma_cm_event(xprt, event);
+	trace_xprtrdma_cm_event(r_xprt, event);
 	switch (event->event) {
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
@@ -256,11 +257,11 @@
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 		pr_info("rpcrdma: removing device %s for %s:%s\n",
 			ia->ri_device->name,
-			rpcrdma_addrstr(xprt), rpcrdma_portstr(xprt));
+			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt));
 #endif
 		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
 		ep->rep_connected = -ENODEV;
-		xprt_force_disconnect(&xprt->rx_xprt);
+		xprt_force_disconnect(xprt);
 		wait_for_completion(&ia->ri_remove_done);
 
 		ia->ri_id = NULL;
@@ -268,9 +269,9 @@
 		/* Return 1 to ensure the core destroys the id. */
 		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
-		++xprt->rx_xprt.connect_cookie;
+		++xprt->connect_cookie;
 		connstate = 1;
-		rpcrdma_update_connect_private(xprt, &event->param.conn);
+		rpcrdma_update_connect_private(r_xprt, &event->param.conn);
 		goto connected;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
 		connstate = -ENOTCONN;
@@ -280,14 +281,14 @@
 		goto connected;
 	case RDMA_CM_EVENT_REJECTED:
 		dprintk("rpcrdma: connection to %s:%s rejected: %s\n",
-			rpcrdma_addrstr(xprt), rpcrdma_portstr(xprt),
+			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
 			rdma_reject_msg(id, event->status));
 		connstate = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
 			connstate = -EAGAIN;
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		++xprt->rx_xprt.connect_cookie;
+		++xprt->connect_cookie;
 		connstate = -ECONNABORTED;
 connected:
 		ep->rep_connected = connstate;
@@ -297,7 +298,7 @@
 	default:
 		dprintk("RPC:       %s: %s:%s on %s/%s (ep 0x%p): %s\n",
 			__func__,
-			rpcrdma_addrstr(xprt), rpcrdma_portstr(xprt),
+			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
 			ia->ri_device->name, ia->ri_ops->ro_displayname,
 			ep, rdma_event_msg(event->event));
 		break;
