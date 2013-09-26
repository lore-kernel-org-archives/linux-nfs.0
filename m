Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643Ab3IZVpV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/7] SUNRPC: Don't set the request connect_cookie until a successful transmit
Date: Thu, 26 Sep 2013 17:45:02 -0400
Message-ID: <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're using the request connect_cookie to track whether or not a
request was successfully transmitted on the current transport
connection or not. For that reason we should ensure that it is
only set after we've successfully transmitted the request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprt.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 095363e..e9ee7bf 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -912,7 +912,6 @@ void xprt_transmit(struct rpc_task *task)
 	} else if (!req->rq_bytes_sent)
 		return;
 
-	req->rq_connect_cookie = xprt->connect_cookie;
 	req->rq_xtime = ktime_get();
 	status = xprt->ops->send_request(task);
 	if (status != 0) {
@@ -938,12 +937,14 @@ void xprt_transmit(struct rpc_task *task)
 	/* Don't race with disconnect */
 	if (!xprt_connected(xprt))
 		task->tk_status = -ENOTCONN;
-	else if (!req->rq_reply_bytes_recvd && rpc_reply_expected(task)) {
+	else {
 		/*
 		 * Sleep on the pending queue since
 		 * we're expecting a reply.
 		 */
-		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		if (!req->rq_reply_bytes_recvd && rpc_reply_expected(task))
+			rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		req->rq_connect_cookie = xprt->connect_cookie;
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -1186,6 +1187,7 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
 	req->rq_xid     = xprt_alloc_xid(xprt);
+	req->rq_connect_cookie = xprt->connect_cookie - 1;
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
-- 
1.8.3.1

