Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:40602 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756589AbdLTVbj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:39 -0500
Subject: [PATCH v1 10/12] xprtrdma: Add trace points in the client-side
 backchannel code paths
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:37 -0500
Message-ID: <20171220213137.29321.55527.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h    |   68 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c |    8 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 +
 3 files changed, 73 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 79cc487..16ac4d4 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -266,6 +266,39 @@
 				), \
 				TP_ARGS(mr))
 
+DECLARE_EVENT_CLASS(xprtrdma_cb_event,
+	TP_PROTO(
+		const struct rpc_rqst *rqst
+	),
+
+	TP_ARGS(rqst),
+
+	TP_STRUCT__entry(
+		__field(const void *, rqst)
+		__field(const void *, rep)
+		__field(const void *, req)
+		__field(u32, xid)
+	),
+
+	TP_fast_assign(
+		__entry->rqst = rqst;
+		__entry->req = rpcr_to_rdmar(rqst);
+		__entry->rep = rpcr_to_rdmar(rqst)->rl_reply;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+	),
+
+	TP_printk("xid=0x%08x, rqst=%p req=%p rep=%p",
+		__entry->xid, __entry->rqst, __entry->req, __entry->rep
+	)
+);
+
+#define DEFINE_CB_EVENT(name)						\
+		DEFINE_EVENT(xprtrdma_cb_event, name,			\
+				TP_PROTO(				\
+					const struct rpc_rqst *rqst	\
+				),					\
+				TP_ARGS(rqst))
+
 /**
  ** Connection events
  **/
@@ -718,6 +751,41 @@
 	)
 );
 
+/**
+ ** Callback events
+ **/
+
+TRACE_EVENT(xprtrdma_cb_setup,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		unsigned int reqs
+	),
+
+	TP_ARGS(r_xprt, reqs),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(unsigned int, reqs)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->reqs = reqs;
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p: %u reqs",
+		__get_str(addr), __get_str(port),
+		__entry->r_xprt, __entry->reqs
+	)
+);
+
+DEFINE_CB_EVENT(xprtrdma_cb_call);
+DEFINE_CB_EVENT(xprtrdma_cb_reply);
+
 #endif /* _TRACE_RPCRDMA_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 3c7998a..ca0c5d3 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -140,7 +140,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 
 	buffer->rb_bc_srv_max_requests = reqs;
 	request_module("svcrdma");
-
+	trace_xprtrdma_cb_setup(r_xprt, reqs);
 	return 0;
 
 out_free:
@@ -212,6 +212,8 @@ static int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	if (rpcrdma_prepare_send_sges(r_xprt, req, RPCRDMA_HDRLEN_MIN,
 				      &rqst->rq_snd_buf, rpcrdma_noch))
 		return -EIO;
+
+	trace_xprtrdma_cb_reply(rqst);
 	return 0;
 }
 
@@ -331,7 +333,6 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 				struct rpc_rqst, rq_bc_pa_list);
 	list_del(&rqst->rq_bc_pa_list);
 	spin_unlock(&xprt->bc_pa_lock);
-	dprintk("RPC:       %s: using rqst %p\n", __func__, rqst);
 
 	/* Prepare rqst */
 	rqst->rq_reply_bytes_recvd = 0;
@@ -352,9 +353,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	 * the Upper Layer is done decoding it.
 	 */
 	req = rpcr_to_rdmar(rqst);
-	dprintk("RPC:       %s: attaching rep %p to req %p\n",
-		__func__, rep, req);
 	req->rl_reply = rep;
+	trace_xprtrdma_cb_call(rqst);
 
 	/* Queue rqst for ULP's callback service */
 	bc_serv = xprt->bc_serv;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a1ca1b6..69883a9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -365,7 +365,7 @@ enum {
 }
 
 static inline struct rpcrdma_req *
-rpcr_to_rdmar(struct rpc_rqst *rqst)
+rpcr_to_rdmar(const struct rpc_rqst *rqst)
 {
 	return rqst->rq_xprtdata;
 }

