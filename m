Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:43475 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728269AbeIQSbk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:40 -0400
Received: by mail-qk1-f193.google.com with SMTP id 130-v6so8903611qkd.10
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:25 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 23/44] SUNRPC: Don't reset the request 'bytes_sent' counter when releasing XPRT_LOCK
Date: Mon, 17 Sep 2018 09:03:14 -0400
Message-Id: <20180917130335.112832-24-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-23-trond.myklebust@hammerspace.com>
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
index dcefbf406482..4ca23a6607ba 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2128,15 +2128,11 @@ static void
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
index 00b17cb49910..3b31830ef851 100644
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
@@ -1093,7 +1080,6 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 static void
 xprt_request_dequeue_transmit_locked(struct rpc_task *task)
 {
-	xprt_task_clear_bytes_sent(task);
 	if (test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
 		list_del(&task->tk_rqstp->rq_xmit);
 }
-- 
2.17.1
