From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Tue, 21 Oct 2008 14:31:38 -0400
Message-ID: <48FE200A.6070805@citi.umich.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040204050505090502060503"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:4366 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbYJUSbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Oct 2008 14:31:39 -0400
Received: from yoga.citi.umich.edu (yoga.citi.umich.edu [141.211.133.26])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "aglo", Issuer "CITI Production KCA" (verified OK))
	by citi.umich.edu (Postfix) with ESMTP id B95CF42CA
	for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2008 14:31:38 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040204050505090502060503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------040204050505090502060503
Content-Type: text/x-patch;
 name="0001-autotuning-recv-window-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-autotuning-recv-window-fix.patch"

From: Olga Kornievskaia <aglo@citi.umich.edu>
Date: Tue, 21 Oct 2008 14:13:47 -0400
Subject: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix

This patch allows for the NFSv4 server to make use of TCP autotuning behaviour
which was previously disabled by setting sk_userlocks variable. 

This patch sets the receive buffers to be big enough to receive the whole 
RPC request. This buffer size had to be set for the listening socket and not
the accept socket as it was previously done. 

This patch removes the code that readjust the receive/send buffer sizes for
the accepted socket. Previously this code was used to influence the TCP
window management behaviour which is no longer needed when autotuning is 
enabled. 

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
---
 net/sunrpc/svcsock.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3e65719..4bb535e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -349,7 +349,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
-	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	release_sock(sock->sk);
 #endif
 }
@@ -801,23 +800,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
-	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
-		/* sndbuf needs to have room for one request
-		 * per thread, otherwise we can stall even when the
-		 * network isn't a bottleneck.
-		 *
-		 * We count all threads rather than threads in a
-		 * particular pool, which provides an upper bound
-		 * on the number of threads which will access the socket.
-		 *
-		 * rcvbuf just needs to be able to hold a few requests.
-		 * Normally they will be removed from the queue
-		 * as soon a a complete request arrives.
-		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				    3 * serv->sv_max_mesg);
-
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	/* Receive data. If we haven't got the record length yet, get
@@ -1065,15 +1047,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 * svc_tcp_recvfrom will re-adjust if necessary
-		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
-
-		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		if (sk->sk_state != TCP_ESTABLISHED)
 			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
@@ -1143,8 +1116,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
 		svc_udp_init(svsk, serv);
-	else
+	else {
+		/* initialise setting must have enough space to
+		 * receive and respond to one request.
+		 */
+		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
+					4 * serv->sv_max_mesg);
 		svc_tcp_init(svsk, serv);
+	}
 
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);
-- 
1.5.0.2


--------------040204050505090502060503--
