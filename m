Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.229]:21247 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751317AbbAVNTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 08:19:35 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc/lockd: fix references to the BKL
Date: Thu, 22 Jan 2015 08:19:32 -0500
Message-Id: <1421932772-4044-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The BKL is completely out of the picture in the lockd and sunrpc code
these days. Update the antiquated comments that refer to it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svclock.c         | 4 ++--
 include/linux/sunrpc/svc.h | 2 +-
 net/sunrpc/svc.c           | 4 ++--
 net/sunrpc/svc_xprt.c      | 3 +--
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 56598742dde4..5581e020644b 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -57,8 +57,8 @@ static DEFINE_SPINLOCK(nlm_blocked_lock);
 static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 {
 	/*
-	 * We can get away with a static buffer because we're only
-	 * called with BKL held.
+	 * We can get away with a static buffer because this is only called
+	 * from lockd, which is single-threaded.
 	 */
 	static char buf[2*NLM_MAXCOOKIELEN+1];
 	unsigned int i, len = sizeof(buf);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6f22cfeef5e3..fae6fb947fc8 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -110,7 +110,7 @@ struct svc_serv {
  * We use sv_nrthreads as a reference count.  svc_destroy() drops
  * this refcount, so we need to bump it up around operations that
  * change the number of threads.  Horrible, but there it is.
- * Should be called with the BKL held.
+ * Should be called with the "service mutex" held.
  */
 static inline void svc_get(struct svc_serv *serv)
 {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 91eaef1844c8..78974e4d9ad2 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -768,8 +768,8 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 EXPORT_SYMBOL_GPL(svc_set_num_threads);
 
 /*
- * Called from a server thread as it's exiting. Caller must hold the BKL or
- * the "service mutex", whichever is appropriate for the service.
+ * Called from a server thread as it's exiting. Caller must hold the "service
+ * mutex" for the service.
  */
 void
 svc_exit_thread(struct svc_rqst *rqstp)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c69358b3cf7f..163ac45c3639 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -42,7 +42,7 @@ static LIST_HEAD(svc_xprt_class_list);
  *	svc_pool->sp_lock protects most of the fields of that pool.
  *	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
- *	BKL protects svc_serv->sv_nrthread.
+ *	The "service mutex" protects svc_serv->sv_nrthread.
  *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
  *             and the ->sk_info_authunix cache.
  *
@@ -67,7 +67,6 @@ static LIST_HEAD(svc_xprt_class_list);
  *		  that no other thread will be using the transport or will
  *		  try to set XPT_DEAD.
  */
-
 int svc_reg_xprt_class(struct svc_xprt_class *xcl)
 {
 	struct svc_xprt_class *cl;
-- 
2.1.0

