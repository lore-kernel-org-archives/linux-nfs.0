From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/10] SUNRPC: Add a new helper rpc_wake_up_queued_task()
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.81531.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbYBZXis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:48 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcl8Y013355
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:47 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In all cases where we currently use rpc_wake_up_task(), we almost always
know on which waitqueue the rpc_task is actually sleeping. This will allows
us to simplify the queue locking in a future patch.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    4 ++-
 net/sunrpc/clnt.c            |    2 +
 net/sunrpc/sched.c           |   64 ++++++++++++++++++++----------------------
 3 files changed, 34 insertions(+), 36 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index fefb0ab..83f6777 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -33,7 +33,6 @@ struct rpc_wait_queue;
 struct rpc_wait {
 	struct list_head	list;		/* wait queue links */
 	struct list_head	links;		/* Links to related tasks */
-	struct rpc_wait_queue *	rpc_waitq;	/* RPC wait queue we're on */
 };
 
 /*
@@ -80,6 +79,7 @@ struct rpc_task {
 	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
 						 * be any workqueue
 						 */
+	struct rpc_wait_queue 	*tk_waitqueue;	/* RPC wait queue we're on */
 	union {
 		struct work_struct	tk_work;	/* Async task work queue */
 		struct rpc_wait		tk_wait;	/* RPC wait */
@@ -233,6 +233,8 @@ void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
 					rpc_action action, rpc_action timer);
 void		rpc_wake_up_task(struct rpc_task *);
+void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
+					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c6a7f1..fe95bd0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1535,7 +1535,7 @@ void rpc_show_tasks(void)
 				proc = -1;
 
 			if (RPC_IS_QUEUED(t))
-				rpc_waitq = rpc_qname(t->u.tk_wait.rpc_waitq);
+				rpc_waitq = rpc_qname(t->tk_waitqueue);
 
 			printk("%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
 				t->tk_pid, proc,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9433a11..9233ace 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -148,7 +148,7 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *
 		list_add(&task->u.tk_wait.list, &queue->tasks[0]);
 	else
 		list_add_tail(&task->u.tk_wait.list, &queue->tasks[0]);
-	task->u.tk_wait.rpc_waitq = queue;
+	task->tk_waitqueue = queue;
 	queue->qlen++;
 	rpc_set_queued(task);
 
@@ -175,11 +175,8 @@ static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
  * Remove request from queue.
  * Note: must be called with spin lock held.
  */
-static void __rpc_remove_wait_queue(struct rpc_task *task)
+static void __rpc_remove_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
-	struct rpc_wait_queue *queue;
-	queue = task->u.tk_wait.rpc_waitq;
-
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_remove_wait_queue_priority(task);
 	else
@@ -364,11 +361,12 @@ EXPORT_SYMBOL_GPL(rpc_sleep_on);
 
 /**
  * __rpc_do_wake_up_task - wake up a single rpc_task
+ * @queue: wait queue
  * @task: task to be woken up
  *
  * Caller must hold queue->lock, and have cleared the task queued flag.
  */
-static void __rpc_do_wake_up_task(struct rpc_task *task)
+static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	dprintk("RPC: %5u __rpc_wake_up_task (now %lu)\n",
 			task->tk_pid, jiffies);
@@ -383,7 +381,7 @@ static void __rpc_do_wake_up_task(struct rpc_task *task)
 	}
 
 	__rpc_disable_timer(task);
-	__rpc_remove_wait_queue(task);
+	__rpc_remove_wait_queue(queue, task);
 
 	rpc_make_runnable(task);
 
@@ -391,36 +389,38 @@ static void __rpc_do_wake_up_task(struct rpc_task *task)
 }
 
 /*
- * Wake up the specified task
+ * Wake up a queued task while the queue lock is being held
  */
-static void __rpc_wake_up_task(struct rpc_task *task)
+static void rpc_wake_up_task_queue_locked(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
+	if (!RPC_IS_QUEUED(task) || task->tk_waitqueue != queue)
+		return;
 	if (rpc_start_wakeup(task)) {
-		if (RPC_IS_QUEUED(task))
-			__rpc_do_wake_up_task(task);
+			__rpc_do_wake_up_task(queue, task);
 		rpc_finish_wakeup(task);
 	}
 }
 
 /*
- * Wake up the specified task
+ * Wake up a task on a specific queue
  */
-void rpc_wake_up_task(struct rpc_task *task)
+void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	rcu_read_lock_bh();
-	if (rpc_start_wakeup(task)) {
-		if (RPC_IS_QUEUED(task)) {
-			struct rpc_wait_queue *queue = task->u.tk_wait.rpc_waitq;
-
-			/* Note: we're already in a bh-safe context */
-			spin_lock(&queue->lock);
-			__rpc_do_wake_up_task(task);
-			spin_unlock(&queue->lock);
-		}
-		rpc_finish_wakeup(task);
-	}
+	spin_lock(&queue->lock);
+	rpc_wake_up_task_queue_locked(queue, task);
+	spin_unlock(&queue->lock);
 	rcu_read_unlock_bh();
 }
+EXPORT_SYMBOL_GPL(rpc_wake_up_queued_task);
+
+/*
+ * Wake up the specified task
+ */
+void rpc_wake_up_task(struct rpc_task *task)
+{
+	rpc_wake_up_queued_task(task->tk_waitqueue, task);
+}
 EXPORT_SYMBOL_GPL(rpc_wake_up_task);
 
 /*
@@ -471,7 +471,7 @@ new_queue:
 new_owner:
 	rpc_set_waitqueue_owner(queue, task->tk_owner);
 out:
-	__rpc_wake_up_task(task);
+	rpc_wake_up_task_queue_locked(queue, task);
 	return task;
 }
 
@@ -490,7 +490,7 @@ struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
 		task = __rpc_wake_up_next_priority(queue);
 	else {
 		task_for_first(task, &queue->tasks[0])
-			__rpc_wake_up_task(task);
+			rpc_wake_up_task_queue_locked(queue, task);
 	}
 	spin_unlock(&queue->lock);
 	rcu_read_unlock_bh();
@@ -515,7 +515,7 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
-			__rpc_wake_up_task(task);
+			rpc_wake_up_task_queue_locked(queue, task);
 		if (head == &queue->tasks[0])
 			break;
 		head--;
@@ -543,7 +543,7 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
 			task->tk_status = status;
-			__rpc_wake_up_task(task);
+			rpc_wake_up_task_queue_locked(queue, task);
 		}
 		if (head == &queue->tasks[0])
 			break;
@@ -562,10 +562,8 @@ static void rpc_run_timer(unsigned long ptr)
 	struct rpc_task *task = (struct rpc_task *)ptr;
 	void (*callback)(struct rpc_task *);
 
-	if (!rpc_start_wakeup(task))
-		goto out;
 	if (RPC_IS_QUEUED(task)) {
-		struct rpc_wait_queue *queue = task->u.tk_wait.rpc_waitq;
+		struct rpc_wait_queue *queue = task->tk_waitqueue;
 		callback = task->tk_timeout_fn;
 
 		dprintk("RPC: %5u running timer\n", task->tk_pid);
@@ -573,11 +571,9 @@ static void rpc_run_timer(unsigned long ptr)
 			callback(task);
 		/* Note: we're already in a bh-safe context */
 		spin_lock(&queue->lock);
-		__rpc_do_wake_up_task(task);
+		rpc_wake_up_task_queue_locked(queue, task);
 		spin_unlock(&queue->lock);
 	}
-	rpc_finish_wakeup(task);
-out:
 	smp_mb__before_clear_bit();
 	clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
 	smp_mb__after_clear_bit();

