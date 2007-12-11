From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 24/38] svc: Move the authinfo cache to svc_xprt.
Date: Tue, 11 Dec 2007 17:32:47 -0600
Message-ID: <20071211233247.15718.96948.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35431 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755113AbXLKXcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:48 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Move the authinfo cache to svc_xprt. This allows both the TCP and RDMA
transports to share this logic. A flag bit is used to determine if
auth information is to be cached or not. Previously, this code looked
at the transport protocol.

I've also changed the spin_lock/unlock logic so that a lock is not taken for 
transports that are not caching auth info.  

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    4 +++
 include/linux/sunrpc/svcsock.h  |    5 ----
 net/sunrpc/svc_xprt.c           |    4 +++
 net/sunrpc/svcauth_unix.c       |   54 +++++++++++++++++++++------------------
 net/sunrpc/svcsock.c            |   22 +++++++++-------
 5 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c416d05..dfb1d4d 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -50,11 +50,15 @@ struct svc_xprt {
 #define	XPT_OLD		9		/* used for xprt aging mark+sweep */
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
+#define XPT_CACHE_AUTH	12		/* cache auth info */
 
 	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
+	spinlock_t		xpt_lock;	/* protects sk_deferred
+						 * and xpt_auth_cache */
+	void			*xpt_auth_cache;/* auth cache */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 406d003..f2ed6a2 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -20,8 +20,6 @@ struct svc_sock {
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
-	spinlock_t		sk_lock;	/* protects sk_deferred and
-						 * sk_info_authunix */
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
 
@@ -34,9 +32,6 @@ struct svc_sock {
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
 
-	/* cache of various info for TCP sockets */
-	void			*sk_info_authunix;
-
 	struct sockaddr_storage	sk_local;	/* local address */
 	struct sockaddr_storage	sk_remote;	/* remote peer's address */
 	int			sk_remotelen;	/* length of address */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7544102..79009c2 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -88,6 +88,9 @@ static void svc_xprt_free(struct kref *kref)
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	BUG_ON(atomic_read(&kref->refcount));
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
+	    && xprt->xpt_auth_cache != NULL)
+		svcauth_unix_info_release(xprt->xpt_auth_cache);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
@@ -113,6 +116,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
 	mutex_init(&xprt->xpt_mutex);
+	spin_lock_init(&xprt->xpt_lock);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4114794..6815157 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -384,41 +384,45 @@ void svcauth_unix_purge(void)
 static inline struct ip_map *
 ip_map_cached_get(struct svc_rqst *rqstp)
 {
-	struct ip_map *ipm;
-	struct svc_sock *svsk = rqstp->rq_sock;
-	spin_lock(&svsk->sk_lock);
-	ipm = svsk->sk_info_authunix;
-	if (ipm != NULL) {
-		if (!cache_valid(&ipm->h)) {
-			/*
-			 * The entry has been invalidated since it was
-			 * remembered, e.g. by a second mount from the
-			 * same IP address.
-			 */
-			svsk->sk_info_authunix = NULL;
-			spin_unlock(&svsk->sk_lock);
-			cache_put(&ipm->h, &ip_map_cache);
-			return NULL;
+	struct ip_map *ipm = NULL;
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)) {
+		spin_lock(&xprt->xpt_lock);
+		ipm = xprt->xpt_auth_cache;
+		if (ipm != NULL) {
+			if (!cache_valid(&ipm->h)) {
+				/*
+				 * The entry has been invalidated since it was
+				 * remembered, e.g. by a second mount from the
+				 * same IP address.
+				 */
+				xprt->xpt_auth_cache = NULL;
+				spin_unlock(&xprt->xpt_lock);
+				cache_put(&ipm->h, &ip_map_cache);
+				return NULL;
+			}
+			cache_get(&ipm->h);
 		}
-		cache_get(&ipm->h);
+		spin_unlock(&xprt->xpt_lock);
 	}
-	spin_unlock(&svsk->sk_lock);
 	return ipm;
 }
 
 static inline void
 ip_map_cached_put(struct svc_rqst *rqstp, struct ip_map *ipm)
 {
-	struct svc_sock *svsk = rqstp->rq_sock;
+	struct svc_xprt *xprt = rqstp->rq_xprt;
 
-	spin_lock(&svsk->sk_lock);
-	if (svsk->sk_sock->type == SOCK_STREAM &&
-	    svsk->sk_info_authunix == NULL) {
-		/* newly cached, keep the reference */
-		svsk->sk_info_authunix = ipm;
-		ipm = NULL;
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)) {
+		spin_lock(&xprt->xpt_lock);
+		if (xprt->xpt_auth_cache == NULL) {
+			/* newly cached, keep the reference */
+			xprt->xpt_auth_cache = ipm;
+			ipm = NULL;
+		}
+		spin_unlock(&xprt->xpt_lock);
 	}
-	spin_unlock(&svsk->sk_lock);
 	if (ipm)
 		cache_put(&ipm->h, &ip_map_cache);
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a7af4cf..328155a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -113,12 +113,16 @@ static inline void svc_reclassify_socket(struct socket *sock)
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
-		    &svc_slock_key[0], "sk_lock-AF_INET-NFSD", &svc_key[0]);
+					      &svc_slock_key[0],
+					      "sk_xprt.xpt_lock-AF_INET-NFSD",
+					      &svc_key[0]);
 		break;
 
 	case AF_INET6:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFSD",
-		    &svc_slock_key[1], "sk_lock-AF_INET6-NFSD", &svc_key[1]);
+					      &svc_slock_key[1],
+					      "sk_xprt.xpt_lock-AF_INET6-NFSD",
+					      &svc_key[1]);
 		break;
 
 	default:
@@ -927,6 +931,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	mm_segment_t oldfs;
 
 	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
+	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 
@@ -1382,7 +1387,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
-
+	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
@@ -1755,7 +1760,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
@@ -1900,8 +1904,6 @@ static void svc_sock_free(struct svc_xprt *xprt)
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	dprintk("svc: svc_sock_free(%p)\n", svsk);
 
-	if (svsk->sk_info_authunix != NULL)
-		svcauth_unix_info_release(svsk->sk_info_authunix);
 	if (svsk->sk_sock->file)
 		sockfd_put(svsk->sk_sock);
 	else
@@ -1986,9 +1988,9 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	dprintk("revisit queued\n");
 	svsk = dr->svsk;
 	dr->svsk = NULL;
-	spin_lock(&svsk->sk_lock);
+	spin_lock(&svsk->sk_xprt.xpt_lock);
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock(&svsk->sk_lock);
+	spin_unlock(&svsk->sk_xprt.xpt_lock);
 	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	svc_xprt_enqueue(&svsk->sk_xprt);
 	svc_xprt_put(&svsk->sk_xprt);
@@ -2054,7 +2056,7 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
 
 	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
 		return NULL;
-	spin_lock(&svsk->sk_lock);
+	spin_lock(&svsk->sk_xprt.xpt_lock);
 	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -2063,7 +2065,7 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
 		list_del_init(&dr->handle.recent);
 		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	}
-	spin_unlock(&svsk->sk_lock);
+	spin_unlock(&svsk->sk_xprt.xpt_lock);
 	return dr;
 }
 
