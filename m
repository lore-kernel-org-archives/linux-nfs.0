From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/7] SUNRPC: make new svc_create_kthread function
Date: Tue, 18 Dec 2007 11:42:35 -0500
Message-ID: <1197996159-20799-4-git-send-email-jlayton@redhat.com>
References: <1197996159-20799-1-git-send-email-jlayton@redhat.com>
 <1197996159-20799-2-git-send-email-jlayton@redhat.com>
 <1197996159-20799-3-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758304AbXLRQxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 11:53:12 -0500
In-Reply-To: <1197996159-20799-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new function svc_create_kthread that spawns svc threads using the
kthread API.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/sunrpc_syms.c   |    1 +
 net/sunrpc/svc.c           |   19 +++++++++++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 19483fe..5296b52 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -385,6 +385,8 @@ struct svc_serv *  svc_create(struct svc_program *, unsigned int,
 struct svc_rqst *  svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
+int		   svc_create_kthread(svc_thread_fn func,
+					struct svc_rqst *rqstp);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 			void (*shutdown)(struct svc_serv*),
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 27bb185..757e730 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -65,6 +65,7 @@ EXPORT_SYMBOL(put_rpccred);
 EXPORT_SYMBOL(svc_create);
 EXPORT_SYMBOL(svc_prepare_thread);
 EXPORT_SYMBOL(svc_create_thread);
+EXPORT_SYMBOL(svc_create_kthread);
 EXPORT_SYMBOL(svc_create_pooled);
 EXPORT_SYMBOL(svc_set_num_threads);
 EXPORT_SYMBOL(svc_exit_thread);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 854e8ec..0c8c327 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/kthread.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -619,6 +620,24 @@ svc_create_thread(svc_thread_fn func, struct svc_serv *serv)
 	return __svc_create_thread(func, serv, &serv->sv_pools[0]);
 }
 
+int
+svc_create_kthread(svc_thread_fn func, struct svc_rqst *rqstp)
+{
+	struct svc_serv *serv = rqstp->rq_server;
+	struct task_struct *task;
+
+	task = kthread_create((int (*)(void *)) func, rqstp, serv->sv_name);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	if (serv->sv_nrpools > 1)
+		svc_pool_map_set_cpumask(task, rqstp->rq_pool->sp_id, NULL);
+
+	svc_sock_update_bufs(serv);
+	wake_up_process(task);
+	return 0;
+}
+
 /*
  * Choose a pool in which to create a new thread, for svc_set_num_threads
  */
-- 
1.5.3.3

