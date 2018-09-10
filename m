Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:36479 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728357AbeIJUEW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:22 -0400
Subject: [PATCH v1 10/22] xprtrdma: Rename rpcrdma_conn_upcall
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:48 -0400
Message-ID: <20180910150948.10564.95683.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/verbs.c    |   16 +++++++++++++---
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index cd3e5e7..d3d05fd 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -306,7 +306,7 @@
  ** Connection events
  **/
 
-TRACE_EVENT(xprtrdma_conn_upcall,
+TRACE_EVENT(xprtrdma_cm_event,
 	TP_PROTO(
 		const struct rpcrdma_xprt *r_xprt,
 		struct rdma_cm_event *event
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3a9a62d..7bf0e65 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -219,15 +219,25 @@
 	rpcrdma_set_max_header_sizes(r_xprt);
 }
 
+/**
+ * rpcrdma_cm_event_handler - Handle RDMA CM events
+ * @id: rdma_cm_id on which an event has occurred
+ * @event: details of the event
+ *
+ * Called with @id's mutex held. Returns 1 if caller should
+ * destroy @id, otherwise 0.
+ */
 static int
-rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
+rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 {
 	struct rpcrdma_xprt *xprt = id->context;
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 	struct rpcrdma_ep *ep = &xprt->rx_ep;
 	int connstate = 0;
 
-	trace_xprtrdma_conn_upcall(xprt, event);
+	might_sleep();
+
+	trace_xprtrdma_cm_event(xprt, event);
 	switch (event->event) {
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
@@ -308,7 +318,7 @@
 	init_completion(&ia->ri_done);
 	init_completion(&ia->ri_remove_done);
 
-	id = rdma_create_id(xprt->rx_xprt.xprt_net, rpcrdma_conn_upcall,
+	id = rdma_create_id(xprt->rx_xprt.xprt_net, rpcrdma_cm_event_handler,
 			    xprt, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
