Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:51767 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbaLBSYe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:34 -0500
Received: by mail-qa0-f46.google.com with SMTP id n8so3134229qaq.19
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:33 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 03/14] sunrpc: move sv_module parm into sv_ops
Date: Tue,  2 Dec 2014 13:24:12 -0500
Message-Id: <1417544663-13299-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...not technically an operation, but it's more convenient and cleaner
to pass the module pointer in this struct.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfssvc.c           | 3 ++-
 include/linux/sunrpc/svc.h | 9 ++++++---
 net/sunrpc/svc.c           | 8 +++-----
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 5017af3fe882..94e7e173aa10 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -393,6 +393,7 @@ static int nfsd_get_default_max_blksize(void)
 static struct svc_serv_ops nfsd_sv_ops = {
 	.svo_shutdown = nfsd_last_thread,
 	.svo_function = nfsd,
+	.svo_module = THIS_MODULE,
 };
 
 int nfsd_create_serv(struct net *net)
@@ -409,7 +410,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      &nfsd_sv_ops, THIS_MODULE);
+						&nfsd_sv_ops);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7e27894bc065..377be73b736f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -54,7 +54,12 @@ struct svc_serv;
 struct svc_serv_ops {
 	/* Callback to use when last thread exits. */
 	void		(*svo_shutdown)(struct svc_serv *, struct net *);
+
+	/* function for service threads to run */
 	int		(*svo_function)(void *);
+
+	/* optional module to count when adding threads (pooled svcs only) */
+	struct module	*svo_module;
 };
 
 /*
@@ -89,8 +94,6 @@ struct svc_serv {
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	struct svc_serv_ops *	sv_ops;		/* server operations */
-	struct module *		sv_module;	/* optional module to count when
-						 * adding threads */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -430,7 +433,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			struct svc_serv_ops *, struct module *);
+			struct svc_serv_ops *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
 void		   svc_destroy(struct svc_serv *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 897c755c6186..9b4b4d8d109a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -494,7 +494,7 @@ EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  struct svc_serv_ops *ops, struct module *mod)
+		  struct svc_serv_ops *ops)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
@@ -502,8 +502,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 	serv = __svc_create(prog, bufsize, npools, ops);
 	if (!serv)
 		goto out_err;
-
-	serv->sv_module = mod;
 	return serv;
 out_err:
 	svc_pool_map_put();
@@ -737,12 +735,12 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 			break;
 		}
 
-		__module_get(serv->sv_module);
+		__module_get(serv->sv_ops->svo_module);
 		task = kthread_create_on_node(serv->sv_ops->svo_function, rqstp,
 					      node, "%s", serv->sv_name);
 		if (IS_ERR(task)) {
 			error = PTR_ERR(task);
-			module_put(serv->sv_module);
+			module_put(serv->sv_ops->svo_module);
 			svc_exit_thread(rqstp);
 			break;
 		}
-- 
2.1.0

