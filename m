Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33168 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbEDR5X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 13:57:23 -0400
Subject: [PATCH v1 04/14] xprtrdma: Use ib_device pointer safely
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 13:57:20 -0400
Message-ID: <20150504175720.3483.80356.stgit@manet.1015granger.net>
In-Reply-To: <20150504174626.3483.97639.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The connect worker can replace ri_id, but prevents ri_id->device
from changing during the lifetime of a transport instance.

Cache a copy of ri_id->device in rpcrdma_ia and in rpcrdma_rep.
The cached copy can be used safely in code that does not serialize
with the connect worker.

Other code can use it to save an extra address generation (one
pointer dereference instead of two).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |    8 +----
 net/sunrpc/xprtrdma/frwr_ops.c     |   12 +++----
 net/sunrpc/xprtrdma/physical_ops.c |    8 +----
 net/sunrpc/xprtrdma/verbs.c        |   61 +++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    2 +
 5 files changed, 43 insertions(+), 48 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 302d4eb..0a96155 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -85,7 +85,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	   int nsegs, bool writing)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct ib_device *device = ia->ri_id->device;
+	struct ib_device *device = ia->ri_device;
 	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
@@ -137,17 +137,13 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_device *device;
 	int rc, nsegs = seg->mr_nsegs;
 	LIST_HEAD(l);
 
 	list_add(&seg1->rl_mw->r.fmr->list, &l);
 	rc = ib_unmap_fmr(&l);
-	read_lock(&ia->ri_qplock);
-	device = ia->ri_id->device;
 	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(device, seg++);
-	read_unlock(&ia->ri_qplock);
+		rpcrdma_unmap_one(ia->ri_device, seg++);
 	if (rc)
 		goto out_err;
 	return nsegs;
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index dff0481..66a85fa 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -137,7 +137,7 @@ static int
 frwr_op_init(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct ib_device *device = r_xprt->rx_ia.ri_id->device;
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
 	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	int i;
@@ -178,7 +178,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	    int nsegs, bool writing)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct ib_device *device = ia->ri_id->device;
+	struct ib_device *device = ia->ri_device;
 	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_mw *mw = seg1->rl_mw;
@@ -263,7 +263,6 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc, nsegs = seg->mr_nsegs;
-	struct ib_device *device;
 
 	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
 
@@ -273,10 +272,9 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
-	read_lock(&ia->ri_qplock);
-	device = ia->ri_id->device;
 	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(device, seg++);
+		rpcrdma_unmap_one(ia->ri_device, seg++);
+	read_lock(&ia->ri_qplock);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
 	if (rc)
@@ -304,7 +302,7 @@ static void
 frwr_op_reset(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct ib_device *device = r_xprt->rx_ia.ri_id->device;
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
 	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	struct rpcrdma_mw *r;
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index ba518af..da149e8 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -50,8 +50,7 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	rpcrdma_map_one(ia->ri_id->device, seg,
-			rpcrdma_data_dir(writing));
+	rpcrdma_map_one(ia->ri_device, seg, rpcrdma_data_dir(writing));
 	seg->mr_rkey = ia->ri_bind_mem->rkey;
 	seg->mr_base = seg->mr_dma;
 	seg->mr_nsegs = 1;
@@ -65,10 +64,7 @@ physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	read_lock(&ia->ri_qplock);
-	rpcrdma_unmap_one(ia->ri_id->device, seg);
-	read_unlock(&ia->ri_qplock);
-
+	rpcrdma_unmap_one(ia->ri_device, seg);
 	return 1;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e1eb7c4..ebcb0e2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -278,7 +278,6 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 {
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
-	struct rpcrdma_ia *ia;
 
 	/* WARNING: Only wr_id and status are reliable at this point */
 	if (wc->status != IB_WC_SUCCESS)
@@ -291,9 +290,8 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 	dprintk("RPC:       %s: rep %p opcode 'recv', length %u: success\n",
 		__func__, rep, wc->byte_len);
 
-	ia = &rep->rr_rxprt->rx_ia;
 	rep->rr_len = wc->byte_len;
-	ib_dma_sync_single_for_cpu(ia->ri_id->device,
+	ib_dma_sync_single_for_cpu(rep->rr_device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
 	prefetch(rdmab_to_msg(rep->rr_rdmabuf));
@@ -489,7 +487,7 @@ connected:
 
 		pr_info("rpcrdma: connection to %pIS:%u on %s, memreg '%s', %d credits, %d responders%s\n",
 			sap, rpc_get_port(sap),
-			ia->ri_id->device->name,
+			ia->ri_device->name,
 			ia->ri_ops->ro_displayname,
 			xprt->rx_buf.rb_max_requests,
 			ird, ird < 4 && ird < tird / 2 ? " (low!)" : "");
@@ -590,8 +588,9 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		rc = PTR_ERR(ia->ri_id);
 		goto out1;
 	}
+	ia->ri_device = ia->ri_id->device;
 
-	ia->ri_pd = ib_alloc_pd(ia->ri_id->device);
+	ia->ri_pd = ib_alloc_pd(ia->ri_device);
 	if (IS_ERR(ia->ri_pd)) {
 		rc = PTR_ERR(ia->ri_pd);
 		dprintk("RPC:       %s: ib_alloc_pd() failed %i\n",
@@ -599,7 +598,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		goto out2;
 	}
 
-	rc = ib_query_device(ia->ri_id->device, devattr);
+	rc = ib_query_device(ia->ri_device, devattr);
 	if (rc) {
 		dprintk("RPC:       %s: ib_query_device failed %d\n",
 			__func__, rc);
@@ -608,7 +607,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 
 	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
 		ia->ri_have_dma_lkey = 1;
-		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
+		ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
 	}
 
 	if (memreg == RPCRDMA_FRMR) {
@@ -623,7 +622,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		}
 	}
 	if (memreg == RPCRDMA_MTHCAFMR) {
-		if (!ia->ri_id->device->alloc_fmr) {
+		if (!ia->ri_device->alloc_fmr) {
 			dprintk("RPC:       %s: MTHCAFMR registration "
 				"not supported by HCA\n", __func__);
 			memreg = RPCRDMA_ALLPHYSICAL;
@@ -773,9 +772,9 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
-	sendcq = ib_create_cq(ia->ri_id->device, rpcrdma_sendcq_upcall,
-				  rpcrdma_cq_async_error_upcall, ep,
-				  ep->rep_attr.cap.max_send_wr + 1, 0);
+	sendcq = ib_create_cq(ia->ri_device, rpcrdma_sendcq_upcall,
+			      rpcrdma_cq_async_error_upcall, ep,
+			      ep->rep_attr.cap.max_send_wr + 1, 0);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
@@ -790,9 +789,9 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 		goto out2;
 	}
 
-	recvcq = ib_create_cq(ia->ri_id->device, rpcrdma_recvcq_upcall,
-				  rpcrdma_cq_async_error_upcall, ep,
-				  ep->rep_attr.cap.max_recv_wr + 1, 0);
+	recvcq = ib_create_cq(ia->ri_device, rpcrdma_recvcq_upcall,
+			      rpcrdma_cq_async_error_upcall, ep,
+			      ep->rep_attr.cap.max_recv_wr + 1, 0);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
 		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
@@ -913,7 +912,7 @@ retry:
 		 * More stuff I haven't thought of!
 		 * Rrrgh!
 		 */
-		if (ia->ri_id->device != id->device) {
+		if (ia->ri_device != id->device) {
 			printk("RPC:       %s: can't reconnect on "
 				"different device!\n", __func__);
 			rdma_destroy_id(id);
@@ -1055,6 +1054,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 		goto out_free;
 	}
 
+	rep->rr_device = ia->ri_device;
 	rep->rr_rxprt = r_xprt;
 	return rep;
 
@@ -1457,9 +1457,9 @@ rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
 	/*
 	 * All memory passed here was kmalloc'ed, therefore phys-contiguous.
 	 */
-	iov->addr = ib_dma_map_single(ia->ri_id->device,
+	iov->addr = ib_dma_map_single(ia->ri_device,
 			va, len, DMA_BIDIRECTIONAL);
-	if (ib_dma_mapping_error(ia->ri_id->device, iov->addr))
+	if (ib_dma_mapping_error(ia->ri_device, iov->addr))
 		return -ENOMEM;
 
 	iov->length = len;
@@ -1503,8 +1503,8 @@ rpcrdma_deregister_internal(struct rpcrdma_ia *ia,
 {
 	int rc;
 
-	ib_dma_unmap_single(ia->ri_id->device,
-			iov->addr, iov->length, DMA_BIDIRECTIONAL);
+	ib_dma_unmap_single(ia->ri_device,
+			    iov->addr, iov->length, DMA_BIDIRECTIONAL);
 
 	if (NULL == mr)
 		return 0;
@@ -1597,15 +1597,18 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 	send_wr.num_sge = req->rl_niovs;
 	send_wr.opcode = IB_WR_SEND;
 	if (send_wr.num_sge == 4)	/* no need to sync any pad (constant) */
-		ib_dma_sync_single_for_device(ia->ri_id->device,
-			req->rl_send_iov[3].addr, req->rl_send_iov[3].length,
-			DMA_TO_DEVICE);
-	ib_dma_sync_single_for_device(ia->ri_id->device,
-		req->rl_send_iov[1].addr, req->rl_send_iov[1].length,
-		DMA_TO_DEVICE);
-	ib_dma_sync_single_for_device(ia->ri_id->device,
-		req->rl_send_iov[0].addr, req->rl_send_iov[0].length,
-		DMA_TO_DEVICE);
+		ib_dma_sync_single_for_device(ia->ri_device,
+					      req->rl_send_iov[3].addr,
+					      req->rl_send_iov[3].length,
+					      DMA_TO_DEVICE);
+	ib_dma_sync_single_for_device(ia->ri_device,
+				      req->rl_send_iov[1].addr,
+				      req->rl_send_iov[1].length,
+				      DMA_TO_DEVICE);
+	ib_dma_sync_single_for_device(ia->ri_device,
+				      req->rl_send_iov[0].addr,
+				      req->rl_send_iov[0].length,
+				      DMA_TO_DEVICE);
 
 	if (DECR_CQCOUNT(ep) > 0)
 		send_wr.send_flags = 0;
@@ -1638,7 +1641,7 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 	recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	recv_wr.num_sge = 1;
 
-	ib_dma_sync_single_for_cpu(ia->ri_id->device,
+	ib_dma_sync_single_for_cpu(ia->ri_device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rdmab_length(rep->rr_rdmabuf),
 				   DMA_BIDIRECTIONAL);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 143eb10..531ad33 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -62,6 +62,7 @@
 struct rpcrdma_ia {
 	const struct rpcrdma_memreg_ops	*ri_ops;
 	rwlock_t		ri_qplock;
+	struct ib_device	*ri_device;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
 	struct ib_mr		*ri_bind_mem;
@@ -173,6 +174,7 @@ struct rpcrdma_buffer;
 
 struct rpcrdma_rep {
 	unsigned int		rr_len;
+	struct ib_device	*rr_device;
 	struct rpcrdma_xprt	*rr_rxprt;
 	void			(*rr_func)(struct rpcrdma_rep *);
 	struct list_head	rr_list;

