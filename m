From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] [RFC] sunrpc: remove unneeded fields from svc_serv struct
Date: Sat, 17 May 2008 22:35:13 -0400
Message-ID: <1211078114-18384-3-git-send-email-jlayton@redhat.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
 <1211078114-18384-2-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbYERCfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 May 2008 22:35:17 -0400
In-Reply-To: <1211078114-18384-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove 2 fields that are no longer needed in the svc_serv struct,
sv_module and sv_kill_signal. sv_kill_signal doesn't appear to
currently be used for anything, and sv_module is no longer
needed since svc_set_num_threads doesn't bother with module reference
counts anymore. Also, remove the args from svc_create_pooled from
which these fields were populated.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c           |    6 ++----
 include/linux/sunrpc/svc.h |   10 ++--------
 net/sunrpc/svc.c           |    7 ++-----
 3 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b5fdb9b..d4d4be9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -218,10 +218,8 @@ int nfsd_create_serv(void)
 	}
 
 	atomic_set(&nfsd_busy, 0);
-	nfsd_serv = svc_create_pooled(&nfsd_program,
-				      nfsd_max_blksize,
-				      nfsd_last_thread,
-				      nfsd, SIG_NOCLEAN, THIS_MODULE);
+	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
+				      nfsd_last_thread, nfsd);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 	unlock_kernel();
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 011d6d8..cd304c4 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -72,15 +72,10 @@ struct svc_serv {
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 
+	/* Callback to use when last thread exits */
 	void			(*sv_shutdown)(struct svc_serv *serv);
-						/* Callback to use when last thread
-						 * exits.
-						 */
 
-	struct module *		sv_module;	/* optional module to count when
-						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-	int			sv_kill_signal;	/* signal to kill threads */
 };
 
 /*
@@ -388,8 +383,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv*),
-			svc_thread_fn, int sig, struct module *);
+			void (*shutdown)(struct svc_serv*), svc_thread_fn);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 18a9e33..da90ce0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -434,18 +434,15 @@ EXPORT_SYMBOL(svc_create);
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 		void (*shutdown)(struct svc_serv *serv),
-		  svc_thread_fn func, int sig, struct module *mod)
+		  svc_thread_fn func)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
 	serv = __svc_create(prog, bufsize, npools, shutdown);
 
-	if (serv != NULL) {
+	if (serv != NULL)
 		serv->sv_function = func;
-		serv->sv_kill_signal = sig;
-		serv->sv_module = mod;
-	}
 
 	return serv;
 }
-- 
1.5.3.6

