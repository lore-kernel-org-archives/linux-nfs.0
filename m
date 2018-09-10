Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:40446 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUEe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:34 -0400
Subject: [PATCH v1 12/22] xprtrdma: Eliminate "connstate" variable from
 rpcrdma_conn_upcall()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:59 -0400
Message-ID: <20180910150959.10564.83078.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Since commit 173b8f49b3af ("xprtrdma: Demote "connect" log messages")
there has been no need to initialize connstat to zero. In fact, in
this code path there's now no reason not to set rep_connected
directly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f2c8c3c..422d3db 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -234,7 +234,6 @@
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
-	int connstate = 0;
 
 	might_sleep();
 
@@ -270,28 +269,27 @@
 		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
 		++xprt->connect_cookie;
-		connstate = 1;
+		ep->rep_connected = 1;
 		rpcrdma_update_connect_private(r_xprt, &event->param.conn);
 		goto connected;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
-		connstate = -ENOTCONN;
+		ep->rep_connected = -ENOTCONN;
 		goto connected;
 	case RDMA_CM_EVENT_UNREACHABLE:
-		connstate = -ENETUNREACH;
+		ep->rep_connected = -ENETUNREACH;
 		goto connected;
 	case RDMA_CM_EVENT_REJECTED:
 		dprintk("rpcrdma: connection to %s:%s rejected: %s\n",
 			rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
 			rdma_reject_msg(id, event->status));
-		connstate = -ECONNREFUSED;
+		ep->rep_connected = -ECONNREFUSED;
 		if (event->status == IB_CM_REJ_STALE_CONN)
-			connstate = -EAGAIN;
+			ep->rep_connected = -EAGAIN;
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
 		++xprt->connect_cookie;
-		connstate = -ECONNABORTED;
+		ep->rep_connected = -ECONNABORTED;
 connected:
-		ep->rep_connected = connstate;
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
 		/*FALLTHROUGH*/
