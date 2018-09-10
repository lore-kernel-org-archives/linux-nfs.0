Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:40006 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUEt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:49 -0400
Subject: [PATCH v1 15/22] xprtrdma: Rename rpcrdma_qp_async_error_upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:15 -0400
Message-ID: <20180910151015.10564.41595.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use a function name that is consistent with the RDMA core
API and with other consumers. Because this is a function that is
invoked from outside the rpcrdma.ko module, add an appropriate
documenting comment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |    2 +-
 net/sunrpc/xprtrdma/verbs.c    |   14 +++++++++++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index d3d05fd..d8ddcac 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -377,7 +377,7 @@
 DEFINE_RXPRT_EVENT(xprtrdma_reconnect);
 DEFINE_RXPRT_EVENT(xprtrdma_inject_dsc);
 
-TRACE_EVENT(xprtrdma_qp_error,
+TRACE_EVENT(xprtrdma_qp_event,
 	TP_PROTO(
 		const struct rpcrdma_xprt *r_xprt,
 		const struct ib_event *event
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index abbd3cd..72bf811 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -127,14 +127,22 @@
 	xprt_force_disconnect(&r_xprt->rx_xprt);
 }
 
+/**
+ * rpcrdma_qp_event_handler - Handle one QP event (error notification)
+ * @event: details of the event
+ * @context: ep that owns QP where event occurred
+ *
+ * Called from RDMA provider (device driver) possibly in a non-blocking
+ * context.
+ */
 static void
-rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
+rpcrdma_qp_event_handler(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;
 	struct rpcrdma_xprt *r_xprt = container_of(ep, struct rpcrdma_xprt,
 						   rx_ep);
 
-	trace_xprtrdma_qp_error(r_xprt, event);
+	trace_xprtrdma_qp_event(r_xprt, event);
 	pr_err("rpcrdma: %s on device %s ep %p\n",
 	       ib_event_msg(event->event), event->device->name, context);
 
@@ -547,7 +555,7 @@
 	if (rc)
 		return rc;
 
-	ep->rep_attr.event_handler = rpcrdma_qp_async_error_upcall;
+	ep->rep_attr.event_handler = rpcrdma_qp_event_handler;
 	ep->rep_attr.qp_context = ep;
 	ep->rep_attr.srq = NULL;
 	ep->rep_attr.cap.max_send_sge = max_sge;
