From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] sunrpc: remove unneeded field from svc_serv struct
Date: Wed,  4 Jun 2008 11:03:16 -0400
Message-ID: <1212591796-22144-5-git-send-email-jlayton@redhat.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
 <1212591796-22144-2-git-send-email-jlayton@redhat.com>
 <1212591796-22144-3-git-send-email-jlayton@redhat.com>
 <1212591796-22144-4-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754089AbYFDPDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 11:03:52 -0400
In-Reply-To: <1212591796-22144-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the sv_module field from the svc_serv struct since
svc_set_num_threads doesn't bother with module reference
counts anymore.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c           |    3 +--
 include/linux/sunrpc/svc.h |    8 ++------
 net/sunrpc/svc.c           |    3 +--
 3 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 825936b..a87f7f9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -228,8 +228,7 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, SIGINT,
-				      THIS_MODULE);
+				      nfsd_last_thread, nfsd, SIGINT);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 011d6d8..6d69165 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -72,13 +72,9 @@ struct svc_serv {
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
 	int			sv_kill_signal;	/* signal to kill threads */
 };
@@ -389,7 +385,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 			void (*shutdown)(struct svc_serv*),
-			svc_thread_fn, int sig, struct module *);
+			svc_thread_fn, int);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f461da2..9eabb3f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -434,7 +434,7 @@ EXPORT_SYMBOL(svc_create);
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 		void (*shutdown)(struct svc_serv *serv),
-		  svc_thread_fn func, int sig, struct module *mod)
+		  svc_thread_fn func, int sig)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
@@ -444,7 +444,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 	if (serv != NULL) {
 		serv->sv_function = func;
 		serv->sv_kill_signal = sig;
-		serv->sv_module = mod;
 	}
 
 	return serv;
-- 
1.5.3.6

