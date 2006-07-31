From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 11] knfsd: add svc_set_num_threads
Date: Mon, 31 Jul 2006 10:42:23 +1000
Message-ID: <1060731004223.29267@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Lra-0003uQ-R8
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:31 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7Lra-0001fj-8m
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:31 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd:  Currently knfsd keeps its own list of all nfsd threads
in nfssvc.c; add a new way of managing the list of all threads
in a svc_serv.  Add svc_create_pooled() to allow creation of
a svc_serv whose threads are managed by the sunrpc code.  Add
svc_set_num_threads() to manage the number of threads in a service,
either per-pool or globally across the service.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |   21 ++++--
 ./net/sunrpc/sunrpc_syms.c   |    2 
 ./net/sunrpc/svc.c           |  139 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 154 insertions(+), 8 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-07-31 10:29:38.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-07-31 10:30:30.000000000 +1000
@@ -17,6 +17,10 @@
 #include <linux/wait.h>
 #include <linux/mm.h>
 
+/*
+ * This is the RPC server thread function prototype
+ */
+typedef void		(*svc_thread_fn)(struct svc_rqst *);
 
 /*
  *
@@ -34,6 +38,7 @@ struct svc_pool {
 	struct list_head	sp_threads;	/* idle server threads */
 	struct list_head	sp_sockets;	/* pending sockets */
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
+	struct list_head	sp_all_threads;	/* all server threads */
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -68,6 +73,11 @@ struct svc_serv {
 						/* Callback to use when last thread
 						 * exits.
 						 */
+
+	struct module *		sv_module;	/* optional module to count when
+						 * adding threads */
+	svc_thread_fn		sv_function;	/* main function for threads */
+	int			sv_kill_signal;	/* signal to kill threads */
 };
 
 /*
@@ -147,6 +157,7 @@ static inline void svc_putu32(struct kve
  */
 struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
+	struct list_head	rq_all;		/* all threads list */
 	struct svc_sock *	rq_sock;	/* socket */
 	struct sockaddr_in	rq_addr;	/* peer address */
 	int			rq_addrlen;
@@ -201,6 +212,7 @@ struct svc_rqst {
 						 * to prevent encrypting page
 						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
+	struct task_struct	*rq_task;	/* service thread */
 };
 
 /*
@@ -342,17 +354,16 @@ struct svc_procedure {
 };
 
 /*
- * This is the RPC server thread function prototype
- */
-typedef void		(*svc_thread_fn)(struct svc_rqst *);
-
-/*
  * Function prototypes.
  */
 struct svc_serv *  svc_create(struct svc_program *, unsigned int,
 			      void (*shutdown)(struct svc_serv*));
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
 void		   svc_exit_thread(struct svc_rqst *);
+struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
+			void (*shutdown)(struct svc_serv*),
+			svc_thread_fn, int sig, struct module *);
+int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
 int		   svc_register(struct svc_serv *, int, unsigned short);

diff .prev/net/sunrpc/sunrpc_syms.c ./net/sunrpc/sunrpc_syms.c
--- .prev/net/sunrpc/sunrpc_syms.c	2006-07-31 10:29:38.000000000 +1000
+++ ./net/sunrpc/sunrpc_syms.c	2006-07-31 10:30:30.000000000 +1000
@@ -73,6 +73,8 @@ EXPORT_SYMBOL(put_rpccred);
 /* RPC server stuff */
 EXPORT_SYMBOL(svc_create);
 EXPORT_SYMBOL(svc_create_thread);
+EXPORT_SYMBOL(svc_create_pooled);
+EXPORT_SYMBOL(svc_set_num_threads);
 EXPORT_SYMBOL(svc_exit_thread);
 EXPORT_SYMBOL(svc_destroy);
 EXPORT_SYMBOL(svc_drop);

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-07-31 10:29:38.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-07-31 10:30:30.000000000 +1000
@@ -12,6 +12,8 @@
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/mm.h>
+#include <linux/interrupt.h>
+#include <linux/module.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -25,8 +27,8 @@
 /*
  * Create an RPC service
  */
-struct svc_serv *
-svc_create(struct svc_program *prog, unsigned int bufsize,
+static struct svc_serv *
+__svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	   void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
@@ -61,7 +63,7 @@ svc_create(struct svc_program *prog, uns
 	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
-	serv->sv_nrpools = 1;
+	serv->sv_nrpools = npools;
 	serv->sv_pools =
 		kcalloc(sizeof(struct svc_pool), serv->sv_nrpools,
 			GFP_KERNEL);
@@ -79,6 +81,7 @@ svc_create(struct svc_program *prog, uns
 		pool->sp_id = i;
 		INIT_LIST_HEAD(&pool->sp_threads);
 		INIT_LIST_HEAD(&pool->sp_sockets);
+		INIT_LIST_HEAD(&pool->sp_all_threads);
 		spin_lock_init(&pool->sp_lock);
 	}
 
@@ -89,6 +92,31 @@ svc_create(struct svc_program *prog, uns
 	return serv;
 }
 
+struct svc_serv *
+svc_create(struct svc_program *prog, unsigned int bufsize,
+		void (*shutdown)(struct svc_serv *serv))
+{
+	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+}
+
+struct svc_serv *
+svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
+		void (*shutdown)(struct svc_serv *serv),
+		  svc_thread_fn func, int sig, struct module *mod)
+{
+	struct svc_serv *serv;
+
+	serv = __svc_create(prog, bufsize, /*npools*/1, shutdown);
+
+	if (serv != NULL) {
+		serv->sv_function = func;
+		serv->sv_kill_signal = sig;
+		serv->sv_module = mod;
+	}
+
+	return serv;
+}
+
 /*
  * Destroy an RPC service.  Should be called with the BKL held
  */
@@ -203,6 +231,7 @@ __svc_create_thread(svc_thread_fn func, 
 	serv->sv_nrthreads++;
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads++;
+	list_add(&rqstp->rq_all, &pool->sp_all_threads);
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
@@ -229,6 +258,109 @@ svc_create_thread(svc_thread_fn func, st
 }
 
 /*
+ * Choose a pool in which to create a new thread, for svc_set_num_threads
+ */
+static inline struct svc_pool *
+choose_pool(struct svc_serv *serv, struct svc_pool *pool, unsigned int *state)
+{
+	if (pool != NULL)
+		return pool;
+
+ 	return &serv->sv_pools[(*state)++ % serv->sv_nrpools];
+}
+
+/*
+ * Choose a thread to kill, for svc_set_num_threads
+ */
+static inline struct task_struct *
+choose_victim(struct svc_serv *serv, struct svc_pool *pool, unsigned int *state)
+{
+	unsigned int i;
+	struct task_struct *task = NULL;
+
+	if (pool != NULL) {
+		spin_lock_bh(&pool->sp_lock);
+	} else {
+		/* choose a pool in round-robin fashion */
+ 		for (i = 0 ; i < serv->sv_nrpools ; i++) {
+ 			pool = &serv->sv_pools[--(*state) % serv->sv_nrpools];
+			spin_lock_bh(&pool->sp_lock);
+ 			if (!list_empty(&pool->sp_all_threads))
+ 				goto found_pool;
+			spin_unlock_bh(&pool->sp_lock);
+ 		}
+		return NULL;
+	}
+
+found_pool:
+	if (!list_empty(&pool->sp_all_threads)) {
+		struct svc_rqst *rqstp;
+
+		/*
+		 * Remove from the pool->sp_all_threads list
+		 * so we don't try to kill it again.
+		 */
+		rqstp = list_entry(pool->sp_all_threads.next, struct svc_rqst, rq_all);
+		list_del_init(&rqstp->rq_all);
+		task = rqstp->rq_task;
+    	}
+	spin_unlock_bh(&pool->sp_lock);
+
+	return task;
+}
+
+/*
+ * Create or destroy enough new threads to make the number
+ * of threads the given number.  If `pool' is non-NULL, applies
+ * only to threads in that pool, otherwise round-robins between
+ * all pools.  Must be called with a svc_get() reference and
+ * the BKL held.
+ *
+ * Destroying threads relies on the service threads filling in
+ * rqstp->rq_task, which only the nfs ones do.  Assumes the serv
+ * has been created using svc_create_pooled().
+ *
+ * Based on code that used to be in nfsd_svc() but tweaked
+ * to be pool-aware.
+ */
+int
+svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
+{
+	struct task_struct *victim;
+	int error = 0;
+	unsigned int state = serv->sv_nrthreads-1;
+
+	if (pool == NULL) {
+		/* The -1 assumes caller has done a svc_get() */
+		nrservs -= (serv->sv_nrthreads-1);
+	} else {
+		spin_lock_bh(&pool->sp_lock);
+		nrservs -= pool->sp_nrthreads;
+		spin_unlock_bh(&pool->sp_lock);
+	}
+
+	/* create new threads */
+	while (nrservs > 0) {
+		nrservs--;
+		__module_get(serv->sv_module);
+		error = __svc_create_thread(serv->sv_function, serv,
+					    choose_pool(serv, pool, &state));
+		if (error < 0) {
+			module_put(serv->sv_module);
+			break;
+		}
+	}
+	/* destroy old threads */
+	while (nrservs < 0 &&
+	       (victim = choose_victim(serv, pool, &state)) != NULL) {
+		send_sig(serv->sv_kill_signal, victim, 1);
+		nrservs++;
+	}
+
+	return error;
+}
+
+/*
  * Called from a server thread as it's exiting.  Caller must hold BKL.
  */
 void
@@ -244,6 +376,7 @@ svc_exit_thread(struct svc_rqst *rqstp)
 
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads--;
+	list_del(&rqstp->rq_all);
 	spin_unlock_bh(&pool->sp_lock);
 
 	kfree(rqstp);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
