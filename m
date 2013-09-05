Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43487 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab3IEC7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 22:59:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] SUNRPC: Replace pointer values with task->tk_pid and rpc_clnt->cl_clid
Date: Wed, 4 Sep 2013 22:58:40 -0400
Message-ID: <1378349920-31206-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378349920-31206-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1378349920-31206-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378349920-31206-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of the pointer values, use the task and client identifier values
for tracing purposes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/trace/events/sunrpc.h | 50 ++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index b74a8ac..d51d16c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -17,18 +17,20 @@ DECLARE_EVENT_CLASS(rpc_task_status,
 	TP_ARGS(task),
 
 	TP_STRUCT__entry(
-		__field(const struct rpc_task *, task)
-		__field(const struct rpc_clnt *, clnt)
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(int, status)
 	),
 
 	TP_fast_assign(
-		__entry->task = task;
-		__entry->clnt = task->tk_client;
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
 		__entry->status = task->tk_status;
 	),
 
-	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
+	TP_printk("task:%u@%u, status %d",
+		__entry->task_id, __entry->client_id,
+		__entry->status)
 );
 
 DEFINE_EVENT(rpc_task_status, rpc_call_status,
@@ -49,18 +51,20 @@ TRACE_EVENT(rpc_connect_status,
 	TP_ARGS(task, status),
 
 	TP_STRUCT__entry(
-		__field(const struct rpc_task *, task)
-		__field(const struct rpc_clnt *, clnt)
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(int, status)
 	),
 
 	TP_fast_assign(
-		__entry->task = task;
-		__entry->clnt = task->tk_client;
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
 		__entry->status = status;
 	),
 
-	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
+	TP_printk("task:%u@%u, status %d",
+		__entry->task_id, __entry->client_id,
+		__entry->status)
 );
 
 DECLARE_EVENT_CLASS(rpc_task_running,
@@ -70,8 +74,8 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 	TP_ARGS(clnt, task, action),
 
 	TP_STRUCT__entry(
-		__field(const struct rpc_clnt *, clnt)
-		__field(const struct rpc_task *, task)
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(const void *, action)
 		__field(unsigned long, runstate)
 		__field(int, status)
@@ -79,17 +83,16 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 		),
 
 	TP_fast_assign(
-		__entry->clnt = clnt;
-		__entry->task = task;
+		__entry->client_id = clnt->cl_clid;
+		__entry->task_id = task->tk_pid;
 		__entry->action = action;
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
 		__entry->flags = task->tk_flags;
 		),
 
-	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d action=%pf",
-		__entry->task,
-		__entry->clnt,
+	TP_printk("task:%u@%u flags=%4.4x state=%4.4lx status=%d action=%pf",
+		__entry->task_id, __entry->client_id,
 		__entry->flags,
 		__entry->runstate,
 		__entry->status,
@@ -128,8 +131,8 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 	TP_ARGS(clnt, task, q),
 
 	TP_STRUCT__entry(
-		__field(const struct rpc_clnt *, clnt)
-		__field(const struct rpc_task *, task)
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(unsigned long, timeout)
 		__field(unsigned long, runstate)
 		__field(int, status)
@@ -138,8 +141,8 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		),
 
 	TP_fast_assign(
-		__entry->clnt = clnt;
-		__entry->task = task;
+		__entry->client_id = clnt->cl_clid;
+		__entry->task_id = task->tk_pid;
 		__entry->timeout = task->tk_timeout;
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
@@ -147,9 +150,8 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		__assign_str(q_name, rpc_qname(q));
 		),
 
-	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
-		__entry->task,
-		__entry->clnt,
+	TP_printk("task:%u@%u flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
+		__entry->task_id, __entry->client_id,
 		__entry->flags,
 		__entry->runstate,
 		__entry->status,
-- 
1.8.3.1

