Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35368 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988AbcFGTrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:47:02 -0400
Subject: [PATCH v1 05/20] xprtrdma: Remove rpcrdma_map_one() and friends
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:46:59 -0400
Message-ID: <20160607194659.18401.61061.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: ALLPHYSICAL is gone and FMR has been converted to use
scatterlists. There are no more users of these functions.

This patch shrinks the size of struct rpcrdma_req by about 3500
bytes on x86_64. There is one of these structs for each RPC credit
(128 credits per transport connection).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    8 --------
 net/sunrpc/xprtrdma/xprt_rdma.h |   36 ------------------------------------
 2 files changed, 44 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ecd494a..4f7e1ba 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1048,14 +1048,6 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
  * Wrappers for internal-use kmalloc memory registration, used by buffer code.
  */
 
-void
-rpcrdma_mapping_error(struct rpcrdma_mr_seg *seg)
-{
-	dprintk("RPC:       map_one: offset %p iova %llx len %zu\n",
-		seg->mr_offset,
-		(unsigned long long)seg->mr_dma, seg->mr_dmalen);
-}
-
 /**
  * rpcrdma_alloc_regbuf - kmalloc and register memory for SEND/RECV buffers
  * @ia: controlling rpcrdma_ia
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6378469..3472844 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -278,9 +278,6 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 	u32		mr_rkey;	/* registration result */
 	u32		mr_len;		/* length of chunk or segment */
 	int		mr_nsegs;	/* number of segments in chunk or 0 */
-	enum dma_data_direction	mr_dir;	/* segment mapping direction */
-	dma_addr_t	mr_dma;		/* segment mapping address */
-	size_t		mr_dmalen;	/* segment mapping length */
 	struct page	*mr_page;	/* owning page, if any */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
@@ -491,45 +488,12 @@ void rpcrdma_destroy_wq(void);
  * Wrappers for chunk registration, shared by read/write chunk code.
  */
 
-void rpcrdma_mapping_error(struct rpcrdma_mr_seg *);
-
 static inline enum dma_data_direction
 rpcrdma_data_dir(bool writing)
 {
 	return writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 }
 
-static inline void
-rpcrdma_map_one(struct ib_device *device, struct rpcrdma_mr_seg *seg,
-		enum dma_data_direction direction)
-{
-	seg->mr_dir = direction;
-	seg->mr_dmalen = seg->mr_len;
-
-	if (seg->mr_page)
-		seg->mr_dma = ib_dma_map_page(device,
-				seg->mr_page, offset_in_page(seg->mr_offset),
-				seg->mr_dmalen, seg->mr_dir);
-	else
-		seg->mr_dma = ib_dma_map_single(device,
-				seg->mr_offset,
-				seg->mr_dmalen, seg->mr_dir);
-
-	if (ib_dma_mapping_error(device, seg->mr_dma))
-		rpcrdma_mapping_error(seg);
-}
-
-static inline void
-rpcrdma_unmap_one(struct ib_device *device, struct rpcrdma_mr_seg *seg)
-{
-	if (seg->mr_page)
-		ib_dma_unmap_page(device,
-				  seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
-	else
-		ib_dma_unmap_single(device,
-				    seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
-}
-
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c
  */

