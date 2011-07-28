Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49925 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab1G1SEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 14:04:14 -0400
Subject: [PATCH] sunrpc: use better NUMA affinities
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        David Miller <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 20:04:09 +0200
Message-ID: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Use NUMA aware allocations to reduce latencies and increase throughput.

sunrpc kthreads can use kthread_create_on_node() if pool_mode is
"percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer() can
also take into account NUMA node affinity for memory allocations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>
CC: Neil Brown <neilb@suse.de>
CC: David Miller <davem@davemloft.net>
---
 fs/lockd/svc.c             |    2 +-
 fs/nfs/callback.c          |    2 +-
 include/linux/sunrpc/svc.h |    2 +-
 net/sunrpc/svc.c           |   33 ++++++++++++++++++++++++---------
 4 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..c061b9a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -282,7 +282,7 @@ int lockd_up(void)
 	/*
 	 * Create the kernel thread and wait for it to start.
 	 */
-	nlmsvc_rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	nlmsvc_rqst = svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
 	if (IS_ERR(nlmsvc_rqst)) {
 		error = PTR_ERR(nlmsvc_rqst);
 		nlmsvc_rqst = NULL;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..ce620b5 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -125,7 +125,7 @@ nfs4_callback_up(struct svc_serv *serv)
 	else
 		goto out_err;
 
-	return svc_prepare_thread(serv, &serv->sv_pools[0]);
+	return svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
 
 out_err:
 	if (ret == 0)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 223588a..a78a51e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -404,7 +404,7 @@ struct svc_procedure {
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
-					struct svc_pool *pool);
+					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 			void (*shutdown)(struct svc_serv *),
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..30d70ab 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -295,6 +295,18 @@ svc_pool_map_put(void)
 }
 
 
+static int svc_pool_map_get_node(unsigned int pidx)
+{
+	const struct svc_pool_map *m = &svc_pool_map;
+
+	if (m->count) {
+		if (m->mode == SVC_POOL_PERCPU)
+			return cpu_to_node(m->pool_to[pidx]);
+		if (m->mode == SVC_POOL_PERNODE)
+			return m->pool_to[pidx];
+	}
+	return NUMA_NO_NODE;
+}
 /*
  * Set the given thread's cpus_allowed mask so that it
  * will only run on cpus in the given pool.
@@ -499,7 +511,7 @@ EXPORT_SYMBOL_GPL(svc_destroy);
  * We allocate pages and place them in rq_argpages.
  */
 static int
-svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
+svc_init_buffer(struct svc_rqst *rqstp, unsigned int size, int node)
 {
 	unsigned int pages, arghi;
 
@@ -513,7 +525,7 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 	arghi = 0;
 	BUG_ON(pages > RPCSVC_MAXPAGES);
 	while (pages) {
-		struct page *p = alloc_page(GFP_KERNEL);
+		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0);
 		if (!p)
 			break;
 		rqstp->rq_pages[arghi++] = p;
@@ -536,11 +548,11 @@ svc_release_buffer(struct svc_rqst *rqstp)
 }
 
 struct svc_rqst *
-svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
+svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
 {
 	struct svc_rqst	*rqstp;
 
-	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
+	rqstp = kzalloc_node(sizeof(*rqstp), GFP_KERNEL, node);
 	if (!rqstp)
 		goto out_enomem;
 
@@ -554,15 +566,15 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
-	rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
+	rqstp->rq_argp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
 	if (!rqstp->rq_argp)
 		goto out_thread;
 
-	rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
+	rqstp->rq_resp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
 	if (!rqstp->rq_resp)
 		goto out_thread;
 
-	if (!svc_init_buffer(rqstp, serv->sv_max_mesg))
+	if (!svc_init_buffer(rqstp, serv->sv_max_mesg, node))
 		goto out_thread;
 
 	return rqstp;
@@ -647,6 +659,7 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 	struct svc_pool *chosen_pool;
 	int error = 0;
 	unsigned int state = serv->sv_nrthreads-1;
+	int node;
 
 	if (pool == NULL) {
 		/* The -1 assumes caller has done a svc_get() */
@@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 		nrservs--;
 		chosen_pool = choose_pool(serv, pool, &state);
 
-		rqstp = svc_prepare_thread(serv, chosen_pool);
+		node = svc_pool_map_get_node(chosen_pool->sp_id);
+		rqstp = svc_prepare_thread(serv, chosen_pool, node);
 		if (IS_ERR(rqstp)) {
 			error = PTR_ERR(rqstp);
 			break;
 		}
 
 		__module_get(serv->sv_module);
-		task = kthread_create(serv->sv_function, rqstp, serv->sv_name);
+		task = kthread_create_on_node(serv->sv_function, rqstp,
+					      node, serv->sv_name);
 		if (IS_ERR(task)) {
 			error = PTR_ERR(task);
 			module_put(serv->sv_module);


