Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33702 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727430AbeICTu5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:57 -0400
Received: by mail-it0-f67.google.com with SMTP id j198-v6so11552639ita.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:17 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:15 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/27] NFS: Add a transmission queue for RPC requests
Date: Mon,  3 Sep 2018 11:29:27 -0400
Message-Id: <20180903152936.24325-19-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-18-trond.myklebust@hammerspace.com>
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
 <20180903152936.24325-16-trond.myklebust@hammerspace.com>
 <20180903152936.24325-17-trond.myklebust@hammerspace.com>
 <20180903152936.24325-18-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h       |  6 +++
 net/sunrpc/backchannel_rqst.c     |  1 +
 net/sunrpc/clnt.c                 |  6 +--
 net/sunrpc/xprt.c                 | 74 +++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/backchannel.c |  1 +
 5 files changed, 77 insertions(+), 11 deletions(-)

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
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 92e9ad30ec2f..39b394b7dae3 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -92,6 +92,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
 
 	req->rq_xprt = xprt;
 	INIT_LIST_HEAD(&req->rq_recv);
+	INIT_LIST_HEAD(&req->rq_xmit);
 	INIT_LIST_HEAD(&req->rq_bc_list);
 
 	/* Preallocate one XDR receive buffer */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5fbd9875544e..a817f70d6192 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1759,8 +1759,6 @@ rpc_xdr_encode(struct rpc_task *task)
 
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
-	if (task->tk_status == 0)
-		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 }
 
 /*
@@ -1959,11 +1957,13 @@ call_transmit(struct rpc_task *task)
 				rpc_exit(task, task->tk_status);
 			return;
 		}
+		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 	}
 
 	/* Add task to reply queue before transmission to avoid races */
 	if (rpc_reply_expected(task))
 		xprt_request_enqueue_receive(task);
+	xprt_request_enqueue_transmit(task);
 
 	if (!xprt_prepare_transmit(task))
 		return;
@@ -1998,7 +1998,6 @@ call_transmit_status(struct rpc_task *task)
 		xprt_end_transmit(task);
 		break;
 	case -EBADMSG:
-		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 		task->tk_action = call_transmit;
 		xprt_end_transmit(task);
 		break;
@@ -2049,6 +2048,7 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
+	xprt_request_enqueue_transmit(task);
 	if (!xprt_prepare_transmit(task))
 		goto out_retry;
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 0184a6aed7e3..defc6167570a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1049,6 +1049,64 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+static bool
+xprt_request_need_transmit(struct rpc_task *task)
+{
+	return !(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) ||
+		xprt_request_retransmit_after_disconnect(task);
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
+	spin_lock(&xprt->queue_lock);
+	if (list_empty(&req->rq_xmit) && xprt_request_need_transmit(task) &&
+	    test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
+	spin_unlock(&xprt->queue_lock);
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
+	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+	list_del_init(&task->tk_rqstp->rq_xmit);
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
@@ -1068,12 +1126,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
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
@@ -1107,11 +1161,11 @@ void xprt_transmit(struct rpc_task *task)
 
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
 
@@ -1126,7 +1180,6 @@ void xprt_transmit(struct rpc_task *task)
 	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
-	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
@@ -1138,6 +1191,8 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	req->rq_connect_cookie = connect_cookie;
+out_dequeue:
+	xprt_request_dequeue_transmit(task);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
@@ -1338,6 +1393,7 @@ xprt_request_init(struct rpc_task *task)
 	struct rpc_rqst	*req = task->tk_rqstp;
 
 	INIT_LIST_HEAD(&req->rq_recv);
+	INIT_LIST_HEAD(&req->rq_xmit);
 	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
@@ -1433,6 +1489,7 @@ void xprt_release(struct rpc_task *task)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
 	spin_lock(&xprt->queue_lock);
 	xprt_request_dequeue_receive_locked(task);
+	xprt_request_dequeue_transmit_locked(task);
 	while (xprt_is_pinned_rqst(req)) {
 		spin_unlock(&xprt->queue_lock);
 		xprt_wait_on_pinned_rqst(req);
@@ -1472,6 +1529,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv_queue);
+	INIT_LIST_HEAD(&xprt->xmit_queue);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 40c7c7306a99..fc01fdabbbce 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -52,6 +52,7 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 
 		rqst->rq_xprt = xprt;
 		INIT_LIST_HEAD(&rqst->rq_recv);
+		INIT_LIST_HEAD(&rqst->rq_xmit);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
 		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 		spin_lock_bh(&xprt->bc_pa_lock);
-- 
2.17.1
