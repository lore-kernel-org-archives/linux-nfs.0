Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27619 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932149AbbFHTGF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 15:06:05 -0400
Message-ID: <5575E794.6020109@oracle.com>
Date: Mon, 08 Jun 2015 12:05:56 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V4 3/7] nfsd/sunrpc: move sv_module parm into sv_ops
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com> 

...not technically an operation, but it's more convenient and cleaner
to pass the module pointer in this struct.
    
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Acked-by: Jeff Layton <jlayton@primarydata.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
---
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index bd03968..17ceaad 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -394,6 +394,7 @@ static int nfsd_get_default_max_blksize(void)
 static struct svc_serv_ops nfsd_sv_ops = {
 	.svo_shutdown = nfsd_last_thread,
 	.svo_function = nfsd,
+	.svo_module = THIS_MODULE,
 };
 
 int nfsd_create_serv(struct net *net)
@@ -410,7 +411,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      &nfsd_sv_ops, THIS_MODULE);
+						&nfsd_sv_ops);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 68103a6..2ec741a 100644
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
index 25d7b92..5ae9d63 100644
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
