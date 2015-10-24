Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38044 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbJXV1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:27:45 -0400
Subject: [PATCH v4 10/16] xprtrdma: Pre-allocate backward rpc_rqst and
 send/receive buffers
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:27:43 -0400
Message-ID: <20151024212743.4715.83575.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprtrdma's backward direction send and receive buffers are the same
size as the forechannel's inline threshold, and must be pre-
registered.

The consumer has no control over which receive buffer the adapter
chooses to catch an incoming backwards-direction call. Any receive
buffer can be used for either a forward reply or a backward call.
Thus both types of RPC message must all be the same size.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/Makefile      |    1 
 net/sunrpc/xprtrdma/backchannel.c |  206 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c   |    7 +
 net/sunrpc/xprtrdma/verbs.c       |   87 ++++++++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h   |   20 ++++
 5 files changed, 309 insertions(+), 12 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/backchannel.c

diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index 48913de..33f99d3 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -5,3 +5,4 @@ rpcrdma-y := transport.o rpc_rdma.o verbs.o \
 	svc_rdma.o svc_rdma_transport.o \
 	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o \
 	module.o
+rpcrdma-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel.o
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
new file mode 100644
index 0000000..3d01b32
--- /dev/null
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -0,0 +1,206 @@
+/*
+ * Copyright (c) 2015 Oracle.  All rights reserved.
+ *
+ * Support for backward direction RPCs on RPC/RDMA.
+ */
+
+#include <linux/module.h>
+
+#include "xprt_rdma.h"
+
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+# define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
+				 struct rpc_rqst *rqst)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+
+	spin_lock(&buf->rb_reqslock);
+	list_del(&req->rl_all);
+	spin_unlock(&buf->rb_reqslock);
+
+	rpcrdma_destroy_req(&r_xprt->rx_ia, req);
+
+	kfree(rqst);
+}
+
+static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
+				 struct rpc_rqst *rqst)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_regbuf *rb;
+	struct rpcrdma_req *req;
+	struct xdr_buf *buf;
+	size_t size;
+
+	req = rpcrdma_create_req(r_xprt);
+	if (!req)
+		return -ENOMEM;
+	req->rl_backchannel = true;
+
+	size = RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
+	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
+	if (IS_ERR(rb))
+		goto out_fail;
+	req->rl_rdmabuf = rb;
+
+	size += RPCRDMA_INLINE_READ_THRESHOLD(rqst);
+	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
+	if (IS_ERR(rb))
+		goto out_fail;
+	rb->rg_owner = req;
+	req->rl_sendbuf = rb;
+	/* so that rpcr_to_rdmar works when receiving a request */
+	rqst->rq_buffer = (void *)req->rl_sendbuf->rg_base;
+
+	buf = &rqst->rq_snd_buf;
+	buf->head[0].iov_base = rqst->rq_buffer;
+	buf->head[0].iov_len = 0;
+	buf->tail[0].iov_base = NULL;
+	buf->tail[0].iov_len = 0;
+	buf->page_len = 0;
+	buf->len = 0;
+	buf->buflen = size;
+
+	return 0;
+
+out_fail:
+	rpcrdma_bc_free_rqst(r_xprt, rqst);
+	return -ENOMEM;
+}
+
+/* Allocate and add receive buffers to the rpcrdma_buffer's
+ * existing list of rep's. These are released when the
+ * transport is destroyed.
+ */
+static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
+				 unsigned int count)
+{
+	struct rpcrdma_buffer *buffers = &r_xprt->rx_buf;
+	struct rpcrdma_rep *rep;
+	unsigned long flags;
+	int rc = 0;
+
+	while (count--) {
+		rep = rpcrdma_create_rep(r_xprt);
+		if (IS_ERR(rep)) {
+			pr_err("RPC:       %s: reply buffer alloc failed\n",
+			       __func__);
+			rc = PTR_ERR(rep);
+			break;
+		}
+
+		spin_lock_irqsave(&buffers->rb_lock, flags);
+		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
+		spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	}
+
+	return rc;
+}
+
+/**
+ * xprt_rdma_bc_setup - Pre-allocate resources for handling backchannel requests
+ * @xprt: transport associated with these backchannel resources
+ * @reqs: number of concurrent incoming requests to expect
+ *
+ * Returns 0 on success; otherwise a negative errno
+ */
+int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
+	struct rpc_rqst *rqst;
+	unsigned int i;
+	int rc;
+
+	/* The backchannel reply path returns each rpc_rqst to the
+	 * bc_pa_list _after_ the reply is sent. If the server is
+	 * faster than the client, it can send another backward
+	 * direction request before the rpc_rqst is returned to the
+	 * list. The client rejects the request in this case.
+	 *
+	 * Twice as many rpc_rqsts are prepared to ensure there is
+	 * always an rpc_rqst available as soon as a reply is sent.
+	 */
+	for (i = 0; i < (reqs << 1); i++) {
+		rqst = kzalloc(sizeof(*rqst), GFP_KERNEL);
+		if (!rqst) {
+			pr_err("RPC:       %s: Failed to create bc rpc_rqst\n",
+			       __func__);
+			goto out_free;
+		}
+
+		rqst->rq_xprt = &r_xprt->rx_xprt;
+		INIT_LIST_HEAD(&rqst->rq_list);
+		INIT_LIST_HEAD(&rqst->rq_bc_list);
+
+		if (rpcrdma_bc_setup_rqst(r_xprt, rqst))
+			goto out_free;
+
+		spin_lock_bh(&xprt->bc_pa_lock);
+		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
+		spin_unlock_bh(&xprt->bc_pa_lock);
+	}
+
+	rc = rpcrdma_bc_setup_reps(r_xprt, reqs);
+	if (rc)
+		goto out_free;
+
+	rc = rpcrdma_ep_post_extra_recv(r_xprt, reqs);
+	if (rc)
+		goto out_free;
+
+	buffer->rb_bc_srv_max_requests = reqs;
+	request_module("svcrdma");
+
+	return 0;
+
+out_free:
+	xprt_rdma_bc_destroy(xprt, reqs);
+
+	pr_err("RPC:       %s: setup backchannel transport failed\n", __func__);
+	return -ENOMEM;
+}
+
+/**
+ * xprt_rdma_bc_destroy - Release resources for handling backchannel requests
+ * @xprt: transport associated with these backchannel resources
+ * @reqs: number of incoming requests to destroy; ignored
+ */
+void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpc_rqst *rqst, *tmp;
+
+	spin_lock_bh(&xprt->bc_pa_lock);
+	list_for_each_entry_safe(rqst, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
+		list_del(&rqst->rq_bc_pa_list);
+		spin_unlock_bh(&xprt->bc_pa_lock);
+
+		rpcrdma_bc_free_rqst(r_xprt, rqst);
+
+		spin_lock_bh(&xprt->bc_pa_lock);
+	}
+	spin_unlock_bh(&xprt->bc_pa_lock);
+}
+
+/**
+ * xprt_rdma_bc_free_rqst - Release a backchannel rqst
+ * @rqst: request to release
+ */
+void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
+{
+	struct rpc_xprt *xprt = rqst->rq_xprt;
+
+	smp_mb__before_atomic();
+	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state));
+	clear_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
+	smp_mb__after_atomic();
+
+	spin_lock_bh(&xprt->bc_pa_lock);
+	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
+	spin_unlock_bh(&xprt->bc_pa_lock);
+}
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 897a2f3..845278e 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -705,7 +705,12 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
 	.print_stats		= xprt_rdma_print_stats,
 	.enable_swap		= xprt_rdma_enable_swap,
 	.disable_swap		= xprt_rdma_disable_swap,
-	.inject_disconnect	= xprt_rdma_inject_disconnect
+	.inject_disconnect	= xprt_rdma_inject_disconnect,
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	.bc_setup		= xprt_rdma_bc_setup,
+	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
+	.bc_destroy		= xprt_rdma_bc_destroy,
+#endif
 };
 
 static struct xprt_class xprt_rdma = {
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index baa0523..7f0ed30 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -831,7 +831,21 @@ retry:
 		}
 		rc = ep->rep_connected;
 	} else {
+		struct rpcrdma_xprt *r_xprt;
+		unsigned int extras;
+
 		dprintk("RPC:       %s: connected\n", __func__);
+
+		r_xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
+		extras = r_xprt->rx_buf.rb_bc_srv_max_requests;
+
+		if (extras) {
+			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
+			if (rc)
+				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
+					__func__, rc);
+				rc = 0;
+		}
 	}
 
 out:
@@ -868,20 +882,25 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	}
 }
 
-static struct rpcrdma_req *
+struct rpcrdma_req *
 rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
 	struct rpcrdma_req *req;
 
 	req = kzalloc(sizeof(*req), GFP_KERNEL);
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	INIT_LIST_HEAD(&req->rl_free);
+	spin_lock(&buffer->rb_reqslock);
+	list_add(&req->rl_all, &buffer->rb_allreqs);
+	spin_unlock(&buffer->rb_reqslock);
 	req->rl_buffer = &r_xprt->rx_buf;
 	return req;
 }
 
-static struct rpcrdma_rep *
+struct rpcrdma_rep *
 rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
@@ -920,6 +939,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	int i, rc;
 
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
+	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_lock);
 
 	rc = ia->ri_ops->ro_init(r_xprt);
@@ -927,6 +947,8 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 		goto out;
 
 	INIT_LIST_HEAD(&buf->rb_send_bufs);
+	INIT_LIST_HEAD(&buf->rb_allreqs);
+	spin_lock_init(&buf->rb_reqslock);
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
 
@@ -937,6 +959,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 			rc = PTR_ERR(req);
 			goto out;
 		}
+		req->rl_backchannel = false;
 		list_add(&req->rl_free, &buf->rb_send_bufs);
 	}
 
@@ -985,19 +1008,13 @@ rpcrdma_buffer_get_rep_locked(struct rpcrdma_buffer *buf)
 static void
 rpcrdma_destroy_rep(struct rpcrdma_ia *ia, struct rpcrdma_rep *rep)
 {
-	if (!rep)
-		return;
-
 	rpcrdma_free_regbuf(ia, rep->rr_rdmabuf);
 	kfree(rep);
 }
 
-static void
+void
 rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 {
-	if (!req)
-		return;
-
 	rpcrdma_free_regbuf(ia, req->rl_sendbuf);
 	rpcrdma_free_regbuf(ia, req->rl_rdmabuf);
 	kfree(req);
@@ -1015,12 +1032,19 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		rpcrdma_destroy_rep(ia, rep);
 	}
 
-	while (!list_empty(&buf->rb_send_bufs)) {
+	spin_lock(&buf->rb_reqslock);
+	while (!list_empty(&buf->rb_allreqs)) {
 		struct rpcrdma_req *req;
 
-		req = rpcrdma_buffer_get_req_locked(buf);
+		req = list_first_entry(&buf->rb_allreqs,
+				       struct rpcrdma_req, rl_all);
+		list_del(&req->rl_all);
+
+		spin_unlock(&buf->rb_reqslock);
 		rpcrdma_destroy_req(ia, req);
+		spin_lock(&buf->rb_reqslock);
 	}
+	spin_unlock(&buf->rb_reqslock);
 
 	ia->ri_ops->ro_destroy(buf);
 }
@@ -1288,6 +1312,47 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 	return rc;
 }
 
+/**
+ * rpcrdma_ep_post_extra_recv - Post buffers for incoming backchannel requests
+ * @r_xprt: transport associated with these backchannel resources
+ * @min_reqs: minimum number of incoming requests expected
+ *
+ * Returns zero if all requested buffers were posted, or a negative errno.
+ */
+int
+rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *r_xprt, unsigned int count)
+{
+	struct rpcrdma_buffer *buffers = &r_xprt->rx_buf;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpcrdma_rep *rep;
+	unsigned long flags;
+	int rc;
+
+	while (count--) {
+		spin_lock_irqsave(&buffers->rb_lock, flags);
+		if (list_empty(&buffers->rb_recv_bufs))
+			goto out_reqbuf;
+		rep = rpcrdma_buffer_get_rep_locked(buffers);
+		spin_unlock_irqrestore(&buffers->rb_lock, flags);
+
+		rc = rpcrdma_ep_post_recv(ia, ep, rep);
+		if (rc)
+			goto out_rc;
+	}
+
+	return 0;
+
+out_reqbuf:
+	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	pr_warn("%s: no extra receive buffers\n", __func__);
+	return -ENOMEM;
+
+out_rc:
+	rpcrdma_recv_buffer_put(rep);
+	return rc;
+}
+
 /* How many chunk list items fit within our inline buffers?
  */
 unsigned int
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6ea1dbe..1eb86c79f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -263,6 +263,9 @@ struct rpcrdma_req {
 	struct rpcrdma_regbuf	*rl_rdmabuf;
 	struct rpcrdma_regbuf	*rl_sendbuf;
 	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
+
+	struct list_head	rl_all;
+	bool			rl_backchannel;
 };
 
 static inline struct rpcrdma_req *
@@ -291,6 +294,10 @@ struct rpcrdma_buffer {
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
+
+	u32			rb_bc_srv_max_requests;
+	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
+	struct list_head	rb_allreqs;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
@@ -411,6 +418,9 @@ int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
 /*
  * Buffer calls - xprtrdma/verbs.c
  */
+struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
+struct rpcrdma_rep *rpcrdma_create_rep(struct rpcrdma_xprt *);
+void rpcrdma_destroy_req(struct rpcrdma_ia *, struct rpcrdma_req *);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 
@@ -427,6 +437,7 @@ void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 			 struct rpcrdma_regbuf *);
 
 unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
+int rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *, unsigned int);
 
 int frwr_alloc_recovery_wq(void);
 void frwr_destroy_recovery_wq(void);
@@ -494,6 +505,15 @@ int rpcrdma_marshal_req(struct rpc_rqst *);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);
 
+/* Backchannel calls - xprtrdma/backchannel.c
+ */
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
+int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
+void xprt_rdma_bc_free_rqst(struct rpc_rqst *);
+void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);
+#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
+
 /* Temporary NFS request map cache. Created in svc_rdma.c  */
 extern struct kmem_cache *svc_rdma_map_cachep;
 /* WR context cache. Created in svc_rdma.c  */

