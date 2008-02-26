From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/10] SUNRPC: Remove now-redundant RCU-safe rpc_task free
	path
Date: Tue, 26 Feb 2008 09:23:09 -0800
Message-ID: <20080226172308.10383.73921.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29320 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbYBZXiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:51 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmwx027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:50 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've tightened up the locking rules for RPC queue wakeups, we can
remove the RCU-safe kfree calls...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/read.c                |    8 +-------
 fs/nfs/write.c               |   16 ++--------------
 include/linux/sunrpc/sched.h |    2 --
 net/sunrpc/sched.c           |   37 ++++++++++++-------------------------
 4 files changed, 15 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 87546cd..be9e827 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -58,19 +58,13 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 	return p;
 }
 
-static void nfs_readdata_rcu_free(struct rcu_head *head)
+static void nfs_readdata_free(struct nfs_read_data *p)
 {
-	struct nfs_read_data *p = container_of(head, struct nfs_read_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_rdata_mempool);
 }
 
-static void nfs_readdata_free(struct nfs_read_data *rdata)
-{
-	call_rcu_bh(&rdata->task.u.tk_rcu, nfs_readdata_rcu_free);
-}
-
 void nfs_readdata_release(void *data)
 {
 	struct nfs_read_data *rdata = data;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 84495ef..3051302 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -58,19 +58,13 @@ struct nfs_write_data *nfs_commit_alloc(void)
 	return p;
 }
 
-static void nfs_commit_rcu_free(struct rcu_head *head)
+void nfs_commit_free(struct nfs_write_data *p)
 {
-	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_commit_mempool);
 }
 
-void nfs_commit_free(struct nfs_write_data *wdata)
-{
-	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_commit_rcu_free);
-}
-
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
 	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
@@ -92,19 +86,13 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 	return p;
 }
 
-static void nfs_writedata_rcu_free(struct rcu_head *head)
+static void nfs_writedata_free(struct nfs_write_data *p)
 {
-	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_wdata_mempool);
 }
 
-static void nfs_writedata_free(struct nfs_write_data *wdata)
-{
-	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_writedata_rcu_free);
-}
-
 void nfs_writedata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index bf69fce..d1a5c8c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -11,7 +11,6 @@
 
 #include <linux/timer.h>
 #include <linux/sunrpc/types.h>
-#include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
@@ -77,7 +76,6 @@ struct rpc_task {
 	union {
 		struct work_struct	tk_work;	/* Async task work queue */
 		struct rpc_wait		tk_wait;	/* RPC wait */
-		struct rcu_head		tk_rcu;		/* for task deletion */
 	} u;
 
 	unsigned short		tk_timeouts;	/* maj timeouts */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0c6fb50..872da12 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -385,11 +385,9 @@ static void rpc_wake_up_task_queue_locked(struct rpc_wait_queue *queue, struct r
  */
 void rpc_wake_up_queued_task(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
-	rcu_read_lock_bh();
-	spin_lock(&queue->lock);
+	spin_lock_bh(&queue->lock);
 	rpc_wake_up_task_queue_locked(queue, task);
-	spin_unlock(&queue->lock);
-	rcu_read_unlock_bh();
+	spin_unlock_bh(&queue->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_queued_task);
 
@@ -462,16 +460,14 @@ struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
 
 	dprintk("RPC:       wake_up_next(%p \"%s\")\n",
 			queue, rpc_qname(queue));
-	rcu_read_lock_bh();
-	spin_lock(&queue->lock);
+	spin_lock_bh(&queue->lock);
 	if (RPC_IS_PRIORITY(queue))
 		task = __rpc_wake_up_next_priority(queue);
 	else {
 		task_for_first(task, &queue->tasks[0])
 			rpc_wake_up_task_queue_locked(queue, task);
 	}
-	spin_unlock(&queue->lock);
-	rcu_read_unlock_bh();
+	spin_unlock_bh(&queue->lock);
 
 	return task;
 }
@@ -488,8 +484,7 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 	struct rpc_task *task, *next;
 	struct list_head *head;
 
-	rcu_read_lock_bh();
-	spin_lock(&queue->lock);
+	spin_lock_bh(&queue->lock);
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
@@ -498,8 +493,7 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 			break;
 		head--;
 	}
-	spin_unlock(&queue->lock);
-	rcu_read_unlock_bh();
+	spin_unlock_bh(&queue->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up);
 
@@ -515,8 +509,7 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 	struct rpc_task *task, *next;
 	struct list_head *head;
 
-	rcu_read_lock_bh();
-	spin_lock(&queue->lock);
+	spin_lock_bh(&queue->lock);
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
@@ -527,8 +520,7 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 			break;
 		head--;
 	}
-	spin_unlock(&queue->lock);
-	rcu_read_unlock_bh();
+	spin_unlock_bh(&queue->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 
@@ -843,13 +835,6 @@ rpc_alloc_task(void)
 	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
 }
 
-static void rpc_free_task_rcu(struct rcu_head *rcu)
-{
-	struct rpc_task *task = container_of(rcu, struct rpc_task, u.tk_rcu);
-	dprintk("RPC: %5u freeing task\n", task->tk_pid);
-	mempool_free(task, rpc_task_mempool);
-}
-
 /*
  * Create a new task for the specified client.
  */
@@ -878,8 +863,10 @@ static void rpc_free_task(struct rpc_task *task)
 	const struct rpc_call_ops *tk_ops = task->tk_ops;
 	void *calldata = task->tk_calldata;
 
-	if (task->tk_flags & RPC_TASK_DYNAMIC)
-		call_rcu_bh(&task->u.tk_rcu, rpc_free_task_rcu);
+	if (task->tk_flags & RPC_TASK_DYNAMIC) {
+		dprintk("RPC: %5u freeing task\n", task->tk_pid);
+		mempool_free(task, rpc_task_mempool);
+	}
 	rpc_release_calldata(tk_ops, calldata);
 }
 

