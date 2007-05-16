From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 9/14] knfsd: centralise SK_CONN handling
Date: Thu, 17 May 2007 05:25:54 +1000
Message-ID: <20070516192554.GO9626@sgi.com>
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
	id 1HoP8F-0000jN-IF
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:25:55 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+BmFDwzG7jXpsxAI9P+iKK/taLYxnVRlU=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoP8I-0002eB-4q
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:25:58 -0700
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


Centralise the handling of the SK_CONN bit to that future
sunrpc server transport implementations will be easier to
write correctly.  The bit should now not be manipulated
directly, inline exist to wrap that.  Also, the sko_recvfrom
method does not need to check for SK_CONN anymore, that's
handled in core code which calls a new sko_accept method.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   24 +++++++++++++++++++++
 net/sunrpc/svcsock.c           |   34 +++++++++++++++---------------
 2 files changed, 41 insertions(+), 17 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 03:00:56.550481700 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:04:33.479451764 +1000
@@ -43,6 +43,10 @@ struct svc_sock_ops {
 	 * svc_sock.
 	 */
 	u32			(*sko_max_payload)(struct svc_sock *);
+	/*
+	 * Accept a pending connection, for connection-oriented transports
+	 */
+	int			(*sko_accept)(struct svc_sock *svsk);
 };
 
 /*
@@ -147,4 +151,24 @@ static inline void svc_sock_delete_bh(st
 	svc_sock_enqueue(svsk);
 }
 
+/*
+ * For transport-specific code, to be called to clear the
+ * state that would otherwise result in a call to sko_accept.
+ */
+static inline void svc_sock_clear_connection_ready(struct svc_sock *svsk)
+{
+	clear_bit(SK_CONN, &svsk->sk_flags);
+}
+
+/*
+ * For transport-specific code, to be called on asynchronous
+ * notification of a connection attempt on a rendezvous socket.
+ * svc_sock_enqueue() should be called to enqueue the svc_sock
+ * so that an nfsd will eventually come along and call sko_accept.
+ */
+static inline void svc_sock_set_connection_ready(struct svc_sock *svsk)
+{
+	set_bit(SK_CONN, &svsk->sk_flags);
+}
+
 #endif /* SUNRPC_SVCSOCK_H */
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 03:01:15.048179452 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 03:04:33.479451764 +1000
@@ -919,6 +919,7 @@ static const struct svc_sock_ops svc_udp
 	.sko_prepare_reply = svc_tcpip_prepare_reply,
 	.sko_has_wspace = svc_udp_has_wspace,
 	.sko_max_payload = svc_udp_max_payload
+	/* no .sko_accept, obviously */
 };
 
 static void
@@ -974,7 +975,7 @@ svc_tcp_listen_data_ready(struct sock *s
 	 */
 	if (sk->sk_state == TCP_LISTEN) {
 		if (svsk) {
-			set_bit(SK_CONN, &svsk->sk_flags);
+			svc_sock_set_connection_ready(svsk);
 			svc_sock_enqueue(svsk);
 		} else
 			printk("svc: socket %p: no user data\n", sk);
@@ -1036,7 +1037,7 @@ static inline int svc_port_is_privileged
 /*
  * Accept a TCP connection
  */
-static void
+static int
 svc_tcp_accept(struct svc_sock *svsk)
 {
 	struct sockaddr_storage addr;
@@ -1045,14 +1046,14 @@ svc_tcp_accept(struct svc_sock *svsk)
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
-	int		err, slen;
+	int		err = 0, slen;
 	char		buf[RPC_MAX_ADDRBUFLEN];
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
-		return;
+		return -EINVAL;
 
-	clear_bit(SK_CONN, &svsk->sk_flags);
+	svc_sock_clear_connection_ready(svsk);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
 	if (err < 0) {
 		if (err == -ENOMEM)
@@ -1061,10 +1062,10 @@ svc_tcp_accept(struct svc_sock *svsk)
 		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		return;
+		return err;
 	}
 
-	set_bit(SK_CONN, &svsk->sk_flags);
+	svc_sock_clear_connection_ready(svsk);
 	svc_sock_enqueue(svsk);
 
 	err = kernel_getpeername(newsock, sin, &slen);
@@ -1151,11 +1152,11 @@ svc_tcp_accept(struct svc_sock *svsk)
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
-	return;
+	return 0;
 
 failed:
 	sock_release(newsock);
-	return;
+	return err;
 }
 
 /*
@@ -1180,12 +1181,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
-		svc_tcp_accept(svsk);
-		svc_sock_received(svsk);
-		return 0;
-	}
-
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
@@ -1389,7 +1384,8 @@ static const struct svc_sock_ops svc_tcp
 	.sko_free = svc_tcpip_free,
 	.sko_prepare_reply = svc_tcp_prepare_reply,
 	.sko_has_wspace = svc_tcp_has_wspace,
-	.sko_max_payload = svc_tcp_max_payload
+	.sko_max_payload = svc_tcp_max_payload,
+	.sko_accept = svc_tcp_accept
 };
 
 static void
@@ -1403,7 +1399,7 @@ svc_tcp_init(struct svc_sock *svsk)
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
-		set_bit(SK_CONN, &svsk->sk_flags);
+		svc_sock_set_connection_ready(svsk);
 	} else {
 		dprintk("setting up TCP socket for reading\n");
 		sk->sk_state_change = svc_tcp_state_change;
@@ -1550,6 +1546,9 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
+		svsk->sk_ops->sko_accept(svsk);
+		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
@@ -1689,6 +1688,7 @@ static struct svc_sock *svc_setup_socket
 	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
+	*errp = 0;
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
 		*errp = -ENOMEM;
 		return NULL;
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
