Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36192 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934002AbcK2QFd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 11:05:33 -0500
Subject: [PATCH v3 09/10] svcrdma: Break up dprintk format in
 svc_rdma_accept()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 11:05:31 -0500
Message-ID: <20161129160531.4477.9355.stgit@klimt.1015granger.net>
In-Reply-To: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
References: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code results in:

Nov  7 14:50:19 klimt kernel: svcrdma: newxprt->sc_cm_id=ffff88085590c800,
 newxprt->sc_pd=ffff880852a7ce00#012    cm_id->device=ffff88084dd20000,
 sc_pd->device=ffff88084dd20000#012    cap.max_send_wr = 272#012
 cap.max_recv_wr = 34#012    cap.max_send_sge = 32#012
 cap.max_recv_sge = 32
Nov  7 14:50:19 klimt kernel: svcrdma: new connection ffff880855908000
 accepted with the following attributes:#012    local_ip        :
 10.0.0.5#012    local_port#011     : 20049#012    remote_ip       :
 10.0.0.2#012    remote_port     : 59909#012    max_sge         : 32#012
 max_sge_rd      : 30#012    sq_depth        : 272#012    max_requests    :
 32#012    ord             : 16

Split up the output over multiple dprintks and take the opportunity
to fix the display of IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   55 ++++++++++--------------------
 1 file changed, 18 insertions(+), 37 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 733d6e03..ca2799a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -41,6 +41,7 @@
  */
 
 #include <linux/sunrpc/svc_xprt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/interrupt.h>
@@ -968,6 +969,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct rpcrdma_connect_private pmsg;
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device *dev;
+	struct sockaddr *sap;
 	unsigned int i;
 	int ret = 0;
 
@@ -1048,18 +1050,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	qp_attr.qp_type = IB_QPT_RC;
 	qp_attr.send_cq = newxprt->sc_sq_cq;
 	qp_attr.recv_cq = newxprt->sc_rq_cq;
-	dprintk("svcrdma: newxprt->sc_cm_id=%p, newxprt->sc_pd=%p\n"
-		"    cm_id->device=%p, sc_pd->device=%p\n"
-		"    cap.max_send_wr = %d\n"
-		"    cap.max_recv_wr = %d\n"
-		"    cap.max_send_sge = %d\n"
-		"    cap.max_recv_sge = %d\n",
-		newxprt->sc_cm_id, newxprt->sc_pd,
-		dev, newxprt->sc_pd->device,
-		qp_attr.cap.max_send_wr,
-		qp_attr.cap.max_recv_wr,
-		qp_attr.cap.max_send_sge,
-		qp_attr.cap.max_recv_sge);
+	dprintk("svcrdma: newxprt->sc_cm_id=%p, newxprt->sc_pd=%p\n",
+		newxprt->sc_cm_id, newxprt->sc_pd);
+	dprintk("    cap.max_send_wr = %d, cap.max_recv_wr = %d\n",
+		qp_attr.cap.max_send_wr, qp_attr.cap.max_recv_wr);
+	dprintk("    cap.max_send_sge = %d, cap.max_recv_sge = %d\n",
+		qp_attr.cap.max_send_sge, qp_attr.cap.max_recv_sge);
 
 	ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
 	if (ret) {
@@ -1142,31 +1138,16 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		goto errout;
 	}
 
-	dprintk("svcrdma: new connection %p accepted with the following "
-		"attributes:\n"
-		"    local_ip        : %pI4\n"
-		"    local_port	     : %d\n"
-		"    remote_ip       : %pI4\n"
-		"    remote_port     : %d\n"
-		"    max_sge         : %d\n"
-		"    max_sge_rd      : %d\n"
-		"    sq_depth        : %d\n"
-		"    max_requests    : %d\n"
-		"    ord             : %d\n",
-		newxprt,
-		&((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.src_addr)->sin_addr.s_addr,
-		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
-		       route.addr.src_addr)->sin_port),
-		&((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.dst_addr)->sin_addr.s_addr,
-		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
-		       route.addr.dst_addr)->sin_port),
-		newxprt->sc_max_sge,
-		newxprt->sc_max_sge_rd,
-		newxprt->sc_sq_depth,
-		newxprt->sc_max_requests,
-		newxprt->sc_ord);
+	dprintk("svcrdma: new connection %p accepted:\n", newxprt);
+	sap = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.src_addr;
+	dprintk("    local address   : %pIS:%u\n", sap, rpc_get_port(sap));
+	sap = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
+	dprintk("    remote address  : %pIS:%u\n", sap, rpc_get_port(sap));
+	dprintk("    max_sge         : %d\n", newxprt->sc_max_sge);
+	dprintk("    max_sge_rd      : %d\n", newxprt->sc_max_sge_rd);
+	dprintk("    sq_depth        : %d\n", newxprt->sc_sq_depth);
+	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
+	dprintk("    ord             : %d\n", newxprt->sc_ord);
 
 	return &newxprt->sc_xprt;
 

