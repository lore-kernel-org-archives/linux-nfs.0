Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:40250 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:36 -0400
Received: by mail-qt0-f196.google.com with SMTP id h4-v6so15112785qtj.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:20 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:18 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 19/44] SUNRPC: Add a transmission queue for RPC requests
Date: Mon, 17 Sep 2018 09:03:10 -0400
Message-Id: <20180917130335.112832-20-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-19-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the queue that will enforce the ordering of RPC task transmission.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  6 +++
 net/sunrpc/clnt.c           |  6 +--
 net/sunrpc/xprt.c           | 84 +++++++++++++++++++++++++++++++++----
 3 files changed, 83 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 9cec2d0811f2..81a6c2c8dfc7 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -88,6 +88,8 @@ struct rpc_rqst {
 		struct list_head	rq_recv;	/* Receive queue */
 	};
 
+	struct list_head	rq_xmit;	/* Send queue */
+
 	void			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
 	void			*rq_rbuffer;	/* Reply XDR decode buffer */
@@ -242,6 +244,9 @@ struct rpc_xprt {
 	spinlock_t		queue_lock;	/* send/receive queue lock */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
+
+	struct list_head	xmit_queue;	/* Send queue */
+
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct svc_serv		*bc_serv;       /* The RPC service which will */
@@ -339,6 +344,7 @@ void			xprt_free_slot(struct rpc_xprt *xprt,
 				       struct rpc_rqst *req);
 void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 bool			xprt_prepare_transmit(struct rpc_task *task);
+void			xprt_request_enqueue_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_receive(struct rpc_task *task);
 void			xprt_request_wait_receive(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index be0f06a8156b..c1a19a3e1356 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1156,11 +1156,11 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	 */
 	xbufp->len = xbufp->head[0].iov_len + xbufp->page_len +
 			xbufp->tail[0].iov_len;
-	set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 
 	task->tk_action = call_bc_transmit;
 	atomic_inc(&task->tk_count);
 	WARN_ON_ONCE(atomic_read(&task->tk_count) != 2);
+	xprt_request_enqueue_transmit(task);
 	rpc_execute(task);
 
 	dprintk("RPC: rpc_run_bc_task: task= %p\n", task);
@@ -1759,8 +1759,6 @@ rpc_xdr_encode(struct rpc_task *task)
 
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
-	if (task->tk_status == 0)
-		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 }
 
 /*
@@ -1964,6 +1962,7 @@ call_transmit(struct rpc_task *task)
 	/* Add task to reply queue before transmission to avoid races */
 	if (rpc_reply_expected(task))
 		xprt_request_enqueue_receive(task);
+	xprt_request_enqueue_transmit(task);
 
 	if (!xprt_prepare_transmit(task))
 		return;
@@ -1998,7 +1997,6 @@ call_transmit_status(struct rpc_task *task)
 		xprt_end_transmit(task);
 		break;
 	case -EBADMSG:
-		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 		task->tk_action = call_transmit;
 		task->tk_status = 0;
 		xprt_end_transmit(task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b242a1c78f8a..39a6f6e8ae01 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1057,6 +1057,72 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+static bool
+xprt_request_need_transmit(struct rpc_task *task)
+{
+	return !(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) ||
+		xprt_request_retransmit_after_disconnect(task);
+}
+
+static bool
+xprt_request_need_enqueue_transmit(struct rpc_task *task, struct rpc_rqst *req)
+{
+	return xprt_request_need_transmit(task) &&
+		!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+}
+
+/**
+ * xprt_request_enqueue_transmit - queue a task for transmission
+ * @task: pointer to rpc_task
+ *
+ * Add a task to the transmission queue.
+ */
+void
+xprt_request_enqueue_transmit(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (xprt_request_need_enqueue_transmit(task, req)) {
+		spin_lock(&xprt->queue_lock);
+		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
+		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+		spin_unlock(&xprt->queue_lock);
+	}
+}
+
+/**
+ * xprt_request_dequeue_transmit_locked - remove a task from the transmission queue
+ * @task: pointer to rpc_task
+ *
+ * Remove a task from the transmission queue
+ * Caller must hold xprt->queue_lock
+ */
+static void
+xprt_request_dequeue_transmit_locked(struct rpc_task *task)
+{
+	xprt_task_clear_bytes_sent(task);
+	if (test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		list_del(&task->tk_rqstp->rq_xmit);
+}
+
+/**
+ * xprt_request_dequeue_transmit - remove a task from the transmission queue
+ * @task: pointer to rpc_task
+ *
+ * Remove a task from the transmission queue
+ */
+static void
+xprt_request_dequeue_transmit(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	spin_lock(&xprt->queue_lock);
+	xprt_request_dequeue_transmit_locked(task);
+	spin_unlock(&xprt->queue_lock);
+}
+
 /**
  * xprt_prepare_transmit - reserve the transport before sending a request
  * @task: RPC task about to send a request
@@ -1076,12 +1142,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 			task->tk_status = req->rq_reply_bytes_recvd;
 			goto out_unlock;
 		}
-		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
-		    !xprt_request_retransmit_after_disconnect(task)) {
-			xprt->ops->set_retrans_timeout(task);
-			rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
 			goto out_unlock;
-		}
 	}
 	if (!xprt->ops->reserve_xprt(xprt, task)) {
 		task->tk_status = -EAGAIN;
@@ -1115,11 +1177,11 @@ void xprt_transmit(struct rpc_task *task)
 
 	if (!req->rq_bytes_sent) {
 		if (xprt_request_data_received(task))
-			return;
+			goto out_dequeue;
 		/* Verify that our message lies in the RPCSEC_GSS window */
 		if (rpcauth_xmit_need_reencode(task)) {
 			task->tk_status = -EBADMSG;
-			return;
+			goto out_dequeue;
 		}
 	}
 
@@ -1134,7 +1196,6 @@ void xprt_transmit(struct rpc_task *task)
 	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
-	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
@@ -1146,6 +1207,8 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	req->rq_connect_cookie = connect_cookie;
+out_dequeue:
+	xprt_request_dequeue_transmit(task);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
@@ -1419,9 +1482,11 @@ xprt_request_dequeue_all(struct rpc_task *task, struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
 
-	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) ||
+	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) ||
+	    test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) ||
 	    xprt_is_pinned_rqst(req)) {
 		spin_lock(&xprt->queue_lock);
+		xprt_request_dequeue_transmit_locked(task);
 		xprt_request_dequeue_receive_locked(task);
 		while (xprt_is_pinned_rqst(req)) {
 			set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
@@ -1492,6 +1557,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv_queue);
+	INIT_LIST_HEAD(&xprt->xmit_queue);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
-- 
2.17.1
