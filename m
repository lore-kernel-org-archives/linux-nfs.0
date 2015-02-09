Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34558 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933546AbbBIRSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:18:52 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so17861426igq.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:18:52 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/14] SUNRPC: Set SO_REUSEPORT socket option for TCP connections
Date: Mon,  9 Feb 2015 12:18:31 -0500
Message-Id: <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using TCP, we need the ability to reuse port numbers after
a disconnection, so that the NFSv3 server knows that we're the same
client. Currently we use a hack to work around the TCP socket's
TIME_WAIT: we send an RST instead of closing, which doesn't
always work...
The SO_REUSEPORT option added in Linux 3.9 allows us to bind multiple
TCP connections to the same source address+port combination, and thus
to use ordinary TCP close() instead of the current hack.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 49 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 87ce7e8bb8dc..484c5040436a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1667,6 +1667,39 @@ static unsigned short xs_get_random_port(void)
 }
 
 /**
+ * xs_set_reuseaddr_port - set the socket's port and address reuse options
+ * @sock: socket
+ *
+ * Note that this function has to be called on all sockets that share the
+ * same port, and it must be called before binding.
+ */
+static void xs_sock_set_reuseport(struct socket *sock)
+{
+	char opt = 1;
+
+	kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));
+}
+
+static unsigned short xs_sock_getport(struct socket *sock)
+{
+	struct sockaddr_storage buf;
+	int buflen;
+	unsigned short port = 0;
+
+	if (kernel_getsockname(sock, (struct sockaddr *)&buf, &buflen) < 0)
+		goto out;
+	switch (buf.ss_family) {
+	case AF_INET6:
+		port = ntohs(((struct sockaddr_in6 *)&buf)->sin6_port);
+		break;
+	case AF_INET:
+		port = ntohs(((struct sockaddr_in *)&buf)->sin_port);
+	}
+out:
+	return port;
+}
+
+/**
  * xs_set_port - reset the port number in the remote endpoint address
  * @xprt: generic transport
  * @port: new port number
@@ -1680,6 +1713,12 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 	xs_update_peer_port(xprt);
 }
 
+static void xs_set_srcport(struct sock_xprt *transport, struct socket *sock)
+{
+	if (transport->srcport == 0)
+		transport->srcport = xs_sock_getport(sock);
+}
+
 static unsigned short xs_get_srcport(struct sock_xprt *transport)
 {
 	unsigned short port = transport->srcport;
@@ -1833,7 +1872,8 @@ static void xs_dummy_setup_socket(struct work_struct *work)
 }
 
 static struct socket *xs_create_sock(struct rpc_xprt *xprt,
-		struct sock_xprt *transport, int family, int type, int protocol)
+		struct sock_xprt *transport, int family, int type,
+		int protocol, bool reuseport)
 {
 	struct socket *sock;
 	int err;
@@ -1846,6 +1886,9 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
 	}
 	xs_reclassify_socket(family, sock);
 
+	if (reuseport)
+		xs_sock_set_reuseport(sock);
+
 	err = xs_bind(transport, sock);
 	if (err) {
 		sock_release(sock);
@@ -2047,7 +2090,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 	sock = xs_create_sock(xprt, transport,
-			xs_addr(xprt)->sa_family, SOCK_DGRAM, IPPROTO_UDP);
+			xs_addr(xprt)->sa_family, SOCK_DGRAM,
+			IPPROTO_UDP, false);
 	if (IS_ERR(sock))
 		goto out;
 
@@ -2149,7 +2193,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_allocation = GFP_ATOMIC;
 
 		/* socket options */
-		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
 		sock_reset_flag(sk, SOCK_LINGER);
 		tcp_sk(sk)->linger2 = 0;
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
@@ -2174,6 +2217,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
 	switch (ret) {
 	case 0:
+		xs_set_srcport(transport, sock);
 	case -EINPROGRESS:
 		/* SYN_SENT! */
 		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
@@ -2202,7 +2246,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
-				xs_addr(xprt)->sa_family, SOCK_STREAM, IPPROTO_TCP);
+				xs_addr(xprt)->sa_family, SOCK_STREAM,
+				IPPROTO_TCP, true);
 		if (IS_ERR(sock)) {
 			status = PTR_ERR(sock);
 			goto out;
-- 
2.1.0

