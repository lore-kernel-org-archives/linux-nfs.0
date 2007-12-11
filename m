From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 16/38] svc: Move sk_server and sk_pool to svc_xprt
Date: Tue, 11 Dec 2007 17:32:29 -0600
Message-ID: <20071211233229.15718.76399.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35402 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754405AbXLKXca (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:30 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is another incremental change that moves transport independent 
fields from svc_sock to the svc_xprt structure. The changes 
should be functionally null.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    6 +++-
 include/linux/sunrpc/svcsock.h  |    2 -
 net/sunrpc/svc_xprt.c           |    4 ++-
 net/sunrpc/svcsock.c            |   57 ++++++++++++++++++---------------------
 4 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index f391d21..4f7dbbc 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -48,11 +48,15 @@ struct svc_xprt {
 #define	XPT_OLD		9		/* used for xprt aging mark+sweep */
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
+
+	struct svc_pool		*xpt_pool;	/* current pool iff queued */
+	struct svc_serv		*xpt_server;	/* service for transport */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 int	svc_unreg_xprt_class(struct svc_xprt_class *);
-void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
+		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
 void	svc_xprt_put(struct svc_xprt *xprt);
 
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index b8a8496..92d4cc9 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -22,8 +22,6 @@ struct svc_sock {
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
-	struct svc_pool *	sk_pool;	/* current pool iff queued */
-	struct svc_serv *	sk_server;	/* service for this socket */
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
 	spinlock_t		sk_lock;	/* protects sk_deferred and
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 43418cf..e366add 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -102,12 +102,14 @@ EXPORT_SYMBOL_GPL(svc_xprt_put);
  * Called by transport drivers to initialize the transport independent
  * portion of the transport instance.
  */
-void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
+void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
+		   struct svc_serv *serv)
 {
 	memset(xprt, 0, sizeof(*xprt));
 	xprt->xpt_class = xcl;
 	xprt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xprt->xpt_ref);
+	xprt->xpt_server = serv;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3a625c4..400cf6e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -215,7 +215,7 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 static void
 svc_sock_enqueue(struct svc_sock *svsk)
 {
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
@@ -227,7 +227,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		return;
 
 	cpu = get_cpu();
-	pool = svc_pool_for_cpu(svsk->sk_server, cpu);
+	pool = svc_pool_for_cpu(svsk->sk_xprt.xpt_server, cpu);
 	put_cpu();
 
 	spin_lock_bh(&pool->sp_lock);
@@ -253,8 +253,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
 		goto out_unlock;
 	}
-	BUG_ON(svsk->sk_pool != NULL);
-	svsk->sk_pool = pool;
+	BUG_ON(svsk->sk_xprt.xpt_pool != NULL);
+	svsk->sk_xprt.xpt_pool = pool;
 
 	/* Handle pending connection */
 	if (test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags))
@@ -268,7 +268,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!svsk->sk_xprt.xpt_ops->xpo_has_wspace(&svsk->sk_xprt)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
-		svsk->sk_pool = NULL;
+		svsk->sk_xprt.xpt_pool = NULL;
 		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 		goto out_unlock;
 	}
@@ -289,12 +289,12 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
-		BUG_ON(svsk->sk_pool != pool);
+		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
 		list_add_tail(&svsk->sk_ready, &pool->sp_sockets);
-		BUG_ON(svsk->sk_pool != pool);
+		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 	}
 
 out_unlock:
@@ -331,7 +331,7 @@ svc_sock_dequeue(struct svc_pool *pool)
 static inline void
 svc_sock_received(struct svc_sock *svsk)
 {
-	svsk->sk_pool = NULL;
+	svsk->sk_xprt.xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	svc_sock_enqueue(svsk);
 }
@@ -735,7 +735,7 @@ static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
 		struct cmsghdr	hdr;
@@ -873,7 +873,7 @@ static void svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
 static int svc_udp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = xprt->xpt_server;
 	unsigned long required;
 
 	/*
@@ -920,13 +920,12 @@ static struct svc_xprt_class svc_udp_class = {
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
 
-static void
-svc_udp_init(struct svc_sock *svsk)
+static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
 	int one = 1;
 	mm_segment_t oldfs;
 
-	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt);
+	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 
@@ -935,8 +934,8 @@ svc_udp_init(struct svc_sock *svsk)
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
 	svc_sock_setbufsize(svsk->sk_sock,
-			    3 * svsk->sk_server->sv_max_mesg,
-			    3 * svsk->sk_server->sv_max_mesg);
+			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* might have come in before data_ready set up */
 	set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
@@ -1041,7 +1040,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	struct sockaddr_storage addr;
 	struct sockaddr	*sin = (struct sockaddr *) &addr;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
@@ -1122,7 +1121,7 @@ static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
 	int pnum, vlen;
@@ -1265,7 +1264,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		svc_sock_received(svsk);
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
-					svsk->sk_server->sv_name, -len);
+		       svsk->sk_xprt.xpt_server->sv_name, -len);
 		goto err_delete;
 	}
 
@@ -1295,7 +1294,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
-		       rqstp->rq_sock->sk_server->sv_name,
+		       rqstp->rq_sock->sk_xprt.xpt_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
 		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
@@ -1319,7 +1318,7 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 	int wspace;
 
@@ -1378,13 +1377,12 @@ void svc_cleanup_xprt_sock(void)
 	svc_unreg_xprt_class(&svc_udp_class);
 }
 
-static void
-svc_tcp_init(struct svc_sock *svsk)
+static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt);
+	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
@@ -1407,8 +1405,8 @@ svc_tcp_init(struct svc_sock *svsk)
 		 * svc_tcp_recvfrom will re-adjust if necessary
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_max_mesg,
-				    3 * svsk->sk_server->sv_max_mesg);
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
@@ -1593,7 +1591,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			 * listener holds a reference too
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(svsk->sk_server);
+			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
 		}
 		svc_sock_received(svsk);
 	} else {
@@ -1761,7 +1759,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	svsk->sk_server = serv;
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
@@ -1770,9 +1767,9 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
-		svc_udp_init(svsk);
+		svc_udp_init(svsk, serv);
 	else
-		svc_tcp_init(svsk);
+		svc_tcp_init(svsk, serv);
 
 	spin_lock_bh(&serv->sv_lock);
 	if (is_temporary) {
@@ -1930,7 +1927,7 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	dprintk("svc: svc_delete_socket(%p)\n", svsk);
 
-	serv = svsk->sk_server;
+	serv = svsk->sk_xprt.xpt_server;
 	sk = svsk->sk_sk;
 
 	svsk->sk_xprt.xpt_ops->xpo_detach(&svsk->sk_xprt);
