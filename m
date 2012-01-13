Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32292 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab2AMKD1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 05:03:27 -0500
Subject: [PATCH v2 4/4] SUNRPC: unregister service on creation in current
 network namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 14:03:04 +0400
Message-ID: <20120113100304.12259.51570.stgit@localhost6.localdomain6>
In-Reply-To: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
References: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On service shutdown we can be sure, that no more users of it left except
current. Thus it looks like using current network namespace context is safe in
this case.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfssvc.c           |    4 ++--
 include/linux/sunrpc/svc.h |    9 +++++----
 net/sunrpc/svc.c           |   14 +++++++-------
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index eda7d7e..fce472f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -251,13 +251,13 @@ static void nfsd_shutdown(void)
 	nfsd_up = false;
 }
 
-static void nfsd_last_thread(struct svc_serv *serv)
+static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
 	nfsd_serv = NULL;
 	nfsd_shutdown();
 
-	svc_rpcb_cleanup(serv);
+	svc_rpcb_cleanup(serv, net);
 
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
 			    "cache\n");
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d3563c2..7b65495 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -84,7 +84,8 @@ struct svc_serv {
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 
-	void			(*sv_shutdown)(struct svc_serv *serv);
+	void			(*sv_shutdown)(struct svc_serv *serv,
+					       struct net *net);
 						/* Callback to use when last thread
 						 * exits.
 						 */
@@ -413,14 +414,14 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
-void svc_rpcb_cleanup(struct svc_serv *serv);
+void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
-			    void (*shutdown)(struct svc_serv *));
+			    void (*shutdown)(struct svc_serv *, struct net *net));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv *),
+			void (*shutdown)(struct svc_serv *, struct net *net),
 			svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b2cc1b3..1bcfc3c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -380,10 +380,10 @@ static int svc_rpcb_setup(struct svc_serv *serv, struct net *net)
 	return 0;
 }
 
-void svc_rpcb_cleanup(struct svc_serv *serv)
+void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net)
 {
-	svc_unregister(serv, &init_net);
-	rpcb_put_local(&init_net);
+	svc_unregister(serv, net);
+	rpcb_put_local(net);
 }
 EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
 
@@ -409,7 +409,7 @@ static int svc_uses_rpcbind(struct svc_serv *serv)
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	     void (*shutdown)(struct svc_serv *serv))
+	     void (*shutdown)(struct svc_serv *serv, struct net *net))
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -483,7 +483,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-	   void (*shutdown)(struct svc_serv *serv))
+	   void (*shutdown)(struct svc_serv *serv, struct net *net))
 {
 	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
 }
@@ -491,7 +491,7 @@ EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  void (*shutdown)(struct svc_serv *serv),
+		  void (*shutdown)(struct svc_serv *serv, struct net *net),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
@@ -532,7 +532,7 @@ svc_destroy(struct svc_serv *serv)
 	svc_close_all(&serv->sv_tempsocks);
 
 	if (serv->sv_shutdown)
-		serv->sv_shutdown(serv);
+		serv->sv_shutdown(serv, current->nsproxy->net_ns);
 
 	svc_close_all(&serv->sv_permsocks);
 

