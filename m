Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31569 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669Ab1ECTw0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 15:52:26 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>, Andy Adamson <andros@netapp.com>
Subject: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Date: Mon,  2 May 2011 21:40:08 -0400
Message-Id: <1304386808-2733-2-git-send-email-andros@netapp.com>
In-Reply-To: <1304386808-2733-1-git-send-email-andros@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Hookup TCP congestion feedback into rpc_slot allocation so that the RPC layer
can fully utilize the negotiated TCP window.

Use a slab cache for rpc_slots. Statically allocate an rpc_xprt rpc_slot slab
cache using GFP_KERNEL to the RPC_DEF_SLOT_TABLE number of slots at
rpc_xprt allocation.

Add a dynamic rpc slot allocator to rpc_xprt_ops which is set only for TCP.
For TCP, trigger a dyamic slot allocation in response to a write_space
callback which is in turn called when the TCP layer is waiting for buffer space.

Dynamically add a slot at the beginning of the RPC call_transmit state. The slot
allocator uses GFP_NOWAIT and will return without allocating a slot if
GFP_NOWAIT allocation fails. This is OK because the write_space callback will
be called again, and the dynamic slot allocator can retry.

Signed-off-by: Andy Adamson <andros@netap.com>
---
 include/linux/sunrpc/sched.h |    2 +
 include/linux/sunrpc/xprt.h  |    6 +++-
 net/sunrpc/clnt.c            |    4 ++
 net/sunrpc/sched.c           |   39 ++++++++++++++++++++++
 net/sunrpc/xprt.c            |   75 +++++++++++++++++++++++++++++++++++++-----
 net/sunrpc/xprtsock.c        |    1 +
 6 files changed, 117 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d81db80..3202d09 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -242,6 +242,8 @@ int		rpc_init_mempool(void);
 void		rpc_destroy_mempool(void);
 extern struct workqueue_struct *rpciod_workqueue;
 void		rpc_prepare_task(struct rpc_task *task);
+void		rpc_free_slot(struct rpc_rqst *req);
+struct rpc_rqst *rpc_alloc_slot(gfp_t gfp);
 
 static inline int rpc_wait_for_completion_task(struct rpc_task *task)
 {
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a0f998c..ae3682c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -118,6 +118,7 @@ struct rpc_xprt_ops {
 	void		(*connect)(struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
 	void		(*buf_free)(void *buffer);
+	void		(*dynamic_slot_alloc)(struct rpc_xprt *xprt);
 	int		(*send_request)(struct rpc_task *task);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_task *task);
@@ -167,7 +168,6 @@ struct rpc_xprt {
 	struct rpc_wait_queue	pending;	/* requests in flight */
 	struct rpc_wait_queue	backlog;	/* waiting for slot */
 	struct list_head	free;		/* free slots */
-	struct rpc_rqst *	slot;		/* slot table storage */
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
@@ -283,6 +283,9 @@ struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
 struct rpc_xprt *	xprt_alloc(struct net *net, int size, int max_req);
 void			xprt_free(struct rpc_xprt *);
+int			xprt_alloc_slot_entries(struct rpc_xprt *xprt,
+						int num_req);
+void			 xprt_add_slot(struct rpc_xprt *xprt);
 
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
 {
@@ -321,6 +324,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_INITIALIZED	(9)
+#define XPRT_WRITE_SPACE	(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e7a96e4..8e21d27 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1276,6 +1276,10 @@ call_transmit(struct rpc_task *task)
 	task->tk_action = call_status;
 	if (task->tk_status < 0)
 		return;
+
+	if (task->tk_xprt->ops->dynamic_slot_alloc)
+		task->tk_xprt->ops->dynamic_slot_alloc(task->tk_xprt);
+
 	task->tk_status = xprt_prepare_transmit(task);
 	if (task->tk_status != 0)
 		return;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6b43ee7..bbd4018 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -33,10 +33,13 @@
 #define RPC_BUFFER_MAXSIZE	(2048)
 #define RPC_BUFFER_POOLSIZE	(8)
 #define RPC_TASK_POOLSIZE	(8)
+#define RPC_SLOT_POOLSIZE	(RPC_TASK_POOLSIZE * RPC_DEF_SLOT_TABLE)
 static struct kmem_cache	*rpc_task_slabp __read_mostly;
 static struct kmem_cache	*rpc_buffer_slabp __read_mostly;
+static struct kmem_cache	*rpc_slot_slabp __read_mostly;
 static mempool_t	*rpc_task_mempool __read_mostly;
 static mempool_t	*rpc_buffer_mempool __read_mostly;
+static mempool_t	*rpc_slot_mempool __read_mostly;
 
 static void			rpc_async_schedule(struct work_struct *);
 static void			 rpc_release_task(struct rpc_task *task);
@@ -961,9 +964,33 @@ static void rpciod_stop(void)
 }
 
 void
+rpc_free_slot(struct rpc_rqst *req)
+{
+	return mempool_free(req, rpc_slot_mempool);
+}
+
+/**
+ * rpc_alloc_slot - rpc_slot allocator
+ *
+ * Static rpc_xprt Initialization:
+ *   Called with GFP_KERNEL
+ *
+ * Dynamic allocation:
+ *   Called with GFP_NOWAIT
+ *   Triggered by write_space callback.
+ */
+struct rpc_rqst *
+rpc_alloc_slot(gfp_t gfp)
+{
+	return (struct rpc_rqst *)mempool_alloc(rpc_slot_mempool, gfp);
+}
+
+void
 rpc_destroy_mempool(void)
 {
 	rpciod_stop();
+	if (rpc_slot_mempool)
+		mempool_destroy(rpc_slot_mempool);
 	if (rpc_buffer_mempool)
 		mempool_destroy(rpc_buffer_mempool);
 	if (rpc_task_mempool)
@@ -972,6 +999,8 @@ rpc_destroy_mempool(void)
 		kmem_cache_destroy(rpc_task_slabp);
 	if (rpc_buffer_slabp)
 		kmem_cache_destroy(rpc_buffer_slabp);
+	if (rpc_slot_slabp)
+		kmem_cache_destroy(rpc_slot_slabp);
 	rpc_destroy_wait_queue(&delay_queue);
 }
 
@@ -998,6 +1027,12 @@ rpc_init_mempool(void)
 					     NULL);
 	if (!rpc_buffer_slabp)
 		goto err_nomem;
+	rpc_slot_slabp = kmem_cache_create("rpc_slots",
+					     sizeof(struct rpc_rqst),
+					     0, SLAB_HWCACHE_ALIGN,
+					     NULL);
+	if (!rpc_slot_slabp)
+		goto err_nomem;
 	rpc_task_mempool = mempool_create_slab_pool(RPC_TASK_POOLSIZE,
 						    rpc_task_slabp);
 	if (!rpc_task_mempool)
@@ -1006,6 +1041,10 @@ rpc_init_mempool(void)
 						      rpc_buffer_slabp);
 	if (!rpc_buffer_mempool)
 		goto err_nomem;
+	rpc_slot_mempool = mempool_create_slab_pool(RPC_SLOT_POOLSIZE,
+						    rpc_slot_slabp);
+	if (!rpc_slot_mempool)
+		goto err_nomem;
 	return 0;
 err_nomem:
 	rpc_destroy_mempool();
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9494c37..1b0aa55 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -498,6 +498,7 @@ void xprt_write_space(struct rpc_xprt *xprt)
 		dprintk("RPC:       write space: waking waiting task on "
 				"xprt %p\n", xprt);
 		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
+		set_bit(XPRT_WRITE_SPACE, &xprt->state);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -957,6 +958,66 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 	spin_unlock(&xprt->reserve_lock);
 }
 
+static void
+xprt_free_slot_entries(struct rpc_xprt *xprt)
+{
+	struct rpc_rqst	*req;
+	int i = 0;
+
+	while (!list_empty(&xprt->free)) {
+		req = list_entry(xprt->free.next, struct rpc_rqst, rq_list);
+		list_del(&req->rq_list);
+		rpc_free_slot(req);
+		i++;
+	}
+	dprintk("<-- %s mempool_free %d reqs\n", __func__, i);
+}
+
+/*
+ * Static transport rpc_slot allocation called only at rpc_xprt allocation.
+ * No need to take the xprt->reserve_lock.
+ */
+int
+xprt_alloc_slot_entries(struct rpc_xprt *xprt, int num_req)
+{
+	struct rpc_rqst *req;
+	int i;
+
+	for (i = 0; i < num_req; i++) {
+		req = rpc_alloc_slot(GFP_KERNEL);
+		if (!req)
+			return -ENOMEM;
+		memset(req, 0, sizeof(*req));
+		list_add(&req->rq_list, &xprt->free);
+	}
+	dprintk("<-- %s mempool_alloc %d reqs\n", __func__,
+		xprt->max_reqs);
+	return 0;
+}
+
+/*
+ * Dynamic rpc_slot allocator. GFP_NOWAIT will not cause rpciod to sleep.
+ * Return NULL if allocation can't be serviced immediately.
+ * Triggered by write_space callback.
+ */
+void
+xprt_add_slot(struct rpc_xprt *xprt)
+{
+	struct rpc_rqst *req;
+
+	if (!test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state))
+		return;
+	req = rpc_alloc_slot(GFP_NOWAIT);
+	if (!req)
+		return;
+	spin_lock(&xprt->reserve_lock);
+	list_add(&req->rq_list, &xprt->free);
+	xprt->max_reqs += 1;
+	spin_unlock(&xprt->reserve_lock);
+
+	dprintk("RPC	added rpc_slot to transport %p\n", xprt);
+}
+
 struct rpc_xprt *xprt_alloc(struct net *net, int size, int max_req)
 {
 	struct rpc_xprt *xprt;
@@ -967,14 +1028,16 @@ struct rpc_xprt *xprt_alloc(struct net *net, int size, int max_req)
 	atomic_set(&xprt->count, 1);
 
 	xprt->max_reqs = max_req;
-	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
-	if (xprt->slot == NULL)
+	/* allocate slots and place on free list */
+	INIT_LIST_HEAD(&xprt->free);
+	if (xprt_alloc_slot_entries(xprt, max_req) != 0)
 		goto out_free;
 
 	xprt->xprt_net = get_net(net);
 	return xprt;
 
 out_free:
+	xprt_free_slot_entries(xprt);
 	kfree(xprt);
 out:
 	return NULL;
@@ -984,7 +1047,7 @@ EXPORT_SYMBOL_GPL(xprt_alloc);
 void xprt_free(struct rpc_xprt *xprt)
 {
 	put_net(xprt->xprt_net);
-	kfree(xprt->slot);
+	xprt_free_slot_entries(xprt);
 	kfree(xprt);
 }
 EXPORT_SYMBOL_GPL(xprt_free);
@@ -1080,7 +1143,6 @@ void xprt_release(struct rpc_task *task)
 struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
 	struct rpc_xprt	*xprt;
-	struct rpc_rqst	*req;
 	struct xprt_class *t;
 
 	spin_lock(&xprt_list_lock);
@@ -1108,7 +1170,6 @@ found:
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
 
-	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv);
 #if defined(CONFIG_NFS_V4_1)
 	spin_lock_init(&xprt->bc_pa_lock);
@@ -1131,10 +1192,6 @@ found:
 	rpc_init_wait_queue(&xprt->resend, "xprt_resend");
 	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
 
-	/* initialize free list */
-	for (req = &xprt->slot[xprt->max_reqs-1]; req >= &xprt->slot[0]; req--)
-		list_add(&req->rq_list, &xprt->free);
-
 	xprt_init_xid(xprt);
 
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf005d3..8ab2801 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2115,6 +2115,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.dynamic_slot_alloc	= xprt_add_slot,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_tcp_close,
-- 
1.7.3.1

