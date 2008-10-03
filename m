From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 11/12] svcrdma: Add a message log string to indicate if FastReg is being used
Date: Fri,  3 Oct 2008 16:33:48 -0500
Message-ID: <1223069629-5267-12-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-7-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-8-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-9-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-10-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-11-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40994 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbYJCVdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:51 -0400
In-Reply-To: <1223069629-5267-11-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a log message that allows the administrator to determine if server memory
is exposed on a particular client connection. This message can be disabled
by writing 0 to the /proc/sys/sunrpc/svc_rdma/show_conn_info file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma.c           |    8 ++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   63 ++++++++++++++++++-----------
 3 files changed, 48 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index c14fe86..7ee0a76 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -52,6 +52,7 @@
 extern unsigned int svcrdma_ord;
 extern unsigned int svcrdma_max_requests;
 extern unsigned int svcrdma_max_req_size;
+extern unsigned int svcrdma_show_conn_info;
 
 extern atomic_t rdma_stat_recv;
 extern atomic_t rdma_stat_read;
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 8710117..493e243 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -58,6 +58,7 @@ static unsigned int max_max_requests = 16384;
 unsigned int svcrdma_max_req_size = RPCRDMA_MAX_REQ_SIZE;
 static unsigned int min_max_inline = 4096;
 static unsigned int max_max_inline = 65536;
+unsigned int svcrdma_show_conn_info = 1;
 
 atomic_t rdma_stat_recv;
 atomic_t rdma_stat_read;
@@ -145,6 +146,13 @@ static ctl_table svcrdma_parm_table[] = {
 		.extra1		= &min_ord,
 		.extra2		= &max_ord,
 	},
+	{
+		.procname	= "show_conn_info",
+		.data		= &svcrdma_show_conn_info,
+		.maxlen		= sizeof(svcrdma_show_conn_info),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 
 	{
 		.procname	= "rdma_stat_read",
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index bd17023..3d97032 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -833,6 +833,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct rdma_conn_param conn_param;
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device_attr devattr;
+	char *transport_string;
+	char *security_string;
 	int dma_mr_acc;
 	int need_dma_mr;
 	int ret;
@@ -981,10 +983,13 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/*
 	 * Determine if a DMA MR is required and if so, what privs are required
 	 */
+	security_string = "Safe. Only RPC memory exposed.";
 	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
 	case RDMA_TRANSPORT_IWARP:
+		transport_string = "iWARP";
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
 		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
+			security_string = "Unsafe: Server memory exposed.";
 			need_dma_mr = 1;
 			dma_mr_acc =
 				(IB_ACCESS_LOCAL_WRITE |
@@ -996,6 +1001,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			need_dma_mr = 0;
 		break;
 	case RDMA_TRANSPORT_IB:
+		transport_string = "IB";
 		if (!(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
 			need_dma_mr = 1;
 			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
@@ -1052,30 +1058,39 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		goto errout;
 	}
 
-	dprintk("svcrdma: new connection %p accepted with the following "
-		"attributes:\n"
-		"    local_ip        : %d.%d.%d.%d\n"
-		"    local_port	     : %d\n"
-		"    remote_ip       : %d.%d.%d.%d\n"
-		"    remote_port     : %d\n"
-		"    max_sge         : %d\n"
-		"    sq_depth        : %d\n"
-		"    max_requests    : %d\n"
-		"    ord             : %d\n",
-		newxprt,
-		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.src_addr)->sin_addr.s_addr),
-		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
-		       route.addr.src_addr)->sin_port),
-		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.dst_addr)->sin_addr.s_addr),
-		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
-		       route.addr.dst_addr)->sin_port),
-		newxprt->sc_max_sge,
-		newxprt->sc_sq_depth,
-		newxprt->sc_max_requests,
-		newxprt->sc_ord);
-
+	if (!svcrdma_show_conn_info)
+		goto out;
+
+	printk(KERN_INFO "svcrdma: New connection accepted with the following "
+	       "attributes:\n"
+	       "    transport       : %s\n"
+	       "    local_ip        : %d.%d.%d.%d\n"
+	       "    local_port      : %d\n"
+	       "    remote_ip       : %d.%d.%d.%d\n"
+	       "    remote_port     : %d\n"
+	       "    max_sge         : %d\n"
+	       "    sq_depth        : %d\n"
+	       "    max_requests    : %d\n"
+	       "    ord             : %d\n"
+	       "    using fastreg?  : %c\n"
+	       "    memory exposure : %s\n",
+	       transport_string,
+	       NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
+			route.addr.src_addr)->sin_addr.s_addr),
+	       ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
+		      route.addr.src_addr)->sin_port),
+	       NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
+			route.addr.dst_addr)->sin_addr.s_addr),
+	       ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
+		      route.addr.dst_addr)->sin_port),
+	       newxprt->sc_max_sge,
+	       newxprt->sc_sq_depth,
+	       newxprt->sc_max_requests,
+	       newxprt->sc_ord,
+	       newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG ? 'Y' : 'N',
+	       security_string);
+
+ out:
 	return &newxprt->sc_xprt;
 
  errout:
