Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:34223 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755092Ab2BFPIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 10:08:23 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 1/2] SUNRPC: Add trace events to the sunrpc subsystem
Date: Mon,  6 Feb 2012 10:08:07 -0500
Message-Id: <1328540888-30109-2-git-send-email-steved@redhat.com>
In-Reply-To: <1328540888-30109-1-git-send-email-steved@redhat.com>
References: <1328540888-30109-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add declarations to allow tracing of RPC call creation, running,
sleeping, and destruction.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/sched.h  |    2 +-
 include/trace/events/sunrpc.h |  124 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c            |   12 ++++
 3 files changed, 137 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/sunrpc.h

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index e775689..c600035 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -267,7 +267,7 @@ static inline int rpc_task_has_priority(struct rpc_task *task, unsigned char pri
 }
 
 #ifdef RPC_DEBUG
-static inline const char * rpc_qname(struct rpc_wait_queue *q)
+static inline const char * rpc_qname(const struct rpc_wait_queue *q)
 {
 	return ((q && q->name) ? q->name : "unknown");
 }
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
new file mode 100644
index 0000000..2f82de9
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
+		__string(    qname, rpc_qname(q))
+		__field(unsigned long, timeout)
+		__field(unsigned long, runstate)
+		__field(int, status)
+		__field(unsigned short, flags)
+		),
+
+	TP_fast_assign(
+		__entry->clnt = clnt;
+		__entry->task = task;
+		__assign_str(qname, rpc_qname(q));
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
+		__get_str(qname)
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
index 3341d89..2ba5739 100644
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
@@ -677,6 +688,7 @@ static void __rpc_execute(struct rpc_task *task)
 			if (do_action == NULL)
 				break;
 		}
+		trace_rpc_task_run_action(task->tk_client, task, task->tk_action);
 		do_action(task);
 
 		/*
-- 
1.7.7.5

