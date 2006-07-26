From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 010 of 11] knfsd: make pools numa aware (ifdefless)
Date: Wed, 26 Jul 2006 21:30:57 +1000
Message-ID: <1153913457.21040.854.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5iTS-0004kO-9z
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 05:26:50 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5iTQ-00026G-9A
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 05:26:50 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1G5hbd-0003qm-Eq
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 04:31:14 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

G'day,

Here's a respin of this patch, incorporating Neil's fixes,
and implementing Neil's and Trond's review feedback.  Changed:

- removed ifdefs entirely
- removed printk()s from svc_pool_map_init()
- collapsed {node,cpu}_to_pool[] arrays into new to_pool[]
- ditto pool_to_{node,cpu}

--

knfsd: Actually implement multiple pools.  On NUMA machines, allocate
a svc_pool per NUMA node; on SMP a svc_pool per CPU; otherwise a single
global pool.  Enqueue sockets on the svc_pool corresponding to the CPU
on which the socket bh is run (i.e. the NIC interrupt CPU).  Threads
have their cpu mask set to limit them to the CPUs in the svc_pool that
owns them.

This is the patch that allows an Altix to scale NFS traffic linearly
beyond 4 CPUs and 4 NICs.

Incorporates changes and feedback from Neil Brown, Trond Myklebust.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc.h |   44 ++++++++++
 net/sunrpc/svc.c           |  148 +++++++++++++++++++++++++++++++++-
 net/sunrpc/svcsock.c       |    7 +
 3 files changed, 197 insertions(+), 2 deletions(-)

Index: linus-git/net/sunrpc/svc.c
===================================================================
--- linus-git.orig/net/sunrpc/svc.c	2006-07-26 16:50:25.802187916 +1000
+++ linus-git/net/sunrpc/svc.c	2006-07-26 19:08:36.758804122 +1000
@@ -4,6 +4,10 @@
  * High-level RPC service routines
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ *
+ * Multiple threads pools and NUMAisation
+ * Copyright (c) 2006 Silicon Graphics, Inc.
+ * by Greg Banks <gnb@melbourne.sgi.com>
  */
 
 #include <linux/linkage.h>
@@ -24,6 +28,135 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 #define RPC_PARANOIA 1
 
+struct svc_pool_map svc_pool_map = { .mode = -1, .init = 0 };
+
+/*
+ * Build the global map of cpus to pools and vice versa.
+ */
+static unsigned int
+svc_pool_map_init(void)
+{
+	struct svc_pool_map *m = &svc_pool_map;
+	unsigned int node;
+	unsigned int cpu;
+	unsigned int pidx = 0;
+	unsigned int maxpools;
+
+	if (m->init)
+		return m->npools;
+	m->init = 1;
+
+	if (m->mode < 0) {
+		/*
+		 * Detect best pool mapping mode heuristically.
+		 */
+		m->mode = 0;	/* default: one global pool */
+		if (num_online_nodes() > 1) {
+			/*
+			 * Actually have multiple NUMA nodes,
+			 * so split pools on NUMA node boundaries
+			 */
+			m->mode = 2;
+		} else {
+			node = any_online_node(node_online_map);
+			if (nr_cpus_node(node) > 2) {
+				/*
+				 * Non-trivial SMP, or CONFIG_NUMA on
+				 * non-NUMA hardware, e.g. with a generic
+				 * x86_64 kernel on Xeons.  In this case we
+				 * want to divide the pools on cpu boundaries.
+				 */
+				m->mode = 1;
+			}
+		}
+	}
+
+	switch (m->mode) {
+	case 0:
+fallback:
+		m->mode = 0;
+		m->npools = 1;
+		break;
+
+	case 1:
+		maxpools = num_possible_cpus();
+		m->to_pool = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
+		if (!m->to_pool)
+			goto fallback;
+		m->pool_to = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
+		if (!m->pool_to) {
+			kfree(m->to_pool);
+			goto fallback;
+		}
+		for_each_online_cpu(cpu) {
+			BUG_ON(pidx > maxpools);
+			m->to_pool[cpu] = pidx;
+			m->pool_to[pidx] = cpu;
+			pidx++;
+		}
+		/* cpus brought online later all get mapped to pool0, sorry */
+		m->npools = pidx;
+
+		break;
+
+	case 2:
+		maxpools = num_possible_nodes();
+		m->to_pool = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
+		if (!m->to_pool)
+			goto fallback;
+		m->pool_to = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
+		if (!m->pool_to) {
+			kfree(m->to_pool);
+			goto fallback;
+		}
+		for_each_node_with_cpus(node) {
+			/* some architectures (e.g. SN2) have cpuless nodes */
+			BUG_ON(pidx > maxpools);
+			m->to_pool[node] = pidx;
+			m->pool_to[pidx] = node;
+			pidx++;
+		}
+		/* nodes brought online later all get mapped to pool0, sorry */
+		m->npools = pidx;
+
+		break;
+	}
+
+	return m->npools;
+}
+
+/*
+ * Set the current thread's cpus_allowed mask so that it
+ * will only run on cpus in the given pool.
+ *
+ * Returns 1 and fills in oldmask iff a cpumask was applied.
+ */
+static inline int
+svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
+{
+	struct svc_pool_map *map = &svc_pool_map;
+	unsigned int node; /* or cpu */
+
+	BUG_ON(!m->init);
+
+	switch (m->mode)
+	{
+	default:
+	case 0:
+		return 0;
+	case 1:
+		node = m->pool_to[pidx];
+		*oldmask = current->cpus_allowed;
+		set_cpus_allowed(current, cpumask_of_cpu(node));
+		return 1;
+	case 2:
+		node = map->pool_to[pidx];
+		*oldmask = current->cpus_allowed;
+		set_cpus_allowed(current, node_to_cpumask(node));
+		return 1;
+	}
+}
+
 /*
  * Create an RPC service
  */
@@ -103,8 +236,9 @@ svc_create_pooled(struct svc_program *pr
 		  svc_thread_fn func, int sig, struct module *mod)
 {
 	struct svc_serv *serv;
+	unsigned int npools = svc_pool_map_init();
 
-	serv = __svc_create(prog, bufsize, shutdown, /*npools*/1);
+	serv = __svc_create(prog, bufsize, shutdown, npools);
 
 	if (serv != NULL) {
 		serv->sv_function = func;
@@ -207,12 +341,16 @@ svc_release_buffer(struct svc_rqst *rqst
 
 /*
  * Create a thread in the given pool.  Caller must hold BKL.
+ * On a NUMA or SMP machine, with a multi-pool serv, the thread
+ * will be restricted to run on the cpus belonging to the pool.
  */
 static int
 __svc_create_thread(svc_thread_fn func, struct svc_serv *serv, struct svc_pool *pool)
 {
 	struct svc_rqst	*rqstp;
 	int		error = -ENOMEM;
+	int		have_oldmask = 0;
+	cpumask_t	oldmask;
 
 	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
 	if (!rqstp)
@@ -232,7 +370,15 @@ __svc_create_thread(svc_thread_fn func, 
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
+
+	if (serv->sv_nrpools > 1)
+		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
+
 	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
+
+	if (have_oldmask)
+		set_cpus_allowed(current, oldmask);
+
 	if (error < 0)
 		goto out_thread;
 	svc_sock_update_bufs(serv);
Index: linus-git/net/sunrpc/svcsock.c
===================================================================
--- linus-git.orig/net/sunrpc/svcsock.c	2006-07-26 16:47:46.018822248 +1000
+++ linus-git/net/sunrpc/svcsock.c	2006-07-26 17:08:01.853054036 +1000
@@ -151,8 +151,9 @@ static void
 svc_sock_enqueue(struct svc_sock *svsk)
 {
 	struct svc_serv	*serv = svsk->sk_server;
-	struct svc_pool *pool = &serv->sv_pools[0];
+	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
+	int cpu;
 
 	if (!(svsk->sk_flags &
 	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
@@ -160,6 +161,10 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		return;
 
+	cpu = get_cpu();
+	pool = svc_pool_for_cpu(svsk->sk_server, cpu);
+	put_cpu();
+
 	spin_lock_bh(&pool->sp_lock);
 
 	if (!list_empty(&pool->sp_threads) &&
Index: linus-git/include/linux/sunrpc/svc.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svc.h	2006-07-26 16:49:47.615119695 +1000
+++ linus-git/include/linux/sunrpc/svc.h	2006-07-26 17:13:17.804142019 +1000
@@ -42,6 +42,27 @@ struct svc_pool {
 } ____cacheline_aligned_in_smp;
 
 /*
+ * Global structure for mapping cpus to pools and vice versa.
+ * Setup once during sunrpc initialisation.
+ */
+struct svc_pool_map {
+	/*
+	 * Mode for mapping cpus to pools.
+	 *
+	 * -1 = automatic, choose one of the other modes at boot
+	 * 0 = no mapping, just a single global pool (legacy & UP mode)
+	 * 1 = one pool per cpu
+	 * 2 = one pool per numa node
+	 */
+	int mode;
+	int init;
+	unsigned int npools;
+	unsigned int *pool_to;		/* maps pool id to cpu or node */
+	unsigned int *to_pool;		/* maps cpu or node to pool id */
+};
+
+
+/*
  * RPC service.
  *
  * An RPC service is a ``daemon,'' possibly multithreaded, which
@@ -368,5 +389,28 @@ int		   svc_process(struct svc_serv *, s
 int		   svc_register(struct svc_serv *, int, unsigned short);
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
+extern struct svc_pool_map svc_pool_map;
+
+
+static inline struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv, int cpu)
+{
+	struct svc_pool_map *m = &svc_pool_map;
+	unsigned int pidx;
+
+	switch (m->mode) {
+	default:
+	case 0:
+		pidx = 0;
+		break;
+	case 1:
+		pidx = m->to_pool[cpu];
+		break;
+	case 2:
+		pidx = m->to_pool[cpu_to_node(cpu)];
+		break;
+	}
+	return &serv->sv_pools[pidx % serv->sv_nrpools];
+}
+
 
 #endif /* SUNRPC_SVC_H */




Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
