Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:51660 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725825AbeIEBdT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:19 -0400
Received: by mail-it0-f66.google.com with SMTP id e14-v6so7032931itf.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:27 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 21/34] SUNRPC: Don't reset the request 'bytes_sent' counter when releasing XPRT_LOCK
Date: Tue,  4 Sep 2018 17:05:36 -0400
Message-Id: <20180904210549.81673-22-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-21-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the request is still on the queue, this will be incorrect behaviour.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c |  4 ----
 net/sunrpc/xprt.c | 14 --------------
 2 files changed, 18 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 497a30762a6d..032b7042adb6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2132,15 +2132,11 @@ static void
 call_status(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
-	struct rpc_rqst	*req = task->tk_rqstp;
 	int		status;
 
 	if (!task->tk_msg.rpc_proc->p_proc)
 		trace_xprt_ping(task->tk_xprt, task->tk_status);
 
-	if (req->rq_reply_bytes_recvd > 0 && !req->rq_bytes_sent)
-		task->tk_status = req->rq_reply_bytes_recvd;
-
 	dprint_status(task);
 
 	status = task->tk_status;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 7c80f93562e5..305aa9570873 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -332,15 +332,6 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 	xprt_clear_locked(xprt);
 }
 
-static void xprt_task_clear_bytes_sent(struct rpc_task *task)
-{
-	if (task != NULL) {
-		struct rpc_rqst *req = task->tk_rqstp;
-		if (req != NULL)
-			req->rq_bytes_sent = 0;
-	}
-}
-
 /**
  * xprt_release_xprt - allow other requests to use a transport
  * @xprt: transport with other tasks potentially waiting
@@ -351,7 +342,6 @@ static void xprt_task_clear_bytes_sent(struct rpc_task *task)
 void xprt_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	if (xprt->snd_task == task) {
-		xprt_task_clear_bytes_sent(task);
 		xprt_clear_locked(xprt);
 		__xprt_lock_write_next(xprt);
 	}
@@ -369,7 +359,6 @@ EXPORT_SYMBOL_GPL(xprt_release_xprt);
 void xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	if (xprt->snd_task == task) {
-		xprt_task_clear_bytes_sent(task);
 		xprt_clear_locked(xprt);
 		__xprt_lock_write_next_cong(xprt);
 	}
@@ -742,7 +731,6 @@ bool xprt_lock_connect(struct rpc_xprt *xprt,
 		goto out;
 	if (xprt->snd_task != task)
 		goto out;
-	xprt_task_clear_bytes_sent(task);
 	xprt->snd_task = cookie;
 	ret = true;
 out:
@@ -788,7 +776,6 @@ void xprt_connect(struct rpc_task *task)
 		xprt->ops->close(xprt);
 
 	if (!xprt_connected(xprt)) {
-		task->tk_rqstp->rq_bytes_sent = 0;
 		task->tk_timeout = task->tk_rqstp->rq_timeout;
 		task->tk_rqstp->rq_connect_cookie = xprt->connect_cookie;
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
@@ -1085,7 +1072,6 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 static void
 xprt_request_dequeue_transmit_locked(struct rpc_task *task)
 {
-	xprt_task_clear_bytes_sent(task);
 	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 	list_del_init(&task->tk_rqstp->rq_xmit);
 }
-- 
2.17.1
