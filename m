Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:51018 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725879AbeIEBdO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:14 -0400
Received: by mail-it0-f42.google.com with SMTP id j81-v6so7042381ite.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:21 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/34] SUNRPC: Refactor xprt_transmit() to remove the reply queue code
Date: Tue,  4 Sep 2018 17:05:29 -0400
Message-Id: <20180904210549.81673-15-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-14-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate out the action of adding a request to the reply queue so that the
backchannel code can simply skip calling it altogether.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |   1 +
 net/sunrpc/clnt.c           |   5 ++
 net/sunrpc/xprt.c           | 100 ++++++++++++++++++++++--------------
 3 files changed, 68 insertions(+), 38 deletions(-)

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
index eda305de9f77..6a5f2dbdc00f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -884,6 +884,57 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
 	wait_var_event(&req->rq_pin, !xprt_is_pinned_rqst(req));
 }
 
+static bool
+xprt_request_data_received(struct rpc_task *task)
+{
+	return !test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
+		READ_ONCE(task->tk_rqstp->rq_reply_bytes_recvd) != 0;
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
+	spin_lock(&xprt->queue_lock);
+	if (xprt_request_data_received(task) || !list_empty(&req->rq_list)) {
+		spin_unlock(&xprt->queue_lock);
+		return;
+	}
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
+	clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
+	list_del_init(&task->tk_rqstp->rq_list);
+}
+
 /**
  * xprt_update_rtt - Update RPC RTT statistics
  * @task: RPC request that recently completed
@@ -923,24 +974,16 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
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
@@ -1014,32 +1057,15 @@ void xprt_transmit(struct rpc_task *task)
 
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
@@ -1376,13 +1402,11 @@ void xprt_release(struct rpc_task *task)
 	else if (task->tk_client)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
 	spin_lock(&xprt->queue_lock);
-	if (!list_empty(&req->rq_list)) {
-		list_del_init(&req->rq_list);
-		if (atomic_read(&req->rq_pin)) {
-			spin_unlock(&xprt->queue_lock);
-			xprt_wait_on_pinned_rqst(req);
-			spin_lock(&xprt->queue_lock);
-		}
+	xprt_request_dequeue_receive_locked(task);
+	while (xprt_is_pinned_rqst(req)) {
+		spin_unlock(&xprt->queue_lock);
+		xprt_wait_on_pinned_rqst(req);
+		spin_lock(&xprt->queue_lock);
 	}
 	spin_unlock(&xprt->queue_lock);
 	spin_lock_bh(&xprt->transport_lock);
-- 
2.17.1
