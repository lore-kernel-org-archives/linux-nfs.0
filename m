From: akpm@linux-foundation.org
Subject: [patch 2/2] net/sunrpc: remove uses of NIPQUAD, use %pI4
Date: Tue, 02 Feb 2010 14:45:23 -0800
Message-ID: <201002022245.o12MjN8q019302@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	joe@perches.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
	neilb@suse.de
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45520 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756824Ab0BBWqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Feb 2010 17:46:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/xprtrdma/transport.c |    3 +--
 net/sunrpc/xprtsock.c           |    5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff -puN net/sunrpc/xprtrdma/transport.c~net-sunrpc-remove-uses-of-nipquad-use-%pi4 net/sunrpc/xprtrdma/transport.c
--- a/net/sunrpc/xprtrdma/transport.c~net-sunrpc-remove-uses-of-nipquad-use-%pi4
+++ a/net/sunrpc/xprtrdma/transport.c
@@ -165,8 +165,7 @@ xprt_rdma_format_addresses(struct rpc_xp
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-				NIPQUAD(sin->sin_addr.s_addr));
+	(void)snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
 	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
diff -puN net/sunrpc/xprtsock.c~net-sunrpc-remove-uses-of-nipquad-use-%pi4 net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c~net-sunrpc-remove-uses-of-nipquad-use-%pi4
+++ a/net/sunrpc/xprtsock.c
@@ -297,12 +297,11 @@ static void xs_format_common_peer_addres
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
_
