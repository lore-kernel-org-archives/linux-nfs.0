Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33737 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbLNVTI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:19:08 -0500
Subject: [PATCH v3 08/11] xprtrdma: Add ro_unmap_sync method for
 all-physical registration
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:19:07 -0500
Message-ID: <20151214211907.16295.8183.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

physical's ro_unmap is synchronous already. The new ro_unmap_sync
method just has to DMA unmap all MRs associated with the RPC
request.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/physical_ops.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index 617b76f..dbb302e 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -83,6 +83,18 @@ physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	return 1;
 }
 
+/* DMA unmap all memory regions that were mapped for "req".
+ */
+static void
+physical_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+{
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
+	unsigned int i;
+
+	for (i = 0; req->rl_nchunks; --req->rl_nchunks)
+		rpcrdma_unmap_one(device, &req->rl_segments[i++]);
+}
+
 static void
 physical_op_destroy(struct rpcrdma_buffer *buf)
 {
@@ -90,6 +102,7 @@ physical_op_destroy(struct rpcrdma_buffer *buf)
 
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
+	.ro_unmap_sync			= physical_op_unmap_sync,
 	.ro_unmap			= physical_op_unmap,
 	.ro_open			= physical_op_open,
 	.ro_maxpages			= physical_op_maxpages,

