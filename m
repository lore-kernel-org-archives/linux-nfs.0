Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:50787 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933455AbdKCRqQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 13:46:16 -0400
Received: by mail-io0-f196.google.com with SMTP id 97so7939888iok.7
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 10:46:16 -0700 (PDT)
Subject: [PATCH 2/2] sunrpc: Add rpc_request static trace point
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 03 Nov 2017 13:46:14 -0400
Message-ID: <20171103174614.31080.38315.stgit@manet.1015granger.net>
In-Reply-To: <20171103174509.31080.80937.stgit@manet.1015granger.net>
References: <20171103174509.31080.80937.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Display information about the RPC procedure being requested in the
trace log. This sometimes critical information cannot always be
derived from other RPC trace entries.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   30 ++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    3 +--
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 82e5057..d7c6dc7 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -70,6 +70,36 @@
 		__entry->status)
 );
 
+TRACE_EVENT(rpc_request,
+	TP_PROTO(const struct rpc_task *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(int, version)
+		__field(bool, async)
+		__string(progname, task->tk_client->cl_program->name)
+		__string(procname, rpc_proc_name(task))
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->version = task->tk_client->cl_vers;
+		__entry->async = RPC_IS_ASYNC(task);
+		__assign_str(progname, task->tk_client->cl_program->name)
+		__assign_str(procname, rpc_proc_name(task))
+	),
+
+	TP_printk("task:%u@%u %sv%d %s (%ssync)",
+		__entry->task_id, __entry->client_id,
+		__get_str(progname), __entry->version,
+		__get_str(procname), __entry->async ? "a": ""
+		)
+);
+
 DECLARE_EVENT_CLASS(rpc_task_running,
 
 	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2ad827d..3e4fcdd 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1491,7 +1491,6 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 const char
 *rpc_proc_name(const struct rpc_task *task)
 {
@@ -1505,7 +1504,6 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	} else
 		return "no proc";
 }
-#endif
 
 /*
  * 0.  Initial state
@@ -1519,6 +1517,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	struct rpc_clnt	*clnt = task->tk_client;
 	int idx = task->tk_msg.rpc_proc->p_statidx;
 
+	trace_rpc_request(task);
 	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", task->tk_pid,
 			clnt->cl_program->name, clnt->cl_vers,
 			rpc_proc_name(task),

