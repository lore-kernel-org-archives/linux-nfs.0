Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35682 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbbDGMcv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:32:51 -0400
Received: by widdi4 with SMTP id di4so15518114wid.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:32:50 -0700 (PDT)
Message-ID: <5523CE6F.4020206@profitbricks.com>
Date: Tue, 07 Apr 2015 14:32:47 +0200
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
Subject: [PATCH v2 06/17] IB/Verbs: Use management helper cap_ib_sa() for
 sa-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_sa() to help us check if the port of an
IB device support Infiniband Subnet Administrator.

Reform ib_sa_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/sa_query.c | 27 +++++++++++++++++----------
 include/rdma/ib_verbs.h            | 15 +++++++++++++++
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index c38f030..f704254 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *handler, struct ib_event *event
 		struct ib_sa_port *port =
 			&sa_dev->port[event->element.port_num - sa_dev->start_port];
 
-		if (rdma_port_get_link_layer(handler->device, port->port_num) != IB_LINK_LAYER_INFINIBAND)
+		if (WARN_ON(!cap_ib_sa(handler->device, port->port_num)))
 			return;
 
 		spin_lock_irqsave(&port->ah_lock, flags);
@@ -1153,9 +1153,7 @@ static void ib_sa_add_one(struct ib_device *device)
 {
 	struct ib_sa_device *sa_dev;
 	int s, e, i;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
 		s = e = 0;
@@ -1175,7 +1173,7 @@ static void ib_sa_add_one(struct ib_device *device)
 
 	for (i = 0; i <= e - s; ++i) {
 		spin_lock_init(&sa_dev->port[i].ah_lock);
-		if (rdma_port_get_link_layer(device, i + 1) != IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ib_sa(device, i + 1))
 			continue;
 
 		sa_dev->port[i].sm_ah    = NULL;
@@ -1189,6 +1187,13 @@ static void ib_sa_add_one(struct ib_device *device)
 			goto err;
 
 		INIT_WORK(&sa_dev->port[i].update_task, update_sm_ah);
+
+		count++;
+	}
+
+	if (!count) {
+		kfree(sa_dev);
+		return;
 	}
 
 	ib_set_client_data(device, &sa_client, sa_dev);
@@ -1204,16 +1209,18 @@ static void ib_sa_add_one(struct ib_device *device)
 	if (ib_register_event_handler(&sa_dev->event_handler))
 		goto err;
 
-	for (i = 0; i <= e - s; ++i)
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND)
+	for (i = 0; i <= e - s; ++i) {
+		if (cap_ib_sa(device, i + 1))
 			update_sm_ah(&sa_dev->port[i].update_task);
+	}
 
 	return;
 
 err:
-	while (--i >= 0)
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND)
+	while (--i >= 0) {
+		if (cap_ib_sa(device, i + 1))
 			ib_unregister_mad_agent(sa_dev->port[i].agent);
+	}
 
 	kfree(sa_dev);
 
@@ -1233,7 +1240,7 @@ static void ib_sa_remove_one(struct ib_device *device)
 	flush_workqueue(ib_wq);
 
 	for (i = 0; i <= sa_dev->end_port - sa_dev->start_port; ++i) {
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND) {
+		if (cap_ib_sa(device, i + 1)) {
 			ib_unregister_mad_agent(sa_dev->port[i].agent);
 			if (sa_dev->port[i].sm_ah)
 				kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 3ba963f..c405e45 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1818,6 +1818,21 @@ static inline int cap_ib_cm(struct ib_device *device, u8 port_num)
 	return rdma_ib_mgmt(device, port_num);
 }
 
+/**
+ * cap_ib_sa - Check if the port of device has the capability Infiniband
+ * Subnet Administrator.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Subnet Administrator.
+ */
+static inline int cap_ib_sa(struct ib_device *device, u8 port_num)
+{
+	return rdma_transport_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
