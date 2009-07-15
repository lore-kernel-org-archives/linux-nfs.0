From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] SUNRPC: Use rpc_ntop() for constructing transport
	address strings
Date: Wed, 15 Jul 2009 17:37:23 -0400
Message-ID: <20090715213723.7582.37432.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38864
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752749AbZGOVh0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:26 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  In addition to using the new generic rpc_ntop() and
rpc_get_port() functions, have the RPC client compute the presentation
address buffer sizes dynamically using kstrdup().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |   45 ++++++----------
 net/sunrpc/xprtsock.c           |  109 ++++++++++++---------------------------
 2 files changed, 52 insertions(+), 102 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 537c210..5f9b867 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -168,39 +168,30 @@ static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
 static void
 xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 {
-	struct sockaddr_in *addr = (struct sockaddr_in *)
+	struct sockaddr *sap = (struct sockaddr *)
 					&rpcx_to_rdmad(xprt).addr;
-	char *buf;
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	char buf[64];
 
-	buf = kzalloc(20, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 20, "%pI4", &addr->sin_addr.s_addr);
-	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+	(void)rpc_ntop(sap, buf, sizeof(buf));
+	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 8, "%u", ntohs(addr->sin_port));
-	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	buf = kzalloc(48, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 48, "addr=%pI4 port=%u proto=%s",
-			&addr->sin_addr.s_addr,
-			ntohs(addr->sin_port), "rdma");
-	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
-
-	buf = kzalloc(10, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 10, "%02x%02x%02x%02x",
-			NIPQUAD(addr->sin_addr.s_addr));
-	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
-
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 8, "%4hx", ntohs(addr->sin_port));
-	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+	(void)snprintf(buf, sizeof(buf), "addr=%s port=%s proto=rdma",
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT]);
+	xprt->address_strings[RPC_DISPLAY_ALL] = kstrdup(buf, GFP_KERNEL);
+
+	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
+				NIPQUAD(sin->sin_addr.s_addr));
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+
+	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	/* netid */
 	xprt->address_strings[RPC_DISPLAY_NETID] = "rdma";
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a42c2ad..302a409 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -296,99 +296,58 @@ static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
 	return (struct sockaddr_in6 *) &xprt->addr;
 }
 
-static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
-					  const char *protocol,
-					  const char *netid)
+static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 {
-	struct sockaddr_in *addr = xs_addr_in(xprt);
-	char *buf;
-
-	buf = kzalloc(20, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 20, "%pI4", &addr->sin_addr.s_addr);
-	}
-	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+	struct sockaddr *sap = xs_addr(xprt);
+	char buf[128];
 
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 8, "%u",
-				ntohs(addr->sin_port));
-	}
-	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+	(void)rpc_ntop(sap, buf, sizeof(buf));
+	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
+	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
-	buf = kzalloc(48, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 48, "addr=%pI4 port=%u proto=%s",
-			&addr->sin_addr.s_addr,
-			ntohs(addr->sin_port),
-			protocol);
-	}
-	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+	(void)snprintf(buf, sizeof(buf), "addr=%s port=%s proto=%s",
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT],
+			xprt->address_strings[RPC_DISPLAY_PROTO]);
+	xprt->address_strings[RPC_DISPLAY_ALL] = kstrdup(buf, GFP_KERNEL);
 
-	buf = kzalloc(10, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 10, "%02x%02x%02x%02x",
-				NIPQUAD(addr->sin_addr.s_addr));
-	}
-	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
+	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
+}
 
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 8, "%4hx",
-				ntohs(addr->sin_port));
-	}
-	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
+					  const char *protocol,
+					  const char *netid)
+{
+	struct sockaddr_in *sin = xs_addr_in(xprt);
+	char buf[16];
 
+	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
 	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
+
+	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
+				NIPQUAD(sin->sin_addr.s_addr));
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+
+	xs_format_common_peer_addresses(xprt);
 }
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 					  const char *protocol,
 					  const char *netid)
 {
-	struct sockaddr_in6 *addr = xs_addr_in6(xprt);
-	char *buf;
-
-	buf = kzalloc(40, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 40, "%pI6",&addr->sin6_addr);
-	}
-	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
-
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 8, "%u",
-				ntohs(addr->sin6_port));
-	}
-	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+	struct sockaddr_in6 *sin6 = xs_addr_in6(xprt);
+	char buf[48];
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
+	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
 
-	buf = kzalloc(64, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 64, "addr=%pI6 port=%u proto=%s",
-				&addr->sin6_addr,
-				ntohs(addr->sin6_port),
-				protocol);
-	}
-	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
-
-	buf = kzalloc(36, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 36, "%pi6", &addr->sin6_addr);
-
-	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
-
-	buf = kzalloc(8, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 8, "%4hx",
-				ntohs(addr->sin6_port));
-	}
-	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+	(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
+	xs_format_common_peer_addresses(xprt);
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)

