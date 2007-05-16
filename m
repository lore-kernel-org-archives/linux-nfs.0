From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 12/14] knfsd: add svc_sock_get
Date: Thu, 17 May 2007 05:27:50 +1000
Message-ID: <20070516192750.GR9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoPA7-0000wE-Pk
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:27:54 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+IMoyWsNkSKO7YRxExbFdDlxunMKDVVlc=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoPAA-0003GN-De
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:27:54 -0700
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


Add inline svc_sock_get() so that service transport code will not
need to manipulate sk_inuse directly.  Also, make svc_sock_put()
available so that transport code outside svcsock.c can use it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   15 +++++++++++++++
 net/sunrpc/sunrpc_syms.c       |    1 +
 net/sunrpc/svcsock.c           |   28 +++++++++++++---------------
 3 files changed, 29 insertions(+), 15 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:41.298476262 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:19:26.626631647 +1000
@@ -121,6 +121,7 @@ int		svc_addsock(struct svc_serv *serv,
 			    int *proto);
 void		svc_sock_enqueue(struct svc_sock *svsk);
 void		svc_sock_received(struct svc_sock *svsk);
+void	    	__svc_sock_put(struct svc_sock *svsk);
 
 /*
  * svc_makesock socket characteristics
@@ -194,4 +195,18 @@ static inline void svc_sock_set_data_rea
 	set_bit(SK_DATA, &svsk->sk_flags);
 }
 
+/*
+ * Take and drop a temporary reference count on the svc_sock.
+ */
+static inline void svc_sock_get(struct svc_sock *svsk)
+{
+	atomic_inc(&svsk->sk_inuse);
+}
+
+static inline void svc_sock_put(struct svc_sock *svsk)
+{
+	if (atomic_dec_and_test(&svsk->sk_inuse))
+	    __svc_sock_put(svsk);
+}
+
 #endif /* SUNRPC_SVCSOCK_H */
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 03:05:29.776426277 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 03:24:02.438110603 +1000
@@ -274,7 +274,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		BUG_ON(svsk->sk_pool != pool);
@@ -351,16 +351,14 @@ void svc_reserve(struct svc_rqst *rqstp,
 /*
  * Release a socket after use.
  */
-static inline void
-svc_sock_put(struct svc_sock *svsk)
+void
+__svc_sock_put(struct svc_sock *svsk)
 {
-	if (atomic_dec_and_test(&svsk->sk_inuse)) {
-		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
+	BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
 
-		if (svsk->sk_info_authunix != NULL)
-			svcauth_unix_info_release(svsk->sk_info_authunix);
-    	    	svsk->sk_ops->sko_free(svsk);
-	}
+	if (svsk->sk_info_authunix != NULL)
+		svcauth_unix_info_release(svsk->sk_info_authunix);
+    	svsk->sk_ops->sko_free(svsk);
 }
 
 static void
@@ -1134,7 +1132,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 			svsk = list_entry(serv->sv_tempsocks.prev,
 					  struct svc_sock,
 					  sk_list);
-			atomic_inc(&svsk->sk_inuse);
+			svc_sock_get(svsk);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
@@ -1512,7 +1510,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_lock_bh(&pool->sp_lock);
 	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
@@ -1651,7 +1649,7 @@ svc_age_temp_sockets(unsigned long closu
 			continue;
 		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		list_move(le, &to_be_aged);
 		svc_sock_set_close(svsk);
 		set_bit(SK_DETACHED, &svsk->sk_flags);
@@ -1899,7 +1897,7 @@ svc_delete_socket(struct svc_sock *svsk)
 	 */
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
 		BUG_ON(atomic_read(&svsk->sk_inuse)<2);
-		atomic_dec(&svsk->sk_inuse);
+		svc_sock_put(svsk);
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
 	}
@@ -1914,7 +1912,7 @@ static void svc_close_socket(struct svc_
 		/* someone else will have to effect the close */
 		return;
 
-	atomic_inc(&svsk->sk_inuse);
+	svc_sock_get(svsk);
 	svc_delete_socket(svsk);
 	clear_bit(SK_BUSY, &svsk->sk_flags);
 	svc_sock_put(svsk);
@@ -2007,7 +2005,7 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	atomic_inc(&rqstp->rq_sock->sk_inuse);
+	svc_sock_get(rqstp->rq_sock);
 	dr->svsk = rqstp->rq_sock;
 
 	dr->handle.revisit = svc_revisit;
Index: linux/net/sunrpc/sunrpc_syms.c
===================================================================
--- linux.orig/net/sunrpc/sunrpc_syms.c	2007-05-17 02:09:47.000000000 +1000
+++ linux/net/sunrpc/sunrpc_syms.c	2007-05-17 03:20:08.785046921 +1000
@@ -80,6 +80,7 @@ EXPORT_SYMBOL(svc_makesock);
 EXPORT_SYMBOL_GPL(svc_sock_enqueue);
 EXPORT_SYMBOL_GPL(svc_sock_received);
 EXPORT_SYMBOL(svc_reserve);
+EXPORT_SYMBOL(__svc_sock_put);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
 EXPORT_SYMBOL(svc_authenticate);
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
