Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:41462 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728246AbeIQSbh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:37 -0400
Received: by mail-qt0-f193.google.com with SMTP id t39-v6so15114149qtc.8
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 20/44] SUNRPC: Refactor RPC call encoding
Date: Mon, 17 Sep 2018 09:03:11 -0400
Message-Id: <20180917130335.112832-21-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-20-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the call encoding so that it occurs before the transport connection
etc.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 +
 net/sunrpc/clnt.c           | 81 ++++++++++++++++++++++---------------
 net/sunrpc/xprt.c           | 22 +++++-----
 3 files changed, 63 insertions(+), 41 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 81a6c2c8dfc7..b8a7de161f67 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -347,6 +347,7 @@ bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_receive(struct rpc_task *task);
 void			xprt_request_wait_receive(struct rpc_task *task);
+bool			xprt_request_need_retransmit(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
 void			xprt_end_transmit(struct rpc_task *task);
 int			xprt_adjust_timeout(struct rpc_rqst *req);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c1a19a3e1356..64159716be30 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -61,6 +61,7 @@ static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
 static void	call_allocate(struct rpc_task *task);
+static void	call_encode(struct rpc_task *task);
 static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
@@ -1140,7 +1141,8 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	struct xdr_buf *xbufp = &req->rq_snd_buf;
 	struct rpc_task_setup task_setup_data = {
 		.callback_ops = &rpc_default_ops,
-		.flags = RPC_TASK_SOFTCONN,
+		.flags = RPC_TASK_SOFTCONN |
+			RPC_TASK_NO_RETRANS_TIMEOUT,
 	};
 
 	dprintk("RPC: rpc_run_bc_task req= %p\n", req);
@@ -1160,7 +1162,6 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	task->tk_action = call_bc_transmit;
 	atomic_inc(&task->tk_count);
 	WARN_ON_ONCE(atomic_read(&task->tk_count) != 2);
-	xprt_request_enqueue_transmit(task);
 	rpc_execute(task);
 
 	dprintk("RPC: rpc_run_bc_task: task= %p\n", task);
@@ -1680,7 +1681,7 @@ call_allocate(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	task->tk_action = call_bind;
+	task->tk_action = call_encode;
 
 	if (req->rq_buffer)
 		return;
@@ -1724,12 +1725,12 @@ call_allocate(struct rpc_task *task)
 static int
 rpc_task_need_encode(struct rpc_task *task)
 {
-	return test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) == 0;
+	return test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) == 0 &&
+		(!(task->tk_flags & RPC_TASK_SENT) ||
+		 !(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) ||
+		 xprt_request_need_retransmit(task));
 }
 
-/*
- * 3.	Encode arguments of an RPC call
- */
 static void
 rpc_xdr_encode(struct rpc_task *task)
 {
@@ -1745,6 +1746,7 @@ rpc_xdr_encode(struct rpc_task *task)
 	xdr_buf_init(&req->rq_rcv_buf,
 		     req->rq_rbuffer,
 		     req->rq_rcvsize);
+	req->rq_bytes_sent = 0;
 
 	p = rpc_encode_header(task);
 	if (p == NULL) {
@@ -1761,6 +1763,34 @@ rpc_xdr_encode(struct rpc_task *task)
 			task->tk_msg.rpc_argp);
 }
 
+/*
+ * 3.	Encode arguments of an RPC call
+ */
+static void
+call_encode(struct rpc_task *task)
+{
+	if (!rpc_task_need_encode(task))
+		goto out;
+	/* Encode here so that rpcsec_gss can use correct sequence number. */
+	rpc_xdr_encode(task);
+	/* Did the encode result in an error condition? */
+	if (task->tk_status != 0) {
+		/* Was the error nonfatal? */
+		if (task->tk_status == -EAGAIN)
+			rpc_delay(task, HZ >> 4);
+		else
+			rpc_exit(task, task->tk_status);
+		return;
+	}
+
+	/* Add task to reply queue before transmission to avoid races */
+	if (rpc_reply_expected(task))
+		xprt_request_enqueue_receive(task);
+	xprt_request_enqueue_transmit(task);
+out:
+	task->tk_action = call_bind;
+}
+
 /*
  * 4.	Get the server port number if not yet set
  */
@@ -1945,24 +1975,8 @@ call_transmit(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
-	/* Encode here so that rpcsec_gss can use correct sequence number. */
-	if (rpc_task_need_encode(task)) {
-		rpc_xdr_encode(task);
-		/* Did the encode result in an error condition? */
-		if (task->tk_status != 0) {
-			/* Was the error nonfatal? */
-			if (task->tk_status == -EAGAIN)
-				rpc_delay(task, HZ >> 4);
-			else
-				rpc_exit(task, task->tk_status);
-			return;
-		}
-	}
-
-	/* Add task to reply queue before transmission to avoid races */
-	if (rpc_reply_expected(task))
-		xprt_request_enqueue_receive(task);
-	xprt_request_enqueue_transmit(task);
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		return;
 
 	if (!xprt_prepare_transmit(task))
 		return;
@@ -1997,9 +2011,9 @@ call_transmit_status(struct rpc_task *task)
 		xprt_end_transmit(task);
 		break;
 	case -EBADMSG:
-		task->tk_action = call_transmit;
-		task->tk_status = 0;
 		xprt_end_transmit(task);
+		task->tk_status = 0;
+		task->tk_action = call_encode;
 		break;
 		/*
 		 * Special cases: if we've been waiting on the
@@ -2048,6 +2062,9 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
+	if (rpc_task_need_encode(task))
+		xprt_request_enqueue_transmit(task);
+
 	if (!xprt_prepare_transmit(task))
 		goto out_retry;
 
@@ -2169,7 +2186,7 @@ call_status(struct rpc_task *task)
 	case -EPIPE:
 	case -ENOTCONN:
 	case -EAGAIN:
-		task->tk_action = call_bind;
+		task->tk_action = call_encode;
 		break;
 	case -EIO:
 		/* shutdown or soft timeout */
@@ -2234,7 +2251,7 @@ call_timeout(struct rpc_task *task)
 	rpcauth_invalcred(task);
 
 retry:
-	task->tk_action = call_bind;
+	task->tk_action = call_encode;
 	task->tk_status = 0;
 }
 
@@ -2278,7 +2295,7 @@ call_decode(struct rpc_task *task)
 
 	if (req->rq_rcv_buf.len < 12) {
 		if (!RPC_IS_SOFT(task)) {
-			task->tk_action = call_bind;
+			task->tk_action = call_encode;
 			goto out_retry;
 		}
 		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
@@ -2409,7 +2426,7 @@ rpc_verify_header(struct rpc_task *task)
 			task->tk_garb_retry--;
 			dprintk("RPC: %5u %s: retry garbled creds\n",
 					task->tk_pid, __func__);
-			task->tk_action = call_bind;
+			task->tk_action = call_encode;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
 			printk(KERN_NOTICE "RPC: server %s requires stronger "
@@ -2478,7 +2495,7 @@ rpc_verify_header(struct rpc_task *task)
 		task->tk_garb_retry--;
 		dprintk("RPC: %5u %s: retrying\n",
 				task->tk_pid, __func__);
-		task->tk_action = call_bind;
+		task->tk_action = call_encode;
 out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 39a6f6e8ae01..426a3a05e075 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1057,18 +1057,10 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
-static bool
-xprt_request_need_transmit(struct rpc_task *task)
-{
-	return !(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) ||
-		xprt_request_retransmit_after_disconnect(task);
-}
-
 static bool
 xprt_request_need_enqueue_transmit(struct rpc_task *task, struct rpc_rqst *req)
 {
-	return xprt_request_need_transmit(task) &&
-		!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+	return !test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 }
 
 /**
@@ -1123,6 +1115,18 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+/**
+ * xprt_request_need_retransmit - Test if a task needs retransmission
+ * @task: pointer to rpc_task
+ *
+ * Test for whether a connection breakage requires the task to retransmit
+ */
+bool
+xprt_request_need_retransmit(struct rpc_task *task)
+{
+	return xprt_request_retransmit_after_disconnect(task);
+}
+
 /**
  * xprt_prepare_transmit - reserve the transport before sending a request
  * @task: RPC task about to send a request
-- 
2.17.1
