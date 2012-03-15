Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031675Ab2COSlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:41:03 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 08/11] SUNRPC: add rpc_drain_queue to empty an rpc_waitq
Date: Thu, 15 Mar 2012 14:40:47 -0400
Message-Id: <1331836850-5195-9-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index dc0c3cc..fce0873 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -235,6 +235,7 @@ void		rpc_sleep_on_priority(struct rpc_wait_queue *,
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
+void		rpc_drain_queue(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
 					bool (*)(struct rpc_task *, void *),
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 1c570a8..11928ff 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -551,6 +551,33 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 EXPORT_SYMBOL_GPL(rpc_wake_up);
 
 /**
+ * rpc_drain_queue - empty the queue and wake up all rpc_tasks
+ * @queue: rpc_wait_queue on which the tasks are sleeping
+ *
+ * Grabs queue->lock
+ */
+void rpc_drain_queue(struct rpc_wait_queue *queue)
+{
+	struct rpc_task *task;
+	struct list_head *head;
+
+	spin_lock_bh(&queue->lock);
+	head = &queue->tasks[queue->maxpriority];
+	for (;;) {
+		while (!list_empty(head)) {
+			task = list_entry(head->next, struct rpc_task,
+					  u.tk_wait.list);
+			rpc_wake_up_task_queue_locked(queue, task);
+		}
+		if (head == &queue->tasks[0])
+			break;
+		head--;
+	}
+	spin_unlock_bh(&queue->lock);
+}
+EXPORT_SYMBOL_GPL(rpc_drain_queue);
+
+/**
  * rpc_wake_up_status - wake up all rpc_tasks and set their status value.
  * @queue: rpc_wait_queue on which the tasks are sleeping
  * @status: status value to set
-- 
1.7.6.4

