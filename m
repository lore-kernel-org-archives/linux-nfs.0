From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/40] SUNRPC: Remove @family argument from svc_create() and
	svc_create_pooled()
Date: Thu, 12 Mar 2009 12:07:51 -0400
Message-ID: <20090312160751.16019.76662.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:61761 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750AbZCLQId (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:08:33 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since an RPC service listener's protocol family is specified now via
svc_create_xprt(), it no longer needs to be passed to svc_create() or
svc_create_pooled().  Remove that argument from the synopsis of those
functions, and remove the sv_family field from the svc_serv struct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c             |    2 +-
 fs/nfs/callback.c          |    3 +--
 fs/nfsd/nfssvc.c           |    1 -
 include/linux/sunrpc/svc.h |    5 ++---
 net/sunrpc/svc.c           |   11 +++++------
 5 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 390c559..d309200 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -275,7 +275,7 @@ int lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, nlmsvc_family, NULL);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index fb35cab..ddf4b4a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -116,8 +116,7 @@ int nfs_callback_up(void)
 	mutex_lock(&nfs_callback_mutex);
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
-				nfs_callback_family, NULL);
+	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
 	ret = -ENOMEM;
 	if (!serv)
 		goto out_err;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ab7f249..bc3567b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -229,7 +229,6 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      AF_INET,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1f18fc7..d3a4c02 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -69,7 +69,6 @@ struct svc_serv {
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
 	int			sv_tmpcnt;	/* count of temporary sockets */
 	struct timer_list	sv_temptimer;	/* timer for aging temporary sockets */
-	sa_family_t		sv_family;	/* listener's address family */
 
 	char *			sv_name;	/* service name */
 
@@ -385,13 +384,13 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
-struct svc_serv *svc_create(struct svc_program *, unsigned int, sa_family_t,
+struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			sa_family_t, void (*shutdown)(struct svc_serv *),
+			void (*shutdown)(struct svc_serv *),
 			svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 41bc36e..d72ff44 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -359,7 +359,7 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	   sa_family_t family, void (*shutdown)(struct svc_serv *serv))
+	     void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -368,7 +368,6 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
-	serv->sv_family    = family;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
@@ -427,21 +426,21 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-		sa_family_t family, void (*shutdown)(struct svc_serv *serv))
+	   void (*shutdown)(struct svc_serv *serv))
 {
-	return __svc_create(prog, bufsize, /*npools*/1, family, shutdown);
+	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
 }
 EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  sa_family_t family, void (*shutdown)(struct svc_serv *serv),
+		  void (*shutdown)(struct svc_serv *serv),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, family, shutdown);
+	serv = __svc_create(prog, bufsize, npools, shutdown);
 
 	if (serv != NULL) {
 		serv->sv_function = func;

