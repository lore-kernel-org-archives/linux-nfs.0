Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47372 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab0JDMwB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:52:01 -0400
Message-ID: <4CA9CDEC.1080201@parallels.com>
Date: Mon, 04 Oct 2010 16:51:56 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/13] sunrpc: Remove unused sock arg from xs_next_srcport
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
index 304e2de..024a644 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1524,7 +1524,7 @@ static unsigned short xs_get_srcport(struct sock_xprt *transport)
 	return port;
 }
 
-static unsigned short xs_next_srcport(struct sock_xprt *transport, struct socket *sock, unsigned short port)
+static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned short port)
 {
 	if (transport->srcport != 0)
 		transport->srcport = 0;
@@ -1558,7 +1558,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 			break;
 		}
 		last = port;
-		port = xs_next_srcport(transport, sock, port);
+		port = xs_next_srcport(transport, port);
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
@@ -1591,7 +1591,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 			break;
 		}
 		last = port;
-		port = xs_next_srcport(transport, sock, port);
+		port = xs_next_srcport(transport, port);
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
-- 
1.5.5.6

