From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 05/11] svcrdma: Add dma map count and WARN_ON
Date: Wed,  2 Jul 2008 21:27:37 -0500
Message-ID: <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48836 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753395AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a dma map count in order to verify that all DMA mapping resources
have been freed when the transport is closed.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +++++
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index fd5e8a1..ab93afc 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -130,6 +130,7 @@ struct svcxprt_rdma {
 
 	struct ib_pd         *sc_pd;
 
+	atomic_t	     sc_dma_used;
 	atomic_t	     sc_ctxt_used;
 	struct list_head     sc_ctxt_free;
 	int		     sc_ctxt_cnt;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index d25971b..b4b17f4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -222,6 +222,7 @@ static void rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 	ctxt->count = count;
 	ctxt->direction = DMA_FROM_DEVICE;
 	for (i = 0; i < count; i++) {
+		atomic_inc(&xprt->sc_dma_used);
 		ctxt->sge[i].addr =
 			ib_dma_map_single(xprt->sc_cm_id->device,
 					  vec[i].iov_base, vec[i].iov_len,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index bdc11a3..a19b22b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -163,6 +163,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		sge_bytes = min((size_t)bc,
 				(size_t)(vec->sge[xdr_sge_no].iov_len-sge_off));
 		sge[sge_no].length = sge_bytes;
+		atomic_inc(&xprt->sc_dma_used);
 		sge[sge_no].addr =
 			ib_dma_map_single(xprt->sc_cm_id->device,
 					  (void *)
@@ -385,6 +386,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	ctxt->count = 1;
 
 	/* Prepare the SGE for the RPCRDMA Header */
+	atomic_inc(&rdma->sc_dma_used);
 	ctxt->sge[0].addr =
 		ib_dma_map_page(rdma->sc_cm_id->device,
 				page, 0, PAGE_SIZE, DMA_TO_DEVICE);
@@ -396,6 +398,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
 		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
 		byte_count -= sge_bytes;
+		atomic_inc(&rdma->sc_dma_used);
 		ctxt->sge[sge_no].addr =
 			ib_dma_map_single(rdma->sc_cm_id->device,
 					  vec->sge[sge_no].iov_base,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 7e8ee66..6fddd58 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -155,6 +155,7 @@ static void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 	struct svcxprt_rdma *xprt = ctxt->xprt;
 	int i;
 	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
+		atomic_dec(&xprt->sc_dma_used);
 		ib_dma_unmap_single(xprt->sc_cm_id->device,
 				    ctxt->sge[i].addr,
 				    ctxt->sge[i].length,
@@ -519,6 +520,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	cma_xprt->sc_max_requests = svcrdma_max_requests;
 	cma_xprt->sc_sq_depth = svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT;
 	atomic_set(&cma_xprt->sc_sq_count, 0);
+	atomic_set(&cma_xprt->sc_ctxt_used, 0);
 
 	if (!listener) {
 		int reqs = cma_xprt->sc_max_requests;
@@ -569,6 +571,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		BUG_ON(sge_no >= xprt->sc_max_sge);
 		page = svc_rdma_get_page();
 		ctxt->pages[sge_no] = page;
+		atomic_inc(&xprt->sc_dma_used);
 		pa = ib_dma_map_page(xprt->sc_cm_id->device,
 				     page, 0, PAGE_SIZE,
 				     DMA_FROM_DEVICE);
@@ -1049,6 +1052,7 @@ static void __svc_rdma_free(struct work_struct *work)
 
 	/* Warn if we leaked a resource or under-referenced */
 	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
+	WARN_ON(atomic_read(&rdma->sc_dma_used) != 0);
 
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
@@ -1169,6 +1173,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
 
 	/* Prepare SGE for local address */
+	atomic_inc(&xprt->sc_dma_used);
 	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
 				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
 	sge.lkey = xprt->sc_phys_mr->lkey;
