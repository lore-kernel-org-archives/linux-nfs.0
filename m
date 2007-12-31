From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 21/40] svc: Make the enqueue service transport neutral and export it.
Date: Sun, 30 Dec 2007 21:07:57 -0600
Message-ID: <20071231030757.8430.59754.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41541 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752688AbXLaDH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:57 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_sock_enqueue function is now transport independent since all of
the fields it touches have been moved to the transport independent svc_xprt
structure. Change the function to use the svc_xprt structure directly
instead of the transport specific svc_sock structure.

Transport specific data-ready handlers need to call this function, so
export it.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   94 ++++++++++++++++++++++++++------------------------
 1 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ec5ad81..f356c02 100644
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
@@ -63,7 +63,7 @@
  *	providing that certain rules are followed:
  *
  *	XPT_CONN, XPT_DATA, can be set or cleared at any time.
- *		after a set, svc_sock_enqueue must be called.
+ *		after a set, svc_xprt_enqueue must be called.
  *		after a clear, the socket must be read/accepted
  *		 if this succeeds, it must be set again.
  *	XPT_CLOSE can set at any time. It is never cleared.
@@ -212,22 +212,21 @@ static void svc_release_skb(struct svc_rqst *rqstp)
  * processes, wake 'em up.
  *
  */
-static void
-svc_sock_enqueue(struct svc_sock *svsk)
+void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
-	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	struct svc_serv	*serv = xprt->xpt_server;
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
 
-	if (!(svsk->sk_xprt.xpt_flags &
+	if (!(xprt->xpt_flags &
 	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
 		return;
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		return;
 
 	cpu = get_cpu();
-	pool = svc_pool_for_cpu(svsk->sk_xprt.xpt_server, cpu);
+	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
 	put_cpu();
 
 	spin_lock_bh(&pool->sp_lock);
@@ -235,11 +234,12 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!list_empty(&pool->sp_threads) &&
 	    !list_empty(&pool->sp_sockets))
 		printk(KERN_ERR
-			"svc_sock_enqueue: threads and sockets both waiting??\n");
+		       "svc_xprt_enqueue: "
+		       "threads and transports both waiting??\n");
 
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags)) {
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
 		/* Don't enqueue dead sockets */
-		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
+		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
 		goto out_unlock;
 	}
 
@@ -248,28 +248,29 @@ svc_sock_enqueue(struct svc_sock *svsk)
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
-	if (!svsk->sk_xprt.xpt_ops->xpo_has_wspace(&svsk->sk_xprt)) {
+	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
 		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
-		svsk->sk_xprt.xpt_pool = NULL;
-		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
+		dprintk("svc: no write space, transport %p  not enqueued\n",
+			xprt);
+		xprt->xpt_pool = NULL;
+		clear_bit(XPT_BUSY, &xprt->xpt_flags);
 		goto out_unlock;
 	}
 
@@ -278,28 +279,29 @@ svc_sock_enqueue(struct svc_sock *svsk)
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
@@ -333,7 +335,7 @@ svc_sock_received(struct svc_sock *svsk)
 {
 	svsk->sk_xprt.xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
-	svc_sock_enqueue(svsk);
+	svc_xprt_enqueue(&svsk->sk_xprt);
 }
 
 
@@ -352,11 +354,11 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
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
 
@@ -684,7 +686,7 @@ svc_udp_data_ready(struct sock *sk, int count)
 			svsk, sk, count,
 			test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
@@ -701,7 +703,7 @@ svc_write_space(struct sock *sk)
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), write_space busy=%d\n",
 			svsk, sk, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
@@ -973,7 +975,7 @@ svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 	if (sk->sk_state == TCP_LISTEN) {
 		if (svsk) {
 			set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
-			svc_sock_enqueue(svsk);
+			svc_xprt_enqueue(&svsk->sk_xprt);
 		} else
 			printk("svc: socket %p: no user data\n", sk);
 	}
@@ -997,7 +999,7 @@ svc_tcp_state_change(struct sock *sk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_all(sk->sk_sleep);
@@ -1012,7 +1014,7 @@ svc_tcp_data_ready(struct sock *sk, int count)
 		sk, sk->sk_user_data);
 	if (svsk) {
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
@@ -1298,7 +1300,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
 		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
-		svc_sock_enqueue(rqstp->rq_sock);
+		svc_xprt_enqueue(rqstp->rq_xprt);
 		sent = -EAGAIN;
 	}
 	return sent;
@@ -1476,7 +1478,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 		spin_unlock_bh(&serv->sv_lock);
 
 		if (svsk) {
-			svc_sock_enqueue(svsk);
+			svc_xprt_enqueue(&svsk->sk_xprt);
 			svc_xprt_put(&svsk->sk_xprt);
 		}
 	}
@@ -1709,7 +1711,7 @@ svc_age_temp_sockets(unsigned long closure)
 			svsk, get_seconds() - svsk->sk_lastrecv);
 
 		/* a thread will dequeue and close it soon */
-		svc_sock_enqueue(svsk);
+		svc_xprt_enqueue(&svsk->sk_xprt);
 		svc_xprt_put(&svsk->sk_xprt);
 	}
 
@@ -1991,7 +1993,7 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
 	spin_unlock(&svsk->sk_lock);
 	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	svc_sock_enqueue(svsk);
+	svc_xprt_enqueue(&svsk->sk_xprt);
 	svc_xprt_put(&svsk->sk_xprt);
 }
 
