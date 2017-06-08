Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:38879 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdFHPxC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 11:53:02 -0400
Subject: [PATCH v2 10/13] xprtrdma: Demote "connect" log messages
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 08 Jun 2017 11:53:00 -0400
Message-ID: <20170608155300.18945.28044.stgit@manet.1015granger.net>
In-Reply-To: <20170608154339.18945.5500.stgit@manet.1015granger.net>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some have complained about the log messages generated when xprtrdma
opens or closes a connection to a server. When an NFS mount is
mostly idle these can appear every few minutes as the client idles
out the connection and reconnects.

Connection and disconnection is a normal part of operation, and not
exceptional, so change these to dprintk's for now. At some point
all of these will be converted to tracepoints, but that's for
another day.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   44 ++++++++-----------------------------------
 1 file changed, 8 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a215a87..e4171f2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -243,8 +243,6 @@
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	struct sockaddr *sap = (struct sockaddr *)&ep->rep_remote_addr;
 #endif
-	struct ib_qp_attr *attr = &ia->ri_qp_attr;
-	struct ib_qp_init_attr *iattr = &ia->ri_qp_init_attr;
 	int connstate = 0;
 
 	switch (event->event) {
@@ -267,7 +265,8 @@
 		break;
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-		pr_info("rpcrdma: removing device for %pIS:%u\n",
+		pr_info("rpcrdma: removing device %s for %pIS:%u\n",
+			ia->ri_device->name,
 			sap, rpc_get_port(sap));
 #endif
 		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
@@ -282,13 +281,6 @@
 		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
 		connstate = 1;
-		ib_query_qp(ia->ri_id->qp, attr,
-			    IB_QP_MAX_QP_RD_ATOMIC | IB_QP_MAX_DEST_RD_ATOMIC,
-			    iattr);
-		dprintk("RPC:       %s: %d responder resources"
-			" (%d initiator)\n",
-			__func__, attr->max_dest_rd_atomic,
-			attr->max_rd_atomic);
 		rpcrdma_update_connect_private(xprt, &event->param.conn);
 		goto connected;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
@@ -298,11 +290,9 @@
 		connstate = -ENETDOWN;
 		goto connected;
 	case RDMA_CM_EVENT_REJECTED:
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-		pr_info("rpcrdma: connection to %pIS:%u on %s rejected: %s\n",
-			sap, rpc_get_port(sap), ia->ri_device->name,
+		dprintk("rpcrdma: connection to %pIS:%u rejected: %s\n",
+			sap, rpc_get_port(sap),
 			rdma_reject_msg(id, event->status));
-#endif
 		connstate = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
 			connstate = -EAGAIN;
@@ -310,37 +300,19 @@
 	case RDMA_CM_EVENT_DISCONNECTED:
 		connstate = -ECONNABORTED;
 connected:
-		dprintk("RPC:       %s: %sconnected\n",
-					__func__, connstate > 0 ? "" : "dis");
 		atomic_set(&xprt->rx_buf.rb_credits, 1);
 		ep->rep_connected = connstate;
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
 		/*FALLTHROUGH*/
 	default:
-		dprintk("RPC:       %s: %pIS:%u (ep 0x%p): %s\n",
-			__func__, sap, rpc_get_port(sap), ep,
-			rdma_event_msg(event->event));
+		dprintk("RPC:       %s: %pIS:%u on %s/%s (ep 0x%p): %s\n",
+			__func__, sap, rpc_get_port(sap),
+			ia->ri_device->name, ia->ri_ops->ro_displayname,
+			ep, rdma_event_msg(event->event));
 		break;
 	}
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-	if (connstate == 1) {
-		int ird = attr->max_dest_rd_atomic;
-		int tird = ep->rep_remote_cma.responder_resources;
-
-		pr_info("rpcrdma: connection to %pIS:%u on %s, memreg '%s', %d credits, %d responders%s\n",
-			sap, rpc_get_port(sap),
-			ia->ri_device->name,
-			ia->ri_ops->ro_displayname,
-			xprt->rx_buf.rb_max_requests,
-			ird, ird < 4 && ird < tird / 2 ? " (low!)" : "");
-	} else if (connstate < 0) {
-		pr_info("rpcrdma: connection to %pIS:%u closed (%d)\n",
-			sap, rpc_get_port(sap), connstate);
-	}
-#endif
-
 	return 0;
 }
 

