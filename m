From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/4] SUNRPC: Allow the rpc_release() callback to be run on
	another workqueue
Date: Tue, 19 Feb 2008 18:04:59 -0500
Message-ID: <20080219230459.22007.36417.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080219230459.22007.10990.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53378 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558AbYBSXPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 18:15:05 -0500
In-Reply-To: <20080219230459.22007.10990.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A lot of the work done by the rpc_release() callback is inappropriate for
rpciod as it will often involve things like starting a new rpc call in
order to clean up state after an interrupted NFSv4 open() call, or
calls to mntput(), etc.

This patch allows the caller of rpc_run_task() to specify that the
rpc_release callback should run on a different workqueue than the default
rpciod_workqueue.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   29 +++++++++++++++++++++--------
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index f689f02..fefb0ab 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -123,6 +123,7 @@ struct rpc_task_setup {
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
+	struct workqueue_struct *workqueue;
 	unsigned short flags;
 	signed char priority;
 };
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 4c66912..3e0b223 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -326,7 +326,7 @@ static void rpc_make_runnable(struct rpc_task *task)
 		int status;
 
 		INIT_WORK(&task->u.tk_work, rpc_async_schedule);
-		status = queue_work(task->tk_workqueue, &task->u.tk_work);
+		status = queue_work(rpciod_workqueue, &task->u.tk_work);
 		if (status < 0) {
 			printk(KERN_WARNING "RPC: failed to add task to queue: error: %d!\n", status);
 			task->tk_status = status;
@@ -832,7 +832,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 	task->tk_owner = current->tgid;
 
 	/* Initialize workqueue for async tasks */
-	task->tk_workqueue = rpciod_workqueue;
+	task->tk_workqueue = task_setup_data->workqueue;
 
 	task->tk_client = task_setup_data->rpc_client;
 	if (task->tk_client != NULL) {
@@ -868,7 +868,7 @@ rpc_alloc_task(void)
 	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
 }
 
-static void rpc_free_task(struct rcu_head *rcu)
+static void rpc_free_task_rcu(struct rcu_head *rcu)
 {
 	struct rpc_task *task = container_of(rcu, struct rpc_task, u.tk_rcu);
 	dprintk("RPC: %5u freeing task\n", task->tk_pid);
@@ -898,12 +898,23 @@ out:
 	return task;
 }
 
-
-void rpc_put_task(struct rpc_task *task)
+static void rpc_free_task(struct rpc_task *task)
 {
 	const struct rpc_call_ops *tk_ops = task->tk_ops;
 	void *calldata = task->tk_calldata;
 
+	if (task->tk_flags & RPC_TASK_DYNAMIC)
+		call_rcu_bh(&task->u.tk_rcu, rpc_free_task_rcu);
+	rpc_release_calldata(tk_ops, calldata);
+}
+
+static void rpc_async_release(struct work_struct *work)
+{
+	rpc_free_task(container_of(work, struct rpc_task, u.tk_work));
+}
+
+void rpc_put_task(struct rpc_task *task)
+{
 	if (!atomic_dec_and_test(&task->tk_count))
 		return;
 	/* Release resources */
@@ -915,9 +926,11 @@ void rpc_put_task(struct rpc_task *task)
 		rpc_release_client(task->tk_client);
 		task->tk_client = NULL;
 	}
-	if (task->tk_flags & RPC_TASK_DYNAMIC)
-		call_rcu_bh(&task->u.tk_rcu, rpc_free_task);
-	rpc_release_calldata(tk_ops, calldata);
+	if (task->tk_workqueue != NULL) {
+		INIT_WORK(&task->u.tk_work, rpc_async_release);
+		queue_work(task->tk_workqueue, &task->u.tk_work);
+	} else
+		rpc_free_task(task);
 }
 EXPORT_SYMBOL_GPL(rpc_put_task);
 
