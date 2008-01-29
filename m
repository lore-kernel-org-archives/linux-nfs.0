From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] SUNRPC: spin svc_rqst initialization to its own function
Date: Tue, 29 Jan 2008 10:30:54 -0500
Message-ID: <1201620655-7595-2-git-send-email-jlayton@redhat.com>
References: <1201620655-7595-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335AbYA2Pa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 10:30:58 -0500
In-Reply-To: <1201620655-7595-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the initialzation in __svc_create_thread that happens prior to
thread creation to a new function. Export the function to allow
services to have better control over the svc_rqst structs.

Also rearrange the rqstp initialization to prevent NULL pointer
dereferences in svc_exit_thread in case allocations fail.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc.h |    2 +
 net/sunrpc/svc.c           |   59 +++++++++++++++++++++++++++++++------------
 2 files changed, 44 insertions(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 742ab46..64c7710 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -384,6 +384,8 @@ struct svc_procedure {
  */
 struct svc_serv *  svc_create(struct svc_program *, unsigned int,
 			      void (*shutdown)(struct svc_serv*));
+struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
+					struct svc_pool *pool);
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index be18734..fec82f8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -530,31 +530,17 @@ svc_release_buffer(struct svc_rqst *rqstp)
 			put_page(rqstp->rq_pages[i]);
 }
 
-/*
- * Create a thread in the given pool.  Caller must hold BKL.
- * On a NUMA or SMP machine, with a multi-pool serv, the thread
- * will be restricted to run on the cpus belonging to the pool.
- */
-static int
-__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
-		    struct svc_pool *pool)
+struct svc_rqst *
+svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
 {
 	struct svc_rqst	*rqstp;
-	int		error = -ENOMEM;
-	int		have_oldmask = 0;
-	cpumask_t	oldmask;
 
 	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
 	if (!rqstp)
-		goto out;
+		goto out_enomem;
 
 	init_waitqueue_head(&rqstp->rq_wait);
 
-	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !svc_init_buffer(rqstp, serv->sv_max_mesg))
-		goto out_thread;
-
 	serv->sv_nrthreads++;
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads++;
@@ -563,6 +549,45 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
+	rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
+	if (!rqstp->rq_argp)
+		goto out_thread;
+
+	rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
+	if (!rqstp->rq_resp)
+		goto out_thread;
+
+	if (!svc_init_buffer(rqstp, serv->sv_max_mesg))
+		goto out_thread;
+
+	return rqstp;
+out_thread:
+	svc_exit_thread(rqstp);
+out_enomem:
+	return ERR_PTR(-ENOMEM);
+}
+EXPORT_SYMBOL(svc_prepare_thread);
+
+/*
+ * Create a thread in the given pool.  Caller must hold BKL.
+ * On a NUMA or SMP machine, with a multi-pool serv, the thread
+ * will be restricted to run on the cpus belonging to the pool.
+ */
+static int
+__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
+		    struct svc_pool *pool)
+{
+	struct svc_rqst	*rqstp;
+	int		error = -ENOMEM;
+	int		have_oldmask = 0;
+	cpumask_t	oldmask;
+
+	rqstp = svc_prepare_thread(serv, pool);
+	if (IS_ERR(rqstp)) {
+		error = PTR_ERR(rqstp);
+		goto out;
+	}
+
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
 
-- 
1.5.3.8

