Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:45077 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeIQSb0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:26 -0400
Received: by mail-qt0-f194.google.com with SMTP id g44-v6so15093728qtb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:11 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.09
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:09 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 12/44] SUNRPC: Test whether the task is queued before grabbing the queue spinlocks
Date: Mon, 17 Sep 2018 09:03:03 -0400
Message-Id: <20180917130335.112832-13-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-12-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When asked to wake up an RPC task, it makes sense to test whether or not
the task is still queued.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/sched.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index dec01bd1b71c..9a8ec012b449 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -479,6 +479,8 @@ void rpc_wake_up_queued_task_on_wq(struct workqueue_struct *wq,
 		struct rpc_wait_queue *queue,
 		struct rpc_task *task)
 {
+	if (!RPC_IS_QUEUED(task))
+		return;
 	spin_lock_bh(&queue->lock);
 	rpc_wake_up_task_on_wq_queue_locked(wq, queue, task);
 	spin_unlock_bh(&queue->lock);
@@ -489,6 +491,8 @@ void rpc_wake_up_queued_task_on_wq(struct workqueue_struct *wq,
  */
 void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
+	if (!RPC_IS_QUEUED(task))
+		return;
 	spin_lock_bh(&queue->lock);
 	rpc_wake_up_task_queue_locked(queue, task);
 	spin_unlock_bh(&queue->lock);
-- 
2.17.1
