Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f180.google.com ([209.85.222.180]:38046 "EHLO
        mail-qk1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728250AbeIQSbh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:37 -0400
Received: by mail-qk1-f180.google.com with SMTP id g197-v6so8901351qke.5
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:13 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 15/44] SUNRPC: Refactor xprt_transmit() to remove the reply queue code
Date: Mon, 17 Sep 2018 09:03:06 -0400
Message-Id: <20180917130335.112832-16-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-15-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate out the action of adding a request to the reply queue so that the
backchannel code can simply skip calling it altogether.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h       |   1 +
 net/sunrpc/backchannel_rqst.c     |   1 -
 net/sunrpc/clnt.c                 |   5 ++
 net/sunrpc/xprt.c                 | 126 +++++++++++++++++++-----------
 net/sunrpc/xprtrdma/backchannel.c |   1 -
 5 files changed, 88 insertions(+), 46 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index c25d0a5fda69..0250294c904a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -334,6 +334,7 @@ void			xprt_free_slot(struct rpc_xprt *xprt,
 				       struct rpc_rqst *req);
 void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 bool			xprt_prepare_transmit(struct rpc_task *task);
+void			xprt_request_enqueue_receive(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
 void			xprt_end_transmit(struct rpc_task *task);
 int			xprt_adjust_timeout(struct rpc_rqst *req);
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 3c15a99b9700..fa5ba6ed3197 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -91,7 +91,6 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
 		return NULL;
 
 	req->rq_xprt = xprt;
-	INIT_LIST_HEAD(&req->rq_list);
 	INIT_LIST_HEAD(&req->rq_bc_list);
 
 	/* Preallocate one XDR receive buffer */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a858366cd15d..414966273a3f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1962,6 +1962,11 @@ call_transmit(struct rpc_task *task)
 			return;
 		}
 	}
+
+	/* Add task to reply queue before transmission to avoid races */
+	if (rpc_reply_expected(task))
+		xprt_request_enqueue_receive(task);
+
 	if (!xprt_prepare_transmit(task))
 		return;
 	task->tk_action = call_transmit_status;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 6e3d4b4ee79e..d8f870b5dd46 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -888,6 +888,61 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
 	wait_var_event(&req->rq_pin, !xprt_is_pinned_rqst(req));
 }
 
+static bool
+xprt_request_data_received(struct rpc_task *task)
+{
+	return !test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
+		READ_ONCE(task->tk_rqstp->rq_reply_bytes_recvd) != 0;
+}
+
+static bool
+xprt_request_need_enqueue_receive(struct rpc_task *task, struct rpc_rqst *req)
+{
+	return !xprt_request_data_received(task);
+}
+
+/**
+ * xprt_request_enqueue_receive - Add an request to the receive queue
+ * @task: RPC task
+ *
+ */
+void
+xprt_request_enqueue_receive(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (!xprt_request_need_enqueue_receive(task, req))
+		return;
+	spin_lock(&xprt->queue_lock);
+
+	/* Update the softirq receive buffer */
+	memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
+			sizeof(req->rq_private_buf));
+
+	/* Add request to the receive list */
+	list_add_tail(&req->rq_list, &xprt->recv);
+	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
+	spin_unlock(&xprt->queue_lock);
+
+	xprt_reset_majortimeo(req);
+	/* Turn off autodisconnect */
+	del_singleshot_timer_sync(&xprt->timer);
+}
+
+/**
+ * xprt_request_dequeue_receive_locked - Remove a request from the receive queue
+ * @task: RPC task
+ *
+ * Caller must hold xprt->queue_lock.
+ */
+static void
+xprt_request_dequeue_receive_locked(struct rpc_task *task)
+{
+	if (test_and_clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate))
+		list_del(&task->tk_rqstp->rq_list);
+}
+
 /**
  * xprt_update_rtt - Update RPC RTT statistics
  * @task: RPC request that recently completed
@@ -927,24 +982,16 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
 	xprt->stat.recvs++;
 
-	list_del_init(&req->rq_list);
 	req->rq_private_buf.len = copied;
 	/* Ensure all writes are done before we update */
 	/* req->rq_reply_bytes_recvd */
 	smp_wmb();
 	req->rq_reply_bytes_recvd = copied;
-	clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
+	xprt_request_dequeue_receive_locked(task);
 	rpc_wake_up_queued_task(&xprt->pending, task);
 }
 EXPORT_SYMBOL_GPL(xprt_complete_rqst);
 
-static bool
-xprt_request_data_received(struct rpc_task *task)
-{
-	return !test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
-		task->tk_rqstp->rq_reply_bytes_recvd != 0;
-}
-
 static void xprt_timer(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
@@ -1018,32 +1065,15 @@ void xprt_transmit(struct rpc_task *task)
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
-	if (!req->rq_reply_bytes_recvd) {
-
+	if (!req->rq_bytes_sent) {
+		if (xprt_request_data_received(task))
+			return;
 		/* Verify that our message lies in the RPCSEC_GSS window */
-		if (!req->rq_bytes_sent && rpcauth_xmit_need_reencode(task)) {
+		if (rpcauth_xmit_need_reencode(task)) {
 			task->tk_status = -EBADMSG;
 			return;
 		}
-
-		if (list_empty(&req->rq_list) && rpc_reply_expected(task)) {
-			/*
-			 * Add to the list only if we're expecting a reply
-			 */
-			/* Update the softirq receive buffer */
-			memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
-					sizeof(req->rq_private_buf));
-			/* Add request to the receive list */
-			spin_lock(&xprt->queue_lock);
-			list_add_tail(&req->rq_list, &xprt->recv);
-			set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
-			spin_unlock(&xprt->queue_lock);
-			xprt_reset_majortimeo(req);
-			/* Turn off autodisconnect */
-			del_singleshot_timer_sync(&xprt->timer);
-		}
-	} else if (xprt_request_data_received(task) && !req->rq_bytes_sent)
-		return;
+	}
 
 	connect_cookie = xprt->connect_cookie;
 	status = xprt->ops->send_request(task);
@@ -1285,7 +1315,6 @@ xprt_request_init(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_rqst	*req = task->tk_rqstp;
 
-	INIT_LIST_HEAD(&req->rq_list);
 	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
@@ -1355,6 +1384,26 @@ void xprt_retry_reserve(struct rpc_task *task)
 	xprt_do_reserve(xprt, task);
 }
 
+static void
+xprt_request_dequeue_all(struct rpc_task *task, struct rpc_rqst *req)
+{
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) ||
+	    xprt_is_pinned_rqst(req)) {
+		spin_lock(&xprt->queue_lock);
+		xprt_request_dequeue_receive_locked(task);
+		while (xprt_is_pinned_rqst(req)) {
+			set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+			spin_unlock(&xprt->queue_lock);
+			xprt_wait_on_pinned_rqst(req);
+			spin_lock(&xprt->queue_lock);
+			clear_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+		}
+		spin_unlock(&xprt->queue_lock);
+	}
+}
+
 /**
  * xprt_release - release an RPC request slot
  * @task: task which is finished with the slot
@@ -1379,18 +1428,7 @@ void xprt_release(struct rpc_task *task)
 		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
 	else if (task->tk_client)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
-	spin_lock(&xprt->queue_lock);
-	if (!list_empty(&req->rq_list)) {
-		list_del_init(&req->rq_list);
-		if (xprt_is_pinned_rqst(req)) {
-			set_bit(RPC_TASK_MSG_PIN_WAIT, &req->rq_task->tk_runstate);
-			spin_unlock(&xprt->queue_lock);
-			xprt_wait_on_pinned_rqst(req);
-			spin_lock(&xprt->queue_lock);
-			clear_bit(RPC_TASK_MSG_PIN_WAIT, &req->rq_task->tk_runstate);
-		}
-	}
-	spin_unlock(&xprt->queue_lock);
+	xprt_request_dequeue_all(task, req);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 90adeff4c06b..ed58761e6b23 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -51,7 +51,6 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		rqst = &req->rl_slot;
 
 		rqst->rq_xprt = xprt;
-		INIT_LIST_HEAD(&rqst->rq_list);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
 		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 		spin_lock_bh(&xprt->bc_pa_lock);
-- 
2.17.1
