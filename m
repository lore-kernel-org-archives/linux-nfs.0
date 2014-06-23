Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:42456 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaFWWkZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:40:25 -0400
Subject: [PATCH v1 10/13] xprtrdma: Release FRMR segment buffers during
 LOCAL_INV completion
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:40:23 -0400
Message-ID: <20140623224023.1634.67233.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FRMR uses a LOCAL_INV Work Request, which is asynchronous, to
deregister segment buffers.  Other registration strategies use
synchronous deregistration mechanisms (like ib_unmap_fmr()).

For a synchronous deregistration mechanism, it makes sense for
xprt_rdma_free() to put segment buffers back into the buffer pool
immediately once rpcrdma_deregister_external() returns.

This is currently also what FRMR is doing. It is releasing segment
buffers just after the LOCAL_INV WR is posted.

But segment buffers need to be put back after the LOCAL_INV WR
_completes_ (or flushes). Otherwise, rpcrdma_buffer_get() can then
assign these segment buffers to another RPC task while they are
still "in use" by the hardware.

The result of re-using an FRMR too quickly is that it's rkey
no longer matches the rkey that was registered with the provider.
This results in FAST_REG_MR or LOCAL_INV Work Requests completing
with IB_WC_MW_BIND_ERR, and the FRMR, and thus the transport,
becomes unusable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   44 +++++++++++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 2 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f24f0bf..52f57f7 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -62,6 +62,8 @@
 #endif
 
 static void rpcrdma_decrement_frmr_rkey(struct rpcrdma_mw *);
+static void rpcrdma_get_mw(struct rpcrdma_mw *);
+static void rpcrdma_put_mw(struct rpcrdma_mw *);
 
 /*
  * internal functions
@@ -167,6 +169,7 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 		if (fastreg)
 			rpcrdma_decrement_frmr_rkey(mw);
 	}
+	rpcrdma_put_mw(mw);
 }
 
 static int
@@ -1034,7 +1037,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	len += cdata->padding;
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-		len += buf->rb_max_requests * RPCRDMA_MAX_SEGS *
+		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
 				sizeof(struct rpcrdma_mw);
 		break;
 	case RPCRDMA_MTHCAFMR:
@@ -1076,7 +1079,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	r = (struct rpcrdma_mw *)p;
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-		for (i = buf->rb_max_requests * RPCRDMA_MAX_SEGS; i; i--) {
+		for (i = (buf->rb_max_requests+1) * RPCRDMA_MAX_SEGS; i; i--) {
 			r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
 						ia->ri_max_frmr_depth);
 			if (IS_ERR(r->r.frmr.fr_mr)) {
@@ -1252,12 +1255,36 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 }
 
 static void
-rpcrdma_put_mw_locked(struct rpcrdma_mw *mw)
+rpcrdma_free_mw(struct kref *kref)
 {
+	struct rpcrdma_mw *mw = container_of(kref, struct rpcrdma_mw, mw_ref);
 	list_add_tail(&mw->mw_list, &mw->mw_pool->rb_mws);
 }
 
 static void
+rpcrdma_put_mw_locked(struct rpcrdma_mw *mw)
+{
+	kref_put(&mw->mw_ref, rpcrdma_free_mw);
+}
+
+static void
+rpcrdma_get_mw(struct rpcrdma_mw *mw)
+{
+	kref_get(&mw->mw_ref);
+}
+
+static void
+rpcrdma_put_mw(struct rpcrdma_mw *mw)
+{
+	struct rpcrdma_buffer *buffers = mw->mw_pool;
+	unsigned long flags;
+
+	spin_lock_irqsave(&buffers->rb_lock, flags);
+	rpcrdma_put_mw_locked(mw);
+	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+}
+
+static void
 rpcrdma_buffer_put_mw(struct rpcrdma_mw **mw)
 {
 	rpcrdma_put_mw_locked(*mw);
@@ -1304,6 +1331,7 @@ rpcrdma_buffer_get_mws(struct rpcrdma_req *req, struct rpcrdma_buffer *buffers)
 		r = list_entry(buffers->rb_mws.next,
 				struct rpcrdma_mw, mw_list);
 		list_del(&r->mw_list);
+		kref_init(&r->mw_ref);
 		r->mw_pool = buffers;
 		req->rl_segments[i].mr_chunk.rl_mw = r;
 	}
@@ -1583,6 +1611,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, seg1->mr_chunk.rl_mw, i);
 
+	rpcrdma_get_mw(seg1->mr_chunk.rl_mw);
 	if (unlikely(seg1->mr_chunk.rl_mw->r.frmr.fr_state == FRMR_IS_VALID)) {
 		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
 			__func__,
@@ -1595,6 +1624,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		invalidate_wr.send_flags = IB_SEND_SIGNALED;
 		invalidate_wr.ex.invalidate_rkey =
 			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+		rpcrdma_get_mw(seg1->mr_chunk.rl_mw);
 		DECR_CQCOUNT(&r_xprt->rx_ep);
 		post_wr = &invalidate_wr;
 	} else
@@ -1638,6 +1668,9 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	*nsegs = i;
 	return 0;
 out_err:
+	rpcrdma_put_mw(seg1->mr_chunk.rl_mw);
+	if (post_wr == &invalidate_wr)
+		rpcrdma_put_mw(seg1->mr_chunk.rl_mw);
 	while (i--)
 		rpcrdma_unmap_one(ia, --seg);
 	return rc;
@@ -1653,6 +1686,7 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 
 	while (seg1->mr_nsegs--)
 		rpcrdma_unmap_one(ia, seg++);
+	rpcrdma_get_mw(seg1->mr_chunk.rl_mw);
 
 	memset(&invalidate_wr, 0, sizeof invalidate_wr);
 	invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
@@ -1664,9 +1698,11 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	read_lock(&ia->ri_qplock);
 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
 	read_unlock(&ia->ri_qplock);
-	if (rc)
+	if (rc) {
+		rpcrdma_put_mw(seg1->mr_chunk.rl_mw);
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
 			" status %i\n", __func__, rc);
+	}
 	return rc;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b81e5b5..7a140fe 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -44,6 +44,7 @@
 #include <linux/spinlock.h> 		/* spinlock_t, etc */
 #include <linux/atomic.h>			/* atomic_t, etc */
 #include <linux/workqueue.h>		/* struct work_struct */
+#include <linux/kref.h>
 
 #include <rdma/rdma_cm.h>		/* RDMA connection api */
 #include <rdma/ib_verbs.h>		/* RDMA verbs api */
@@ -176,6 +177,7 @@ struct rpcrdma_mw {
 	} r;
 	struct list_head	mw_list;
 	struct rpcrdma_buffer	*mw_pool;
+	struct kref		mw_ref;
 };
 
 #define RPCRDMA_BIT_FASTREG		(0)

