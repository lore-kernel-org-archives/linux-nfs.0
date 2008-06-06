From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] sunrpc: remove unneeded fields from svc_serv struct
Date: Fri,  6 Jun 2008 11:12:51 -0400
Message-ID: <1212765171-26042-6-git-send-email-jlayton@redhat.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
 <1212765171-26042-2-git-send-email-jlayton@redhat.com>
 <1212765171-26042-3-git-send-email-jlayton@redhat.com>
 <1212765171-26042-4-git-send-email-jlayton@redhat.com>
 <1212765171-26042-5-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757652AbYFFPM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:12:57 -0400
In-Reply-To: <1212765171-26042-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the sv_module sv_kill_signal fields from the svc_serv struct.
svc_set_num_threads doesn't bother with module reference counts
anymore, and since we don't have a special shutdown signal anymore,
we might as well just standardize on one that's always used to take
down the threads by the kernel (SIGINT).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c           |    3 +--
 include/linux/sunrpc/svc.h |   10 ++--------
 net/sunrpc/svc.c           |   10 +++-------
 3 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index fe62ec8..f4b8592 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -236,8 +236,7 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, SIGINT,
-				      THIS_MODULE);
+				      nfsd_last_thread, nfsd);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 
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
index f461da2..a6794a8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -433,19 +433,15 @@ EXPORT_SYMBOL(svc_create);
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		void (*shutdown)(struct svc_serv *serv),
-		  svc_thread_fn func, int sig, struct module *mod)
+		void (*shutdown)(struct svc_serv *serv), svc_thread_fn func)
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
@@ -681,7 +677,7 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 	/* destroy old threads */
 	while (nrservs < 0 &&
 	       (task = choose_victim(serv, pool, &state)) != NULL) {
-		send_sig(serv->sv_kill_signal, task, 1);
+		send_sig(SIGINT, task, 1);
 		nrservs++;
 	}
 
-- 
1.5.3.6

