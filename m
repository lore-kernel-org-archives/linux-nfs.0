Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51054 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752786AbbGEXWT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jul 2015 19:22:19 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V3 4/5] svcrdma: Use transport independent MR allocation
To: dledford@redhat.com
Cc: sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Date: Sun, 05 Jul 2015 18:22:19 -0500
Message-ID: <20150705232217.12029.97472.stgit@build2.ogc.int>
In-Reply-To: <20150705231831.12029.80307.stgit@build2.ogc.int>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use rdma_get_dma_mr() to allocat DMA MRs.

Use rdma_fast_reg_access_flags() to compute the needed
access flags in fast register operations.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    3 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++++++-------------------
 2 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 86b4416..81fd5e0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -249,7 +249,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 
 	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
 	frmr->direction = DMA_FROM_DEVICE;
-	frmr->access_flags = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
+	frmr->access_flags = rdma_fast_reg_access_flags(xprt->sc_pd,
+							RDMA_MRR_READ_DEST, 0);
 	frmr->map_len = pages_needed << PAGE_SHIFT;
 	frmr->page_list_len = pages_needed;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f4cfa76..5ad65d9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -858,7 +858,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct ib_cq_init_attr cq_attr = {};
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device_attr devattr;
-	int uninitialized_var(dma_mr_acc);
+	int uninitialized_var(dma_mr_roles);
 	int need_dma_mr = 0;
 	int ret;
 	int i;
@@ -961,26 +961,18 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 
 	/*
-	 * Use the most secure set of MR resources based on the
-	 * transport type and available memory management features in
-	 * the device. Here's the table implemented below:
+	 * Use the most secure set of MR resources based on the available
+	 * memory management features in the device. Here's the table
+	 * implemented below:
 	 *
-	 *		Fast	Global	DMA	Remote WR
-	 *		Reg	LKEY	MR	Access
-	 *		Sup'd	Sup'd	Needed	Needed
+	 *		Fast	Global	DMA
+	 *		Reg	LKEY	MR
+	 *		Sup'd	Sup'd	Needed
 	 *
-	 * IWARP	N	N	Y	Y
-	 *		N	Y	Y	Y
-	 *		Y	N	Y	N
-	 *		Y	Y	N	-
-	 *
-	 * IB		N	N	Y	N
-	 *		N	Y	N	-
-	 *		Y	N	Y	N
-	 *		Y	Y	N	-
-	 *
-	 * NB:	iWARP requires remote write access for the data sink
-	 *	of an RDMA_READ. IB does not.
+	 *		N	N	Y
+	 *		N	Y	Y
+	 *		Y	N	Y
+	 *		Y	Y	N
 	 */
 	newxprt->sc_reader = rdma_read_chunk_lcl;
 	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
@@ -1002,11 +994,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG) ||
 	    !(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
 		need_dma_mr = 1;
-		dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
-		if (rdma_protocol_iwarp(newxprt->sc_cm_id->device,
-					newxprt->sc_cm_id->port_num) &&
-		    !(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG))
-			dma_mr_acc |= IB_ACCESS_REMOTE_WRITE;
+		dma_mr_roles = RDMA_MRR_SEND | RDMA_MRR_RECV |
+			       RDMA_MRR_WRITE_SOURCE | RDMA_MRR_READ_DEST;
 	}
 
 	if (rdma_protocol_iwarp(newxprt->sc_cm_id->device,
@@ -1016,8 +1005,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/* Create the DMA MR if needed, otherwise, use the DMA LKEY */
 	if (need_dma_mr) {
 		/* Register all of physical memory */
-		newxprt->sc_phys_mr =
-			ib_get_dma_mr(newxprt->sc_pd, dma_mr_acc);
+		newxprt->sc_phys_mr = rdma_get_dma_mr(newxprt->sc_pd,
+						      dma_mr_roles, 0);
 		if (IS_ERR(newxprt->sc_phys_mr)) {
 			dprintk("svcrdma: Failed to create DMA MR ret=%d\n",
 				ret);

