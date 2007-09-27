From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 23/33] svc: Move the authinfo cache to svc_xprt.
Date: Thu, 27 Sep 2007 00:02:22 -0500
Message-ID: <20070927050222.12677.48478.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalW4-0005j5-B9
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:24 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalW8-0005T8-7f
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:29 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Move the authinfo cache to svc_xprt. This allows both the TCP and RDMA
transports to share this logic. A flag bit is used to determine if
auth information is to be cached or not. Previously, this code looked
at the transport protocol.

I've also changed the spin_lock/unlock logic so that a lock is not taken for 
transports that are not caching auth info.  

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    5 +++-
 include/linux/sunrpc/svcsock.h  |    5 ----
 net/sunrpc/svc_xprt.c           |    4 +++
 net/sunrpc/svcauth_unix.c       |   54 +++++++++++++++++++++------------------
 net/sunrpc/svcsock.c            |   23 ++++++++---------
 5 files changed, 48 insertions(+), 43 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index edb7ad2..c763dce 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -51,12 +51,15 @@ #define	XPT_DEFERRED	8			/* deferred req
 #define	XPT_OLD		9			/* used for transport aging mark+sweep */
 #define	XPT_DETACHED	10			/* detached from tempsocks list */
 #define XPT_LISTENER	11			/* listening endpoint */
-
+#define XPT_CACHE_AUTH	12			/* cache auth info */
 	struct svc_pool *	xpt_pool;	/* current pool iff queued */
 	struct svc_serv *	xpt_server;	/* service for this transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is reserved */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
 	time_t			xpt_lastrecv;	/* time of last received request */
+	spinlock_t		xpt_lock;	/* protects sk_deferred 
+						 * and xpt_auth_cache */
+	void		*	xpt_auth_cache;	/* auth cache */
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
index d80fc5f..06bf4e8 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -89,6 +89,9 @@ static inline void svc_xprt_free(struct 
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	BUG_ON(atomic_read(&kref->refcount));
 	xprt->xpt_ops.xpo_free(xprt);
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags) 
+	    && xprt->xpt_auth_cache != NULL)
+		svcauth_unix_info_release(xprt->xpt_auth_cache);
 	module_put(owner);
 }
 
@@ -112,6 +115,7 @@ void svc_xprt_init(struct svc_xprt_class
 	INIT_LIST_HEAD(&xpt->xpt_list);
 	INIT_LIST_HEAD(&xpt->xpt_ready);
 	mutex_init(&xpt->xpt_mutex);
+	spin_lock_init(&xpt->xpt_lock);
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
index 04155aa..1dead5d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -53,8 +53,8 @@ #include <linux/sunrpc/stats.h>
  * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
  *	BKL protects svc_serv->sv_nrthread.
- *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
- *             and the ->sk_info_authunix cache.
+ *	svc_sock->sk_xprt.xpt_lock protects the svc_sock->sk_deferred list
+ *             and the ->sk_xprt.xpt_auth_cache cache.
  *	svc_sock->sk_xprt.xpt_flags.XPT_BUSY prevents a svc_sock being enqueued multiply.
  *
  *	Some flags can be set to certain values at any time
@@ -107,16 +107,16 @@ static struct lock_class_key svc_slock_k
 static inline void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sk->sk_lock.owner != NULL);
+	BUG_ON(sk->sk_xprt.xpt_lock.owner != NULL);
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
-		    &svc_slock_key[0], "sk_lock-AF_INET-NFSD", &svc_key[0]);
+		    &svc_slock_key[0], "sk_xprt.xpt_lock-AF_INET-NFSD", &svc_key[0]);
 		break;
 
 	case AF_INET6:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFSD",
-		    &svc_slock_key[1], "sk_lock-AF_INET6-NFSD", &svc_key[1]);
+		    &svc_slock_key[1], "sk_xprt.xpt_lock-AF_INET6-NFSD", &svc_key[1]);
 		break;
 
 	default:
@@ -1774,16 +1774,17 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_xprt.xpt_lastrecv = get_seconds();
-	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM) {
 		svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
 		svc_udp_init(svsk);
+		clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	} else {
 		svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
 		svc_tcp_init(svsk);
+		set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	}
 
 	spin_lock_bh(&serv->sv_lock);
@@ -1925,8 +1926,6 @@ svc_sock_free(struct svc_xprt *xprt)
 	struct svc_sock *svsk = (struct svc_sock *)xprt;
 	dprintk("svc: svc_sock_free(%p)\n", svsk);
 
-	if (svsk->sk_info_authunix != NULL)
-		svcauth_unix_info_release(svsk->sk_info_authunix);
 	if (svsk->sk_sock->file)
 		sockfd_put(svsk->sk_sock);
 	else
@@ -2017,9 +2016,9 @@ static void svc_revisit(struct cache_def
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
@@ -2085,7 +2084,7 @@ static struct svc_deferred_req *svc_defe
 
 	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
 		return NULL;
-	spin_lock(&svsk->sk_lock);
+	spin_lock(&svsk->sk_xprt.xpt_lock);
 	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -2094,7 +2093,7 @@ static struct svc_deferred_req *svc_defe
 		list_del_init(&dr->handle.recent);
 		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	}
-	spin_unlock(&svsk->sk_lock);
+	spin_unlock(&svsk->sk_xprt.xpt_lock);
 	return dr;
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
