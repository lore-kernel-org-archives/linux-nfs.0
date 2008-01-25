From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 019/112] SUNRPC: Clean up the initialisation of priority
	queue scheduling info.
Date: Fri, 25 Jan 2008 11:37:28 -0500
Message-ID: <20080125163728.31887.25923.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755607AbYAYRAC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:02 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlo5019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:00 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want the default scheduling priority (priority == 0) to remain
RPC_PRIORITY_NORMAL.

Also ensure that the priority wait queue scheduling is per process id
instead of sometimes being per thread, and sometimes being per inode.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c              |   10 ----------
 fs/nfs/read.c                |    2 --
 fs/nfs/write.c               |   12 +++++-------
 include/linux/sunrpc/sched.h |   17 +++++++++--------
 net/sunrpc/sched.c           |   30 +++++++++++++++---------------
 5 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index f9f5fc1..5bcc764 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -331,8 +331,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->read_setup(data);
 
-		data->task.tk_cookie = (unsigned long) inode;
-
 		rpc_execute(&data->task);
 
 		dprintk("NFS: %5u initiated direct read call "
@@ -465,9 +463,6 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->write_setup(data, FLUSH_STABLE);
 
-		data->task.tk_priority = RPC_PRIORITY_NORMAL;
-		data->task.tk_cookie = (unsigned long) inode;
-
 		/*
 		 * We're called via an RPC callback, so BKL is already held.
 		 */
@@ -534,8 +529,6 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(data->inode)->commit_setup(data, 0);
 
-	data->task.tk_priority = RPC_PRIORITY_NORMAL;
-	data->task.tk_cookie = (unsigned long)data->inode;
 	/* Note: task.tk_ops->rpc_release will free dreq->commit_data */
 	dreq->commit_data = NULL;
 
@@ -718,9 +711,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->write_setup(data, sync);
 
-		data->task.tk_priority = RPC_PRIORITY_NORMAL;
-		data->task.tk_cookie = (unsigned long) inode;
-
 		rpc_execute(&data->task);
 
 		dprintk("NFS: %5u initiated direct write call "
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c7f0d5e..8f1eb08 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -189,8 +189,6 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->read_setup(data);
 
-	data->task.tk_cookie = (unsigned long)inode;
-
 	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 			data->task.tk_pid,
 			inode->i_sb->s_id,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c437660..8d90e90 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -753,7 +753,7 @@ static void nfs_writepage_release(struct nfs_page *req)
 	nfs_clear_page_tag_locked(req);
 }
 
-static inline int flush_task_priority(int how)
+static int flush_task_priority(int how)
 {
 	switch (how & (FLUSH_HIGHPRI|FLUSH_LOWPRI)) {
 		case FLUSH_HIGHPRI:
@@ -775,11 +775,13 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
+	int priority = flush_task_priority(how);
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.flags = flags,
+		.priority = priority,
 	};
 
 	/* Set up the RPC argument and reply structs
@@ -805,9 +807,6 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->write_setup(data, how);
 
-	data->task.tk_priority = flush_task_priority(how);
-	data->task.tk_cookie = (unsigned long)inode;
-
 	dprintk("NFS: %5u initiated write call "
 		"(req %s/%Ld, %u bytes @ offset %Lu)\n",
 		data->task.tk_pid,
@@ -1152,11 +1151,13 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	struct nfs_page *first = nfs_list_entry(head->next);
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
+	int priority = flush_task_priority(how);
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
 		.callback_ops = &nfs_commit_ops,
 		.callback_data = data,
 		.flags = flags,
+		.priority = priority,
 	};
 
 	/* Set up the RPC argument and reply structs
@@ -1180,9 +1181,6 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->commit_setup(data, how);
 
-	data->task.tk_priority = flush_task_priority(how);
-	data->task.tk_cookie = (unsigned long)inode;
-	
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 }
 
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d974421..c9444fd 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -56,8 +56,6 @@ struct rpc_task {
 	__u8			tk_garb_retry;
 	__u8			tk_cred_retry;
 
-	unsigned long		tk_cookie;	/* Cookie for batching tasks */
-
 	/*
 	 * timeout_fn   to be executed by timer bottom half
 	 * callback	to be executed after waking up
@@ -78,7 +76,6 @@ struct rpc_task {
 	struct timer_list	tk_timer;	/* kernel timer */
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
 	unsigned short		tk_flags;	/* misc flags */
-	unsigned char		tk_priority : 2;/* Task priority */
 	unsigned long		tk_runstate;	/* Task run status */
 	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
 						 * be any workqueue
@@ -94,6 +91,9 @@ struct rpc_task {
 	unsigned long		tk_start;	/* RPC task init timestamp */
 	long			tk_rtt;		/* round-trip time (jiffies) */
 
+	pid_t			tk_owner;	/* Process id for batching tasks */
+	unsigned char		tk_priority : 2;/* Task priority */
+
 #ifdef RPC_DEBUG
 	unsigned short		tk_pid;		/* debugging aid */
 #endif
@@ -123,6 +123,7 @@ struct rpc_task_setup {
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
 	unsigned short flags;
+	signed char priority;
 };
 
 /*
@@ -187,10 +188,10 @@ struct rpc_task_setup {
  * Note: if you change these, you must also change
  * the task initialization definitions below.
  */
-#define RPC_PRIORITY_LOW	0
-#define RPC_PRIORITY_NORMAL	1
-#define RPC_PRIORITY_HIGH	2
-#define RPC_NR_PRIORITY		(RPC_PRIORITY_HIGH+1)
+#define RPC_PRIORITY_LOW	(-1)
+#define RPC_PRIORITY_NORMAL	(0)
+#define RPC_PRIORITY_HIGH	(1)
+#define RPC_NR_PRIORITY		(1 + RPC_PRIORITY_HIGH - RPC_PRIORITY_LOW)
 
 /*
  * RPC synchronization objects
@@ -198,7 +199,7 @@ struct rpc_task_setup {
 struct rpc_wait_queue {
 	spinlock_t		lock;
 	struct list_head	tasks[RPC_NR_PRIORITY];	/* task queue for each priority level */
-	unsigned long		cookie;			/* cookie of last task serviced */
+	pid_t			owner;			/* process id of last task serviced */
 	unsigned char		maxpriority;		/* maximum priority (0 if queue is not a priority queue) */
 	unsigned char		priority;		/* current priority */
 	unsigned char		count;			/* # task groups remaining serviced so far */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 2bcaef5..0adbddb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -135,7 +135,7 @@ static void __rpc_add_wait_queue_priority(struct rpc_wait_queue *queue, struct r
 	if (unlikely(task->tk_priority > queue->maxpriority))
 		q = &queue->tasks[queue->maxpriority];
 	list_for_each_entry(t, q, u.tk_wait.list) {
-		if (t->tk_cookie == task->tk_cookie) {
+		if (t->tk_owner == task->tk_owner) {
 			list_add_tail(&task->u.tk_wait.list, &t->u.tk_wait.links);
 			return;
 		}
@@ -208,26 +208,26 @@ static inline void rpc_set_waitqueue_priority(struct rpc_wait_queue *queue, int
 	queue->count = 1 << (priority * 2);
 }
 
-static inline void rpc_set_waitqueue_cookie(struct rpc_wait_queue *queue, unsigned long cookie)
+static inline void rpc_set_waitqueue_owner(struct rpc_wait_queue *queue, pid_t pid)
 {
-	queue->cookie = cookie;
+	queue->owner = pid;
 	queue->nr = RPC_BATCH_COUNT;
 }
 
 static inline void rpc_reset_waitqueue_priority(struct rpc_wait_queue *queue)
 {
 	rpc_set_waitqueue_priority(queue, queue->maxpriority);
-	rpc_set_waitqueue_cookie(queue, 0);
+	rpc_set_waitqueue_owner(queue, 0);
 }
 
-static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const char *qname, int maxprio)
+static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const char *qname, unsigned char nr_queues)
 {
 	int i;
 
 	spin_lock_init(&queue->lock);
 	for (i = 0; i < ARRAY_SIZE(queue->tasks); i++)
 		INIT_LIST_HEAD(&queue->tasks[i]);
-	queue->maxpriority = maxprio;
+	queue->maxpriority = nr_queues - 1;
 	rpc_reset_waitqueue_priority(queue);
 #ifdef RPC_DEBUG
 	queue->name = qname;
@@ -236,12 +236,12 @@ static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const c
 
 void rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const char *qname)
 {
-	__rpc_init_priority_wait_queue(queue, qname, RPC_PRIORITY_HIGH);
+	__rpc_init_priority_wait_queue(queue, qname, RPC_NR_PRIORITY);
 }
 
 void rpc_init_wait_queue(struct rpc_wait_queue *queue, const char *qname)
 {
-	__rpc_init_priority_wait_queue(queue, qname, 0);
+	__rpc_init_priority_wait_queue(queue, qname, 1);
 }
 EXPORT_SYMBOL_GPL(rpc_init_wait_queue);
 
@@ -456,12 +456,12 @@ static struct rpc_task * __rpc_wake_up_next_priority(struct rpc_wait_queue *queu
 	struct rpc_task *task;
 
 	/*
-	 * Service a batch of tasks from a single cookie.
+	 * Service a batch of tasks from a single owner.
 	 */
 	q = &queue->tasks[queue->priority];
 	if (!list_empty(q)) {
 		task = list_entry(q->next, struct rpc_task, u.tk_wait.list);
-		if (queue->cookie == task->tk_cookie) {
+		if (queue->owner == task->tk_owner) {
 			if (--queue->nr)
 				goto out;
 			list_move_tail(&task->u.tk_wait.list, q);
@@ -470,7 +470,7 @@ static struct rpc_task * __rpc_wake_up_next_priority(struct rpc_wait_queue *queu
 		 * Check if we need to switch queues.
 		 */
 		if (--queue->count)
-			goto new_cookie;
+			goto new_owner;
 	}
 
 	/*
@@ -492,8 +492,8 @@ static struct rpc_task * __rpc_wake_up_next_priority(struct rpc_wait_queue *queu
 
 new_queue:
 	rpc_set_waitqueue_priority(queue, (unsigned int)(q - &queue->tasks[0]));
-new_cookie:
-	rpc_set_waitqueue_cookie(queue, task->tk_cookie);
+new_owner:
+	rpc_set_waitqueue_owner(queue, task->tk_owner);
 out:
 	__rpc_wake_up_task(task);
 	return task;
@@ -831,8 +831,8 @@ void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setu
 	task->tk_garb_retry = 2;
 	task->tk_cred_retry = 2;
 
-	task->tk_priority = RPC_PRIORITY_NORMAL;
-	task->tk_cookie = (unsigned long)current;
+	task->tk_priority = task_setup_data->priority - RPC_PRIORITY_LOW;
+	task->tk_owner = current->tgid;
 
 	/* Initialize workqueue for async tasks */
 	task->tk_workqueue = rpciod_workqueue;
