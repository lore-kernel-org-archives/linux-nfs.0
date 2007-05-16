From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Thu, 17 May 2007 05:22:11 +1000
Message-ID: <20070516192211.GJ9626@sgi.com>
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
	id 1HoP4h-0000KY-7q
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:22:15 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18Pv0Zy5BY+3Oxhzw02xGERnUBTt2GOUPE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoP4i-0001R3-RQ
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:22:18 -0700
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


Move the code in svc_sock_enqueue() that checks for available
write space on the socket, into a new sko_has_wspace method
in svc_sock_ops.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    4 +
 net/sunrpc/svcsock.c           |   74 +++++++++++++++++-------------
 2 files changed, 48 insertions(+), 30 deletions(-)

Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 00:36:20.381217499 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 00:49:50.820303639 +1000
@@ -204,22 +204,6 @@ svc_release_skb(struct svc_rqst *rqstp)
 }
 
 /*
- * Any space to write?
- */
-static inline unsigned long
-svc_sock_wspace(struct svc_sock *svsk)
-{
-	int wspace;
-
-	if (svsk->sk_sock->type == SOCK_STREAM)
-		wspace = sk_stream_wspace(svsk->sk_sk);
-	else
-		wspace = sock_wspace(svsk->sk_sk);
-
-	return wspace;
-}
-
-/*
  * Queue up a socket with data pending. If there are idle nfsd
  * processes, wake 'em up.
  *
@@ -268,21 +252,15 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	BUG_ON(svsk->sk_pool != NULL);
 	svsk->sk_pool = pool;
 
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
-	     > svc_sock_wspace(svsk))
+	if (svsk->sk_ops->sko_has_wspace
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
-		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
-			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
-			svc_sock_wspace(svsk));
-		svsk->sk_pool = NULL;
-		clear_bit(SK_BUSY, &svsk->sk_flags);
-		goto out_unlock;
+		if (!svsk->sk_ops->sko_has_wspace(svsk)) {
+			svsk->sk_pool = NULL;
+			clear_bit(SK_BUSY, &svsk->sk_flags);
+			goto out_unlock;
+		}
 	}
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-
 
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
@@ -904,13 +882,42 @@ svc_tcpip_prepare_reply(struct svc_rqst 
 	return 0;
 }
 
+/**
+ * svc_sock_has_write_space - Checks if there is enough space
+ * to send the reply on the socket.
+ * @svsk: the svc_sock to write on
+ * @wspace: the number of bytes available for writing
+ */
+static int svc_sock_has_write_space(struct svc_sock *svsk, int wspace)
+{
+	struct svc_serv	*serv = svsk->sk_server;
+	int required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	if (required*2 > wspace) {
+		/* Don't enqueue while not enough space for reply */
+		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
+			svsk->sk_sk, required, wspace);
+		return 0;
+	}
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 1;
+}
+
+static int
+svc_udp_has_wspace(struct svc_sock *svsk)
+{
+	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
+}
+
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_recvfrom = svc_udp_recvfrom,
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
-	.sko_prepare_reply = svc_tcpip_prepare_reply
+	.sko_prepare_reply = svc_tcpip_prepare_reply,
+	.sko_has_wspace = svc_udp_has_wspace
 };
 
 static void
@@ -1365,13 +1372,20 @@ svc_tcp_prepare_reply(struct svc_rqst *r
 	return 0;
 }
 
+static int
+svc_tcp_has_wspace(struct svc_sock *svsk)
+{
+	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
+}
+
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
-	.sko_prepare_reply = svc_tcp_prepare_reply
+	.sko_prepare_reply = svc_tcp_prepare_reply,
+	.sko_has_wspace = svc_tcp_has_wspace
 };
 
 static void
Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 00:36:20.553194321 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 00:46:47.944827892 +1000
@@ -33,6 +33,10 @@ struct svc_sock_ops {
 	 * fail, e.g. due to memory allocation.
 	 */
 	int                     (*sko_prepare_reply)(struct svc_rqst *);
+	/*
+	 * Return 1 if sufficient space to write reply to network.
+	 */
+	int			(*sko_has_wspace)(struct svc_sock *);
 };
 
 /*
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
