Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32864 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727458AbeICTvF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:51:05 -0400
Received: by mail-io0-f193.google.com with SMTP id r196-v6so712017iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:25 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:24 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 27/27] SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
Date: Mon,  3 Sep 2018 11:29:36 -0400
Message-Id: <20180903152936.24325-28-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-27-trond.myklebust@hammerspace.com>
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
 <20180903152936.24325-22-trond.myklebust@hammerspace.com>
 <20180903152936.24325-23-trond.myklebust@hammerspace.com>
 <20180903152936.24325-24-trond.myklebust@hammerspace.com>
 <20180903152936.24325-25-trond.myklebust@hammerspace.com>
 <20180903152936.24325-26-trond.myklebust@hammerspace.com>
 <20180903152936.24325-27-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We no longer need priority semantics on the xprt->sending queue, because
the order in which tasks are sent is now dictated by their position in
the send queue.
Note that the backlog queue remains a priority queue, meaning that
slot resources are still managed in order of task priority.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 29 ++++++-----------------------
 1 file changed, 6 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1ce32e555c9b..730e8bbd63a9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -183,7 +183,6 @@ EXPORT_SYMBOL_GPL(xprt_load_transport);
 int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -201,13 +200,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 			task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req == NULL)
-		priority = RPC_PRIORITY_LOW;
-	else if (!req->rq_ntrans)
-		priority = RPC_PRIORITY_NORMAL;
-	else
-		priority = RPC_PRIORITY_HIGH;
-	rpc_sleep_on_priority(&xprt->sending, task, NULL, priority);
+	rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
@@ -234,7 +227,6 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -257,13 +249,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req == NULL)
-		priority = RPC_PRIORITY_LOW;
-	else if (!req->rq_ntrans)
-		priority = RPC_PRIORITY_NORMAL;
-	else
-		priority = RPC_PRIORITY_HIGH;
-	rpc_sleep_on_priority(&xprt->sending, task, NULL, priority);
+	rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt_cong);
@@ -295,8 +281,7 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
 
-	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_func, xprt))
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
 		return;
 	xprt_clear_locked(xprt);
 }
@@ -325,8 +310,7 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 		return;
 	if (RPCXPRT_CONGESTED(xprt))
 		goto out_unlock;
-	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_cong_func, xprt))
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_cong_func, xprt))
 		return;
 out_unlock:
 	xprt_clear_locked(xprt);
@@ -506,8 +490,7 @@ void xprt_write_space(struct rpc_xprt *xprt)
 	if (xprt->snd_task) {
 		dprintk("RPC:       write space: waking waiting task on "
 				"xprt %p\n", xprt);
-		rpc_wake_up_queued_task_on_wq(xprtiod_workqueue,
-				&xprt->pending, xprt->snd_task);
+		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -1573,7 +1556,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
-	rpc_init_priority_wait_queue(&xprt->sending, "xprt_sending");
+	rpc_init_wait_queue(&xprt->sending, "xprt_sending");
 	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
 
 	xprt_init_xid(xprt);
-- 
2.17.1
