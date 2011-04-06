Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39843 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab1DFXGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, Jim Rees <rees@umich.edu>,
        "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/7] svcrpc: take advantage of tcp autotuning
Date: Wed,  6 Apr 2011 19:06:26 -0400
Message-Id: <1302131186-6578-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Olga Kornievskaia <aglo@citi.umich.edu>

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
---
 net/sunrpc/svcsock.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index fdb8ea5..8485698 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -436,7 +436,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
-	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
 #endif
@@ -967,23 +966,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	unsigned int want;
 	int len;
 
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
 
 	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
@@ -1361,15 +1343,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
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
@@ -1433,8 +1406,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
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
1.7.1

