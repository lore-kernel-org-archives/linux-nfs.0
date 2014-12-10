Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:39462 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964AbaLJTI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:28 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so2611652qcz.38
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:27 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 13/16] sunrpc: keep a cache of svc_rqsts for each NUMA node
Date: Wed, 10 Dec 2014 14:07:57 -0500
Message-Id: <1418238480-18857-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocating an entire svc_rqst (including all of the pages, etc...) for
each workqueue request is pretty expensive. Keep a cache of allocated
svc_rqst structures for each NUMA node that we keep in svc_pool.

When an xprt needs servicing we look for an existing svc_rqst if
possible, attach the xprt to it and then queue it to do the work. If
one isn't currently available, we queue the svc_xprt work to allocate
one, add it to the cache and then queue the svc_rqst's work to handle
the rest.

In order to keep the cache from growing without bound, we register a
shrinker. Since the cache is already NUMA-aware, we can use a NUMA-aware
shrinker as well.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfssvc.c           |  11 ++--
 include/linux/sunrpc/svc.h |  11 ++++
 net/sunrpc/svc.c           |   1 +
 net/sunrpc/svc_wq.c        | 158 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 172 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 7e22068bdad4..416faf9a77f0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -669,26 +669,25 @@ nfsd_rqst_work(struct work_struct *work)
 	rqstp->rq_server->sv_maxconn = nn->max_connections;
 
 	if (svc_wq_recv(rqstp) < 0) {
-		svc_rqst_free(rqstp);
+		put_svc_rqst(rqstp);
 		return;
 	}
 
 	saved_fs = swap_fs_struct(rqstp->rq_fs);
 	svc_process(rqstp);
-	saved_fs = swap_fs_struct(saved_fs);
-	svc_rqst_free(rqstp);
+	swap_fs_struct(saved_fs);
+	put_svc_rqst(rqstp);
 }
 
 /* work function for workqueue-based nfsd */
 static void
 nfsd_xprt_work(struct work_struct *work)
 {
-	int node = numa_node_id();
 	struct svc_xprt *xprt = container_of(work, struct svc_xprt, xpt_work);
-	struct svc_rqst *rqstp;
 	struct svc_serv *serv = xprt->xpt_server;
+	struct svc_rqst *rqstp;
 
-	rqstp = svc_rqst_alloc(serv, &serv->sv_pools[node], node);
+	rqstp = find_or_alloc_svc_rqst(serv);
 	if (!rqstp) {
 		/* Alloc failure. Give up for now, and requeue the work */
 		queue_work(serv->sv_wq, &xprt->xpt_work);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 695bc989c007..4a71436efb1f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -108,6 +108,7 @@ struct svc_serv {
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	struct svc_serv_ops *	sv_ops;		/* server operations */
 	struct workqueue_struct	*sv_wq;		/* workqueue for wq-based services */
+	struct shrinker		sv_shrinker;	/* for shrinking svc_rqst caches */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -277,6 +278,7 @@ struct svc_rqst {
 #define	RQ_VICTIM	(5)			/* about to be shut down */
 #define	RQ_BUSY		(6)			/* request is busy */
 	unsigned long		rq_flags;	/* flags field */
+	unsigned long		rq_time;	/* when rqstp was last put */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
@@ -496,6 +498,15 @@ char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 
 int		   svc_wq_setup(struct svc_serv *, struct svc_pool *, int);
 void		   svc_wq_enqueue_xprt(struct svc_xprt *);
+struct svc_rqst	*  find_or_alloc_svc_rqst(struct svc_serv *serv);
+void		   exit_svc_rqst_cache(struct svc_serv *serv);
+
+static inline void
+put_svc_rqst(struct svc_rqst *rqstp)
+{
+	rqstp->rq_time = jiffies;
+	clear_bit(RQ_BUSY, &rqstp->rq_flags);
+}
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78395f790b54..32018951928e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -545,6 +545,7 @@ svc_destroy(struct svc_serv *serv)
 
 	if (serv->sv_wq) {
 		destroy_workqueue(serv->sv_wq);
+		exit_svc_rqst_cache(serv);
 		module_put(serv->sv_ops->svo_module);
 	}
 
diff --git a/net/sunrpc/svc_wq.c b/net/sunrpc/svc_wq.c
index d1778373249e..1ca26d51b8ec 100644
--- a/net/sunrpc/svc_wq.c
+++ b/net/sunrpc/svc_wq.c
@@ -11,6 +11,143 @@
 #include <linux/workqueue.h>
 #include <trace/events/sunrpc.h>
 
+static struct svc_rqst *
+find_svc_rqst(struct svc_serv *serv)
+{
+	int node = numa_node_id();
+	struct svc_rqst *rqstp;
+	struct svc_pool *pool = &serv->sv_pools[node];
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
+		if (!test_and_set_bit(RQ_BUSY, &rqstp->rq_flags)) {
+			rcu_read_unlock();
+			return rqstp;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
+
+/*
+ * Find a svc_rqst to use. Try to find an already allocated-one on the list
+ * first, and then allocate if there isn't one available.
+ */
+struct svc_rqst *
+find_or_alloc_svc_rqst(struct svc_serv *serv)
+{
+	int node = numa_node_id();
+	struct svc_rqst *rqstp;
+	struct svc_pool *pool = &serv->sv_pools[node];
+
+	rqstp = find_svc_rqst(serv);
+	if (likely(rqstp))
+		return rqstp;
+
+	rqstp = svc_rqst_alloc(serv, pool, node);
+	if (rqstp) {
+		spin_lock_bh(&pool->sp_lock);
+		list_add_tail_rcu(&rqstp->rq_all, &pool->sp_all_threads);
+		++pool->sp_nrthreads;
+		spin_unlock_bh(&pool->sp_lock);
+	}
+	return rqstp;
+}
+EXPORT_SYMBOL_GPL(find_or_alloc_svc_rqst);
+
+static unsigned long
+count_svc_rqst_objects(struct shrinker *shrinker, struct shrink_control *sc)
+{
+	struct svc_serv *serv = container_of(shrinker, struct svc_serv,
+						sv_shrinker);
+	struct svc_pool *pool = &serv->sv_pools[sc->nid];
+	struct svc_rqst *rqstp;
+	unsigned long count = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
+		/* Don't count it if it's busy */
+		if (test_bit(RQ_BUSY, &rqstp->rq_flags))
+			continue;
+
+		/* Don't count it if it was used within the last second */
+		if (time_before(jiffies, rqstp->rq_time + HZ))
+			continue;
+
+		++count;
+	}
+	rcu_read_unlock();
+
+	return count;
+}
+
+static unsigned long
+scan_svc_rqst_objects(struct shrinker *shrinker, struct shrink_control *sc)
+{
+	struct svc_serv *serv = container_of(shrinker, struct svc_serv,
+						sv_shrinker);
+	struct svc_pool *pool = &serv->sv_pools[sc->nid];
+	struct svc_rqst *rqstp;
+	unsigned long count = 0;
+
+	spin_lock(&pool->sp_lock);
+	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
+		/* Don't free it if it's busy */
+		if (test_and_set_bit(RQ_BUSY, &rqstp->rq_flags))
+			continue;
+
+		list_del_rcu(&rqstp->rq_all);
+		svc_rqst_free(rqstp);
+		--pool->sp_nrthreads;
+		++count;
+		if (sc->nr_to_scan-- == 0)
+			break;
+	}
+	spin_unlock(&pool->sp_lock);
+
+	return count;
+}
+
+static int
+init_svc_rqst_cache(struct svc_serv *serv)
+{
+	struct shrinker *shrinker = &serv->sv_shrinker;
+
+	memset(shrinker, 0, sizeof(*shrinker));
+
+	shrinker->count_objects = count_svc_rqst_objects;
+	shrinker->scan_objects = scan_svc_rqst_objects;
+	shrinker->seeks = DEFAULT_SEEKS;
+	shrinker->flags = SHRINKER_NUMA_AWARE;
+
+	return register_shrinker(shrinker);
+}
+
+void
+exit_svc_rqst_cache(struct svc_serv *serv)
+{
+	int node;
+
+	unregister_shrinker(&serv->sv_shrinker);
+
+	for (node = 0; node < serv->sv_nrpools; node++) {
+		struct svc_pool *pool = &serv->sv_pools[node];
+
+		spin_lock_bh(&pool->sp_lock);
+		while (!list_empty(&pool->sp_all_threads)) {
+			struct svc_rqst *rqstp = list_first_entry(
+					&pool->sp_all_threads, struct svc_rqst,
+					rq_all);
+
+			WARN_ON_ONCE(test_bit(RQ_BUSY, &rqstp->rq_flags));
+			list_del_rcu(&rqstp->rq_all);
+			svc_rqst_free(rqstp);
+		}
+		pool->sp_nrthreads = 0;
+		spin_unlock_bh(&pool->sp_lock);
+	}
+}
+
 /*
  * This workqueue job should run on each node when the workqueue is created. It
  * walks the list of xprts for its node, and queues the workqueue job for each.
@@ -58,8 +195,8 @@ process_queued_xprts(struct svc_serv *serv)
 
 /*
  * Start up or shut down a workqueue-based RPC service. Basically, we use this
- * to allocate the workqueue. The function assumes that the caller holds one
- * serv->sv_nrthreads reference.
+ * to allocate the workqueue and set up the shrinker for the svc_rqst cache.
+ * This function assumes that the caller holds one serv->sv_nrthreads reference.
  *
  * The "active" parm is treated as a boolean here. The only meaningful values
  * are non-zero which means that we're starting the service up, or zero which
@@ -68,6 +205,7 @@ process_queued_xprts(struct svc_serv *serv)
 int
 svc_wq_setup(struct svc_serv *serv, struct svc_pool *pool, int active)
 {
+	int err;
 	int nrthreads = serv->sv_nrthreads - 1; /* -1 for caller's reference */
 
 	WARN_ON_ONCE(nrthreads < 0);
@@ -85,14 +223,20 @@ svc_wq_setup(struct svc_serv *serv, struct svc_pool *pool, int active)
 	 * down the workqueue until the closing of the xprts is done.
 	 */
 	if (!nrthreads && active) {
+		err = init_svc_rqst_cache(serv);
+		if (err)
+			return err;
+
 		__module_get(serv->sv_ops->svo_module);
 		serv->sv_wq = alloc_workqueue("%s",
 					WQ_UNBOUND|WQ_FREEZABLE|WQ_SYSFS,
 					0, serv->sv_name);
 		if (!serv->sv_wq) {
+			exit_svc_rqst_cache(serv);
 			module_put(serv->sv_ops->svo_module);
 			return -ENOMEM;
 		}
+
 		process_queued_xprts(serv);
 	}
 
@@ -111,6 +255,7 @@ void
 svc_wq_enqueue_xprt(struct svc_xprt *xprt)
 {
 	struct svc_serv *serv = xprt->xpt_server;
+	struct svc_rqst *rqstp;
 
 	if (!svc_xprt_has_something_to_do(xprt))
 		return;
@@ -139,8 +284,15 @@ svc_wq_enqueue_xprt(struct svc_xprt *xprt)
 		spin_unlock_bh(&pool->sp_lock);
 		return;
 	}
+
 out:
 	svc_xprt_get(xprt);
-	queue_work(serv->sv_wq, &xprt->xpt_work);
+	rqstp = find_svc_rqst(serv);
+	if (!rqstp) {
+		queue_work(serv->sv_wq, &xprt->xpt_work);
+		return;
+	}
+	rqstp->rq_xprt = xprt;
+	queue_work(serv->sv_wq, &rqstp->rq_work);
 }
 EXPORT_SYMBOL_GPL(svc_wq_enqueue_xprt);
-- 
2.1.0

