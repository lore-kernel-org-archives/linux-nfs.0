Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38036 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752162AbdLDARc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 19:17:32 -0500
Received: by mail-it0-f66.google.com with SMTP id r6so2647501itr.3
        for <linux-nfs@vger.kernel.org>; Sun, 03 Dec 2017 16:17:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracl.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3] SUNRPC: Fix a race in the receive code path
Date: Sun,  3 Dec 2017 19:17:26 -0500
Message-Id: <20171204001726.5747-1-trond.myklebust@primarydata.com>
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
 net/sunrpc/xprt.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 333b9d697ae5..5e4278e9ce37 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1024,6 +1024,7 @@ void xprt_transmit(struct rpc_task *task)
 	} else if (!req->rq_bytes_sent)
 		return;
 
+	req->rq_connect_cookie = xprt->connect_cookie;
 	req->rq_xtime = ktime_get();
 	status = xprt->ops->send_request(task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
@@ -1047,20 +1048,27 @@ void xprt_transmit(struct rpc_task *task)
 	xprt->stat.bklog_u += xprt->backlog.qlen;
 	xprt->stat.sending_u += xprt->sending.qlen;
 	xprt->stat.pending_u += xprt->pending.qlen;
+	spin_unlock_bh(&xprt->transport_lock);
 
-	/* Don't race with disconnect */
-	if (!xprt_connected(xprt))
-		task->tk_status = -ENOTCONN;
-	else {
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

