From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 1/14] knfsd: add transport ops
Date: Thu, 17 May 2007 05:19:06 +1000
Message-ID: <20070516191906.GG9626@sgi.com>
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
	id 1HoP1n-0008T9-Ry
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:19:15 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/xLHnkJkmlWb+JRYRDRAFDvyL/RhrAF9I=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoP1k-0002LT-BI
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:19:13 -0700
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


Start moving to a transport switch for knfsd.  Add a svc_sock_ops
operations vector and move the sk_sendto and sk_recvfrom function
pointers into it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    9 +++++++--
 net/sunrpc/svcsock.c           |   22 ++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-04-26 13:08:32.000000000 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-16 23:29:24.797243245 +1000
@@ -11,6 +11,12 @@
 
 #include <linux/sunrpc/svc.h>
 
+struct svc_sock_ops {
+	const char		*sko_name;
+	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
+	int			(*sko_sendto)(struct svc_rqst *rqstp);
+};
+
 /*
  * RPC server socket.
  */
@@ -42,8 +48,7 @@ struct svc_sock {
 						 * be revisted */
 	struct mutex		sk_mutex;	/* to serialize sending data */
 
-	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
-	int			(*sk_sendto)(struct svc_rqst *rqstp);
+	const struct svc_sock_ops *sk_ops;
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-04-26 13:08:32.000000000 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-16 23:29:24.961221880 +1000
@@ -883,6 +883,12 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static const struct svc_sock_ops svc_udp_ops = {
+	.sko_name = "udp",
+	.sko_recvfrom = svc_udp_recvfrom,
+	.sko_sendto = svc_udp_sendto
+};
+
 static void
 svc_udp_init(struct svc_sock *svsk)
 {
@@ -891,8 +897,7 @@ svc_udp_init(struct svc_sock *svsk)
 
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
-	svsk->sk_recvfrom = svc_udp_recvfrom;
-	svsk->sk_sendto = svc_udp_sendto;
+	svsk->sk_ops = &svc_udp_ops;
 
 	/* initialise setting must have enough space to
 	 * receive and respond to one request.
@@ -1320,14 +1325,19 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+static const struct svc_sock_ops svc_tcp_ops = {
+	.sko_name = "tcp",
+	.sko_recvfrom = svc_tcp_recvfrom,
+	.sko_sendto = svc_tcp_sendto
+};
+
 static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	svsk->sk_recvfrom = svc_tcp_recvfrom;
-	svsk->sk_sendto = svc_tcp_sendto;
+	svsk->sk_ops = &svc_tcp_ops;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
@@ -1475,7 +1485,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 
 	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_recvfrom(rqstp);
+	len = svsk->sk_ops->sko_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
 	/* No data, incomplete (TCP) read, or accept() */
@@ -1535,7 +1545,7 @@ svc_send(struct svc_rqst *rqstp)
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_sendto(rqstp);
+		len = svsk->sk_ops->sko_sendto(rqstp);
 	mutex_unlock(&svsk->sk_mutex);
 	svc_sock_release(rqstp);
 
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
