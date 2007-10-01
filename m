From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 07/35] svc: Add per-transport delete functions
Date: Mon, 01 Oct 2007 14:27:45 -0500
Message-ID: <20071001192744.3250.68713.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQvi-0005VN-2z
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:27:46 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQvm-0000py-H1
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:27:51 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
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


Add transport specific xpo_detach and xpo_free functions. The xpo_detach
function causes the transport to stop delivering data-ready events 
and enqueing the transport for I/O.

The xpo_free function frees all resources associated with the particular 
transport instance.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 +
 net/sunrpc/svcsock.c            |   58 ++++++++++++++++++++++++++++++---------
 2 files changed, 47 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 5871faa..85d84b2 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -13,6 +13,8 @@ struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
 	void		(*xpo_release)(struct svc_rqst *);
+	void		(*xpo_detach)(struct svc_xprt *);
+	void		(*xpo_free)(struct svc_xprt *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2d5731c..cb13977 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -84,6 +84,8 @@ static void		svc_udp_data_ready(struct s
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_close_socket(struct svc_sock *svsk);
+static void		svc_sock_detach(struct svc_xprt *);
+static void		svc_sock_free(struct svc_xprt *);
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -376,16 +378,8 @@ static inline void
 svc_sock_put(struct svc_sock *svsk)
 {
 	if (atomic_dec_and_test(&svsk->sk_inuse)) {
-		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
-
-		dprintk("svc: releasing dead socket\n");
-		if (svsk->sk_sock->file)
-			sockfd_put(svsk->sk_sock);
-		else
-			sock_release(svsk->sk_sock);
-		if (svsk->sk_info_authunix != NULL)
-			svcauth_unix_info_release(svsk->sk_info_authunix);
-		kfree(svsk);
+		BUG_ON(!test_bit(SK_DEAD, &svsk->sk_flags));
+		svsk->sk_xprt.xpt_ops.xpo_free(&svsk->sk_xprt);
 	}
 }
 
@@ -903,6 +897,8 @@ static struct svc_xprt_ops svc_udp_ops =
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release = svc_release_skb,
+	.xpo_detach = svc_sock_detach,
+	.xpo_free = svc_sock_free,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1358,6 +1354,8 @@ static struct svc_xprt_ops svc_tcp_ops =
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release = svc_release_skb,
+	.xpo_detach = svc_sock_detach,
+	.xpo_free = svc_sock_free,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1815,6 +1813,42 @@ bummer:
 }
 
 /*
+ * Detach the svc_sock from the socket so that no
+ * more callbacks occur.
+ */
+static void
+svc_sock_detach(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
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
+svc_sock_free(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	dprintk("svc: svc_sock_free(%p)\n", svsk);
+
+	if (svsk->sk_info_authunix != NULL)
+		svcauth_unix_info_release(svsk->sk_info_authunix);
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
@@ -1828,9 +1862,7 @@ svc_delete_socket(struct svc_sock *svsk)
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
 
-	sk->sk_state_change = svsk->sk_ostate;
-	sk->sk_data_ready = svsk->sk_odata;
-	sk->sk_write_space = svsk->sk_owspace;
+	svsk->sk_xprt.xpt_ops.xpo_detach(&svsk->sk_xprt);
 
 	spin_lock_bh(&serv->sv_lock);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
