From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 30/40] svc: Make svc_recv transport neutral
Date: Sun, 30 Dec 2007 21:08:16 -0600
Message-ID: <20071231030816.8430.39384.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41574 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752889AbXLaDIQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:16 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


All of the transport field and functions used by svc_recv are now
transport independent. Change the svc_recv function to use the svc_xprt
structure directly instead of the transport specific svc_sock structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   61 +++++++++++++++++++++++++-------------------------
 1 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 505336e..b3a64bf 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -310,22 +310,21 @@ EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 /*
  * Dequeue the first socket.  Must be called with the pool->sp_lock held.
  */
-static inline struct svc_sock *
-svc_sock_dequeue(struct svc_pool *pool)
+static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 {
-	struct svc_sock	*svsk;
+	struct svc_xprt	*xprt;
 
 	if (list_empty(&pool->sp_sockets))
 		return NULL;
 
-	svsk = list_entry(pool->sp_sockets.next,
-			  struct svc_sock, sk_xprt.xpt_ready);
-	list_del_init(&svsk->sk_xprt.xpt_ready);
+	xprt = list_entry(pool->sp_sockets.next,
+			  struct svc_xprt, xpt_ready);
+	list_del_init(&xprt->xpt_ready);
 
-	dprintk("svc: socket %p dequeued, inuse=%d\n",
-		svsk->sk_sk, atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
+	dprintk("svc: transport %p dequeued, inuse=%d\n",
+		xprt, atomic_read(&xprt->xpt_ref.refcount));
 
-	return svsk;
+	return xprt;
 }
 
 /*
@@ -1475,20 +1474,20 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
-	struct svc_sock		*svsk = NULL;
+	struct svc_xprt		*xprt = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
-	int 			pages;
+	int			pages;
 	struct xdr_buf		*arg;
 	DECLARE_WAITQUEUE(wait, current);
 
 	dprintk("svc: server %p waiting for data (to = %ld)\n",
 		rqstp, timeout);
 
-	if (rqstp->rq_sock)
+	if (rqstp->rq_xprt)
 		printk(KERN_ERR
-			"svc_recv: service %p, socket not NULL!\n",
+			"svc_recv: service %p, transport not NULL!\n",
 			 rqstp);
 	if (waitqueue_active(&rqstp->rq_wait))
 		printk(KERN_ERR
@@ -1525,11 +1524,12 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		return -EINTR;
 
 	spin_lock_bh(&pool->sp_lock);
-	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
-		rqstp->rq_sock = svsk;
-		svc_xprt_get(&svsk->sk_xprt);
+	xprt = svc_xprt_dequeue(pool);
+	if (xprt) {
+		rqstp->rq_xprt = xprt;
+		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -1549,7 +1549,8 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
 
-		if (!(svsk = rqstp->rq_sock)) {
+		xprt = rqstp->rq_xprt;
+		if (!xprt) {
 			svc_thread_dequeue(pool, rqstp);
 			spin_unlock_bh(&pool->sp_lock);
 			dprintk("svc: server %p, no data yet\n", rqstp);
@@ -1559,12 +1560,12 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags)) {
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(&svsk->sk_xprt);
-	} else if (test_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags)) {
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
-		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
+		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
 			/*
 			 * We know this module_get will succeed because the
@@ -1574,17 +1575,17 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
 			svc_xprt_received(newxpt);
 		}
-		svc_xprt_received(&svsk->sk_xprt);
+		svc_xprt_received(xprt);
 	} else {
-		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-			rqstp, pool->sp_id, svsk,
-			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
-		rqstp->rq_deferred = svc_deferred_dequeue(&svsk->sk_xprt);
+		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
+			rqstp, pool->sp_id, xprt,
+			atomic_read(&xprt->xpt_ref.refcount));
+		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred) {
-			svc_xprt_received(&svsk->sk_xprt);
+			svc_xprt_received(xprt);
 			len = svc_deferred_recv(rqstp);
 		} else
-			len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
+			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
 
@@ -1594,7 +1595,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		svc_xprt_release(rqstp);
 		return -EAGAIN;
 	}
-	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
+	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
