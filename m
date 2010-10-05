Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32501 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752410Ab0JEQs7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 12:48:59 -0400
Message-ID: <4CAB56F0.9000504@parallels.com>
Date: Tue, 05 Oct 2010 20:48:48 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Don't return NULL from rpcb_create
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Its callers check for ERR_PTR.

However grep shows that nobody calls this with sa_familiy other than
AF_INET/AF_INET6 so this case can be simply dropped.

Furthermore - the remaining code can be replaced with the existing helper.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/rpcb_clnt.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 83af38d..620dee7 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -241,17 +241,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
 
-	switch (srvaddr->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
-		break;
-	default:
-		return NULL;
-	}
-
+	rpc_set_port(srvaddr, RPCBIND_PORT);
 	return rpc_create(&args);
 }
 
-- 
1.5.5.6

