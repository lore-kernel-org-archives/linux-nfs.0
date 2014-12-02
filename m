Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:47971 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbaLBSYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:43 -0500
Received: by mail-qg0-f49.google.com with SMTP id a108so9545885qge.8
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:42 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 09/14] sunrpc: add basic support for workqueue-based services
Date: Tue,  2 Dec 2014 13:24:18 -0500
Message-Id: <1417544663-13299-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new "workqueue" pool mode setting. When that is configured, we'll
set up a svc_pool for each NUMA node, but don't bother with the
pool <=> cpu mapping arrays.

We use an unbound workqueue, which should naturally make each xprt be
queued to a CPU within the current NUMA node.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h      |  10 ++-
 include/linux/sunrpc/svc_xprt.h |   1 +
 include/linux/sunrpc/svcsock.h  |   1 +
 net/sunrpc/Kconfig              |  10 +++
 net/sunrpc/Makefile             |   1 +
 net/sunrpc/svc.c                |  15 ++++
 net/sunrpc/svc_wq.c             | 148 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svc_xprt.c           |  49 ++++++++++++-
 8 files changed, 233 insertions(+), 2 deletions(-)
 create mode 100644 net/sunrpc/svc_wq.c

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8bd53f723485..81e723220346 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -47,6 +47,7 @@ struct svc_pool {
 #define	SP_TASK_PENDING		(0)		/* still work to do even if no
 						 * xprt is queued. */
 	unsigned long		sp_flags;
+	struct work_struct	sp_work;	/* per-pool work struct */
 } ____cacheline_aligned_in_smp;
 
 struct svc_serv;
@@ -103,6 +104,7 @@ struct svc_serv {
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	struct svc_serv_ops *	sv_ops;		/* server operations */
+	struct workqueue_struct	*sv_wq;		/* workqueue for wq-based services */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -438,7 +440,8 @@ enum {
 	SVC_POOL_GLOBAL,	/* no mapping, just a single global pool
 				 * (legacy & UP mode) */
 	SVC_POOL_PERCPU,	/* one pool per cpu */
-	SVC_POOL_PERNODE	/* one pool per numa node */
+	SVC_POOL_PERNODE,	/* one pool per numa node */
+	SVC_POOL_WORKQUEUE,	/* workqueue-based service */
 };
 
 struct svc_pool_map {
@@ -486,6 +489,11 @@ void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 
+#if IS_ENABLED(CONFIG_SUNRPC_SVC_WORKQUEUE)
+int		   svc_wq_setup(struct svc_serv *, struct svc_pool *, int);
+void		   svc_wq_enqueue_xprt(struct svc_xprt *);
+#endif
+
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
 /*
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 096937871cda..ce7fd68a905e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -117,6 +117,7 @@ void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, const char *, struct net *,
 			const int, const unsigned short, int);
+bool	svc_xprt_has_something_to_do(struct svc_xprt *xprt);
 void	svc_xprt_do_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 2e780134f449..3ce0a640605d 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -53,6 +53,7 @@ static inline u32 svc_sock_final_rec(struct svc_sock *svsk)
  */
 void		svc_close_net(struct svc_serv *, struct net *);
 int		svc_recv(struct svc_rqst *, long);
+int		svc_wq_recv(struct svc_rqst *);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index fb78117b896c..08e01949bdc5 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -71,3 +71,13 @@ config SUNRPC_XPRT_RDMA_SERVER
 	  choose M here: the module will be called svcrdma.
 
 	  If unsure, say N.
+
+config SUNRPC_SVC_WORKQUEUE
+	bool "Support for workqueue-based SUNRPC services"
+	depends on SUNRPC
+	default	n
+	help
+	  Traditional SUNRPC services have required a dedicated thread
+	  to handle incoming requests. This option enables support for
+	  queueing incoming reqests to a workqueue instead, eliminating
+	  the need for a dedicated thread pool.
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 15e6f6c23c5d..401341123fdd 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -18,3 +18,4 @@ sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
 sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+sunrpc-$(CONFIG_SUNRPC_SVC_WORKQUEUE) += svc_wq.o
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 135ffbe9d983..7c8e33923210 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -71,6 +71,10 @@ param_set_pool_mode(const char *val, struct kernel_param *kp)
 		*ip = SVC_POOL_PERCPU;
 	else if (!strncmp(val, "pernode", 7))
 		*ip = SVC_POOL_PERNODE;
+#if IS_ENABLED(CONFIG_SUNRPC_SVC_WORKQUEUE)
+	else if (!strncmp(val, "workqueue", 9))
+		*ip = SVC_POOL_WORKQUEUE;
+#endif
 	else
 		err = -EINVAL;
 
@@ -94,6 +98,8 @@ param_get_pool_mode(char *buf, struct kernel_param *kp)
 		return strlcpy(buf, "percpu", 20);
 	case SVC_POOL_PERNODE:
 		return strlcpy(buf, "pernode", 20);
+	case SVC_POOL_WORKQUEUE:
+		return strlcpy(buf, "workqueue", 20);
 	default:
 		return sprintf(buf, "%d", *ip);
 	}
@@ -242,6 +248,10 @@ svc_pool_map_get(void)
 	case SVC_POOL_PERNODE:
 		npools = svc_pool_map_init_pernode(m);
 		break;
+	case SVC_POOL_WORKQUEUE:
+		/* workqueues get a pool per numa node, but don't need a map */
+		npools = nr_node_ids;
+		break;
 	}
 
 	if (npools < 0) {
@@ -534,6 +544,11 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
+	if (serv->sv_wq) {
+		destroy_workqueue(serv->sv_wq);
+		module_put(serv->sv_ops->svo_module);
+	}
+
 	kfree(serv->sv_pools);
 	kfree(serv);
 }
diff --git a/net/sunrpc/svc_wq.c b/net/sunrpc/svc_wq.c
new file mode 100644
index 000000000000..d4720ecd0b32
--- /dev/null
+++ b/net/sunrpc/svc_wq.c
@@ -0,0 +1,148 @@
+/*
+ * svc_wq - support for workqueue-based rpc svcs
+ */
+
+#include <linux/sched.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/svc_xprt.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+#include <trace/events/sunrpc.h>
+
+/*
+ * This workqueue job should run on each node when the workqueue is created. It
+ * walks the list of xprts for its node, and queues the workqueue job for each.
+ */
+static void
+process_queued_xprt_work(struct work_struct *work)
+{
+	struct svc_pool *pool = container_of(work, struct svc_pool, sp_work);
+
+	spin_lock_bh(&pool->sp_lock);
+	while (!list_empty(&pool->sp_sockets)) {
+		struct svc_xprt *xprt = list_first_entry(&pool->sp_sockets,
+						 struct svc_xprt, xpt_ready);
+
+		list_del_init(&xprt->xpt_ready);
+		svc_xprt_get(xprt);
+		queue_work(xprt->xpt_server->sv_wq, &xprt->xpt_work);
+	}
+	spin_unlock_bh(&pool->sp_lock);
+}
+
+/*
+ * If any svc_xprts are enqueued before the workqueue is available, they get
+ * added to the pool->sp_sockets list. When the workqueue becomes available,
+ * we must walk the list  for each pool and queue each xprt to the workqueue.
+ *
+ * In order to minimize inter-node communication, we queue a separate job for
+ * each node to walk its own list. We queue this job to any cpu in the node.
+ * Since the workqueues are unbound they'll end up queued to the pool_workqueue
+ * for their corresponding node, and not necessarily to the given CPU.
+ */
+static void
+process_queued_xprts(struct svc_serv *serv)
+{
+	int node;
+
+	for (node = 0; node < serv->sv_nrpools; ++node) {
+		int cpu = any_online_cpu(*cpumask_of_node(node));
+		struct svc_pool *pool = &serv->sv_pools[node];
+
+		INIT_WORK(&pool->sp_work, process_queued_xprt_work);
+		queue_work_on(cpu, serv->sv_wq, &pool->sp_work);
+	}
+}
+
+/*
+ * Start up or shut down a workqueue-based RPC service. Basically, we use this
+ * to allocate the workqueue. The function assumes that the caller holds one
+ * serv->sv_nrthreads reference.
+ */
+int
+svc_wq_setup(struct svc_serv *serv, struct svc_pool *pool, int max_active)
+{
+	int nrthreads = serv->sv_nrthreads - 1; /* -1 for caller's reference */
+
+	WARN_ON_ONCE(nrthreads < 0);
+
+	/*
+	 * We don't allow tuning max_active on a per-node basis. If we got here
+	 * via the pool_threads interface, then just return an error.
+	 */
+	if (pool)
+		return -EINVAL;
+
+	if (!nrthreads) {
+		/* svc is down and none requested? */
+		if (!max_active)
+			return 0;
+		__module_get(serv->sv_ops->svo_module);
+		serv->sv_wq = alloc_workqueue("%s",
+					WQ_UNBOUND|WQ_FREEZABLE|WQ_SYSFS,
+					max_active, serv->sv_name);
+		if (!serv->sv_wq) {
+			module_put(serv->sv_ops->svo_module);
+			return -ENOMEM;
+		}
+		process_queued_xprts(serv);
+	} else {
+		/*
+		 * If max_active is 0, then that means we're taking the service
+		 * down. Don't destroy the workqueue just yet, as we need it
+		 * to process the closing of the xprts.
+		 */
+		if (max_active)
+			workqueue_set_max_active(serv->sv_wq, max_active);
+	}
+
+	/* +1 for caller's reference */
+	serv->sv_nrthreads = max_active + 1;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(svc_wq_setup);
+
+/*
+ * A svc_xprt needs to be serviced. Queue its workqueue job and return. In the
+ * event that the workqueue isn't available yet, add it to the sp_sockets list
+ * so that it can be processed when it does become available.
+ */
+void
+svc_wq_enqueue_xprt(struct svc_xprt *xprt)
+{
+	struct svc_serv *serv = xprt->xpt_server;
+
+	if (!svc_xprt_has_something_to_do(xprt))
+		return;
+
+	/* Don't enqueue transport while already enqueued */
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
+		return;
+
+	/* No workqueue yet? Queue the socket until there is one. */
+	if (!serv->sv_wq) {
+		struct svc_pool *pool = &serv->sv_pools[numa_node_id()];
+
+		spin_lock_bh(&pool->sp_lock);
+
+		/*
+		 * It's possible for the workqueue to be started up between
+		 * when we checked for it before but before we took the lock.
+		 * Check again while holding lock to avoid that potential race.
+		 */
+		if (serv->sv_wq) {
+			spin_unlock_bh(&pool->sp_lock);
+			goto out;
+		}
+
+		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
+		spin_unlock_bh(&pool->sp_lock);
+		return;
+	}
+out:
+	svc_xprt_get(xprt);
+	queue_work(serv->sv_wq, &xprt->xpt_work);
+}
+EXPORT_SYMBOL_GPL(svc_wq_enqueue_xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 63b42a8578c0..30f9fdfbff0c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -313,7 +313,7 @@ char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
 }
 EXPORT_SYMBOL_GPL(svc_print_addr);
 
-static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
+bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
@@ -850,6 +850,53 @@ out:
 }
 EXPORT_SYMBOL_GPL(svc_recv);
 
+#if IS_ENABLED(CONFIG_SUNRPC_SVC_WORKQUEUE)
+/*
+ * Perform a receive off the rqstp->rq_xprt socket.
+ *
+ * This function is a bit different from the standard svc_recv function as it
+ * assumes that the xprt is already provided in rqstp->rq_xprt, and so it
+ * does not sleep when there is no more work to be done.
+ */
+int
+svc_wq_recv(struct svc_rqst *rqstp)
+{
+	int len, err;
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+	struct svc_serv *serv = xprt->xpt_server;
+
+	err = svc_alloc_arg(rqstp);
+	if (err)
+		goto out;
+
+	len = svc_handle_xprt(rqstp, xprt);
+	if (len <= 0) {
+		err = -EAGAIN;
+		goto out_release;
+	}
+
+	clear_bit(XPT_OLD, &xprt->xpt_flags);
+
+	if (xprt->xpt_ops->xpo_secure_port(rqstp))
+		set_bit(RQ_SECURE, &rqstp->rq_flags);
+	else
+		clear_bit(RQ_SECURE, &rqstp->rq_flags);
+	rqstp->rq_chandle.defer = svc_defer;
+	rqstp->rq_xid = svc_getu32(&rqstp->rq_arg.head[0]);
+
+	if (serv->sv_stats)
+		serv->sv_stats->netcnt++;
+	trace_svc_recv(rqstp, len);
+	return len;
+out_release:
+	rqstp->rq_res.len = 0;
+	svc_xprt_release(rqstp);
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(svc_wq_recv);
+#endif
+
 /*
  * Drop request
  */
-- 
2.1.0

