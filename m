From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 11] knfsd: convert sk_inuse to atomic_t
Date: Mon, 31 Jul 2006 10:41:52 +1000
Message-ID: <1060731004152.29195@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Lr8-0003nk-01
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:02 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7Lr5-0001W3-Ff
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:02 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: Convert the svc_sock->sk_inuse counter from an int protected
by svc_serv->sv_lock, to an atomic.  This reduces the number of places
we need to take the (effectively global) svc_serv->sv_lock.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svcsock.c           |   29 +++++++++++------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-07-31 09:56:44.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-07-31 09:58:07.000000000 +1000
@@ -21,7 +21,7 @@ struct svc_sock {
 	struct sock *		sk_sk;		/* INET layer */
 
 	struct svc_serv *	sk_server;	/* service for this socket */
-	unsigned int		sk_inuse;	/* use count */
+	atomic_t		sk_inuse;	/* use count */
 	unsigned long		sk_flags;
 #define	SK_BUSY		0			/* enqueued/receiving */
 #define	SK_CONN		1			/* conn pending */

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-07-31 09:56:44.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-31 09:58:07.000000000 +1000
@@ -206,7 +206,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				"svc_sock_enqueue: server %p, rq_sock=%p!\n",
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
-		svsk->sk_inuse++;
+		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;
 		svsk->sk_reserved += rqstp->rq_reserved;
 		wake_up(&rqstp->rq_wait);
@@ -235,7 +235,7 @@ svc_sock_dequeue(struct svc_serv *serv)
 	list_del_init(&svsk->sk_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
-		svsk->sk_sk, svsk->sk_inuse);
+		svsk->sk_sk, atomic_read(&svsk->sk_inuse));
 
 	return svsk;
 }
@@ -285,17 +285,11 @@ void svc_reserve(struct svc_rqst *rqstp,
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
@@ -907,7 +901,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 					  struct svc_sock,
 					  sk_list);
 			set_bit(SK_CLOSE, &svsk->sk_flags);
-			svsk->sk_inuse ++;
+			atomic_inc(&svsk->sk_inuse);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
@@ -1239,7 +1233,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_lock_bh(&serv->sv_lock);
 	if ((svsk = svc_sock_dequeue(serv)) != NULL) {
 		rqstp->rq_sock = svsk;
-		svsk->sk_inuse++;
+		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;	
 		svsk->sk_reserved += rqstp->rq_reserved;
 	} else {
@@ -1271,7 +1265,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	spin_unlock_bh(&serv->sv_lock);
 
 	dprintk("svc: server %p, socket %p, inuse=%d\n",
-		 rqstp, svsk, svsk->sk_inuse);
+		 rqstp, svsk, atomic_read(&svsk->sk_inuse));
 	len = svsk->sk_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
@@ -1367,9 +1361,9 @@ svc_age_temp_sockets(unsigned long closu
 
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
@@ -1430,6 +1424,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
 	svsk->sk_server = serv;
+	atomic_set(&svsk->sk_inuse, 0);
 	svsk->sk_lastrecv = get_seconds();
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
@@ -1575,7 +1570,7 @@ svc_delete_socket(struct svc_sock *svsk)
 		if (test_bit(SK_TEMP, &svsk->sk_flags))
 			serv->sv_tmpcnt--;
 
-	if (!svsk->sk_inuse) {
+	if (!atomic_read(&svsk->sk_inuse)) {
 		spin_unlock_bh(&serv->sv_lock);
 		if (svsk->sk_sock->file)
 			sockfd_put(svsk->sk_sock);
@@ -1656,10 +1651,8 @@ svc_defer(struct cache_req *req)
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

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
