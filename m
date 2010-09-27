Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45469 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab0I0KJV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:09:21 -0400
Message-ID: <4CA06D45.10803@parallels.com>
Date: Mon, 27 Sep 2010 14:09:09 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] sunrpc: Tag rpc_xprt with net
References: <4CA06C7A.5060307@parallels.com>
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The net is known from the xprt_create and this tagging will also
give us the context in the connection workers where real sockets
are created.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index cd27538..83ae00a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -224,6 +224,7 @@ struct rpc_xprt {
 					bklog_u;	/* backlog queue utilization */
 	} stat;
 
+	struct net		*xprt_net;
 	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 98d4b7b..292f449 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2296,11 +2296,13 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	if (args->srcaddr)
 		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
 
+	xprt->xprt_net = get_net(args->net);
 	return xprt;
 }
 
 static void xs_free_xprt(struct rpc_xprt *xprt)
 {
+	put_net(xprt->xprt_net);
 	kfree(xprt->slot);
 	kfree(xprt);
 }
-- 
1.5.5.6

