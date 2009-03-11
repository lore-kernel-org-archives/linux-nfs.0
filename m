From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/30] SUNRPC: Return EAGAIN instead of ENOTCONN when
 waking up xprt->pending
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.32906.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866AbZCKSpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:17 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj6hx022202
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:13 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While we should definitely return socket errors to the task that is
currently trying to send data, there is no need to propagate the same error
to all the other tasks on xprt->pending. Doing so actually slows down
recovery, since it causes more than one tasks to attempt socket recovery.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c     |   15 +++----------
 net/sunrpc/xprt.c     |   20 +++++------------
 net/sunrpc/xprtsock.c |   58 ++++++++++++++++++++++++++-----------------------
 3 files changed, 41 insertions(+), 52 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 145715b..5abab09 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1032,27 +1032,20 @@ call_connect_status(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	if (status >= 0) {
+	if (status >= 0 || status == -EAGAIN) {
 		clnt->cl_stats->netreconn++;
 		task->tk_action = call_transmit;
 		return;
 	}
 
-	/* Something failed: remote service port may have changed */
-	rpc_force_rebind(clnt);
-
 	switch (status) {
-	case -ENOTCONN:
-	case -EAGAIN:
-		task->tk_action = call_bind;
-		if (!RPC_IS_SOFT(task))
-			return;
 		/* if soft mounted, test if we've timed out */
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
-		return;
+		break;
+	default:
+		rpc_exit(task, -EIO);
 	}
-	rpc_exit(task, -EIO);
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d588e75..a0bfe53 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -611,7 +611,7 @@ void xprt_disconnect_done(struct rpc_xprt *xprt)
 	dprintk("RPC:       disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_clear_connected(xprt);
-	xprt_wake_pending_tasks(xprt, -ENOTCONN);
+	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect_done);
@@ -629,7 +629,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		queue_work(rpciod_workqueue, &xprt->task_cleanup);
-	xprt_wake_pending_tasks(xprt, -ENOTCONN);
+	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
@@ -656,7 +656,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		queue_work(rpciod_workqueue, &xprt->task_cleanup);
-	xprt_wake_pending_tasks(xprt, -ENOTCONN);
+	xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -726,9 +726,8 @@ static void xprt_connect_status(struct rpc_task *task)
 	}
 
 	switch (task->tk_status) {
-	case -ENOTCONN:
-		dprintk("RPC: %5u xprt_connect_status: connection broken\n",
-				task->tk_pid);
+	case -EAGAIN:
+		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
 		break;
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u xprt_connect_status: connect attempt timed "
@@ -849,15 +848,8 @@ int xprt_prepare_transmit(struct rpc_task *task)
 		err = req->rq_received;
 		goto out_unlock;
 	}
-	if (!xprt->ops->reserve_xprt(task)) {
+	if (!xprt->ops->reserve_xprt(task))
 		err = -EAGAIN;
-		goto out_unlock;
-	}
-
-	if (!xprt_connected(xprt)) {
-		err = -ENOTCONN;
-		goto out_unlock;
-	}
 out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
 	return err;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 879af6f..8e58b0b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1162,7 +1162,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->tcp_flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
-			xprt_wake_pending_tasks(xprt, 0);
+			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
 		spin_unlock_bh(&xprt->transport_lock);
 		break;
@@ -1721,20 +1721,22 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);
-	if (status < 0) {
-		switch (status) {
-			case -EINPROGRESS:
-			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
-				break;
-			default:
-				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
-		}
+	switch (status) {
+	case 0:
+	case -EINPROGRESS:
+	case -EALREADY:
+		goto out_clear;
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+		/* retry with existing socket, after a delay */
+		break;
+	default:
+		/* get rid of existing socket, and retry */
+		xs_tcp_shutdown(xprt);
+		printk("%s: connect returned unhandled error %d\n",
+				__func__, status);
 	}
+	status = -EAGAIN;
 out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
@@ -1780,20 +1782,22 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	status = xs_tcp_finish_connecting(xprt, sock);
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
-	if (status < 0) {
-		switch (status) {
-			case -EINPROGRESS:
-			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
-				break;
-			default:
-				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
-		}
+	switch (status) {
+	case 0:
+	case -EINPROGRESS:
+	case -EALREADY:
+		goto out_clear;
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+		/* retry with existing socket, after a delay */
+		break;
+	default:
+		/* get rid of existing socket, and retry */
+		xs_tcp_shutdown(xprt);
+		printk("%s: connect returned unhandled error %d\n",
+				__func__, status);
 	}
+	status = -EAGAIN;
 out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:

