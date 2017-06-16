Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35678 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753322AbdFPPWc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 11:22:32 -0400
Subject: [PATCH v2 16/19] svcrdma: Clean up after converting
 svc_rdma_recvfrom to rdma_rw API
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Jun 2017 11:22:30 -0400
Message-ID: <20170616152230.14210.77568.stgit@klimt.1015granger.net>
In-Reply-To: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Registration mode details are now handled by the rdma_rw
API, and thus can be removed from svcrdma.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    4 ---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   39 +++---------------------------
 2 files changed, 4 insertions(+), 39 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index fd7775f..995c6fe 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -90,9 +90,6 @@ struct svc_rdma_op_ctxt {
 	struct page *pages[RPCSVC_MAXPAGES];
 };
 
-#define	SVCRDMA_DEVCAP_FAST_REG		1	/* fast mr registration */
-#define	SVCRDMA_DEVCAP_READ_W_INV	2	/* read w/ invalidate */
-
 struct svcxprt_rdma {
 	struct svc_xprt      sc_xprt;		/* SVC transport structure */
 	struct rdma_cm_id    *sc_cm_id;		/* RDMA connection id */
@@ -123,7 +120,6 @@ struct svcxprt_rdma {
 	struct ib_qp         *sc_qp;
 	struct ib_cq         *sc_rq_cq;
 	struct ib_cq         *sc_sq_cq;
-	u32		     sc_dev_caps;	/* distilled device caps */
 
 	spinlock_t	     sc_lock;		/* transport lock */
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 75bd11f..e660d49 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -783,7 +783,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	memset(&qp_attr, 0, sizeof qp_attr);
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
-	qp_attr.port_num = newxprt->sc_cm_id->port_num;
+	qp_attr.port_num = newxprt->sc_port_num;
 	qp_attr.cap.max_rdma_ctxs = newxprt->sc_max_requests;
 	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
 	qp_attr.cap.max_recv_wr = newxprt->sc_rq_depth;
@@ -807,43 +807,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	}
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 
-	/*
-	 * Use the most secure set of MR resources based on the
-	 * transport type and available memory management features in
-	 * the device. Here's the table implemented below:
-	 *
-	 *		Fast	Global	DMA	Remote WR
-	 *		Reg	LKEY	MR	Access
-	 *		Sup'd	Sup'd	Needed	Needed
-	 *
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
-	 */
-	if (dev->attrs.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
-		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
-	} else
+	if (!(dev->attrs.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
 		newxprt->sc_snd_w_inv = false;
-
-	/*
-	 * Determine if a DMA MR is required and if so, what privs are required
-	 */
-	if (!rdma_protocol_iwarp(dev, newxprt->sc_cm_id->port_num) &&
-	    !rdma_ib_or_roce(dev, newxprt->sc_cm_id->port_num))
+	if (!rdma_protocol_iwarp(dev, newxprt->sc_port_num) &&
+	    !rdma_ib_or_roce(dev, newxprt->sc_port_num))
 		goto errout;
 
-	if (rdma_protocol_iwarp(dev, newxprt->sc_cm_id->port_num))
-		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
-
 	/* Post receive buffers */
 	for (i = 0; i < newxprt->sc_max_requests; i++) {
 		ret = svc_rdma_post_recv(newxprt, GFP_KERNEL);

