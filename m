Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37044 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726999AbeIEBdZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:25 -0400
Received: by mail-it0-f65.google.com with SMTP id h20-v6so6706379itf.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:33 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:32 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 29/34] SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
Date: Tue,  4 Sep 2018 17:05:44 -0400
Message-Id: <20180904210549.81673-30-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-29-trond.myklebust@hammerspace.com>
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
 <20180904210549.81673-28-trond.myklebust@hammerspace.com>
 <20180904210549.81673-29-trond.myklebust@hammerspace.com>
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
index ba9af25d14de..ebe5235c484b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -181,7 +181,6 @@ EXPORT_SYMBOL_GPL(xprt_load_transport);
 int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -197,13 +196,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
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
@@ -231,7 +224,6 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -251,13 +243,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
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
@@ -285,8 +271,7 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
 
-	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_func, xprt))
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
 		return;
 	xprt_clear_locked(xprt);
 }
@@ -297,8 +282,7 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 		return;
 	if (RPCXPRT_CONGESTED(xprt))
 		goto out_unlock;
-	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_func, xprt))
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
 		return;
 out_unlock:
 	xprt_clear_locked(xprt);
@@ -495,8 +479,7 @@ void xprt_write_space(struct rpc_xprt *xprt)
 	if (xprt->snd_task) {
 		dprintk("RPC:       write space: waking waiting task on "
 				"xprt %p\n", xprt);
-		rpc_wake_up_queued_task_on_wq(xprtiod_workqueue,
-				&xprt->pending, xprt->snd_task);
+		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -1596,7 +1579,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
-	rpc_init_priority_wait_queue(&xprt->sending, "xprt_sending");
+	rpc_init_wait_queue(&xprt->sending, "xprt_sending");
 	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
 
 	xprt_init_xid(xprt);
-- 
2.17.1
