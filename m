Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:45708 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727105AbeIEBd2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:28 -0400
Received: by mail-io0-f195.google.com with SMTP id e12-v6so4197185iok.12
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:36 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:35 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 34/34] SUNRPC: Queue fairness for all.
Date: Tue,  4 Sep 2018 17:05:49 -0400
Message-Id: <20180904210549.81673-35-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-34-trond.myklebust@hammerspace.com>
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
 <20180904210549.81673-30-trond.myklebust@hammerspace.com>
 <20180904210549.81673-31-trond.myklebust@hammerspace.com>
 <20180904210549.81673-32-trond.myklebust@hammerspace.com>
 <20180904210549.81673-33-trond.myklebust@hammerspace.com>
 <20180904210549.81673-34-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the priority queue to not batch by owner, but by queue, so that
we allow '1 << priority' elements to be dequeued before switching to
the next priority queue.
The owner field is still used to wake up requests in round robin order
by owner to avoid single processes hogging the RPC layer by loading the
queues. We extend this property to non-priority queues as well.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |   2 -
 net/sunrpc/sched.c           | 126 ++++++++++++++++-------------------
 2 files changed, 57 insertions(+), 71 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index c5bc779feb00..869e2ee787fa 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -188,7 +188,6 @@ struct rpc_timer {
 struct rpc_wait_queue {
 	spinlock_t		lock;
 	struct list_head	tasks[RPC_NR_PRIORITY];	/* task queue for each priority level */
-	pid_t			owner;			/* process id of last task serviced */
 	unsigned char		maxpriority;		/* maximum priority (0 if queue is not a priority queue) */
 	unsigned char		priority;		/* current priority */
 	unsigned char		nr;			/* # tasks remaining for cookie */
@@ -204,7 +203,6 @@ struct rpc_wait_queue {
  * from a single cookie.  The aim is to improve
  * performance of NFS operations such as read/write.
  */
-#define RPC_BATCH_COUNT			16
 #define RPC_IS_PRIORITY(q)		((q)->maxpriority > 0)
 
 /*
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 104c056daf83..1120857eb1df 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -99,64 +99,77 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 	list_add(&task->u.tk_wait.timer_list, &queue->timer_list.list);
 }
 
-static void rpc_rotate_queue_owner(struct rpc_wait_queue *queue)
-{
-	struct list_head *q = &queue->tasks[queue->priority];
-	struct rpc_task *task;
-
-	if (!list_empty(q)) {
-		task = list_first_entry(q, struct rpc_task, u.tk_wait.list);
-		if (task->tk_owner == queue->owner)
-			list_move_tail(&task->u.tk_wait.list, q);
-	}
-}
-
 static void rpc_set_waitqueue_priority(struct rpc_wait_queue *queue, int priority)
 {
 	if (queue->priority != priority) {
-		/* Fairness: rotate the list when changing priority */
-		rpc_rotate_queue_owner(queue);
 		queue->priority = priority;
+		queue->nr = 1U << priority;
 	}
 }
 
-static void rpc_set_waitqueue_owner(struct rpc_wait_queue *queue, pid_t pid)
-{
-	queue->owner = pid;
-	queue->nr = RPC_BATCH_COUNT;
-}
-
 static void rpc_reset_waitqueue_priority(struct rpc_wait_queue *queue)
 {
 	rpc_set_waitqueue_priority(queue, queue->maxpriority);
-	rpc_set_waitqueue_owner(queue, 0);
 }
 
 /*
- * Add new request to a priority queue.
+ * Add a request to a queue list
  */
-static void __rpc_add_wait_queue_priority(struct rpc_wait_queue *queue,
-		struct rpc_task *task,
-		unsigned char queue_priority)
+static void
+__rpc_list_enqueue_task(struct list_head *q, struct rpc_task *task)
 {
-	struct list_head *q;
 	struct rpc_task *t;
-
-	INIT_LIST_HEAD(&task->u.tk_wait.links);
-	if (unlikely(queue_priority > queue->maxpriority))
-		queue_priority = queue->maxpriority;
-	if (queue_priority > queue->priority)
-		rpc_set_waitqueue_priority(queue, queue_priority);
-	q = &queue->tasks[queue_priority];
 	list_for_each_entry(t, q, u.tk_wait.list) {
 		if (t->tk_owner == task->tk_owner) {
-			list_add_tail(&task->u.tk_wait.list, &t->u.tk_wait.links);
+			list_add_tail(&task->u.tk_wait.links,
+					&t->u.tk_wait.links);
+			/* Cache the queue head in task->u.tk_wait.list */
+			task->u.tk_wait.list.next = q;
+			task->u.tk_wait.list.prev = NULL;
 			return;
 		}
 	}
+	INIT_LIST_HEAD(&task->u.tk_wait.links);
 	list_add_tail(&task->u.tk_wait.list, q);
 }
 
+/*
+ * Remove request from a queue list
+ */
+static void
+__rpc_list_dequeue_task(struct rpc_task *task)
+{
+	struct list_head *q;
+	struct rpc_task *t;
+
+	if (task->u.tk_wait.list.prev == NULL) {
+		list_del(&task->u.tk_wait.links);
+		return;
+	}
+	if (!list_empty(&task->u.tk_wait.links)) {
+		t = list_first_entry(&task->u.tk_wait.links,
+				struct rpc_task,
+				u.tk_wait.links);
+		/* Assume __rpc_list_enqueue_task() cached the queue head */
+		q = t->u.tk_wait.list.next;
+		list_add_tail(&t->u.tk_wait.list, q);
+		list_del(&task->u.tk_wait.links);
+	}
+	list_del(&task->u.tk_wait.list);
+}
+
+/*
+ * Add new request to a priority queue.
+ */
+static void __rpc_add_wait_queue_priority(struct rpc_wait_queue *queue,
+		struct rpc_task *task,
+		unsigned char queue_priority)
+{
+	if (unlikely(queue_priority > queue->maxpriority))
+		queue_priority = queue->maxpriority;
+	__rpc_list_enqueue_task(&queue->tasks[queue_priority], task);
+}
+
 /*
  * Add new request to wait queue.
  *
@@ -175,10 +188,11 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue,
 
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_add_wait_queue_priority(queue, task, queue_priority);
-	else if (RPC_IS_SWAPPER(task))
+	else if (RPC_IS_SWAPPER(task)) {
 		list_add(&task->u.tk_wait.list, &queue->tasks[0]);
-	else
-		list_add_tail(&task->u.tk_wait.list, &queue->tasks[0]);
+		INIT_LIST_HEAD(&task->u.tk_wait.links);
+	} else
+		__rpc_list_enqueue_task(&queue->tasks[0], task);
 	task->tk_waitqueue = queue;
 	queue->qlen++;
 	/* barrier matches the read in rpc_wake_up_task_queue_locked() */
@@ -189,20 +203,6 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue,
 			task->tk_pid, queue, rpc_qname(queue));
 }
 
-/*
- * Remove request from a priority queue.
- */
-static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
-{
-	struct rpc_task *t;
-
-	if (!list_empty(&task->u.tk_wait.links)) {
-		t = list_entry(task->u.tk_wait.links.next, struct rpc_task, u.tk_wait.list);
-		list_move(&t->u.tk_wait.list, &task->u.tk_wait.list);
-		list_splice_init(&task->u.tk_wait.links, &t->u.tk_wait.links);
-	}
-}
-
 /*
  * Remove request from queue.
  * Note: must be called with spin lock held.
@@ -210,9 +210,7 @@ static void __rpc_remove_wait_queue_priority(struct rpc_task *task)
 static void __rpc_remove_wait_queue(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
 	__rpc_disable_timer(queue, task);
-	if (RPC_IS_PRIORITY(queue))
-		__rpc_remove_wait_queue_priority(task);
-	list_del(&task->u.tk_wait.list);
+	__rpc_list_dequeue_task(task);
 	queue->qlen--;
 	dprintk("RPC: %5u removed from queue %p \"%s\"\n",
 			task->tk_pid, queue, rpc_qname(queue));
@@ -536,20 +534,12 @@ static struct rpc_task *__rpc_find_next_queued_priority(struct rpc_wait_queue *q
 	struct rpc_task *task;
 
 	/*
-	 * Service a batch of tasks from a single owner.
+	 * Service a batch of tasks from a single queue.
 	 */
 	q = &queue->tasks[queue->priority];
-	if (!list_empty(q)) {
-		task = list_entry(q->next, struct rpc_task, u.tk_wait.list);
-		if (queue->owner == task->tk_owner) {
-			if (--queue->nr)
-				goto out;
-			list_move_tail(&task->u.tk_wait.list, q);
-		}
-		/*
-		 * Check if we need to switch queues.
-		 */
-		goto new_owner;
+	if (!list_empty(q) && --queue->nr) {
+		task = list_first_entry(q, struct rpc_task, u.tk_wait.list);
+		goto out;
 	}
 
 	/*
@@ -561,7 +551,7 @@ static struct rpc_task *__rpc_find_next_queued_priority(struct rpc_wait_queue *q
 		else
 			q = q - 1;
 		if (!list_empty(q)) {
-			task = list_entry(q->next, struct rpc_task, u.tk_wait.list);
+			task = list_first_entry(q, struct rpc_task, u.tk_wait.list);
 			goto new_queue;
 		}
 	} while (q != &queue->tasks[queue->priority]);
@@ -571,8 +561,6 @@ static struct rpc_task *__rpc_find_next_queued_priority(struct rpc_wait_queue *q
 
 new_queue:
 	rpc_set_waitqueue_priority(queue, (unsigned int)(q - &queue->tasks[0]));
-new_owner:
-	rpc_set_waitqueue_owner(queue, task->tk_owner);
 out:
 	return task;
 }
-- 
2.17.1
