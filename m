Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35940 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbeCTVFR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:05:17 -0400
Subject: [PATCH 2/3] svcrdma: Consult max_qp_init_rd_atom when accepting
 connections
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 20 Mar 2018 17:05:15 -0400
Message-ID: <20180320210515.13273.44910.stgit@klimt.1015granger.net>
In-Reply-To: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
References: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The target needs to return the lesser of the client's Inbound RDMA
Read Queue Depth (IRD), provided in the connection parameters, and
the local device's Outbound RDMA Read Queue Depth (ORD). The latter
limit is max_qp_init_rd_atom, not max_qp_rd_atom.

The svcrdma_ord value caps the ORD value for iWARP transports, which
do not exchange ORD/IRD values at connection time. Since no other
Linux kernel RDMA-enabled storage target sees fit to provide this
cap, I'm removing it here too.

initiator_depth is a u8, so ensure the computed ORD value does not
overflow that field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma.c           |    4 ++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   22 +++++++++-------------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 8045981..4af0820 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -133,9 +133,6 @@ struct svcxprt_rdma {
 #define RDMAXPRT_CONN_PENDING	3
 
 #define RPCRDMA_LISTEN_BACKLOG  10
-/* The default ORD value is based on two outstanding full-size writes with a
- * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
-#define RPCRDMA_ORD             (64/4)
 #define RPCRDMA_MAX_REQUESTS    32
 
 /* Typical ULP usage of BC requests is NFSv4.1 backchannel. Our
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index a4a8f69..dd8a431 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -51,9 +51,9 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 /* RPC/RDMA parameters */
-unsigned int svcrdma_ord = RPCRDMA_ORD;
+unsigned int svcrdma_ord = 16;	/* historical default */
 static unsigned int min_ord = 1;
-static unsigned int max_ord = 4096;
+static unsigned int max_ord = 255;
 unsigned int svcrdma_max_requests = RPCRDMA_MAX_REQUESTS;
 unsigned int svcrdma_max_bc_requests = RPCRDMA_MAX_BC_REQUESTS;
 static unsigned int min_max_requests = 4;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 8da637a..9c5dadb 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -765,13 +765,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
 
-	/*
-	 * Limit ORD based on client limit, local device limit, and
-	 * configured svcrdma limit.
-	 */
-	newxprt->sc_ord = min_t(size_t, dev->attrs.max_qp_rd_atom, newxprt->sc_ord);
-	newxprt->sc_ord = min_t(size_t,	svcrdma_ord, newxprt->sc_ord);
-
 	newxprt->sc_pd = ib_alloc_pd(dev, 0);
 	if (IS_ERR(newxprt->sc_pd)) {
 		dprintk("svcrdma: error creating PD for connect request\n");
@@ -846,15 +839,18 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	set_bit(RDMAXPRT_CONN_PENDING, &newxprt->sc_flags);
 	memset(&conn_param, 0, sizeof conn_param);
 	conn_param.responder_resources = 0;
-	conn_param.initiator_depth = newxprt->sc_ord;
+	conn_param.initiator_depth = min_t(int, newxprt->sc_ord,
+					   dev->attrs.max_qp_init_rd_atom);
+	if (!conn_param.initiator_depth) {
+		dprintk("svcrdma: invalid ORD setting\n");
+		ret = -EINVAL;
+		goto errout;
+	}
 	conn_param.private_data = &pmsg;
 	conn_param.private_data_len = sizeof(pmsg);
 	ret = rdma_accept(newxprt->sc_cm_id, &conn_param);
-	if (ret) {
-		dprintk("svcrdma: failed to accept new connection, ret=%d\n",
-		       ret);
+	if (ret)
 		goto errout;
-	}
 
 	dprintk("svcrdma: new connection %p accepted:\n", newxprt);
 	sap = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.src_addr;
@@ -865,7 +861,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dprintk("    sq_depth        : %d\n", newxprt->sc_sq_depth);
 	dprintk("    rdma_rw_ctxs    : %d\n", ctxts);
 	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
-	dprintk("    ord             : %d\n", newxprt->sc_ord);
+	dprintk("    ord             : %d\n", conn_param.initiator_depth);
 
 	return &newxprt->sc_xprt;
 

