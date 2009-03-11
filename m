From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/30] SUNRPC: Handle ECONNREFUSED correctly in
 xprt_transmit()
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.99709.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbZCKSpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:13 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj5Tb012448
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:11 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we get an ECONNREFUSED error, we currently go to sleep on the
'xprt->sending' wait queue. The problem is that no timeout is set there,
and there is nothing else that will wake the task up later.

We should deal with ECONNREFUSED in call_status, given that is where we
also deal with -EHOSTDOWN, and friends.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c     |    7 ++++++-
 net/sunrpc/xprt.c     |   38 ++++++++++++++++----------------------
 net/sunrpc/xprtsock.c |   26 ++++++++++++--------------
 3 files changed, 34 insertions(+), 37 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 07e9b05..145715b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1117,10 +1117,12 @@ call_transmit_status(struct rpc_task *task)
 		 * then hold onto the transport lock.
 		 */
 	case -ECONNREFUSED:
+	case -ECONNRESET:
 	case -ENOTCONN:
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+	case -EPIPE:
 		rpc_task_force_reencode(task);
 	}
 }
@@ -1162,9 +1164,12 @@ call_status(struct rpc_task *task)
 			xprt_conditional_disconnect(task->tk_xprt,
 					req->rq_connect_cookie);
 		break;
+	case -ECONNRESET:
 	case -ECONNREFUSED:
-	case -ENOTCONN:
 		rpc_force_rebind(clnt);
+		rpc_delay(task, 3*HZ);
+	case -EPIPE:
+	case -ENOTCONN:
 		task->tk_action = call_bind;
 		break;
 	case -EAGAIN:
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d1afec6..d588e75 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -901,32 +901,26 @@ void xprt_transmit(struct rpc_task *task)
 	req->rq_connect_cookie = xprt->connect_cookie;
 	req->rq_xtime = jiffies;
 	status = xprt->ops->send_request(task);
-	if (status == 0) {
-		dprintk("RPC: %5u xmit complete\n", task->tk_pid);
-		spin_lock_bh(&xprt->transport_lock);
+	if (status != 0) {
+		task->tk_status = status;
+		return;
+	}
 
-		xprt->ops->set_retrans_timeout(task);
+	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
+	spin_lock_bh(&xprt->transport_lock);
 
-		xprt->stat.sends++;
-		xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
-		xprt->stat.bklog_u += xprt->backlog.qlen;
+	xprt->ops->set_retrans_timeout(task);
 
-		/* Don't race with disconnect */
-		if (!xprt_connected(xprt))
-			task->tk_status = -ENOTCONN;
-		else if (!req->rq_received)
-			rpc_sleep_on(&xprt->pending, task, xprt_timer);
-		spin_unlock_bh(&xprt->transport_lock);
-		return;
-	}
+	xprt->stat.sends++;
+	xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
+	xprt->stat.bklog_u += xprt->backlog.qlen;
 
-	/* Note: at this point, task->tk_sleeping has not yet been set,
-	 *	 hence there is no danger of the waking up task being put on
-	 *	 schedq, and being picked up by a parallel run of rpciod().
-	 */
-	task->tk_status = status;
-	if (status == -ECONNREFUSED)
-		rpc_sleep_on(&xprt->sending, task, NULL);
+	/* Don't race with disconnect */
+	if (!xprt_connected(xprt))
+		task->tk_status = -ENOTCONN;
+	else if (!req->rq_received)
+		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+	spin_unlock_bh(&xprt->transport_lock);
 }
 
 static inline void do_xprt_reserve(struct rpc_task *task)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9d1898f..5e8198b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -594,6 +594,8 @@ static int xs_udp_send_request(struct rpc_task *task)
 		/* Still some bytes left; set up for a retry later. */
 		status = -EAGAIN;
 	}
+	if (!transport->sock)
+		goto out;
 
 	switch (status) {
 	case -ENOTSOCK:
@@ -603,19 +605,17 @@ static int xs_udp_send_request(struct rpc_task *task)
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
+	default:
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
+			-status);
 	case -ENETUNREACH:
 	case -EPIPE:
 	case -ECONNREFUSED:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		break;
-	default:
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
-			-status);
 	}
-
+out:
 	return status;
 }
 
@@ -697,6 +697,8 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 		break;
 	}
+	if (!transport->sock)
+		goto out;
 
 	switch (status) {
 	case -ENOTSOCK:
@@ -706,21 +708,17 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
+	default:
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
+			-status);
 	case -ECONNRESET:
 		xs_tcp_shutdown(xprt);
 	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EPIPE:
-		status = -ENOTCONN;
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		break;
-	default:
-		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
-			-status);
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		xs_tcp_shutdown(xprt);
 	}
-
+out:
 	return status;
 }
 

