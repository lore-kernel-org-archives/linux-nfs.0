From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Tue,  5 Jan 2010 17:20:16 -0800
Message-ID: <b39f7936e8b262c3367ab708bf1e039db53509d3.1262726222.git.joe@perches.com>
References: <cover.1262726222.git.joe@perches.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1531 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755322Ab0AFBUZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 20:20:25 -0500
In-Reply-To: <cover.1262726222.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
-- 
1.6.6.rc0.57.gad7a

