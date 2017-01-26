Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35727 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754038AbdAZR4g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 12:56:36 -0500
Subject: [PATCH v1 2/7] xprtrdma: Handle stale connection rejection
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 26 Jan 2017 12:55:47 -0500
Message-ID: <20170126175547.5794.86451.stgit@manet.1015granger.net>
In-Reply-To: <20170126174806.5794.14678.stgit@manet.1015granger.net>
References: <20170126174806.5794.14678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A server rejects a connection attempt with STALE_CONNECTION when a
client attempts to connect to a working remote service, but uses a
QPN and GUID that corresponds to an old connection that was
abandoned. This might occur after a client crashes and restarts.

Fix rpcrdma_conn_upcall() to distinguish between a normal rejection
and rejection of stale connection parameters.

As an additional clean-up, remove the code that retries the
connection attempt with different ORD/IRD values. Code audit of
other ULP initiators shows no similar special case handling of
initiator_depth or responder_resources.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   65 +++++++++++++------------------------------
 1 file changed, 20 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 61d16c3..45db2b4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -54,6 +54,7 @@
 #include <linux/sunrpc/svc_rdma.h>
 #include <asm/bitops.h>
 #include <linux/module.h> /* try_module_get()/module_put() */
+#include <rdma/ib_cm.h>
 
 #include "xprt_rdma.h"
 
@@ -279,7 +280,14 @@
 		connstate = -ENETDOWN;
 		goto connected;
 	case RDMA_CM_EVENT_REJECTED:
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+		pr_info("rpcrdma: connection to %pIS:%u on %s rejected: %s\n",
+			sap, rpc_get_port(sap), ia->ri_device->name,
+			rdma_reject_msg(id, event->status));
+#endif
 		connstate = -ECONNREFUSED;
+		if (event->status == IB_CM_REJ_STALE_CONN)
+			connstate = -EAGAIN;
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
 		connstate = -ECONNABORTED;
@@ -643,20 +651,20 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 int
 rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
+	struct rpcrdma_xprt *r_xprt = container_of(ia, struct rpcrdma_xprt,
+						   rx_ia);
 	struct rdma_cm_id *id, *old;
+	unsigned int extras;
 	int rc = 0;
-	int retry_count = 0;
 
 	if (ep->rep_connected != 0) {
-		struct rpcrdma_xprt *xprt;
 retry:
 		dprintk("RPC:       %s: reconnecting...\n", __func__);
 
 		rpcrdma_ep_disconnect(ep, ia);
 
-		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
-		id = rpcrdma_create_id(xprt, ia,
-				(struct sockaddr *)&xprt->rx_data.addr);
+		id = rpcrdma_create_id(r_xprt, ia,
+				(struct sockaddr *)&r_xprt->rx_data.addr);
 		if (IS_ERR(id)) {
 			rc = -EHOSTUNREACH;
 			goto out;
@@ -711,51 +719,18 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	}
 
 	wait_event_interruptible(ep->rep_connect_wait, ep->rep_connected != 0);
-
-	/*
-	 * Check state. A non-peer reject indicates no listener
-	 * (ECONNREFUSED), which may be a transient state. All
-	 * others indicate a transport condition which has already
-	 * undergone a best-effort.
-	 */
-	if (ep->rep_connected == -ECONNREFUSED &&
-	    ++retry_count <= RDMA_CONNECT_RETRY_MAX) {
-		dprintk("RPC:       %s: non-peer_reject, retry\n", __func__);
-		goto retry;
-	}
 	if (ep->rep_connected <= 0) {
-		/* Sometimes, the only way to reliably connect to remote
-		 * CMs is to use same nonzero values for ORD and IRD. */
-		if (retry_count++ <= RDMA_CONNECT_RETRY_MAX + 1 &&
-		    (ep->rep_remote_cma.responder_resources == 0 ||
-		     ep->rep_remote_cma.initiator_depth !=
-				ep->rep_remote_cma.responder_resources)) {
-			if (ep->rep_remote_cma.responder_resources == 0)
-				ep->rep_remote_cma.responder_resources = 1;
-			ep->rep_remote_cma.initiator_depth =
-				ep->rep_remote_cma.responder_resources;
+		if (ep->rep_connected == -EAGAIN)
 			goto retry;
-		}
 		rc = ep->rep_connected;
-	} else {
-		struct rpcrdma_xprt *r_xprt;
-		unsigned int extras;
-
-		dprintk("RPC:       %s: connected\n", __func__);
-
-		r_xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
-		extras = r_xprt->rx_buf.rb_bc_srv_max_requests;
-
-		if (extras) {
-			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
-			if (rc) {
-				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
-					__func__, rc);
-				rc = 0;
-			}
-		}
+		goto out;
 	}
 
+	dprintk("RPC:       %s: connected\n", __func__);
+	extras = r_xprt->rx_buf.rb_bc_srv_max_requests;
+	if (extras)
+		rpcrdma_ep_post_extra_recv(r_xprt, extras);
+
 out:
 	if (rc)
 		ep->rep_connected = rc;

