Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34085 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbDGMcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:32:10 -0400
Received: by wgbdm7 with SMTP id dm7so54398549wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:32:09 -0700 (PDT)
Message-ID: <5523CE45.4080606@profitbricks.com>
Date: Tue, 07 Apr 2015 14:32:05 +0200
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
Subject: [PATCH v2 05/17] IB/Verbs: Use management helper cap_ib_cm() for
 cm-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_cm() to help us check if the port of an
IB device support Infiniband Communication Manager.

Reform cm_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cm.c | 22 +++++++++++++++++++---
 include/rdma/ib_verbs.h      | 15 +++++++++++++++
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index e28a494..63418ee 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3761,9 +3761,7 @@ static void cm_add_one(struct ib_device *ib_device)
 	unsigned long flags;
 	int ret;
 	u8 i;
-
-	if (rdma_node_get_transport(ib_device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
 			 ib_device->phys_port_cnt, GFP_KERNEL);
@@ -3783,6 +3781,9 @@ static void cm_add_one(struct ib_device *ib_device)
 
 	set_bit(IB_MGMT_METHOD_SEND, reg_req.method_mask);
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = kzalloc(sizeof *port, GFP_KERNEL);
 		if (!port)
 			goto error1;
@@ -3809,7 +3810,16 @@ static void cm_add_one(struct ib_device *ib_device)
 		ret = ib_modify_port(ib_device, i, 0, &port_modify);
 		if (ret)
 			goto error3;
+
+		count++;
 	}
+
+	if (!count) {
+		device_unregister(cm_dev->device);
+		kfree(cm_dev);
+		return;
+	}
+
 	ib_set_client_data(ib_device, &cm_client, cm_dev);
 
 	write_lock_irqsave(&cm.device_lock, flags);
@@ -3825,6 +3835,9 @@ error1:
 	port_modify.set_port_cap_mask = 0;
 	port_modify.clr_port_cap_mask = IB_PORT_CM_SUP;
 	while (--i) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = cm_dev->port[i-1];
 		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
 		ib_unregister_mad_agent(port->mad_agent);
@@ -3853,6 +3866,9 @@ static void cm_remove_one(struct ib_device *ib_device)
 	write_unlock_irqrestore(&cm.device_lock, flags);
 
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = cm_dev->port[i-1];
 		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
 		ib_unregister_mad_agent(port->mad_agent);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ee76010..3ba963f 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1803,6 +1803,21 @@ static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
 	return rdma_transport_ib(device, port_num);
 }
 
+/**
+ * cap_ib_cm - Check if the port of device has the capability Infiniband
+ * Communication Manager.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Communication Manager.
+ */
+static inline int cap_ib_cm(struct ib_device *device, u8 port_num)
+{
+	return rdma_ib_mgmt(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
