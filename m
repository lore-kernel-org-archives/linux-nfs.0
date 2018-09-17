Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:37310 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728321AbeIQSbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:55 -0400
Received: by mail-qt0-f195.google.com with SMTP id n6-v6so15133235qtl.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:39 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.37
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:38 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 37/44] SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
Date: Mon, 17 Sep 2018 09:03:28 -0400
Message-Id: <20180917130335.112832-38-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-37-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
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
 net/sunrpc/xprt.c | 20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 051638d5b39c..d1a67e97e7d3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -192,7 +192,6 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -212,13 +211,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 			task->tk_pid, xprt);
 	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
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
@@ -260,7 +253,6 @@ xprt_test_and_clear_congestion_window_wait(struct rpc_xprt *xprt)
 int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	int priority;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -283,13 +275,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
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
@@ -1795,7 +1781,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
-	rpc_init_priority_wait_queue(&xprt->sending, "xprt_sending");
+	rpc_init_wait_queue(&xprt->sending, "xprt_sending");
 	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
 
 	xprt_init_xid(xprt);
-- 
2.17.1
