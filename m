Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:45973 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754679AbdLOB5A (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:00 -0500
Subject: [PATCH v1 08/16] xprtrdma: Remove another sockaddr_storage field
 (cdata::addr)
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:58 -0500
Message-ID: <20171215015658.13776.5532.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save more space in struct rpcrdma_xprt by removing the redundant
"addr" field from struct rpcrdma_create_data_internal. Wherever
we have rpcrdma_xprt, we also have the rpc_xprt, which has a
sockaddr_storage field with the same content.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    8 ++------
 net/sunrpc/xprtrdma/verbs.c     |   20 +++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
 3 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index f6d171e..8ba0aa8 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -361,9 +361,7 @@
 	/*
 	 * Set up RDMA-specific connect data.
 	 */
-
-	sap = (struct sockaddr *)&cdata.addr;
-	memcpy(sap, args->dstaddr, args->addrlen);
+	sap = args->dstaddr;
 
 	/* Ensure xprt->addr holds valid server TCP (not RDMA)
 	 * address, for any side protocols which peek at it */
@@ -397,7 +395,7 @@
 
 	new_xprt = rpcx_to_rdmax(xprt);
 
-	rc = rpcrdma_ia_open(new_xprt, sap);
+	rc = rpcrdma_ia_open(new_xprt);
 	if (rc)
 		goto out1;
 
@@ -483,8 +481,6 @@
 
 	sap = (struct sockaddr_in *)&xprt->addr;
 	sap->sin_port = htons(port);
-	sap = (struct sockaddr_in *)&rpcx_to_rdmad(xprt).addr;
-	sap->sin_port = htons(port);
 	dprintk("RPC:       %s: %u\n", __func__, port);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0b4d6a3..d6c737d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -294,8 +294,7 @@
 }
 
 static struct rdma_cm_id *
-rpcrdma_create_id(struct rpcrdma_xprt *xprt,
-			struct rpcrdma_ia *ia, struct sockaddr *addr)
+rpcrdma_create_id(struct rpcrdma_xprt *xprt, struct rpcrdma_ia *ia)
 {
 	unsigned long wtimeout = msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1;
 	struct rdma_cm_id *id;
@@ -314,7 +313,9 @@
 	}
 
 	ia->ri_async_rc = -ETIMEDOUT;
-	rc = rdma_resolve_addr(id, NULL, addr, RDMA_RESOLVE_TIMEOUT);
+	rc = rdma_resolve_addr(id, NULL,
+			       (struct sockaddr *)&xprt->rx_xprt.addr,
+			       RDMA_RESOLVE_TIMEOUT);
 	if (rc) {
 		dprintk("RPC:       %s: rdma_resolve_addr() failed %i\n",
 			__func__, rc);
@@ -361,19 +362,18 @@
 
 /**
  * rpcrdma_ia_open - Open and initialize an Interface Adapter.
- * @xprt: controlling transport
- * @addr: IP address of remote peer
+ * @xprt: transport with IA to (re)initialize
  *
  * Returns 0 on success, negative errno if an appropriate
  * Interface Adapter could not be found and opened.
  */
 int
-rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr)
+rpcrdma_ia_open(struct rpcrdma_xprt *xprt)
 {
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 	int rc;
 
-	ia->ri_id = rpcrdma_create_id(xprt, ia, addr);
+	ia->ri_id = rpcrdma_create_id(xprt, ia);
 	if (IS_ERR(ia->ri_id)) {
 		rc = PTR_ERR(ia->ri_id);
 		goto out_err;
@@ -649,13 +649,12 @@
 rpcrdma_ep_recreate_xprt(struct rpcrdma_xprt *r_xprt,
 			 struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	struct sockaddr *sap = (struct sockaddr *)&r_xprt->rx_data.addr;
 	int rc, err;
 
 	pr_info("%s: r_xprt = %p\n", __func__, r_xprt);
 
 	rc = -EHOSTUNREACH;
-	if (rpcrdma_ia_open(r_xprt, sap))
+	if (rpcrdma_ia_open(r_xprt))
 		goto out1;
 
 	rc = -ENOMEM;
@@ -687,7 +686,6 @@
 rpcrdma_ep_reconnect(struct rpcrdma_xprt *r_xprt, struct rpcrdma_ep *ep,
 		     struct rpcrdma_ia *ia)
 {
-	struct sockaddr *sap = (struct sockaddr *)&r_xprt->rx_data.addr;
 	struct rdma_cm_id *id, *old;
 	int err, rc;
 
@@ -696,7 +694,7 @@
 	rpcrdma_ep_disconnect(ep, ia);
 
 	rc = -EHOSTUNREACH;
-	id = rpcrdma_create_id(r_xprt, ia, sap);
+	id = rpcrdma_create_id(r_xprt, ia);
 	if (IS_ERR(id))
 		goto out;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0b28026..7c09e2a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -430,7 +430,6 @@ struct rpcrdma_buffer {
  * This data should be set with mount options
  */
 struct rpcrdma_create_data_internal {
-	struct sockaddr_storage	addr;	/* RDMA server address */
 	unsigned int	max_requests;	/* max requests (slots) in flight */
 	unsigned int	rsize;		/* mount rsize - max read hdr+data */
 	unsigned int	wsize;		/* mount wsize - max write hdr+data */
@@ -543,7 +542,7 @@ struct rpcrdma_xprt {
 /*
  * Interface Adapter calls - xprtrdma/verbs.c
  */
-int rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr);
+int rpcrdma_ia_open(struct rpcrdma_xprt *xprt);
 void rpcrdma_ia_remove(struct rpcrdma_ia *ia);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
 bool frwr_is_supported(struct rpcrdma_ia *);

