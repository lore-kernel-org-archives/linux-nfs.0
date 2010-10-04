Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40816 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227Ab0JDM4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:56:13 -0400
Message-ID: <4CA9CEE8.9050404@parallels.com>
Date: Mon, 04 Oct 2010 16:56:08 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 9/13] sunrpc: Merge the xs_bind code
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There's the only difference betseen the xs_bind4 and the
xs_bind6 - the size of sockaddr structure they use.

Fortunately its size can be indirectly get from transport and
the port in question resides on the same offset within the
v4 and the v6 sockaddrs.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   65 +++++++++++++-----------------------------------
 1 files changed, 18 insertions(+), 47 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7fdf2bb..3618cfd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1534,23 +1534,19 @@ static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned shor
 		return xprt_max_resvport;
 	return --port;
 }
-
-static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
+static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 {
-	struct sockaddr_in myaddr = {
-		.sin_family = AF_INET,
-	};
-	struct sockaddr_in *sa;
+	struct sockaddr myaddr;
 	int err, nloop = 0;
 	unsigned short port = xs_get_srcport(transport);
 	unsigned short last;
 
-	sa = (struct sockaddr_in *)&transport->srcaddr;
-	myaddr.sin_addr = sa->sin_addr;
+	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
 	do {
-		myaddr.sin_port = htons(port);
-		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
-						sizeof(myaddr));
+		BUILD_BUG_ON(offsetof(struct sockaddr_in, sin_port) !=
+				offsetof(struct sockaddr_in6, sin6_port));
+		((struct sockaddr_in *)&myaddr)->sin_port = htons(port);
+		err = kernel_bind(sock, &myaddr, transport->xprt.addrlen);
 		if (port == 0)
 			break;
 		if (err == 0) {
@@ -1562,44 +1558,19 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
-	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
-			__func__, &myaddr.sin_addr,
-			port, err ? "failed" : "ok", err);
-	return err;
-}
-
-static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
-{
-	struct sockaddr_in6 myaddr = {
-		.sin6_family = AF_INET6,
-	};
-	struct sockaddr_in6 *sa;
-	int err, nloop = 0;
-	unsigned short port = xs_get_srcport(transport);
-	unsigned short last;
 
-	sa = (struct sockaddr_in6 *)&transport->srcaddr;
-	myaddr.sin6_addr = sa->sin6_addr;
-	do {
-		myaddr.sin6_port = htons(port);
-		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
-						sizeof(myaddr));
-		if (port == 0)
-			break;
-		if (err == 0) {
-			transport->srcport = port;
-			break;
-		}
-		last = port;
-		port = xs_next_srcport(transport, port);
-		if (port > last)
-			nloop++;
-	} while (err == -EADDRINUSE && nloop != 2);
-	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
-		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
+	if (myaddr.sa_family == PF_INET)
+		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
+				&((struct sockaddr_in *)&myaddr)->sin_addr,
+				port, err ? "failed" : "ok", err);
+	else
+		dprintk("RPC:       %s %pI6:%u: %s (%d)\n", __func__,
+				&((struct sockaddr_in6 *)&myaddr)->sin6_addr,
+				port, err ? "failed" : "ok", err);
 	return err;
 }
 
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key xs_key[2];
 static struct lock_class_key xs_slock_key[2];
@@ -1645,7 +1616,7 @@ static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
 	}
 	xs_reclassify_socket4(sock);
 
-	if (xs_bind4(transport, sock)) {
+	if (xs_bind(transport, sock)) {
 		sock_release(sock);
 		goto out;
 	}
@@ -1669,7 +1640,7 @@ static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
 	}
 	xs_reclassify_socket6(sock);
 
-	if (xs_bind6(transport, sock)) {
+	if (xs_bind(transport, sock)) {
 		sock_release(sock);
 		goto out;
 	}
-- 
1.5.5.6

