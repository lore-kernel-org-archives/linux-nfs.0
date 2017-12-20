Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38865 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755718AbdLTVbX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:23 -0500
Subject: [PATCH v1 08/12] xprtrdma: Add trace points to instrument MR
 allocation and recovery
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:21 -0500
Message-ID: <20171220213120.29321.51753.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   57 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c    |    6 ++--
 2 files changed, 60 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 057662b..d4dad18 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -50,6 +50,37 @@
 				),					\
 				TP_ARGS(rep))
 
+DECLARE_EVENT_CLASS(xprtrdma_rxprt,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt
+	),
+
+	TP_ARGS(r_xprt),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p",
+		__get_str(addr), __get_str(port), __entry->r_xprt
+	)
+);
+
+#define DEFINE_RXPRT_EVENT(name)					\
+		DEFINE_EVENT(xprtrdma_rxprt, name,			\
+				TP_PROTO(				\
+					const struct rpcrdma_xprt *r_xprt \
+				),					\
+				TP_ARGS(r_xprt))
+
 DECLARE_EVENT_CLASS(xprtrdma_rdch_event,
 	TP_PROTO(
 		const struct rpc_task *task,
@@ -239,6 +270,31 @@
  ** Call events
  **/
 
+TRACE_EVENT(xprtrdma_createmrs,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		unsigned int count
+	),
+
+	TP_ARGS(r_xprt, count),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(unsigned int, count)
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->count = count;
+	),
+
+	TP_printk("r_xprt=%p: created %u MRs",
+		__entry->r_xprt, __entry->count
+	)
+);
+
+DEFINE_RXPRT_EVENT(xprtrdma_nomrs);
+
 DEFINE_RDCH_EVENT(xprtrdma_read_chunk);
 DEFINE_WRCH_EVENT(xprtrdma_write_chunk);
 DEFINE_WRCH_EVENT(xprtrdma_reply_chunk);
@@ -422,6 +478,7 @@
 DEFINE_MR_EVENT(xprtrdma_localinv);
 DEFINE_MR_EVENT(xprtrdma_dma_unmap);
 DEFINE_MR_EVENT(xprtrdma_remoteinv);
+DEFINE_MR_EVENT(xprtrdma_recover_mr);
 
 /**
  ** Reply events
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0e89e55..1addcc9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -998,7 +998,7 @@ void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
 		mr = rpcrdma_mr_pop(&buf->rb_stale_mrs);
 		spin_unlock(&buf->rb_recovery_lock);
 
-		dprintk("RPC:       %s: recovering MR %p\n", __func__, mr);
+		trace_xprtrdma_recover_mr(mr);
 		mr->mr_xprt->rx_ia.ri_ops->ro_recover_mr(mr);
 
 		spin_lock(&buf->rb_recovery_lock);
@@ -1054,7 +1054,7 @@ void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
 	r_xprt->rx_stats.mrs_allocated += count;
 	spin_unlock(&buf->rb_mrlock);
 
-	dprintk("RPC:       %s: created %u MRs\n", __func__, count);
+	trace_xprtrdma_createmrs(r_xprt, count);
 }
 
 static void
@@ -1310,7 +1310,7 @@ struct rpcrdma_mr *
 	return mr;
 
 out_nomrs:
-	dprintk("RPC:       %s: no MRs available\n", __func__);
+	trace_xprtrdma_nomrs(r_xprt);
 	if (r_xprt->rx_ep.rep_connected != -ENODEV)
 		schedule_delayed_work(&buf->rb_refresh_worker, 0);
 

