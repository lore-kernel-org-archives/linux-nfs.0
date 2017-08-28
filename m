Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36539 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751249AbdH1TGX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 15:06:23 -0400
Subject: [PATCH 3/3] svcrdma: Estimate Send Queue depth properly
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 15:06:22 -0400
Message-ID: <20170828190622.13285.39686.stgit@klimt.1015granger.net>
In-Reply-To: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
References: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rdma_rw API adjusts max_send_wr upwards during the
rdma_create_qp() call. If the ULP actually wants to take advantage
of these extra resources, it must increase the size of its send
completion queue (created before rdma_create_qp is called) and
increase its send queue accounting limit.

Use the new rdma_rw_mr_factor API to figure out the correct value
to use for the Send Queue and Send Completion Queue depths.

And, ensure that the chosen Send Queue depth for a newly created
transport does not overrun the QP WR limit of the underlying device.

Lastly, there's no longer a need to carry the Send Queue depth in
struct svcxprt_rdma, since the value is used only in the
svc_rdma_accept() path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index cdb04f8..5caf8e7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -51,6 +51,7 @@
 #include <linux/workqueue.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
+#include <rdma/rw.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/export.h>
 #include "xprt_rdma.h"
@@ -713,7 +714,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device *dev;
 	struct sockaddr *sap;
-	unsigned int i;
+	unsigned int i, ctxts;
 	int ret = 0;
 
 	listen_rdma = container_of(xprt, struct svcxprt_rdma, sc_xprt);
@@ -754,7 +755,14 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt->sc_max_bc_requests = 2;
 	}
 	newxprt->sc_fc_credits = cpu_to_be32(newxprt->sc_max_requests);
-	newxprt->sc_sq_depth = newxprt->sc_rq_depth;
+	ctxts = rdma_rw_mr_factor(dev, newxprt->sc_port_num, RPCSVC_MAXPAGES);
+	ctxts *= newxprt->sc_max_requests;
+	newxprt->sc_sq_depth = newxprt->sc_rq_depth + ctxts;
+	if (newxprt->sc_sq_depth > dev->attrs.max_qp_wr) {
+		pr_warn("svcrdma: reducing send depth to %d\n",
+			dev->attrs.max_qp_wr);
+		newxprt->sc_sq_depth = dev->attrs.max_qp_wr;
+	}
 	atomic_set(&newxprt->sc_sq_avail, newxprt->sc_sq_depth);
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
@@ -789,8 +797,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	qp_attr.event_handler = qp_event_handler;
 	qp_attr.qp_context = &newxprt->sc_xprt;
 	qp_attr.port_num = newxprt->sc_port_num;
-	qp_attr.cap.max_rdma_ctxs = newxprt->sc_max_requests;
-	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
+	qp_attr.cap.max_rdma_ctxs = ctxts;
+	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth - ctxts;
 	qp_attr.cap.max_recv_wr = newxprt->sc_rq_depth;
 	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
 	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
@@ -858,6 +866,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dprintk("    remote address  : %pIS:%u\n", sap, rpc_get_port(sap));
 	dprintk("    max_sge         : %d\n", newxprt->sc_max_sge);
 	dprintk("    sq_depth        : %d\n", newxprt->sc_sq_depth);
+	dprintk("    rdma_rw_ctxs    : %d\n", ctxts);
 	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
 	dprintk("    ord             : %d\n", newxprt->sc_ord);
 

