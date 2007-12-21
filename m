From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/6] SUNRPC: spin svc_rqst initialization to its own function
Date: Fri, 21 Dec 2007 10:28:05 -0500
Message-ID: <1198250890-25571-2-git-send-email-jlayton@redhat.com>
References: <1198250890-25571-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018AbXLUP2V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2007 10:28:21 -0500
In-Reply-To: <1198250890-25571-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the initialzation in __svc_create_thread that happens prior to
thread creation to a new function. Export the function to allow
services to have better control over the svc_rqst structs.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svc.c           |   43 +++++++++++++++++++++++++++++++------------
 2 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8531a70..5f07300 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -382,6 +382,8 @@ struct svc_procedure {
  */
 struct svc_serv *  svc_create(struct svc_program *, unsigned int,
 			      void (*shutdown)(struct svc_serv*));
+struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
+					struct svc_pool *pool);
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a4a6bf7..cde480e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -535,23 +535,14 @@ svc_release_buffer(struct svc_rqst *rqstp)
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
 
@@ -567,6 +558,34 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
+	return rqstp;
+
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
 
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
-- 
1.5.3.6

