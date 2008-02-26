From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/10] SUNRPC: Clean up rpc_run_timer()
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.1040.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYBZXiu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:50 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmwt027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:49 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All RPC timeout callback functions are expected to wake the task up. We can
enforce this by moving the wakeup back into rpc_run_timer.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sched.c |   67 +++++++++++++++++++++++++++-------------------------
 net/sunrpc/xprt.c  |    2 --
 2 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 3e0b223..9433a11 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -38,7 +38,6 @@ static struct kmem_cache	*rpc_buffer_slabp __read_mostly;
 static mempool_t	*rpc_task_mempool __read_mostly;
 static mempool_t	*rpc_buffer_mempool __read_mostly;
 
-static void			__rpc_default_timer(struct rpc_task *task);
 static void			rpc_async_schedule(struct work_struct *);
 static void			 rpc_release_task(struct rpc_task *task);
 
@@ -66,25 +65,13 @@ __rpc_disable_timer(struct rpc_task *task)
 }
 
 /*
- * Run a timeout function.
- * We use the callback in order to allow __rpc_wake_up_task()
- * and friends to disable the timer synchronously on SMP systems
- * without calling del_timer_sync(). The latter could cause a
- * deadlock if called while we're holding spinlocks...
+ * Default timeout handler if none specified by user
  */
-static void rpc_run_timer(struct rpc_task *task)
+static void
+__rpc_default_timer(struct rpc_task *task)
 {
-	void (*callback)(struct rpc_task *);
-
-	callback = task->tk_timeout_fn;
-	task->tk_timeout_fn = NULL;
-	if (callback && RPC_IS_QUEUED(task)) {
-		dprintk("RPC: %5u running timer\n", task->tk_pid);
-		callback(task);
-	}
-	smp_mb__before_clear_bit();
-	clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
-	smp_mb__after_clear_bit();
+	dprintk("RPC: %5u timeout (default timer)\n", task->tk_pid);
+	task->tk_status = -ETIMEDOUT;
 }
 
 /*
@@ -416,17 +403,6 @@ static void __rpc_wake_up_task(struct rpc_task *task)
 }
 
 /*
- * Default timeout handler if none specified by user
- */
-static void
-__rpc_default_timer(struct rpc_task *task)
-{
-	dprintk("RPC: %5u timeout (default timer)\n", task->tk_pid);
-	task->tk_status = -ETIMEDOUT;
-	rpc_wake_up_task(task);
-}
-
-/*
  * Wake up the specified task
  */
 void rpc_wake_up_task(struct rpc_task *task)
@@ -578,9 +554,37 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 
+/*
+ * Run a timeout function.
+ */
+static void rpc_run_timer(unsigned long ptr)
+{
+	struct rpc_task *task = (struct rpc_task *)ptr;
+	void (*callback)(struct rpc_task *);
+
+	if (!rpc_start_wakeup(task))
+		goto out;
+	if (RPC_IS_QUEUED(task)) {
+		struct rpc_wait_queue *queue = task->u.tk_wait.rpc_waitq;
+		callback = task->tk_timeout_fn;
+
+		dprintk("RPC: %5u running timer\n", task->tk_pid);
+		if (callback != NULL)
+			callback(task);
+		/* Note: we're already in a bh-safe context */
+		spin_lock(&queue->lock);
+		__rpc_do_wake_up_task(task);
+		spin_unlock(&queue->lock);
+	}
+	rpc_finish_wakeup(task);
+out:
+	smp_mb__before_clear_bit();
+	clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
+	smp_mb__after_clear_bit();
+}
+
 static void __rpc_atrun(struct rpc_task *task)
 {
-	rpc_wake_up_task(task);
 }
 
 /*
@@ -816,8 +820,7 @@ EXPORT_SYMBOL_GPL(rpc_free);
 static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setup_data)
 {
 	memset(task, 0, sizeof(*task));
-	setup_timer(&task->tk_timer, (void (*)(unsigned long))rpc_run_timer,
-			(unsigned long)task);
+	setup_timer(&task->tk_timer, rpc_run_timer, (unsigned long)task);
 	atomic_set(&task->tk_count, 1);
 	task->tk_flags  = task_setup_data->flags;
 	task->tk_ops = task_setup_data->callback_ops;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d5553b8..96c212d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -777,8 +777,6 @@ static void xprt_timer(struct rpc_task *task)
 			xprt->ops->timer(task);
 		task->tk_status = -ETIMEDOUT;
 	}
-	task->tk_timeout = 0;
-	rpc_wake_up_task(task);
 	spin_unlock(&xprt->transport_lock);
 }
 

