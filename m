Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:44161 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbbAGXNT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:13:19 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so6635036iec.11
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:13:18 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id 75sm1430341ioz.35.2015.01.07.15.13.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:13:18 -0800 (PST)
Subject: [PATCH v1 11/20] xprtrdma: Take struct ib_device_attr off the stack
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:13:17 -0500
Message-ID: <20150107231317.13466.66838.stgit@manet.1015granger.net>
In-Reply-To: <20150107230859.13466.67723.stgit@manet.1015granger.net>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Device attributes are large, and are used in more than one place.
Stash a copy in dynamically allocated memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   37 +++++++++++++------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index aa012a3..123bb04 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -588,8 +588,8 @@ int
 rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 {
 	int rc, mem_priv;
-	struct ib_device_attr devattr;
 	struct rpcrdma_ia *ia = &xprt->rx_ia;
+	struct ib_device_attr *devattr = &ia->ri_devattr;
 
 	ia->ri_id = rpcrdma_create_id(xprt, ia, addr);
 	if (IS_ERR(ia->ri_id)) {
@@ -605,26 +605,21 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		goto out2;
 	}
 
-	/*
-	 * Query the device to determine if the requested memory
-	 * registration strategy is supported. If it isn't, set the
-	 * strategy to a globally supported model.
-	 */
-	rc = ib_query_device(ia->ri_id->device, &devattr);
+	rc = ib_query_device(ia->ri_id->device, devattr);
 	if (rc) {
 		dprintk("RPC:       %s: ib_query_device failed %d\n",
 			__func__, rc);
 		goto out3;
 	}
 
-	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
+	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
 		ia->ri_have_dma_lkey = 1;
 		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
 	}
 
 	if (memreg == RPCRDMA_FRMR) {
 		/* Requires both frmr reg and local dma lkey */
-		if ((devattr.device_cap_flags &
+		if ((devattr->device_cap_flags &
 		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
 		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) {
 			dprintk("RPC:       %s: FRMR registration "
@@ -634,7 +629,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 			/* Mind the ia limit on FRMR page list depth */
 			ia->ri_max_frmr_depth = min_t(unsigned int,
 				RPCRDMA_MAX_DATA_SEGS,
-				devattr.max_fast_reg_page_list_len);
+				devattr->max_fast_reg_page_list_len);
 		}
 	}
 	if (memreg == RPCRDMA_MTHCAFMR) {
@@ -736,20 +731,13 @@ int
 rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 				struct rpcrdma_create_data_internal *cdata)
 {
-	struct ib_device_attr devattr;
+	struct ib_device_attr *devattr = &ia->ri_devattr;
 	struct ib_cq *sendcq, *recvcq;
 	int rc, err;
 
-	rc = ib_query_device(ia->ri_id->device, &devattr);
-	if (rc) {
-		dprintk("RPC:       %s: ib_query_device failed %d\n",
-			__func__, rc);
-		return rc;
-	}
-
 	/* check provider's send/recv wr limits */
-	if (cdata->max_requests > devattr.max_qp_wr)
-		cdata->max_requests = devattr.max_qp_wr;
+	if (cdata->max_requests > devattr->max_qp_wr)
+		cdata->max_requests = devattr->max_qp_wr;
 
 	ep->rep_attr.event_handler = rpcrdma_qp_async_error_upcall;
 	ep->rep_attr.qp_context = ep;
@@ -784,8 +772,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 		}
 		ep->rep_attr.cap.max_send_wr *= depth;
-		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr) {
-			cdata->max_requests = devattr.max_qp_wr / depth;
+		if (ep->rep_attr.cap.max_send_wr > devattr->max_qp_wr) {
+			cdata->max_requests = devattr->max_qp_wr / depth;
 			if (!cdata->max_requests)
 				return -EINVAL;
 			ep->rep_attr.cap.max_send_wr = cdata->max_requests *
@@ -868,10 +856,11 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* Client offers RDMA Read but does not initiate */
 	ep->rep_remote_cma.initiator_depth = 0;
-	if (devattr.max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
+	if (devattr->max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
 		ep->rep_remote_cma.responder_resources = 32;
 	else
-		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;
+		ep->rep_remote_cma.responder_resources =
+						devattr->max_qp_rd_atom;
 
 	ep->rep_remote_cma.retry_count = 7;
 	ep->rep_remote_cma.flow_control = 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 657c370..ec596ce 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -70,6 +70,7 @@ struct rpcrdma_ia {
 	int			ri_async_rc;
 	enum rpcrdma_memreg	ri_memreg_strategy;
 	unsigned int		ri_max_frmr_depth;
+	struct ib_device_attr	ri_devattr;
 };
 
 /*

