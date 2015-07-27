Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:54242 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754525AbbG0W6F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 18:58:05 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 3/4] svcrdma: Use max_sge_rd for destination read depths
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Mon, 27 Jul 2015 17:58:05 -0500
Message-ID: <20150727225804.9959.89530.stgit@build2.ogc.int>
In-Reply-To: <20150727225408.9959.78916.stgit@build2.ogc.int>
References: <20150727225408.9959.78916.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   12 +-----------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++++
 3 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index cb94ee4..83211bc 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -132,6 +132,7 @@ struct svcxprt_rdma {
 	struct list_head     sc_accept_q;	/* Conn. waiting accept */
 	int		     sc_ord;		/* RDMA read limit */
 	int                  sc_max_sge;
+	int                  sc_max_sge_rd;	/* max sge for read target */
 
 	int                  sc_sq_depth;	/* Depth of SQ */
 	atomic_t             sc_sq_count;	/* Number of SQ WR on queue */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 2e1348b..cb51742 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -115,15 +115,6 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	rqstp->rq_arg.tail[0].iov_len = 0;
 }
 
-static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
-{
-	if (!rdma_cap_read_multi_sge(xprt->sc_cm_id->device,
-				     xprt->sc_cm_id->port_num))
-		return 1;
-	else
-		return min_t(int, sge_count, xprt->sc_max_sge);
-}
-
 /* Issue an RDMA_READ using the local lkey to map the data sink */
 int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 			struct svc_rqst *rqstp,
@@ -144,8 +135,7 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->read_hdr = head;
-	pages_needed =
-		min_t(int, pages_needed, rdma_read_max_sge(xprt, pages_needed));
+	pages_needed = min_t(int, pages_needed, xprt->sc_max_sge_rd);
 	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
 
 	for (pno = 0; pno < pages_needed; pno++) {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6b36279..fdc850f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -872,6 +872,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 * capabilities of this particular device */
 	newxprt->sc_max_sge = min((size_t)devattr.max_sge,
 				  (size_t)RPCSVC_MAXPAGES);
+	newxprt->sc_max_sge_rd = min_t(size_t, devattr.max_sge_rd,
+				       RPCSVC_MAXPAGES);
 	newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
 				   (size_t)svcrdma_max_requests);
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
@@ -1046,6 +1048,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		"    remote_ip       : %pI4\n"
 		"    remote_port     : %d\n"
 		"    max_sge         : %d\n"
+		"    max_sge_rd      : %d\n"
 		"    sq_depth        : %d\n"
 		"    max_requests    : %d\n"
 		"    ord             : %d\n",
@@ -1059,6 +1062,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
 		       route.addr.dst_addr)->sin_port),
 		newxprt->sc_max_sge,
+		newxprt->sc_max_sge_rd,
 		newxprt->sc_sq_depth,
 		newxprt->sc_max_requests,
 		newxprt->sc_ord);

