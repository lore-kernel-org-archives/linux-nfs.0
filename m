Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:39290 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbeCPOdw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:33:52 -0400
Received: by mail-it0-f68.google.com with SMTP id e98-v6so2364503itd.4
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 07:33:51 -0700 (PDT)
Subject: [PATCH 2/3] sunrpc: Add static trace point to report RPC latency
 stats
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:33:49 -0400
Message-ID: <20180316143349.14289.87854.stgit@manet.1015granger.net>
In-Reply-To: <20180316142858.14289.44885.stgit@manet.1015granger.net>
References: <20180316142858.14289.44885.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a low-overhead mechanism to report information about
latencies of individual RPCs. The goal is to enable user space to
filter the trace record for latency outliers, or build histograms,
etc.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/stats.c            |   16 ++++++++++-----
 2 files changed, 56 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 53bbaea..fda9e72 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -212,6 +212,51 @@
 
 );
 
+TRACE_EVENT(rpc_stats_latency,
+
+	TP_PROTO(
+		const struct rpc_task *task,
+		ktime_t backlog,
+		ktime_t rtt,
+		ktime_t execute
+	),
+
+	TP_ARGS(task, backlog, rtt, execute),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(int, version)
+		__string(progname, task->tk_client->cl_program->name)
+		__string(procname, rpc_proc_name(task))
+		__field(unsigned long, backlog)
+		__field(unsigned long, rtt)
+		__field(unsigned long, execute)
+		__string(addr,
+			 task->tk_xprt->address_strings[RPC_DISPLAY_ADDR])
+		__string(port,
+			 task->tk_xprt->address_strings[RPC_DISPLAY_PORT])
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
+		__entry->version = task->tk_client->cl_vers;
+		__assign_str(progname, task->tk_client->cl_program->name)
+		__assign_str(procname, rpc_proc_name(task))
+		__entry->backlog = ktime_to_us(backlog);
+		__entry->rtt = ktime_to_us(rtt);
+		__entry->execute = ktime_to_us(execute);
+		__assign_str(addr,
+			     task->tk_xprt->address_strings[RPC_DISPLAY_ADDR]);
+		__assign_str(port,
+			     task->tk_xprt->address_strings[RPC_DISPLAY_PORT]);
+	),
+
+	TP_printk("peer=[%s]:%s xid=0x%08x %sv%d %s backlog=%lu rtt=%lu execute=%lu",
+		__get_str(addr), __get_str(port), __entry->xid,
+		__get_str(progname), __entry->version, __get_str(procname),
+		__entry->backlog, __entry->rtt, __entry->execute)
+);
+
 /*
  * First define the enums in the below macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 1e67133..f68aa46 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -24,6 +24,8 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/rcupdate.h>
 
+#include <trace/events/sunrpc.h>
+
 #include "netns.h"
 
 #define RPCDBG_FACILITY	RPCDBG_MISC
@@ -148,7 +150,7 @@ void rpc_count_iostats_metrics(const struct rpc_task *task,
 			       struct rpc_iostats *op_metrics)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	ktime_t delta, now;
+	ktime_t backlog, execute, now;
 
 	if (!op_metrics || !req)
 		return;
@@ -164,16 +166,20 @@ void rpc_count_iostats_metrics(const struct rpc_task *task,
 	op_metrics->om_bytes_sent += req->rq_xmit_bytes_sent;
 	op_metrics->om_bytes_recv += req->rq_reply_bytes_recvd;
 
+	backlog = 0;
 	if (ktime_to_ns(req->rq_xtime)) {
-		delta = ktime_sub(req->rq_xtime, task->tk_start);
-		op_metrics->om_queue = ktime_add(op_metrics->om_queue, delta);
+		backlog = ktime_sub(req->rq_xtime, task->tk_start);
+		op_metrics->om_queue = ktime_add(op_metrics->om_queue, backlog);
 	}
+
 	op_metrics->om_rtt = ktime_add(op_metrics->om_rtt, req->rq_rtt);
 
-	delta = ktime_sub(now, task->tk_start);
-	op_metrics->om_execute = ktime_add(op_metrics->om_execute, delta);
+	execute = ktime_sub(now, task->tk_start);
+	op_metrics->om_execute = ktime_add(op_metrics->om_execute, execute);
 
 	spin_unlock(&op_metrics->om_lock);
+
+	trace_rpc_stats_latency(req->rq_task, backlog, req->rq_rtt, execute);
 }
 EXPORT_SYMBOL_GPL(rpc_count_iostats_metrics);
 

