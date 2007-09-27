From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 19/33] svc: Make the enqueue service transport neutral and
	export it.
Date: Thu, 27 Sep 2007 00:02:14 -0500
Message-ID: <20070927050214.12677.21902.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVw-0005iJ-5e
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:16 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVz-0005QD-Pi
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:21 -0700
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


The svc_sock_enqueue function is now transport independent since all of
the fields it touches have been moved to the transport independent svc_xprt
structure. Change the function to use the svc_xprt structure directly
instead of the transport specific svc_sock structure.

Transport specific data-ready handlers need to call this function, so
export it.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   95 +++++++++++++++++++++++++-------------------------
 1 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8ea950a..db9963e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -5,7 +5,7 @@
  *
  * The server scheduling algorithm does not always distribute the load
  * evenly when servicing a single client. May need to modify the
- * svc_sock_enqueue procedure...
+ * svc_xprt_enqueue procedure...
  *
  * TCP support is largely untested and may be a little slow. The problem
  * is that we currently do two separate recvfrom's, one for the 4-byte
@@ -61,7 +61,7 @@ #include <linux/sunrpc/stats.h>
  *	providing that certain rules are followed:
  *
  *	XPT_CONN, XPT_DATA, can be set or cleared at any time.
- *		after a set, svc_sock_enqueue must be called.
+ *		after a set, svc_xprt_enqueue must be called.
  *		after a clear, the socket must be read/accepted
  *		 if this succeeds, it must be set again.
  *	XPT_CLOSE can set at any time. It is never cleared.
@@ -227,22 +227,22 @@ svc_sock_wspace(struct svc_sock *svsk)
  * processes, wake 'em up.
  *
  */
-static void
-svc_sock_enqueue(struct svc_sock *svsk)
+void
+svc_xprt_enqueue(struct svc_xprt *xprt)
 {
-	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	struct svc_serv	*serv = xprt->xpt_server;
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
 
-	if (!(svsk->sk_xprt.xpt_flags &
+	if (!(xprt->xpt_flags &
 	      ( (1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED)) ))
 		return;
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		return;
 
 	cpu = get_cpu();
-	pool = svc_pool_for_cpu(svsk->sk_xprt.xpt_server, cpu);
+	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
 	put_cpu();
 
 	spin_lock_bh(&pool->sp_lock);
@@ -250,11 +250,11 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!list_empty(&pool->sp_threads) &&
 	    !list_empty(&pool->sp_sockets))
 		printk(KERN_ERR
-			"svc_sock_enqueue: threads and sockets both waiting??\n");
+			"svc_xprt_enqueue: threads and sockets both waiting??\n");
 
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags)) {
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
 		/* Don't enqueue dead sockets */
-		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
+		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
 		goto out_unlock;
 	}
 
@@ -263,28 +263,28 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	 * on the idle list.  We update XPT_BUSY atomically because
 	 * it also guards against trying to enqueue the svc_sock twice.
 	 */
-	if (test_and_set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags)) {
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
 		/* Don't enqueue socket while already enqueued */
-		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
+		dprintk("svc: transport %p busy, not enqueued\n", xprt);
 		goto out_unlock;
 	}
-	BUG_ON(svsk->sk_xprt.xpt_pool != NULL);
-	svsk->sk_xprt.xpt_pool = pool;
+	BUG_ON(xprt->xpt_pool != NULL);
+	xprt->xpt_pool = pool;
 
 	/* Handle pending connection */
-	if (test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags))
+	if (test_bit(XPT_CONN, &xprt->xpt_flags))
 		goto process;
 
 	/* Handle close in-progress */
-	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags))
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
 		goto process;
 
 	/* Check if we have space to reply to a request */
-	if (!svsk->sk_xprt.xpt_ops.xpo_has_wspace(&svsk->sk_xprt)) {
+	if (!xprt->xpt_ops.xpo_has_wspace(xprt)) {
 		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
-		svsk->sk_xprt.xpt_pool = NULL;
-		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
+		dprintk("svc: no write space, transport %p  not enqueued\n", xprt);
+		xprt->xpt_pool = NULL;
+		clear_bit(XPT_BUSY, &xprt->xpt_flags);
 		goto out_unlock;
 	}
 
@@ -293,28 +293,29 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
 				   rq_list);
-		dprintk("svc: socket %p served by daemon %p\n",
-			svsk->sk_sk, rqstp);
+		dprintk("svc: transport %p served by daemon %p\n",
+			xprt, rqstp);
 		svc_thread_dequeue(pool, rqstp);
-		if (rqstp->rq_sock)
+		if (rqstp->rq_xprt)
 			printk(KERN_ERR
-				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
-				rqstp, rqstp->rq_sock);
-		rqstp->rq_sock = svsk;
-		svc_xprt_get(&svsk->sk_xprt);
+				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
+				rqstp, rqstp->rq_xprt);
+		rqstp->rq_xprt = xprt;
+		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
-		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+		BUG_ON(xprt->xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
-		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
-		list_add_tail(&svsk->sk_xprt.xpt_ready, &pool->sp_sockets);
-		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
+		dprintk("svc: transport %p put into queue\n", xprt);
+		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
+		BUG_ON(xprt->xpt_pool != pool);
 	}
 
 out_unlock:
 	spin_unlock_bh(&pool->sp_lock);
 }
+EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 
 /*
  * Dequeue the first socket.  Must be called with the pool->sp_lock held.
@@ -348,7 +349,7 @@ svc_sock_received(struct svc_sock *svsk)
 {
 	svsk->sk_xprt.xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
-	svc_sock_enqueue(svsk);
+	svc_xprt_enqueue(&svsk->sk_xprt);
 }
 
 
@@ -367,11 +368,11 @@ void svc_reserve(struct svc_rqst *rqstp,
 	space += rqstp->rq_res.head[0].iov_len;
 
 	if (space < rqstp->rq_reserved) {
-		struct svc_sock *svsk = rqstp->rq_sock;
-		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_xprt.xpt_reserved);
+		struct svc_xprt *xprt = rqstp->rq_xprt;
+		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
 		rqstp->rq_reserved = space;
 
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(xprt);
 	}
 }
 
@@ -698,7 +699,7 @@ svc_udp_data_ready(struct sock *sk, int 
 		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
 			svsk, sk, count, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
@@ -715,7 +716,7 @@ svc_write_space(struct sock *sk)
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), write_space busy=%d\n",
 			svsk, sk, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
@@ -990,7 +991,7 @@ svc_tcp_listen_data_ready(struct sock *s
 	if (sk->sk_state == TCP_LISTEN) {
 		if (svsk) {
 			set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
-			svc_sock_enqueue(svsk);
+			svc_xprt_enqueue(&svsk->sk_xprt);
 		} else
 			printk("svc: socket %p: no user data\n", sk);
 	}
@@ -1014,7 +1015,7 @@ svc_tcp_state_change(struct sock *sk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_all(sk->sk_sleep);
@@ -1029,7 +1030,7 @@ svc_tcp_data_ready(struct sock *sk, int 
 		sk, sk->sk_user_data);
 	if (svsk) {
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
@@ -1082,7 +1083,7 @@ svc_tcp_accept(struct svc_xprt *xprt)
 	}
 
 	set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
-	svc_sock_enqueue(svsk);
+	svc_xprt_enqueue(&svsk->sk_xprt);
 
 	err = kernel_getpeername(newsock, sin, &slen);
 	if (err < 0) {
@@ -1318,7 +1319,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
 		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
-		svc_sock_enqueue(rqstp->rq_sock);
+		svc_xprt_enqueue(rqstp->rq_xprt);
 		sent = -EAGAIN;
 	}
 	return sent;
@@ -1495,7 +1496,7 @@ svc_check_conn_limits(struct svc_serv *s
 		spin_unlock_bh(&serv->sv_lock);
 
 		if (svsk) {
-			svc_sock_enqueue(svsk);
+			svc_xprt_enqueue(&svsk->sk_xprt);
 			svc_xprt_put(&svsk->sk_xprt);
 		}
 	}
@@ -1728,7 +1729,7 @@ svc_age_temp_sockets(unsigned long closu
 			svsk, get_seconds() - svsk->sk_lastrecv);
 
 		/* a thread will dequeue and close it soon */
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 		svc_xprt_put(&svsk->sk_xprt);
 	}
 
@@ -2022,7 +2023,7 @@ static void svc_revisit(struct cache_def
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
 	spin_unlock(&svsk->sk_lock);
 	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	svc_sock_enqueue(svsk);
+	svc_xprt_enqueue(&svsk->sk_xprt);
 	svc_xprt_put(&svsk->sk_xprt);
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
