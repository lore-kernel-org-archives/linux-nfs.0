From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 11/14] knfsd: centralise SK_DATA handling
Date: Thu, 17 May 2007 05:27:03 +1000
Message-ID: <20070516192703.GQ9626@sgi.com>
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
	id 1HoP9M-0000sE-4e
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:27:04 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP9O-0004XP-3f
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:27:07 -0700
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


Centralise the handling of the SK_DATA bit to that future
sunrpc server transport implementations will be easier to
write correctly.  The bit should now not be manipulated
directly, inline exist to wrap that.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   22 ++++++++++++++++++++++
 net/sunrpc/svcsock.c           |   16 ++++++++--------
 2 files changed, 30 insertions(+), 8 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:37.023009680 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:41.298476262 +1000
@@ -172,4 +172,26 @@ static inline void svc_sock_set_connecti
 	set_bit(SK_CONN, &svsk->sk_flags);
 }
 
+/*
+ * For transport-specific code, to be called to clear the
+ * state that would otherwise result in a call to sko_recvfrom.
+ */
+static inline void svc_sock_clear_data_ready(struct svc_sock *svsk)
+{
+	clear_bit(SK_DATA, &svsk->sk_flags);
+}
+
+/*
+ * For transport-specific code, to be called on asynchronous
+ * notification of a data being available on a svc_sock.
+ * Enqueues the svc_sock so that an nfsd will eventually come
+ * along and call sko_recvfrom.  svc_sock_enqueue() or
+ * svc_sock_received() must be called soon afterward.
+ */
+
+static inline void svc_sock_set_data_ready(struct svc_sock *svsk)
+{
+	set_bit(SK_DATA, &svsk->sk_flags);
+}
+
 #endif /* SUNRPC_SVCSOCK_H */
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 03:04:37.218985230 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 03:05:29.776426277 +1000
@@ -671,7 +671,7 @@ svc_udp_data_ready(struct sock *sk, int 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
 			svsk, sk, count, test_bit(SK_BUSY, &svsk->sk_flags));
-		set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_set_data_ready(svsk);
 		svc_sock_enqueue(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
@@ -756,7 +756,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	clear_bit(SK_DATA, &svsk->sk_flags);
+	svc_sock_clear_data_ready(svsk);
 	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
 	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
@@ -778,7 +778,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		   need that much accuracy */
 	}
 	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
-	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
+	svc_sock_set_data_ready(svsk);
 
 	/*
 	 * Maybe more packets - kick another thread ASAP.
@@ -940,7 +940,7 @@ svc_udp_init(struct svc_sock *svsk)
 			    3 * svsk->sk_server->sv_max_mesg,
 			    3 * svsk->sk_server->sv_max_mesg);
 
-	set_bit(SK_DATA, &svsk->sk_flags); /* might have come in before data_ready set up */
+	svc_sock_set_data_ready(svsk); /* might have come in before data_ready set up */
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
 
 	oldfs = get_fs();
@@ -1013,7 +1013,7 @@ svc_tcp_data_ready(struct sock *sk, int 
 	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
 		sk, sk->sk_user_data);
 	if (svsk) {
-		set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_set_data_ready(svsk);
 		svc_sock_enqueue(svsk);
 	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
@@ -1198,7 +1198,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
 				    3 * serv->sv_max_mesg);
 
-	clear_bit(SK_DATA, &svsk->sk_flags);
+	svc_sock_clear_data_ready(svsk);
 
 	/* Receive data. If we haven't got the record length yet, get
 	 * the next four bytes. Otherwise try to gobble up as much as
@@ -1257,7 +1257,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return -EAGAIN;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
-	set_bit(SK_DATA, &svsk->sk_flags);
+	svc_sock_set_data_ready(svsk);
 
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
@@ -1421,7 +1421,7 @@ svc_tcp_init(struct svc_sock *svsk)
 				    3 * svsk->sk_server->sv_max_mesg);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
-		set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_set_data_ready(svsk);
 		if (sk->sk_state != TCP_ESTABLISHED) {
 			/* note: caller calls svc_sock_enqueue() */
 			svc_sock_set_close(svsk);
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
