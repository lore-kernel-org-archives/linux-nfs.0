From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] sunrpc: have pooled services make NUMA-friendly
	allocations
Date: Tue, 03 Jun 2008 07:18:02 -0400
Message-ID: <20080603111802.8769.22921.stgit@dantu.usersys.redhat.com>
References: <20080603111757.8769.69366.stgit@dantu.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46221 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803AbYFCLSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2008 07:18:04 -0400
In-Reply-To: <20080603111757.8769.69366.stgit-LRazzElzaNIFmhoHi+V13ACJwEvxM/w9@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, svc_prepare_thread allocates memory using plain kmalloc()
and alloc_page() calls, even for threads that are destined to run on
different CPUs or NUMA nodes than the current one. Add a function to
translate a poolid into a NUMA node, and have svc_prepare_thread and
svc_init_buffer allocate memory on those nodes instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 net/sunrpc/svc.c |   43 +++++++++++++++++++++++++++++++++++++------
 1 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 01c7e31..a61e7aa 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -332,6 +332,31 @@ svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
 }
 
 /*
+ * for a given poolid, return the closest NUMA node to its threads
+ */
+static unsigned int
+svc_pool_to_node(unsigned int pidx)
+{
+	struct svc_pool_map *m = &svc_pool_map;
+	unsigned int poolnode = m->pool_to[pidx];
+
+	/*
+	 * The caller checks for sv_nrpools > 1, which
+	 * implies that we've been initialized.
+	 */
+	BUG_ON(m->count == 0);
+
+	switch (m->mode) {
+	case SVC_POOL_PERNODE:
+		return poolnode;
+	case SVC_POOL_PERCPU:
+		return cpu_to_node(poolnode);
+	}
+
+	return numa_node_id();
+}
+
+/*
  * Use the mapping mode to choose a pool for a given CPU.
  * Used when enqueueing an incoming RPC.  Always returns
  * a non-NULL pool pointer.
@@ -507,7 +532,7 @@ EXPORT_SYMBOL(svc_destroy);
  * We allocate pages and place them in rq_argpages.
  */
 static int
-svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
+svc_init_buffer(struct svc_rqst *rqstp, unsigned int size, unsigned int node)
 {
 	unsigned int pages, arghi;
 
@@ -517,7 +542,7 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 	arghi = 0;
 	BUG_ON(pages > RPCSVC_MAXPAGES);
 	while (pages) {
-		struct page *p = alloc_page(GFP_KERNEL);
+		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0);
 		if (!p)
 			break;
 		rqstp->rq_pages[arghi++] = p;
@@ -543,8 +568,14 @@ struct svc_rqst *
 svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
 {
 	struct svc_rqst	*rqstp;
+	unsigned int	node;
+
+	if (serv->sv_nrpools > 1)
+		node = svc_pool_to_node(pool->sp_id);
+	else
+		node = numa_node_id();
 
-	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
+	rqstp = kzalloc_node(sizeof(*rqstp), GFP_KERNEL, node);
 	if (!rqstp)
 		goto out_enomem;
 
@@ -558,15 +589,15 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
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

