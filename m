From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/10] SUNRPC: Add a timer function to wait queues.
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.364.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47575 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbYBZXiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:52 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmx1027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:51 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is designed to replace the timeout timer in the individual rpc_tasks.
By putting the timer function in the wait queue, we will eventually be able
to reduce the total number of timers in use by the RPC subsystem.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    9 +++++++++
 net/sunrpc/sched.c           |   40 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d39729e..7751d3a 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -33,6 +33,8 @@ struct rpc_wait_queue;
 struct rpc_wait {
 	struct list_head	list;		/* wait queue links */
 	struct list_head	links;		/* Links to related tasks */
+	struct list_head	timer_list;	/* Timer list */
+	unsigned long		expires;
 };
 
 /*
@@ -191,6 +193,12 @@ struct rpc_task_setup {
 #define RPC_PRIORITY_HIGH	(1)
 #define RPC_NR_PRIORITY		(1 + RPC_PRIORITY_HIGH - RPC_PRIORITY_LOW)
 
+struct rpc_timer {
+	struct timer_list timer;
+	struct list_head list;
+	unsigned long expires;
+};
+
 /*
  * RPC synchronization objects
  */
@@ -203,6 +211,7 @@ struct rpc_wait_queue {
 	unsigned char		count;			/* # task groups remaining serviced so far */
 	unsigned char		nr;			/* # tasks remaining for cookie */
 	unsigned short		qlen;			/* total # tasks waiting in queue */
+	struct rpc_timer	timer_list;
 #ifdef RPC_DEBUG
 	const char *		name;
 #endif
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 86aa897..cdff04d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -40,6 +40,7 @@ static mempool_t	*rpc_buffer_mempool __read_mostly;
 
 static void			rpc_async_schedule(struct work_struct *);
 static void			 rpc_release_task(struct rpc_task *task);
+static void __rpc_queue_timer_fn(unsigned long ptr);
 
 /*
  * RPC tasks sit here while waiting for conditions to improve.
@@ -61,6 +62,7 @@ __rpc_disable_timer(struct rpc_task *task)
 {
 	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
 	task->tk_timeout = 0;
+	list_del(&task->u.tk_wait.timer_list);
 }
 
 /*
@@ -127,6 +129,7 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *
 {
 	BUG_ON (RPC_IS_QUEUED(task));
 
+	INIT_LIST_HEAD(&task->u.tk_wait.timer_list);
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_add_wait_queue_priority(queue, task);
 	else if (RPC_IS_SWAPPER(task))
@@ -153,7 +156,6 @@ static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
 		list_move(&t->u.tk_wait.list, &task->u.tk_wait.list);
 		list_splice_init(&task->u.tk_wait.links, &t->u.tk_wait.links);
 	}
-	list_del(&task->u.tk_wait.list);
 }
 
 /*
@@ -162,10 +164,10 @@ static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
  */
 static void __rpc_remove_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
+	__rpc_disable_timer(task);
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_remove_wait_queue_priority(task);
-	else
-		list_del(&task->u.tk_wait.list);
+	list_del(&task->u.tk_wait.list);
 	queue->qlen--;
 	dprintk("RPC: %5u removed from queue %p \"%s\"\n",
 			task->tk_pid, queue, rpc_qname(queue));
@@ -198,6 +200,9 @@ static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const c
 		INIT_LIST_HEAD(&queue->tasks[i]);
 	queue->maxpriority = nr_queues - 1;
 	rpc_reset_waitqueue_priority(queue);
+	queue->qlen = 0;
+	setup_timer(&queue->timer_list.timer, __rpc_queue_timer_fn, (unsigned long)queue);
+	INIT_LIST_HEAD(&queue->timer_list.list);
 #ifdef RPC_DEBUG
 	queue->name = qname;
 #endif
@@ -216,6 +221,7 @@ EXPORT_SYMBOL_GPL(rpc_init_wait_queue);
 
 void rpc_destroy_wait_queue(struct rpc_wait_queue *queue)
 {
+	del_timer_sync(&queue->timer_list.timer);
 }
 EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
 
@@ -369,7 +375,6 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
 		return;
 	}
 
-	__rpc_disable_timer(task);
 	__rpc_remove_wait_queue(queue, task);
 
 	rpc_make_runnable(task);
@@ -562,6 +567,33 @@ static void rpc_run_timer(unsigned long ptr)
 	smp_mb__after_clear_bit();
 }
 
+static void __rpc_queue_timer_fn(unsigned long ptr)
+{
+	struct rpc_wait_queue *queue = (struct rpc_wait_queue *)ptr;
+	struct rpc_task *task, *n;
+	unsigned long expires, now, timeo;
+
+	spin_lock(&queue->lock);
+	expires = now = jiffies;
+	list_for_each_entry_safe(task, n, &queue->timer_list.list, u.tk_wait.timer_list) {
+		timeo = task->u.tk_wait.expires;
+		if (time_after_eq(now, timeo)) {
+			list_del_init(&task->u.tk_wait.timer_list);
+			dprintk("RPC: %5u timeout\n", task->tk_pid);
+			task->tk_status = -ETIMEDOUT;
+			rpc_wake_up_task_queue_locked(queue, task);
+			continue;
+		}
+		if (expires == now || time_before(expires, timeo))
+			expires = timeo;
+	}
+	if (!list_empty(&queue->timer_list.list)) {
+		mod_timer(&queue->timer_list.timer, expires);
+		queue->timer_list.expires = expires;
+	}
+	spin_unlock(&queue->lock);
+}
+
 static void __rpc_atrun(struct rpc_task *task)
 {
 	task->tk_status = 0;

