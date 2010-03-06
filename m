From: Joe Perches <joe@perches.com>
Subject: [PATCH resend] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Fri, 05 Mar 2010 22:46:20 -0800
Message-ID: <1267857980.849.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1450 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab0CFGqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Mar 2010 01:46:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Originally submitted Jan 1, 2010
http://patchwork.kernel.org/patch/71221/

Convert NIPQUAD to the %pI4 format extension where possible
Convert %02x%02x%02x%02x/NIPQUAD to %08x/ntohl

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 +--
 net/sunrpc/xprtsock.c           |    5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7018eef..83d339f 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -165,8 +165,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-				NIPQUAD(sin->sin_addr.s_addr));
+	(void)snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
 	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..86234bc 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -297,12 +297,11 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 	switch (sap->sa_family) {
 	case AF_INET:
 		sin = xs_addr_in(xprt);
-		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-					NIPQUAD(sin->sin_addr.s_addr));
+		snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 		break;
 	case AF_INET6:
 		sin6 = xs_addr_in6(xprt);
-		(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+		snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
 		break;
 	default:
 		BUG();


