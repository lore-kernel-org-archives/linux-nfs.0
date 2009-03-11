From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/30] SUNRPC: Don't disconnect if a connection is still in
 progress.
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.39213.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbZCKSpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:14 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj6hv022202
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:12 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cb4bd93..9d1898f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1613,10 +1613,9 @@ out:
  * We need to preserve the port number so the reply cache on the server can
  * find our cached RPC replies when we get around to reconnecting.
  */
-static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
+static void xs_abort_connection(struct rpc_xprt *xprt, struct sock_xprt *transport)
 {
 	int result;
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct sockaddr any;
 
 	dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
@@ -1633,6 +1632,17 @@ static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
 				result);
 }
 
+static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct sock_xprt *transport)
+{
+	unsigned int state = transport->inet->sk_state;
+
+	if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED)
+		return;
+	if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
+		return;
+	xs_abort_connection(xprt, transport);
+}
+
 static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1706,7 +1716,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 		}
 	} else
 		/* "close" the socket, preserving the local port */
-		xs_tcp_reuse_connection(xprt);
+		xs_tcp_reuse_connection(xprt, transport);
 
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
@@ -1766,7 +1776,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 		}
 	} else
 		/* "close" the socket, preserving the local port */
-		xs_tcp_reuse_connection(xprt);
+		xs_tcp_reuse_connection(xprt, transport);
 
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);

