From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 08/20] svc: centralise accept handling
Date: Tue, 10 Jul 2007 00:34:37 -0500
Message-ID: <20070710053437.28979.95495.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Ms-00074U-HR
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:34 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mv-0004rn-9v
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:38 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 1BA7A7C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:37 -0500 (CDT)
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


Centralise the handling of the SK_CONN bit to that future
sunrpc server transport implementations will be easier to
write correctly.  Also, the sko_recvfrom method does not 
need to check for SK_CONN anymore, that's handled in core 
code which calls a new sko_accept method.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/svcsock.c           |   26 ++++++++++++--------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 9fa4321..c4eb40c 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -41,6 +41,10 @@ struct svc_sock_ops {
 	 * svc_sock.
 	 */
 	u32			sko_max_payload;
+	/*
+	 * Accept a pending connection, for connection-oriented transports
+	 */
+	int			(*sko_accept)(struct svc_sock *svsk);
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 75fae77..2ef3013 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1012,7 +1012,7 @@ static inline int svc_port_is_privileged
 /*
  * Accept a TCP connection
  */
-static void
+static int
 svc_tcp_accept(struct svc_sock *svsk)
 {
 	struct sockaddr_storage addr;
@@ -1021,12 +1021,12 @@ svc_tcp_accept(struct svc_sock *svsk)
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
 
 	clear_bit(SK_CONN, &svsk->sk_flags);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
@@ -1037,9 +1037,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		return;
+		return err;
 	}
-
 	set_bit(SK_CONN, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 
@@ -1124,11 +1123,11 @@ svc_tcp_accept(struct svc_sock *svsk)
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
@@ -1153,12 +1152,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1360,7 +1353,8 @@ static const struct svc_sock_ops svc_tcp
 	.sko_free = svc_tcpip_free,
 	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.sko_has_wspace = svc_tcp_has_wspace,
-	.sko_max_payload = RPCSVC_MAXPAYLOAD_TCP
+	.sko_max_payload = RPCSVC_MAXPAYLOAD_TCP,
+	.sko_accept = svc_tcp_accept
 };
 
 static void
@@ -1521,6 +1515,9 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
+		svsk->sk_ops->sko_accept(svsk);
+		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
@@ -1660,6 +1657,7 @@ static struct svc_sock *svc_setup_socket
 	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
+	*errp = 0;
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
 		*errp = -ENOMEM;
 		return NULL;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
