Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30612 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755805Ab0JDMw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:52:29 -0400
Message-ID: <4CA9CE09.8060208@parallels.com>
Date: Mon, 04 Oct 2010 16:52:25 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/13] sunrpc: Get xprt pointer once in xs_tcp_setup_socket
References: <4CA9CDA8.4010407@parallels.com>
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprtsock.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 024a644..a76446a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1851,12 +1851,12 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
-		struct sock_xprt *transport,
+static void xs_tcp_setup_socket(struct sock_xprt *transport,
 		struct socket *(*create_sock)(struct rpc_xprt *,
 			struct sock_xprt *))
 {
 	struct socket *sock = transport->sock;
+	struct rpc_xprt *xprt = &transport->xprt;
 	int status = -EIO;
 
 	if (xprt->shutdown)
@@ -1958,9 +1958,8 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
-	struct rpc_xprt *xprt = &transport->xprt;
 
-	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock4);
+	xs_tcp_setup_socket(transport, xs_create_tcp_sock4);
 }
 
 static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
@@ -1997,9 +1996,8 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
-	struct rpc_xprt *xprt = &transport->xprt;
 
-	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock6);
+	xs_tcp_setup_socket(transport, xs_create_tcp_sock6);
 }
 
 /**
-- 
1.5.5.6

