Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35869 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbcFNTEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:04:39 -0400
Received: by mail-it0-f67.google.com with SMTP id h190so409411ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:04:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] SUNRPC: Reduce latency when send queue is congested
Date: Tue, 14 Jun 2016 15:04:05 -0400
Message-Id: <1465931046-30696-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931046-30696-3-git-send-email-trond.myklebust@primarydata.com>
References: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the low latency transport workqueue to process the task that is
next in line on the xprt->sending queue.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h |  4 ++++
 net/sunrpc/sched.c           | 43 +++++++++++++++++++++++++++++++++----------
 net/sunrpc/xprt.c            |  6 ++++--
 3 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index ef780b3b5e31..817af0b4385e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -230,6 +230,10 @@ void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
+struct rpc_task *rpc_wake_up_first_on_wq(struct workqueue_struct *wq,
+					struct rpc_wait_queue *,
+					bool (*)(struct rpc_task *, void *),
+					void *);
 struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
 					bool (*)(struct rpc_task *, void *),
 					void *);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index a9f786247ffb..9ae588511aaf 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -330,7 +330,8 @@ EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
  * lockless RPC_IS_QUEUED() test) before we've had a chance to test
  * the RPC_TASK_RUNNING flag.
  */
-static void rpc_make_runnable(struct rpc_task *task)
+static void rpc_make_runnable(struct workqueue_struct *wq,
+		struct rpc_task *task)
 {
 	bool need_wakeup = !rpc_test_and_set_running(task);
 
@@ -339,7 +340,7 @@ static void rpc_make_runnable(struct rpc_task *task)
 		return;
 	if (RPC_IS_ASYNC(task)) {
 		INIT_WORK(&task->u.tk_work, rpc_async_schedule);
-		queue_work(rpciod_workqueue, &task->u.tk_work);
+		queue_work(wq, &task->u.tk_work);
 	} else
 		wake_up_bit(&task->tk_runstate, RPC_TASK_QUEUED);
 }
@@ -408,13 +409,16 @@ void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
 EXPORT_SYMBOL_GPL(rpc_sleep_on_priority);
 
 /**
- * __rpc_do_wake_up_task - wake up a single rpc_task
+ * __rpc_do_wake_up_task_on_wq - wake up a single rpc_task
+ * @wq: workqueue on which to run task
  * @queue: wait queue
  * @task: task to be woken up
  *
  * Caller must hold queue->lock, and have cleared the task queued flag.
  */
-static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task *task)
+static void __rpc_do_wake_up_task_on_wq(struct workqueue_struct *wq,
+		struct rpc_wait_queue *queue,
+		struct rpc_task *task)
 {
 	dprintk("RPC: %5u __rpc_wake_up_task (now %lu)\n",
 			task->tk_pid, jiffies);
@@ -429,7 +433,7 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
 
 	__rpc_remove_wait_queue(queue, task);
 
-	rpc_make_runnable(task);
+	rpc_make_runnable(wq, task);
 
 	dprintk("RPC:       __rpc_wake_up_task done\n");
 }
@@ -437,16 +441,25 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
 /*
  * Wake up a queued task while the queue lock is being held
  */
-static void rpc_wake_up_task_queue_locked(struct rpc_wait_queue *queue, struct rpc_task *task)
+static void rpc_wake_up_task_on_wq_queue_locked(struct workqueue_struct *wq,
+		struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	if (RPC_IS_QUEUED(task)) {
 		smp_rmb();
 		if (task->tk_waitqueue == queue)
-			__rpc_do_wake_up_task(queue, task);
+			__rpc_do_wake_up_task_on_wq(wq, queue, task);
 	}
 }
 
 /*
+ * Wake up a queued task while the queue lock is being held
+ */
+static void rpc_wake_up_task_queue_locked(struct rpc_wait_queue *queue, struct rpc_task *task)
+{
+	rpc_wake_up_task_on_wq_queue_locked(rpciod_workqueue, queue, task);
+}
+
+/*
  * Wake up a task on a specific queue
  */
 void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task)
@@ -519,7 +532,8 @@ static struct rpc_task *__rpc_find_next_queued(struct rpc_wait_queue *queue)
 /*
  * Wake up the first task on the wait queue.
  */
-struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *queue,
+struct rpc_task *rpc_wake_up_first_on_wq(struct workqueue_struct *wq,
+		struct rpc_wait_queue *queue,
 		bool (*func)(struct rpc_task *, void *), void *data)
 {
 	struct rpc_task	*task = NULL;
@@ -530,7 +544,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *queue,
 	task = __rpc_find_next_queued(queue);
 	if (task != NULL) {
 		if (func(task, data))
-			rpc_wake_up_task_queue_locked(queue, task);
+			rpc_wake_up_task_on_wq_queue_locked(wq, queue, task);
 		else
 			task = NULL;
 	}
@@ -538,6 +552,15 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *queue,
 
 	return task;
 }
+
+/*
+ * Wake up the first task on the wait queue.
+ */
+struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *queue,
+		bool (*func)(struct rpc_task *, void *), void *data)
+{
+	return rpc_wake_up_first_on_wq(rpciod_workqueue, queue, func, data);
+}
 EXPORT_SYMBOL_GPL(rpc_wake_up_first);
 
 static bool rpc_wake_up_next_func(struct rpc_task *task, void *data)
@@ -815,7 +838,7 @@ void rpc_execute(struct rpc_task *task)
 	bool is_async = RPC_IS_ASYNC(task);
 
 	rpc_set_active(task);
-	rpc_make_runnable(task);
+	rpc_make_runnable(rpciod_workqueue, task);
 	if (!is_async)
 		__rpc_execute(task);
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 71df082b84a9..8313960cac52 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -295,7 +295,8 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
 
-	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
+	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
+				__xprt_lock_write_func, xprt))
 		return;
 	xprt_clear_locked(xprt);
 }
@@ -324,7 +325,8 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 		return;
 	if (RPCXPRT_CONGESTED(xprt))
 		goto out_unlock;
-	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_cong_func, xprt))
+	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
+				__xprt_lock_write_cong_func, xprt))
 		return;
 out_unlock:
 	xprt_clear_locked(xprt);
-- 
2.5.5

