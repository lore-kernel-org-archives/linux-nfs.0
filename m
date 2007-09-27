From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 17/33] svc: Make close transport independent
Date: Thu, 27 Sep 2007 00:02:10 -0500
Message-ID: <20070927050210.12677.66923.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVm-0005hF-1x
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:06 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVq-0001kb-E8
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:11 -0700
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


Move sk_list and sk_ready to svc_xprt. This involves close because these
lists are walked by svcs when closing all their transports. So I combined
the moving of these lists to svc_xprt with making close transport independent.

The svc_force_sock_close has been changed to svc_close_all and takes a list
as an argument. This removes some svc internals knowledge from the svcs. 

This code races with module removal and transport addition. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfssvc.c                |    4 +-
 include/linux/sunrpc/svc_xprt.h |    2 +
 include/linux/sunrpc/svcsock.h  |    4 --
 net/sunrpc/svc.c                |    9 +---
 net/sunrpc/svc_xprt.c           |    2 +
 net/sunrpc/svcsock.c            |  100 ++++++++++++++++++++-------------------
 6 files changed, 60 insertions(+), 61 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index bf70b06..4f6d6fd 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -155,8 +155,8 @@ static int killsig;	/* signal that was u
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
-	struct svc_sock *svsk;
-	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
+	struct svc_xprt *xprt;
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
 		lockd_down();
 	nfsd_serv = NULL;
 	nfsd_racache_shutdown();
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b850922..84e31bc 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -37,6 +37,8 @@ struct svc_xprt {
 	struct svc_xprt_ops	xpt_ops;
 	u32			xpt_max_payload;
 	struct kref		xpt_ref;
+	struct list_head	xpt_list;
+	struct list_head	xpt_ready;
 	unsigned long		xpt_flags;
 #define	XPT_BUSY	0			/* enqueued/receiving */
 #define	XPT_CONN	1			/* conn pending */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 92d4cc9..060508b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -17,8 +17,6 @@ #include <linux/sunrpc/svc_xprt.h>
  */
 struct svc_sock {
 	struct svc_xprt		sk_xprt;
-	struct list_head	sk_ready;	/* list of ready sockets */
-	struct list_head	sk_list;	/* list of all sockets */
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
@@ -51,7 +49,7 @@ struct svc_sock {
 /*
  * Function prototypes.
  */
-void		svc_force_close_socket(struct svc_sock *);
+void		svc_close_all(struct list_head *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ee68117..440ea59 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -458,9 +458,6 @@ svc_create_pooled(struct svc_program *pr
 void
 svc_destroy(struct svc_serv *serv)
 {
-	struct svc_sock	*svsk;
-	struct svc_sock *tmp;
-
 	dprintk("svc: svc_destroy(%s, %d)\n",
 				serv->sv_program->pg_name,
 				serv->sv_nrthreads);
@@ -475,14 +472,12 @@ svc_destroy(struct svc_serv *serv)
 
 	del_timer_sync(&serv->sv_temptimer);
 
-	list_for_each_entry_safe(svsk, tmp, &serv->sv_tempsocks, sk_list)
-		svc_force_close_socket(svsk);
+	svc_close_all(&serv->sv_tempsocks);
 
 	if (serv->sv_shutdown)
 		serv->sv_shutdown(serv);
 
-	list_for_each_entry_safe(svsk, tmp, &serv->sv_permsocks, sk_list)
-		svc_force_close_socket(svsk);
+	svc_close_all(&serv->sv_permsocks);
 
 	BUG_ON(!list_empty(&serv->sv_permsocks));
 	BUG_ON(!list_empty(&serv->sv_tempsocks));
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e1a9378..c5eaf8b 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -109,6 +109,8 @@ void svc_xprt_init(struct svc_xprt_class
 	xpt->xpt_max_payload = xcl->xcl_max_payload;
 	kref_init(&xpt->xpt_ref);
 	xpt->xpt_server = serv;
+	INIT_LIST_HEAD(&xpt->xpt_list);
+	INIT_LIST_HEAD(&xpt->xpt_ready);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 625e31c..be73044 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -79,11 +79,11 @@ #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int *errp, int flags);
-static void		svc_delete_socket(struct svc_sock *svsk);
+static void		svc_delete_xprt(struct svc_xprt *xprt);
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
-static void		svc_close_socket(struct svc_sock *svsk);
+static void		svc_close_xprt(struct svc_xprt *xprt);
 static void		svc_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
@@ -308,7 +308,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
-		list_add_tail(&svsk->sk_ready, &pool->sp_sockets);
+		list_add_tail(&svsk->sk_xprt.xpt_ready, &pool->sp_sockets);
 		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 	}
 
@@ -328,8 +328,8 @@ svc_sock_dequeue(struct svc_pool *pool)
 		return NULL;
 
 	svsk = list_entry(pool->sp_sockets.next,
-			  struct svc_sock, sk_ready);
-	list_del_init(&svsk->sk_ready);
+			  struct svc_sock, sk_xprt.xpt_ready);
+	list_del_init(&svsk->sk_xprt.xpt_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
 		svsk->sk_sk, atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
@@ -587,7 +587,7 @@ svc_sock_names(char *buf, struct svc_ser
 	if (!serv)
 		return 0;
 	spin_lock_bh(&serv->sv_lock);
-	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list) {
+	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list) {
 		int onelen = one_sock_name(buf+len, svsk);
 		if (toclose && strcmp(toclose, buf+len) == 0)
 			closesk = svsk;
@@ -599,7 +599,7 @@ svc_sock_names(char *buf, struct svc_ser
 		/* Should unregister with portmap, but you cannot
 		 * unregister just one protocol...
 		 */
-		svc_close_socket(closesk);
+		svc_close_xprt(&closesk->sk_xprt);
 	else if (toclose)
 		return -ENOENT;
 	return len;
@@ -1275,7 +1275,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	return len;
 
  err_delete:
-	svc_delete_socket(svsk);
+	svc_delete_xprt(&svsk->sk_xprt);
 	return -EAGAIN;
 
  error:
@@ -1441,12 +1441,12 @@ svc_sock_update_bufs(struct svc_serv *se
 	spin_lock_bh(&serv->sv_lock);
 	list_for_each(le, &serv->sv_permsocks) {
 		struct svc_sock *svsk =
-			list_entry(le, struct svc_sock, sk_list);
+			list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 	}
 	list_for_each(le, &serv->sv_tempsocks) {
 		struct svc_sock *svsk =
-			list_entry(le, struct svc_sock, sk_list);
+			list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
@@ -1488,7 +1488,7 @@ svc_check_conn_limits(struct svc_serv *s
 			 */
 			svsk = list_entry(serv->sv_tempsocks.prev,
 					  struct svc_sock,
-					  sk_list);
+					  sk_xprt.xpt_list);
 			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 			svc_xprt_get(&svsk->sk_xprt);
 		}
@@ -1595,7 +1595,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	len = 0;
 	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_socket(svsk);
+		svc_delete_xprt(&svsk->sk_xprt);
 	} else if (test_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
@@ -1704,7 +1704,7 @@ svc_age_temp_sockets(unsigned long closu
 	}
 
 	list_for_each_safe(le, next, &serv->sv_tempsocks) {
-		svsk = list_entry(le, struct svc_sock, sk_list);
+		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
 		if (!test_and_set_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags))
 			continue;
@@ -1720,9 +1720,9 @@ svc_age_temp_sockets(unsigned long closu
 
 	while (!list_empty(&to_be_aged)) {
 		le = to_be_aged.next;
-		/* fiddling the sk_list node is safe 'cos we're XPT_DETACHED */
+		/* fiddling the sk_xprt.xpt_list node is safe 'cos we're XPT_DETACHED */
 		list_del_init(le);
-		svsk = list_entry(le, struct svc_sock, sk_list);
+		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
 		dprintk("queuing svsk %p for closing, %lu seconds old\n",
 			svsk, get_seconds() - svsk->sk_lastrecv);
@@ -1776,7 +1776,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
-	INIT_LIST_HEAD(&svsk->sk_ready);
 	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
@@ -1791,7 +1790,7 @@ static struct svc_sock *svc_setup_socket
 	spin_lock_bh(&serv->sv_lock);
 	if (is_temporary) {
 		set_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_list, &serv->sv_tempsocks);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
 			/* setup timer to age temp sockets */
@@ -1802,7 +1801,7 @@ static struct svc_sock *svc_setup_socket
 		}
 	} else {
 		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_list, &serv->sv_permsocks);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
@@ -1937,66 +1936,69 @@ svc_sock_free(struct svc_xprt *xprt)
 }
 
 /*
- * Remove a dead socket
+ * Remove a dead transport
  */
 static void
-svc_delete_socket(struct svc_sock *svsk)
+svc_delete_xprt(struct svc_xprt *xprt)
 {
 	struct svc_serv	*serv;
-	struct sock	*sk;
 
-	dprintk("svc: svc_delete_socket(%p)\n", svsk);
+	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
 
-	serv = svsk->sk_xprt.xpt_server;
-	sk = svsk->sk_sk;
+	serv = xprt->xpt_server;
 
-	svsk->sk_xprt.xpt_ops.xpo_detach(&svsk->sk_xprt);
+	xprt->xpt_ops.xpo_detach(xprt);
 
 	spin_lock_bh(&serv->sv_lock);
 
-	if (!test_and_set_bit(XPT_DETACHED, &svsk->sk_xprt.xpt_flags))
-		list_del_init(&svsk->sk_list);
+	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
+		list_del_init(&xprt->xpt_list);
 	/*
-	 * We used to delete the svc_sock from whichever list
-	 * it's sk_ready node was on, but we don't actually
+	 * We used to delete the transport from whichever list
+	 * it's sk_xprt.xpt_ready node was on, but we don't actually
 	 * need to.  This is because the only time we're called
 	 * while still attached to a queue, the queue itself
 	 * is about to be destroyed (in svc_destroy).
 	 */
-	if (!test_and_set_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags)) {
-		BUG_ON(atomic_read(&svsk->sk_xprt.xpt_ref.refcount)<2);
-		svc_xprt_put(&svsk->sk_xprt);
-		if (test_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags))
+	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
+		BUG_ON(atomic_read(&xprt->xpt_ref.refcount)<2);
+		svc_xprt_put(xprt);
+		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 			serv->sv_tmpcnt--;
 	}
 
 	spin_unlock_bh(&serv->sv_lock);
 }
 
-static void svc_close_socket(struct svc_sock *svsk)
+static void svc_close_xprt(struct svc_xprt *xprt)
 {
-	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-	if (test_and_set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags))
+	set_bit(XPT_CLOSE, &xprt->xpt_flags);
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
 		/* someone else will have to effect the close */
 		return;
 
-	svc_xprt_get(&svsk->sk_xprt);
-	svc_delete_socket(svsk);
-	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
-	svc_xprt_put(&svsk->sk_xprt);
+	svc_xprt_get(xprt);
+	svc_delete_xprt(xprt);
+	clear_bit(XPT_BUSY, &xprt->xpt_flags);
+	svc_xprt_put(xprt);
 }
 
-void svc_force_close_socket(struct svc_sock *svsk)
+void svc_close_all(struct list_head *xprt_list)
 {
-	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-	if (test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags)) {
-		/* Waiting to be processed, but no threads left,
-		 * So just remove it from the waiting list
-		 */
-		list_del_init(&svsk->sk_ready);
-		clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
+	struct svc_xprt *xprt;
+	struct svc_xprt *tmp;
+
+	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		if (test_bit(XPT_BUSY, &xprt->xpt_flags)) {
+			/* Waiting to be processed, but no threads left,
+			 * So just remove it from the waiting list
+			 */
+			list_del_init(&xprt->xpt_ready);
+			clear_bit(XPT_BUSY, &xprt->xpt_flags);
+		}
+		svc_close_xprt(xprt);
 	}
-	svc_close_socket(svsk);
 }
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
