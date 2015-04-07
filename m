Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36258 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbDGMj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:39:57 -0400
Received: by wgsk9 with SMTP id k9so32017120wgs.3
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:39:56 -0700 (PDT)
Message-ID: <5523D019.1060805@profitbricks.com>
Date: Tue, 07 Apr 2015 14:39:53 +0200
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
Subject: [PATCH v2 17/17] IB/Verbs: Move rdma_port_get_link_layer() to mlx4
 head file
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Now only mlx4 still using rdma_port_get_link_layer(), move it
to it's private head file.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/verbs.c      | 20 --------------------
 drivers/infiniband/hw/mlx4/mlx4_ib.h |  8 ++++++++
 include/rdma/ib_verbs.h              |  3 ---
 3 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index 49acdbc..f1eac93 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -107,26 +107,6 @@ __attribute_const__ int ib_rate_to_mbps(enum ib_rate rate)
 }
 EXPORT_SYMBOL(ib_rate_to_mbps);
 
-enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device, u8 port_num)
-{
-	if (device->get_link_layer)
-		return device->get_link_layer(device, port_num);
-
-	switch (device->query_transport(device, port_num)) {
-	case RDMA_TRANSPORT_IB:
-	case RDMA_TRANSPORT_IBOE:
-		return IB_LINK_LAYER_INFINIBAND;
-	case RDMA_TRANSPORT_IWARP:
-	case RDMA_TRANSPORT_USNIC:
-	case RDMA_TRANSPORT_USNIC_UDP:
-		return IB_LINK_LAYER_ETHERNET;
-	default:
-		BUG();
-		return IB_LINK_LAYER_UNSPECIFIED;
-	}
-}
-EXPORT_SYMBOL(rdma_port_get_link_layer);
-
 /* Protection domains */
 
 struct ib_pd *ib_alloc_pd(struct ib_device *device)
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 6eb743f..8e86ecc 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -708,6 +708,14 @@ int __mlx4_ib_query_pkey(struct ib_device *ibdev, u8 port, u16 index,
 int __mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
 			union ib_gid *gid, int netw_view);
 
+static enum rdma_link_layer
+rdma_port_get_link_layer(struct ib_device *device, u8 port_num)
+{
+	/* Will this happen? */
+	BUG_ON(!device->get_link_layer);
+	return device->get_link_layer(device, port_num);
+}
+
 static inline bool mlx4_ib_ah_grh_present(struct mlx4_ib_ah *ah)
 {
 	u8 port = be32_to_cpu(ah->av.ib.port_pd) >> 24 & 3;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index f033f824..67b3e71 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1742,9 +1742,6 @@ int ib_query_device(struct ib_device *device,
 int ib_query_port(struct ib_device *device,
 		  u8 port_num, struct ib_port_attr *port_attr);
 
-enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device,
-					       u8 port_num);
-
 static inline int rdma_transport_ib(struct ib_device *device, u8 port_num)
 {
 	return device->query_transport(device, port_num)
-- 
2.1.0
