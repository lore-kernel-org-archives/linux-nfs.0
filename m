Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34558 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaJ1SYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 14:24:25 -0400
Received: by mail-qg0-f44.google.com with SMTP id q107so975421qgd.17
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 11:24:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] sunrpc: add new tracepoints in xprt handling code
Date: Tue, 28 Oct 2014 14:24:13 -0400
Message-Id: <1414520654-1606-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
References: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so we can keep track of when calls are sent and replies received.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 63 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c             |  9 ++++++-
 net/sunrpc/xprtsock.c         |  8 +++++-
 3 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 6260f5134212..5edb16bcd836 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -307,6 +307,69 @@ DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
 
+DECLARE_EVENT_CLASS(rpc_xprt_event,
+	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
+
+	TP_ARGS(xprt, xid, status),
+
+	TP_STRUCT__entry(
+		__field(__be32, xid)
+		__field(int, status)
+		__string(addr, xprt->address_strings[RPC_DISPLAY_ADDR])
+		__string(port, xprt->address_strings[RPC_DISPLAY_PORT])
+	),
+
+	TP_fast_assign(
+		__entry->xid = xid;
+		__entry->status = status;
+		__assign_str(addr, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		__assign_str(port, xprt->address_strings[RPC_DISPLAY_PORT]);
+	),
+
+	TP_printk("peer=%s/%s xid=0x%x status=%d", __get_str(addr),
+			__get_str(port), be32_to_cpu(__entry->xid),
+			__entry->status)
+);
+
+DEFINE_EVENT(rpc_xprt_event, xprt_lookup_rqst,
+	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
+	TP_ARGS(xprt, xid, status));
+
+DEFINE_EVENT(rpc_xprt_event, xprt_transmit,
+	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
+	TP_ARGS(xprt, xid, status));
+
+DEFINE_EVENT(rpc_xprt_event, xprt_complete_rqst,
+	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
+	TP_ARGS(xprt, xid, status));
+
+TRACE_EVENT(xs_tcp_data_ready,
+	TP_PROTO(struct rpc_xprt *xprt, int err, unsigned int total),
+
+	TP_ARGS(xprt, err, total),
+
+	TP_STRUCT__entry(
+		__field(int, err)
+		__field(unsigned int, total)
+		__string(addr, xprt ? xprt->address_strings[RPC_DISPLAY_ADDR] :
+				"(null)")
+		__string(port, xprt ? xprt->address_strings[RPC_DISPLAY_PORT] :
+				"(null)")
+	),
+
+	TP_fast_assign(
+		__entry->err = err;
+		__entry->total = total;
+		__assign_str(addr, xprt ?
+			xprt->address_strings[RPC_DISPLAY_ADDR] : "(null)");
+		__assign_str(port, xprt ?
+			xprt->address_strings[RPC_DISPLAY_PORT] : "(null)");
+	),
+
+	TP_printk("peer=[%s]:%s err=%d total=%u", __get_str(addr),
+			__get_str(port), __entry->err, __entry->total)
+);
+
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 56e4e150e80e..1b2e5e616cae 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -49,6 +49,8 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
 
+#include <trace/events/sunrpc.h>
+
 #include "sunrpc.h"
 
 /*
@@ -772,11 +774,14 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 	struct rpc_rqst *entry;
 
 	list_for_each_entry(entry, &xprt->recv, rq_list)
-		if (entry->rq_xid == xid)
+		if (entry->rq_xid == xid) {
+			trace_xprt_lookup_rqst(xprt, xid, 0);
 			return entry;
+		}
 
 	dprintk("RPC:       xprt_lookup_rqst did not find xid %08x\n",
 			ntohl(xid));
+	trace_xprt_lookup_rqst(xprt, xid, -ENOENT);
 	xprt->stat.bad_xids++;
 	return NULL;
 }
@@ -810,6 +815,7 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
 	dprintk("RPC: %5u xid %08x complete (%d bytes received)\n",
 			task->tk_pid, ntohl(req->rq_xid), copied);
+	trace_xprt_complete_rqst(xprt, req->rq_xid, copied);
 
 	xprt->stat.recvs++;
 	req->rq_rtt = ktime_sub(ktime_get(), req->rq_xtime);
@@ -926,6 +932,7 @@ void xprt_transmit(struct rpc_task *task)
 
 	req->rq_xtime = ktime_get();
 	status = xprt->ops->send_request(task);
+	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
 		task->tk_status = status;
 		return;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3b305ab17afe..b63e26272dc2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1454,12 +1454,15 @@ static void xs_tcp_data_ready(struct sock *sk)
 	struct rpc_xprt *xprt;
 	read_descriptor_t rd_desc;
 	int read;
+	unsigned long total = 0;
 
 	dprintk("RPC:       xs_tcp_data_ready...\n");
 
 	read_lock_bh(&sk->sk_callback_lock);
-	if (!(xprt = xprt_from_sock(sk)))
+	if (!(xprt = xprt_from_sock(sk))) {
+		read = 0;
 		goto out;
+	}
 	/* Any data means we had a useful conversation, so
 	 * the we don't need to delay the next reconnect
 	 */
@@ -1471,8 +1474,11 @@ static void xs_tcp_data_ready(struct sock *sk)
 	do {
 		rd_desc.count = 65536;
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+		if (read > 0)
+			total += read;
 	} while (read > 0);
 out:
+	trace_xs_tcp_data_ready(xprt, read, total);
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
-- 
1.9.3

