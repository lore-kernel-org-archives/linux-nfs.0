Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36619 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726999AbeIEBdX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:23 -0400
Received: by mail-it0-f66.google.com with SMTP id u13-v6so6717246iti.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:32 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 27/34] SUNRPC: Allow calls to xprt_transmit() to drain the entire transmit queue
Date: Tue,  4 Sep 2018 17:05:42 -0400
Message-Id: <20180904210549.81673-28-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-27-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than forcing each and every RPC task to grab the socket write
lock in order to send itself, we allow whichever task is holding the
write lock to attempt to drain the entire transmit queue.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 79 +++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 66 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8a4c5260eecd..ba9af25d14de 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1139,15 +1139,20 @@ void xprt_end_transmit(struct rpc_task *task)
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
@@ -1155,11 +1160,13 @@ void xprt_transmit(struct rpc_task *task)
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
@@ -1167,12 +1174,10 @@ void xprt_transmit(struct rpc_task *task)
 	req->rq_ntrans++;
 
 	connect_cookie = xprt->connect_cookie;
-	status = xprt->ops->send_request(req, task);
+	status = xprt->ops->send_request(req, snd_task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
-	if (status != 0) {
-		task->tk_status = status;
-		return;
-	}
+	if (status != 0)
+		return status;
 
 	if (is_retrans)
 		task->tk_client->cl_stats->rpcretrans++;
@@ -1193,6 +1198,54 @@ void xprt_transmit(struct rpc_task *task)
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
+	LIST_HEAD(head);
+	int status;
+
+	task->tk_status = -EAGAIN;
+	spin_lock(&xprt->queue_lock);
+	/* Avoid livelock by moving the xmit_queue contents to a private list */
+	list_splice_init(&xprt->xmit_queue, &head);
+	while (!list_empty(&head)) {
+		next = list_first_entry(&head, struct rpc_rqst, rq_xmit);
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
+		/* On early exit, splice back the list contents */
+		list_splice(&head, &xprt->xmit_queue);
+		break;
+	}
+	spin_unlock(&xprt->queue_lock);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
-- 
2.17.1
