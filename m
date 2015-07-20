Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33564 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818AbbGTTCg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 15:02:36 -0400
Subject: [PATCH v3 01/15] xprtrdma: Make xprt_setup_rdma() agnostic to
 family of server address
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jul 2015 15:02:33 -0400
Message-ID: <20150720190233.10997.29445.stgit@manet.1015granger.net>
In-Reply-To: <20150720185624.10997.51574.stgit@manet.1015granger.net>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In particular, recognize when an IPv6 connection is bound.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/transport.c |   28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 680f888..d737300 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -175,10 +175,8 @@ xprt_rdma_format_addresses6(struct rpc_xprt *xprt, struct sockaddr *sap)
 }
 
 static void
-xprt_rdma_format_addresses(struct rpc_xprt *xprt)
+xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap)
 {
-	struct sockaddr *sap = (struct sockaddr *)
-					&rpcx_to_rdmad(xprt).addr;
 	char buf[128];
 
 	switch (sap->sa_family) {
@@ -302,7 +300,7 @@ xprt_setup_rdma(struct xprt_create *args)
 	struct rpc_xprt *xprt;
 	struct rpcrdma_xprt *new_xprt;
 	struct rpcrdma_ep *new_ep;
-	struct sockaddr_in *sin;
+	struct sockaddr *sap;
 	int rc;
 
 	if (args->addrlen > sizeof(xprt->addr)) {
@@ -333,26 +331,20 @@ xprt_setup_rdma(struct xprt_create *args)
 	 * Set up RDMA-specific connect data.
 	 */
 
-	/* Put server RDMA address in local cdata */
-	memcpy(&cdata.addr, args->dstaddr, args->addrlen);
+	sap = (struct sockaddr *)&cdata.addr;
+	memcpy(sap, args->dstaddr, args->addrlen);
 
 	/* Ensure xprt->addr holds valid server TCP (not RDMA)
 	 * address, for any side protocols which peek at it */
 	xprt->prot = IPPROTO_TCP;
 	xprt->addrlen = args->addrlen;
-	memcpy(&xprt->addr, &cdata.addr, xprt->addrlen);
+	memcpy(&xprt->addr, sap, xprt->addrlen);
 
-	sin = (struct sockaddr_in *)&cdata.addr;
-	if (ntohs(sin->sin_port) != 0)
+	if (rpc_get_port(sap))
 		xprt_set_bound(xprt);
 
-	dprintk("RPC:       %s: %pI4:%u\n",
-		__func__, &sin->sin_addr.s_addr, ntohs(sin->sin_port));
-
-	/* Set max requests */
 	cdata.max_requests = xprt->max_reqs;
 
-	/* Set some length limits */
 	cdata.rsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA write max */
 	cdata.wsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA read max */
 
@@ -375,8 +367,7 @@ xprt_setup_rdma(struct xprt_create *args)
 
 	new_xprt = rpcx_to_rdmax(xprt);
 
-	rc = rpcrdma_ia_open(new_xprt, (struct sockaddr *) &cdata.addr,
-				xprt_rdma_memreg_strategy);
+	rc = rpcrdma_ia_open(new_xprt, sap, xprt_rdma_memreg_strategy);
 	if (rc)
 		goto out1;
 
@@ -409,7 +400,7 @@ xprt_setup_rdma(struct xprt_create *args)
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
 
-	xprt_rdma_format_addresses(xprt);
+	xprt_rdma_format_addresses(xprt, sap);
 	xprt->max_payload = new_xprt->rx_ia.ri_ops->ro_maxpages(new_xprt);
 	if (xprt->max_payload == 0)
 		goto out4;
@@ -420,6 +411,9 @@ xprt_setup_rdma(struct xprt_create *args)
 	if (!try_module_get(THIS_MODULE))
 		goto out4;
 
+	dprintk("RPC:       %s: %s:%s\n", __func__,
+		xprt->address_strings[RPC_DISPLAY_ADDR],
+		xprt->address_strings[RPC_DISPLAY_PORT]);
 	return xprt;
 
 out4:

