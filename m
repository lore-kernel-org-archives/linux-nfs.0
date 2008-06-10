From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] sunrpc: remove sv_kill_signal field from svc_serv struct
Date: Tue, 10 Jun 2008 08:40:39 -0400
Message-ID: <1213101639-26423-6-git-send-email-jlayton@redhat.com>
References: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
 <1213101639-26423-2-git-send-email-jlayton@redhat.com>
 <1213101639-26423-3-git-send-email-jlayton@redhat.com>
 <1213101639-26423-4-git-send-email-jlayton@redhat.com>
 <1213101639-26423-5-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbYFJMkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 08:40:52 -0400
In-Reply-To: <1213101639-26423-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we no longer make any distinction between shutdown signals with
nfsd, then it becomes easier to just standardize on a particular signal
to use to bring it down (SIGINT, in this case).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c           |    3 +--
 include/linux/sunrpc/svc.h |    5 ++---
 net/sunrpc/svc.c           |    5 ++---
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9e21568..26c8114 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -236,8 +236,7 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, SIGINT,
-				      THIS_MODULE);
+				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 011d6d8..dc69068 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -80,7 +80,6 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-	int			sv_kill_signal;	/* signal to kill threads */
 };
 
 /*
@@ -388,8 +387,8 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv*),
-			svc_thread_fn, int sig, struct module *);
+			void (*shutdown)(struct svc_serv*), svc_thread_fn,
+			struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index bcb7ccf..77088bf 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -434,7 +434,7 @@ EXPORT_SYMBOL(svc_create);
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 		void (*shutdown)(struct svc_serv *serv),
-		  svc_thread_fn func, int sig, struct module *mod)
+		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
@@ -443,7 +443,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 
 	if (serv != NULL) {
 		serv->sv_function = func;
-		serv->sv_kill_signal = sig;
 		serv->sv_module = mod;
 	}
 
@@ -684,7 +683,7 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 	/* destroy old threads */
 	while (nrservs < 0 &&
 	       (task = choose_victim(serv, pool, &state)) != NULL) {
-		send_sig(serv->sv_kill_signal, task, 1);
+		send_sig(SIGINT, task, 1);
 		nrservs++;
 	}
 
-- 
1.5.3.6

