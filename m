Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33853 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbAUQEK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:04:10 -0500
Subject: [PATCH v3 16/20] xprtrdma: Allocate RPC send buffer separately from
 struct rpcrdma_req
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:04:08 -0500
Message-ID: <20150121160408.17297.62467.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because internal memory registration is an expensive and synchronous
operation, xprtrdma pre-registers send and receive buffers at mount
time, and then re-uses them for each RPC.

A "hardway" allocation is a memory allocation and registration that
replaces a send buffer during the processing of an RPC. Hardway must
be done if the RPC send buffer is too small to accommodate an RPC's
call and reply headers.

For xprtrdma, each RPC send buffer is currently part of struct
rpcrdma_req so that xprt_rdma_free(), which is passed nothing but
the address of an RPC send buffer, can find its matching struct
rpcrdma_req and rpcrdma_rep quickly via container_of / offsetof.

That means that hardway currently has to replace a whole rpcrmda_req
when it replaces an RPC send buffer. This is often a fairly hefty
chunk of contiguous memory due to the size of the rl_segments array
and the fact that both the send and receive buffers are part of
struct rpcrdma_req.

Some obscure re-use of fields in rpcrdma_req is done so that
xprt_rdma_free() can detect replaced rpcrdma_req structs, and
restore the original.

This commit breaks apart the RPC send buffer and struct rpcrdma_req
so that increasing the size of the rl_segments array does not change
the alignment of each RPC send buffer. (Increasing rl_segments is
needed to bump up the maximum r/wsize for NFS/RDMA).

This change opens up some interesting possibilities for improving
the design of xprt_rdma_allocate().

xprt_rdma_allocate() is now the one place where RPC send buffers
are allocated or re-allocated, and they are now always left in place
by xprt_rdma_free().

A large re-allocation that includes both the rl_segments array and
the RPC send buffer is no longer needed. Send buffer re-allocation
becomes quite rare. Good send buffer alignment is guaranteed no
matter what the size of the rl_segments array is.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +-
 net/sunrpc/xprtrdma/transport.c |  146 ++++++++++++++++-----------------------
 net/sunrpc/xprtrdma/verbs.c     |   16 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |   14 +++-
 4 files changed, 78 insertions(+), 104 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f2eda15..8a6bdbd 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -541,9 +541,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = req->rl_iov.lkey;
 
-	req->rl_send_iov[1].addr = req->rl_iov.addr + (base - req->rl_base);
+	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
-	req->rl_send_iov[1].lkey = req->rl_iov.lkey;
+	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
 	req->rl_niovs = 2;
 
@@ -556,7 +556,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 
 		req->rl_send_iov[3].addr = req->rl_send_iov[1].addr + rpclen;
 		req->rl_send_iov[3].length = rqst->rq_slen - rpclen;
-		req->rl_send_iov[3].lkey = req->rl_iov.lkey;
+		req->rl_send_iov[3].lkey = rdmab_lkey(req->rl_sendbuf);
 
 		req->rl_niovs = 4;
 	}
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 808b3c5..a9d5662 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -449,77 +449,72 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 /*
  * The RDMA allocate/free functions need the task structure as a place
  * to hide the struct rpcrdma_req, which is necessary for the actual send/recv
- * sequence. For this reason, the recv buffers are attached to send
- * buffers for portions of the RPC. Note that the RPC layer allocates
- * both send and receive buffers in the same call. We may register
- * the receive buffer portion when using reply chunks.
+ * sequence.
+ *
+ * The RPC layer allocates both send and receive buffers in the same call
+ * (rq_send_buf and rq_rcv_buf are both part of a single contiguous buffer).
+ * We may register rq_rcv_buf when using reply chunks.
  */
 static void *
 xprt_rdma_allocate(struct rpc_task *task, size_t size)
 {
 	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
-	struct rpcrdma_req *req, *nreq;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_regbuf *rb;
+	struct rpcrdma_req *req;
+	size_t min_size;
+	gfp_t flags = task->tk_flags & RPC_TASK_SWAPPER ?
+						GFP_ATOMIC : GFP_NOFS;
 
-	req = rpcrdma_buffer_get(&rpcx_to_rdmax(xprt)->rx_buf);
+	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
 	if (req == NULL)
 		return NULL;
 
-	if (size > req->rl_size) {
-		dprintk("RPC:       %s: size %zd too large for buffer[%zd]: "
-			"prog %d vers %d proc %d\n",
-			__func__, size, req->rl_size,
-			task->tk_client->cl_prog, task->tk_client->cl_vers,
-			task->tk_msg.rpc_proc->p_proc);
-		/*
-		 * Outgoing length shortage. Our inline write max must have
-		 * been configured to perform direct i/o.
-		 *
-		 * This is therefore a large metadata operation, and the
-		 * allocate call was made on the maximum possible message,
-		 * e.g. containing long filename(s) or symlink data. In
-		 * fact, while these metadata operations *might* carry
-		 * large outgoing payloads, they rarely *do*. However, we
-		 * have to commit to the request here, so reallocate and
-		 * register it now. The data path will never require this
-		 * reallocation.
-		 *
-		 * If the allocation or registration fails, the RPC framework
-		 * will (doggedly) retry.
-		 */
-		if (task->tk_flags & RPC_TASK_SWAPPER)
-			nreq = kmalloc(sizeof *req + size, GFP_ATOMIC);
-		else
-			nreq = kmalloc(sizeof *req + size, GFP_NOFS);
-		if (nreq == NULL)
-			goto outfail;
-
-		if (rpcrdma_register_internal(&rpcx_to_rdmax(xprt)->rx_ia,
-				nreq->rl_base, size + sizeof(struct rpcrdma_req)
-				- offsetof(struct rpcrdma_req, rl_base),
-				&nreq->rl_handle, &nreq->rl_iov)) {
-			kfree(nreq);
-			goto outfail;
-		}
-		rpcx_to_rdmax(xprt)->rx_stats.hardway_register_count += size;
-		nreq->rl_size = size;
-		nreq->rl_niovs = 0;
-		nreq->rl_nchunks = 0;
-		nreq->rl_buffer = (struct rpcrdma_buffer *)req;
-		nreq->rl_reply = req->rl_reply;
-		memcpy(nreq->rl_segments,
-			req->rl_segments, sizeof nreq->rl_segments);
-		/* flag the swap with an unused field */
-		nreq->rl_iov.length = 0;
-		req->rl_reply = NULL;
-		req = nreq;
-	}
+	if (req->rl_sendbuf == NULL)
+		goto out_sendbuf;
+	if (size > req->rl_sendbuf->rg_size)
+		goto out_sendbuf;
+
+out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
-	return req->rl_xdr_buf;
-
-outfail:
+	return req->rl_sendbuf->rg_base;
+
+out_sendbuf:
+	/* XDR encoding and RPC/RDMA marshaling of this request has not
+	 * yet occurred. Thus a lower bound is needed to prevent buffer
+	 * overrun during marshaling.
+	 *
+	 * RPC/RDMA marshaling may choose to send payload bearing ops
+	 * inline, if the result is smaller than the inline threshold.
+	 * The value of the "size" argument accounts for header
+	 * requirements but not for the payload in these cases.
+	 *
+	 * Likewise, allocate enough space to receive a reply up to the
+	 * size of the inline threshold.
+	 *
+	 * It's unlikely that both the send header and the received
+	 * reply will be large, but slush is provided here to allow
+	 * flexibility when marshaling.
+	 */
+	min_size = RPCRDMA_INLINE_READ_THRESHOLD(task->tk_rqstp);
+	min_size += RPCRDMA_INLINE_WRITE_THRESHOLD(task->tk_rqstp);
+	if (size < min_size)
+		size = min_size;
+
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
+	if (IS_ERR(rb))
+		goto out_fail;
+	rb->rg_owner = req;
+
+	r_xprt->rx_stats.hardway_register_count += size;
+	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_sendbuf);
+	req->rl_sendbuf = rb;
+	goto out;
+
+out_fail:
 	rpcrdma_buffer_put(req);
-	rpcx_to_rdmax(xprt)->rx_stats.failed_marshal_count++;
+	r_xprt->rx_stats.failed_marshal_count++;
 	return NULL;
 }
 
@@ -531,47 +526,24 @@ xprt_rdma_free(void *buffer)
 {
 	struct rpcrdma_req *req;
 	struct rpcrdma_xprt *r_xprt;
-	struct rpcrdma_rep *rep;
+	struct rpcrdma_regbuf *rb;
 	int i;
 
 	if (buffer == NULL)
 		return;
 
-	req = container_of(buffer, struct rpcrdma_req, rl_xdr_buf[0]);
-	if (req->rl_iov.length == 0) {	/* see allocate above */
-		r_xprt = container_of(((struct rpcrdma_req *) req->rl_buffer)->rl_buffer,
-				      struct rpcrdma_xprt, rx_buf);
-	} else
-		r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
-	rep = req->rl_reply;
+	rb = container_of(buffer, struct rpcrdma_regbuf, rg_base[0]);
+	req = rb->rg_owner;
+	r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
 
-	dprintk("RPC:       %s: called on 0x%p%s\n",
-		__func__, rep, (rep && rep->rr_func) ? " (with waiter)" : "");
+	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	/*
-	 * Finish the deregistration.  The process is considered
-	 * complete when the rr_func vector becomes NULL - this
-	 * was put in place during rpcrdma_reply_handler() - the wait
-	 * call below will not block if the dereg is "done". If
-	 * interrupted, our framework will clean up.
-	 */
 	for (i = 0; req->rl_nchunks;) {
 		--req->rl_nchunks;
 		i += rpcrdma_deregister_external(
 			&req->rl_segments[i], r_xprt);
 	}
 
-	if (req->rl_iov.length == 0) {	/* see allocate above */
-		struct rpcrdma_req *oreq = (struct rpcrdma_req *)req->rl_buffer;
-		oreq->rl_reply = req->rl_reply;
-		(void) rpcrdma_deregister_internal(&r_xprt->rx_ia,
-						   req->rl_handle,
-						   &req->rl_iov);
-		kfree(req);
-		req = oreq;
-	}
-
-	/* Put back request+reply buffers */
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cdd6aac..4089440 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1079,25 +1079,22 @@ static struct rpcrdma_req *
 rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	size_t wlen = 1 << fls(cdata->inline_wsize +
-			       sizeof(struct rpcrdma_req));
+	size_t wlen = cdata->inline_wsize;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_req *req;
 	int rc;
 
 	rc = -ENOMEM;
-	req = kmalloc(wlen, GFP_KERNEL);
+	req = kmalloc(sizeof(*req) + wlen, GFP_KERNEL);
 	if (req == NULL)
 		goto out;
-	memset(req, 0, sizeof(struct rpcrdma_req));
+	memset(req, 0, sizeof(*req));
 
-	rc = rpcrdma_register_internal(ia, req->rl_base, wlen -
-				       offsetof(struct rpcrdma_req, rl_base),
+	rc = rpcrdma_register_internal(ia, req->rl_base, wlen,
 				       &req->rl_handle, &req->rl_iov);
 	if (rc)
 		goto out_free;
 
-	req->rl_size = wlen - sizeof(struct rpcrdma_req);
 	req->rl_buffer = &r_xprt->rx_buf;
 	return req;
 
@@ -1121,7 +1118,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 	rep = kmalloc(rlen, GFP_KERNEL);
 	if (rep == NULL)
 		goto out;
-	memset(rep, 0, sizeof(struct rpcrdma_rep));
+	memset(rep, 0, sizeof(*rep));
 
 	rc = rpcrdma_register_internal(ia, rep->rr_base, rlen -
 				       offsetof(struct rpcrdma_rep, rr_base),
@@ -1335,6 +1332,7 @@ rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 	if (!req)
 		return;
 
+	rpcrdma_free_regbuf(ia, req->rl_sendbuf);
 	rpcrdma_deregister_internal(ia, req->rl_handle, &req->rl_iov);
 	kfree(req);
 }
@@ -1729,8 +1727,6 @@ rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	unsigned long flags;
 
-	if (req->rl_iov.length == 0)	/* special case xprt_rdma_allocate() */
-		buffers = ((struct rpcrdma_req *) buffers)->rl_buffer;
 	spin_lock_irqsave(&buffers->rb_lock, flags);
 	if (buffers->rb_recv_index < buffers->rb_max_requests) {
 		req->rl_reply = buffers->rb_recv_bufs[buffers->rb_recv_index];
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 36c37c6..aa82f8d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -262,7 +262,6 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 };
 
 struct rpcrdma_req {
-	size_t 		rl_size;	/* actual length of buffer */
 	unsigned int	rl_niovs;	/* 0, 2 or 4 */
 	unsigned int	rl_nchunks;	/* non-zero if chunks */
 	unsigned int	rl_connect_cookie;	/* retry detection */
@@ -271,13 +270,20 @@ struct rpcrdma_req {
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
 	struct rpcrdma_mr_seg rl_segments[RPCRDMA_MAX_SEGS];/* chunk segments */
 	struct ib_sge	rl_send_iov[4];	/* for active requests */
+	struct rpcrdma_regbuf *rl_sendbuf;
 	struct ib_sge	rl_iov;		/* for posting */
 	struct ib_mr	*rl_handle;	/* handle for mem in rl_iov */
 	char		rl_base[MAX_RPCRDMAHDR]; /* start of actual buffer */
-	__u32 		rl_xdr_buf[0];	/* start of returned rpc rq_buffer */
 };
-#define rpcr_to_rdmar(r) \
-	container_of((r)->rq_buffer, struct rpcrdma_req, rl_xdr_buf[0])
+
+static inline struct rpcrdma_req *
+rpcr_to_rdmar(struct rpc_rqst *rqst)
+{
+	struct rpcrdma_regbuf *rb = container_of(rqst->rq_buffer,
+						 struct rpcrdma_regbuf,
+						 rg_base[0]);
+	return rb->rg_owner;
+}
 
 /*
  * struct rpcrdma_buffer -- holds list/queue of pre-registered memory for

