From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] sunrpc: Adding trace points to status routines (take 2)
Date: Tue, 09 Jun 2009 14:18:49 -0400
Message-ID: <4A2EA789.60608@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux Kernel Mailing list <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@redhat.com>, Jason Baron <jbaron@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39631 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbZFISV7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 14:21:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

Here is an updated version of the patch I sent out a while
back... all that has changed was the addtion of 'rpc_'  to
the name of the trace points which coincides with the
other trace points naming convention.

Here is a pointer to the previous email that has the 
fairly long winded explanation of how all this works:

   http://marc.info/?l=linux-kernel&m=124058933520183&w=2

And below is the updated patch which is based on Ingo's
linux-2.6-tip.git tree. 

Comments?

steved.
 
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Jun  9 14:12:07 EDT 2009

    Adds three trace points to the status routines in the
    sunrpc state machine. The trace points will only execute
    in error conditions.
    
    The goal of these trace points it to make it easier to
    debug process that spin or get hung up in the NFS and
    related subsystems.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
new file mode 100644
index 0000000..f502eb4
--- /dev/null
+++ b/include/trace/events/sunrpc.h
@@ -0,0 +1,86 @@
+#if !defined(_TRACE_SUNRPC_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SUNRPC_H
+
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sunrpc
+
+TRACE_EVENT(rpc_call_status,
+
+	TP_PROTO(struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(u32, cl_prog)
+		__field(u32, cl_vers)
+		__field(u32, p_proc)
+		__field(int, tk_status)
+	),
+
+	TP_fast_assign(
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->cl_vers = task->tk_client->cl_vers;
+		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->tk_status = task->tk_status;
+	),
+
+	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
+		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
+);
+
+TRACE_EVENT(rpc_bind_status,
+
+	TP_PROTO(struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(u32, cl_prog)
+		__field(u32, cl_vers)
+		__field(u32, p_proc)
+		__field(int, tk_status)
+	),
+
+	TP_fast_assign(
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->cl_vers = task->tk_client->cl_vers;
+		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->tk_status = task->tk_status;
+	),
+
+	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
+		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
+);
+TRACE_EVENT(rpc_connect_status,
+
+	TP_PROTO(struct rpc_task *task, int status),
+
+	TP_ARGS(task, status),
+
+	TP_STRUCT__entry(
+		__field(u32, cl_prog)
+		__field(u32, cl_vers)
+		__field(u32, p_proc)
+		__field(int, tk_status)
+	),
+
+	TP_fast_assign(
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->cl_vers = task->tk_client->cl_vers;
+		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
+		__entry->cl_prog = task->tk_client->cl_prog;
+		__entry->tk_status = status;
+	),
+
+	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
+		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
+
+);
+#endif /* __TRACE_SUNRPC_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5abab09..b86ee2a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -37,6 +37,9 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/metrics.h>
 
+#include <linux/ftrace.h>
+#define CREATE_TRACE_POINTS
+#include <trace/events/sunrpc.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_CALL
@@ -957,6 +960,7 @@ call_bind_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_bind_status(task);
 	switch (task->tk_status) {
 	case -ENOMEM:
 		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
@@ -1038,6 +1042,7 @@ call_connect_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_connect_status(task, status);
 	switch (status) {
 		/* if soft mounted, test if we've timed out */
 	case -ETIMEDOUT:
@@ -1141,6 +1146,7 @@ call_status(struct rpc_task *task)
 		return;
 	}
 
+	trace_rpc_call_status(task);
 	task->tk_status = 0;
 	switch(status) {
 	case -EHOSTDOWN:


