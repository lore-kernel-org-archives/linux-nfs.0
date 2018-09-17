Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:42667 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728299AbeIQSbr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:47 -0400
Received: by mail-qk1-f193.google.com with SMTP id g13-v6so8900525qki.9
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:31 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 29/44] SUNRPC: Allow calls to xprt_transmit() to drain the entire transmit queue
Date: Mon, 17 Sep 2018 09:03:20 -0400
Message-Id: <20180917130335.112832-30-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-29-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than forcing each and every RPC task to grab the socket write
lock in order to send itself, we allow whichever task is holding the
write lock to attempt to drain the entire transmit queue.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 71 +++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 60 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 68974966b2e4..ae1109c7b9b4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1223,15 +1223,20 @@ void xprt_end_transmit(struct rpc_task *task)
 }
 
 /**
- * xprt_transmit - send an RPC request on a transport
- * @task: controlling RPC task
+ * xprt_request_transmit - send an RPC request on a transport
+ * @req: pointer to request to transmit
+ * @snd_task: RPC task that owns the transport lock
  *
- * We have to copy the iovec because sendmsg fiddles with its contents.
+ * This performs the transmission of a single request.
+ * Note that if the request is not the same as snd_task, then it
+ * does need to be pinned.
+ * Returns '0' on success.
  */
-void xprt_transmit(struct rpc_task *task)
+static int
+xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 {
-	struct rpc_rqst	*req = task->tk_rqstp;
-	struct rpc_xprt	*xprt = req->rq_xprt;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct rpc_task *task = req->rq_task;
 	unsigned int connect_cookie;
 	int is_retrans = RPC_WAS_SENT(task);
 	int status;
@@ -1239,11 +1244,13 @@ void xprt_transmit(struct rpc_task *task)
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
 	if (!req->rq_bytes_sent) {
-		if (xprt_request_data_received(task))
+		if (xprt_request_data_received(task)) {
+			status = 0;
 			goto out_dequeue;
+		}
 		/* Verify that our message lies in the RPCSEC_GSS window */
 		if (rpcauth_xmit_need_reencode(task)) {
-			task->tk_status = -EBADMSG;
+			status = -EBADMSG;
 			goto out_dequeue;
 		}
 	}
@@ -1256,12 +1263,11 @@ void xprt_transmit(struct rpc_task *task)
 	req->rq_ntrans++;
 
 	connect_cookie = xprt->connect_cookie;
-	status = xprt->ops->send_request(req, task);
+	status = xprt->ops->send_request(req, snd_task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
 		req->rq_ntrans--;
-		task->tk_status = status;
-		return;
+		return status;
 	}
 
 	if (is_retrans)
@@ -1283,6 +1289,49 @@ void xprt_transmit(struct rpc_task *task)
 	req->rq_connect_cookie = connect_cookie;
 out_dequeue:
 	xprt_request_dequeue_transmit(task);
+	rpc_wake_up_queued_task_set_status(&xprt->sending, task, status);
+	return status;
+}
+
+/**
+ * xprt_transmit - send an RPC request on a transport
+ * @task: controlling RPC task
+ *
+ * Attempts to drain the transmit queue. On exit, either the transport
+ * signalled an error that needs to be handled before transmission can
+ * resume, or @task finished transmitting, and detected that it already
+ * received a reply.
+ */
+void
+xprt_transmit(struct rpc_task *task)
+{
+	struct rpc_rqst *next, *req = task->tk_rqstp;
+	struct rpc_xprt	*xprt = req->rq_xprt;
+	int status;
+
+	spin_lock(&xprt->queue_lock);
+	while (!list_empty(&xprt->xmit_queue)) {
+		next = list_first_entry(&xprt->xmit_queue,
+				struct rpc_rqst, rq_xmit);
+		xprt_pin_rqst(next);
+		spin_unlock(&xprt->queue_lock);
+		status = xprt_request_transmit(next, task);
+		if (status == -EBADMSG && next != req)
+			status = 0;
+		cond_resched();
+		spin_lock(&xprt->queue_lock);
+		xprt_unpin_rqst(next);
+		if (status == 0) {
+			if (!xprt_request_data_received(task) ||
+			    test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+				continue;
+		} else if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+			rpc_wake_up_queued_task(&xprt->pending, task);
+		else
+			task->tk_status = status;
+		break;
+	}
+	spin_unlock(&xprt->queue_lock);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
-- 
2.17.1
