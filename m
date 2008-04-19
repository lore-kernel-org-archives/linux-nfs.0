From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/33] SUNRPC: Fix up xprt_write_space()
Date: Sat, 19 Apr 2008 16:40:47 -0400
Message-ID: <20080419204047.14124.5947.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756476AbYDSUue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:34 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoXCp002646
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:33 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rest of the networking layer uses SOCK_ASYNC_NOSPACE to signal whether
or not we have someone waiting for buffer memory. Convert the SUNRPC layer
to use the same idiom.
Remove the unlikely()s in xs_udp_write_space and xs_tcp_write_space. In
fact, the most common case will be that there is nobody waiting for buffer
space.

SOCK_NOSPACE is there to tell the TCP layer whether or not the cwnd was
limited by the application window. Ensure that we follow the same idiom as
the rest of the networking layer here too.

Finally, ensure that we clear SOCK_ASYNC_NOSPACE once we wake up, so that
write_space() doesn't keep waking things up on xprt->pending.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    2 +
 net/sunrpc/xprt.c           |    4 +--
 net/sunrpc/xprtsock.c       |   61 +++++++++++++++++++++++++++++--------------
 3 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b3ff9a8..8a0629a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -232,7 +232,7 @@ int			xprt_unregister_transport(struct xprt_class *type);
 void			xprt_set_retrans_timeout_def(struct rpc_task *task);
 void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
-void			xprt_wait_for_buffer_space(struct rpc_task *task);
+void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
 void			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_update_rtt(struct rpc_task *task);
 void			xprt_adjust_cwnd(struct rpc_task *task, int result);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 85199c6..3ba64f9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -447,13 +447,13 @@ EXPORT_SYMBOL_GPL(xprt_wake_pending_tasks);
  * @task: task to be put to sleep
  *
  */
-void xprt_wait_for_buffer_space(struct rpc_task *task)
+void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	task->tk_timeout = req->rq_timeout;
-	rpc_sleep_on(&xprt->pending, task, NULL);
+	rpc_sleep_on(&xprt->pending, task, action);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8bd3b0f..4c2462e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -516,6 +516,14 @@ out:
 	return sent;
 }
 
+static void xs_nospace_callback(struct rpc_task *task)
+{
+	struct sock_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct sock_xprt, xprt);
+
+	transport->inet->sk_write_pending--;
+	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+}
+
 /**
  * xs_nospace - place task on wait queue if transmit was incomplete
  * @task: task to put to sleep
@@ -531,20 +539,27 @@ static void xs_nospace(struct rpc_task *task)
 			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
 			req->rq_slen);
 
-	if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
-		/* Protect against races with write_space */
-		spin_lock_bh(&xprt->transport_lock);
-
-		/* Don't race with disconnect */
-		if (!xprt_connected(xprt))
-			task->tk_status = -ENOTCONN;
-		else if (test_bit(SOCK_NOSPACE, &transport->sock->flags))
-			xprt_wait_for_buffer_space(task);
+	/* Protect against races with write_space */
+	spin_lock_bh(&xprt->transport_lock);
+
+	/* Don't race with disconnect */
+	if (xprt_connected(xprt)) {
+		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
+			/*
+			 * Notify TCP that we're limited by the application
+			 * window size
+			 */
+			set_bit(SOCK_NOSPACE, &transport->sock->flags);
+			transport->inet->sk_write_pending++;
+			/* ...and wait for more buffer space */
+			xprt_wait_for_buffer_space(task, xs_nospace_callback);
+		}
+	} else {
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		task->tk_status = -ENOTCONN;
+	}
 
-		spin_unlock_bh(&xprt->transport_lock);
-	} else
-		/* Keep holding the socket if it is blocked */
-		rpc_delay(task, HZ>>4);
+	spin_unlock_bh(&xprt->transport_lock);
 }
 
 /**
@@ -588,19 +603,20 @@ static int xs_udp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -EAGAIN:
+		xs_nospace(task);
+		break;
 	case -ENETUNREACH:
 	case -EPIPE:
 	case -ECONNREFUSED:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
-		break;
-	case -EAGAIN:
-		xs_nospace(task);
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		break;
 	default:
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
-		break;
 	}
 
 	return status;
@@ -695,12 +711,13 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -ENOTCONN:
 	case -EPIPE:
 		status = -ENOTCONN;
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		xs_tcp_shutdown(xprt);
-		break;
 	}
 
 	return status;
@@ -1189,9 +1206,11 @@ static void xs_udp_write_space(struct sock *sk)
 
 		if (unlikely(!(sock = sk->sk_socket)))
 			goto out;
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+
 		if (unlikely(!(xprt = xprt_from_sock(sk))))
 			goto out;
-		if (unlikely(!test_and_clear_bit(SOCK_NOSPACE, &sock->flags)))
+		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
 			goto out;
 
 		xprt_write_space(xprt);
@@ -1222,9 +1241,11 @@ static void xs_tcp_write_space(struct sock *sk)
 
 		if (unlikely(!(sock = sk->sk_socket)))
 			goto out;
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+
 		if (unlikely(!(xprt = xprt_from_sock(sk))))
 			goto out;
-		if (unlikely(!test_and_clear_bit(SOCK_NOSPACE, &sock->flags)))
+		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
 			goto out;
 
 		xprt_write_space(xprt);

