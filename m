Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:46515 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756589AbdLTVbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:55 -0500
Subject: [PATCH v1 12/12] xprtrdma: Instrument allocation/release of
 rpcrdma_req/rep objects
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:53 -0500
Message-ID: <20171220213153.29321.43120.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |   67 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c |   12 +++----
 net/sunrpc/xprtrdma/verbs.c     |    4 +-
 3 files changed, 74 insertions(+), 9 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 5aa3ec7..27fd452 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -783,6 +783,73 @@
 );
 
 /**
+ ** Allocation/release of rpcrdma_reqs and rpcrdma_reps
+ **/
+
+TRACE_EVENT(xprtrdma_allocate,
+	TP_PROTO(
+		const struct rpc_task *task,
+		const struct rpcrdma_req *req
+	),
+
+	TP_ARGS(task, req),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, req)
+		__field(const void *, rep)
+		__field(size_t, callsize)
+		__field(size_t, rcvsize)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->req = req;
+		__entry->rep = req ? req->rl_reply : NULL;
+		__entry->callsize = task->tk_rqstp->rq_callsize;
+		__entry->rcvsize = task->tk_rqstp->rq_rcvsize;
+	),
+
+	TP_printk("task:%u@%u req=%p rep=%p (%zu, %zu)",
+		__entry->task_id, __entry->client_id,
+		__entry->req, __entry->rep,
+		__entry->callsize, __entry->rcvsize
+	)
+);
+
+TRACE_EVENT(xprtrdma_rpc_done,
+	TP_PROTO(
+		const struct rpc_task *task,
+		const struct rpcrdma_req *req
+	),
+
+	TP_ARGS(task, req),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, req)
+		__field(const void *, rep)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->req = req;
+		__entry->rep = req->rl_reply;
+	),
+
+	TP_printk("task:%u@%u req=%p rep=%p",
+		__entry->task_id, __entry->client_id,
+		__entry->req, __entry->rep
+	)
+);
+
+DEFINE_RXPRT_EVENT(xprtrdma_noreps);
+
+/**
  ** Callback events
  **/
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 25d1160..b90179a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -640,7 +640,7 @@
 
 	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
 	if (req == NULL)
-		return -ENOMEM;
+		goto out_get;
 
 	flags = RPCRDMA_DEF_GFP;
 	if (RPC_IS_SWAPPER(task))
@@ -653,19 +653,18 @@
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
 		goto out_fail;
 
-	dprintk("RPC: %5u %s: send size = %zd, recv size = %zd, req = %p\n",
-		task->tk_pid, __func__, rqst->rq_callsize,
-		rqst->rq_rcvsize, req);
-
 	req->rl_cpu = smp_processor_id();
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
+	trace_xprtrdma_allocate(task, req);
 	return 0;
 
 out_fail:
 	rpcrdma_buffer_put(req);
+out_get:
+	trace_xprtrdma_allocate(task, NULL);
 	return -ENOMEM;
 }
 
@@ -682,10 +681,9 @@
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 
-	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
-
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
 		rpcrdma_release_rqst(r_xprt, req);
+	trace_xprtrdma_rpc_done(task, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fb81d3a..57e1139 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1385,11 +1385,11 @@ struct rpcrdma_req *
 	req = rpcrdma_buffer_get_req_locked(buffers);
 	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
 	spin_unlock(&buffers->rb_lock);
+
 	return req;
 
 out_reqbuf:
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("RPC:       %s: out of request buffers\n", __func__);
 	return NULL;
 }
 
@@ -1612,7 +1612,7 @@ struct rpcrdma_regbuf *
 
 out_reqbuf:
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("%s: no extra receive buffers\n", __func__);
+	trace_xprtrdma_noreps(r_xprt);
 	return -ENOMEM;
 
 out_rc:

