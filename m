From: Greg Banks <gnb@sgi.com>
Subject: [patch 09/29] knfsd: Cache per-client stats entry on TCP transports.
Date: Wed, 01 Apr 2009 07:28:09 +1100
Message-ID: <20090331202941.064678000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22585 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761806AbZCaVCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TCP transports are connection-oriented and every call arriving on
such a transport will use the same per-client stats entry.  So we
can avoid doing a hash lookup in a locked global hashtable on every
NFS call by caching the result of nfsd_stats_find() on the transport.

The same is true of RDMA transports, but this patch doesn't address
that.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/stats.c                 |   45 ++++++++++++++++++++++++++---
 include/linux/sunrpc/svc_xprt.h |    3 +
 net/sunrpc/svc_xprt.c           |    4 ++
 net/sunrpc/svcsock.c            |    1 
 4 files changed, 49 insertions(+), 4 deletions(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -394,6 +394,39 @@ static void __nfsd_stats_op(struct svc_r
 	os->os_ops[op]++;
 }
 
+static inline nfsd_stats_hentry_t *
+nfsd_stats_xprt_cached_get(struct svc_rqst *rqstp)
+{
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+	nfsd_stats_hentry_t *se = NULL;
+
+	if (test_bit(XPT_CACHE_STATS, &xprt->xpt_flags)) {
+		spin_lock(&xprt->xpt_lock);
+		se = xprt->xpt_stats_cache;
+		if (se != NULL)
+			nfsd_stats_get(se);
+		spin_unlock(&xprt->xpt_lock);
+	}
+	return se;
+}
+
+static inline void
+nfsd_stats_xprt_cached_set(struct svc_rqst *rqstp, nfsd_stats_hentry_t *se)
+{
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+
+	if (test_bit(XPT_CACHE_STATS, &xprt->xpt_flags)) {
+		spin_lock(&xprt->xpt_lock);
+		if (xprt->xpt_stats_cache == NULL) {
+			xprt->xpt_stats_cache = se;
+			xprt->xpt_stats_cache_release = (void (*)(void*))nfsd_stats_put;
+			/* take a reference for the cached pointer */
+			nfsd_stats_get(se);
+		}
+		spin_unlock(&xprt->xpt_lock);
+	}
+}
+
 void nfsd_stats_update_op(struct svc_rqst *rqstp, struct svc_fh *fh,
 			  int rbucket, int wbucket, int op)
 {
@@ -424,10 +457,14 @@ void nfsd_stats_update_op(struct svc_rqs
 	/* first op in the call: find and cache per-client stats */
 	if (rqstp->rq_client_stats == NULL) {
 		char *client, buf[SVC_FORMAT_ADDR_MAX];
-		se = NULL;
-		client = __svc_format_addr(svc_addr(rqstp), buf, sizeof(buf));
-		if (client != NULL)
-			se = nfsd_stats_find(&nfsd_client_stats_hash, client, strlen(client));
+		se = nfsd_stats_xprt_cached_get(rqstp);
+		if (se == NULL) {
+			client = __svc_format_addr(svc_addr(rqstp), buf, sizeof(buf));
+			if (client != NULL)
+				se = nfsd_stats_find(&nfsd_client_stats_hash, client, strlen(client));
+			if (se != NULL)
+				nfsd_stats_xprt_cached_set(rqstp, se);
+		}
 		if (se != NULL) {
 			/* take over the new reference from nfsd_stats_find() */
 			rqstp->rq_client_stats = se;
Index: bfields/include/linux/sunrpc/svc_xprt.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc_xprt.h
+++ bfields/include/linux/sunrpc/svc_xprt.h
@@ -51,6 +51,7 @@ struct svc_xprt {
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
 #define XPT_CACHE_AUTH	12		/* cache auth info */
+#define XPT_CACHE_STATS	13		/* cache stats info */
 
 	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
@@ -59,6 +60,8 @@ struct svc_xprt {
 	spinlock_t		xpt_lock;	/* protects sk_deferred
 						 * and xpt_auth_cache */
 	void			*xpt_auth_cache;/* auth cache */
+	void			*xpt_stats_cache;
+	void			(*xpt_stats_cache_release)(void *);
 	struct list_head	xpt_deferred;	/* deferred requests that need
 						 * to be revisted */
 	struct sockaddr_storage	xpt_local;	/* local address */
Index: bfields/net/sunrpc/svc_xprt.c
===================================================================
--- bfields.orig/net/sunrpc/svc_xprt.c
+++ bfields/net/sunrpc/svc_xprt.c
@@ -130,6 +130,10 @@ static void svc_xprt_free(struct kref *k
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
 	    && xprt->xpt_auth_cache != NULL)
 		svcauth_unix_info_release(xprt->xpt_auth_cache);
+	if (test_bit(XPT_CACHE_STATS, &xprt->xpt_flags) &&
+	    xprt->xpt_stats_cache != NULL &&
+	    xprt->xpt_stats_cache_release != NULL)
+		xprt->xpt_stats_cache_release(xprt->xpt_stats_cache);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
Index: bfields/net/sunrpc/svcsock.c
===================================================================
--- bfields.orig/net/sunrpc/svcsock.c
+++ bfields/net/sunrpc/svcsock.c
@@ -1108,6 +1108,7 @@ static void svc_tcp_init(struct svc_sock
 
 	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_CACHE_STATS, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);

--
Greg
