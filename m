Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:53790 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726408AbeJBBFT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:19 -0400
Subject: [PATCH v2 13/20] xprtrdma: Rename rpcrdma_qp_async_error_upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:13 -0400
Message-ID: <20181001182613.18578.55205.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
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
index 3b9de5b..a4d9ff9 100644
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
index abbd3cd..b62260a 100644
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
+ * Called from the RDMA provider (device driver) possibly in an interrupt
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
