Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:43079 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBd2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:28 -0400
Received: by mail-io0-f170.google.com with SMTP id y10-v6so4213060ioa.10
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:35 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.33
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:34 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 32/34] SUNRPC: Clean up transport write space handling
Date: Tue,  4 Sep 2018 17:05:47 -0400
Message-Id: <20180904210549.81673-33-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-32-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
 <20180904210549.81673-26-trond.myklebust@hammerspace.com>
 <20180904210549.81673-27-trond.myklebust@hammerspace.com>
 <20180904210549.81673-28-trond.myklebust@hammerspace.com>
 <20180904210549.81673-29-trond.myklebust@hammerspace.com>
 <20180904210549.81673-30-trond.myklebust@hammerspace.com>
 <20180904210549.81673-31-trond.myklebust@hammerspace.com>
 <20180904210549.81673-32-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Treat socket write space handling in the same way we now treat transport
congestion: by denying the XPRT_LOCK until the transport signals that it
has free buffer space.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/svc_xprt.h            |  1 -
 include/linux/sunrpc/xprt.h                |  5 +-
 net/sunrpc/clnt.c                          | 11 +---
 net/sunrpc/svc_xprt.c                      |  2 -
 net/sunrpc/xprt.c                          | 69 ++++++++++++++--------
 net/sunrpc/xprtrdma/rpc_rdma.c             |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  7 +--
 net/sunrpc/xprtsock.c                      | 33 ++++-------
 8 files changed, 62 insertions(+), 68 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c3d72066d4b1..6b7a86c4d6e6 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -84,7 +84,6 @@ struct svc_xprt {
 	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
 	size_t			xpt_remotelen;	/* length of address */
 	char			xpt_remotebuf[INET6_ADDRSTRLEN + 10];
-	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
 	struct list_head	xpt_users;	/* callbacks on free */
 
 	struct net		*xpt_net;
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index d623bebab4f9..ba4a9d83102a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -386,8 +386,8 @@ int			xprt_load_transport(const char *);
 void			xprt_set_retrans_timeout_def(struct rpc_task *task);
 void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
-void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
-void			xprt_write_space(struct rpc_xprt *xprt);
+void			xprt_wait_for_buffer_space(struct rpc_xprt *xprt);
+bool			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_update_rtt(struct rpc_task *task);
@@ -414,6 +414,7 @@ void			xprt_unlock_connect(struct rpc_xprt *, void *);
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
 #define XPRT_CONGESTED		(9)
+#define XPRT_WRITE_SPACE	(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4f8803413499..fb19c8a85e68 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1978,6 +1978,7 @@ call_transmit(struct rpc_task *task)
 	if (!xprt_prepare_transmit(task))
 		return;
 	xprt_transmit(task);
+	xprt_end_transmit(task);
 }
 
 /*
@@ -1993,7 +1994,6 @@ call_transmit_status(struct rpc_task *task)
 	 * test first.
 	 */
 	if (task->tk_status == 0) {
-		xprt_end_transmit(task);
 		xprt_request_wait_receive(task);
 		return;
 	}
@@ -2001,15 +2001,12 @@ call_transmit_status(struct rpc_task *task)
 	switch (task->tk_status) {
 	default:
 		dprint_status(task);
-		xprt_end_transmit(task);
 		break;
 	case -EBADSLT:
-		xprt_end_transmit(task);
 		task->tk_action = call_transmit;
 		task->tk_status = 0;
 		break;
 	case -EBADMSG:
-		xprt_end_transmit(task);
 		task->tk_action = call_encode;
 		break;
 		/*
@@ -2032,7 +2029,6 @@ call_transmit_status(struct rpc_task *task)
 	case -ENETUNREACH:
 	case -EPERM:
 		if (RPC_IS_SOFTCONN(task)) {
-			xprt_end_transmit(task);
 			if (!task->tk_msg.rpc_proc->p_proc)
 				trace_xprt_ping(task->tk_xprt,
 						task->tk_status);
@@ -2076,9 +2072,6 @@ call_bc_transmit(struct rpc_task *task)
 
 	xprt_transmit(task);
 
-	if (task->tk_status == -EAGAIN)
-		goto out_nospace;
-
 	xprt_end_transmit(task);
 	dprint_status(task);
 	switch (task->tk_status) {
@@ -2094,6 +2087,8 @@ call_bc_transmit(struct rpc_task *task)
 	case -ENOTCONN:
 	case -EPIPE:
 		break;
+	case -EAGAIN:
+		goto out_nospace;
 	case -ETIMEDOUT:
 		/*
 		 * Problem reaching the server.  Disconnect and let the
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5185efb9027b..87533fbb96cf 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -171,7 +171,6 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
-	rpc_init_wait_queue(&xprt->xpt_bc_pending, "xpt_bc_pending");
 	xprt->xpt_net = get_net(net);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
 }
@@ -895,7 +894,6 @@ int svc_send(struct svc_rqst *rqstp)
 	else
 		len = xprt->xpt_ops->xpo_sendto(rqstp);
 	mutex_unlock(&xprt->xpt_mutex);
-	rpc_wake_up(&xprt->xpt_bc_pending);
 	trace_svc_send(rqstp, len);
 	svc_xprt_release(rqstp);
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4068d0ea3a21..baa454b0d855 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -169,6 +169,17 @@ int xprt_load_transport(const char *transport_name)
 }
 EXPORT_SYMBOL_GPL(xprt_load_transport);
 
+static void xprt_clear_locked(struct rpc_xprt *xprt)
+{
+	xprt->snd_task = NULL;
+	if (!test_bit(XPRT_CLOSE_WAIT, &xprt->state)) {
+		smp_mb__before_atomic();
+		clear_bit(XPRT_LOCKED, &xprt->state);
+		smp_mb__after_atomic();
+	} else
+		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
+}
+
 /**
  * xprt_reserve_xprt - serialize write access to transports
  * @task: task that is requesting access to the transport
@@ -187,10 +198,14 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 			return 1;
 		goto out_sleep;
 	}
+	if (test_bit(XPRT_WRITE_SPACE, &xprt->state))
+		goto out_unlock;
 	xprt->snd_task = task;
 
 	return 1;
 
+out_unlock:
+	xprt_clear_locked(xprt);
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n",
 			task->tk_pid, xprt);
@@ -201,17 +216,6 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
 
-static void xprt_clear_locked(struct rpc_xprt *xprt)
-{
-	xprt->snd_task = NULL;
-	if (!test_bit(XPRT_CLOSE_WAIT, &xprt->state)) {
-		smp_mb__before_atomic();
-		clear_bit(XPRT_LOCKED, &xprt->state);
-		smp_mb__after_atomic();
-	} else
-		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
-}
-
 /*
  * xprt_reserve_xprt_cong - serialize write access to transports
  * @task: task that is requesting access to the transport
@@ -234,10 +238,13 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 		xprt->snd_task = task;
 		return 1;
 	}
+	if (test_bit(XPRT_WRITE_SPACE, &xprt->state))
+		goto out_unlock;
 	if (!RPCXPRT_CONGESTED(xprt)) {
 		xprt->snd_task = task;
 		return 1;
 	}
+out_unlock:
 	xprt_clear_locked(xprt);
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
@@ -270,9 +277,11 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
 {
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
-
+	if (test_bit(XPRT_WRITE_SPACE, &xprt->state))
+		goto out_unlock;
 	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
 		return;
+out_unlock:
 	xprt_clear_locked(xprt);
 }
 
@@ -280,6 +289,8 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 {
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
+	if (test_bit(XPRT_WRITE_SPACE, &xprt->state))
+		goto out_unlock;
 	if (RPCXPRT_CONGESTED(xprt))
 		goto out_unlock;
 	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
@@ -450,38 +461,43 @@ EXPORT_SYMBOL_GPL(xprt_wake_pending_tasks);
 
 /**
  * xprt_wait_for_buffer_space - wait for transport output buffer to clear
- * @task: task to be put to sleep
- * @action: function pointer to be executed after wait
+ * @xprt: transport
  *
  * Note that we only set the timer for the case of RPC_IS_SOFT(), since
  * we don't in general want to force a socket disconnection due to
  * an incomplete RPC call transmission.
  */
-void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
+void xprt_wait_for_buffer_space(struct rpc_xprt *xprt)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_xprt *xprt = req->rq_xprt;
-
-	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
-	rpc_sleep_on(&xprt->pending, task, action);
+	set_bit(XPRT_WRITE_SPACE, &xprt->state);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
 
+static bool
+xprt_clear_write_space_locked(struct rpc_xprt *xprt)
+{
+	if (test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state)) {
+		__xprt_lock_write_next(xprt);
+		dprintk("RPC:       write space: waking waiting task on "
+				"xprt %p\n", xprt);
+		return true;
+	}
+	return false;
+}
+
 /**
  * xprt_write_space - wake the task waiting for transport output buffer space
  * @xprt: transport with waiting tasks
  *
  * Can be called in a soft IRQ context, so xprt_write_space never sleeps.
  */
-void xprt_write_space(struct rpc_xprt *xprt)
+bool xprt_write_space(struct rpc_xprt *xprt)
 {
+	bool ret;
 	spin_lock_bh(&xprt->transport_lock);
-	if (xprt->snd_task) {
-		dprintk("RPC:       write space: waking waiting task on "
-				"xprt %p\n", xprt);
-		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
-	}
+	ret = xprt_clear_write_space_locked(xprt);
 	spin_unlock_bh(&xprt->transport_lock);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(xprt_write_space);
 
@@ -592,6 +608,7 @@ void xprt_disconnect_done(struct rpc_xprt *xprt)
 	dprintk("RPC:       disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_clear_connected(xprt);
+	xprt_clear_write_space_locked(xprt);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 0020dc401215..53fa95d60015 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -866,7 +866,7 @@ rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
 out_err:
 	switch (ret) {
 	case -EAGAIN:
-		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
+		xprt_wait_for_buffer_space(rqst->rq_xprt);
 		break;
 	case -ENOBUFS:
 		break;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index d1618c70edb4..35a8c3aab302 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -224,12 +224,7 @@ xprt_rdma_bc_send_request(struct rpc_rqst *rqst, struct rpc_task *task)
 	dprintk("svcrdma: sending bc call with xid: %08x\n",
 		be32_to_cpu(rqst->rq_xid));
 
-	if (!mutex_trylock(&sxprt->xpt_mutex)) {
-		rpc_sleep_on(&sxprt->xpt_bc_pending, task, NULL);
-		if (!mutex_trylock(&sxprt->xpt_mutex))
-			return -EAGAIN;
-		rpc_wake_up_queued_task(&sxprt->xpt_bc_pending, task);
-	}
+	mutex_lock(&sxprt->xpt_mutex);
 
 	ret = -ENOTCONN;
 	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f54e8110f4c6..ef8d0e81cbda 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -440,20 +440,12 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	return err;
 }
 
-static void xs_nospace_callback(struct rpc_task *task)
-{
-	struct sock_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct sock_xprt, xprt);
-
-	transport->inet->sk_write_pending--;
-}
-
 /**
- * xs_nospace - place task on wait queue if transmit was incomplete
+ * xs_nospace - handle transmit was incomplete
  * @req: pointer to RPC request
- * @task: task to put to sleep
  *
  */
-static int xs_nospace(struct rpc_rqst *req, struct rpc_task *task)
+static int xs_nospace(struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -461,7 +453,8 @@ static int xs_nospace(struct rpc_rqst *req, struct rpc_task *task)
 	int ret = -EAGAIN;
 
 	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
-			task->tk_pid, req->rq_slen - transport->xmit.offset,
+			req->rq_task->tk_pid,
+			req->rq_slen - transport->xmit.offset,
 			req->rq_slen);
 
 	/* Protect against races with write_space */
@@ -471,7 +464,7 @@ static int xs_nospace(struct rpc_rqst *req, struct rpc_task *task)
 	if (xprt_connected(xprt)) {
 		/* wait for more buffer space */
 		sk->sk_write_pending++;
-		xprt_wait_for_buffer_space(task, xs_nospace_callback);
+		xprt_wait_for_buffer_space(xprt);
 	} else
 		ret = -ENOTCONN;
 
@@ -569,7 +562,7 @@ static int xs_local_send_request(struct rpc_rqst *req, struct rpc_task *task)
 	case -ENOBUFS:
 		break;
 	case -EAGAIN:
-		status = xs_nospace(req, task);
+		status = xs_nospace(req);
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
@@ -642,7 +635,7 @@ static int xs_udp_send_request(struct rpc_rqst *req, struct rpc_task *task)
 		/* Should we call xs_close() here? */
 		break;
 	case -EAGAIN:
-		status = xs_nospace(req, task);
+		status = xs_nospace(req);
 		break;
 	case -ENETUNREACH:
 	case -ENOBUFS:
@@ -765,7 +758,7 @@ static int xs_tcp_send_request(struct rpc_rqst *req, struct rpc_task *task)
 		/* Should we call xs_close() here? */
 		break;
 	case -EAGAIN:
-		status = xs_nospace(req, task);
+		status = xs_nospace(req);
 		break;
 	case -ECONNRESET:
 	case -ECONNREFUSED:
@@ -1672,7 +1665,8 @@ static void xs_write_space(struct sock *sk)
 	if (!wq || test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags) == 0)
 		goto out;
 
-	xprt_write_space(xprt);
+	if (xprt_write_space(xprt))
+		sk->sk_write_pending--;
 out:
 	rcu_read_unlock();
 }
@@ -2725,12 +2719,7 @@ static int bc_send_request(struct rpc_rqst *req, struct rpc_task *task)
 	 * Grab the mutex to serialize data as the connection is shared
 	 * with the fore channel
 	 */
-	if (!mutex_trylock(&xprt->xpt_mutex)) {
-		rpc_sleep_on(&xprt->xpt_bc_pending, task, NULL);
-		if (!mutex_trylock(&xprt->xpt_mutex))
-			return -EAGAIN;
-		rpc_wake_up_queued_task(&xprt->xpt_bc_pending, task);
-	}
+	mutex_lock(&xprt->xpt_mutex);
 	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		len = -ENOTCONN;
 	else
-- 
2.17.1
