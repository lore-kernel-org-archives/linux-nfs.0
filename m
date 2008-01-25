From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 072/100] svc: Move the authinfo cache to svc_xprt.
Date: Fri, 25 Jan 2008 18:16:52 -0500
Message-ID: <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761990AbYAYXSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:11 -0500
In-Reply-To: <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Move the authinfo cache to svc_xprt. This allows both the TCP and RDMA
transports to share this logic. A flag bit is used to determine if
auth information is to be cached or not. Previously, this code looked
at the transport protocol.

I've also changed the spin_lock/unlock logic so that a lock is not taken for
transports that are not caching auth info.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    4 +++
 include/linux/sunrpc/svcsock.h  |    5 ---
 net/sunrpc/svc_xprt.c           |    4 +++
 net/sunrpc/svcauth_unix.c       |   56 +++++++++++++++++++++------------------
 net/sunrpc/svcsock.c            |   22 ++++++++-------
 5 files changed, 50 insertions(+), 41 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 936e0dc..1b5da39 100644
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
index 3e6a1c8..d2ac130 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -75,6 +75,9 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
+	    && xprt->xpt_auth_cache != NULL)
+		svcauth_unix_info_release(xprt->xpt_auth_cache);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
@@ -100,6 +103,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
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
index e98ea4d..073e832 100644
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
@@ -930,6 +934,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	mm_segment_t oldfs;
 
 	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
+	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 
@@ -1385,7 +1390,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
-
+	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
@@ -1753,7 +1758,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
@@ -1898,8 +1902,6 @@ static void svc_sock_free(struct svc_xprt *xprt)
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	dprintk("svc: svc_sock_free(%p)\n", svsk);
 
-	if (svsk->sk_info_authunix != NULL)
-		svcauth_unix_info_release(svsk->sk_info_authunix);
 	if (svsk->sk_sock->file)
 		sockfd_put(svsk->sk_sock);
 	else
@@ -1984,9 +1986,9 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
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
@@ -2052,7 +2054,7 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
 
 	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
 		return NULL;
-	spin_lock(&svsk->sk_lock);
+	spin_lock(&svsk->sk_xprt.xpt_lock);
 	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -2061,6 +2063,6 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
 		list_del_init(&dr->handle.recent);
 		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	}
-	spin_unlock(&svsk->sk_lock);
+	spin_unlock(&svsk->sk_xprt.xpt_lock);
 	return dr;
 }
-- 
1.5.4.rc2.60.gb2e62

