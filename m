From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/6] SUNRPC: Break up __svc_create_thread and make svc_create_kthread
Date: Thu, 13 Dec 2007 15:40:24 -0500
Message-ID: <1197578428-26815-3-git-send-email-jlayton@redhat.com>
References: <1197578428-26815-1-git-send-email-jlayton@redhat.com>
 <1197578428-26815-2-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409AbXLMUka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 15:40:30 -0500
In-Reply-To: <1197578428-26815-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the initialization that happens prior to thread creation to a new
function (svc_prepare_thread) so that we can call it from a new thread
creation routine. Add a new function svc_create_kthread that spawns svc
threads using kthread API.

We should be able to eventually convert all of the callers to the
kthread API, at which point we can drop __svc_create_thread.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |    2 +
 net/sunrpc/sunrpc_syms.c   |    1 +
 net/sunrpc/svc.c           |   69 +++++++++++++++++++++++++++++++++++++++----
 3 files changed, 65 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8531a70..fd980af 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -383,6 +383,8 @@ struct svc_procedure {
 struct svc_serv *  svc_create(struct svc_program *, unsigned int,
 			      void (*shutdown)(struct svc_serv*));
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
+int		   svc_create_kthread(svc_thread_fn func,
+			struct svc_serv *serv, struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 			void (*shutdown)(struct svc_serv*),
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 33d89e8..7feb878 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -64,6 +64,7 @@ EXPORT_SYMBOL(put_rpccred);
 /* RPC server stuff */
 EXPORT_SYMBOL(svc_create);
 EXPORT_SYMBOL(svc_create_thread);
+EXPORT_SYMBOL(svc_create_kthread);
 EXPORT_SYMBOL(svc_create_pooled);
 EXPORT_SYMBOL(svc_set_num_threads);
 EXPORT_SYMBOL(svc_exit_thread);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 9696ae7..d9c26e3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/kthread.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -543,18 +544,15 @@ svc_release_buffer(struct svc_rqst *rqstp)
  * On a NUMA or SMP machine, with a multi-pool serv, the thread
  * will be restricted to run on the cpus belonging to the pool.
  */
-static int
-__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
-		    struct svc_pool *pool)
+static struct svc_rqst *
+svc_prepare_thread(svc_thread_fn func, struct svc_serv *serv,
+		   struct svc_pool *pool)
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
 
@@ -570,6 +568,30 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
+out:
+	return rqstp;
+
+out_thread:
+	svc_exit_thread(rqstp);
+out_enomem:
+	rqstp = ERR_PTR(-ENOMEM);
+	goto out;
+}
+
+static int
+__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
+		    struct svc_pool *pool)
+{
+	struct svc_rqst	*rqstp;
+	int		have_oldmask = 0;
+	cpumask_t	oldmask;
+	int		error;
+
+	rqstp = svc_prepare_thread(func, serv, pool);
+	if (IS_ERR(rqstp)) {
+		error = PTR_ERR(rqstp);
+		goto out;
+	}
 
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(current, pool->sp_id,
@@ -601,6 +623,39 @@ svc_create_thread(svc_thread_fn func, struct svc_serv *serv)
 	return __svc_create_thread(func, serv, &serv->sv_pools[0]);
 }
 
+int
+svc_create_kthread(svc_thread_fn func, struct svc_serv *serv,
+		       struct svc_pool *pool)
+{
+	struct svc_rqst	*rqstp;
+	struct task_struct *task;
+	int error = 0;
+	
+	rqstp = svc_prepare_thread(func, serv, pool);
+	if (IS_ERR(rqstp)) {
+		error = PTR_ERR(rqstp);
+		goto out;
+	}
+
+	task = kthread_create((int (*)(void *)) func, rqstp, serv->sv_name);
+	if (IS_ERR(task)) {
+		error = PTR_ERR(task);
+		goto out_thread;
+	}
+
+	if (serv->sv_nrpools > 1)
+		svc_pool_map_set_cpumask(task, pool->sp_id, NULL);
+
+	svc_sock_update_bufs(serv);
+	wake_up_process(task);
+out:
+	return error;
+
+out_thread:
+	svc_exit_thread(rqstp);
+	goto out;
+}
+
 /*
  * Choose a pool in which to create a new thread, for svc_set_num_threads
  */
-- 
1.5.3.3

