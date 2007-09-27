From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 27/33] svc: Make svc_recv transport neutral
Date: Thu, 27 Sep 2007 00:02:31 -0500
Message-ID: <20070927050231.12677.71841.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalW6-0005jK-RM
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:26 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWB-0005U9-DZ
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


All of the transport field and functions used by svc_recv are now
transport independent. Change the svc_recv function to use the svc_xprt
structure directly instead of the transport specific svc_sock structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    1 +
 net/sunrpc/svcsock.c  |   65 ++++++++++++++++++++++++-------------------------
 2 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 14cd288..8d87b6a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -117,6 +117,7 @@ void svc_xprt_init(struct svc_xprt_class
 	INIT_LIST_HEAD(&xpt->xpt_deferred);
 	mutex_init(&xpt->xpt_mutex);
 	spin_lock_init(&xpt->xpt_lock);
+	xpt->xpt_lastrecv = get_seconds();
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 89f345d..f5da434 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -320,22 +320,22 @@ EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 /*
  * Dequeue the first socket.  Must be called with the pool->sp_lock held.
  */
-static inline struct svc_sock *
-svc_sock_dequeue(struct svc_pool *pool)
+static inline struct svc_xprt *
+svc_xprt_dequeue(struct svc_pool *pool)
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
@@ -1500,7 +1500,7 @@ static void inline svc_copy_addr(struct 
 int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
-	struct svc_sock		*svsk = NULL;
+	struct svc_xprt		*xprt = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
@@ -1511,9 +1511,9 @@ svc_recv(struct svc_rqst *rqstp, long ti
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
@@ -1550,11 +1550,11 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		return -EINTR;
 
 	spin_lock_bh(&pool->sp_lock);
-	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
-		rqstp->rq_sock = svsk;
-		svc_xprt_get(&svsk->sk_xprt);
+	if ((xprt = svc_xprt_dequeue(pool)) != NULL) {
+		rqstp->rq_xprt = xprt;
+		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -1574,7 +1574,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
 
-		if (!(svsk = rqstp->rq_sock)) {
+		if (!(xprt = rqstp->rq_xprt)) {
 			svc_thread_dequeue(pool, rqstp);
 			spin_unlock_bh(&pool->sp_lock);
 			dprintk("svc: server %p, no data yet\n", rqstp);
@@ -1584,12 +1584,12 @@ svc_recv(struct svc_rqst *rqstp, long ti
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
-		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
+		newxpt = xprt->xpt_ops.xpo_accept(xprt);
 		if (newxpt) {
 			svc_xprt_received(newxpt);
 			/* 
@@ -1597,20 +1597,20 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			 * listener holds a reference too 
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
+			svc_check_conn_limits(xprt->xpt_server);
 		}			
-		svc_xprt_received(&svsk->sk_xprt);
+		svc_xprt_received(xprt);
 	} else {
-		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-			rqstp, pool->sp_id, svsk, 
-			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
+		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
+			rqstp, pool->sp_id, xprt, 
+			atomic_read(&xprt->xpt_ref.refcount));
 
-		if ((rqstp->rq_deferred = svc_deferred_dequeue(&svsk->sk_xprt))) {
-			svc_xprt_received(&svsk->sk_xprt);
+		if ((rqstp->rq_deferred = svc_deferred_dequeue(xprt))) {
+			svc_xprt_received(xprt);
 			len = svc_deferred_recv(rqstp);
 		} else 
-			len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
-		svc_copy_addr(rqstp, &svsk->sk_xprt);
+			len = xprt->xpt_ops.xpo_recvfrom(rqstp);
+		svc_copy_addr(rqstp, xprt);
 		dprintk("svc: got len=%d\n", len);
 	}
 
@@ -1620,8 +1620,8 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		svc_xprt_release(rqstp);
 		return -EAGAIN;
 	}
-	svsk->sk_xprt.xpt_lastrecv = get_seconds();
-	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
+	xprt->xpt_lastrecv = get_seconds();
+	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
@@ -1771,7 +1771,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	svsk->sk_xprt.xpt_lastrecv = get_seconds();
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM) {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
