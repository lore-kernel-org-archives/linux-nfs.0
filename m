Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:54580 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932819AbaLJTIL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:11 -0500
Received: by mail-qg0-f51.google.com with SMTP id e89so2562228qgf.24
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:11 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 02/16] sunrpc: move sv_function into sv_ops
Date: Wed, 10 Dec 2014 14:07:46 -0500
Message-Id: <1418238480-18857-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we now have a container for holding svc_serv operations, move the
sv_function into it as well.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfssvc.c           |  3 ++-
 include/linux/sunrpc/svc.h | 11 +++--------
 net/sunrpc/svc.c           |  8 +++-----
 3 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cc5dd1227732..5017af3fe882 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -392,6 +392,7 @@ static int nfsd_get_default_max_blksize(void)
 
 static struct svc_serv_ops nfsd_sv_ops = {
 	.svo_shutdown = nfsd_last_thread,
+	.svo_function = nfsd,
 };
 
 int nfsd_create_serv(struct net *net)
@@ -408,7 +409,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      &nfsd_sv_ops, nfsd, THIS_MODULE);
+				      &nfsd_sv_ops, THIS_MODULE);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 35faea625d9f..7e27894bc065 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -19,11 +19,6 @@
 #include <linux/wait.h>
 #include <linux/mm.h>
 
-/*
- * This is the RPC server thread function prototype
- */
-typedef int		(*svc_thread_fn)(void *);
-
 /* statistics for svc_pool structures */
 struct svc_pool_stats {
 	atomic_long_t	packets;
@@ -58,7 +53,8 @@ struct svc_serv;
 
 struct svc_serv_ops {
 	/* Callback to use when last thread exits. */
-	void	(*svo_shutdown)(struct svc_serv *serv, struct net *net);
+	void		(*svo_shutdown)(struct svc_serv *, struct net *);
+	int		(*svo_function)(void *);
 };
 
 /*
@@ -95,7 +91,6 @@ struct svc_serv {
 	struct svc_serv_ops *	sv_ops;		/* server operations */
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
-	svc_thread_fn		sv_function;	/* main function for threads */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -435,7 +430,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			struct svc_serv_ops *, svc_thread_fn, struct module *);
+			struct svc_serv_ops *, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
 void		   svc_destroy(struct svc_serv *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 057185e11261..897c755c6186 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -34,7 +34,7 @@
 
 static void svc_unregister(const struct svc_serv *serv, struct net *net);
 
-#define svc_serv_is_pooled(serv)    ((serv)->sv_function)
+#define svc_serv_is_pooled(serv)    ((serv)->sv_ops->svo_function)
 
 /*
  * Mode for mapping cpus to pools.
@@ -494,8 +494,7 @@ EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  struct svc_serv_ops *ops, svc_thread_fn func,
-		  struct module *mod)
+		  struct svc_serv_ops *ops, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
@@ -504,7 +503,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 	if (!serv)
 		goto out_err;
 
-	serv->sv_function = func;
 	serv->sv_module = mod;
 	return serv;
 out_err:
@@ -740,7 +738,7 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 		}
 
 		__module_get(serv->sv_module);
-		task = kthread_create_on_node(serv->sv_function, rqstp,
+		task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
 					      node, "%s", serv->sv_name);
 		if (IS_ERR(task)) {
 			error = PTR_ERR(task);
-- 
2.1.0

