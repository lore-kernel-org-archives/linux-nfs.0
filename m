Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38553 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752673AbeCPOdq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:33:46 -0400
Received: by mail-it0-f68.google.com with SMTP id r10-v6so2046176iti.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 07:33:46 -0700 (PDT)
Subject: [PATCH 1/3] sunrpc: Simplify synopsis of some trace points
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:33:44 -0400
Message-ID: <20180316143344.14289.55848.stgit@manet.1015granger.net>
In-Reply-To: <20180316142858.14289.44885.stgit@manet.1015granger.net>
References: <20180316142858.14289.44885.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: struct rpc_task carries a pointer to a struct rpc_clnt,
and in fact task->tk_client is always what is passed into trace
points that are already passing @task.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   40 +++++++++++++++++++++-------------------
 net/sunrpc/clnt.c             |    2 +-
 net/sunrpc/sched.c            |   10 +++++-----
 3 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 970c91a..53bbaea 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -50,9 +50,9 @@
 );
 
 TRACE_EVENT(rpc_connect_status,
-	TP_PROTO(struct rpc_task *task, int status),
+	TP_PROTO(const struct rpc_task *task),
 
-	TP_ARGS(task, status),
+	TP_ARGS(task),
 
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
@@ -63,7 +63,7 @@
 	TP_fast_assign(
 		__entry->task_id = task->tk_pid;
 		__entry->client_id = task->tk_client->cl_clid;
-		__entry->status = status;
+		__entry->status = task->tk_status;
 	),
 
 	TP_printk("task:%u@%u status=%d",
@@ -103,9 +103,9 @@
 
 DECLARE_EVENT_CLASS(rpc_task_running,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+	TP_PROTO(const struct rpc_task *task, const void *action),
 
-	TP_ARGS(clnt, task, action),
+	TP_ARGS(task, action),
 
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
@@ -117,7 +117,8 @@
 		),
 
 	TP_fast_assign(
-		__entry->client_id = clnt ? clnt->cl_clid : -1;
+		__entry->client_id = task->tk_client ?
+				     task->tk_client->cl_clid : -1;
 		__entry->task_id = task->tk_pid;
 		__entry->action = action;
 		__entry->runstate = task->tk_runstate;
@@ -136,33 +137,33 @@
 
 DEFINE_EVENT(rpc_task_running, rpc_task_begin,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+	TP_PROTO(const struct rpc_task *task, const void *action),
 
-	TP_ARGS(clnt, task, action)
+	TP_ARGS(task, action)
 
 );
 
 DEFINE_EVENT(rpc_task_running, rpc_task_run_action,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+	TP_PROTO(const struct rpc_task *task, const void *action),
 
-	TP_ARGS(clnt, task, action)
+	TP_ARGS(task, action)
 
 );
 
 DEFINE_EVENT(rpc_task_running, rpc_task_complete,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+	TP_PROTO(const struct rpc_task *task, const void *action),
 
-	TP_ARGS(clnt, task, action)
+	TP_ARGS(task, action)
 
 );
 
 DECLARE_EVENT_CLASS(rpc_task_queued,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+	TP_PROTO(const struct rpc_task *task, const struct rpc_wait_queue *q),
 
-	TP_ARGS(clnt, task, q),
+	TP_ARGS(task, q),
 
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
@@ -175,7 +176,8 @@
 		),
 
 	TP_fast_assign(
-		__entry->client_id = clnt ? clnt->cl_clid : -1;
+		__entry->client_id = task->tk_client ?
+				     task->tk_client->cl_clid : -1;
 		__entry->task_id = task->tk_pid;
 		__entry->timeout = task->tk_timeout;
 		__entry->runstate = task->tk_runstate;
@@ -196,17 +198,17 @@
 
 DEFINE_EVENT(rpc_task_queued, rpc_task_sleep,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+	TP_PROTO(const struct rpc_task *task, const struct rpc_wait_queue *q),
 
-	TP_ARGS(clnt, task, q)
+	TP_ARGS(task, q)
 
 );
 
 DEFINE_EVENT(rpc_task_queued, rpc_task_wakeup,
 
-	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+	TP_PROTO(const struct rpc_task *task, const struct rpc_wait_queue *q),
 
-	TP_ARGS(clnt, task, q)
+	TP_ARGS(task, q)
 
 );
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 226f558..3acfa01 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1888,7 +1888,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 
 	dprint_status(task);
 
-	trace_rpc_connect_status(task, status);
+	trace_rpc_connect_status(task);
 	task->tk_status = 0;
 	switch (status) {
 	case -ECONNREFUSED:
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d9db2ea..3fe5d60 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -276,7 +276,7 @@ static void rpc_set_active(struct rpc_task *task)
 {
 	rpc_task_set_debuginfo(task);
 	set_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
-	trace_rpc_task_begin(task->tk_client, task, NULL);
+	trace_rpc_task_begin(task, NULL);
 }
 
 /*
@@ -291,7 +291,7 @@ static int rpc_complete_task(struct rpc_task *task)
 	unsigned long flags;
 	int ret;
 
-	trace_rpc_task_complete(task->tk_client, task, NULL);
+	trace_rpc_task_complete(task, NULL);
 
 	spin_lock_irqsave(&wq->lock, flags);
 	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
@@ -358,7 +358,7 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
 			task->tk_pid, rpc_qname(q), jiffies);
 
-	trace_rpc_task_sleep(task->tk_client, task, q);
+	trace_rpc_task_sleep(task, q);
 
 	__rpc_add_wait_queue(q, task, queue_priority);
 
@@ -428,7 +428,7 @@ static void __rpc_do_wake_up_task_on_wq(struct workqueue_struct *wq,
 		return;
 	}
 
-	trace_rpc_task_wakeup(task->tk_client, task, queue);
+	trace_rpc_task_wakeup(task, queue);
 
 	__rpc_remove_wait_queue(queue, task);
 
@@ -780,7 +780,7 @@ static void __rpc_execute(struct rpc_task *task)
 		}
 		if (!do_action)
 			break;
-		trace_rpc_task_run_action(task->tk_client, task, do_action);
+		trace_rpc_task_run_action(task, do_action);
 		do_action(task);
 
 		/*

