Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47347 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A5J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 19:57:09 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 30 Nov 2011 11:52:51 +1100
Subject: [PATCH 2/2] sunrpc: wake up SOFTCONN tasks when a connection error
 happens.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20111130005251.23632.16655.stgit@notabene.brown>
In-Reply-To: <20111130005231.23632.87382.stgit@notabene.brown>
References: <20111130005231.23632.87382.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A 'SOFTCONN' task should fail if there is an error or a major timeout
during connection.

However errors are currently converted into a timeout (60seconds for
TCP) which is treated as a minor timeout and 3 of these are required
before failure.

The result of this is that if you try to mount an NFSv4 filesystem
(which doesn't require rpcbind and the failure modes that provides)
from a server which you do not have a route to (an so get
NETUNREACHABLE), you have an unnecessary 3 minutes timeout.

So when ENETUNREACH is reported for a connection - or other errors
which are fatal, wake up any SOFTCONN tasks with that error - rather
than letting them wait 60 seconds and then generate ETIMEDOUT.

This causes the above mentioned mount attempt to fail instantly.

This patch unifies rpc_wake_up and rpc_wake_up_status and adds a
'flag' option so we can just wake tasks with a given flag.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 include/linux/sunrpc/sched.h   |    7 +++++--
 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 net/sunrpc/rpcb_clnt.c         |    2 +-
 net/sunrpc/sched.c             |   39 +++++++++------------------------------
 net/sunrpc/xprt.c              |    2 +-
 net/sunrpc/xprtsock.c          |    6 +++++-
 6 files changed, 23 insertions(+), 37 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index e775689..f4af625 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -233,9 +233,12 @@ void		rpc_sleep_on_priority(struct rpc_wait_queue *,
 					int priority);
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
-void		rpc_wake_up(struct rpc_wait_queue *);
+void		rpc_wake_up_status(struct rpc_wait_queue *, int, int);
+static inline void rpc_wake_up(struct rpc_wait_queue *q)
+{
+	rpc_wake_up_status(q, 0, 0);
+}
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
-void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 int		rpc_queue_empty(struct rpc_wait_queue *);
 void		rpc_delay(struct rpc_task *, unsigned long);
 void *		rpc_malloc(struct rpc_task *, size_t);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index afb5655..15701d9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -334,7 +334,7 @@ static void
 __gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 {
 	list_del_init(&gss_msg->list);
-	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno, 0);
 	wake_up_all(&gss_msg->waitqueue);
 	atomic_dec(&gss_msg->count);
 }
@@ -367,7 +367,7 @@ gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss
 	}
 	gss_cred->gc_upcall_timestamp = jiffies;
 	gss_cred->gc_upcall = NULL;
-	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno, 0);
 }
 
 static void
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8761bf8..aadcf24 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -151,7 +151,7 @@ static const struct rpc_call_ops rpcb_getport_ops = {
 static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 {
 	xprt_clear_binding(xprt);
-	rpc_wake_up_status(&xprt->binding, status);
+	rpc_wake_up_status(&xprt->binding, status, 0);
 }
 
 static void rpcb_map_release(void *data)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..02617b8 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -493,12 +493,14 @@ struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
 EXPORT_SYMBOL_GPL(rpc_wake_up_next);
 
 /**
- * rpc_wake_up - wake up all rpc_tasks
+ * rpc_wake_up_status - wake up some or all rpc_tasks
  * @queue: rpc_wait_queue on which the tasks are sleeping
+ * @status: status to set, or zero
+ * @flag:  only wake tasks with this flag set.
  *
  * Grabs queue->lock
  */
-void rpc_wake_up(struct rpc_wait_queue *queue)
+void rpc_wake_up_status(struct rpc_wait_queue *queue, int status, int flag)
 {
 	struct rpc_task *task, *next;
 	struct list_head *head;
@@ -507,34 +509,11 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
-			rpc_wake_up_task_queue_locked(queue, task);
-		if (head == &queue->tasks[0])
-			break;
-		head--;
-	}
-	spin_unlock_bh(&queue->lock);
-}
-EXPORT_SYMBOL_GPL(rpc_wake_up);
-
-/**
- * rpc_wake_up_status - wake up all rpc_tasks and set their status value.
- * @queue: rpc_wait_queue on which the tasks are sleeping
- * @status: status value to set
- *
- * Grabs queue->lock
- */
-void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
-{
-	struct rpc_task *task, *next;
-	struct list_head *head;
-
-	spin_lock_bh(&queue->lock);
-	head = &queue->tasks[queue->maxpriority];
-	for (;;) {
-		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
-			task->tk_status = status;
-			rpc_wake_up_task_queue_locked(queue, task);
-		}
+			if (flag == 0 || (task->tk_flags & flag)) {
+				if (status)
+					task->tk_status = status;
+				rpc_wake_up_task_queue_locked(queue, task);
+			}
 		if (head == &queue->tasks[0])
 			break;
 		head--;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f4385e4..1603bb9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -471,7 +471,7 @@ EXPORT_SYMBOL_GPL(xprt_adjust_cwnd);
 void xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status)
 {
 	if (status < 0)
-		rpc_wake_up_status(&xprt->pending, status);
+		rpc_wake_up_status(&xprt->pending, status, 0);
 	else
 		rpc_wake_up(&xprt->pending);
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..d1bb5d4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2157,7 +2157,11 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
-		/* retry with existing socket, after a delay */
+		/* Retry with existing socket after a delay, except
+		 * for SOFTCONN tasks which fail. */
+		xprt_clear_connecting(xprt);
+		rpc_wake_up_status(&xprt->pending, status, RPC_TASK_SOFTCONN);
+		return;
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:


