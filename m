From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 24/33] svc: Make deferral processing xprt independent
Date: Thu, 27 Sep 2007 00:02:25 -0500
Message-ID: <20070927050224.12677.12190.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalW6-0005jA-3x
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:26 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWA-0005U9-AF
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:31 -0700
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


This functionally trivial patch moves the transport independent sk_deferred 
list to the svc_xprt structure and updates the svc_deferred_req structure
to keep pointers to svc_xprt's directly.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h      |    2 +
 include/linux/sunrpc/svc_xprt.h |    2 +
 include/linux/sunrpc/svcsock.h  |    3 --
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |   60 +++++++++++++++++----------------------
 5 files changed, 30 insertions(+), 38 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index cfb2652..40adc9d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -320,7 +320,7 @@ static inline void svc_free_res_pages(st
 
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
-	struct svc_sock		*svsk;
+	struct svc_xprt		*xprt;
 	struct sockaddr_storage	addr;	/* where reply must go */
 	size_t			addrlen;
 	union svc_addr_u	daddr;	/* where reply must come from */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c763dce..ef5026d 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -60,6 +60,8 @@ #define XPT_CACHE_AUTH	12			/* cache aut
 	spinlock_t		xpt_lock;	/* protects sk_deferred 
 						 * and xpt_auth_cache */
 	void		*	xpt_auth_cache;	/* auth cache */
+	struct list_head	xpt_deferred;	/* deferred requests that need to
+						 * be revisted */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index f2ed6a2..96a229e 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -20,9 +20,6 @@ struct svc_sock {
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
-	struct list_head	sk_deferred;	/* deferred requests that need to
-						 * be revisted */
-
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
 	void			(*sk_odata)(struct sock *, int bytes);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 06bf4e8..14cd288 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -114,6 +114,7 @@ void svc_xprt_init(struct svc_xprt_class
 	xpt->xpt_server = serv;
 	INIT_LIST_HEAD(&xpt->xpt_list);
 	INIT_LIST_HEAD(&xpt->xpt_ready);
+	INIT_LIST_HEAD(&xpt->xpt_deferred);
 	mutex_init(&xpt->xpt_mutex);
 	spin_lock_init(&xpt->xpt_lock);
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1dead5d..9e3071c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -53,7 +53,7 @@ #include <linux/sunrpc/stats.h>
  * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
  *	BKL protects svc_serv->sv_nrthread.
- *	svc_sock->sk_xprt.xpt_lock protects the svc_sock->sk_deferred list
+ *	svc_sock->sk_xprt.xpt_lock protects the svc_sock->sk_xprt.xpt_deferred list
  *             and the ->sk_xprt.xpt_auth_cache cache.
  *	svc_sock->sk_xprt.xpt_flags.XPT_BUSY prevents a svc_sock being enqueued multiply.
  *
@@ -87,7 +87,7 @@ static void		svc_close_xprt(struct svc_x
 static void		svc_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *
@@ -778,11 +778,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_xprt_received(&svsk->sk_xprt);
-		return svc_deferred_recv(rqstp);
-	}
-
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
@@ -1150,11 +1145,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_xprt_received(&svsk->sk_xprt);
-		return svc_deferred_recv(rqstp);
-	}
-
 	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
@@ -1612,7 +1602,12 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk, 
 			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
-		len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
+
+		if ((rqstp->rq_deferred = svc_deferred_dequeue(&svsk->sk_xprt))) {
+			svc_xprt_received(&svsk->sk_xprt);
+			len = svc_deferred_recv(rqstp);
+		} else 
+			len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
 
@@ -1774,7 +1769,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_xprt.xpt_lastrecv = get_seconds();
-	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM) {
@@ -2006,22 +2000,21 @@ void svc_close_all(struct list_head *xpr
 static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 {
 	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
-	struct svc_sock *svsk;
+	struct svc_xprt *xprt = dr->xprt;
 
 	if (too_many) {
-		svc_xprt_put(&dr->svsk->sk_xprt);
+		svc_xprt_put(xprt);
 		kfree(dr);
 		return;
 	}
 	dprintk("revisit queued\n");
-	svsk = dr->svsk;
-	dr->svsk = NULL;
-	spin_lock(&svsk->sk_xprt.xpt_lock);
-	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock(&svsk->sk_xprt.xpt_lock);
-	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	svc_xprt_enqueue(&svsk->sk_xprt);
-	svc_xprt_put(&svsk->sk_xprt);
+	dr->xprt = NULL;
+	spin_lock(&xprt->xpt_lock);
+	list_add(&dr->handle.recent, &xprt->xpt_deferred);
+	spin_unlock(&xprt->xpt_lock);
+	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
+	svc_xprt_put(xprt);
 }
 
 static struct cache_deferred_req *
@@ -2052,7 +2045,7 @@ svc_defer(struct cache_req *req)
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
 	svc_xprt_get(rqstp->rq_xprt);
-	dr->svsk = rqstp->rq_sock;
+	dr->xprt = rqstp->rq_xprt;
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -2078,22 +2071,21 @@ static int svc_deferred_recv(struct svc_
 }
 
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 {
 	struct svc_deferred_req *dr = NULL;
 
-	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
+	if (!test_bit(XPT_DEFERRED, &xprt->xpt_flags))
 		return NULL;
-	spin_lock(&svsk->sk_xprt.xpt_lock);
-	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	if (!list_empty(&svsk->sk_deferred)) {
-		dr = list_entry(svsk->sk_deferred.next,
+	spin_lock(&xprt->xpt_lock);
+	clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	if (!list_empty(&xprt->xpt_deferred)) {
+		dr = list_entry(xprt->xpt_deferred.next,
 				struct svc_deferred_req,
 				handle.recent);
 		list_del_init(&dr->handle.recent);
-		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
+		set_bit(XPT_DEFERRED, &xprt->xpt_flags);
 	}
-	spin_unlock(&svsk->sk_xprt.xpt_lock);
+	spin_unlock(&xprt->xpt_lock);
 	return dr;
 }
-

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
