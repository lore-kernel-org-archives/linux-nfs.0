Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34082 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbbDGMa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:30:27 -0400
Received: by wgbdm7 with SMTP id dm7so54348939wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:30:25 -0700 (PDT)
Message-ID: <5523CDDE.4050209@profitbricks.com>
Date: Tue, 07 Apr 2015 14:30:22 +0200
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
Subject: [PATCH v2 03/17] IB/Verbs: Use management helper cap_ib_mad() for
 mad-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_mad() to help us check if the port of an
IB device support Infiniband Management Datagrams.

Reform ib_umad_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/mad.c      | 18 +++++++++---------
 drivers/infiniband/core/user_mad.c | 26 ++++++++++++++++++++------
 include/rdma/ib_verbs.h            | 15 +++++++++++++++
 3 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 74c30f4..ef0c0c5 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -3057,9 +3057,6 @@ static void ib_mad_init_device(struct ib_device *device)
 {
 	int start, end, i;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
 		start = 0;
 		end   = 0;
@@ -3069,6 +3066,9 @@ static void ib_mad_init_device(struct ib_device *device)
 	}
 
 	for (i = start; i <= end; i++) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		if (ib_mad_port_open(device, i)) {
 			dev_err(&device->dev, "Couldn't open port %d\n", i);
 			goto error;
@@ -3086,15 +3086,15 @@ error_agent:
 		dev_err(&device->dev, "Couldn't close port %d\n", i);
 
 error:
-	i--;
+	while (--i >= start) {
+		if (!cap_ib_mad(device, i))
+			continue;
 
-	while (i >= start) {
 		if (ib_agent_port_close(device, i))
 			dev_err(&device->dev,
 				"Couldn't close port %d for agents\n", i);
 		if (ib_mad_port_close(device, i))
 			dev_err(&device->dev, "Couldn't close port %d\n", i);
-		i--;
 	}
 }
 
@@ -3102,9 +3102,6 @@ static void ib_mad_remove_device(struct ib_device *device)
 {
 	int i, num_ports, cur_port;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
 		num_ports = 1;
 		cur_port = 0;
@@ -3113,6 +3110,9 @@ static void ib_mad_remove_device(struct ib_device *device)
 		cur_port = 1;
 	}
 	for (i = 0; i < num_ports; i++, cur_port++) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		if (ib_agent_port_close(device, cur_port))
 			dev_err(&device->dev,
 				"Couldn't close port %d for agents\n",
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 928cdd2..b52884b 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1273,9 +1273,7 @@ static void ib_umad_add_one(struct ib_device *device)
 {
 	struct ib_umad_device *umad_dev;
 	int s, e, i;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
 		s = e = 0;
@@ -1296,11 +1294,21 @@ static void ib_umad_add_one(struct ib_device *device)
 	umad_dev->end_port   = e;
 
 	for (i = s; i <= e; ++i) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		umad_dev->port[i - s].umad_dev = umad_dev;
 
 		if (ib_umad_init_port(device, i, umad_dev,
 				      &umad_dev->port[i - s]))
 			goto err;
+
+		count++;
+	}
+
+	if (!count) {
+		kobject_put(&umad_dev->kobj);
+		return;
 	}
 
 	ib_set_client_data(device, &umad_client, umad_dev);
@@ -1308,8 +1316,12 @@ static void ib_umad_add_one(struct ib_device *device)
 	return;
 
 err:
-	while (--i >= s)
+	while (--i >= s) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		ib_umad_kill_port(&umad_dev->port[i - s]);
+	}
 
 	kobject_put(&umad_dev->kobj);
 }
@@ -1322,8 +1334,10 @@ static void ib_umad_remove_one(struct ib_device *device)
 	if (!umad_dev)
 		return;
 
-	for (i = 0; i <= umad_dev->end_port - umad_dev->start_port; ++i)
-		ib_umad_kill_port(&umad_dev->port[i]);
+	for (i = 0; i <= umad_dev->end_port - umad_dev->start_port; ++i) {
+		if (cap_ib_mad(device, i))
+			ib_umad_kill_port(&umad_dev->port[i]);
+	}
 
 	kobject_put(&umad_dev->kobj);
 }
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 780b3b7..4013933 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1773,6 +1773,21 @@ static inline int rdma_ib_mgmt(struct ib_device *device, u8 port_num)
 	return (tp == RDMA_TRANSPORT_IB || tp == RDMA_TRANSPORT_IBOE);
 }
 
+/**
+ * cap_ib_mad - Check if the port of device has the capability Infiniband
+ * Management Datagrams.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Management Datagrams.
+ */
+static inline int cap_ib_mad(struct ib_device *device, u8 port_num)
+{
+	return rdma_ib_mgmt(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
