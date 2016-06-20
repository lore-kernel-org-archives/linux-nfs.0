Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32829 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012AbcFTQJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:09:42 -0400
Subject: [PATCH v3 08/25] xprtrdma: Remove ALLPHYSICAL memory registration
 mode
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:09:40 -0400
Message-ID: <20160620160940.10809.61457.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No HCA or RNIC in the kernel tree requires the use of ALLPHYSICAL.

ALLPHYSICAL advertises in the clear on the network fabric an R_key
that is good for all of the client's memory. No known exploit
exists, but theoretically any user on the server can use that R_key
on the client's QP to read or update any part of the client's memory.

ALLPHYSICAL exposes the client to server bugs, including:
 o base/bounds errors causing data outside the i/o buffer to be
   accessed
 o RDMA access after reply causing data corruption and/or integrity
   fail

ALLPHYSICAL can't protect application memory regions from server
update after a local signal or soft timeout has terminated an RPC.

ALLPHYSICAL chunks are no larger than a page. Special cases to
handle small chunks and long chunk lists have been a source of
implementation complexity and bugs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/Makefile       |    2 -
 net/sunrpc/xprtrdma/physical_ops.c |  122 ------------------------------------
 net/sunrpc/xprtrdma/verbs.c        |   15 ----
 net/sunrpc/xprtrdma/xprt_rdma.h    |    5 -
 4 files changed, 2 insertions(+), 142 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/physical_ops.c

diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index dc9f3b5..ef19fa4 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_SUNRPC_XPRT_RDMA) += rpcrdma.o
 
 rpcrdma-y := transport.o rpc_rdma.o verbs.o \
-	fmr_ops.o frwr_ops.o physical_ops.o \
+	fmr_ops.o frwr_ops.o \
 	svc_rdma.o svc_rdma_backchannel.o svc_rdma_transport.o \
 	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o \
 	module.o
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
deleted file mode 100644
index 3750596..0000000
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ /dev/null
@@ -1,122 +0,0 @@
-/*
- * Copyright (c) 2015 Oracle.  All rights reserved.
- * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
- */
-
-/* No-op chunk preparation. All client memory is pre-registered.
- * Sometimes referred to as ALLPHYSICAL mode.
- *
- * Physical registration is simple because all client memory is
- * pre-registered and never deregistered. This mode is good for
- * adapter bring up, but is considered not safe: the server is
- * trusted not to abuse its access to client memory not involved
- * in RDMA I/O.
- */
-
-#include "xprt_rdma.h"
-
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY	RPCDBG_TRANS
-#endif
-
-static int
-physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
-		 struct rpcrdma_create_data_internal *cdata)
-{
-	struct ib_mr *mr;
-
-	/* Obtain an rkey to use for RPC data payloads.
-	 */
-	mr = ib_get_dma_mr(ia->ri_pd,
-			   IB_ACCESS_LOCAL_WRITE |
-			   IB_ACCESS_REMOTE_WRITE |
-			   IB_ACCESS_REMOTE_READ);
-	if (IS_ERR(mr)) {
-		pr_err("%s: ib_get_dma_mr for failed with %lX\n",
-		       __func__, PTR_ERR(mr));
-		return -ENOMEM;
-	}
-	ia->ri_dma_mr = mr;
-
-	rpcrdma_set_max_header_sizes(ia, cdata, min_t(unsigned int,
-						      RPCRDMA_MAX_DATA_SEGS,
-						      RPCRDMA_MAX_HDR_SEGS));
-	return 0;
-}
-
-/* PHYSICAL memory registration conveys one page per chunk segment.
- */
-static size_t
-physical_op_maxpages(struct rpcrdma_xprt *r_xprt)
-{
-	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS);
-}
-
-static int
-physical_op_init(struct rpcrdma_xprt *r_xprt)
-{
-	return 0;
-}
-
-/* The client's physical memory is already exposed for
- * remote access via RDMA READ or RDMA WRITE.
- */
-static int
-physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-		int nsegs, bool writing)
-{
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-
-	rpcrdma_map_one(ia->ri_device, seg, rpcrdma_data_dir(writing));
-	seg->mr_rkey = ia->ri_dma_mr->rkey;
-	seg->mr_base = seg->mr_dma;
-	return 1;
-}
-
-/* DMA unmap all memory regions that were mapped for "req".
- */
-static void
-physical_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
-{
-	struct ib_device *device = r_xprt->rx_ia.ri_device;
-	unsigned int i;
-
-	for (i = 0; req->rl_nchunks; --req->rl_nchunks)
-		rpcrdma_unmap_one(device, &req->rl_segments[i++]);
-}
-
-/* Use a slow, safe mechanism to invalidate all memory regions
- * that were registered for "req".
- *
- * For physical memory registration, there is no good way to
- * fence a single MR that has been advertised to the server. The
- * client has already handed the server an R_key that cannot be
- * invalidated and is shared by all MRs on this connection.
- * Tearing down the PD might be the only safe choice, but it's
- * not clear that a freshly acquired DMA R_key would be different
- * than the one used by the PD that was just destroyed.
- * FIXME.
- */
-static void
-physical_op_unmap_safe(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-		       bool sync)
-{
-	physical_op_unmap_sync(r_xprt, req);
-}
-
-static void
-physical_op_destroy(struct rpcrdma_buffer *buf)
-{
-}
-
-const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
-	.ro_map				= physical_op_map,
-	.ro_unmap_sync			= physical_op_unmap_sync,
-	.ro_unmap_safe			= physical_op_unmap_safe,
-	.ro_open			= physical_op_open,
-	.ro_maxpages			= physical_op_maxpages,
-	.ro_init			= physical_op_init,
-	.ro_destroy			= physical_op_destroy,
-	.ro_displayname			= "physical",
-};
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 77a371d..5ee98e9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -379,8 +379,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
 	int rc;
 
-	ia->ri_dma_mr = NULL;
-
 	ia->ri_id = rpcrdma_create_id(xprt, ia, addr);
 	if (IS_ERR(ia->ri_id)) {
 		rc = PTR_ERR(ia->ri_id);
@@ -418,9 +416,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	case RPCRDMA_FRMR:
 		ia->ri_ops = &rpcrdma_frwr_memreg_ops;
 		break;
-	case RPCRDMA_ALLPHYSICAL:
-		ia->ri_ops = &rpcrdma_physical_memreg_ops;
-		break;
 	case RPCRDMA_MTHCAFMR:
 		ia->ri_ops = &rpcrdma_fmr_memreg_ops;
 		break;
@@ -585,8 +580,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 out2:
 	ib_free_cq(sendcq);
 out1:
-	if (ia->ri_dma_mr)
-		ib_dereg_mr(ia->ri_dma_mr);
 	return rc;
 }
 
@@ -600,8 +593,6 @@ out1:
 void
 rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	int rc;
-
 	dprintk("RPC:       %s: entering, connected is %d\n",
 		__func__, ep->rep_connected);
 
@@ -615,12 +606,6 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 
 	ib_free_cq(ep->rep_attr.recv_cq);
 	ib_free_cq(ep->rep_attr.send_cq);
-
-	if (ia->ri_dma_mr) {
-		rc = ib_dereg_mr(ia->ri_dma_mr);
-		dprintk("RPC:       %s: ib_dereg_mr returned %i\n",
-			__func__, rc);
-	}
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4e03037..bcb168e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -68,7 +68,6 @@ struct rpcrdma_ia {
 	struct ib_device	*ri_device;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
-	struct ib_mr		*ri_dma_mr;
 	struct completion	ri_done;
 	int			ri_async_rc;
 	unsigned int		ri_max_frmr_depth;
@@ -269,8 +268,7 @@ struct rpcrdma_mw {
  * NOTES:
  *   o RPCRDMA_MAX_SEGS is the max number of addressible chunk elements we
  *     marshal. The number needed varies depending on the iov lists that
- *     are passed to us, the memory registration mode we are in, and if
- *     physical addressing is used, the layout.
+ *     are passed to us and the memory registration mode we are in.
  */
 
 struct rpcrdma_mr_seg {		/* chunk descriptors */
@@ -417,7 +415,6 @@ struct rpcrdma_memreg_ops {
 
 extern const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops;
 extern const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops;
-extern const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops;
 
 /*
  * RPCRDMA transport -- encapsulates the structures above for

