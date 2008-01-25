From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 065/100] svc: Make close transport independent
Date: Fri, 25 Jan 2008 18:16:45 -0500
Message-ID: <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47484 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165AbYAYXSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:04 -0500
In-Reply-To: <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Move sk_list and sk_ready to svc_xprt. This involves close because these
lists are walked by svcs when closing all their transports. So I combined
the moving of these lists to svc_xprt with making close transport independent.

The svc_force_sock_close has been changed to svc_close_all and takes a list
as an argument. This removes some svc internals knowledge from the svcs.

This code races with module removal and transport addition.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc.c                  |    6 +-
 fs/nfsd/nfssvc.c                |    4 +-
 include/linux/sunrpc/svc_xprt.h |    2 +
 include/linux/sunrpc/svcsock.h  |    4 +-
 net/sunrpc/svc.c                |    9 +---
 net/sunrpc/svc_xprt.c           |    2 +
 net/sunrpc/svcsock.c            |  102 +++++++++++++++++++--------------------
 7 files changed, 61 insertions(+), 68 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 8686915..a8e79a9 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -221,10 +221,10 @@ lockd(struct svc_rqst *rqstp)
 
 static int find_xprt(struct svc_serv *serv, char *proto)
 {
-	struct svc_sock *svsk;
+	struct svc_xprt *xprt;
 	int found = 0;
-	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
-		if (strcmp(svsk->sk_xprt.xpt_class->xcl_name, proto) == 0) {
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
+		if (strcmp(xprt->xpt_class->xcl_name, proto) == 0) {
 			found = 1;
 			break;
 		}
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a828b0b..9647b0f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -155,8 +155,8 @@ static int killsig;	/* signal that was used to kill last nfsd */
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
index 4042cdf..0a3e09b 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -36,6 +36,8 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	struct svc_xprt_ops	*xpt_ops;
 	struct kref		xpt_ref;
+	struct list_head	xpt_list;
+	struct list_head	xpt_ready;
 	unsigned long		xpt_flags;
 #define	XPT_BUSY	0		/* enqueued/receiving */
 #define	XPT_CONN	1		/* conn pending */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 92d4cc9..060508b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -17,8 +17,6 @@
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
index 3cc945d..be18734 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -458,9 +458,6 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
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
index ea17b53..95186b5 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -97,6 +97,8 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	xprt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xprt->xpt_ref);
 	xprt->xpt_server = serv;
+	INIT_LIST_HEAD(&xprt->xpt_list);
+	INIT_LIST_HEAD(&xprt->xpt_ready);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f86538e..6dffdda 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -81,11 +81,11 @@
 
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
 
@@ -293,7 +293,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
-		list_add_tail(&svsk->sk_ready, &pool->sp_sockets);
+		list_add_tail(&svsk->sk_xprt.xpt_ready, &pool->sp_sockets);
 		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 	}
 
@@ -313,8 +313,8 @@ svc_sock_dequeue(struct svc_pool *pool)
 		return NULL;
 
 	svsk = list_entry(pool->sp_sockets.next,
-			  struct svc_sock, sk_ready);
-	list_del_init(&svsk->sk_ready);
+			  struct svc_sock, sk_xprt.xpt_ready);
+	list_del_init(&svsk->sk_xprt.xpt_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
 		svsk->sk_sk, atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
@@ -572,7 +572,7 @@ svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 	if (!serv)
 		return 0;
 	spin_lock_bh(&serv->sv_lock);
-	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list) {
+	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list) {
 		int onelen = one_sock_name(buf+len, svsk);
 		if (toclose && strcmp(toclose, buf+len) == 0)
 			closesk = svsk;
@@ -584,7 +584,7 @@ svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 		/* Should unregister with portmap, but you cannot
 		 * unregister just one protocol...
 		 */
-		svc_close_socket(closesk);
+		svc_close_xprt(&closesk->sk_xprt);
 	else if (toclose)
 		return -ENOENT;
 	return len;
@@ -1427,12 +1427,12 @@ svc_sock_update_bufs(struct svc_serv *serv)
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
@@ -1469,7 +1469,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 			 */
 			svsk = list_entry(serv->sv_tempsocks.prev,
 					  struct svc_sock,
-					  sk_list);
+					  sk_xprt.xpt_list);
 			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 			svc_xprt_get(&svsk->sk_xprt);
 		}
@@ -1576,7 +1576,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	len = 0;
 	if (test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_socket(svsk);
+		svc_delete_xprt(&svsk->sk_xprt);
 	} else if (test_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
@@ -1685,7 +1685,7 @@ svc_age_temp_sockets(unsigned long closure)
 	}
 
 	list_for_each_safe(le, next, &serv->sv_tempsocks) {
-		svsk = list_entry(le, struct svc_sock, sk_list);
+		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
 		if (!test_and_set_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags))
 			continue;
@@ -1701,9 +1701,9 @@ svc_age_temp_sockets(unsigned long closure)
 
 	while (!list_empty(&to_be_aged)) {
 		le = to_be_aged.next;
-		/* fiddling the sk_list node is safe 'cos we're XPT_DETACHED */
+		/* fiddling the sk_xprt.xpt_list node is safe 'cos we're XPT_DETACHED */
 		list_del_init(le);
-		svsk = list_entry(le, struct svc_sock, sk_list);
+		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
 
 		dprintk("queuing svsk %p for closing, %lu seconds old\n",
 			svsk, get_seconds() - svsk->sk_lastrecv);
@@ -1757,7 +1757,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
-	INIT_LIST_HEAD(&svsk->sk_ready);
 	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
@@ -1769,7 +1768,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	spin_lock_bh(&serv->sv_lock);
 	if (is_temporary) {
 		set_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_list, &serv->sv_tempsocks);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
 			/* setup timer to age temp sockets */
@@ -1780,7 +1779,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		}
 	} else {
 		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_list, &serv->sv_permsocks);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
@@ -1912,66 +1911,63 @@ static void svc_sock_free(struct svc_xprt *xprt)
 }
 
 /*
- * Remove a dead socket
+ * Remove a dead transport
  */
-static void
-svc_delete_socket(struct svc_sock *svsk)
+static void svc_delete_xprt(struct svc_xprt *xprt)
 {
-	struct svc_serv	*serv;
-	struct sock	*sk;
-
-	dprintk("svc: svc_delete_socket(%p)\n", svsk);
-
-	serv = svsk->sk_xprt.xpt_server;
-	sk = svsk->sk_sk;
+	struct svc_serv	*serv = xprt->xpt_server;
 
-	svsk->sk_xprt.xpt_ops->xpo_detach(&svsk->sk_xprt);
+	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
+	xprt->xpt_ops->xpo_detach(xprt);
 
 	spin_lock_bh(&serv->sv_lock);
-
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
-		BUG_ON(atomic_read(&svsk->sk_xprt.xpt_ref.refcount) < 2);
-		if (test_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags))
+	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
+		BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
+		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 			serv->sv_tmpcnt--;
 		svc_xprt_put(&svsk->sk_xprt);
 	}
-
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
-- 
1.5.4.rc2.60.gb2e62

