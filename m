Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36328 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbbDGMet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:34:49 -0400
Received: by wgsk9 with SMTP id k9so31870830wgs.3
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:34:47 -0700 (PDT)
Message-ID: <5523CEE4.5060901@profitbricks.com>
Date: Tue, 07 Apr 2015 14:34:44 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
CC: Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Ira Weiny <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>,
        Michael Wang <yun.wang@profitbricks.com>
Subject: [PATCH v2 09/17] IB/Verbs: Use helper cap_read_multi_sge() and reform
 svc_rdma_accept()
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_read_multi_sge() to help us check if the port of an
IB device support RDMA Read Multiple Scatter-Gather Entries.

Reform svc_rdma_accept() to adopt management helpers.

Cc: Tom Talpey <tom@talpey.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 include/rdma/ib_verbs.h                  | 15 +++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  4 ++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 12 +++++-------
 3 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 9db8966..cae6f2d 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1849,6 +1849,21 @@ static inline int cap_ib_mcast(struct ib_device *device, u8 port_num)
 }
 
 /**
+ * cap_read_multi_sge - Check if the port of device has the capability
+ * RDMA Read Multiple Scatter-Gather Entries.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * RDMA Read Multiple Scatter-Gather Entries.
+ */
+static inline int cap_read_multi_sge(struct ib_device *device, u8 port_num)
+{
+	return !rdma_transport_iwarp(device, port_num);
+}
+
+/**
  * cap_ipoib - Check if the port of device has the capability
  * IP over Infiniband.
  *
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index e011027..604d035 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -118,8 +118,8 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 
 static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
 {
-	if (rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
-	     RDMA_TRANSPORT_IWARP)
+	if (!cap_read_multi_sge(xprt->sc_cm_id->device,
+				xprt->sc_cm_id->port_num))
 		return 1;
 	else
 		return min_t(int, sge_count, xprt->sc_max_sge);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4e61880..e75175d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -979,8 +979,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/*
 	 * Determine if a DMA MR is required and if so, what privs are required
 	 */
-	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
-	case RDMA_TRANSPORT_IWARP:
+	if (rdma_transport_iwarp(newxprt->sc_cm_id->device,
+				 newxprt->sc_cm_id->port_num)) {
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
 		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
 			need_dma_mr = 1;
@@ -992,8 +992,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
 		} else
 			need_dma_mr = 0;
-		break;
-	case RDMA_TRANSPORT_IB:
+	} else if (rdma_ib_mgmt(newxprt->sc_cm_id->device,
+				newxprt->sc_cm_id->port_num)) {
 		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
 			need_dma_mr = 1;
 			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
@@ -1003,10 +1003,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
 		} else
 			need_dma_mr = 0;
-		break;
-	default:
+	} else
 		goto errout;
-	}
 
 	/* Create the DMA MR if needed, otherwise, use the DMA LKEY */
 	if (need_dma_mr) {
-- 
2.1.0
