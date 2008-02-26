From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/10] SUNRPC: Run rpc timeout functions as callbacks
	instead of in softirqs
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.33259.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29320 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbYBZXiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:51 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmwv027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:50 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An audit of the current RPC timeout functions shows that they don't really
ever need to run in the softirq context. As long as the softirq is
able to signal that the wakeup is due to a timeout (which it can do by
setting task->tk_status to -ETIMEDOUT) then the callback functions can just
run as standard task->tk_callback functions (in the rpciod/process
context).

The only possible border-line case would be xprt_timer() for the case of
UDP, when the callback is used to reduce the size of the transport
congestion window. In testing, however, the effect of moving that update
to a callback would appear to be minor.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c              |    2 +-
 fs/nfs/nfs4state.c             |    2 +-
 include/linux/sunrpc/sched.h   |    4 +--
 net/sunrpc/auth_gss/auth_gss.c |    4 ++-
 net/sunrpc/rpcb_clnt.c         |    2 +-
 net/sunrpc/sched.c             |   50 ++++++++++++----------------------------
 net/sunrpc/xprt.c              |   28 ++++++++++++----------
 7 files changed, 36 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5474339..bbb0d58 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2765,7 +2765,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
-			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL, NULL);
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 			nfs4_schedule_state_recovery(clp);
 			if (test_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b962397..a2ef028 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -731,7 +731,7 @@ int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 		list_add_tail(&seqid->list, &sequence->list);
 	if (list_first_entry(&sequence->list, struct nfs_seqid, list) == seqid)
 		goto unlock;
-	rpc_sleep_on(&sequence->wait, task, NULL, NULL);
+	rpc_sleep_on(&sequence->wait, task, NULL);
 	status = -EAGAIN;
 unlock:
 	spin_unlock(&sequence->lock);
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7963ef0..503a937 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -56,12 +56,10 @@ struct rpc_task {
 	__u8			tk_cred_retry;
 
 	/*
-	 * timeout_fn   to be executed by timer bottom half
 	 * callback	to be executed after waking up
 	 * action	next procedure for async tasks
 	 * tk_ops	caller callbacks
 	 */
-	void			(*tk_timeout_fn)(struct rpc_task *);
 	void			(*tk_callback)(struct rpc_task *);
 	void			(*tk_action)(struct rpc_task *);
 	const struct rpc_call_ops *tk_ops;
@@ -231,7 +229,7 @@ void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
-					rpc_action action, rpc_action timer);
+					rpc_action action);
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6dac387..dc6391b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -408,13 +408,13 @@ gss_refresh_upcall(struct rpc_task *task)
 	}
 	spin_lock(&inode->i_lock);
 	if (gss_cred->gc_upcall != NULL)
-		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL, NULL);
+		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
 	else if (gss_msg->ctx == NULL && gss_msg->msg.errno >= 0) {
 		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
 		atomic_inc(&gss_msg->count);
-		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback, NULL);
+		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback);
 	} else
 		err = gss_msg->msg.errno;
 	spin_unlock(&inode->i_lock);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 3164a08..f480c71 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -298,7 +298,7 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	/* Put self on queue before sending rpcbind request, in case
 	 * rpcb_getport_done completes before we return from rpc_run_task */
-	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
+	rpc_sleep_on(&xprt->binding, task, NULL);
 
 	/* Someone else may have bound if we slept */
 	if (xprt_bound(xprt)) {
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 35acdc3..caf12fd 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -56,29 +56,18 @@ struct workqueue_struct *rpciod_workqueue;
  * queue->lock and bh_disabled in order to avoid races within
  * rpc_run_timer().
  */
-static inline void
+static void
 __rpc_disable_timer(struct rpc_task *task)
 {
 	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
-	task->tk_timeout_fn = NULL;
 	task->tk_timeout = 0;
 }
 
 /*
- * Default timeout handler if none specified by user
- */
-static void
-__rpc_default_timer(struct rpc_task *task)
-{
-	dprintk("RPC: %5u timeout (default timer)\n", task->tk_pid);
-	task->tk_status = -ETIMEDOUT;
-}
-
-/*
  * Set up a timer for the current task.
  */
-static inline void
-__rpc_add_timer(struct rpc_task *task, rpc_action timer)
+static void
+__rpc_add_timer(struct rpc_task *task)
 {
 	if (!task->tk_timeout)
 		return;
@@ -86,10 +75,6 @@ __rpc_add_timer(struct rpc_task *task, rpc_action timer)
 	dprintk("RPC: %5u setting alarm for %lu ms\n",
 			task->tk_pid, task->tk_timeout * 1000 / HZ);
 
-	if (timer)
-		task->tk_timeout_fn = timer;
-	else
-		task->tk_timeout_fn = __rpc_default_timer;
 	set_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
 	mod_timer(&task->tk_timer, jiffies + task->tk_timeout);
 }
@@ -297,7 +282,6 @@ EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
  */
 static void rpc_make_runnable(struct rpc_task *task)
 {
-	BUG_ON(task->tk_timeout_fn);
 	rpc_clear_queued(task);
 	if (rpc_test_and_set_running(task))
 		return;
@@ -327,7 +311,7 @@ static void rpc_make_runnable(struct rpc_task *task)
  * as it's on a wait queue.
  */
 static void __rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
-			rpc_action action, rpc_action timer)
+			rpc_action action)
 {
 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
 			task->tk_pid, rpc_qname(q), jiffies);
@@ -341,11 +325,11 @@ static void __rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 
 	BUG_ON(task->tk_callback != NULL);
 	task->tk_callback = action;
-	__rpc_add_timer(task, timer);
+	__rpc_add_timer(task);
 }
 
 void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
-				rpc_action action, rpc_action timer)
+				rpc_action action)
 {
 	/* Mark the task as being activated if so needed */
 	rpc_set_active(task);
@@ -354,7 +338,7 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 	 * Protect the queue operations.
 	 */
 	spin_lock_bh(&q->lock);
-	__rpc_sleep_on(q, task, action, timer);
+	__rpc_sleep_on(q, task, action);
 	spin_unlock_bh(&q->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_sleep_on);
@@ -559,20 +543,15 @@ EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 static void rpc_run_timer(unsigned long ptr)
 {
 	struct rpc_task *task = (struct rpc_task *)ptr;
-	void (*callback)(struct rpc_task *);
+	struct rpc_wait_queue *queue = task->tk_waitqueue;
 
-	if (RPC_IS_QUEUED(task)) {
-		struct rpc_wait_queue *queue = task->tk_waitqueue;
-		callback = task->tk_timeout_fn;
-
-		dprintk("RPC: %5u running timer\n", task->tk_pid);
-		if (callback != NULL)
-			callback(task);
-		/* Note: we're already in a bh-safe context */
-		spin_lock(&queue->lock);
+	spin_lock(&queue->lock);
+	if (RPC_IS_QUEUED(task) && task->tk_waitqueue == queue) {
+		dprintk("RPC: %5u timeout\n", task->tk_pid);
+		task->tk_status = -ETIMEDOUT;
 		rpc_wake_up_task_queue_locked(queue, task);
-		spin_unlock(&queue->lock);
 	}
+	spin_unlock(&queue->lock);
 	smp_mb__before_clear_bit();
 	clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate);
 	smp_mb__after_clear_bit();
@@ -580,6 +559,7 @@ static void rpc_run_timer(unsigned long ptr)
 
 static void __rpc_atrun(struct rpc_task *task)
 {
+	task->tk_status = 0;
 }
 
 /*
@@ -588,7 +568,7 @@ static void __rpc_atrun(struct rpc_task *task)
 void rpc_delay(struct rpc_task *task, unsigned long delay)
 {
 	task->tk_timeout = delay;
-	rpc_sleep_on(&delay_queue, task, NULL, __rpc_atrun);
+	rpc_sleep_on(&delay_queue, task, __rpc_atrun);
 }
 EXPORT_SYMBOL_GPL(rpc_delay);
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 6e27722..9bf118c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -188,9 +188,9 @@ out_sleep:
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (req && req->rq_ntrans)
-		rpc_sleep_on(&xprt->resend, task, NULL, NULL);
+		rpc_sleep_on(&xprt->resend, task, NULL);
 	else
-		rpc_sleep_on(&xprt->sending, task, NULL, NULL);
+		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
@@ -238,9 +238,9 @@ out_sleep:
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (req && req->rq_ntrans)
-		rpc_sleep_on(&xprt->resend, task, NULL, NULL);
+		rpc_sleep_on(&xprt->resend, task, NULL);
 	else
-		rpc_sleep_on(&xprt->sending, task, NULL, NULL);
+		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt_cong);
@@ -453,7 +453,7 @@ void xprt_wait_for_buffer_space(struct rpc_task *task)
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	task->tk_timeout = req->rq_timeout;
-	rpc_sleep_on(&xprt->pending, task, NULL, NULL);
+	rpc_sleep_on(&xprt->pending, task, NULL);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
 
@@ -652,7 +652,7 @@ void xprt_connect(struct rpc_task *task)
 			task->tk_rqstp->rq_bytes_sent = 0;
 
 		task->tk_timeout = xprt->connect_timeout;
-		rpc_sleep_on(&xprt->pending, task, xprt_connect_status, NULL);
+		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
 		xprt->stat.connect_start = jiffies;
 		xprt->ops->connect(task);
 	}
@@ -769,15 +769,17 @@ static void xprt_timer(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
+	if (task->tk_status != -ETIMEDOUT)
+		return;
 	dprintk("RPC: %5u xprt_timer\n", task->tk_pid);
 
-	spin_lock(&xprt->transport_lock);
+	spin_lock_bh(&xprt->transport_lock);
 	if (!req->rq_received) {
 		if (xprt->ops->timer)
 			xprt->ops->timer(task);
-		task->tk_status = -ETIMEDOUT;
-	}
-	spin_unlock(&xprt->transport_lock);
+	} else
+		task->tk_status = 0;
+	spin_unlock_bh(&xprt->transport_lock);
 }
 
 /**
@@ -862,7 +864,7 @@ void xprt_transmit(struct rpc_task *task)
 		if (!xprt_connected(xprt))
 			task->tk_status = -ENOTCONN;
 		else if (!req->rq_received)
-			rpc_sleep_on(&xprt->pending, task, NULL, xprt_timer);
+			rpc_sleep_on(&xprt->pending, task, xprt_timer);
 		spin_unlock_bh(&xprt->transport_lock);
 		return;
 	}
@@ -873,7 +875,7 @@ void xprt_transmit(struct rpc_task *task)
 	 */
 	task->tk_status = status;
 	if (status == -ECONNREFUSED)
-		rpc_sleep_on(&xprt->sending, task, NULL, NULL);
+		rpc_sleep_on(&xprt->sending, task, NULL);
 }
 
 static inline void do_xprt_reserve(struct rpc_task *task)
@@ -893,7 +895,7 @@ static inline void do_xprt_reserve(struct rpc_task *task)
 	dprintk("RPC:       waiting for request slot\n");
 	task->tk_status = -EAGAIN;
 	task->tk_timeout = 0;
-	rpc_sleep_on(&xprt->backlog, task, NULL, NULL);
+	rpc_sleep_on(&xprt->backlog, task, NULL);
 }
 
 /**

