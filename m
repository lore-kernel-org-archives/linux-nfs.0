Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16886 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150Ab1IMSON (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:13 -0400
Subject: [PATCH v3 04/11] SUNRPC: parametrize svc creation calls with
	portmapper flag
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:13:51 +0400
Message-ID: <20110913181351.3961.70207.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This new flag ("setup_rpcbind) will be used to detect, that new service will
send portmapper register calls. For such services we will create rpcbind
clients and remove all stale portmap registrations.
Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
in case of this field wasn't initialized earlier. This will allow to destroy
rpcbind clients when no other users of them left.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svc.c           |   21 ++++++++++++++-------
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 223588a..528952a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -402,11 +402,13 @@ struct svc_procedure {
  * Function prototypes.
  */
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
+			    int setup_rpcbind,
 			    void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
+			int setup_rpcbind,
 			void (*shutdown)(struct svc_serv *),
 			svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f31e5cc..03231d5 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -378,7 +378,7 @@ static void svc_rpcb_cleanup(struct svc_serv *serv)
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	     void (*shutdown)(struct svc_serv *serv))
+	     int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -437,29 +437,36 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-	/* Remove any stale portmap registrations */
-	svc_unregister(serv);
+	if (setup_rpcbind) {
+	       	if (svc_rpcb_setup(serv) < 0) {
+			kfree(serv->sv_pools);
+			kfree(serv);
+			return NULL;
+		}
+		if (!serv->sv_shutdown)
+			serv->sv_shutdown = svc_rpcb_cleanup;
+	}
 
 	return serv;
 }
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-	   void (*shutdown)(struct svc_serv *serv))
+	   int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
 {
-	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+	return __svc_create(prog, bufsize, /*npools*/1, setup_rpcbind, shutdown);
 }
 EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  void (*shutdown)(struct svc_serv *serv),
+		  int setup_rpcbind, void (*shutdown)(struct svc_serv *serv),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, shutdown);
+	serv = __svc_create(prog, bufsize, npools, setup_rpcbind, shutdown);
 
 	if (serv != NULL) {
 		serv->sv_function = func;

