Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39029 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727405AbeICTux (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:53 -0400
Received: by mail-io0-f194.google.com with SMTP id l7-v6so687513iok.6
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:13 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:12 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/27] SUNRPC: Refactor xprt_transmit() to remove wait for reply code
Date: Mon,  3 Sep 2018 11:29:24 -0400
Message-Id: <20180903152936.24325-16-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-15-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
 <20180903152936.24325-14-trond.myklebust@hammerspace.com>
 <20180903152936.24325-15-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the caller in clnt.c to call into the code to wait for a reply
after calling xprt_transmit(). Again, the reason is that the backchannel
code does not need this functionality.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 +
 net/sunrpc/clnt.c           | 10 +-----
 net/sunrpc/xprt.c           | 72 ++++++++++++++++++++++++++-----------
 3 files changed, 53 insertions(+), 30 deletions(-)

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
index 3d6d1b5f9e81..cf09aab11014 100644
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
index cb3c0f7d5b3d..aefa23c90a2b 100644
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
@@ -1000,6 +1016,39 @@ static void xprt_timer(struct rpc_task *task)
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
@@ -1019,9 +1068,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
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
@@ -1082,8 +1130,6 @@ void xprt_transmit(struct rpc_task *task)
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
-	xprt->ops->set_retrans_timeout(task);
-
 	xprt->stat.sends++;
 	xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
 	xprt->stat.bklog_u += xprt->backlog.qlen;
@@ -1092,22 +1138,6 @@ void xprt_transmit(struct rpc_task *task)
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
-- 
2.17.1
