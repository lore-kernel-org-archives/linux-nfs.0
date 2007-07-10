From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 02/20] svc: sko_detach and sko_free
Date: Tue, 10 Jul 2007 00:34:24 -0500
Message-ID: <20070710053424.28979.54098.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mk-00073y-Jg
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:26 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mn-0003RV-TP
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:30 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 72B9E7C79E
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:24 -0500 (CDT)
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


Add sko_detach and sko_free methods to svc_sock_ops and
change svc_delete_socket() and svc_sock_put() to use them.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   12 +++++++++
 net/sunrpc/svcsock.c           |   54 ++++++++++++++++++++++++++++++++--------
 2 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 3c926b9..72beb7b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
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
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ce325f2..da7e5ea 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -84,6 +84,8 @@ static void		svc_udp_data_ready(struct s
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_close_socket(struct svc_sock *svsk);
+static void		svc_tcpip_detach(struct svc_sock *);
+static void		svc_tcpip_free(struct svc_sock *);
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -378,14 +380,9 @@ svc_sock_put(struct svc_sock *svsk)
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
 
@@ -888,7 +885,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_recvfrom = svc_udp_recvfrom,
-	.sko_sendto = svc_udp_sendto
+	.sko_sendto = svc_udp_sendto,
+	.sko_detach = svc_tcpip_detach,
+	.sko_free = svc_tcpip_free
 };
 
 static void
@@ -1330,7 +1329,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
-	.sko_sendto = svc_tcp_sendto
+	.sko_sendto = svc_tcp_sendto,
+	.sko_detach = svc_tcpip_detach,
+	.sko_free = svc_tcpip_free
 };
 
 static void
@@ -1770,6 +1771,38 @@ bummer:
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
@@ -1783,9 +1816,8 @@ svc_delete_socket(struct svc_sock *svsk)
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
 
-	sk->sk_state_change = svsk->sk_ostate;
-	sk->sk_data_ready = svsk->sk_odata;
-	sk->sk_write_space = svsk->sk_owspace;
+	if (svsk->sk_ops->sko_detach)
+		svsk->sk_ops->sko_detach(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
