From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Thu, 17 May 2007 05:19:51 +1000
Message-ID: <20070516191951.GH9626@sgi.com>
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
	id 1HoP2S-0008U3-5N
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:19:56 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP2T-0000m3-K6
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:19:59 -0700
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


Add sko_detach and sko_free methods to svc_sock_ops and
change svc_delete_socket() and svc_sock_put() to use them.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   12 ++++++
 net/sunrpc/svcsock.c           |   54 +++++++++++++++++++++++-------
 2 files changed, 55 insertions(+), 11 deletions(-)

Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-16 23:50:21.721414451 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 00:16:39.911496313 +1000
@@ -83,6 +83,8 @@ static void		svc_udp_data_ready(struct s
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_close_socket(struct svc_sock *svsk);
+static void		svc_tcpip_detach(struct svc_sock *);
+static void		svc_tcpip_free(struct svc_sock *);
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -377,14 +379,9 @@ svc_sock_put(struct svc_sock *svsk)
 	if (atomic_dec_and_test(&svsk->sk_inuse)) {
 		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
 
-		dprintk("svc: releasing dead socket\n");
-		if (svsk->sk_sock->file)
-			sockfd_put(svsk->sk_sock);
-		else
-			sock_release(svsk->sk_sock);
 		if (svsk->sk_info_authunix != NULL)
 			svcauth_unix_info_release(svsk->sk_info_authunix);
-		kfree(svsk);
+    	    	svsk->sk_ops->sko_free(svsk);
 	}
 }
 
@@ -886,7 +883,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_recvfrom = svc_udp_recvfrom,
-	.sko_sendto = svc_udp_sendto
+	.sko_sendto = svc_udp_sendto,
+	.sko_detach = svc_tcpip_detach,
+	.sko_free = svc_tcpip_free
 };
 
 static void
@@ -1328,7 +1327,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
-	.sko_sendto = svc_tcp_sendto
+	.sko_sendto = svc_tcp_sendto,
+	.sko_detach = svc_tcpip_detach,
+	.sko_free = svc_tcpip_free
 };
 
 static void
@@ -1768,6 +1769,38 @@ bummer:
 }
 
 /*
+ * Detach the svc_sock from the socket so that no
+ * more callbacks occur.
+ */
+static void
+svc_tcpip_detach(struct svc_sock *svsk)
+{
+	struct sock *sk = svsk->sk_sk;
+
+	dprintk("svc: svc_sock_detach(%p)\n", svsk);
+
+	/* put back the old socket callbacks */
+	sk->sk_state_change = svsk->sk_ostate;
+	sk->sk_data_ready = svsk->sk_odata;
+	sk->sk_write_space = svsk->sk_owspace;
+}
+
+/*
+ * Free the svc_sock's socket resources and the svc_sock itself.
+ */
+static void
+svc_tcpip_free(struct svc_sock *svsk)
+{
+	dprintk("svc: svc_sock_free(%p)\n", svsk);
+
+	if (svsk->sk_sock->file)
+		sockfd_put(svsk->sk_sock);
+	else
+		sock_release(svsk->sk_sock);
+	kfree(svsk);
+}
+
+/*
  * Remove a dead socket
  */
 static void
@@ -1781,9 +1814,8 @@ svc_delete_socket(struct svc_sock *svsk)
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
 
-	sk->sk_state_change = svsk->sk_ostate;
-	sk->sk_data_ready = svsk->sk_odata;
-	sk->sk_write_space = svsk->sk_owspace;
+	if (svsk->sk_ops->sko_detach)
+		svsk->sk_ops->sko_detach(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
 
Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-16 23:50:21.637425405 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 00:12:50.074342601 +1000
@@ -15,6 +15,18 @@ struct svc_sock_ops {
 	const char		*sko_name;
 	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sko_sendto)(struct svc_rqst *rqstp);
+	/*
+	 * Detach the svc_sock from it's socket, so that the
+	 * svc_sock will not be enqueued any more.  This is
+	 * the first stage in the destruction of a svc_sock.
+	 */
+	void			(*sko_detach)(struct svc_sock *);
+	/*
+	 * Release all network-level resources held by the svc_sock,
+	 * and the svc_sock itself.  This is the final stage in the
+	 * destruction of a svc_sock.
+	 */
+	void			(*sko_free)(struct svc_sock *);
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
