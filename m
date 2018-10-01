Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f65.google.com ([209.85.166.65]:38934 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbeJBBEm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:04:42 -0400
Subject: [PATCH v2 06/20] sunrpc: Fix connect metrics
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:25:36 -0400
Message-ID: <20181001182536.18578.41702.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For TCP, the logic in xprt_connect_status is currently never invoked
to record a successful connection. Commit 2a4919919a97 ("SUNRPC:
Return EAGAIN instead of ENOTCONN when waking up xprt->pending")
changed the way TCP xprt's are awoken after a connect succeeds.

Instead, change connection-oriented transports to bump connect_count
and compute connect_time the moment that XPRT_CONNECTED is set.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c               |   14 ++++----------
 net/sunrpc/xprtrdma/transport.c |    6 +++++-
 net/sunrpc/xprtsock.c           |   10 ++++++----
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a8db2e3f..93c7a2f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -789,17 +789,11 @@ void xprt_connect(struct rpc_task *task)
 
 static void xprt_connect_status(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt = task->tk_rqstp->rq_xprt;
-
-	if (task->tk_status == 0) {
-		xprt->stat.connect_count++;
-		xprt->stat.connect_time += (long)jiffies - xprt->stat.connect_start;
+	switch (task->tk_status) {
+	case 0:
 		dprintk("RPC: %5u xprt_connect_status: connection established\n",
 				task->tk_pid);
-		return;
-	}
-
-	switch (task->tk_status) {
+		break;
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ECONNABORTED:
@@ -816,7 +810,7 @@ static void xprt_connect_status(struct rpc_task *task)
 	default:
 		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
 				"server %s\n", task->tk_pid, -task->tk_status,
-				xprt->servername);
+				task->tk_rqstp->rq_xprt->servername);
 		task->tk_status = -EIO;
 	}
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3ae73e6..087acfc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -242,8 +242,12 @@
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (ep->rep_connected > 0) {
-		if (!xprt_test_and_set_connected(xprt))
+		if (!xprt_test_and_set_connected(xprt)) {
+			xprt->stat.connect_count++;
+			xprt->stat.connect_time += (long)jiffies -
+						   xprt->stat.connect_start;
 			xprt_wake_pending_tasks(xprt, 0);
+		}
 	} else {
 		if (xprt_test_and_clear_connected(xprt))
 			xprt_wake_pending_tasks(xprt, -ENOTCONN);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6b7539c..e146caa 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1611,6 +1611,9 @@ static void xs_tcp_state_change(struct sock *sk)
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 			xprt_clear_connecting(xprt);
 
+			xprt->stat.connect_count++;
+			xprt->stat.connect_time += (long)jiffies -
+						   xprt->stat.connect_start;
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
 		spin_unlock(&xprt->transport_lock);
@@ -2029,8 +2032,6 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 	}
 
 	/* Tell the socket layer to start connecting... */
-	xprt->stat.connect_count++;
-	xprt->stat.connect_start = jiffies;
 	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, 0);
 }
 
@@ -2062,6 +2063,9 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	case 0:
 		dprintk("RPC:       xprt %p connected to %s\n",
 				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		xprt->stat.connect_count++;
+		xprt->stat.connect_time += (long)jiffies -
+					   xprt->stat.connect_start;
 		xprt_set_connected(xprt);
 	case -ENOBUFS:
 		break;
@@ -2387,8 +2391,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	xs_set_memalloc(xprt);
 
 	/* Tell the socket layer to start connecting... */
-	xprt->stat.connect_count++;
-	xprt->stat.connect_start = jiffies;
 	set_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
 	switch (ret) {
