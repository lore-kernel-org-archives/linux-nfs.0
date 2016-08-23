Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36828 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753046AbcHWRwh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 13:52:37 -0400
Subject: [PATCH v2 04/22] SUNRPC: Generalize the RPC buffer release API
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:52:36 -0400
Message-ID: <20160823175235.13038.20673.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprtrdma needs to allocate the Call and Reply buffers separately.
TBH, the reliance on using a single buffer for the pair of XDR
buffers is transport implementation-specific.

Instead of passing just the rq_buffer into the buf_free method, pass
the task structure and let buf_free take care of freeing both
XDR buffers at once.

There's a micro-optimization here. In the common case, both
xprt_release and the transport's buf_free method were checking if
rq_buffer was NULL. Now the check is done only once per RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/sched.h               |    2 +-
 include/linux/sunrpc/xprt.h                |    2 +-
 net/sunrpc/sched.c                         |   10 ++++------
 net/sunrpc/xprt.c                          |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 +-
 net/sunrpc/xprtrdma/transport.c            |   26 ++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h            |    1 -
 net/sunrpc/xprtsock.c                      |    6 ++----
 8 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 38d4c1b..7ba040c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -240,7 +240,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 void		rpc_delay(struct rpc_task *, unsigned long);
 int		rpc_malloc(struct rpc_task *);
-void		rpc_free(void *);
+void		rpc_free(struct rpc_task *);
 int		rpciod_up(void);
 void		rpciod_down(void);
 int		__rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index c01f468..72c2aeb 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -128,7 +128,7 @@ struct rpc_xprt_ops {
 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
 	int		(*buf_alloc)(struct rpc_task *task);
-	void		(*buf_free)(void *buffer);
+	void		(*buf_free)(struct rpc_task *task);
 	int		(*send_request)(struct rpc_task *task);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b964d40..6690ebc 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -896,18 +896,16 @@ int rpc_malloc(struct rpc_task *task)
 EXPORT_SYMBOL_GPL(rpc_malloc);
 
 /**
- * rpc_free - free buffer allocated via rpc_malloc
- * @buffer: buffer to free
+ * rpc_free - free RPC buffer resources allocated via rpc_malloc
+ * @task: RPC task
  *
  */
-void rpc_free(void *buffer)
+void rpc_free(struct rpc_task *task)
 {
+	void *buffer = task->tk_rqstp->rq_buffer;
 	size_t size;
 	struct rpc_buffer *buf;
 
-	if (!buffer)
-		return;
-
 	buf = container_of(buffer, struct rpc_buffer, data);
 	size = buf->len;
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ea244b2..685e6d2 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1295,7 +1295,7 @@ void xprt_release(struct rpc_task *task)
 	xprt_schedule_autodisconnect(xprt);
 	spin_unlock_bh(&xprt->transport_lock);
 	if (req->rq_buffer)
-		xprt->ops->buf_free(req->rq_buffer);
+		xprt->ops->buf_free(task);
 	xprt_inject_disconnect(xprt);
 	if (req->rq_cred != NULL)
 		put_rpccred(req->rq_cred);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 124688b..fa89350 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -186,7 +186,7 @@ xprt_rdma_bc_allocate(struct rpc_task *task)
 }
 
 static void
-xprt_rdma_bc_free(void *buffer)
+xprt_rdma_bc_free(struct rpc_task *task)
 {
 	/* No-op: ctxt and page have already been freed. */
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index daa7d4d..ebf14ba 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -523,7 +523,6 @@ xprt_rdma_allocate(struct rpc_task *task)
 out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
-	req->rl_task = task;
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	return 0;
 
@@ -571,31 +570,26 @@ out_fail:
 	return -ENOMEM;
 }
 
-/*
- * This function returns all RDMA resources to the pool.
+/**
+ * xprt_rdma_free - release resources allocated by xprt_rdma_allocate
+ * @task: RPC task
+ *
+ * Caller guarantees rqst->rq_buffer is non-NULL.
  */
 static void
-xprt_rdma_free(void *buffer)
+xprt_rdma_free(struct rpc_task *task)
 {
-	struct rpcrdma_req *req;
-	struct rpcrdma_xprt *r_xprt;
-	struct rpcrdma_regbuf *rb;
-
-	if (buffer == NULL)
-		return;
+	struct rpc_rqst *rqst = task->tk_rqstp;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 
-	rb = container_of(buffer, struct rpcrdma_regbuf, rg_base[0]);
-	req = rb->rg_owner;
 	if (req->rl_backchannel)
 		return;
 
-	r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
-
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
 	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req,
-					    !RPC_IS_ASYNC(req->rl_task));
-
+					    !RPC_IS_ASYNC(task));
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6d466ab..296d9ab 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -283,7 +283,6 @@ struct rpcrdma_req {
 	struct list_head	rl_free;
 	unsigned int		rl_niovs;
 	unsigned int		rl_connect_cookie;
-	struct rpc_task		*rl_task;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 54a7b4c..41fae68 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2560,13 +2560,11 @@ static int bc_malloc(struct rpc_task *task)
 /*
  * Free the space allocated in the bc_alloc routine
  */
-static void bc_free(void *buffer)
+static void bc_free(struct rpc_task *task)
 {
+	void *buffer = task->tk_rqstp->rq_buffer;
 	struct rpc_buffer *buf;
 
-	if (!buffer)
-		return;
-
 	buf = container_of(buffer, struct rpc_buffer, data);
 	free_page((unsigned long)buf);
 }

