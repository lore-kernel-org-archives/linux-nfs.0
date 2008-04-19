From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 28/33] SUNRPC: Don't disconnect more than once if
	retransmitting NFSv4 requests
Date: Sat, 19 Apr 2008 16:40:54 -0400
Message-ID: <20080419204054.14124.67474.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756413AbYDSUuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:35 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoYcr026111
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:34 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 requires us to ensure that we break the TCP connection before we're
allowed to retransmit a request. However in the case where we're
retransmitting several requests that have been sent on the same
connection, we need to ensure that we don't interfere with the attempt to
reconnect and/or break the connection again once it has been established.

We therefore introduce a 'connection' cookie that is bumped every time a
connection is broken. This allows requests to track if they need to force a
disconnection.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    8 ++++++++
 net/sunrpc/clnt.c           |    6 ++++--
 net/sunrpc/xprt.c           |   29 +++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c       |    2 ++
 4 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8a0629a..4d80a11 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -86,6 +86,10 @@ struct rpc_rqst {
 	unsigned long		rq_majortimeo;	/* major timeout alarm */
 	unsigned long		rq_timeout;	/* Current timeout value */
 	unsigned int		rq_retries;	/* # of retries */
+	unsigned int		rq_connect_cookie;
+						/* A cookie used to track the
+						   state of the transport
+						   connection */
 	
 	/*
 	 * Partial send handling
@@ -152,6 +156,9 @@ struct rpc_xprt {
 	unsigned long		connect_timeout,
 				bind_timeout,
 				reestablish_timeout;
+	unsigned int		connect_cookie;	/* A cookie that gets bumped
+						   every time the transport
+						   is reconnected */
 
 	/*
 	 * Disconnection of idle transports
@@ -241,6 +248,7 @@ void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
+void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 57663a4..2969e84 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1116,7 +1116,8 @@ call_status(struct rpc_task *task)
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
 		if (task->tk_client->cl_discrtry)
-			xprt_force_disconnect(task->tk_xprt);
+			xprt_conditional_disconnect(task->tk_xprt,
+					req->rq_connect_cookie);
 		break;
 	case -ECONNREFUSED:
 	case -ENOTCONN:
@@ -1241,7 +1242,8 @@ out_retry:
 	if (task->tk_rqstp == req) {
 		req->rq_received = req->rq_rcv_buf.len = 0;
 		if (task->tk_client->cl_discrtry)
-			xprt_force_disconnect(task->tk_xprt);
+			xprt_conditional_disconnect(task->tk_xprt,
+					req->rq_connect_cookie);
 	}
 }
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a0646a3..75d748e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -606,6 +606,34 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
+/**
+ * xprt_conditional_disconnect - force a transport to disconnect
+ * @xprt: transport to disconnect
+ * @cookie: 'connection cookie'
+ *
+ * This attempts to break the connection if and only if 'cookie' matches
+ * the current transport 'connection cookie'. It ensures that we don't
+ * try to break the connection more than once when we need to retransmit
+ * a batch of RPC requests.
+ *
+ */
+void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
+{
+	/* Don't race with the test_bit() in xprt_clear_locked() */
+	spin_lock_bh(&xprt->transport_lock);
+	if (cookie != xprt->connect_cookie)
+		goto out;
+	if (test_bit(XPRT_CLOSING, &xprt->state) || !xprt_connected(xprt))
+		goto out;
+	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	/* Try to schedule an autoclose RPC call */
+	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
+		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	xprt_wake_pending_tasks(xprt, -ENOTCONN);
+out:
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
 static void
 xprt_init_autodisconnect(unsigned long data)
 {
@@ -849,6 +877,7 @@ void xprt_transmit(struct rpc_task *task)
 	} else if (!req->rq_bytes_sent)
 		return;
 
+	req->rq_connect_cookie = xprt->connect_cookie;
 	status = xprt->ops->send_request(task);
 	if (status == 0) {
 		dprintk("RPC: %5u xmit complete\n", task->tk_pid);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4a567a9..63d79e3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1142,6 +1142,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		break;
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
+		xprt->connect_cookie++;
 		xprt->reestablish_timeout = 0;
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
@@ -1154,6 +1155,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		set_bit(XPRT_CLOSING, &xprt->state);
 		xprt_force_disconnect(xprt);
 	case TCP_SYN_SENT:
+		xprt->connect_cookie++;
 	case TCP_CLOSING:
 		/*
 		 * If the server closed down the connection, make sure that

