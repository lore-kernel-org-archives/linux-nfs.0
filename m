From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 100/112] SUNRPC: Clean up functions that free
	address_strings array
Date: Fri, 25 Jan 2008 11:38:00 -0500
Message-ID: <20080125163759.31887.1374.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687AbYAYQ7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:50 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlnn019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:49 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: document the rule (kfree) and the exceptions
(RPC_DISPLAY_PROTO and RPC_DISPLAY_NETID) when freeing the objects in
a transport's address_strings array.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtrdma/transport.c |   16 ++++++++++------
 net/sunrpc/xprtsock.c           |   16 ++++++++++------
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d1389af..02c522c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -212,12 +212,16 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 static void
 xprt_rdma_free_addresses(struct rpc_xprt *xprt)
 {
-	kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
-	kfree(xprt->address_strings[RPC_DISPLAY_HEX_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_HEX_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR]);
+	unsigned int i;
+
+	for (i = 0; i < RPC_DISPLAY_MAX; i++)
+		switch (i) {
+		case RPC_DISPLAY_PROTO:
+		case RPC_DISPLAY_NETID:
+			continue;
+		default:
+			kfree(xprt->address_strings[i]);
+		}
 }
 
 static void
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 17e1721..7f1e686 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -398,12 +398,16 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 {
-	kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
-	kfree(xprt->address_strings[RPC_DISPLAY_HEX_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_HEX_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR]);
+	unsigned int i;
+
+	for (i = 0; i < RPC_DISPLAY_MAX; i++)
+		switch (i) {
+		case RPC_DISPLAY_PROTO:
+		case RPC_DISPLAY_NETID:
+			continue;
+		default:
+			kfree(xprt->address_strings[i]);
+		}
 }
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
