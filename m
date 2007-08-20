From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 08/20] svc: centralise accept handling
Date: Mon, 20 Aug 2007 11:23:38 -0500
Message-ID: <20070820162338.15224.14674.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2W-0006Nx-IL
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:41 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2a-0005NR-7o
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:44 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 7A2547C79E
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:38 -0500 (CDT)
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


Centralise the handling of the SK_CONN bit so that future
server transport implementations will be easier to
write correctly.  Also, the xpt_recvfrom method does not 
need to check for SK_CONN anymore, that's handled in core 
code which calls a new xpt_accept method.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/svcsock.c           |   24 +++++++++++-------------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 0145057..7663578 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -41,6 +41,10 @@ struct svc_xprt {
 	 * svc_sock.
 	 */
 	u32			xpt_max_payload;
+	/*
+	 * Accept a pending connection, for connection-oriented transports
+	 */
+	int			(*xpt_accept)(struct svc_sock *svsk);
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5c3a794..94eb921 100644
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
@@ -1361,6 +1354,7 @@ static const struct svc_xprt svc_tcp_xpr
 	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpt_has_wspace = svc_tcp_has_wspace,
 	.xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
+	.xpt_accept = svc_tcp_accept,
 };
 
 static void
@@ -1521,6 +1515,9 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
+		svsk->sk_xprt->xpt_accept(svsk);
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
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
