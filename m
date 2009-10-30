Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59707 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754731AbZJ3FwP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2009 01:52:15 -0400
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 30 Oct 2009 16:53:46 +1100
Content-Type: text/plain; charset=us-ascii
Message-ID: <19178.32618.958277.726234@notabene.brown>
Cc: Martin Wilck <martin.wilck@ts.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: replace large table of slots with mempool
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


From: Martin Wilck <martin.wilck@ts.fujitsu.com>
Date: Fri, 30 Oct 2009 16:35:19 +1100

If {udp,tcp}_slot_table_entries exceeds 111 (on x86-64),
the allocated slot table exceeds 32K and so requires an
order-4 allocation.
As 4 exceeds PAGE_ALLOC_COSTLY_ORDER (==3), these are more
likely to fail, so the chance of a mount failing due to low or
fragmented memory goes up significantly.

This is particularly a problem for autofs which can try a mount
at any time and does not retry in the face of failure.

There is no really need for the slots to be allocated in a single
slab of memory.  Using a kmemcache, particularly when fronted by
a mempool to allow allocation to usually succeed in atomic context,
avoid the need for a large allocation, and also reduces memory waste
in cases where not all of the slots are required.

This patch replaces the single  kmalloc per client with a mempool
shared among all clients.

Signed-off-by: NeilBrown <neilb@suse.de>
---

The only thing that I'm not completely confident about in this patch
is 
   #define RPC_RQST_POOLSIZE	(128)
simply because it is an arbitrary number.  This allocations will only
come from this pool when a GFP_ATOMIC alloc fails, so memory has to 
be tight.  Allowing a further 128 requests which might serve to
free up memory is probably enough.

If/when the swap-over-nfs gets upstream it will need to handle this
memory pool as well ofcourse.

NeilBrown


 include/linux/sunrpc/sched.h |    2 ++
 include/linux/sunrpc/xprt.h  |    4 +---
 net/sunrpc/sched.c           |   36 ++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c            |   31 ++++++++++++-------------------
 net/sunrpc/xprtsock.c        |   11 -----------
 5 files changed, 51 insertions(+), 33 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 4010977..4442b6a 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -208,6 +208,8 @@ struct rpc_wait_queue {
 /*
  * Function prototypes
  */
+struct rpc_rqst *rpc_alloc_rqst(struct rpc_task *task);
+void rpc_free_rqst(struct rpc_rqst *req);
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6f9457a..521a60b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -163,9 +163,8 @@ struct rpc_xprt {
 	struct rpc_wait_queue	resend;		/* requests waiting to resend */
 	struct rpc_wait_queue	pending;	/* requests in flight */
 	struct rpc_wait_queue	backlog;	/* waiting for slot */
-	struct list_head	free;		/* free slots */
-	struct rpc_rqst *	slot;		/* slot table storage */
 	unsigned int		max_reqs;	/* total slots */
+	atomic_t		busy_reqs;      /* busy slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				resvport   : 1; /* use a reserved port */
@@ -193,7 +192,6 @@ struct rpc_xprt {
 	 * Send stuff
 	 */
 	spinlock_t		transport_lock;	/* lock transport info */
-	spinlock_t		reserve_lock;	/* lock slot table */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index cef74ba..89d6fe6 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -34,10 +34,13 @@
 #define RPC_BUFFER_MAXSIZE	(2048)
 #define RPC_BUFFER_POOLSIZE	(8)
 #define RPC_TASK_POOLSIZE	(8)
+#define RPC_RQST_POOLSIZE	(128)
 static struct kmem_cache	*rpc_task_slabp __read_mostly;
 static struct kmem_cache	*rpc_buffer_slabp __read_mostly;
+static struct kmem_cache	*rpc_rqst_slabp __read_mostly;
 static mempool_t	*rpc_task_mempool __read_mostly;
 static mempool_t	*rpc_buffer_mempool __read_mostly;
+static mempool_t	*rpc_rqst_mempool __read_mostly;
 
 static void			rpc_async_schedule(struct work_struct *);
 static void			 rpc_release_task(struct rpc_task *task);
@@ -831,6 +834,18 @@ rpc_alloc_task(void)
 	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
 }
 
+struct rpc_rqst *
+rpc_alloc_rqst(struct rpc_task *task)
+{
+	gfp_t gfp = RPC_IS_SWAPPER(task) ? GFP_ATOMIC : GFP_NOWAIT;
+	return (struct rpc_rqst *)mempool_alloc(rpc_rqst_mempool, gfp);
+}
+
+void rpc_free_rqst(struct rpc_rqst *req)
+{
+	mempool_free(req, rpc_rqst_mempool);
+}
+
 /*
  * Create a new task for the specified client.
  */
@@ -993,11 +1008,22 @@ rpc_destroy_mempool(void)
 		mempool_destroy(rpc_buffer_mempool);
 	if (rpc_task_mempool)
 		mempool_destroy(rpc_task_mempool);
+	if (rpc_rqst_mempool)
+		mempool_destroy(rpc_rqst_mempool);
 	if (rpc_task_slabp)
 		kmem_cache_destroy(rpc_task_slabp);
 	if (rpc_buffer_slabp)
 		kmem_cache_destroy(rpc_buffer_slabp);
 	rpc_destroy_wait_queue(&delay_queue);
+	if (rpc_rqst_slabp)
+		kmem_cache_destroy(rpc_rqst_slabp);
+}
+
+static void 
+init_rqst(void * foo)
+{
+	struct rpc_rqst *req = foo;
+	memset(req, 0, sizeof(*req));
 }
 
 int
@@ -1023,6 +1049,12 @@ rpc_init_mempool(void)
 					     NULL);
 	if (!rpc_buffer_slabp)
 		goto err_nomem;
+	rpc_rqst_slabp = kmem_cache_create("rpc_rqsts",
+					     sizeof(struct rpc_rqst),
+					     0, SLAB_HWCACHE_ALIGN,
+					     &init_rqst);
+	if (!rpc_rqst_slabp)
+		goto err_nomem;
 	rpc_task_mempool = mempool_create_slab_pool(RPC_TASK_POOLSIZE,
 						    rpc_task_slabp);
 	if (!rpc_task_mempool)
@@ -1031,6 +1063,10 @@ rpc_init_mempool(void)
 						      rpc_buffer_slabp);
 	if (!rpc_buffer_mempool)
 		goto err_nomem;
+	rpc_rqst_mempool = mempool_create_slab_pool(RPC_RQST_POOLSIZE,
+						    rpc_rqst_slabp);
+	if (!rpc_rqst_mempool)
+		goto err_nomem;
 	return 0;
 err_nomem:
 	rpc_destroy_mempool();
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index fd46d42..f9bfec3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -937,12 +937,14 @@ static inline void do_xprt_reserve(struct rpc_task *task)
 	task->tk_status = 0;
 	if (task->tk_rqstp)
 		return;
-	if (!list_empty(&xprt->free)) {
-		struct rpc_rqst	*req = list_entry(xprt->free.next, struct rpc_rqst, rq_list);
-		list_del_init(&req->rq_list);
-		task->tk_rqstp = req;
-		xprt_request_init(task, xprt);
-		return;
+	if (atomic_read(&xprt->busy_reqs) < xprt->max_reqs) {
+		struct rpc_rqst	*req = rpc_alloc_rqst(task);
+		if (req != NULL) {
+			atomic_inc(&xprt->busy_reqs);
+			task->tk_rqstp = req;
+			xprt_request_init(task, xprt);
+			return;
+		}
 	}
 	dprintk("RPC:       waiting for request slot\n");
 	task->tk_status = -EAGAIN;
@@ -959,12 +961,8 @@ static inline void do_xprt_reserve(struct rpc_task *task)
  */
 void xprt_reserve(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt = task->tk_xprt;
-
 	task->tk_status = -EIO;
-	spin_lock(&xprt->reserve_lock);
 	do_xprt_reserve(task);
-	spin_unlock(&xprt->reserve_lock);
 }
 
 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
@@ -981,6 +979,7 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 
+	INIT_LIST_HEAD(&req->rq_list);
 	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
@@ -1039,10 +1038,9 @@ void xprt_release(struct rpc_task *task)
 
 	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
 
-	spin_lock(&xprt->reserve_lock);
-	list_add(&req->rq_list, &xprt->free);
+	rpc_free_rqst(req);
+	atomic_dec(&xprt->busy_reqs);
 	rpc_wake_up_next(&xprt->backlog);
-	spin_unlock(&xprt->reserve_lock);
 }
 
 /**
@@ -1077,9 +1075,7 @@ found:
 
 	kref_init(&xprt->kref);
 	spin_lock_init(&xprt->transport_lock);
-	spin_lock_init(&xprt->reserve_lock);
 
-	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv);
 #if defined(CONFIG_NFS_V4_1)
 	spin_lock_init(&xprt->bc_pa_lock);
@@ -1102,10 +1098,7 @@ found:
 	rpc_init_wait_queue(&xprt->resend, "xprt_resend");
 	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
 
-	/* initialize free list */
-	for (req = &xprt->slot[xprt->max_reqs-1]; req >= &xprt->slot[0]; req--)
-		list_add(&req->rq_list, &xprt->free);
-
+	atomic_set(&xprt->busy_reqs, 0);
 	xprt_init_xid(xprt);
 
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..a5d23cd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -806,7 +806,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
-	kfree(xprt->slot);
 	kfree(xprt);
 	module_put(THIS_MODULE);
 }
@@ -2309,13 +2308,6 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	xprt = &new->xprt;
 
 	xprt->max_reqs = slot_table_size;
-	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
-	if (xprt->slot == NULL) {
-		kfree(xprt);
-		dprintk("RPC:       xs_setup_xprt: couldn't allocate slot "
-				"table\n");
-		return ERR_PTR(-ENOMEM);
-	}
 
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
@@ -2397,7 +2389,6 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	if (try_module_get(THIS_MODULE))
 		return xprt;
 
-	kfree(xprt->slot);
 	kfree(xprt);
 	return ERR_PTR(-EINVAL);
 }
@@ -2472,7 +2463,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	if (try_module_get(THIS_MODULE))
 		return xprt;
 
-	kfree(xprt->slot);
 	kfree(xprt);
 	return ERR_PTR(-EINVAL);
 }
@@ -2554,7 +2544,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
-	kfree(xprt->slot);
 	kfree(xprt);
 	return ERR_PTR(-EINVAL);
 }
-- 
1.6.4.3

