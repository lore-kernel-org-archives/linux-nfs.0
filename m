From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: svcrpc: take advantage of tcp autotuning
Date: Wed, 18 Mar 2009 19:38:00 -0400
Message-ID: <20090318233800.GP18894@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, rees@umich.edu
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42910 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbZCRXiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:38:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm also queuing this up for 2.6.30, barring any objections.

--b.

commit 47a14ef1af48c696b214ac168f056ddc79793d0e
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Oct 21 14:13:47 2008 -0400

    svcrpc: take advantage of tcp autotuning
    
    Allow the NFSv4 server to make use of TCP autotuning behaviour, which
    was previously disabled by setting the sk_userlocks variable.
    
    Set the receive buffers to be big enough to receive the whole RPC
    request, and set this for the listening socket, not the accept socket.
    
    Remove the code that readjusts the receive/send buffer sizes for the
    accepted socket. Previously this code was used to influence the TCP
    window management behaviour, which is no longer needed when autotuning
    is enabled.
    
    This can improve IO bandwidth on networks with high bandwidth-delay
    products, where a large tcp window is required.  It also simplifies
    performance tuning, since getting adequate tcp buffers previously
    required increasing the number of nfsd threads.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Cc: Jim Rees <rees@umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5763e64..7a2a90f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -345,7 +345,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
-	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	release_sock(sock->sk);
 #endif
 }
@@ -797,23 +796,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1061,15 +1043,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
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
@@ -1140,8 +1113,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
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
 
 	/*
 	 * We start one listener per sv_serv.  We want AF_INET
