From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 094/100] SUNRPC: spin svc_rqst initialization to its own function
Date: Fri, 25 Jan 2008 18:17:14 -0500
Message-ID: <1201303040-7779-94-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-88-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-89-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-90-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-91-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-92-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762062AbYAYXSh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:37 -0500
In-Reply-To: <1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

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
1.5.4.rc2.60.gb2e62

