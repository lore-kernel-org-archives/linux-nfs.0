Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176Ab2AXUB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 15:01:58 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0OK1wZL004374
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 15:01:58 -0500
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q0OK1unx023893
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 15:01:57 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/2] SUNRPC: Adding status trace points
Date: Tue, 24 Jan 2012 15:51:47 -0500
Message-Id: <1327438307-2910-3-git-send-email-steved@redhat.com>
In-Reply-To: <1327438307-2910-1-git-send-email-steved@redhat.com>
References: <1327438307-2910-1-git-send-email-steved@redhat.com>
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
index b783f2f..89ea1f9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -38,6 +38,8 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <trace/events/sunrpc.h>
+
 
 #include "sunrpc.h"
 
@@ -57,7 +59,6 @@ static DEFINE_SPINLOCK(rpc_client_lock);
 
 static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
 
-
 static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
@@ -1159,6 +1160,7 @@ call_bind_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_bind_status(task);
 	switch (task->tk_status) {
 	case -ENOMEM:
 		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
@@ -1258,6 +1260,7 @@ call_connect_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_connect_status(task, status);
 	switch (status) {
 		/* if soft mounted, test if we've timed out */
 	case -ETIMEDOUT:
@@ -1446,6 +1449,7 @@ call_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_call_status(task);
 	task->tk_status = 0;
 	switch(status) {
 	case -EHOSTDOWN:
-- 
1.7.1

