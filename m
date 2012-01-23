Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:47432 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753010Ab2AWTyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 14:54:44 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RpPyU-0003dQ-8C
	for linux-nfs@vger.kernel.org; Mon, 23 Jan 2012 14:54:42 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] SUNRPC: Adding status trace points
Date: Mon, 23 Jan 2012 14:54:40 -0500
Message-Id: <1327348480-32549-2-git-send-email-steved@redhat.com>
In-Reply-To: <1327348480-32549-1-git-send-email-steved@redhat.com>
References: <1327348480-32549-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds three trace points to the status routines
in the sunrpc state machine.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    4 +++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 1852f11..bca5ad3 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -8,6 +8,51 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/tracepoint.h>
 
+DECLARE_EVENT_CLASS(rpc_task_status,
+
+	TP_PROTO(struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->status = task->tk_status;
+	),
+
+	TP_printk("status %d", __entry->status)
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
+	TP_PROTO(int status),
+
+	TP_ARGS(status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+	),
+
+	TP_printk("status=%d", __entry->status)
+);
+
 DECLARE_EVENT_CLASS(rpc_task_running,
 
 	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f0268ea..bbe7385 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -55,6 +55,7 @@ static DEFINE_SPINLOCK(rpc_client_lock);
 
 static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
 
+#include <trace/events/sunrpc.h>
 
 static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
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
 
+	trace_rpc_connect_status(status);
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

