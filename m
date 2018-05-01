Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37096 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756032AbeEAPhV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2018 11:37:21 -0400
Subject: [PATCH v1 2/2] sunrpc: Fix latency trace point crashes
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 May 2018 11:37:19 -0400
Message-ID: <20180501153719.5863.14456.stgit@manet.1015granger.net>
In-Reply-To: <20180501153109.5863.33183.stgit@manet.1015granger.net>
References: <20180501153109.5863.33183.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the rpc_task survived longer than the transport, task->tk_xprt
points to freed memory by the time rpc_count_iostats_metrics runs.
Replace the references to task->tk_xprt with references to the
task's tk_client.

Reported-by: syzbot+27db1f90e2b972a5f2d3@syzkaller.appspotmail.com
Fixes: 40bf7eb304b5 ('sunrpc: Add static trace point to report ...')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 335d872..bbb08a3 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -224,6 +224,8 @@
 	TP_ARGS(task, backlog, rtt, execute),
 
 	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(u32, xid)
 		__field(int, version)
 		__string(progname, task->tk_client->cl_program->name)
@@ -231,13 +233,11 @@
 		__field(unsigned long, backlog)
 		__field(unsigned long, rtt)
 		__field(unsigned long, execute)
-		__string(addr,
-			 task->tk_xprt->address_strings[RPC_DISPLAY_ADDR])
-		__string(port,
-			 task->tk_xprt->address_strings[RPC_DISPLAY_PORT])
 	),
 
 	TP_fast_assign(
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->task_id = task->tk_pid;
 		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
 		__entry->version = task->tk_client->cl_vers;
 		__assign_str(progname, task->tk_client->cl_program->name)
@@ -245,14 +245,10 @@
 		__entry->backlog = ktime_to_us(backlog);
 		__entry->rtt = ktime_to_us(rtt);
 		__entry->execute = ktime_to_us(execute);
-		__assign_str(addr,
-			     task->tk_xprt->address_strings[RPC_DISPLAY_ADDR]);
-		__assign_str(port,
-			     task->tk_xprt->address_strings[RPC_DISPLAY_PORT]);
 	),
 
-	TP_printk("peer=[%s]:%s xid=0x%08x %sv%d %s backlog=%lu rtt=%lu execute=%lu",
-		__get_str(addr), __get_str(port), __entry->xid,
+	TP_printk("task:%u@%d xid=0x%08x %sv%d %s backlog=%lu rtt=%lu execute=%lu",
+		__entry->task_id, __entry->client_id, __entry->xid,
 		__get_str(progname), __entry->version, __get_str(procname),
 		__entry->backlog, __entry->rtt, __entry->execute)
 );

