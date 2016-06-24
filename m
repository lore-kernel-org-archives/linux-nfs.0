Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33838 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFXO41 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:27 -0400
Received: by mail-io0-f194.google.com with SMTP id 100so16545247ioh.1
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] SUNRPC: Call the default socket callbacks instead of open coding
Date: Fri, 24 Jun 2016 10:55:48 -0400
Message-Id: <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than code up our own versions of the socket callbacks, just
call the defaults.
This also allows us to merge svc_udp_data_ready() and svc_tcp_data_ready().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 88 ++++++++++++----------------------------------------
 1 file changed, 19 insertions(+), 69 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index abe2da602fb8..03134708deeb 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -60,7 +60,6 @@
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int flags);
-static void		svc_udp_data_ready(struct sock *);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_sock_detach(struct svc_xprt *);
@@ -398,48 +397,21 @@ static int svc_sock_secure_port(struct svc_rqst *rqstp)
 	return svc_port_is_privileged(svc_addr(rqstp));
 }
 
-static bool sunrpc_waitqueue_active(wait_queue_head_t *wq)
-{
-	if (!wq)
-		return false;
-	/*
-	 * There should normally be a memory * barrier here--see
-	 * wq_has_sleeper().
-	 *
-	 * It appears that isn't currently necessary, though, basically
-	 * because callers all appear to have sufficient memory barriers
-	 * between the time the relevant change is made and the
-	 * time they call these callbacks.
-	 *
-	 * The nfsd code itself doesn't actually explicitly wait on
-	 * these waitqueues, but it may wait on them for example in
-	 * sendpage() or sendmsg() calls.  (And those may be the only
-	 * places, since it it uses nonblocking reads.)
-	 *
-	 * Maybe we should add the memory barriers anyway, but these are
-	 * hot paths so we'd need to be convinced there's no sigificant
-	 * penalty.
-	 */
-	return waitqueue_active(wq);
-}
-
 /*
  * INET callback when data has been received on the socket.
  */
-static void svc_udp_data_ready(struct sock *sk)
+static void svc_data_ready(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
-	wait_queue_head_t *wq = sk_sleep(sk);
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), busy=%d\n",
 			svsk, sk,
 			test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
+		svsk->sk_odata(sk);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sunrpc_waitqueue_active(wq))
-		wake_up_interruptible(wq);
 }
 
 /*
@@ -448,19 +420,13 @@ static void svc_udp_data_ready(struct sock *sk)
 static void svc_write_space(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)(sk->sk_user_data);
-	wait_queue_head_t *wq = sk_sleep(sk);
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), write_space busy=%d\n",
 			svsk, sk, test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
+		svsk->sk_owspace(sk);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-
-	if (sunrpc_waitqueue_active(wq)) {
-		dprintk("RPC svc_write_space: someone sleeping on %p\n",
-		       svsk);
-		wake_up_interruptible(wq);
-	}
 }
 
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
@@ -485,11 +451,15 @@ static void svc_tcp_write_space(struct sock *sk)
 	struct svc_sock *svsk = (struct svc_sock *)(sk->sk_user_data);
 	struct socket *sock = sk->sk_socket;
 
+	if (!svsk)
+		return;
+
 	if (!sk_stream_is_writeable(sk) || !sock)
 		return;
-	if (!svsk || svc_tcp_has_wspace(&svsk->sk_xprt))
+	if (svc_tcp_has_wspace(&svsk->sk_xprt)) {
 		clear_bit(SOCK_NOSPACE, &sock->flags);
-	svc_write_space(sk);
+		svc_write_space(sk);
+	}
 }
 
 static void svc_tcp_adjust_wspace(struct svc_xprt *xprt)
@@ -746,7 +716,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_udp_class,
 		      &svsk->sk_xprt, serv);
 	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
-	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
+	svsk->sk_sk->sk_data_ready = svc_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 
 	/* initialise setting must have enough space to
@@ -786,11 +756,12 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 static void svc_tcp_listen_data_ready(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
-	wait_queue_head_t *wq;
 
 	dprintk("svc: socket %p TCP (listen) state change %d\n",
 		sk, sk->sk_state);
 
+	if (svsk)
+		svsk->sk_odata(sk);
 	/*
 	 * This callback may called twice when a new connection
 	 * is established as a child socket inherits everything
@@ -808,10 +779,6 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
 		} else
 			printk("svc: socket %p: no user data\n", sk);
 	}
-
-	wq = sk_sleep(sk);
-	if (sunrpc_waitqueue_active(wq))
-		wake_up_interruptible_all(wq);
 }
 
 /*
@@ -820,7 +787,6 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
 static void svc_tcp_state_change(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
-	wait_queue_head_t *wq = sk_sleep(sk);
 
 	dprintk("svc: socket %p TCP (connected) state change %d (svsk %p)\n",
 		sk, sk->sk_state, sk->sk_user_data);
@@ -828,26 +794,10 @@ static void svc_tcp_state_change(struct sock *sk)
 	if (!svsk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
+		svsk->sk_ostate(sk);
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sunrpc_waitqueue_active(wq))
-		wake_up_interruptible_all(wq);
-}
-
-static void svc_tcp_data_ready(struct sock *sk)
-{
-	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
-	wait_queue_head_t *wq = sk_sleep(sk);
-
-	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
-		sk, sk->sk_user_data);
-	if (svsk) {
-		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_xprt_enqueue(&svsk->sk_xprt);
-	}
-	if (sunrpc_waitqueue_active(wq))
-		wake_up_interruptible(wq);
 }
 
 /*
@@ -901,6 +851,11 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	dprintk("%s: connect from %s\n", serv->sv_name,
 		__svc_print_addr(sin, buf, sizeof(buf)));
 
+	/* Reset the inherited callbacks before calling svc_setup_socket */
+	newsock->sk->sk_state_change = svsk->sk_ostate;
+	newsock->sk->sk_data_ready = svsk->sk_odata;
+	newsock->sk->sk_write_space = svsk->sk_owspace;
+
 	/* make sure that a write doesn't block forever when
 	 * low on memory
 	 */
@@ -1357,7 +1312,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	} else {
 		dprintk("setting up TCP socket for reading\n");
 		sk->sk_state_change = svc_tcp_state_change;
-		sk->sk_data_ready = svc_tcp_data_ready;
+		sk->sk_data_ready = svc_data_ready;
 		sk->sk_write_space = svc_tcp_write_space;
 
 		svsk->sk_reclen = 0;
@@ -1606,7 +1561,6 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	struct sock *sk = svsk->sk_sk;
-	wait_queue_head_t *wq;
 
 	dprintk("svc: svc_sock_detach(%p)\n", svsk);
 
@@ -1617,10 +1571,6 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 	sk->sk_write_space = svsk->sk_owspace;
 	sk->sk_user_data = NULL;
 	release_sock(sk);
-
-	wq = sk_sleep(sk);
-	if (sunrpc_waitqueue_active(wq))
-		wake_up_interruptible(wq);
 }
 
 /*
-- 
2.7.4

