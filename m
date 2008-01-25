From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 006/112] SUNRPC: Fix TCP rebinding logic
Date: Fri, 25 Jan 2008 11:37:25 -0500
Message-ID: <20080125163724.31887.6958.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14406 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755771AbYAYRAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:22 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UU010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:20 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the TCP rebinding logic assumes that if we're not using a
reserved port, then we don't need to reconnect on the same port if a
disconnection event occurs. This breaks most RPC duplicate reply cache
implementations.

Also take into account the fact that xprt_min_resvport and
xprt_max_resvport may change while we're reconnecting, since the user may
change them at any time via the sysctls. Ensure that we check the port
boundaries every time we loop in xs_bind4/xs_bind6. Also ensure that if the
boundaries change, we only scan the ports a maximum of 2 times.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   59 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 29c5e6c..45cb1dc 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1272,34 +1272,53 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 	}
 }
 
+static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
+{
+	unsigned short port = transport->port;
+
+	if (port == 0 && transport->xprt.resvport)
+		port = xs_get_random_port();
+	return port;
+}
+
+static unsigned short xs_next_srcport(struct sock_xprt *transport, struct socket *sock, unsigned short port)
+{
+	if (transport->port != 0)
+		transport->port = 0;
+	if (!transport->xprt.resvport)
+		return 0;
+	if (port <= xprt_min_resvport || port > xprt_max_resvport)
+		return xprt_max_resvport;
+	return --port;
+}
+
 static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
 	struct sockaddr_in *sa;
-	int err;
-	unsigned short port = transport->port;
+	int err, nloop = 0;
+	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short last;
 
-	if (!transport->xprt.resvport)
-		port = 0;
 	sa = (struct sockaddr_in *)&transport->addr;
 	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
-		if (!transport->xprt.resvport)
+		if (port == 0)
 			break;
 		if (err == 0) {
 			transport->port = port;
 			break;
 		}
-		if (port <= xprt_min_resvport)
-			port = xprt_max_resvport;
-		else
-			port--;
-	} while (err == -EADDRINUSE && port != transport->port);
+		last = port;
+		port = xs_next_srcport(transport, sock, port);
+		if (port > last)
+			nloop++;
+	} while (err == -EADDRINUSE && nloop != 2);
 	dprintk("RPC:       %s "NIPQUAD_FMT":%u: %s (%d)\n",
 			__FUNCTION__, NIPQUAD(myaddr.sin_addr),
 			port, err ? "failed" : "ok", err);
@@ -1312,28 +1331,27 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		.sin6_family = AF_INET6,
 	};
 	struct sockaddr_in6 *sa;
-	int err;
-	unsigned short port = transport->port;
+	int err, nloop = 0;
+	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short last;
 
-	if (!transport->xprt.resvport)
-		port = 0;
 	sa = (struct sockaddr_in6 *)&transport->addr;
 	myaddr.sin6_addr = sa->sin6_addr;
 	do {
 		myaddr.sin6_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
-		if (!transport->xprt.resvport)
+		if (port == 0)
 			break;
 		if (err == 0) {
 			transport->port = port;
 			break;
 		}
-		if (port <= xprt_min_resvport)
-			port = xprt_max_resvport;
-		else
-			port--;
-	} while (err == -EADDRINUSE && port != transport->port);
+		last = port;
+		port = xs_next_srcport(transport, sock, port);
+		if (port > last)
+			nloop++;
+	} while (err == -EADDRINUSE && nloop != 2);
 	dprintk("RPC:       xs_bind6 "NIP6_FMT":%u: %s (%d)\n",
 		NIP6(myaddr.sin6_addr), port, err ? "failed" : "ok", err);
 	return err;
@@ -1815,7 +1833,6 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
 		memcpy(&new->addr, args->srcaddr, args->addrlen);
-	new->port = xs_get_random_port();
 
 	return xprt;
 }
