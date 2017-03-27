Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32947 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752813AbdC0OGX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:06:23 -0400
Subject: [PATCH v2 05/13] xprtrdma: Use same device when mapping or syncing
 DMA buffers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:06:15 -0400
Message-ID: <20170327140615.20813.31011.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the underlying device driver is reloaded, ia->ri_device will be
replaced. All cached copies of that device pointer have to be
updated as well.

Commit 54cbd6b0c6b9 ("xprtrdma: Delay DMA mapping Send and Receive
buffers") added the rg_device field to each regbuf. As part of
handling a device removal, rpcrdma_dma_unmap_regbuf is invoked on
all regbufs for a transport.

Simply calling rpcrdma_dma_map_regbuf for each Receive buffer after
the driver has been reloaded should reinitialize rg_device correctly
for every case except rpcrdma_wc_receive, which still uses
rpcrdma_rep::rr_device.

Ensure the same device that was used to map a Receive buffer is also
used to sync it in rpcrdma_wc_receive by using rg_device there
instead of rr_device.

This is the only use of rr_device, so it can be removed.

The use of regbufs in the send path is also updated, for
completeness.

Fixes: 54cbd6b0c6b9 ("xprtrdma: Delay DMA mapping Send and ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ++--
 net/sunrpc/xprtrdma/verbs.c     |   12 ++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 ++++++-
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a044be2..e68131b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -494,7 +494,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	}
 	sge->length = len;
 
-	ib_dma_sync_single_for_device(ia->ri_device, sge->addr,
+	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr,
 				      sge->length, DMA_TO_DEVICE);
 	req->rl_send_wr.num_sge++;
 	return true;
@@ -523,7 +523,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	sge[sge_no].addr = rdmab_addr(rb);
 	sge[sge_no].length = xdr->head[0].iov_len;
 	sge[sge_no].lkey = rdmab_lkey(rb);
-	ib_dma_sync_single_for_device(device, sge[sge_no].addr,
+	ib_dma_sync_single_for_device(rdmab_device(rb), sge[sge_no].addr,
 				      sge[sge_no].length, DMA_TO_DEVICE);
 
 	/* If there is a Read chunk, the page list is being handled
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d4880d5..c8813fb 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -180,7 +180,7 @@
 	rep->rr_wc_flags = wc->wc_flags;
 	rep->rr_inv_rkey = wc->ex.invalidate_rkey;
 
-	ib_dma_sync_single_for_cpu(rep->rr_device,
+	ib_dma_sync_single_for_cpu(rdmab_device(rep->rr_rdmabuf),
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
 
@@ -878,7 +878,6 @@ struct rpcrdma_rep *
 rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_rep *rep;
 	int rc;
 
@@ -894,7 +893,6 @@ struct rpcrdma_rep *
 		goto out_free;
 	}
 
-	rep->rr_device = ia->ri_device;
 	rep->rr_cqe.done = rpcrdma_wc_receive;
 	rep->rr_rxprt = r_xprt;
 	INIT_WORK(&rep->rr_work, rpcrdma_reply_handler);
@@ -1232,17 +1230,19 @@ struct rpcrdma_regbuf *
 bool
 __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
 {
+	struct ib_device *device = ia->ri_device;
+
 	if (rb->rg_direction == DMA_NONE)
 		return false;
 
-	rb->rg_iov.addr = ib_dma_map_single(ia->ri_device,
+	rb->rg_iov.addr = ib_dma_map_single(device,
 					    (void *)rb->rg_base,
 					    rdmab_length(rb),
 					    rb->rg_direction);
-	if (ib_dma_mapping_error(ia->ri_device, rdmab_addr(rb)))
+	if (ib_dma_mapping_error(device, rdmab_addr(rb)))
 		return false;
 
-	rb->rg_device = ia->ri_device;
+	rb->rg_device = device;
 	rb->rg_iov.lkey = ia->ri_pd->local_dma_lkey;
 	return true;
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index af844fc..9d58260 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -164,6 +164,12 @@ struct rpcrdma_regbuf {
 	return (struct rpcrdma_msg *)rb->rg_base;
 }
 
+static inline struct ib_device *
+rdmab_device(struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_device;
+}
+
 #define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
 
 /* To ensure a transport can always make forward progress,
@@ -209,7 +215,6 @@ struct rpcrdma_rep {
 	unsigned int		rr_len;
 	int			rr_wc_flags;
 	u32			rr_inv_rkey;
-	struct ib_device	*rr_device;
 	struct rpcrdma_xprt	*rr_rxprt;
 	struct work_struct	rr_work;
 	struct list_head	rr_list;

