Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:32791 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbbDGMbe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:31:34 -0400
Received: by wgin8 with SMTP id n8so54361867wgi.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:31:33 -0700 (PDT)
Message-ID: <5523CE21.5090703@profitbricks.com>
Date: Tue, 07 Apr 2015 14:31:29 +0200
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
Subject: [PATCH v2 04/17] IB/Verbs: Use management helper cap_ib_smi() for
 smi-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ib_smi() to help us check if the port of an
IB device support Infiniband Subnet Management Interface.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/agent.c |  2 +-
 drivers/infiniband/core/mad.c   |  2 +-
 include/rdma/ib_verbs.h         | 15 +++++++++++++++
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/agent.c b/drivers/infiniband/core/agent.c
index f6d2961..61471ee 100644
--- a/drivers/infiniband/core/agent.c
+++ b/drivers/infiniband/core/agent.c
@@ -156,7 +156,7 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
 		goto error1;
 	}
 
-	if (rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_INFINIBAND) {
+	if (cap_ib_smi(device, port_num)) {
 		/* Obtain send only MAD agent for SMI QP */
 		port_priv->agent[0] = ib_register_mad_agent(device, port_num,
 							    IB_QPT_SMI, NULL, 0,
diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index ef0c0c5..2668d4e 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -2938,7 +2938,7 @@ static int ib_mad_port_open(struct ib_device *device,
 	init_mad_qp(port_priv, &port_priv->qp_info[1]);
 
 	cq_size = mad_sendq_size + mad_recvq_size;
-	has_smi = rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_INFINIBAND;
+	has_smi = cap_ib_smi(device, port_num);
 	if (has_smi)
 		cq_size *= 2;
 
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 4013933..ee76010 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1788,6 +1788,21 @@ static inline int cap_ib_mad(struct ib_device *device, u8 port_num)
 	return rdma_ib_mgmt(device, port_num);
 }
 
+/**
+ * cap_ib_smi - Check if the port of device has the capability Infiniband
+ * Subnet Management Interface.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Subnet Management Interface.
+ */
+static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
+{
+	return rdma_transport_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
