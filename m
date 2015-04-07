Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35136 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbbDGMjZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:39:25 -0400
Received: by widdi4 with SMTP id di4so15727720wid.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:39:24 -0700 (PDT)
Message-ID: <5523CFF9.5090409@profitbricks.com>
Date: Tue, 07 Apr 2015 14:39:21 +0200
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
Subject: [PATCH v2 16/17] IB/Verbs: Cleanup rdma_node_get_transport()
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We have get rid of all the scene using rdma_node_get_transport(),
now clean it up.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/verbs.c | 21 ---------------------
 include/rdma/ib_verbs.h         |  3 ---
 2 files changed, 24 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index ca06f76..49acdbc 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -107,27 +107,6 @@ __attribute_const__ int ib_rate_to_mbps(enum ib_rate rate)
 }
 EXPORT_SYMBOL(ib_rate_to_mbps);
 
-__attribute_const__ enum rdma_transport_type
-rdma_node_get_transport(enum rdma_node_type node_type)
-{
-	switch (node_type) {
-	case RDMA_NODE_IB_CA:
-	case RDMA_NODE_IB_SWITCH:
-	case RDMA_NODE_IB_ROUTER:
-		return RDMA_TRANSPORT_IB;
-	case RDMA_NODE_RNIC:
-		return RDMA_TRANSPORT_IWARP;
-	case RDMA_NODE_USNIC:
-		return RDMA_TRANSPORT_USNIC;
-	case RDMA_NODE_USNIC_UDP:
-		return RDMA_TRANSPORT_USNIC_UDP;
-	default:
-		BUG();
-		return 0;
-	}
-}
-EXPORT_SYMBOL(rdma_node_get_transport);
-
 enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device, u8 port_num)
 {
 	if (device->get_link_layer)
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 2767a91..f033f824 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -84,9 +84,6 @@ enum rdma_transport_type {
 	RDMA_TRANSPORT_IBOE,
 };
 
-__attribute_const__ enum rdma_transport_type
-rdma_node_get_transport(enum rdma_node_type node_type);
-
 enum rdma_link_layer {
 	IB_LINK_LAYER_UNSPECIFIED,
 	IB_LINK_LAYER_INFINIBAND,
-- 
2.1.0
