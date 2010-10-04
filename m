Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17680 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755782Ab0JDMv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:51:28 -0400
Message-ID: <4CA9CDCB.7070903@parallels.com>
Date: Mon, 04 Oct 2010 16:51:23 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/13] sunrpc: Remove unused sock arg from xs_get_srcport
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f9964ef..304e2de 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1515,7 +1515,7 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 	xs_update_peer_port(xprt);
 }
 
-static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
+static unsigned short xs_get_srcport(struct sock_xprt *transport)
 {
 	unsigned short port = transport->srcport;
 
@@ -1542,7 +1542,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 	};
 	struct sockaddr_in *sa;
 	int err, nloop = 0;
-	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short port = xs_get_srcport(transport);
 	unsigned short last;
 
 	sa = (struct sockaddr_in *)&transport->srcaddr;
@@ -1575,7 +1575,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 	};
 	struct sockaddr_in6 *sa;
 	int err, nloop = 0;
-	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short port = xs_get_srcport(transport);
 	unsigned short last;
 
 	sa = (struct sockaddr_in6 *)&transport->srcaddr;
-- 
1.5.5.6

