From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 10/20] svc: Add generic refcount services
Date: Tue, 10 Jul 2007 00:34:41 -0500
Message-ID: <20070710053441.28979.11952.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88N1-00074l-PV
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:43 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88N4-0004u8-No
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:47 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 53DD47C79C
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:41 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |   15 +++++++++++++++
 net/sunrpc/svcsock.c           |   29 ++++++++++++++---------------
 2 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index a52c9fd..e455783 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -115,6 +115,7 @@ int		svc_addsock(struct svc_serv *serv,
 			    int *proto);
 void		svc_sock_enqueue(struct svc_sock *svsk);
 void		svc_sock_received(struct svc_sock *svsk);
+void	    	__svc_sock_put(struct svc_sock *svsk);
 
 /*
  * svc_makesock socket characteristics
@@ -123,4 +124,18 @@ #define SVC_SOCK_DEFAULTS	(0U)
 #define SVC_SOCK_ANONYMOUS	(1U << 0)	/* don't register with pmap */
 #define SVC_SOCK_TEMPORARY	(1U << 1)	/* flag socket as temporary */
 
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
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 59c6b35..0193f54 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -273,7 +273,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		BUG_ON(svsk->sk_pool != pool);
@@ -351,17 +351,16 @@ void svc_reserve(struct svc_rqst *rqstp,
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
+EXPORT_SYMBOL(__svc_sock_put);
 
 static void
 svc_sock_release(struct svc_rqst *rqstp)
@@ -1109,7 +1108,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 					  struct svc_sock,
 					  sk_list);
 			set_bit(SK_CLOSE, &svsk->sk_flags);
-			atomic_inc(&svsk->sk_inuse);
+			svc_sock_get(svsk);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
@@ -1482,7 +1481,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_lock_bh(&pool->sp_lock);
 	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
 		rqstp->rq_sock = svsk;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
@@ -1621,7 +1620,7 @@ svc_age_temp_sockets(unsigned long closu
 			continue;
 		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
-		atomic_inc(&svsk->sk_inuse);
+		svc_sock_get(svsk);
 		list_move(le, &to_be_aged);
 		set_bit(SK_CLOSE, &svsk->sk_flags);
 		set_bit(SK_DETACHED, &svsk->sk_flags);
@@ -1869,7 +1868,7 @@ svc_delete_socket(struct svc_sock *svsk)
 	 */
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags)) {
 		BUG_ON(atomic_read(&svsk->sk_inuse)<2);
-		atomic_dec(&svsk->sk_inuse);
+		svc_sock_put(svsk);
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
 	}
@@ -1884,7 +1883,7 @@ static void svc_close_socket(struct svc_
 		/* someone else will have to effect the close */
 		return;
 
-	atomic_inc(&svsk->sk_inuse);
+	svc_sock_get(svsk);
 	svc_delete_socket(svsk);
 	clear_bit(SK_BUSY, &svsk->sk_flags);
 	svc_sock_put(svsk);
@@ -1977,7 +1976,7 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	atomic_inc(&rqstp->rq_sock->sk_inuse);
+	svc_sock_get(rqstp->rq_sock);
 	dr->svsk = rqstp->rq_sock;
 
 	dr->handle.revisit = svc_revisit;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
