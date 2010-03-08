From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/sunrpc: Convert (void)snprintf to snprintf
Date: Mon, 08 Mar 2010 08:38:30 -0800
Message-ID: <1268066310.1925.26.camel@Joe-Laptop.home>
References: <1267857980.849.22.camel@Joe-Laptop.home>
	 <4B951BF0.9050403@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1510 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755466Ab0CHQib (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 11:38:31 -0500
In-Reply-To: <4B951BF0.9050403@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Applies on top of "Remove uses of NIPQUAD, use %pI4")

Casts to void of snprintf are most uncommon in kernel source.
9 use casts, 1301 do not.

Remove the remaining uses in net/sunrpc/

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/xprtrdma/transport.c |    6 +++---
 net/sunrpc/xprtsock.c           |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 83d339f..f96c2fe 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -160,15 +160,15 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 	(void)rpc_ntop(sap, buf, sizeof(buf));
 	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	(void)snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
+	snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	/* netid */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 11f417b..75ab08e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -314,10 +314,10 @@ static void xs_format_common_peer_ports(struct rpc_xprt *xprt)
 	struct sockaddr *sap = xs_addr(xprt);
 	char buf[128];
 
-	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
-	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 }
 


