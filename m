Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:40219 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeIQSbZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:25 -0400
Received: by mail-qt0-f194.google.com with SMTP id h4-v6so15112231qtj.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:10 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:08 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/44] SUNRPC: Add a helper to wake up a sleeping rpc_task and set its status
Date: Mon, 17 Sep 2018 09:03:02 -0400
Message-Id: <20180917130335.112832-12-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-11-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper that will wake up a task that is sleeping on a specific
queue, and will set the value of task->tk_status. This is mainly
intended for use by the transport layer to notify the task of an
error condition.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |  3 ++
 net/sunrpc/sched.c           | 65 ++++++++++++++++++++++++++++++------
 2 files changed, 58 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 8062ce6b18e5..8840a420cf4c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -235,6 +235,9 @@ void rpc_wake_up_queued_task_on_wq(struct workqueue_struct *wq,
 		struct rpc_task *task);
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
+void		rpc_wake_up_queued_task_set_status(struct rpc_wait_queue *,
+						   struct rpc_task *,
+						   int);
 void		rpc_wake_up(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_first_on_wq(struct workqueue_struct *wq,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 3fe5d60ab0e2..dec01bd1b71c 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -440,14 +440,28 @@ static void __rpc_do_wake_up_task_on_wq(struct workqueue_struct *wq,
 /*
  * Wake up a queued task while the queue lock is being held
  */
-static void rpc_wake_up_task_on_wq_queue_locked(struct workqueue_struct *wq,
-		struct rpc_wait_queue *queue, struct rpc_task *task)
+static struct rpc_task *
+rpc_wake_up_task_on_wq_queue_action_locked(struct workqueue_struct *wq,
+		struct rpc_wait_queue *queue, struct rpc_task *task,
+		bool (*action)(struct rpc_task *, void *), void *data)
 {
 	if (RPC_IS_QUEUED(task)) {
 		smp_rmb();
-		if (task->tk_waitqueue == queue)
-			__rpc_do_wake_up_task_on_wq(wq, queue, task);
+		if (task->tk_waitqueue == queue) {
+			if (action == NULL || action(task, data)) {
+				__rpc_do_wake_up_task_on_wq(wq, queue, task);
+				return task;
+			}
+		}
 	}
+	return NULL;
+}
+
+static void
+rpc_wake_up_task_on_wq_queue_locked(struct workqueue_struct *wq,
+		struct rpc_wait_queue *queue, struct rpc_task *task)
+{
+	rpc_wake_up_task_on_wq_queue_action_locked(wq, queue, task, NULL, NULL);
 }
 
 /*
@@ -481,6 +495,40 @@ void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_queued_task);
 
+static bool rpc_task_action_set_status(struct rpc_task *task, void *status)
+{
+	task->tk_status = *(int *)status;
+	return true;
+}
+
+static void
+rpc_wake_up_task_queue_set_status_locked(struct rpc_wait_queue *queue,
+		struct rpc_task *task, int status)
+{
+	rpc_wake_up_task_on_wq_queue_action_locked(rpciod_workqueue, queue,
+			task, rpc_task_action_set_status, &status);
+}
+
+/**
+ * rpc_wake_up_queued_task_set_status - wake up a task and set task->tk_status
+ * @queue: pointer to rpc_wait_queue
+ * @task: pointer to rpc_task
+ * @status: integer error value
+ *
+ * If @task is queued on @queue, then it is woken up, and @task->tk_status is
+ * set to the value of @status.
+ */
+void
+rpc_wake_up_queued_task_set_status(struct rpc_wait_queue *queue,
+		struct rpc_task *task, int status)
+{
+	if (!RPC_IS_QUEUED(task))
+		return;
+	spin_lock_bh(&queue->lock);
+	rpc_wake_up_task_queue_set_status_locked(queue, task, status);
+	spin_unlock_bh(&queue->lock);
+}
+
 /*
  * Wake up the next task on a priority queue.
  */
@@ -553,12 +601,9 @@ struct rpc_task *rpc_wake_up_first_on_wq(struct workqueue_struct *wq,
 			queue, rpc_qname(queue));
 	spin_lock_bh(&queue->lock);
 	task = __rpc_find_next_queued(queue);
-	if (task != NULL) {
-		if (func(task, data))
-			rpc_wake_up_task_on_wq_queue_locked(wq, queue, task);
-		else
-			task = NULL;
-	}
+	if (task != NULL)
+		task = rpc_wake_up_task_on_wq_queue_action_locked(wq, queue,
+				task, func, data);
 	spin_unlock_bh(&queue->lock);
 
 	return task;
-- 
2.17.1
