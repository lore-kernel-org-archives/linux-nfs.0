From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Move the test for XPRT_CONNECTING into xprt_connect()
Date: Fri, 16 Apr 2010 16:47:48 -0400
Message-ID: <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932524Ab0DPUrx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:53 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp8x008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:52 -0700 (PDT)
In-Reply-To: <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a bug with setting xprt->stat.connect_start.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprt.c               |    6 +++++-
 net/sunrpc/xprtrdma/transport.c |   28 +++++++++++++---------------
 net/sunrpc/xprtsock.c           |   15 +--------------
 3 files changed, 19 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 18415cc..c71d835 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -712,10 +712,14 @@ void xprt_connect(struct rpc_task *task)
 
 		task->tk_timeout = xprt->connect_timeout;
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
+
+		if (test_bit(XPRT_CLOSING, &xprt->state))
+			return;
+		if (xprt_test_and_set_connecting(xprt))
+			return;
 		xprt->stat.connect_start = jiffies;
 		xprt->ops->connect(task);
 	}
-	return;
 }
 
 static void xprt_connect_status(struct rpc_task *task)
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 187257b..0607b9a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -449,21 +449,19 @@ xprt_rdma_connect(struct rpc_task *task)
 	struct rpc_xprt *xprt = (struct rpc_xprt *)task->tk_xprt;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
-	if (!xprt_test_and_set_connecting(xprt)) {
-		if (r_xprt->rx_ep.rep_connected != 0) {
-			/* Reconnect */
-			schedule_delayed_work(&r_xprt->rdma_connect,
-				xprt->reestablish_timeout);
-			xprt->reestablish_timeout <<= 1;
-			if (xprt->reestablish_timeout > (30 * HZ))
-				xprt->reestablish_timeout = (30 * HZ);
-			else if (xprt->reestablish_timeout < (5 * HZ))
-				xprt->reestablish_timeout = (5 * HZ);
-		} else {
-			schedule_delayed_work(&r_xprt->rdma_connect, 0);
-			if (!RPC_IS_ASYNC(task))
-				flush_scheduled_work();
-		}
+	if (r_xprt->rx_ep.rep_connected != 0) {
+		/* Reconnect */
+		schedule_delayed_work(&r_xprt->rdma_connect,
+			xprt->reestablish_timeout);
+		xprt->reestablish_timeout <<= 1;
+		if (xprt->reestablish_timeout > (30 * HZ))
+			xprt->reestablish_timeout = (30 * HZ);
+		else if (xprt->reestablish_timeout < (5 * HZ))
+			xprt->reestablish_timeout = (5 * HZ);
+	} else {
+		schedule_delayed_work(&r_xprt->rdma_connect, 0);
+		if (!RPC_IS_ASYNC(task))
+			flush_scheduled_work();
 	}
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9847c30..d138afa 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2016,9 +2016,6 @@ static void xs_connect(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
-	if (xprt_test_and_set_connecting(xprt))
-		return;
-
 	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
@@ -2038,16 +2035,6 @@ static void xs_connect(struct rpc_task *task)
 	}
 }
 
-static void xs_tcp_connect(struct rpc_task *task)
-{
-	struct rpc_xprt *xprt = task->tk_xprt;
-
-	/* Exit if we need to wait for socket shutdown to complete */
-	if (test_bit(XPRT_CLOSING, &xprt->state))
-		return;
-	xs_connect(task);
-}
-
 /**
  * xs_udp_print_stats - display UDP socket-specifc stats
  * @xprt: rpc_xprt struct containing statistics
@@ -2246,7 +2233,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
-	.connect		= xs_tcp_connect,
+	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
-- 
1.6.6.1

