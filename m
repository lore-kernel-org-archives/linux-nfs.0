From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/20] SUNRPC: Split xs_reclassify_socket into an IPv4
	and	IPv6 version
Date: Mon, 06 Aug 2007 11:58:04 -0400
Message-ID: <20070806155803.31233.30721.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4y5-00017y-U2
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:05 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4y9-0006R4-Mr
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:10 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   38 ++++++++++++++++++++------------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 24a8348..45b2af1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1326,27 +1326,29 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 static struct lock_class_key xs_key[2];
 static struct lock_class_key xs_slock_key[2];
 
-static inline void xs_reclassify_socket(struct socket *sock)
+static inline void xs_reclassify_socket4(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+
 	BUG_ON(sk->sk_lock.owner != NULL);
-	switch (sk->sk_family) {
-	case AF_INET:
-		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFS",
-			&xs_slock_key[0], "sk_lock-AF_INET-NFS", &xs_key[0]);
-		break;
+	sock_lock_init_class_and_name(sk, "slock-AF_INET-RPC",
+		&xs_slock_key[0], "sk_lock-AF_INET-RPC", &xs_key[0]);
+}
 
-	case AF_INET6:
-		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFS",
-			&xs_slock_key[1], "sk_lock-AF_INET6-NFS", &xs_key[1]);
-		break;
+static inline void xs_reclassify_socket6(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
 
-	default:
-		BUG();
-	}
+	BUG_ON(sk->sk_lock.owner != NULL);
+	sock_lock_init_class_and_name(sk, "slock-AF_INET6-RPC",
+		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
 }
 #else
-static inline void xs_reclassify_socket(struct socket *sock)
+static inline void xs_reclassify_socket4(struct socket *sock)
+{
+}
+
+static inline void xs_reclassify_socket6(struct socket *sock)
 {
 }
 #endif
@@ -1404,7 +1406,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
 	}
-	xs_reclassify_socket(sock);
+	xs_reclassify_socket4(sock);
 
 	if (xs_bind4(transport, sock)) {
 		sock_release(sock);
@@ -1445,7 +1447,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
 	}
-	xs_reclassify_socket(sock);
+	xs_reclassify_socket6(sock);
 
 	if (xs_bind6(transport, sock) < 0) {
 		sock_release(sock);
@@ -1548,7 +1550,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
 			goto out;
 		}
-		xs_reclassify_socket(sock);
+		xs_reclassify_socket4(sock);
 
 		if (xs_bind4(transport, sock) < 0) {
 			sock_release(sock);
@@ -1609,7 +1611,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
 			goto out;
 		}
-		xs_reclassify_socket(sock);
+		xs_reclassify_socket6(sock);
 
 		if (xs_bind6(transport, sock) < 0) {
 			sock_release(sock);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
