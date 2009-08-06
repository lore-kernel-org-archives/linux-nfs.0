From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] SUNRPC: Rename sock_xprt.addr as sock_xprt.srcaddr
Date: Thu, 06 Aug 2009 14:55:23 -0400
Message-ID: <20090806185522.3458.49685.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45910
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752495AbZHFSzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:24 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Give the "addr" and "port" field less ambiguous names.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 302a409..7bc3c17 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -248,8 +248,8 @@ struct sock_xprt {
 	 * Connection of transports
 	 */
 	struct delayed_work	connect_worker;
-	struct sockaddr_storage	addr;
-	unsigned short		port;
+	struct sockaddr_storage	srcaddr;
+	unsigned short		srcport;
 
 	/*
 	 * UDP socket buffer size parameters
@@ -1546,7 +1546,7 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 
 static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
 {
-	unsigned short port = transport->port;
+	unsigned short port = transport->srcport;
 
 	if (port == 0 && transport->xprt.resvport)
 		port = xs_get_random_port();
@@ -1555,8 +1555,8 @@ static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket
 
 static unsigned short xs_next_srcport(struct sock_xprt *transport, struct socket *sock, unsigned short port)
 {
-	if (transport->port != 0)
-		transport->port = 0;
+	if (transport->srcport != 0)
+		transport->srcport = 0;
 	if (!transport->xprt.resvport)
 		return 0;
 	if (port <= xprt_min_resvport || port > xprt_max_resvport)
@@ -1574,7 +1574,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in *)&transport->addr;
+	sa = (struct sockaddr_in *)&transport->srcaddr;
 	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
@@ -1583,7 +1583,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		if (port == 0)
 			break;
 		if (err == 0) {
-			transport->port = port;
+			transport->srcport = port;
 			break;
 		}
 		last = port;
@@ -1607,7 +1607,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in6 *)&transport->addr;
+	sa = (struct sockaddr_in6 *)&transport->srcaddr;
 	myaddr.sin6_addr = sa->sin6_addr;
 	do {
 		myaddr.sin6_port = htons(port);
@@ -1616,7 +1616,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		if (port == 0)
 			break;
 		if (err == 0) {
-			transport->port = port;
+			transport->srcport = port;
 			break;
 		}
 		last = port;
@@ -2061,7 +2061,7 @@ static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
 	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
-			transport->port,
+			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -2085,7 +2085,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
-			transport->port,
+			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -2164,7 +2164,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
-		memcpy(&new->addr, args->srcaddr, args->addrlen);
+		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
 
 	return xprt;
 }

