Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40181 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756997Ab2ARERi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 23:17:38 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/10] SUNRPC: Fix potential races in xprt_lock_write_next()
Date: Tue, 17 Jan 2012 23:17:13 -0500
Message-Id: <1326860233-27947-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326860233-27947-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-3-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-4-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-5-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-6-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-7-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-8-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have to ensure that the wake up from the waitqueue and the assignment
of xprt->snd_task are atomic. We can do this by assigning the snd_task
while under the waitqueue spinlock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h             |    1 +
 fs/nfs/nfs4proc.c            |   13 ++++++----
 fs/nfs/nfs4state.c           |   17 ++++++-------
 include/linux/sunrpc/sched.h |    3 ++
 net/sunrpc/sched.c           |   42 ++++++++++++++++++++++++++++-------
 net/sunrpc/xprt.c            |   49 ++++++++++++++++++++++-------------------
 6 files changed, 79 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b7e5a1d..fbb1bc0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -222,6 +222,7 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 	return server->nfs_client->cl_session;
 }
 
+extern bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy);
 extern int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f2a4d32..734bd5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -385,17 +385,20 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 		free_slotid, tbl->highest_used_slotid);
 }
 
+bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy)
+{
+	rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
+	return true;
+}
+
 /*
  * Signal state manager thread if session fore channel is drained
  */
 static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
 {
-	struct rpc_task *task;
-
 	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
-		task = rpc_wake_up_next(&ses->fc_slot_table.slot_tbl_waitq);
-		if (task)
-			rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
+		rpc_wake_up_first(&ses->fc_slot_table.slot_tbl_waitq,
+				nfs4_set_task_privileged, NULL);
 		return;
 	}
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a42e60d..f0e9881 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -190,23 +190,22 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 static void nfs4_end_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
+	struct nfs4_slot_table *tbl;
 	int max_slots;
 
 	if (ses == NULL)
 		return;
+	tbl = &ses->fc_slot_table;
 	if (test_and_clear_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
-		spin_lock(&ses->fc_slot_table.slot_tbl_lock);
-		max_slots = ses->fc_slot_table.max_slots;
+		spin_lock(&tbl->slot_tbl_lock);
+		max_slots = tbl->max_slots;
 		while (max_slots--) {
-			struct rpc_task *task;
-
-			task = rpc_wake_up_next(&ses->fc_slot_table.
-						slot_tbl_waitq);
-			if (!task)
+			if (rpc_wake_up_first(&tbl->slot_tbl_waitq,
+						nfs4_set_task_privileged,
+						NULL) == NULL)
 				break;
-			rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
 		}
-		spin_unlock(&ses->fc_slot_table.slot_tbl_lock);
+		spin_unlock(&tbl->slot_tbl_lock);
 	}
 }
 
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index b16243a..bd337f9 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -235,6 +235,9 @@ void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
+struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
+					bool (*)(struct rpc_task *, void *),
+					void *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 int		rpc_queue_empty(struct rpc_wait_queue *);
 void		rpc_delay(struct rpc_task *, unsigned long);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 3341d89..7c8142e 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -422,7 +422,7 @@ EXPORT_SYMBOL_GPL(rpc_wake_up_queued_task);
 /*
  * Wake up the next task on a priority queue.
  */
-static struct rpc_task * __rpc_wake_up_next_priority(struct rpc_wait_queue *queue)
+static struct rpc_task *__rpc_find_next_queued_priority(struct rpc_wait_queue *queue)
 {
 	struct list_head *q;
 	struct rpc_task *task;
@@ -467,30 +467,54 @@ new_queue:
 new_owner:
 	rpc_set_waitqueue_owner(queue, task->tk_owner);
 out:
-	rpc_wake_up_task_queue_locked(queue, task);
 	return task;
 }
 
+static struct rpc_task *__rpc_find_next_queued(struct rpc_wait_queue *queue)
+{
+	if (RPC_IS_PRIORITY(queue))
+		return __rpc_find_next_queued_priority(queue);
+	if (!list_empty(&queue->tasks[0]))
+		return list_first_entry(&queue->tasks[0], struct rpc_task, u.tk_wait.list);
+	return NULL;
+}
+
 /*
- * Wake up the next task on the wait queue.
+ * Wake up the first task on the wait queue.
  */
-struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
+struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *queue,
+		bool (*func)(struct rpc_task *, void *), void *data)
 {
 	struct rpc_task	*task = NULL;
 
-	dprintk("RPC:       wake_up_next(%p \"%s\")\n",
+	dprintk("RPC:       wake_up_first(%p \"%s\")\n",
 			queue, rpc_qname(queue));
 	spin_lock_bh(&queue->lock);
-	if (RPC_IS_PRIORITY(queue))
-		task = __rpc_wake_up_next_priority(queue);
-	else {
-		task_for_first(task, &queue->tasks[0])
+	task = __rpc_find_next_queued(queue);
+	if (task != NULL) {
+		if (func(task, data))
 			rpc_wake_up_task_queue_locked(queue, task);
+		else
+			task = NULL;
 	}
 	spin_unlock_bh(&queue->lock);
 
 	return task;
 }
+EXPORT_SYMBOL_GPL(rpc_wake_up_first);
+
+static bool rpc_wake_up_next_func(struct rpc_task *task, void *data)
+{
+	return true;
+}
+
+/*
+ * Wake up the next task on the wait queue.
+*/
+struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
+{
+	return rpc_wake_up_first(queue, rpc_wake_up_next_func, NULL);
+}
 EXPORT_SYMBOL_GPL(rpc_wake_up_next);
 
 /**
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c64c0ef..839f6ef 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -292,54 +292,57 @@ static inline int xprt_lock_write(struct rpc_xprt *xprt, struct rpc_task *task)
 	return retval;
 }
 
-static void __xprt_lock_write_next(struct rpc_xprt *xprt)
+static bool __xprt_lock_write_func(struct rpc_task *task, void *data)
 {
-	struct rpc_task *task;
+	struct rpc_xprt *xprt = data;
 	struct rpc_rqst *req;
 
-	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
-		return;
-
-	task = rpc_wake_up_next(&xprt->sending);
-	if (task == NULL)
-		goto out_unlock;
-
 	req = task->tk_rqstp;
 	xprt->snd_task = task;
 	if (req) {
 		req->rq_bytes_sent = 0;
 		req->rq_ntrans++;
 	}
-	return;
+	return true;
+}
 
-out_unlock:
+static void __xprt_lock_write_next(struct rpc_xprt *xprt)
+{
+	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
+		return;
+
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_func, xprt))
+		return;
 	xprt_clear_locked(xprt);
 }
 
-static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
+static bool __xprt_lock_write_cong_func(struct rpc_task *task, void *data)
 {
-	struct rpc_task *task;
+	struct rpc_xprt *xprt = data;
 	struct rpc_rqst *req;
 
-	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
-		return;
-	if (RPCXPRT_CONGESTED(xprt))
-		goto out_unlock;
-	task = rpc_wake_up_next(&xprt->sending);
-	if (task == NULL)
-		goto out_unlock;
-
 	req = task->tk_rqstp;
 	if (req == NULL) {
 		xprt->snd_task = task;
-		return;
+		return true;
 	}
 	if (__xprt_get_cong(xprt, task)) {
 		xprt->snd_task = task;
 		req->rq_bytes_sent = 0;
 		req->rq_ntrans++;
-		return;
+		return true;
 	}
+	return false;
+}
+
+static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
+{
+	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
+		return;
+	if (RPCXPRT_CONGESTED(xprt))
+		goto out_unlock;
+	if (rpc_wake_up_first(&xprt->sending, __xprt_lock_write_cong_func, xprt))
+		return;
 out_unlock:
 	xprt_clear_locked(xprt);
 }
-- 
1.7.7.5

