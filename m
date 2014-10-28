Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:54481 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaJ1SYY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 14:24:24 -0400
Received: by mail-qa0-f54.google.com with SMTP id u7so881625qaz.41
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 11:24:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] sunrpc: add some tracepoints in svc_rqst handling functions
Date: Tue, 28 Oct 2014 14:24:12 -0400
Message-Id: <1414520654-1606-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
References: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...just around svc_send, svc_recv and svc_process for now.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 55 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svc.c              | 21 ++++++++++-------
 net/sunrpc/svc_xprt.c         | 31 ++++++++++++++++--------
 3 files changed, 88 insertions(+), 19 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 1fef3e6e9436..6260f5134212 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -6,6 +6,7 @@
 
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/svc.h>
 #include <net/tcp_states.h>
 #include <linux/net.h>
 #include <linux/tracepoint.h>
@@ -306,6 +307,60 @@ DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
 
+TRACE_EVENT(svc_recv,
+	TP_PROTO(struct svc_rqst *rqst, int status),
+
+	TP_ARGS(rqst, status),
+
+	TP_STRUCT__entry(
+		__field(struct sockaddr *, addr)
+		__field(__be32, xid)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
+		__entry->xid = status > 0 ? rqst->rq_xid : 0;
+		__entry->status = status;
+	),
+
+	TP_printk("addr=%pIScp xid=0x%x status=%d", __entry->addr,
+			be32_to_cpu(__entry->xid), __entry->status)
+);
+
+DECLARE_EVENT_CLASS(svc_rqst_status,
+
+	TP_PROTO(struct svc_rqst *rqst, int status),
+
+	TP_ARGS(rqst, status),
+
+	TP_STRUCT__entry(
+		__field(struct sockaddr *, addr)
+		__field(__be32, xid)
+		__field(int, dropme)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
+		__entry->xid = rqst->rq_xid;
+		__entry->dropme = (int)rqst->rq_dropme;
+		__entry->status = status;
+	),
+
+	TP_printk("addr=%pIScp rq_xid=0x%x dropme=%d status=%d",
+		__entry->addr, be32_to_cpu(__entry->xid), __entry->dropme,
+		__entry->status)
+);
+
+DEFINE_EVENT(svc_rqst_status, svc_process,
+	TP_PROTO(struct svc_rqst *rqst, int status),
+	TP_ARGS(rqst, status));
+
+DEFINE_EVENT(svc_rqst_status, svc_send,
+	TP_PROTO(struct svc_rqst *rqst, int status),
+	TP_ARGS(rqst, status));
+
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ca8a7958f4e6..371a8bbb43d6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -28,6 +28,8 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
 
+#include <trace/events/sunrpc.h>
+
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
 static void svc_unregister(const struct svc_serv *serv, struct net *net);
@@ -1314,24 +1316,25 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_base = NULL;
 	rqstp->rq_res.tail[0].iov_len = 0;
 
-	rqstp->rq_xid = svc_getu32(argv);
-
 	dir  = svc_getnl(argv);
 	if (dir != 0) {
 		/* direction != CALL */
 		svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
 		serv->sv_stats->rpcbadfmt++;
-		svc_drop(rqstp);
-		return 0;
+		goto out_drop;
 	}
 
 	/* Returns 1 for send, 0 for drop */
-	if (svc_process_common(rqstp, argv, resv))
-		return svc_send(rqstp);
-	else {
-		svc_drop(rqstp);
-		return 0;
+	if (likely(svc_process_common(rqstp, argv, resv))) {
+		int ret = svc_send(rqstp);
+
+		trace_svc_process(rqstp, ret);
+		return ret;
 	}
+out_drop:
+	trace_svc_process(rqstp, 0);
+	svc_drop(rqstp);
+	return 0;
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c179ca2a5aa4..bbb3b044b877 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/module.h>
+#include <trace/events/sunrpc.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -773,35 +774,43 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	err = svc_alloc_arg(rqstp);
 	if (err)
-		return err;
+		goto out;
 
 	try_to_freeze();
 	cond_resched();
+	err = -EINTR;
 	if (signalled() || kthread_should_stop())
-		return -EINTR;
+		goto out;
 
 	xprt = svc_get_next_xprt(rqstp, timeout);
-	if (IS_ERR(xprt))
-		return PTR_ERR(xprt);
+	if (IS_ERR(xprt)) {
+		err = PTR_ERR(xprt);
+		goto out;
+	}
 
 	len = svc_handle_xprt(rqstp, xprt);
 
 	/* No data, incomplete (TCP) read, or accept() */
+	err = -EAGAIN;
 	if (len <= 0)
-		goto out;
+		goto out_release;
 
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
 	rqstp->rq_secure = xprt->xpt_ops->xpo_secure_port(rqstp);
 	rqstp->rq_chandle.defer = svc_defer;
+	rqstp->rq_xid = svc_getu32(&rqstp->rq_arg.head[0]);
 
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
+	trace_svc_recv(rqstp, len);
 	return len;
-out:
+out_release:
 	rqstp->rq_res.len = 0;
 	svc_xprt_release(rqstp);
-	return -EAGAIN;
+out:
+	trace_svc_recv(rqstp, err);
+	return err;
 }
 EXPORT_SYMBOL_GPL(svc_recv);
 
@@ -821,12 +830,12 @@ EXPORT_SYMBOL_GPL(svc_drop);
 int svc_send(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt;
-	int		len;
+	int		len = -EFAULT;
 	struct xdr_buf	*xb;
 
 	xprt = rqstp->rq_xprt;
 	if (!xprt)
-		return -EFAULT;
+		goto out;
 
 	/* release the receive skb before sending the reply */
 	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
@@ -849,7 +858,9 @@ int svc_send(struct svc_rqst *rqstp)
 	svc_xprt_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
-		return 0;
+		len = 0;
+out:
+	trace_svc_send(rqstp, len);
 	return len;
 }
 
-- 
1.9.3

