Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33369 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbDGMiL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:38:11 -0400
Received: by wgin8 with SMTP id n8so54548698wgi.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:38:10 -0700 (PDT)
Message-ID: <5523CFAF.6080907@profitbricks.com>
Date: Tue, 07 Apr 2015 14:38:07 +0200
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
Subject: [PATCH v2 14/17] IB/Verbs: Reserve legacy transport type for 'struct
 rdma_dev_addr'
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Reserve the legacy transport type for the 'transport' member
of 'struct rdma_dev_addr' until we make sure this is no
longer needed.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cma.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index c23f483..e26b42e 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -244,14 +244,35 @@ static inline void cma_set_ip_ver(struct cma_hdr *hdr, u8 ip_ver)
 	hdr->ip_version = (ip_ver << 4) | (hdr->ip_version & 0xF);
 }
 
+static inline void cma_set_legacy_transport(struct rdma_cm_id *id)
+{
+	switch (id->device->node_type) {
+	case RDMA_NODE_IB_CA:
+	case RDMA_NODE_IB_SWITCH:
+	case RDMA_NODE_IB_ROUTER:
+		id->route.addr.dev_addr.transport = RDMA_TRANSPORT_IB;
+		break;
+	case RDMA_NODE_RNIC:
+		id->route.addr.dev_addr.transport = RDMA_TRANSPORT_IWARP;
+		break;
+	case RDMA_NODE_USNIC:
+		id->route.addr.dev_addr.transport = RDMA_TRANSPORT_USNIC;
+		break;
+	case RDMA_NODE_USNIC_UDP:
+		id->route.addr.dev_addr.transport = RDMA_TRANSPORT_USNIC_UDP;
+		break;
+	default:
+		BUG();
+	}
+}
+
 static void cma_attach_to_dev(struct rdma_id_private *id_priv,
 			      struct cma_device *cma_dev)
 {
 	atomic_inc(&cma_dev->refcount);
 	id_priv->cma_dev = cma_dev;
 	id_priv->id.device = cma_dev->device;
-	id_priv->id.route.addr.dev_addr.transport =
-		rdma_node_get_transport(cma_dev->device->node_type);
+	cma_set_legacy_transport(&id_priv->id);
 	list_add_tail(&id_priv->list, &cma_dev->id_list);
 }
 
-- 
2.1.0
