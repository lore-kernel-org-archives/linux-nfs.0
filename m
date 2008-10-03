From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 03/12] svcrdma: Query device for Fast Reg support during connection setup
Date: Fri,  3 Oct 2008 16:33:40 -0500
Message-ID: <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40975 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753386AbYJCVdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:50 -0400
In-Reply-To: <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Query the device capabilities in the svc_rdma_accept function to determine
what advanced memory management capabilities are supported by the device.
Based on the query, select the most secure model available given the
requirements of the transport and capabilities of the adapter.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   76 +++++++++++++++++++++++++++--
 1 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index dd170af..5918285 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -813,6 +813,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct rdma_conn_param conn_param;
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device_attr devattr;
+	int dma_mr_acc;
+	int need_dma_mr;
 	int ret;
 	int i;
 
@@ -928,15 +930,77 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	}
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 
-	/* Register all of physical memory */
-	newxprt->sc_phys_mr = ib_get_dma_mr(newxprt->sc_pd,
-					    IB_ACCESS_LOCAL_WRITE |
-					    IB_ACCESS_REMOTE_WRITE);
-	if (IS_ERR(newxprt->sc_phys_mr)) {
-		dprintk("svcrdma: Failed to create DMA MR ret=%d\n", ret);
+	/*
+	 * Use the most secure set of MR resources based on the
+	 * transport type and available memory management features in
+	 * the device. Here's the table implemented below:
+	 *
+	 *		Fast	Global	DMA	Remote WR
+	 *		Reg	LKEY	MR	Access
+	 *		Sup'd	Sup'd	Needed	Needed
+	 *
+	 * IWARP	N	N	Y	Y
+	 *		N	Y	Y	Y
+	 *		Y	N	Y	N
+	 *		Y	Y	N	-
+	 *
+	 * IB		N	N	Y	N
+	 *		N	Y	N	-
+	 *		Y	N	Y	N
+	 *		Y	Y	N	-
+	 *
+	 * NB:	iWARP requires remote write access for the data sink
+	 *	of an RDMA_READ. IB does not.
+	 */
+	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
+		newxprt->sc_frmr_pg_list_len =
+			devattr.max_fast_reg_page_list_len;
+		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
+	}
+
+	/*
+	 * Determine if a DMA MR is required and if so, what privs are required
+	 */
+	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
+	case RDMA_TRANSPORT_IWARP:
+		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
+		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
+			need_dma_mr = 1;
+			dma_mr_acc =
+				(IB_ACCESS_LOCAL_WRITE |
+				 IB_ACCESS_REMOTE_WRITE);
+		} else if (!(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
+			need_dma_mr = 1;
+			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
+		} else
+			need_dma_mr = 0;
+		break;
+	case RDMA_TRANSPORT_IB:
+		if (!(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
+			need_dma_mr = 1;
+			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
+		} else
+			need_dma_mr = 0;
+		break;
+	default:
 		goto errout;
 	}
 
+	/* Create the DMA MR if needed, otherwise, use the DMA LKEY */
+	if (need_dma_mr) {
+		/* Register all of physical memory */
+		newxprt->sc_phys_mr =
+			ib_get_dma_mr(newxprt->sc_pd, dma_mr_acc);
+		if (IS_ERR(newxprt->sc_phys_mr)) {
+			dprintk("svcrdma: Failed to create DMA MR ret=%d\n",
+				ret);
+			goto errout;
+		}
+		newxprt->sc_dma_lkey = newxprt->sc_phys_mr->lkey;
+	} else
+		newxprt->sc_dma_lkey =
+			newxprt->sc_cm_id->device->local_dma_lkey;
+
 	/* Post receive buffers */
 	for (i = 0; i < newxprt->sc_max_requests; i++) {
 		ret = svc_rdma_post_recv(newxprt);
