From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 16/33] svc: Move sk_server and sk_pool to svc_xprt
Date: Thu, 27 Sep 2007 00:02:08 -0500
Message-ID: <20070927050208.12677.10694.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVj-0005fE-R8
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:03 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVo-0001kb-Aj
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:08 -0700
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


This is another incremental change that moves transport independent 
fields from svc_sock to the svc_xprt structure. The changes 
should be functionally null.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    5 +++-
 include/linux/sunrpc/svcsock.h  |    2 -
 net/sunrpc/svc_xprt.c           |    3 +-
 net/sunrpc/svcsock.c            |   53 +++++++++++++++++++--------------------
 4 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 935726e..b850922 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -49,11 +49,14 @@ #define	XPT_DEFERRED	8			/* deferred req
 #define	XPT_OLD		9			/* used for transport aging mark+sweep */
 #define	XPT_DETACHED	10			/* detached from tempsocks list */
 #define XPT_LISTENER	11			/* listening endpoint */
+
+	struct svc_pool *	xpt_pool;	/* current pool iff queued */
+	struct svc_serv *	xpt_server;	/* service for this transport */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 int	svc_unreg_xprt_class(struct svc_xprt_class *);
-void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *, struct svc_serv *);
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
index 9a9670f..e1a9378 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -102,12 +102,13 @@ EXPORT_SYMBOL_GPL(svc_xprt_put);
  * Called by transport drivers to initialize the transport independent
  * portion of the transport instance.
  */
-void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xpt)
+void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xpt, struct svc_serv *serv)
 {
 	xpt->xpt_class = xcl;
 	xpt->xpt_ops = *xcl->xcl_ops;
 	xpt->xpt_max_payload = xcl->xcl_max_payload;
 	kref_init(&xpt->xpt_ref);
+	xpt->xpt_server = serv;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c6b521d..625e31c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -230,7 +230,7 @@ svc_sock_wspace(struct svc_sock *svsk)
 static void
 svc_sock_enqueue(struct svc_sock *svsk)
 {
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
@@ -242,7 +242,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		return;
 
 	cpu = get_cpu();
-	pool = svc_pool_for_cpu(svsk->sk_server, cpu);
+	pool = svc_pool_for_cpu(svsk->sk_xprt.xpt_server, cpu);
 	put_cpu();
 
 	spin_lock_bh(&pool->sp_lock);
@@ -268,8 +268,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
 		goto out_unlock;
 	}
-	BUG_ON(svsk->sk_pool != NULL);
-	svsk->sk_pool = pool;
+	BUG_ON(svsk->sk_xprt.xpt_pool != NULL);
+	svsk->sk_xprt.xpt_pool = pool;
 
 	/* Handle pending connection */
 	if (test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags))
@@ -283,7 +283,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!svsk->sk_xprt.xpt_ops.xpo_has_wspace(&svsk->sk_xprt)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
-		svsk->sk_pool = NULL;
+		svsk->sk_xprt.xpt_pool = NULL;
 		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 		goto out_unlock;
 	}
@@ -304,12 +304,12 @@ svc_sock_enqueue(struct svc_sock *svsk)
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
@@ -346,7 +346,7 @@ svc_sock_dequeue(struct svc_pool *pool)
 static inline void
 svc_sock_received(struct svc_sock *svsk)
 {
-	svsk->sk_pool = NULL;
+	svsk->sk_xprt.xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	svc_sock_enqueue(svsk);
 }
@@ -749,7 +749,7 @@ static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
 		struct cmsghdr	hdr;
@@ -889,7 +889,7 @@ static int
 svc_udp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = (struct svc_sock*)xprt;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 
 	/*
@@ -943,7 +943,6 @@ svc_udp_init(struct svc_sock *svsk)
 	int one = 1;
 	mm_segment_t oldfs;
 
-	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 
@@ -952,8 +951,8 @@ svc_udp_init(struct svc_sock *svsk)
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
 	svc_sock_setbufsize(svsk->sk_sock,
-			    3 * svsk->sk_server->sv_max_mesg,
-			    3 * svsk->sk_server->sv_max_mesg);
+			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* might have come in before data_ready set up */
 	set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
@@ -1059,7 +1058,7 @@ svc_tcp_accept(struct svc_xprt *xprt)
 	struct svc_sock *svsk = (struct svc_sock *)xprt;
 	struct sockaddr_storage addr;
 	struct sockaddr	*sin = (struct sockaddr *) &addr;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
@@ -1142,7 +1141,7 @@ static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
 	int pnum, vlen;
@@ -1285,7 +1284,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		svc_sock_received(svsk);
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
-					svsk->sk_server->sv_name, -len);
+					svsk->sk_xprt.xpt_server->sv_name, -len);
 		goto err_delete;
 	}
 
@@ -1315,7 +1314,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
-		       rqstp->rq_sock->sk_server->sv_name,
+		       rqstp->rq_sock->sk_xprt.xpt_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
 		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
@@ -1341,7 +1340,7 @@ static int
 svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = (struct svc_sock*)xprt;
-	struct svc_serv	*serv = svsk->sk_server;
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 
 	/*
@@ -1400,8 +1399,6 @@ svc_tcp_init(struct svc_sock *svsk)
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt);
-
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
@@ -1422,8 +1419,8 @@ svc_tcp_init(struct svc_sock *svsk)
 		 * svc_tcp_recvfrom will re-adjust if necessary
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_max_mesg,
-				    3 * svsk->sk_server->sv_max_mesg);
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
@@ -1608,7 +1605,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			 * listener holds a reference too 
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(svsk->sk_server);
+			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
 		}			
 		svc_sock_received(svsk);
 	} else {
@@ -1776,7 +1773,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	svsk->sk_server = serv;
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
@@ -1784,10 +1780,13 @@ static struct svc_sock *svc_setup_socket
 	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
-	if (sock->type == SOCK_DGRAM)
+	if (sock->type == SOCK_DGRAM) {
+		svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
 		svc_udp_init(svsk);
-	else
+	} else {
+		svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
 		svc_tcp_init(svsk);
+	}
 
 	spin_lock_bh(&serv->sv_lock);
 	if (is_temporary) {
@@ -1948,7 +1947,7 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	dprintk("svc: svc_delete_socket(%p)\n", svsk);
 
-	serv = svsk->sk_server;
+	serv = svsk->sk_xprt.xpt_server;
 	sk = svsk->sk_sk;
 
 	svsk->sk_xprt.xpt_ops.xpo_detach(&svsk->sk_xprt);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
