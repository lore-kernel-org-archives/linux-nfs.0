Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:52277 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720AbaLBSYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:35 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so9863507qcv.15
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:34 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 04/14] sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
Date: Tue,  2 Dec 2014 13:24:13 -0500
Message-Id: <1417544663-13299-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For now, all services use svc_xprt_do_enqueue, but once we add
workqueue-based service support, we'll need to do something different.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svc.c                  |  3 ++-
 fs/nfs/callback.c               |  1 +
 fs/nfsd/nfssvc.c                | 11 ++++++-----
 include/linux/sunrpc/svc.h      |  3 +++
 include/linux/sunrpc/svc_xprt.h |  1 +
 net/sunrpc/svc_xprt.c           | 10 +++++-----
 6 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index d93a8d0a04bb..b6bdba25d4fb 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -327,7 +327,8 @@ out_rqst:
 }
 
 static struct svc_serv_ops lockd_sv_ops = {
-	.svo_shutdown	= svc_rpcb_cleanup,
+	.svo_shutdown		= svc_rpcb_cleanup,
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 };
 
 static struct svc_serv *lockd_create_svc(void)
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ace6c70f807b..1800a918f244 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -307,6 +307,7 @@ err_bind:
 }
 
 static struct svc_serv_ops nfs_cb_sv_ops = {
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 };
 
 static struct svc_serv *nfs_callback_create_svc(int minorversion)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 94e7e173aa10..5904c06cfd32 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -390,10 +390,11 @@ static int nfsd_get_default_max_blksize(void)
 	return ret;
 }
 
-static struct svc_serv_ops nfsd_sv_ops = {
-	.svo_shutdown = nfsd_last_thread,
-	.svo_function = nfsd,
-	.svo_module = THIS_MODULE,
+static struct svc_serv_ops nfsd_thread_sv_ops = {
+	.svo_shutdown		= nfsd_last_thread,
+	.svo_function		= nfsd,
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_module		= THIS_MODULE,
 };
 
 int nfsd_create_serv(struct net *net)
@@ -410,7 +411,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-						&nfsd_sv_ops);
+						&nfsd_thread_sv_ops);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 377be73b736f..7429cdcb48b5 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -58,6 +58,9 @@ struct svc_serv_ops {
 	/* function for service threads to run */
 	int		(*svo_function)(void *);
 
+	/* queue up a transport for servicing */
+	void		(*svo_enqueue_xprt)(struct svc_xprt *);
+
 	/* optional module to count when adding threads (pooled svcs only) */
 	struct module	*svo_module;
 };
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 79f6f8f3dc0a..78512cfe1fe6 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -116,6 +116,7 @@ void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, const char *, struct net *,
 			const int, const unsigned short, int);
+void	svc_xprt_do_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c69358b3cf7f..4954339315b7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -24,7 +24,6 @@ static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static void svc_age_temp_xprts(unsigned long closure);
 static void svc_delete_xprt(struct svc_xprt *xprt);
-static void svc_xprt_do_enqueue(struct svc_xprt *xprt);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -226,12 +225,12 @@ static void svc_xprt_received(struct svc_xprt *xprt)
 	}
 
 	/* As soon as we clear busy, the xprt could be closed and
-	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
+	 * 'put', so we need a reference to call svc_enqueue_xprt with:
 	 */
 	svc_xprt_get(xprt);
 	smp_mb__before_atomic();
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
-	svc_xprt_do_enqueue(xprt);
+	xprt->xpt_server->sv_ops->svo_enqueue_xprt(xprt);
 	svc_xprt_put(xprt);
 }
 
@@ -321,7 +320,7 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 	return false;
 }
 
-static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
+void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 {
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp = NULL;
@@ -403,6 +402,7 @@ redo_search:
 out:
 	trace_svc_xprt_do_enqueue(xprt, rqstp);
 }
+EXPORT_SYMBOL_GPL(svc_xprt_do_enqueue);
 
 /*
  * Queue up a transport with data pending. If there are idle nfsd
@@ -413,7 +413,7 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
 	if (test_bit(XPT_BUSY, &xprt->xpt_flags))
 		return;
-	svc_xprt_do_enqueue(xprt);
+	xprt->xpt_server->sv_ops->svo_enqueue_xprt(xprt);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 
-- 
2.1.0

