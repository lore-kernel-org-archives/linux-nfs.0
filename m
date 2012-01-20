Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049Ab2ATUMt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 15:12:49 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Add trace events to the sunrpc subsystem
Date: Fri, 20 Jan 2012 15:12:44 -0500
Message-Id: <1327090364-6549-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add declarations to allow tracing of RPC call creation, running, sleeping,
and destruction.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/sched.h  |    2 +-
 include/trace/events/sunrpc.h |  124 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c            |   12 ++++
 3 files changed, 137 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/sunrpc.h

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index bd337f9..f7b2df5 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -271,7 +271,7 @@ static inline int rpc_task_has_priority(struct rpc_task *task, unsigned char pri
 }
 
 #ifdef RPC_DEBUG
-static inline const char * rpc_qname(struct rpc_wait_queue *q)
+static inline const char * rpc_qname(const struct rpc_wait_queue *q)
 {
 	return ((q && q->name) ? q->name : "unknown");
 }
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
new file mode 100644
index 0000000..51cc949
--- /dev/null
+++ b/include/trace/events/sunrpc.h
@@ -0,0 +1,124 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sunrpc
+
+#if !defined(_TRACE_SUNRPC_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SUNRPC_H
+
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/tracepoint.h>
+
+DECLARE_EVENT_CLASS(rpc_task_running,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+
+	TP_ARGS(clnt, task, action),
+
+	TP_STRUCT__entry(
+		__field(const struct rpc_clnt *, clnt)
+		__field(const struct rpc_task *, task)
+		__field(const void *, action)
+		__field(unsigned long, runstate)
+		__field(int, status)
+		__field(unsigned short, flags)
+		),
+
+	TP_fast_assign(
+		__entry->clnt = clnt;
+		__entry->task = task;
+		__entry->action = action;
+		__entry->runstate = task->tk_runstate;
+		__entry->status = task->tk_status;
+		__entry->flags = task->tk_flags;
+		),
+
+	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d action=%pf",
+		__entry->task,
+		__entry->clnt,
+		__entry->flags,
+		__entry->runstate,
+		__entry->status,
+		__entry->action
+		)
+);
+
+DEFINE_EVENT(rpc_task_running, rpc_task_begin,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+
+	TP_ARGS(clnt, task, action)
+
+);
+
+DEFINE_EVENT(rpc_task_running, rpc_task_run_action,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+
+	TP_ARGS(clnt, task, action)
+
+);
+
+DEFINE_EVENT(rpc_task_running, rpc_task_complete,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
+
+	TP_ARGS(clnt, task, action)
+
+);
+
+DECLARE_EVENT_CLASS(rpc_task_queued,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+
+	TP_ARGS(clnt, task, q),
+
+	TP_STRUCT__entry(
+		__field(const struct rpc_clnt *, clnt)
+		__field(const struct rpc_task *, task)
+		__field(const struct rpc_wait_queue *, queue)
+		__field(unsigned long, timeout)
+		__field(unsigned long, runstate)
+		__field(int, status)
+		__field(unsigned short, flags)
+		),
+
+	TP_fast_assign(
+		__entry->clnt = clnt;
+		__entry->task = task;
+		__entry->queue = q;
+		__entry->timeout = task->tk_timeout;
+		__entry->runstate = task->tk_runstate;
+		__entry->status = task->tk_status;
+		__entry->flags = task->tk_flags;
+		),
+
+	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
+		__entry->task,
+		__entry->clnt,
+		__entry->flags,
+		__entry->runstate,
+		__entry->status,
+		__entry->timeout,
+		rpc_qname(__entry->queue)
+		)
+);
+
+DEFINE_EVENT(rpc_task_queued, rpc_task_sleep,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+
+	TP_ARGS(clnt, task, q)
+
+);
+
+DEFINE_EVENT(rpc_task_queued, rpc_task_wakeup,
+
+	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
+
+	TP_ARGS(clnt, task, q)
+
+);
+
+#endif /* _TRACE_SUNRPC_H */
+
+#include <trace/define_trace.h>
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index f982dfe..d79c63d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -28,6 +28,9 @@
 #define RPCDBG_FACILITY		RPCDBG_SCHED
 #endif
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/sunrpc.h>
+
 /*
  * RPC slabs and memory pools
  */
@@ -251,6 +254,8 @@ static inline void rpc_task_set_debuginfo(struct rpc_task *task)
 
 static void rpc_set_active(struct rpc_task *task)
 {
+	trace_rpc_task_begin(task->tk_client, task, NULL);
+
 	rpc_task_set_debuginfo(task);
 	set_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
 }
@@ -267,6 +272,8 @@ static int rpc_complete_task(struct rpc_task *task)
 	unsigned long flags;
 	int ret;
 
+	trace_rpc_task_complete(task->tk_client, task, NULL);
+
 	spin_lock_irqsave(&wq->lock, flags);
 	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
 	ret = atomic_dec_and_test(&task->tk_count);
@@ -324,6 +331,8 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
 			task->tk_pid, rpc_qname(q), jiffies);
 
+	trace_rpc_task_sleep(task->tk_client, task, q);
+
 	__rpc_add_wait_queue(q, task, queue_priority);
 
 	BUG_ON(task->tk_callback != NULL);
@@ -378,6 +387,8 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
 		return;
 	}
 
+	trace_rpc_task_wakeup(task->tk_client, task, queue);
+
 	__rpc_remove_wait_queue(queue, task);
 
 	rpc_make_runnable(task);
@@ -701,6 +712,7 @@ static void __rpc_execute(struct rpc_task *task)
 			if (do_action == NULL)
 				break;
 		}
+		trace_rpc_task_run_action(task->tk_client, task, task->tk_action);
 		do_action(task);
 
 		/*
-- 
1.7.7.5

