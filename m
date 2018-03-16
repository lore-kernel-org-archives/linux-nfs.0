Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:42729 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbeCPOd5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:33:57 -0400
Received: by mail-io0-f194.google.com with SMTP id u84so12885339iod.9
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 07:33:56 -0700 (PDT)
Subject: [PATCH 3/3] sunrpc: Add static trace point to report result of RPC
 ping
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:33:55 -0400
Message-ID: <20180316143355.14289.11923.stgit@manet.1015granger.net>
In-Reply-To: <20180316142858.14289.44885.stgit@manet.1015granger.net>
References: <20180316142858.14289.44885.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This information can help track down local misconfiguration issues
as well as network partitions and unresponsive servers.

There are several ways to send a ping, and with transport multi-
plexing, the exact rpc_xprt that is used is sometimes not known by
the upper layer. The rpc_xprt pointer passed to the trace point
call also has to be RCU-safe.

I found a spot inside the client FSM where an rpc_xprt pointer is
always available and safe to use.

Suggested-by: Bill Baker <Bill.Baker@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   21 +++++++++++++++++++++
 net/sunrpc/clnt.c             |    6 ++++++
 2 files changed, 27 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index fda9e72..76887d6 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -453,6 +453,27 @@
 	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
 	TP_ARGS(xprt, xid, status));
 
+TRACE_EVENT(xprt_ping,
+	TP_PROTO(const struct rpc_xprt *xprt, int status),
+
+	TP_ARGS(xprt, status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+		__string(addr, xprt->address_strings[RPC_DISPLAY_ADDR])
+		__string(port, xprt->address_strings[RPC_DISPLAY_PORT])
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+		__assign_str(addr, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		__assign_str(port, xprt->address_strings[RPC_DISPLAY_PORT]);
+	),
+
+	TP_printk("peer=[%s]:%s status=%d",
+			__get_str(addr), __get_str(port), __entry->status)
+);
+
 TRACE_EVENT(xs_tcp_data_ready,
 	TP_PROTO(struct rpc_xprt *xprt, int err, unsigned int total),
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3acfa01..eb1a818 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2015,6 +2015,9 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	case -EPERM:
 		if (RPC_IS_SOFTCONN(task)) {
 			xprt_end_transmit(task);
+			if (!task->tk_msg.rpc_proc->p_proc)
+				trace_xprt_ping(task->tk_xprt,
+						task->tk_status);
 			rpc_exit(task, task->tk_status);
 			break;
 		}
@@ -2113,6 +2116,9 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	struct rpc_rqst	*req = task->tk_rqstp;
 	int		status;
 
+	if (!task->tk_msg.rpc_proc->p_proc)
+		trace_xprt_ping(task->tk_xprt, task->tk_status);
+
 	if (req->rq_reply_bytes_recvd > 0 && !req->rq_bytes_sent)
 		task->tk_status = req->rq_reply_bytes_recvd;
 

