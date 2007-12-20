From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] SUNRPC: fewer conditionals in the format_ip_address
	routines
Date: Thu, 20 Dec 2007 14:55:18 -0500
Message-ID: <20071220195518.3280.91282.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:47301 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbXLTTza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:55:30 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: have the set up routines explicitly pass the strings to be used
for the transport name and NETID.  This removes a number of conditionals
and dependencies on rpc_xprt.prot, which is overloaded.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   48 ++++++++++++++++++------------------------------
 1 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2f630a5..9f5c7b0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -280,7 +280,9 @@ static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
 	return (struct sockaddr_in6 *) &xprt->addr;
 }
 
-static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
+static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
+					  const char *protocol,
+					  const char *netid)
 {
 	struct sockaddr_in *addr = xs_addr_in(xprt);
 	char *buf;
@@ -299,21 +301,15 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
 
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		if (xprt->prot == IPPROTO_UDP)
-			snprintf(buf, 8, "udp");
-		else
-			snprintf(buf, 8, "tcp");
-	}
-	xprt->address_strings[RPC_DISPLAY_PROTO] = buf;
+	xprt->address_strings[RPC_DISPLAY_PROTO] = kstrdup(protocol,
+							   GFP_KERNEL);
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf) {
 		snprintf(buf, 48, "addr="NIPQUAD_FMT" port=%u proto=%s",
 			NIPQUAD(addr->sin_addr.s_addr),
 			ntohs(addr->sin_port),
-			xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+			protocol);
 	}
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
@@ -340,12 +336,12 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 
-	xprt->address_strings[RPC_DISPLAY_NETID] =
-		kstrdup(xprt->prot == IPPROTO_UDP ?
-			RPCBIND_NETID_UDP : RPCBIND_NETID_TCP, GFP_KERNEL);
+	xprt->address_strings[RPC_DISPLAY_NETID] = kstrdup(netid, GFP_KERNEL);
 }
 
-static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
+static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
+					  const char *protocol,
+					  const char *netid)
 {
 	struct sockaddr_in6 *addr = xs_addr_in6(xprt);
 	char *buf;
@@ -364,21 +360,15 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
 
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		if (xprt->prot == IPPROTO_UDP)
-			snprintf(buf, 8, "udp");
-		else
-			snprintf(buf, 8, "tcp");
-	}
-	xprt->address_strings[RPC_DISPLAY_PROTO] = buf;
+	xprt->address_strings[RPC_DISPLAY_PROTO] = kstrdup(protocol,
+							   GFP_KERNEL);
 
 	buf = kzalloc(64, GFP_KERNEL);
 	if (buf) {
 		snprintf(buf, 64, "addr="NIP6_FMT" port=%u proto=%s",
 				NIP6(addr->sin6_addr),
 				ntohs(addr->sin6_port),
-				xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+				protocol);
 	}
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
@@ -405,9 +395,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 
-	xprt->address_strings[RPC_DISPLAY_NETID] =
-		kstrdup(xprt->prot == IPPROTO_UDP ?
-			RPCBIND_NETID_UDP6 : RPCBIND_NETID_TCP6, GFP_KERNEL);
+	xprt->address_strings[RPC_DISPLAY_NETID] = kstrdup(netid, GFP_KERNEL);
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
@@ -1863,7 +1851,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt);
+		xs_format_ipv4_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
@@ -1871,7 +1859,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt);
+		xs_format_ipv6_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
 		kfree(xprt);
@@ -1927,14 +1915,14 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt);
+		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt);
+		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
 		kfree(xprt);

