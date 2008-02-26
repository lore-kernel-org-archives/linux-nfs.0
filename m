From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/10] SUNRPC: Switch tasks to using the rpc_waitqueue's
	timer function
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.67305.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbYBZXis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:48 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNclLN027322
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:47 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    9 +-----
 net/sunrpc/sched.c           |   59 +++++++-----------------------------------
 2 files changed, 11 insertions(+), 57 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7751d3a..0d7be16 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -67,12 +67,6 @@ struct rpc_task {
 	const struct rpc_call_ops *tk_ops;
 	void *			tk_calldata;
 
-	/*
-	 * tk_timer is used for async processing by the RPC scheduling
-	 * primitives. You should not access this directly unless
-	 * you have a pathological interest in kernel oopses.
-	 */
-	struct timer_list	tk_timer;	/* kernel timer */
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned long		tk_runstate;	/* Task run status */
@@ -149,8 +143,7 @@ struct rpc_task_setup {
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
 #define RPC_TASK_WAKEUP		2
-#define RPC_TASK_HAS_TIMER	3
-#define RPC_TASK_ACTIVE		4
+#define RPC_TASK_ACTIVE		3
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index cdff04d..bb58eb4 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -58,18 +58,20 @@ struct workqueue_struct *rpciod_workqueue;
  * rpc_run_timer().
  */
 static void
-__rpc_disable_timer(struct rpc_task *task)
+__rpc_disable_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
 	task->tk_timeout = 0;
 	list_del(&task->u.tk_wait.timer_list);
+	if (list_empty(&queue->timer_list.list))
+		del_timer(&queue->timer_list.timer);
 }
 
 /*
  * Set up a timer for the current task.
  */
 static void
-__rpc_add_timer(struct rpc_task *task)
+__rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	if (!task->tk_timeout)
 		return;
@@ -77,23 +79,10 @@ __rpc_add_timer(struct rpc_task *task)
 	dprintk("RPC: %5u setting alarm for %lu ms\n",
 			task->tk_pid, task->tk_timeout * 1000 / HZ);
 
-	set_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
-	mod_timer(&task->tk_timer, jiffies + task->tk_timeout);
-}
-
-/*
- * Delete any timer for the current task. Because we use del_timer_sync(),
- * this function should never be called while holding queue->lock.
- */
-static void
-rpc_delete_timer(struct rpc_task *task)
-{
-	if (RPC_IS_QUEUED(task))
-		return;
-	if (test_and_clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate)) {
-		del_singleshot_timer_sync(&task->tk_timer);
-		dprintk("RPC: %5u deleting timer\n", task->tk_pid);
-	}
+	task->u.tk_wait.expires = jiffies + task->tk_timeout;
+	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))
+		mod_timer(&queue->timer_list.timer, task->u.tk_wait.expires);
+	list_add(&queue->timer_list.list, &task->u.tk_wait.timer_list);
 }
 
 /*
@@ -164,7 +153,7 @@ static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
  */
 static void __rpc_remove_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
-	__rpc_disable_timer(task);
+	__rpc_disable_timer(queue, task);
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_remove_wait_queue_priority(task);
 	list_del(&task->u.tk_wait.list);
@@ -336,7 +325,7 @@ static void __rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 
 	BUG_ON(task->tk_callback != NULL);
 	task->tk_callback = action;
-	__rpc_add_timer(task);
+	__rpc_add_timer(q, task);
 }
 
 void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
@@ -547,26 +536,6 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 
-/*
- * Run a timeout function.
- */
-static void rpc_run_timer(unsigned long ptr)
-{
-	struct rpc_task *task = (struct rpc_task *)ptr;
-	struct rpc_wait_queue *queue = task->tk_waitqueue;
-
-	spin_lock(&queue->lock);
-	if (RPC_IS_QUEUED(task) && task->tk_waitqueue == queue) {
-		dprintk("RPC: %5u timeout\n", task->tk_pid);
-		task->tk_status = -ETIMEDOUT;
-		rpc_wake_up_task_queue_locked(queue, task);
-	}
-	spin_unlock(&queue->lock);
-	smp_mb__before_clear_bit();
-	clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
-	smp_mb__after_clear_bit();
-}
-
 static void __rpc_queue_timer_fn(unsigned long ptr)
 {
 	struct rpc_wait_queue *queue = (struct rpc_wait_queue *)ptr;
@@ -660,10 +629,6 @@ static void __rpc_execute(struct rpc_task *task)
 	BUG_ON(RPC_IS_QUEUED(task));
 
 	for (;;) {
-		/*
-		 * Garbage collection of pending timers...
-		 */
-		rpc_delete_timer(task);
 
 		/*
 		 * Execute any pending callback.
@@ -832,7 +797,6 @@ EXPORT_SYMBOL_GPL(rpc_free);
 static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setup_data)
 {
 	memset(task, 0, sizeof(*task));
-	setup_timer(&task->tk_timer, rpc_run_timer, (unsigned long)task);
 	atomic_set(&task->tk_count, 1);
 	task->tk_flags  = task_setup_data->flags;
 	task->tk_ops = task_setup_data->callback_ops;
@@ -965,9 +929,6 @@ static void rpc_release_task(struct rpc_task *task)
 	}
 	BUG_ON (RPC_IS_QUEUED(task));
 
-	/* Synchronously delete any running timer */
-	rpc_delete_timer(task);
-
 #ifdef RPC_DEBUG
 	task->tk_magic = 0;
 #endif

