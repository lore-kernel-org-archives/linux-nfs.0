Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43658 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727430AbeICTu7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:59 -0400
Received: by mail-io0-f195.google.com with SMTP id y10-v6so669735ioa.10
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:19 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:18 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/27] SUNRPC: Don't reset the request 'bytes_sent' counter when releasing XPRT_LOCK
Date: Mon,  3 Sep 2018 11:29:30 -0400
Message-Id: <20180903152936.24325-22-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-21-trond.myklebust@hammerspace.com>
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
 <20180903152936.24325-19-trond.myklebust@hammerspace.com>
 <20180903152936.24325-20-trond.myklebust@hammerspace.com>
 <20180903152936.24325-21-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the request is still on the queue, this will be incorrect behaviour.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c |  3 ---
 net/sunrpc/xprt.c | 14 --------------
 2 files changed, 17 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 497a30762a6d..585a82dfaf4d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2138,9 +2138,6 @@ call_status(struct rpc_task *task)
 	if (!task->tk_msg.rpc_proc->p_proc)
 		trace_xprt_ping(task->tk_xprt, task->tk_status);
 
-	if (req->rq_reply_bytes_recvd > 0 && !req->rq_bytes_sent)
-		task->tk_status = req->rq_reply_bytes_recvd;
-
 	dprint_status(task);
 
 	status = task->tk_status;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3efcb69af526..5efa9eddf769 100644
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
