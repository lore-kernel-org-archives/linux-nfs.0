From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svcrdma: Fix compile warning on 32b platforms
Date: Fri, 23 May 2008 10:39:53 -0500
Message-ID: <1211557193.4114.21.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55389 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753355AbYEWPgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2008 11:36:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ib_sge is used to store both dma_addr_t and virtual addresses.
This causes a warning on 32b platforms when casting ptrs to the
u64 addr field of the ib_sge. There is work underway to reduce the
memory footprint of the WR context in 2.6.27 the time frame that will
remove the overloading of the ib_sge.addr field.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

Thanks to Bruce and Andrew for pointing this out. I will compile-test both
32b and 64b platforms in the future.

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 4da0d1d..dbab252 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -231,7 +231,8 @@ static void rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 		atomic_inc(&xprt->sc_dma_used);
 		ctxt->sge[i].addr = (unsigned long)
 			ib_dma_map_single(xprt->sc_cm_id->device,
-					  (void*)sge[i].addr, sge[i].length,
+					  (void*)(unsigned long)
+					  sge[i].addr, sge[i].length,
 					  DMA_FROM_DEVICE);
 		ctxt->sge[i].length = sge[i].length;
 		ctxt->sge[i].lkey = sge[i].lkey;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index cdb0732..eeee078 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -177,7 +177,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		atomic_inc(&xprt->sc_dma_used);
 		sge[sge_no].addr =
 			ib_dma_map_single(xprt->sc_cm_id->device,
-					  (void *)
+					  (void *)(unsigned long)
 					  xdr_sge[xdr_sge_no].addr + sge_off,
 					  sge_bytes, DMA_TO_DEVICE);
 		if (dma_mapping_error(sge[sge_no].addr))
@@ -416,7 +416,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		atomic_inc(&rdma->sc_dma_used);
 		ctxt->sge[sge_no].addr =
 			ib_dma_map_single(rdma->sc_cm_id->device,
-					  (void *)
+					  (void *)(unsigned long)
 					  ctxt->sge[sge_no].addr,
 					  sge_bytes, DMA_TO_DEVICE);
 	}

