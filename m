Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33933 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840Ab0JEQtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 12:49:40 -0400
Message-ID: <4CAB571F.1000307@parallels.com>
Date: Tue, 05 Oct 2010 20:49:35 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Remove dead "else" branch from bc xprt creation
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Since the xprt in question is forcibly set to be bound the else
branch of this check is unneeded.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 114cca0..c0001ce 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2365,15 +2365,10 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 		goto out_err;
 	}
 
-	if (xprt_bound(xprt))
-		dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
-				xprt->address_strings[RPC_DISPLAY_ADDR],
-				xprt->address_strings[RPC_DISPLAY_PORT],
-				xprt->address_strings[RPC_DISPLAY_PROTO]);
-	else
-		dprintk("RPC:       set up xprt to %s (autobind) via %s\n",
-				xprt->address_strings[RPC_DISPLAY_ADDR],
-				xprt->address_strings[RPC_DISPLAY_PROTO]);
+	dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT],
+			xprt->address_strings[RPC_DISPLAY_PROTO]);
 
 	/*
 	 * Since we don't want connections for the backchannel, we set
-- 
1.5.5.6

