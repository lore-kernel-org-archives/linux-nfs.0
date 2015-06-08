Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50833 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbbFHTHC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 15:07:02 -0400
Message-ID: <5575E7CB.4070302@oracle.com>
Date: Mon, 08 Jun 2015 12:06:51 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V4 4/7] nfsd/sunrpc: turn enqueueing a svc_xprt into a
 svc_serv operation
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

For now, all services use svc_xprt_do_enqueue, but once we add
workqueue-based service support, we'll need to do something different.
    
Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Acked-by: Jeff Layton <jlayton@primarydata.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
---
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 4182b2f..530914b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -323,7 +323,8 @@ out_rqst:
 }
 
 static struct svc_serv_ops lockd_sv_ops = {
-	.svo_shutdown	= svc_rpcb_cleanup,
+	.svo_shutdown		= svc_rpcb_cleanup,
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 };
 
 static struct svc_serv *lockd_create_svc(void)
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5bd657d2..15b3e65 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -309,6 +309,7 @@ err_bind:
 }
 
 static struct svc_serv_ops nfs_cb_sv_ops = {
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 };
 
 static struct svc_serv *nfs_callback_create_svc(int minorversion)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 17ceaad..d8b9b4c 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -391,10 +391,11 @@ static int nfsd_get_default_max_blksize(void)
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
@@ -411,7 +412,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-						&nfsd_sv_ops);
+						&nfsd_thread_sv_ops);
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2ec741a..51dd3f1 100644
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
index 79f6f8f..78512cf 100644
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
index 163ac45..a6cbb21 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -24,7 +24,6 @@ static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static void svc_age_temp_xprts(unsigned long closure);
 static void svc_delete_xprt(struct svc_xprt *xprt);
-static void svc_xprt_do_enqueue(struct svc_xprt *xprt);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -225,12 +224,12 @@ static void svc_xprt_received(struct svc_xprt *xprt)
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
 
@@ -320,7 +319,7 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 	return false;
 }
 
-static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
+void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 {
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp = NULL;
@@ -402,6 +401,7 @@ redo_search:
 out:
 	trace_svc_xprt_do_enqueue(xprt, rqstp);
 }
+EXPORT_SYMBOL_GPL(svc_xprt_do_enqueue);
 
 /*
  * Queue up a transport with data pending. If there are idle nfsd
@@ -412,7 +412,7 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
 	if (test_bit(XPT_BUSY, &xprt->xpt_flags))
 		return;
-	svc_xprt_do_enqueue(xprt);
+	xprt->xpt_server->sv_ops->svo_enqueue_xprt(xprt);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 
