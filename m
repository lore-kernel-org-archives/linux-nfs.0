Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:34219 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755147Ab2BFPIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 10:08:23 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 2/2] SUNRPC: Adding status trace points
Date: Mon,  6 Feb 2012 10:08:08 -0500
Message-Id: <1328540888-30109-3-git-send-email-steved@redhat.com>
In-Reply-To: <1328540888-30109-1-git-send-email-steved@redhat.com>
References: <1328540888-30109-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds three trace points to the status routines
in the sunrpc state machine.

The goal of these trace points is to give an Admin
the ability to check on binding status or connection
status to see if there is a potential problem.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/trace/events/sunrpc.h |   53 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    6 ++++-
 2 files changed, 58 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 2f82de9..abcf45d 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -8,6 +8,59 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/tracepoint.h>
 
+DECLARE_EVENT_CLASS(rpc_task_status,
+
+	TP_PROTO(struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(const struct rpc_task *, task)
+		__field(const struct rpc_clnt *, clnt)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->task = task;
+		__entry->clnt = task->tk_client;
+		__entry->status = task->tk_status;
+	),
+
+	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
+);
+
+DEFINE_EVENT(rpc_task_status, rpc_call_status,
+	TP_PROTO(struct rpc_task *task), 
+
+	TP_ARGS(task)
+);
+
+DEFINE_EVENT(rpc_task_status, rpc_bind_status,
+	TP_PROTO(struct rpc_task *task), 
+
+	TP_ARGS(task)
+);
+
+TRACE_EVENT(rpc_connect_status,
+	TP_PROTO(struct rpc_task *task, int status),
+
+	TP_ARGS(task, status),
+
+	TP_STRUCT__entry(
+		__field(const struct rpc_task *, task)
+		__field(const struct rpc_clnt *, clnt)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->task = task;
+		__entry->clnt = task->tk_client;
+		__entry->status = status;
+	),
+
+	TP_printk("task:%p@%p, status %d",__entry->task, __entry->clnt, __entry->status)
+);
+
 DECLARE_EVENT_CLASS(rpc_task_running,
 
 	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f0268ea..130809a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -36,6 +36,8 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <trace/events/sunrpc.h>
+
 
 #include "sunrpc.h"
 
@@ -55,7 +57,6 @@ static DEFINE_SPINLOCK(rpc_client_lock);
 
 static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
 
-
 static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
@@ -1163,6 +1164,7 @@ call_bind_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_bind_status(task);
 	switch (task->tk_status) {
 	case -ENOMEM:
 		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
@@ -1262,6 +1264,7 @@ call_connect_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_connect_status(task, status);
 	switch (status) {
 		/* if soft mounted, test if we've timed out */
 	case -ETIMEDOUT:
@@ -1450,6 +1453,7 @@ call_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_call_status(task);
 	task->tk_status = 0;
 	switch(status) {
 	case -EHOSTDOWN:
-- 
1.7.7.5

