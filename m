From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 002 of 11] knfsd: convert sk_inuse to atomic_t
Date: Tue, 25 Jul 2006 15:06:53 +1000
Message-ID: <1153804013.21040.5.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5F8E-00036G-UV
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:06:58 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5F8F-0005yq-33
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:06:59 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: Convert the svc_sock->sk_inuse counter from an int protected
by svc_serv->sv_lock, to an atomic.  This reduces the number of places
we need to take the (effectively global) svc_serv->sv_lock.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    2 +-
 net/sunrpc/svcsock.c           |   29 +++++++++++------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

Index: linus-git/include/linux/sunrpc/svcsock.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svcsock.h	2006-07-24 16:11:01.433553624 +1000
+++ linus-git/include/linux/sunrpc/svcsock.h	2006-07-24 16:54:25.020894827 +1000
@@ -21,7 +21,7 @@ struct svc_sock {
 	struct sock *		sk_sk;		/* INET layer */
 
 	struct svc_serv *	sk_server;	/* service for this socket */
-	unsigned int		sk_inuse;	/* use count */
+	atomic_t		sk_inuse;	/* use count */
 	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */
Index: linus-git/net/sunrpc/svcsock.c
===================================================================
--- linus-git.orig/net/sunrpc/svcsock.c	2006-07-24 16:53:39.126813226 +1000
+++ linus-git/net/sunrpc/svcsock.c	2006-07-24 16:54:25.092885543 +1000
@@ -205,7 +205,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		svsk->sk_inuse++;
+		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;
 		svsk->sk_reserved += rqstp->rq_reserved;
 		wake_up(&rqstp->rq_wait);
@@ -234,7 +234,7 @@ svc_sock_dequeue(struct svc_serv *serv)
 	list_del_init(&svsk->sk_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
-		svsk->sk_sk, svsk->sk_inuse);
+		svsk->sk_sk, atomic_read(&svsk->sk_inuse));
 
 	return svsk;
 }
@@ -284,17 +284,11 @@ void svc_reserve(struct svc_rqst *rqstp,
 static inline void
 svc_sock_put(struct svc_sock *svsk)
 {
-	struct svc_serv *serv = svsk->sk_server;
-
-	spin_lock_bh(&serv->sv_lock);
-	if (!--(svsk->sk_inuse) && test_bit(SK_DEAD, &svsk->sk_flags)) {
-		spin_unlock_bh(&serv->sv_lock);
+	if (atomic_dec_and_test(&svsk->sk_inuse) && test_bit(SK_DEAD, &svsk->sk_flags)) {
 		dprintk("svc: releasing dead socket\n");
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	}
-	else
-		spin_unlock_bh(&serv->sv_lock);
 }
 
 static void
@@ -861,7 +855,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 					  struct svc_sock,
 					  sk_list);
 			set_bit(SK_CLOSE, &svsk->sk_flags);
-			svsk->sk_inuse ++;
+			atomic_inc(&svsk->sk_inuse);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
@@ -1192,7 +1186,7 @@ svc_recv(struct svc_serv *serv, struct s
 	spin_lock_bh(&serv->sv_lock);
 	if ((svsk = svc_sock_dequeue(serv)) != NULL) {
 		rqstp->rq_sock = svsk;
-		svsk->sk_inuse++;
+		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;	
 		svsk->sk_reserved += rqstp->rq_reserved;
 	} else {
@@ -1224,7 +1218,7 @@ svc_recv(struct svc_serv *serv, struct s
 	spin_unlock_bh(&serv->sv_lock);
 
 	dprintk("svc: server %p, socket %p, inuse=%d\n",
-		 rqstp, svsk, svsk->sk_inuse);
+		 rqstp, svsk, atomic_read(&svsk->sk_inuse));
 	len = svsk->sk_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
@@ -1320,9 +1314,9 @@ svc_age_temp_sockets(unsigned long closu
 
 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
 			continue;
-		if (svsk->sk_inuse || test_bit(SK_BUSY, &svsk->sk_flags))
+		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
-		svsk->sk_inuse++;
+		atomic_inc(&svsk->sk_inuse);
 		list_move(le, &to_be_aged);
 		set_bit(SK_CLOSE, &svsk->sk_flags);
 		set_bit(SK_DETACHED, &svsk->sk_flags);
@@ -1383,6 +1377,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_server = serv;
+	atomic_set(&svsk->sk_inuse, 0);
 	svsk->sk_lastrecv = get_seconds();
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
@@ -1496,7 +1491,7 @@ svc_delete_socket(struct svc_sock *svsk)
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
 
-	if (!svsk->sk_inuse) {
+	if (!atomic_read(&svsk->sk_inuse)) {
 		spin_unlock_bh(&serv->sv_lock);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
@@ -1574,10 +1569,8 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	spin_lock_bh(&rqstp->rq_server->sv_lock);
-	rqstp->rq_sock->sk_inuse++;
+	atomic_inc(&rqstp->rq_sock->sk_inuse);
 	dr->svsk = rqstp->rq_sock;
-	spin_unlock_bh(&rqstp->rq_server->sv_lock);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
