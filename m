Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35669 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752408AbdIERAn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:00:43 -0400
Subject: [PATCH RFC 3/5] xprtrdma: Add data structure to manage RDMA Send
 arguments
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 05 Sep 2017 13:00:37 -0400
Message-ID: <20170905170037.11106.55212.stgit@manet.1015granger.net>
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently Sagi Grimberg <sagi@grimberg.me> observed that kernel RDMA-
enabled storage initiators don't handle delayed Send completion
correctly. If Send completion is delayed beyond the end of a ULP
transaction, the ULP may release resources that are still being used
by the HCA to complete a long-running Send operation.

This is a common design trait amongst our initiators. Most Send
operations are faster than the ULP transaction they are part of.
Waiting for a completion for these is typically unnecessary.

Infrequently, a network partition or some other problem crops up
where an ordering problem can occur. In this case, the HCA can
try to use memory that has been invalidated or DMA unmapped, and
the connection is lost.

Thus we cannot assume that it is safe to release Send-related
resources just because a ULP reply has arrived.

After some analysis, we have determined that the completion
housekeeping will not be difficult for xprtrdma:
 - Inline Send buffers are registered via the local DMA key, and
   are already left DMA mapped for the lifetime of a transport
   connection, thus no additional handling is necessary for those
 - Gathered Sends involving page cache pages _will_ need to
   DMA unmap those pages after the Send completes. But like
   inline send buffers, they are registered via the local DMA key,
   and thus will not need to be invalidated

In this patch, the rpcrdma_sendctx object is introduced, and a
lock-free circular queue is added to manage a set of them per
transport.

The RPC client's send path already prevents sending more than one
RPC Call at the same time. This allows us to treat the consumer
side of the queue (rpcrdma_sendctx_get_locked) as if there is a
single consumer thread.

The producer side of the queue (rpcrdma_sendctx_put_locked) is
invoked only from the Send completion handler, which is a single
thread of execution (soft IRQ).

The only care that needs to be taken is with the tail index, which
is shared between the producer and consumer. Only the producer
updates the tail index. The consumer compares the head with the
tail to ensure that the a sendctx that is in use is never handed
out again (or, more conventionally, the queue is empty).

When the sendctx queue empties completely, there are enough Sends
outstanding that posting more Send operations can result in a
provider Send queue overflow. In this case, the ULP is told to wait
and try again.

As a final touch, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
suggested a mechanism that does not require signaling every Send.
We signal once every N Sends, and SGE unmapping of N Send operations
during that one completion.

Reported-by: Sagi Grimberg <sagi@grimberg.me>
Suggested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   25 +++++
 net/sunrpc/xprtrdma/transport.c |    5 +
 net/sunrpc/xprtrdma/verbs.c     |  178 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |   33 +++++++
 4 files changed, 239 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 71f43a2..63461bd 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -699,6 +699,31 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 }
 
 /**
+ * rpcrdma_unmap_send_sges - DMA-unmap Send buffers
+ * @sc: send_ctx containing SGEs to unmap
+ *
+ * The first two SGEs are always left mapped. They contain the transport
+ * header and the inline buffer.
+ */
+void
+rpcrdma_unmap_send_sges(struct rpcrdma_sendctx *sc)
+{
+	struct ib_sge *sge;
+
+	dprintk("RPC:       %s: unmapping %u sges for sc=%p\n",
+		__func__, sc->sc_unmap_count, sc);
+
+	sge = &sc->sc_sges[2];
+	while (sc->sc_unmap_count) {
+		ib_dma_unmap_page(sc->sc_device, sge->addr, sge->length,
+				  DMA_TO_DEVICE);
+		++sge;
+		--sc->sc_unmap_count;
+	}
+	sc->sc_wr.num_sge = 0;
+}
+
+/**
  * rpcrdma_marshal_req - Marshal and send one RPC request
  * @r_xprt: controlling transport
  * @rqst: RPC request to be marshaled
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b680591..18cb8b4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -790,11 +790,12 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   r_xprt->rx_stats.failed_marshal_count,
 		   r_xprt->rx_stats.bad_reply_count,
 		   r_xprt->rx_stats.nomsg_call_count);
-	seq_printf(seq, "%lu %lu %lu %lu\n",
+	seq_printf(seq, "%lu %lu %lu %lu %lu\n",
 		   r_xprt->rx_stats.mrs_recovered,
 		   r_xprt->rx_stats.mrs_orphaned,
 		   r_xprt->rx_stats.mrs_allocated,
-		   r_xprt->rx_stats.local_inv_needed);
+		   r_xprt->rx_stats.local_inv_needed,
+		   r_xprt->rx_stats.empty_sendctx_q);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c78fb27..81d081d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -52,6 +52,8 @@
 #include <linux/prefetch.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc_rdma.h>
+
+#include <asm-generic/barrier.h>
 #include <asm/bitops.h>
 
 #include <rdma/ib_cm.h>
@@ -564,6 +566,9 @@
 		ep->rep_attr.cap.max_recv_sge);
 
 	/* set trigger for requesting send completion */
+	ep->rep_send_batch = min_t(unsigned int, RPCRDMA_MAX_SEND_BATCH,
+				   cdata->max_requests >> 2);
+	ep->rep_send_count = ep->rep_send_batch;
 	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
 	if (ep->rep_cqinit <= 2)
 		ep->rep_cqinit = 0;	/* always signal? */
@@ -846,6 +851,173 @@
 	ib_drain_qp(ia->ri_id->qp);
 }
 
+/* Fixed-size circular FIFO queue. This implementation is wait-free and
+ * lock-free.
+ *
+ * Consumer is the code path that posts Sends. This path dequeues a
+ * sendctx for use by a Send operation. Multiple consumer threads are
+ * serialized by the RPC transport lock, which allows only one
+ * ->send_request at a time.
+ *
+ * Producer is the code path that handles Send completions. This path
+ * enqueues a sendctx that has been completed. Multiple producer threads
+ * are serialized by the ib_poll_cq() function.
+ */
+
+/* rpcrdma_sendctxs_destroy() assumes caller has already quiesced
+ * queue activity.
+ */
+static void rpcrdma_sendctxs_destroy(struct rpcrdma_buffer *buf)
+{
+	unsigned long i;
+
+	/* Remaining unsignaled Sends could still have mapped SGEs.
+	 * Ensure all SGEs are unmapped before destroying the queue.
+	 */
+	for (i = 0; i <= buf->rb_sc_last; i++) {
+		rpcrdma_unmap_send_sges(buf->rb_sc_ctxs[i]);
+		kfree(buf->rb_sc_ctxs[i]);
+	}
+
+	kfree(buf->rb_sc_ctxs);
+}
+
+static struct rpcrdma_sendctx *rpcrdma_sendctx_create(unsigned int max_sges)
+{
+	struct rpcrdma_sendctx *sc;
+
+	sc = kzalloc(sizeof(*sc) + max_sges * sizeof(struct ib_sge),
+		     GFP_KERNEL);
+	if (!sc)
+		return NULL;
+
+	sc->sc_wr.next = NULL;
+	sc->sc_wr.wr_cqe = &sc->sc_cqe;
+	sc->sc_wr.sg_list = sc->sc_sges;
+	sc->sc_wr.opcode = IB_WR_SEND;
+	sc->sc_cqe.done = rpcrdma_wc_send;
+	return sc;
+}
+
+static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	unsigned long i;
+
+	/* Maximum number of concurrent outstanding Send WRs */
+	i = buf->rb_max_requests + RPCRDMA_MAX_BC_REQUESTS;
+	dprintk("RPC:       %s: allocating %lu send_ctxs (batch size %u)\n",
+		__func__, i, r_xprt->rx_ep.rep_send_batch);
+	buf->rb_sc_ctxs = kcalloc(i, sizeof(struct rpcrdma_sendctx *),
+				  GFP_KERNEL);
+	if (!buf->rb_sc_ctxs)
+		return -ENOMEM;
+
+	buf->rb_sc_last = i - 1;
+	for (i = 0; i <= buf->rb_sc_last; i++) {
+		struct rpcrdma_sendctx *sc;
+
+		sc = rpcrdma_sendctx_create(r_xprt->rx_ia.ri_max_send_sges);
+		if (!sc)
+			goto out_destroy;
+
+		sc->sc_buffers = buf;
+		buf->rb_sc_ctxs[i] = sc;
+	}
+
+	return 0;
+
+out_destroy:
+	rpcrdma_sendctxs_destroy(buf);
+	return -ENOMEM;
+}
+
+/* The sendctx queue is not guaranteed to have a size that is
+ * a power of two, thus the helpers in circ_buf.h cannot be used.
+ * The other option is to use modulus (%), which can be expensive.
+ */
+static unsigned long rpcrdma_sendctx_next(struct rpcrdma_buffer *buf,
+					  unsigned long item)
+{
+	return likely(item < buf->rb_sc_last) ? item + 1 : 0;
+}
+
+/**
+ * rpcrdma_sendctx_get_locked - Acquire a send context
+ * @buf: transport buffers from which to acquire an unused context
+ *
+ * Returns pointer to a free send completion context; or NULL if
+ * the queue is empty.
+ *
+ * Usage: Called before Send WR is posted to acquire an
+ * SGE array.
+ *
+ * The caller serializes calls to this function (per rpcrdma_buffer),
+ * and provides an effective memory barrier that flushes the new value
+ * of rb_sc_head.
+ */
+struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_xprt *r_xprt;
+	struct rpcrdma_sendctx *sc;
+	unsigned long next_head;
+
+	next_head = rpcrdma_sendctx_next(buf, buf->rb_sc_head);
+
+	if (next_head == READ_ONCE(buf->rb_sc_tail))
+		goto out_emptyq;
+
+	/* ORDER: item must be accessed _before_ head is updated */
+	sc = buf->rb_sc_ctxs[next_head];
+
+	/* Releasing the lock in the caller acts as a memory
+	 * barrier that flushes rb_sc_head.
+	 */
+	buf->rb_sc_head = next_head;
+
+	return sc;
+
+out_emptyq:
+	/* The queue is "empty" if there have not been enough Send
+	 * completions recently. This is a sign the Send Queue is
+	 * backing up. Cause the caller to pause and try again.
+	 */
+	dprintk("RPC:       %s: empty sendctx queue\n", __func__);
+	r_xprt = container_of(buf, struct rpcrdma_xprt, rx_buf);
+	r_xprt->rx_stats.empty_sendctx_q++;
+	return NULL;
+}
+
+/**
+ * rpcrdma_sendctx_put_locked - Release a send context
+ * @sc: send context to release
+ *
+ * Usage: Called when Send completes to return a
+ * completed send context to the queue.
+ *
+ * The caller serializes calls to this function (per rpcrdma_buffer).
+ */
+void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
+{
+	struct rpcrdma_buffer *buf = sc->sc_buffers;
+	unsigned long next_tail;
+
+	/* Unmap SGEs of previously completed by unsignaled
+	 * Sends by walking up the queue until @sc is found.
+	 */
+	next_tail = buf->rb_sc_tail;
+	do {
+		next_tail = rpcrdma_sendctx_next(buf, next_tail);
+
+		/* ORDER: item must be accessed _before_ tail is updated */
+		rpcrdma_unmap_send_sges(buf->rb_sc_ctxs[next_tail]);
+
+	} while (buf->rb_sc_ctxs[next_tail] != sc);
+
+	/* Paired with READ_ONCE */
+	smp_store_release(&buf->rb_sc_tail, next_tail);
+}
+
 static void
 rpcrdma_mr_recovery_worker(struct work_struct *work)
 {
@@ -1041,6 +1213,10 @@ struct rpcrdma_rep *
 		list_add(&rep->rr_list, &buf->rb_recv_bufs);
 	}
 
+	rc = rpcrdma_sendctxs_create(r_xprt);
+	if (rc)
+		goto out;
+
 	return 0;
 out:
 	rpcrdma_buffer_destroy(buf);
@@ -1117,6 +1293,8 @@ struct rpcrdma_rep *
 	cancel_delayed_work_sync(&buf->rb_recovery_worker);
 	cancel_delayed_work_sync(&buf->rb_refresh_worker);
 
+	rpcrdma_sendctxs_destroy(buf);
+
 	while (!list_empty(&buf->rb_recv_bufs)) {
 		struct rpcrdma_rep *rep;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 93f3a36..1967e7a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -93,6 +93,8 @@ enum {
  */
 
 struct rpcrdma_ep {
+	unsigned int		rep_send_count;
+	unsigned int		rep_send_batch;
 	atomic_t		rep_cqcount;
 	int			rep_cqinit;
 	int			rep_connected;
@@ -229,6 +231,20 @@ struct rpcrdma_rep {
 	struct ib_recv_wr	rr_recv_wr;
 };
 
+/* struct rpcrdma_sendctx - DMA mapped SGEs to unmap after Send completes
+ */
+struct rpcrdma_buffer;
+struct rpcrdma_sendctx {
+	struct ib_send_wr		sc_wr;
+	struct ib_cqe			sc_cqe;
+
+	struct rpcrdma_buffer		*sc_buffers;
+
+	unsigned int			sc_unmap_count;
+	struct ib_device		*sc_device;
+	struct ib_sge			sc_sges[];
+};
+
 /*
  * struct rpcrdma_mw - external memory region metadata
  *
@@ -337,6 +353,14 @@ enum {
 	RPCRDMA_MAX_SEND_SGES = 1 + 1 + RPCRDMA_MAX_PAGE_SGES + 1,
 };
 
+/* Limit the number of SGEs that can be unmapped during one
+ * Send completion. This caps the amount of work a single
+ * completion can do before returning to the provider.
+ */
+enum {
+	RPCRDMA_MAX_SEND_BATCH = 16,
+};
+
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
@@ -400,6 +424,11 @@ struct rpcrdma_buffer {
 	struct list_head	rb_mws;
 	struct list_head	rb_all;
 
+	unsigned long		rb_sc_head;
+	unsigned long		rb_sc_tail;
+	unsigned long		rb_sc_last;
+	struct rpcrdma_sendctx	**rb_sc_ctxs;
+
 	spinlock_t		rb_lock;	/* protect buf lists */
 	int			rb_send_count, rb_recv_count;
 	struct list_head	rb_send_bufs;
@@ -455,6 +484,7 @@ struct rpcrdma_stats {
 	unsigned long		mrs_recovered;
 	unsigned long		mrs_orphaned;
 	unsigned long		mrs_allocated;
+	unsigned long		empty_sendctx_q;
 
 	/* accessed when receiving a reply */
 	unsigned long long	total_rdma_reply;
@@ -556,6 +586,8 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 void rpcrdma_destroy_req(struct rpcrdma_req *);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
+struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);
+void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc);
 
 static inline void
 rpcrdma_insert_req(struct rpcrdma_buffer *buffers, struct rpcrdma_req *req)
@@ -645,6 +677,7 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			      struct xdr_buf *xdr,
 			      enum rpcrdma_chunktype rtype);
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
+void rpcrdma_unmap_send_sges(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_reply_handler(struct work_struct *work);

