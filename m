Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34361 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUNg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:36 -0500
Subject: [PATCH 8/9] xprtrdma: Make rpc_rqst part of rpcrdma_req
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:34 -0500
Message-ID: <20180305201334.10904.30831.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This simplifies allocation of the generic RPC slot and xprtrdma
specific per-RPC resources.

It also makes xprtrdma more like the socket-based transports:
->buf_alloc and ->buf_free are now responsible only for send and
receive buffers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h       |    1 
 net/sunrpc/xprtrdma/backchannel.c |   77 +++++++++++++++++--------------------
 net/sunrpc/xprtrdma/transport.c   |   35 ++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    9 +---
 4 files changed, 46 insertions(+), 76 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 706eef1..336fd1a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -84,7 +84,6 @@ struct rpc_rqst {
 	void (*rq_release_snd_buf)(struct rpc_rqst *); /* release rq_enc_pages */
 	struct list_head	rq_list;
 
-	void			*rq_xprtdata;	/* Per-xprt private data */
 	void			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
 	void			*rq_rbuffer;	/* Reply XDR decode buffer */
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 47ebac9..4034788 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -29,29 +29,41 @@ static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
 	spin_unlock(&buf->rb_reqslock);
 
 	rpcrdma_destroy_req(req);
-
-	kfree(rqst);
 }
 
-static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
-				 struct rpc_rqst *rqst)
+static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
+				 unsigned int count)
 {
-	struct rpcrdma_regbuf *rb;
-	struct rpcrdma_req *req;
-	size_t size;
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpc_rqst *rqst;
+	unsigned int i;
+
+	for (i = 0; i < (count << 1); i++) {
+		struct rpcrdma_regbuf *rb;
+		struct rpcrdma_req *req;
+		size_t size;
+
+		req = rpcrdma_create_req(r_xprt);
+		if (IS_ERR(req))
+			return PTR_ERR(req);
+		rqst = &req->rl_slot;
+
+		rqst->rq_xprt = xprt;
+		INIT_LIST_HEAD(&rqst->rq_list);
+		INIT_LIST_HEAD(&rqst->rq_bc_list);
+		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
+		spin_lock_bh(&xprt->bc_pa_lock);
+		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
+		spin_unlock_bh(&xprt->bc_pa_lock);
 
-	req = rpcrdma_create_req(r_xprt);
-	if (IS_ERR(req))
-		return PTR_ERR(req);
-
-	size = r_xprt->rx_data.inline_rsize;
-	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
-	if (IS_ERR(rb))
-		goto out_fail;
-	req->rl_sendbuf = rb;
-	xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base,
-		     min_t(size_t, size, PAGE_SIZE));
-	rpcrdma_set_xprtdata(rqst, req);
+		size = r_xprt->rx_data.inline_rsize;
+		rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
+		if (IS_ERR(rb))
+			goto out_fail;
+		req->rl_sendbuf = rb;
+		xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base,
+			     min_t(size_t, size, PAGE_SIZE));
+	}
 	return 0;
 
 out_fail:
@@ -86,9 +98,6 @@ static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
 int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
-	struct rpc_rqst *rqst;
-	unsigned int i;
 	int rc;
 
 	/* The backchannel reply path returns each rpc_rqst to the
@@ -103,25 +112,9 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 	if (reqs > RPCRDMA_BACKWARD_WRS >> 1)
 		goto out_err;
 
-	for (i = 0; i < (reqs << 1); i++) {
-		rqst = kzalloc(sizeof(*rqst), GFP_KERNEL);
-		if (!rqst)
-			goto out_free;
-
-		dprintk("RPC:       %s: new rqst %p\n", __func__, rqst);
-
-		rqst->rq_xprt = &r_xprt->rx_xprt;
-		INIT_LIST_HEAD(&rqst->rq_list);
-		INIT_LIST_HEAD(&rqst->rq_bc_list);
-		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
-
-		if (rpcrdma_bc_setup_rqst(r_xprt, rqst))
-			goto out_free;
-
-		spin_lock_bh(&xprt->bc_pa_lock);
-		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
-		spin_unlock_bh(&xprt->bc_pa_lock);
-	}
+	rc = rpcrdma_bc_setup_reqs(r_xprt, reqs);
+	if (rc)
+		goto out_free;
 
 	rc = rpcrdma_bc_setup_reps(r_xprt, reqs);
 	if (rc)
@@ -131,7 +124,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 	if (rc)
 		goto out_free;
 
-	buffer->rb_bc_srv_max_requests = reqs;
+	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
 	request_module("svcrdma");
 	trace_xprtrdma_cb_setup(r_xprt, reqs);
 	return 0;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1dac949..e0ab2b2 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -330,9 +330,7 @@
 		return ERR_PTR(-EBADF);
 	}
 
-	xprt = xprt_alloc(args->net, sizeof(struct rpcrdma_xprt),
-			xprt_rdma_slot_table_entries,
-			xprt_rdma_slot_table_entries);
+	xprt = xprt_alloc(args->net, sizeof(struct rpcrdma_xprt), 0, 0);
 	if (xprt == NULL) {
 		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
 			__func__);
@@ -364,7 +362,7 @@
 		xprt_set_bound(xprt);
 	xprt_rdma_format_addresses(xprt, sap);
 
-	cdata.max_requests = xprt->max_reqs;
+	cdata.max_requests = xprt_rdma_slot_table_entries;
 
 	cdata.rsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA write max */
 	cdata.wsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA read max */
@@ -549,22 +547,18 @@
 static void
 xprt_rdma_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 {
-	struct rpc_rqst *rqst;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_req *req;
 
-	spin_lock(&xprt->reserve_lock);
-	if (list_empty(&xprt->free))
+	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
+	if (!req)
 		goto out_sleep;
-	rqst = list_first_entry(&xprt->free, struct rpc_rqst, rq_list);
-	list_del(&rqst->rq_list);
-	spin_unlock(&xprt->reserve_lock);
-
-	task->tk_rqstp = rqst;
+	task->tk_rqstp = &req->rl_slot;
 	task->tk_status = 0;
 	return;
 
 out_sleep:
 	rpc_sleep_on(&xprt->backlog, task, NULL);
-	spin_unlock(&xprt->reserve_lock);
 	task->tk_status = -EAGAIN;
 }
 
@@ -578,11 +572,8 @@
 xprt_rdma_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *rqst)
 {
 	memset(rqst, 0, sizeof(*rqst));
-
-	spin_lock(&xprt->reserve_lock);
-	list_add(&rqst->rq_list, &xprt->free);
+	rpcrdma_buffer_put(rpcr_to_rdmar(rqst));
 	rpc_wake_up_next(&xprt->backlog);
-	spin_unlock(&xprt->reserve_lock);
 }
 
 static bool
@@ -655,13 +646,9 @@
 {
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
-	struct rpcrdma_req *req;
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	gfp_t flags;
 
-	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
-	if (req == NULL)
-		goto out_get;
-
 	flags = RPCRDMA_DEF_GFP;
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
@@ -671,15 +658,12 @@
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
 		goto out_fail;
 
-	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
 	trace_xprtrdma_allocate(task, req);
 	return 0;
 
 out_fail:
-	rpcrdma_buffer_put(req);
-out_get:
 	trace_xprtrdma_allocate(task, NULL);
 	return -ENOMEM;
 }
@@ -700,7 +684,6 @@
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
 		rpcrdma_release_rqst(r_xprt, req);
 	trace_xprtrdma_rpc_done(task, req);
-	rpcrdma_buffer_put(req);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3d3b423..b35d80b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -334,6 +334,7 @@ enum {
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
+	struct rpc_rqst		rl_slot;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
 	struct xdr_stream	rl_stream;
@@ -356,16 +357,10 @@ enum {
 	RPCRDMA_REQ_F_TX_RESOURCES,
 };
 
-static inline void
-rpcrdma_set_xprtdata(struct rpc_rqst *rqst, struct rpcrdma_req *req)
-{
-	rqst->rq_xprtdata = req;
-}
-
 static inline struct rpcrdma_req *
 rpcr_to_rdmar(const struct rpc_rqst *rqst)
 {
-	return rqst->rq_xprtdata;
+	return container_of(rqst, struct rpcrdma_req, rl_slot);
 }
 
 static inline void

