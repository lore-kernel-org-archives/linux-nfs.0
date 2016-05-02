Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:34013 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999AbcEBSms (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:42:48 -0400
Subject: [PATCH v3 18/20] xprtrdma: Add ro_unmap_safe memreg method
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:42:46 -0400
Message-ID: <20160502184246.10798.33579.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There needs to be a safe method of releasing registered memory
resources when an RPC terminates. Safe can mean a number of things:

+ Doesn't have to sleep

+ Doesn't rely on having a QP in RTS

ro_unmap_safe will be that safe method. It can be used in cases
where synchronous memory invalidation can deadlock, or needs to have
an active QP.

The important case is fencing an RPC's memory regions after it is
signaled (^C) and before it exits. If this is not done, there is a
window where the server can write an RPC reply into memory that the
client has released and re-used for some other purpose.

Note that this is a full solution for FRWR, but FMR and physical
still have some gaps where a particularly bad server can wreak
some havoc on the client. These gaps are not made worse by this
patch and are expected to be exceptionally rare and timing-based.
They are noted in documenting comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |  105 +++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/frwr_ops.c     |   27 +++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   20 +++++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |    5 --
 net/sunrpc/xprtrdma/transport.c    |    9 +--
 net/sunrpc/xprtrdma/xprt_rdma.h    |    3 +
 6 files changed, 150 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 9d50f3a..a658dcf 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -35,6 +35,64 @@
 /* Maximum scatter/gather per FMR */
 #define RPCRDMA_MAX_FMR_SGES	(64)
 
+static struct workqueue_struct *fmr_recovery_wq;
+
+#define FMR_RECOVERY_WQ_FLAGS		(WQ_UNBOUND)
+
+int
+fmr_alloc_recovery_wq(void)
+{
+	fmr_recovery_wq = alloc_workqueue("fmr_recovery", WQ_UNBOUND, 0);
+	return !fmr_recovery_wq ? -ENOMEM : 0;
+}
+
+void
+fmr_destroy_recovery_wq(void)
+{
+	struct workqueue_struct *wq;
+
+	if (!fmr_recovery_wq)
+		return;
+
+	wq = fmr_recovery_wq;
+	fmr_recovery_wq = NULL;
+	destroy_workqueue(wq);
+}
+
+static int
+__fmr_unmap(struct rpcrdma_mw *mw)
+{
+	LIST_HEAD(l);
+
+	list_add(&mw->fmr.fmr->list, &l);
+	return ib_unmap_fmr(&l);
+}
+
+/* Deferred reset of a single FMR. Generate a fresh rkey by
+ * replacing the MR. There's no recovery if this fails.
+ */
+static void
+__fmr_recovery_worker(struct work_struct *work)
+{
+	struct rpcrdma_mw *mw = container_of(work, struct rpcrdma_mw,
+					    mw_work);
+	struct rpcrdma_xprt *r_xprt = mw->mw_xprt;
+
+	__fmr_unmap(mw);
+	rpcrdma_put_mw(r_xprt, mw);
+	return;
+}
+
+/* A broken MR was discovered in a context that can't sleep.
+ * Defer recovery to the recovery worker.
+ */
+static void
+__fmr_queue_recovery(struct rpcrdma_mw *mw)
+{
+	INIT_WORK(&mw->mw_work, __fmr_recovery_worker);
+	queue_work(fmr_recovery_wq, &mw->mw_work);
+}
+
 static int
 fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	    struct rpcrdma_create_data_internal *cdata)
@@ -92,6 +150,7 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 		if (IS_ERR(r->fmr.fmr))
 			goto out_fmr_err;
 
+		r->mw_xprt = r_xprt;
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
 	}
@@ -107,15 +166,6 @@ out:
 	return rc;
 }
 
-static int
-__fmr_unmap(struct rpcrdma_mw *r)
-{
-	LIST_HEAD(l);
-
-	list_add(&r->fmr.fmr->list, &l);
-	return ib_unmap_fmr(&l);
-}
-
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -242,6 +292,42 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	req->rl_nchunks = 0;
 }
 
+/* Use a slow, safe mechanism to invalidate all memory regions
+ * that were registered for "req".
+ *
+ * In the asynchronous case, DMA unmapping occurs first here
+ * because the rpcrdma_mr_seg is released immediately after this
+ * call. It's contents won't be available in __fmr_dma_unmap later.
+ * FIXME.
+ */
+static void
+fmr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		  bool sync)
+{
+	struct rpcrdma_mr_seg *seg;
+	struct rpcrdma_mw *mw;
+	unsigned int i;
+
+	for (i = 0; req->rl_nchunks; req->rl_nchunks--) {
+		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
+
+		if (sync) {
+			/* ORDER */
+			__fmr_unmap(mw);
+			__fmr_dma_unmap(r_xprt, seg);
+			rpcrdma_put_mw(r_xprt, mw);
+		} else {
+			__fmr_dma_unmap(r_xprt, seg);
+			__fmr_queue_recovery(mw);
+		}
+
+		i += seg->mr_nsegs;
+		seg->mr_nsegs = 0;
+		seg->rl_mw = NULL;
+	}
+}
+
 /* Use the ib_unmap_fmr() verb to prevent further remote
  * access via RDMA READ or RDMA WRITE.
  */
@@ -295,6 +381,7 @@ fmr_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap_sync			= fmr_op_unmap_sync,
+	.ro_unmap_safe			= fmr_op_unmap_safe,
 	.ro_unmap			= fmr_op_unmap,
 	.ro_open			= fmr_op_open,
 	.ro_maxpages			= fmr_op_maxpages,
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 1251a1d..79ba323 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -614,6 +614,32 @@ reset_mrs:
 	goto unmap;
 }
 
+/* Use a slow, safe mechanism to invalidate all memory regions
+ * that were registered for "req".
+ */
+static void
+frwr_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		   bool sync)
+{
+	struct rpcrdma_mr_seg *seg;
+	struct rpcrdma_mw *mw;
+	unsigned int i;
+
+	for (i = 0; req->rl_nchunks; req->rl_nchunks--) {
+		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
+
+		if (sync)
+			__frwr_reset_and_unmap(r_xprt, mw);
+		else
+			__frwr_queue_recovery(mw);
+
+		i += seg->mr_nsegs;
+		seg->mr_nsegs = 0;
+		seg->rl_mw = NULL;
+	}
+}
+
 /* Post a LOCAL_INV Work Request to prevent further remote access
  * via RDMA READ or RDMA WRITE.
  */
@@ -675,6 +701,7 @@ frwr_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap_sync			= frwr_op_unmap_sync,
+	.ro_unmap_safe			= frwr_op_unmap_safe,
 	.ro_unmap			= frwr_op_unmap,
 	.ro_open			= frwr_op_open,
 	.ro_maxpages			= frwr_op_maxpages,
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 2dc6ec2..95ef3a7 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -97,6 +97,25 @@ physical_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		rpcrdma_unmap_one(device, &req->rl_segments[i++]);
 }
 
+/* Use a slow, safe mechanism to invalidate all memory regions
+ * that were registered for "req".
+ *
+ * For physical memory registration, there is no good way to
+ * fence a single MR that has been advertised to the server. The
+ * client has already handed the server an R_key that cannot be
+ * invalidated and is shared by all MRs on this connection.
+ * Tearing down the PD might be the only safe choice, but it's
+ * not clear that a freshly acquired DMA R_key would be different
+ * than the one used by the PD that was just destroyed.
+ * FIXME.
+ */
+static void
+physical_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+		       bool sync)
+{
+	physical_op_unmap_sync(r_xprt, req);
+}
+
 static void
 physical_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -105,6 +124,7 @@ physical_op_destroy(struct rpcrdma_buffer *buf)
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap_sync			= physical_op_unmap_sync,
+	.ro_unmap_safe			= physical_op_unmap_safe,
 	.ro_unmap			= physical_op_unmap,
 	.ro_open			= physical_op_open,
 	.ro_maxpages			= physical_op_maxpages,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9ebaf79..35a8109 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -567,7 +567,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
-	unsigned int pos;
 	ssize_t hdrlen;
 	size_t rpclen;
 	__be32 *iptr;
@@ -697,9 +696,7 @@ out_overflow:
 	return -EIO;
 
 out_unmap:
-	for (pos = 0; req->rl_nchunks--;)
-		pos += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
-						      &req->rl_segments[pos]);
+	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 	return PTR_ERR(iptr);
 }
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 16595ff..99d2e5b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -514,6 +514,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
+	req->rl_task = task;
 	return req->rl_sendbuf->rg_base;
 
 out_rdmabuf:
@@ -570,7 +571,6 @@ xprt_rdma_free(void *buffer)
 	struct rpcrdma_req *req;
 	struct rpcrdma_xprt *r_xprt;
 	struct rpcrdma_regbuf *rb;
-	int i;
 
 	if (buffer == NULL)
 		return;
@@ -584,11 +584,8 @@ xprt_rdma_free(void *buffer)
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	for (i = 0; req->rl_nchunks;) {
-		--req->rl_nchunks;
-		i += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
-						    &req->rl_segments[i]);
-	}
+	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req,
+					    !RPC_IS_ASYNC(req->rl_task));
 
 	rpcrdma_buffer_put(req);
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 97c90a8..59b647e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -295,6 +295,7 @@ struct rpcrdma_req {
 	unsigned int		rl_niovs;
 	unsigned int		rl_nchunks;
 	unsigned int		rl_connect_cookie;
+	struct rpc_task		*rl_task;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
@@ -400,6 +401,8 @@ struct rpcrdma_memreg_ops {
 					 struct rpcrdma_req *);
 	int		(*ro_unmap)(struct rpcrdma_xprt *,
 				    struct rpcrdma_mr_seg *);
+	void		(*ro_unmap_safe)(struct rpcrdma_xprt *,
+					 struct rpcrdma_req *, bool);
 	int		(*ro_open)(struct rpcrdma_ia *,
 				   struct rpcrdma_ep *,
 				   struct rpcrdma_create_data_internal *);

