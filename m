From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] SUNRPC: Add address family field to svc_serv data
	structure
Date: Mon, 18 Aug 2008 19:33:37 -0400
Message-ID: <20080818233336.1214.63403.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21574 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbYHSMG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:06:59 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce and initialize an address family field in the svc_serv structure.

This field will determine what address family to use for the service's
listener sockets and which address family is advertised via the local
rpcbind daemon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c             |    2 +-
 fs/nfs/callback.c          |    3 ++-
 fs/nfsd/nfssvc.c           |    3 ++-
 include/linux/sunrpc/svc.h |   11 +++++++----
 net/sunrpc/svc.c           |   12 +++++++-----
 5 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 5bd9bf0..1553fec 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -266,7 +266,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, AF_INET, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index f447f4b..6a09760 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -105,7 +105,8 @@ int nfs_callback_up(void)
 	mutex_lock(&nfs_callback_mutex);
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
+	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
+				AF_INET, NULL);
 	ret = -ENOMEM;
 	if (!serv)
 		goto out_err;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 80292ff..4eed938 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -229,7 +229,8 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+				      AF_INET, nfsd_last_thread,
+				      nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index dc69068..a794d4a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -66,6 +66,7 @@ struct svc_serv {
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
 	int			sv_tmpcnt;	/* count of temporary sockets */
 	struct timer_list	sv_temptimer;	/* timer for aging temporary sockets */
+	sa_family_t		sv_family;	/* listener's address family */
 
 	char *			sv_name;	/* service name */
 
@@ -381,14 +382,16 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
-struct svc_serv *  svc_create(struct svc_program *, unsigned int,
-			      void (*shutdown)(struct svc_serv*));
+struct svc_serv *svc_create(struct svc_program *, unsigned int,
+					const sa_family_t,
+					void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv*), svc_thread_fn,
-			struct module *);
+					const sa_family_t,
+					void (*shutdown)(struct svc_serv *),
+					svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5a32cb7..2a6649f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -357,7 +357,7 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	   void (*shutdown)(struct svc_serv *serv))
+	     const sa_family_t family, void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -366,6 +366,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
+	serv->sv_family    = family;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
@@ -425,21 +426,22 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-		void (*shutdown)(struct svc_serv *serv))
+	   const sa_family_t family, void (*shutdown)(struct svc_serv *serv))
 {
-	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+	return __svc_create(prog, bufsize, /*npools*/1, family, shutdown);
 }
 EXPORT_SYMBOL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		void (*shutdown)(struct svc_serv *serv),
+		  const sa_family_t family,
+		  void (*shutdown)(struct svc_serv *serv),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, shutdown);
+	serv = __svc_create(prog, bufsize, npools, family, shutdown);
 
 	if (serv != NULL) {
 		serv->sv_function = func;

