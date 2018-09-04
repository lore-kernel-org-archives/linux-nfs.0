Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:54764 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726284AbeIEBdM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:12 -0400
Received: by mail-it0-f65.google.com with SMTP id f14-v6so7022002ita.4
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:20 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/34] SUNRPC: Add a helper to wake up a sleeping rpc_task and set its status
Date: Tue,  4 Sep 2018 17:05:26 -0400
Message-Id: <20180904210549.81673-12-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-11-trond.myklebust@hammerspace.com>
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
 net/sunrpc/sched.c           | 63 ++++++++++++++++++++++++++++++------
 2 files changed, 56 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index a4a42b3a1f03..c5bc779feb00 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -234,6 +234,9 @@ void rpc_wake_up_queued_task_on_wq(struct workqueue_struct *wq,
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
index 3fe5d60ab0e2..104c056daf83 100644
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
@@ -481,6 +495,38 @@ void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task
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
+	spin_lock_bh(&queue->lock);
+	rpc_wake_up_task_queue_set_status_locked(queue, task, status);
+	spin_unlock_bh(&queue->lock);
+}
+
 /*
  * Wake up the next task on a priority queue.
  */
@@ -553,12 +599,9 @@ struct rpc_task *rpc_wake_up_first_on_wq(struct workqueue_struct *wq,
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
