From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 8/14] knfsd: centralise SK_CLOSE handling
Date: Thu, 17 May 2007 05:25:09 +1000
Message-ID: <20070516192509.GN9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoP7X-0000iB-3t
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:25:11 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18yAK1ucY0eDr/ZL0SGnEXO5Zmvatk2eOc=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoP7Y-000431-4R
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:25:14 -0700
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


Centralise the handling of the SK_CLOSE bit to that future
sunrpc server transport implementations will be easier to
write correctly.  The bit should now not be manipulated
directly, inline exist to wrap that.  Also, the sko_recvfrom
method does not need to check for SK_CLOSE anymore, that's
handled in core code.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   23 ++++++++++++++++
 net/sunrpc/svcsock.c           |   42 +++++++++++++++---------------
 2 files changed, 44 insertions(+), 21 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 02:39:51.367033242 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:00:56.550481700 +1000
@@ -124,4 +124,27 @@ void		svc_sock_received(struct svc_sock 
 #define SVC_SOCK_ANONYMOUS	(1U << 0)	/* don't register with pmap */
 #define SVC_SOCK_TEMPORARY	(1U << 1)	/* flag socket as temporary */
 
+/*
+ * To delete a svc_sock, you must do one of two things.  In process
+ * (e.g. nfsd) context, you can call svc_delete_socket().  In other
+ * contexts (softirq, timers etc) call svc_sock_set_close() and
+ * then svc_sock_enqueue().  This enqueues the svc_sock so that an nfsd
+ * will eventually come along and call svc_delete_socket() for you.
+ */
+static inline void svc_sock_set_close(struct svc_sock *svsk)
+{
+	set_bit(SK_CLOSE, &svsk->sk_flags);
+}
+
+/*
+ * Convenience function for the common idiom of enqueuing
+ * a svc_sock for later deletion by an nfsd.  Useful for
+ * error handling in non-process context.
+ */
+static inline void svc_sock_delete_bh(struct svc_sock *svsk)
+{
+	svc_sock_set_close(svsk);
+	svc_sock_enqueue(svsk);
+}
+
 #endif /* SUNRPC_SVCSOCK_H */
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 02:40:30.597956980 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 03:01:15.048179452 +1000
@@ -756,11 +756,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		svc_delete_socket(svsk);
-		return 0;
-	}
-
 	clear_bit(SK_DATA, &svsk->sk_flags);
 	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
@@ -1003,8 +998,7 @@ svc_tcp_state_change(struct sock *sk)
 	if (!svsk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
-		set_bit(SK_CLOSE, &svsk->sk_flags);
-		svc_sock_enqueue(svsk);
+		svc_sock_delete_bh(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_all(sk->sk_sleep);
@@ -1139,13 +1133,16 @@ svc_tcp_accept(struct svc_sock *svsk)
 			svsk = list_entry(serv->sv_tempsocks.prev,
 					  struct svc_sock,
 					  sk_list);
-			set_bit(SK_CLOSE, &svsk->sk_flags);
 			atomic_inc(&svsk->sk_inuse);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
 		if (svsk) {
-			svc_sock_enqueue(svsk);
+			/*
+			 * We're always called in nfsd context so we
+			 * don't have to muck around with SK_CLOSE.
+			 */
+			svc_delete_socket(svsk);
 			svc_sock_put(svsk);
 		}
 
@@ -1183,11 +1180,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		svc_delete_socket(svsk);
-		return 0;
-	}
-
 	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
 		svc_tcp_accept(svsk);
 		svc_sock_received(svsk);
@@ -1433,8 +1425,10 @@ svc_tcp_init(struct svc_sock *svsk)
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 		set_bit(SK_DATA, &svsk->sk_flags);
-		if (sk->sk_state != TCP_ESTABLISHED)
-			set_bit(SK_CLOSE, &svsk->sk_flags);
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			/* note: caller calls svc_sock_enqueue() */
+			svc_sock_set_close(svsk);
+		}
 	}
 }
 
@@ -1552,10 +1546,16 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	}
 	spin_unlock_bh(&pool->sp_lock);
 
-	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_ops->sko_recvfrom(rqstp);
-	dprintk("svc: got len=%d\n", len);
+	len = 0;
+	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
+		dprintk("svc_recv: found SK_CLOSE\n");
+		svc_delete_socket(svsk);
+	} else {
+		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
+			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+		len = svsk->sk_ops->sko_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
@@ -1653,7 +1653,7 @@ svc_age_temp_sockets(unsigned long closu
 			continue;
 		atomic_inc(&svsk->sk_inuse);
 		list_move(le, &to_be_aged);
-		set_bit(SK_CLOSE, &svsk->sk_flags);
+		svc_sock_set_close(svsk);
 		set_bit(SK_DETACHED, &svsk->sk_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
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
