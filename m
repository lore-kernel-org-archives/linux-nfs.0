Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:45863 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728187AbeIQSbd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:33 -0400
Received: by mail-qt0-f172.google.com with SMTP id g44-v6so15094093qtb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:17 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:15 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 16/44] SUNRPC: Refactor xprt_transmit() to remove wait for reply code
Date: Mon, 17 Sep 2018 09:03:07 -0400
Message-Id: <20180917130335.112832-17-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-16-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the caller in clnt.c to call into the code to wait for a reply
after calling xprt_transmit(). Again, the reason is that the backchannel
code does not need this functionality.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 +
 net/sunrpc/clnt.c           | 10 +----
 net/sunrpc/xprt.c           | 74 ++++++++++++++++++++++++++-----------
 3 files changed, 54 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 0250294c904a..4fa2af087cff 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -335,6 +335,7 @@ void			xprt_free_slot(struct rpc_xprt *xprt,
 void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_receive(struct rpc_task *task);
+void			xprt_request_wait_receive(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
 void			xprt_end_transmit(struct rpc_task *task);
 int			xprt_adjust_timeout(struct rpc_rqst *req);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 414966273a3f..775d6e80b6e8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1975,15 +1975,6 @@ call_transmit(struct rpc_task *task)
 		return;
 	if (is_retrans)
 		task->tk_client->cl_stats->rpcretrans++;
-	/*
-	 * On success, ensure that we call xprt_end_transmit() before sleeping
-	 * in order to allow access to the socket to other RPC requests.
-	 */
-	call_transmit_status(task);
-	if (rpc_reply_expected(task))
-		return;
-	task->tk_action = rpc_exit_task;
-	rpc_wake_up_queued_task(&task->tk_rqstp->rq_xprt->pending, task);
 }
 
 /*
@@ -2000,6 +1991,7 @@ call_transmit_status(struct rpc_task *task)
 	 */
 	if (task->tk_status == 0) {
 		xprt_end_transmit(task);
+		xprt_request_wait_receive(task);
 		return;
 	}
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d8f870b5dd46..fe857ab18ee2 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -654,6 +654,22 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_force_disconnect);
 
+static unsigned int
+xprt_connect_cookie(struct rpc_xprt *xprt)
+{
+	return READ_ONCE(xprt->connect_cookie);
+}
+
+static bool
+xprt_request_retransmit_after_disconnect(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	return req->rq_connect_cookie != xprt_connect_cookie(xprt) ||
+		!xprt_connected(xprt);
+}
+
 /**
  * xprt_conditional_disconnect - force a transport to disconnect
  * @xprt: transport to disconnect
@@ -1008,6 +1024,39 @@ static void xprt_timer(struct rpc_task *task)
 		task->tk_status = 0;
 }
 
+/**
+ * xprt_request_wait_receive - wait for the reply to an RPC request
+ * @task: RPC task about to send a request
+ *
+ */
+void xprt_request_wait_receive(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (!test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate))
+		return;
+	/*
+	 * Sleep on the pending queue if we're expecting a reply.
+	 * The spinlock ensures atomicity between the test of
+	 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
+	 */
+	spin_lock(&xprt->queue_lock);
+	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
+		xprt->ops->set_retrans_timeout(task);
+		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		/*
+		 * Send an extra queue wakeup call if the
+		 * connection was dropped in case the call to
+		 * rpc_sleep_on() raced.
+		 */
+		if (xprt_request_retransmit_after_disconnect(task))
+			rpc_wake_up_queued_task_set_status(&xprt->pending,
+					task, -ENOTCONN);
+	}
+	spin_unlock(&xprt->queue_lock);
+}
+
 /**
  * xprt_prepare_transmit - reserve the transport before sending a request
  * @task: RPC task about to send a request
@@ -1027,9 +1076,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 			task->tk_status = req->rq_reply_bytes_recvd;
 			goto out_unlock;
 		}
-		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT)
-		    && xprt_connected(xprt)
-		    && req->rq_connect_cookie == xprt->connect_cookie) {
+		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
+		    !xprt_request_retransmit_after_disconnect(task)) {
 			xprt->ops->set_retrans_timeout(task);
 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
 			goto out_unlock;
@@ -1090,8 +1138,6 @@ void xprt_transmit(struct rpc_task *task)
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
-	xprt->ops->set_retrans_timeout(task);
-
 	xprt->stat.sends++;
 	xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
 	xprt->stat.bklog_u += xprt->backlog.qlen;
@@ -1100,22 +1146,6 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	req->rq_connect_cookie = connect_cookie;
-	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
-		/*
-		 * Sleep on the pending queue if we're expecting a reply.
-		 * The spinlock ensures atomicity between the test of
-		 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
-		 */
-		spin_lock(&xprt->queue_lock);
-		if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
-			rpc_sleep_on(&xprt->pending, task, xprt_timer);
-			/* Wake up immediately if the connection was dropped */
-			if (!xprt_connected(xprt))
-				rpc_wake_up_queued_task_set_status(&xprt->pending,
-						task, -ENOTCONN);
-		}
-		spin_unlock(&xprt->queue_lock);
-	}
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
@@ -1320,7 +1350,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
 	req->rq_xid	= xprt_alloc_xid(xprt);
-	req->rq_connect_cookie = xprt->connect_cookie - 1;
+	req->rq_connect_cookie = xprt_connect_cookie(xprt) - 1;
 	req->rq_bytes_sent = 0;
 	req->rq_snd_buf.len = 0;
 	req->rq_snd_buf.buflen = 0;
-- 
2.17.1
