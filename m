Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f194.google.com ([209.85.222.194]:32937 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727864AbeIQSbR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:17 -0400
Received: by mail-qk1-f194.google.com with SMTP id z78-v6so8931399qka.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:02 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/44] SUNRPC: Simplify identification of when the message send/receive is complete
Date: Mon, 17 Sep 2018 09:02:55 -0400
Message-Id: <20180917130335.112832-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-4-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add states to indicate that the message send and receive are not yet
complete.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |  6 ++++--
 net/sunrpc/clnt.c            | 19 +++++++------------
 net/sunrpc/xprt.c            | 17 ++++++++++++++---
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 592653becd91..9e655df70131 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -140,8 +140,10 @@ struct rpc_task_setup {
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
 #define RPC_TASK_ACTIVE		2
-#define RPC_TASK_MSG_RECV	3
-#define RPC_TASK_MSG_RECV_WAIT	4
+#define RPC_TASK_NEED_XMIT	3
+#define RPC_TASK_NEED_RECV	4
+#define RPC_TASK_MSG_RECV	5
+#define RPC_TASK_MSG_RECV_WAIT	6
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d41b5ac1d4e8..e5ac35e803ad 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1156,6 +1156,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	 */
 	xbufp->len = xbufp->head[0].iov_len + xbufp->page_len +
 			xbufp->tail[0].iov_len;
+	set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 
 	task->tk_action = call_bc_transmit;
 	atomic_inc(&task->tk_count);
@@ -1720,17 +1721,10 @@ call_allocate(struct rpc_task *task)
 	rpc_exit(task, -ERESTARTSYS);
 }
 
-static inline int
+static int
 rpc_task_need_encode(struct rpc_task *task)
 {
-	return task->tk_rqstp->rq_snd_buf.len == 0;
-}
-
-static inline void
-rpc_task_force_reencode(struct rpc_task *task)
-{
-	task->tk_rqstp->rq_snd_buf.len = 0;
-	task->tk_rqstp->rq_bytes_sent = 0;
+	return test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) == 0;
 }
 
 /*
@@ -1765,6 +1759,8 @@ rpc_xdr_encode(struct rpc_task *task)
 
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
+	if (task->tk_status == 0)
+		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 }
 
 /*
@@ -1999,7 +1995,6 @@ call_transmit_status(struct rpc_task *task)
 	 */
 	if (task->tk_status == 0) {
 		xprt_end_transmit(task);
-		rpc_task_force_reencode(task);
 		return;
 	}
 
@@ -2010,7 +2005,6 @@ call_transmit_status(struct rpc_task *task)
 	default:
 		dprint_status(task);
 		xprt_end_transmit(task);
-		rpc_task_force_reencode(task);
 		break;
 		/*
 		 * Special cases: if we've been waiting on the
@@ -2038,7 +2032,7 @@ call_transmit_status(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOTCONN:
 	case -EPIPE:
-		rpc_task_force_reencode(task);
+		break;
 	}
 }
 
@@ -2185,6 +2179,7 @@ call_status(struct rpc_task *task)
 		rpc_exit(task, status);
 		break;
 	case -EBADMSG:
+		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 		task->tk_action = call_transmit;
 		break;
 	default:
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3973e10ea2bd..45d580cd93ac 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -936,10 +936,18 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 	/* req->rq_reply_bytes_recvd */
 	smp_wmb();
 	req->rq_reply_bytes_recvd = copied;
+	clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	rpc_wake_up_queued_task(&xprt->pending, task);
 }
 EXPORT_SYMBOL_GPL(xprt_complete_rqst);
 
+static bool
+xprt_request_data_received(struct rpc_task *task)
+{
+	return !test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
+		task->tk_rqstp->rq_reply_bytes_recvd != 0;
+}
+
 static void xprt_timer(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
@@ -1031,12 +1039,13 @@ void xprt_transmit(struct rpc_task *task)
 			/* Add request to the receive list */
 			spin_lock(&xprt->recv_lock);
 			list_add_tail(&req->rq_list, &xprt->recv);
+			set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 			spin_unlock(&xprt->recv_lock);
 			xprt_reset_majortimeo(req);
 			/* Turn off autodisconnect */
 			del_singleshot_timer_sync(&xprt->timer);
 		}
-	} else if (!req->rq_bytes_sent)
+	} else if (xprt_request_data_received(task) && !req->rq_bytes_sent)
 		return;
 
 	connect_cookie = xprt->connect_cookie;
@@ -1046,9 +1055,11 @@ void xprt_transmit(struct rpc_task *task)
 		task->tk_status = status;
 		return;
 	}
+
 	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
+	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
@@ -1062,14 +1073,14 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	req->rq_connect_cookie = connect_cookie;
-	if (rpc_reply_expected(task) && !READ_ONCE(req->rq_reply_bytes_recvd)) {
+	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 		/*
 		 * Sleep on the pending queue if we're expecting a reply.
 		 * The spinlock ensures atomicity between the test of
 		 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
 		 */
 		spin_lock(&xprt->recv_lock);
-		if (!req->rq_reply_bytes_recvd) {
+		if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
 			/*
 			 * Send an extra queue wakeup call if the
-- 
2.17.1
