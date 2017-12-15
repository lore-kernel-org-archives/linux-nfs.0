Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:38914 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754628AbdLOB5I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:08 -0500
Subject: [PATCH v1 09/16] xprtrdma: Support IPv6 in xprt_rdma_set_port
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:06 -0500
Message-ID: <20171215015706.13776.10025.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up a harmless oversight. xprtrdma's ->set_port method has
never properly supported IPv6.

This issue has never been a problem because NFS/RDMA mounts have
always required "port=20049", thus so far, rpcbind is not invoked
for these mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8ba0aa8..cebcd02 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -474,14 +474,34 @@
 	rpcrdma_ep_disconnect(ep, ia);
 }
 
+/**
+ * xprt_rdma_set_port - update server port with rpcbind result
+ * @xprt: controlling RPC transport
+ * @port: new port value
+ *
+ * Transport connect status is unchanged.
+ */
 static void
 xprt_rdma_set_port(struct rpc_xprt *xprt, u16 port)
 {
-	struct sockaddr_in *sap;
+	struct sockaddr *sap = (struct sockaddr *)&xprt->addr;
+	char buf[8];
+
+	dprintk("RPC:       %s: setting port for xprt %p (%s:%s) to %u\n",
+		__func__, xprt,
+		xprt->address_strings[RPC_DISPLAY_ADDR],
+		xprt->address_strings[RPC_DISPLAY_PORT],
+		port);
+
+	rpc_set_port(sap, port);
 
-	sap = (struct sockaddr_in *)&xprt->addr;
-	sap->sin_port = htons(port);
-	dprintk("RPC:       %s: %u\n", __func__, port);
+	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
+	snprintf(buf, sizeof(buf), "%u", port);
+	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
+
+	kfree(xprt->address_strings[RPC_DISPLAY_HEX_PORT]);
+	snprintf(buf, sizeof(buf), "%4hx", port);
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 }
 
 /**

