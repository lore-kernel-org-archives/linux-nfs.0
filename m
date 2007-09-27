From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 15/33] svc: Move sk_flags to the svc_xprt structure
Date: Thu, 27 Sep 2007 00:02:06 -0500
Message-ID: <20070927050206.12677.134.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVi-0005dQ-8c
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:02 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVm-0001kb-82
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:07 -0700
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


This functionally trivial change moves the transport independent sk_flags 
field to the transport independent svc_xprt structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |   12 +++
 include/linux/sunrpc/svcsock.h  |   13 ----
 net/sunrpc/svcsock.c            |  144 ++++++++++++++++++++-------------------
 3 files changed, 84 insertions(+), 85 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c9196bc..935726e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -37,6 +37,18 @@ struct svc_xprt {
 	struct svc_xprt_ops	xpt_ops;
 	u32			xpt_max_payload;
 	struct kref		xpt_ref;
+	unsigned long		xpt_flags;
+#define	XPT_BUSY	0			/* enqueued/receiving */
+#define	XPT_CONN	1			/* conn pending */
+#define	XPT_CLOSE	2			/* dead or dying */
+#define	XPT_DATA	3			/* data pending */
+#define	XPT_TEMP	4			/* connected transport */
+#define	XPT_DEAD	6			/* transport closed */
+#define	XPT_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
+#define	XPT_DEFERRED	8			/* deferred request pending */
+#define	XPT_OLD		9			/* used for transport aging mark+sweep */
+#define	XPT_DETACHED	10			/* detached from tempsocks list */
+#define XPT_LISTENER	11			/* listening endpoint */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index ba07d50..b8a8496 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -24,19 +24,6 @@ struct svc_sock {
 
 	struct svc_pool *	sk_pool;	/* current pool iff queued */
 	struct svc_serv *	sk_server;	/* service for this socket */
-	unsigned long		sk_flags;
-#define	SK_BUSY		0			/* enqueued/receiving */
-#define	SK_CONN		1			/* conn pending */
-#define	SK_CLOSE	2			/* dead or dying */
-#define	SK_DATA		3			/* data pending */
-#define	SK_TEMP		4			/* temp (TCP) socket */
-#define	SK_DEAD		6			/* socket closed */
-#define	SK_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
-#define	SK_DEFERRED	8			/* request on sk_deferred */
-#define	SK_OLD		9			/* used for temp socket aging mark+sweep */
-#define	SK_DETACHED	10			/* detached from tempsocks list */
-#define SK_LISTENER	11			/* listening endpoint */
-
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
 	spinlock_t		sk_lock;	/* protects sk_deferred and
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a92b000..c6b521d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -55,22 +55,22 @@ #include <linux/sunrpc/stats.h>
  *	BKL protects svc_serv->sv_nrthread.
  *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
  *             and the ->sk_info_authunix cache.
- *	svc_sock->sk_flags.SK_BUSY prevents a svc_sock being enqueued multiply.
+ *	svc_sock->sk_xprt.xpt_flags.XPT_BUSY prevents a svc_sock being enqueued multiply.
  *
  *	Some flags can be set to certain values at any time
  *	providing that certain rules are followed:
  *
- *	SK_CONN, SK_DATA, can be set or cleared at any time.
+ *	XPT_CONN, XPT_DATA, can be set or cleared at any time.
  *		after a set, svc_sock_enqueue must be called.
  *		after a clear, the socket must be read/accepted
  *		 if this succeeds, it must be set again.
- *	SK_CLOSE can set at any time. It is never cleared.
- *      xpt_ref contains a bias of '1' until SK_DEAD is set.
+ *	XPT_CLOSE can set at any time. It is never cleared.
+ *      xpt_ref contains a bias of '1' until XPT_DEAD is set.
  *             so when xprt_ref hits zero, we know the transport is dead
  *             and no-one is using it.
- *      SK_DEAD can only be set while SK_BUSY is held which ensures
+ *      XPT_DEAD can only be set while XPT_BUSY is held which ensures
  *             no other thread will be using the socket or will try to
- *	       set SK_DEAD.
+ *	       set XPT_DEAD.
  *
  */
 
@@ -235,10 +235,10 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	struct svc_rqst	*rqstp;
 	int cpu;
 
-	if (!(svsk->sk_flags &
-	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
+	if (!(svsk->sk_xprt.xpt_flags &
+	      ( (1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED)) ))
 		return;
-	if (test_bit(SK_DEAD, &svsk->sk_flags))
+	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
 		return;
 
 	cpu = get_cpu();
@@ -252,7 +252,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		printk(KERN_ERR
 			"svc_sock_enqueue: threads and sockets both waiting??\n");
 
-	if (test_bit(SK_DEAD, &svsk->sk_flags)) {
+	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags)) {
 		/* Don't enqueue dead sockets */
 		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
 		goto out_unlock;
@@ -260,10 +260,10 @@ svc_sock_enqueue(struct svc_sock *svsk)
 
 	/* Mark socket as busy. It will remain in this state until the
 	 * server has processed all pending data and put the socket back
-	 * on the idle list.  We update SK_BUSY atomically because
+	 * on the idle list.  We update XPT_BUSY atomically because
 	 * it also guards against trying to enqueue the svc_sock twice.
 	 */
-	if (test_and_set_bit(SK_BUSY, &svsk->sk_flags)) {
+	if (test_and_set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags)) {
 		/* Don't enqueue socket while already enqueued */
 		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
 		goto out_unlock;
@@ -272,11 +272,11 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	svsk->sk_pool = pool;
 
 	/* Handle pending connection */
-	if (test_bit(SK_CONN, &svsk->sk_flags))
+	if (test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags))
 		goto process;
 
 	/* Handle close in-progress */
-	if (test_bit(SK_CLOSE, &svsk->sk_flags))
+	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags))
 		goto process;
 
 	/* Check if we have space to reply to a request */
@@ -284,7 +284,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
 		svsk->sk_pool = NULL;
-		clear_bit(SK_BUSY, &svsk->sk_flags);
+		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 		goto out_unlock;
 	}
 
@@ -340,14 +340,14 @@ svc_sock_dequeue(struct svc_pool *pool)
 /*
  * Having read something from a socket, check whether it
  * needs to be re-enqueued.
- * Note: SK_DATA only gets cleared when a read-attempt finds
+ * Note: XPT_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
 static inline void
 svc_sock_received(struct svc_sock *svsk)
 {
 	svsk->sk_pool = NULL;
-	clear_bit(SK_BUSY, &svsk->sk_flags);
+	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	svc_sock_enqueue(svsk);
 }
 
@@ -696,8 +696,8 @@ svc_udp_data_ready(struct sock *sk, int 
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
-			svsk, sk, count, test_bit(SK_BUSY, &svsk->sk_flags));
-		set_bit(SK_DATA, &svsk->sk_flags);
+			svsk, sk, count, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_sock_enqueue(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
@@ -714,7 +714,7 @@ svc_write_space(struct sock *sk)
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), write_space busy=%d\n",
-			svsk, sk, test_bit(SK_BUSY, &svsk->sk_flags));
+			svsk, sk, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
 		svc_sock_enqueue(svsk);
 	}
 
@@ -764,7 +764,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		.msg_flags = MSG_DONTWAIT,
 	};
 
-	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
 	    /* udp sockets need large rcvbuf as all pending
 	     * requests are still in that buffer.  sndbuf must
 	     * also be large enough that there is enough space
@@ -782,7 +782,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	clear_bit(SK_DATA, &svsk->sk_flags);
+	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 			     0, 0, MSG_PEEK | MSG_DONTWAIT);
@@ -793,7 +793,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		if (err != -EAGAIN) {
 			/* possibly an icmp error */
 			dprintk("svc: recvfrom returned error %d\n", -err);
-			set_bit(SK_DATA, &svsk->sk_flags);
+			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		}
 		svc_sock_received(svsk);
 		return -EAGAIN;
@@ -805,7 +805,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		   need that much accuracy */
 	}
 	svsk->sk_sk->sk_stamp = skb->tstamp;
-	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
+	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
 	/*
 	 * Maybe more packets - kick another thread ASAP.
@@ -955,8 +955,8 @@ svc_udp_init(struct svc_sock *svsk)
 			    3 * svsk->sk_server->sv_max_mesg,
 			    3 * svsk->sk_server->sv_max_mesg);
 
-	set_bit(SK_DATA, &svsk->sk_flags); /* might have come in before data_ready set up */
-	set_bit(SK_CHNGBUF, &svsk->sk_flags);
+	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* might have come in before data_ready set up */
+	set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 
 	oldfs = get_fs();
 	set_fs(KERNEL_DS);
@@ -990,7 +990,7 @@ svc_tcp_listen_data_ready(struct sock *s
 	 */
 	if (sk->sk_state == TCP_LISTEN) {
 		if (svsk) {
-			set_bit(SK_CONN, &svsk->sk_flags);
+			set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 			svc_sock_enqueue(svsk);
 		} else
 			printk("svc: socket %p: no user data\n", sk);
@@ -1014,7 +1014,7 @@ svc_tcp_state_change(struct sock *sk)
 	if (!svsk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
-		set_bit(SK_CLOSE, &svsk->sk_flags);
+		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 		svc_sock_enqueue(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
@@ -1029,7 +1029,7 @@ svc_tcp_data_ready(struct sock *sk, int 
 	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
 		sk, sk->sk_user_data);
 	if (svsk) {
-		set_bit(SK_DATA, &svsk->sk_flags);
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_sock_enqueue(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
@@ -1070,7 +1070,7 @@ svc_tcp_accept(struct svc_xprt *xprt)
 	if (!sock)
 		return NULL;
 
-	clear_bit(SK_CONN, &svsk->sk_flags);
+	clear_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
 	if (err < 0) {
 		if (err == -ENOMEM)
@@ -1082,7 +1082,7 @@ svc_tcp_accept(struct svc_xprt *xprt)
 		return NULL;
 	}
 
-	set_bit(SK_CONN, &svsk->sk_flags);
+	set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 	svc_sock_enqueue(svsk);
 
 	err = kernel_getpeername(newsock, sin, &slen);
@@ -1148,16 +1148,16 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	int pnum, vlen;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
-		svsk, test_bit(SK_DATA, &svsk->sk_flags),
-		test_bit(SK_CONN, &svsk->sk_flags),
-		test_bit(SK_CLOSE, &svsk->sk_flags));
+		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
+		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
+		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
 		svc_sock_received(svsk);
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
 		 * network isn't a bottleneck.
@@ -1174,7 +1174,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
 				    3 * serv->sv_max_mesg);
 
-	clear_bit(SK_DATA, &svsk->sk_flags);
+	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	/* Receive data. If we haven't got the record length yet, get
 	 * the next four bytes. Otherwise try to gobble up as much as
@@ -1233,7 +1233,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return -EAGAIN;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
-	set_bit(SK_DATA, &svsk->sk_flags);
+	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
@@ -1309,7 +1309,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	reclen = htonl(0x80000000|((xbufp->len ) - 4));
 	memcpy(xbufp->head[0].iov_base, &reclen, 4);
 
-	if (test_bit(SK_DEAD, &rqstp->rq_sock->sk_flags))
+	if (test_bit(XPT_DEAD, &rqstp->rq_sock->sk_xprt.xpt_flags))
 		return -ENOTCONN;
 
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
@@ -1318,7 +1318,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 		       rqstp->rq_sock->sk_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
-		set_bit(SK_CLOSE, &rqstp->rq_sock->sk_flags);
+		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
 		svc_sock_enqueue(rqstp->rq_sock);
 		sent = -EAGAIN;
 	}
@@ -1405,7 +1405,7 @@ svc_tcp_init(struct svc_sock *svsk)
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
-		set_bit(SK_CONN, &svsk->sk_flags);
+		set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 	} else {
 		dprintk("setting up TCP socket for reading\n");
 		sk->sk_state_change = svc_tcp_state_change;
@@ -1425,10 +1425,10 @@ svc_tcp_init(struct svc_sock *svsk)
 				    3 * svsk->sk_server->sv_max_mesg,
 				    3 * svsk->sk_server->sv_max_mesg);
 
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
-		set_bit(SK_DATA, &svsk->sk_flags);
+		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		if (sk->sk_state != TCP_ESTABLISHED)
-			set_bit(SK_CLOSE, &svsk->sk_flags);
+			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 	}
 }
 
@@ -1445,12 +1445,12 @@ svc_sock_update_bufs(struct svc_serv *se
 	list_for_each(le, &serv->sv_permsocks) {
 		struct svc_sock *svsk =
 			list_entry(le, struct svc_sock, sk_list);
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
+		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 	}
 	list_for_each(le, &serv->sv_tempsocks) {
 		struct svc_sock *svsk =
 			list_entry(le, struct svc_sock, sk_list);
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
+		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 }
@@ -1492,7 +1492,7 @@ svc_check_conn_limits(struct svc_serv *s
 			svsk = list_entry(serv->sv_tempsocks.prev,
 					  struct svc_sock,
 					  sk_list);
-			set_bit(SK_CLOSE, &svsk->sk_flags);
+			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 			svc_xprt_get(&svsk->sk_xprt);
 		}
 		spin_unlock_bh(&serv->sv_lock);
@@ -1596,10 +1596,10 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		dprintk("svc_recv: found SK_CLOSE\n");
+	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_socket(svsk);
-	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
+	} else if (test_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
 		if (newxpt) {
@@ -1626,7 +1626,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		return -EAGAIN;
 	}
 	svsk->sk_lastrecv = get_seconds();
-	clear_bit(SK_OLD, &svsk->sk_flags);
+	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
@@ -1673,7 +1673,7 @@ svc_send(struct svc_rqst *rqstp)
 
 	/* Grab svsk->sk_mutex to serialize outgoing data. */
 	mutex_lock(&svsk->sk_mutex);
-	if (test_bit(SK_DEAD, &svsk->sk_flags))
+	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
 		len = -ENOTCONN;
 	else
 		len = svsk->sk_xprt.xpt_ops.xpo_sendto(rqstp);
@@ -1709,21 +1709,21 @@ svc_age_temp_sockets(unsigned long closu
 	list_for_each_safe(le, next, &serv->sv_tempsocks) {
 		svsk = list_entry(le, struct svc_sock, sk_list);
 
-		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
+		if (!test_and_set_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags))
 			continue;
 		if (atomic_read(&svsk->sk_xprt.xpt_ref.refcount) > 1 
 		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
 		svc_xprt_get(&svsk->sk_xprt);
 		list_move(le, &to_be_aged);
-		set_bit(SK_CLOSE, &svsk->sk_flags);
-		set_bit(SK_DETACHED, &svsk->sk_flags);
+		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+		set_bit(XPT_DETACHED, &svsk->sk_xprt.xpt_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
 	while (!list_empty(&to_be_aged)) {
 		le = to_be_aged.next;
-		/* fiddling the sk_list node is safe 'cos we're SK_DETACHED */
+		/* fiddling the sk_list node is safe 'cos we're XPT_DETACHED */
 		list_del_init(le);
 		svsk = list_entry(le, struct svc_sock, sk_list);
 
@@ -1769,7 +1769,7 @@ static struct svc_sock *svc_setup_socket
 		return NULL;
 	}
 
-	set_bit(SK_BUSY, &svsk->sk_flags);
+	set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	inet->sk_user_data = svsk;
 	svsk->sk_sock = sock;
 	svsk->sk_sk = inet;
@@ -1791,7 +1791,7 @@ static struct svc_sock *svc_setup_socket
 
 	spin_lock_bh(&serv->sv_lock);
 	if (is_temporary) {
-		set_bit(SK_TEMP, &svsk->sk_flags);
+		set_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
@@ -1802,7 +1802,7 @@ static struct svc_sock *svc_setup_socket
 					jiffies + svc_conn_age_period * HZ);
 		}
 	} else {
-		clear_bit(SK_TEMP, &svsk->sk_flags);
+		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
 		list_add(&svsk->sk_list, &serv->sv_permsocks);
 	}
 	spin_unlock_bh(&serv->sv_lock);
@@ -1890,7 +1890,7 @@ svc_create_socket(struct svc_serv *serv,
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
 		if (protocol == IPPROTO_TCP) 
-			set_bit(SK_LISTENER, &svsk->sk_flags);
+			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
 		svc_sock_received(svsk);
 		return (struct svc_xprt *)svsk;
 	}
@@ -1955,7 +1955,7 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	spin_lock_bh(&serv->sv_lock);
 
-	if (!test_and_set_bit(SK_DETACHED, &svsk->sk_flags))
+	if (!test_and_set_bit(XPT_DETACHED, &svsk->sk_xprt.xpt_flags))
 		list_del_init(&svsk->sk_list);
 	/*
 	 * We used to delete the svc_sock from whichever list
@@ -1964,10 +1964,10 @@ svc_delete_socket(struct svc_sock *svsk)
 	 * while still attached to a queue, the queue itself
 	 * is about to be destroyed (in svc_destroy).
 	 */
-	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
+	if (!test_and_set_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags)) {
 		BUG_ON(atomic_read(&svsk->sk_xprt.xpt_ref.refcount)<2);
 		svc_xprt_put(&svsk->sk_xprt);
-		if (test_bit(SK_TEMP, &svsk->sk_flags))
+		if (test_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags))
 			serv->sv_tmpcnt--;
 	}
 
@@ -1976,26 +1976,26 @@ svc_delete_socket(struct svc_sock *svsk)
 
 static void svc_close_socket(struct svc_sock *svsk)
 {
-	set_bit(SK_CLOSE, &svsk->sk_flags);
-	if (test_and_set_bit(SK_BUSY, &svsk->sk_flags))
+	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	if (test_and_set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags))
 		/* someone else will have to effect the close */
 		return;
 
 	svc_xprt_get(&svsk->sk_xprt);
 	svc_delete_socket(svsk);
-	clear_bit(SK_BUSY, &svsk->sk_flags);
+	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	svc_xprt_put(&svsk->sk_xprt);
 }
 
 void svc_force_close_socket(struct svc_sock *svsk)
 {
-	set_bit(SK_CLOSE, &svsk->sk_flags);
-	if (test_bit(SK_BUSY, &svsk->sk_flags)) {
+	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	if (test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags)) {
 		/* Waiting to be processed, but no threads left,
 		 * So just remove it from the waiting list
 		 */
 		list_del_init(&svsk->sk_ready);
-		clear_bit(SK_BUSY, &svsk->sk_flags);
+		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	}
 	svc_close_socket(svsk);
 }
@@ -2020,7 +2020,7 @@ static void svc_revisit(struct cache_def
 	spin_lock(&svsk->sk_lock);
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
 	spin_unlock(&svsk->sk_lock);
-	set_bit(SK_DEFERRED, &svsk->sk_flags);
+	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	svc_sock_enqueue(svsk);
 	svc_xprt_put(&svsk->sk_xprt);
 }
@@ -2083,16 +2083,16 @@ static struct svc_deferred_req *svc_defe
 {
 	struct svc_deferred_req *dr = NULL;
 
-	if (!test_bit(SK_DEFERRED, &svsk->sk_flags))
+	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
 		return NULL;
 	spin_lock(&svsk->sk_lock);
-	clear_bit(SK_DEFERRED, &svsk->sk_flags);
+	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
 				struct svc_deferred_req,
 				handle.recent);
 		list_del_init(&dr->handle.recent);
-		set_bit(SK_DEFERRED, &svsk->sk_flags);
+		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
 	}
 	spin_unlock(&svsk->sk_lock);
 	return dr;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
