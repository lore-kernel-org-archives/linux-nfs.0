From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] SUNRPC: Rename sock_xprt.addr as sock_xprt.srcaddr
Date: Wed, 15 Jul 2009 17:42:46 -0400
Message-ID: <20090715214245.7883.67655.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60996
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754748AbZGOVms (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:48 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename the addr and port field in the sock_xprt struct.  I'm about to add
another address field, so let's avoid confusion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 000ddd9..4804d88 100644
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
@@ -1565,7 +1565,7 @@ static void xs_set_address(struct rpc_xprt *xprt,
 
 static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
 {
-	unsigned short port = transport->port;
+	unsigned short port = transport->srcport;
 
 	if (port == 0 && transport->xprt.resvport)
 		port = xs_get_random_port();
@@ -1574,8 +1574,8 @@ static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket
 
 static unsigned short xs_next_srcport(struct sock_xprt *transport, struct socket *sock, unsigned short port)
 {
-	if (transport->port != 0)
-		transport->port = 0;
+	if (transport->srcport != 0)
+		transport->srcport = 0;
 	if (!transport->xprt.resvport)
 		return 0;
 	if (port <= xprt_min_resvport || port > xprt_max_resvport)
@@ -1593,7 +1593,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in *)&transport->addr;
+	sa = (struct sockaddr_in *)&transport->srcaddr;
 	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
@@ -1602,7 +1602,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		if (port == 0)
 			break;
 		if (err == 0) {
-			transport->port = port;
+			transport->srcport = port;
 			break;
 		}
 		last = port;
@@ -1626,7 +1626,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in6 *)&transport->addr;
+	sa = (struct sockaddr_in6 *)&transport->srcaddr;
 	myaddr.sin6_addr = sa->sin6_addr;
 	do {
 		myaddr.sin6_port = htons(port);
@@ -1635,7 +1635,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		if (port == 0)
 			break;
 		if (err == 0) {
-			transport->port = port;
+			transport->srcport = port;
 			break;
 		}
 		last = port;
@@ -2080,7 +2080,7 @@ static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
 	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
-			transport->port,
+			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -2104,7 +2104,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
-			transport->port,
+			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -2183,7 +2183,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
-		memcpy(&new->addr, args->srcaddr, args->addrlen);
+		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
 
 	return xprt;
 }

