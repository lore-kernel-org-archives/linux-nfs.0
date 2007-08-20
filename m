From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 02/20] svc: xpt_detach and xpt_free
Date: Mon, 20 Aug 2007 11:23:25 -0500
Message-ID: <20070820162325.15224.71015.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2J-0006N4-N3
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:27 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2N-0005Hx-Fc
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:32 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id B49B27C79C
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:25 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
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


Add transport switch functions to ensure that no additional receive 
ready events will be delivered by the transport (xpt_detach), 
and another to free memory associated with the transport (xpt_free).
Change svc_delete_socket() and svc_sock_put() to use the new
transport functions.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |   12 ++++++++++
 net/sunrpc/svcsock.c           |   50 +++++++++++++++++++++++++++++++++-------
 2 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 4792ed6..27c5b1f 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -15,6 +15,18 @@ struct svc_xprt {
 	const char		*xpt_name;
 	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
 	int			(*xpt_sendto)(struct svc_rqst *rqstp);
+	/*
+	 * Detach the svc_sock from it's socket, so that the
+	 * svc_sock will not be enqueued any more.  This is
+	 * the first stage in the destruction of a svc_sock.
+	 */
+	void			(*xpt_detach)(struct svc_sock *);
+	/*
+	 * Release all network-level resources held by the svc_sock,
+	 * and the svc_sock itself.  This is the final stage in the
+	 * destruction of a svc_sock.
+	 */
+	void			(*xpt_free)(struct svc_sock *);
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 789d94a..4956c88 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -84,6 +84,8 @@ static void		svc_udp_data_ready(struct s
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_close_socket(struct svc_sock *svsk);
+static void		svc_sock_detach(struct svc_sock *);
+static void		svc_sock_free(struct svc_sock *);
 
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
+    	    	svsk->sk_xprt->xpt_free(svsk);
 	}
 }
 
@@ -889,6 +886,8 @@ static const struct svc_xprt svc_udp_xpr
 	.xpt_name = "udp",
 	.xpt_recvfrom = svc_udp_recvfrom,
 	.xpt_sendto = svc_udp_sendto,
+	.xpt_detach = svc_sock_detach,
+	.xpt_free = svc_sock_free,
 };
 
 static void
@@ -1331,6 +1330,8 @@ static const struct svc_xprt svc_tcp_xpr
 	.xpt_name = "tcp",
 	.xpt_recvfrom = svc_tcp_recvfrom,
 	.xpt_sendto = svc_tcp_sendto,
+	.xpt_detach = svc_sock_detach,
+	.xpt_free = svc_sock_free,
 };
 
 static void
@@ -1770,6 +1771,38 @@ bummer:
 }
 
 /*
+ * Detach the svc_sock from the socket so that no
+ * more callbacks occur.
+ */
+static void
+svc_sock_detach(struct svc_sock *svsk)
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
+svc_sock_free(struct svc_sock *svsk)
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
+	if (svsk->sk_xprt->xpt_detach)
+		svsk->sk_xprt->xpt_detach(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
