Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:32980 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbbDGMd2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:33:28 -0400
Received: by wgin8 with SMTP id n8so54416025wgi.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:33:26 -0700 (PDT)
Message-ID: <5523CE93.8080809@profitbricks.com>
Date: Tue, 07 Apr 2015 14:33:23 +0200
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
Subject: [PATCH v2 07/17] IB/Verbs: Use management helper cap_ib_mcast() for
 mcast-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_mcast() to help us check if the port of an
IB device support Infiniband Multicast.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/multicast.c | 12 +++---------
 include/rdma/ib_verbs.h             | 15 +++++++++++++++
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index fa17b55..bdc1880 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -780,8 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
 	int index;
 
 	dev = container_of(handler, struct mcast_device, event_handler);
-	if (rdma_port_get_link_layer(dev->device, event->element.port_num) !=
-	    IB_LINK_LAYER_INFINIBAND)
+	if (WARN_ON(!cap_ib_mcast(dev->device, event->element.port_num)))
 		return;
 
 	index = event->element.port_num - dev->start_port;
@@ -808,9 +807,6 @@ static void mcast_add_one(struct ib_device *device)
 	int i;
 	int count = 0;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
 		      GFP_KERNEL);
 	if (!dev)
@@ -824,8 +820,7 @@ static void mcast_add_one(struct ib_device *device)
 	}
 
 	for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-		if (rdma_port_get_link_layer(device, dev->start_port + i) !=
-		    IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ib_mcast(device, dev->start_port + i))
 			continue;
 		port = &dev->port[i];
 		port->dev = dev;
@@ -863,8 +858,7 @@ static void mcast_remove_one(struct ib_device *device)
 	flush_workqueue(mcast_wq);
 
 	for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-		if (rdma_port_get_link_layer(device, dev->start_port + i) ==
-		    IB_LINK_LAYER_INFINIBAND) {
+		if (cap_ib_mcast(device, dev->start_port + i)) {
 			port = &dev->port[i];
 			deref_port(port);
 			wait_for_completion(&port->comp);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index c405e45..5a5f6d5 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1833,6 +1833,21 @@ static inline int cap_ib_sa(struct ib_device *device, u8 port_num)
 	return rdma_transport_ib(device, port_num);
 }
 
+/**
+ * cap_ib_mcast - Check if the port of device has the capability Infiniband
+ * Multicast.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Multicast.
+ */
+static inline int cap_ib_mcast(struct ib_device *device, u8 port_num)
+{
+	return cap_ib_sa(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
