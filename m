From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] SUNRPC: Update xprt address strings after an rpcbind
	completes
Date: Thu, 06 Aug 2009 14:55:38 -0400
Message-ID: <20090806185538.3458.20717.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45916
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753130AbZHFSzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:40 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After a bind completes, update the transport instance's address
strings so debugging messages display the current port the transport
is connected to.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   82 +++++++++++++++++++++++++------------------------
 1 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index eee5ac9..8aaf900 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -299,11 +299,34 @@ static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
 static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 {
 	struct sockaddr *sap = xs_addr(xprt);
+	struct sockaddr_in6 *sin6;
+	struct sockaddr_in *sin;
 	char buf[128];
 
 	(void)rpc_ntop(sap, buf, sizeof(buf));
 	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
 
+	switch (sap->sa_family) {
+	case AF_INET:
+		sin = xs_addr_in(xprt);
+		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
+					NIPQUAD(sin->sin_addr.s_addr));
+		break;
+	case AF_INET6:
+		sin6 = xs_addr_in6(xprt);
+		(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+		break;
+	default:
+		BUG();
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+}
+
+static void xs_format_common_peer_ports(struct rpc_xprt *xprt)
+{
+	struct sockaddr *sap = xs_addr(xprt);
+	char buf[128];
+
 	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
@@ -311,37 +334,22 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 }
 
-static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
-					  const char *protocol,
-					  const char *netid)
+static void xs_format_peer_addresses(struct rpc_xprt *xprt,
+				     const char *protocol,
+				     const char *netid)
 {
-	struct sockaddr_in *sin = xs_addr_in(xprt);
-	char buf[16];
-
 	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
 	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
-
-	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-				NIPQUAD(sin->sin_addr.s_addr));
-	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
-
 	xs_format_common_peer_addresses(xprt);
+	xs_format_common_peer_ports(xprt);
 }
 
-static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
-					  const char *protocol,
-					  const char *netid)
+static void xs_update_peer_port(struct rpc_xprt *xprt)
 {
-	struct sockaddr_in6 *sin6 = xs_addr_in6(xprt);
-	char buf[48];
+	kfree(xprt->address_strings[RPC_DISPLAY_HEX_PORT]);
+	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
 
-	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
-	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
-
-	(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
-	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
-
-	xs_format_common_peer_addresses(xprt);
+	xs_format_common_peer_ports(xprt);
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
@@ -1522,20 +1530,10 @@ static unsigned short xs_get_random_port(void)
  */
 static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 {
-	struct sockaddr *addr = xs_addr(xprt);
-
 	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
 
-	switch (addr->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)addr)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)addr)->sin6_port = htons(port);
-		break;
-	default:
-		BUG();
-	}
+	rpc_set_port(xs_addr(xprt), port);
+	xs_update_peer_port(xprt);
 }
 
 static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
@@ -2216,7 +2214,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
+		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
@@ -2224,7 +2222,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
+		xs_format_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
 		kfree(xprt);
@@ -2288,15 +2286,17 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_tcp_connect_worker4);
+		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
-		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_tcp_connect_worker6);
+		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
 		kfree(xprt);

