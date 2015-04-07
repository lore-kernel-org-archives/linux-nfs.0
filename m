Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38447 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbbDGMgi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:36:38 -0400
Received: by wiun10 with SMTP id n10so16798566wiu.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:36:37 -0700 (PDT)
Message-ID: <5523CF52.4030606@profitbricks.com>
Date: Tue, 07 Apr 2015 14:36:34 +0200
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
Subject: [PATCH v2 12/17] IB/Verbs: Use management helper cap_ib_cm_dev()
 for cm-device-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_cm_dev() to help us check if any port of device
has the capability Infiniband Communication Manager.

Cc: Tom Talpey <tom@talpey.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cma.c |  5 ++---
 drivers/infiniband/core/ucm.c |  3 +--
 include/rdma/ib_verbs.h       | 20 ++++++++++++++++++++
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d570030..d8a8ea7 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1625,8 +1625,7 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 	struct rdma_cm_id *id;
 	int ret;
 
-	if (cma_family(id_priv) == AF_IB &&
-	    rdma_node_get_transport(cma_dev->device->node_type) != RDMA_TRANSPORT_IB)
+	if (cma_family(id_priv) == AF_IB && !cap_ib_cm_dev(cma_dev->device))
 		return;
 
 	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
@@ -2028,7 +2027,7 @@ static int cma_bind_loopback(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	list_for_each_entry(cur_dev, &dev_list, list) {
 		if (cma_family(id_priv) == AF_IB &&
-		    rdma_node_get_transport(cur_dev->device->node_type) != RDMA_TRANSPORT_IB)
+		    !cap_ib_cm_dev(cur_dev->device))
 			continue;
 
 		if (!cma_dev)
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index f2f6393..065405e 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -1253,8 +1253,7 @@ static void ib_ucm_add_one(struct ib_device *device)
 	dev_t base;
 	struct ib_ucm_device *ucm_dev;
 
-	if (!device->alloc_ucontext ||
-	    rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!device->alloc_ucontext || !cap_ib_cm_dev(device))
 		return;
 
 	ucm_dev = kzalloc(sizeof *ucm_dev, GFP_KERNEL);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index cae6f2d..2767a91 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1819,6 +1819,26 @@ static inline int cap_ib_cm(struct ib_device *device, u8 port_num)
 }
 
 /**
+ * cap_ib_cm_dev - Check if any port of device has the capability Infiniband
+ * Communication Manager.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when all port of the device don't support Infiniband
+ * Communication Manager.
+ */
+static inline int cap_ib_cm_dev(struct ib_device *device)
+{
+	int i;
+
+	for (i = 1; i <= device->phys_port_cnt; i++) {
+		if (cap_ib_cm(device, i))
+			return 1;
+	}
+	return 0;
+}
+
+/**
  * cap_ib_sa - Check if the port of device has the capability Infiniband
  * Subnet Administrator.
  *
-- 
2.1.0
