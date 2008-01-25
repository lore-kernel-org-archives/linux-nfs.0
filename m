From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 092/112] SUNRPC: fewer conditionals in the
	format_ip_address routines
Date: Fri, 25 Jan 2008 11:37:56 -0500
Message-ID: <20080125163756.31887.25589.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735AbYAYRAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:19 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Hm010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:17 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: have the set up routines explicitly pass the strings to be used
for the transport name and NETID.  This removes a number of conditionals
and dependencies on rpc_xprt.prot, which is overloaded.

Tighten up type checking on the address_strings array while we're at it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h |    2 +-
 include/linux/sunrpc/xprt.h |    2 +-
 net/sunrpc/clnt.c           |    3 ++
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/xprtsock.c       |   56 +++++++++++++++++--------------------------
 5 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 51a3381..5a13da2 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -143,7 +143,7 @@ void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
-char *		rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
+const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index c3364d8..b3ff9a8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -183,7 +183,7 @@ struct rpc_xprt {
 					bklog_u;	/* backlog queue utilization */
 	} stat;
 
-	char *			address_strings[RPC_DISPLAY_MAX];
+	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
 struct xprt_create {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a3c00da..e775ca7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -679,7 +679,8 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr);
  * @format: address format
  *
  */
-char *rpc_peeraddr2str(struct rpc_clnt *clnt, enum rpc_display_format_t format)
+const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
+			     enum rpc_display_format_t format)
 {
 	struct rpc_xprt *xprt = clnt->cl_xprt;
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index f494e58..b60fa92 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -358,7 +358,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+	map->r_netid = (char *)rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
 	memcpy(map->r_addr,
 	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
 	       sizeof(map->r_addr));
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bb30510..17e1721 100644
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
@@ -299,21 +301,14 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
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
+	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf) {
 		snprintf(buf, 48, "addr="NIPQUAD_FMT" port=%u proto=%s",
 			NIPQUAD(addr->sin_addr.s_addr),
 			ntohs(addr->sin_port),
-			xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+			protocol);
 	}
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
@@ -340,12 +335,12 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 
-	xprt->address_strings[RPC_DISPLAY_NETID] =
-		kstrdup(xprt->prot == IPPROTO_UDP ?
-			RPCBIND_NETID_UDP : RPCBIND_NETID_TCP, GFP_KERNEL);
+	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
 }
 
-static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
+static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
+					  const char *protocol,
+					  const char *netid)
 {
 	struct sockaddr_in6 *addr = xs_addr_in6(xprt);
 	char *buf;
@@ -364,21 +359,14 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
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
+	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
 
 	buf = kzalloc(64, GFP_KERNEL);
 	if (buf) {
 		snprintf(buf, 64, "addr="NIP6_FMT" port=%u proto=%s",
 				NIP6(addr->sin6_addr),
 				ntohs(addr->sin6_port),
-				xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+				protocol);
 	}
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
@@ -405,17 +393,17 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 
-	xprt->address_strings[RPC_DISPLAY_NETID] =
-		kstrdup(xprt->prot == IPPROTO_UDP ?
-			RPCBIND_NETID_UDP6 : RPCBIND_NETID_TCP6, GFP_KERNEL);
+	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 {
-	int i;
-
-	for (i = 0; i < RPC_DISPLAY_MAX; i++)
-		kfree(xprt->address_strings[i]);
+	kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
+	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
+	kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
+	kfree(xprt->address_strings[RPC_DISPLAY_HEX_ADDR]);
+	kfree(xprt->address_strings[RPC_DISPLAY_HEX_PORT]);
+	kfree(xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR]);
 }
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
@@ -1935,7 +1923,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt);
+		xs_format_ipv4_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
@@ -1943,7 +1931,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt);
+		xs_format_ipv6_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
 		kfree(xprt);
@@ -2001,14 +1989,14 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
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
