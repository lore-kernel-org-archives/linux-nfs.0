From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] SUNRPC: Fix the TCP server's send buffer accounting
Date: Mon, 18 May 2009 17:47:56 -0400
Message-ID: <20090518214756.786.58191.stgit@heimdal.trondhjem.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Moyer <jmoyer@redhat.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873AbZERVv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 17:51:27 -0400
In-Reply-To: <20090518214756.786.28129.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the sunrpc server is refusing to allow us to process new RPC
calls if the TCP send buffer is 2/3 full, even if we do actually have
enough free space to guarantee that we can send another request.
The following patch fixes svc_tcp_has_wspace() so that we only stop
processing requests if we know that the socket buffer cannot possibly fit
another reply.

It also fixes the tcp write_space() callback so that we only clear the
SOCK_NOSPACE flag when the TCP send buffer is less than 2/3 full.
This should ensure that the send window will grow as per the standard TCP
socket code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/svcsock.c |   36 +++++++++++++++++++-----------------
 1 files changed, 19 insertions(+), 17 deletions(-)


diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index af31988..eed978e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -345,6 +345,7 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
+	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
 #endif
 }
@@ -386,6 +387,15 @@ static void svc_write_space(struct sock *sk)
 	}
 }
 
+static void svc_tcp_write_space(struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) && sock)
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+	svc_write_space(sk);
+}
+
 /*
  * Copy the UDP datagram's destination address to the rqstp structure.
  * The 'destination' address in this case is the address to which the
@@ -617,6 +627,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	 * receive and respond to one request.
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
+	svsk->sk_sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	svc_sock_setbufsize(svsk->sk_sock,
 			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
 			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
@@ -962,25 +973,16 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
-	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
 	int required;
-	int wspace;
 
-	/*
-	 * Set the SOCK_NOSPACE flag before checking the available
-	 * sock space.
-	 */
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
+		return 1;
+	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
+	if (sk_stream_wspace(svsk->sk_sk) >= required)
+		return 1;
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
-	wspace = sk_stream_wspace(svsk->sk_sk);
-
-	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
-		return 0;
-	if (required * 2 > wspace)
-		return 0;
-
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	return 1;
+	return 0;
 }
 
 static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
@@ -1036,7 +1038,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		dprintk("setting up TCP socket for reading\n");
 		sk->sk_state_change = svc_tcp_state_change;
 		sk->sk_data_ready = svc_tcp_data_ready;
-		sk->sk_write_space = svc_write_space;
+		sk->sk_write_space = svc_tcp_write_space;
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;

