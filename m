Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51342 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbFHFV6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 01:21:58 -0400
Message-ID: <55752673.3030803@oracle.com>
Date: Sun, 07 Jun 2015 22:21:55 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V3 1/7] nfsd/sunrpc: add a new svc_serv_ops struct and
 move sv_shutdown into it
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
    
In later patches we'll need to abstract out more operations on a
per-service level, besides sv_shutdown and sv_function.
    
Declare a new svc_serv_ops struct to hold these operations, and move
sv_shutdown into this struct.

Author: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
---
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 55505cb..4182b2f 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -322,6 +322,10 @@ out_rqst:
 	return error;
 }
 
+static struct svc_serv_ops lockd_sv_ops = {
+	.svo_shutdown	= svc_rpcb_cleanup,
+};
+
 static struct svc_serv *lockd_create_svc(void)
 {
 	struct svc_serv *serv;
@@ -350,7 +354,7 @@ static struct svc_serv *lockd_create_svc(void)
 		nlm_timeout = LOCKD_DFLT_TIMEO;
 	nlmsvc_timeout = nlm_timeout * HZ;
 
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, svc_rpcb_cleanup);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, &lockd_sv_ops);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 8d129bb..5bd657d2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -308,6 +308,9 @@ err_bind:
 	return ret;
 }
 
+static struct svc_serv_ops nfs_cb_sv_ops = {
+};
+
 static struct svc_serv *nfs_callback_create_svc(int minorversion)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
@@ -333,7 +336,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 		printk(KERN_WARNING "nfs_callback_create_svc: no kthread, %d users??\n",
 			cb_info->users);
 
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
+	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, &nfs_cb_sv_ops);
 	if (!serv) {
 		printk(KERN_ERR "nfs_callback_create_svc: create service failed\n");
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9277cc9..7311677 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -391,6 +391,10 @@ static int nfsd_get_default_max_blksize(void)
 	return ret;
 }
 
+static struct svc_serv_ops nfsd_sv_ops = {
+	.svo_shutdown = nfsd_last_thread,
+};
+
 int nfsd_create_serv(struct net *net)
 {
 	int error;
@@ -405,7 +409,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+				      &nfsd_sv_ops, nfsd, THIS_MODULE);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index fae6fb9..3d651be 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -54,6 +54,13 @@ struct svc_pool {
 	unsigned long		sp_flags;
 } ____cacheline_aligned_in_smp;
 
+struct svc_serv;
+
+struct svc_serv_ops {
+	/* Callback to use when last thread exits. */
+	void	(*svo_shutdown)(struct svc_serv *serv, struct net *net);
+};
+
 /*
  * RPC service.
  *
@@ -85,13 +92,7 @@ struct svc_serv {
 
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
-
-	void			(*sv_shutdown)(struct svc_serv *serv,
-					       struct net *net);
-						/* Callback to use when last thread
-						 * exits.
-						 */
-
+	struct svc_serv_ops *	sv_ops;		/* server operations */
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
@@ -429,13 +430,12 @@ int svc_rpcb_setup(struct svc_serv *serv, struct net *net);
 void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net);
 int svc_bind(struct svc_serv *serv, struct net *net);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
-			    void (*shutdown)(struct svc_serv *, struct net *net));
+			    struct svc_serv_ops *);
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv *, struct net *net),
-			svc_thread_fn, struct module *);
+			struct svc_serv_ops *, svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
 void		   svc_destroy(struct svc_serv *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78974e4..bb44682 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -423,7 +423,7 @@ EXPORT_SYMBOL_GPL(svc_bind);
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	     void (*shutdown)(struct svc_serv *serv, struct net *net))
+	     struct svc_serv_ops *ops)
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -440,7 +440,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		bufsize = RPCSVC_MAXPAYLOAD;
 	serv->sv_max_payload = bufsize? bufsize : 4096;
 	serv->sv_max_mesg  = roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE);
-	serv->sv_shutdown  = shutdown;
+	serv->sv_ops = ops;
 	xdrsize = 0;
 	while (prog) {
 		prog->pg_lovers = prog->pg_nvers-1;
@@ -486,21 +486,21 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-	   void (*shutdown)(struct svc_serv *serv, struct net *net))
+	   struct svc_serv_ops *ops)
 {
-	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+	return __svc_create(prog, bufsize, /*npools*/1, ops);
 }
 EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  void (*shutdown)(struct svc_serv *serv, struct net *net),
-		  svc_thread_fn func, struct module *mod)
+		  struct svc_serv_ops *ops, svc_thread_fn func,
+		  struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, shutdown);
+	serv = __svc_create(prog, bufsize, npools, ops);
 	if (!serv)
 		goto out_err;
 
@@ -517,8 +517,8 @@ void svc_shutdown_net(struct svc_serv *serv, struct net *net)
 {
 	svc_close_net(serv, net);
 
-	if (serv->sv_shutdown)
-		serv->sv_shutdown(serv, net);
+	if (serv->sv_ops->svo_shutdown)
+		serv->sv_ops->svo_shutdown(serv, net);
 }
 EXPORT_SYMBOL_GPL(svc_shutdown_net);
 
