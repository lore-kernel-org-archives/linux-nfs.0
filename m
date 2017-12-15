Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:44471 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754594AbdLOCYO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 21:24:14 -0500
Received: by mail-it0-f66.google.com with SMTP id b5so16140791itc.3
        for <linux-nfs@vger.kernel.org>; Thu, 14 Dec 2017 18:24:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@NetApp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Fix a race in the receive code path
Date: Thu, 14 Dec 2017 21:24:08 -0500
Message-Id: <20171215022408.4874-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must ensure that the call to rpc_sleep_on() in xprt_transmit() cannot
race with the call to xprt_complete_rqst().

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=317
Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
Cc: stable@vger.kernel.org # 4.14+
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 333b9d697ae5..33b74fd84051 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1001,6 +1001,7 @@ void xprt_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
+	unsigned int connect_cookie;
 	int status, numreqs;
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
@@ -1024,6 +1025,7 @@ void xprt_transmit(struct rpc_task *task)
 	} else if (!req->rq_bytes_sent)
 		return;
 
+	connect_cookie = xprt->connect_cookie;
 	req->rq_xtime = ktime_get();
 	status = xprt->ops->send_request(task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
@@ -1047,20 +1049,28 @@ void xprt_transmit(struct rpc_task *task)
 	xprt->stat.bklog_u += xprt->backlog.qlen;
 	xprt->stat.sending_u += xprt->sending.qlen;
 	xprt->stat.pending_u += xprt->pending.qlen;
+	spin_unlock_bh(&xprt->transport_lock);
 
-	/* Don't race with disconnect */
-	if (!xprt_connected(xprt))
-		task->tk_status = -ENOTCONN;
-	else {
+	req->rq_connect_cookie = connect_cookie;
+	if (rpc_reply_expected(task) && !READ_ONCE(req->rq_reply_bytes_recvd)) {
 		/*
-		 * Sleep on the pending queue since
-		 * we're expecting a reply.
+		 * Sleep on the pending queue if we're expecting a reply.
+		 * The spinlock ensures atomicity between the test of
+		 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
 		 */
-		if (!req->rq_reply_bytes_recvd && rpc_reply_expected(task))
+		spin_lock(&xprt->recv_lock);
+		if (!req->rq_reply_bytes_recvd) {
 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
-		req->rq_connect_cookie = xprt->connect_cookie;
+			/*
+			 * Send an extra queue wakeup call if the
+			 * connection was dropped in case the call to
+			 * rpc_sleep_on() raced.
+			 */
+			if (!xprt_connected(xprt))
+				xprt_wake_pending_tasks(xprt, -ENOTCONN);
+		}
+		spin_unlock(&xprt->recv_lock);
 	}
-	spin_unlock_bh(&xprt->transport_lock);
 }
 
 static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task *task)
-- 
2.14.3

