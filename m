Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36382 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbC0Pos (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:44:48 -0400
Received: by wgra20 with SMTP id a20so103286723wgr.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:44:46 -0700 (PDT)
Message-ID: <55157AEB.7020705@profitbricks.com>
Date: Fri, 27 Mar 2015 16:44:43 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>,
        Michael Wang <yun.wang@profitbricks.com>
Subject: [RFC PATCH 04/11] IB/Verbs: Use management helper cap_smi() for smi-check
References: <551579CA.4030901@profitbricks.com>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_smi() to help us check if the port of an
IB device support Subnet Management Interface.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/agent.c  |  2 +-
 drivers/infiniband/core/mad.c    |  2 +-
 drivers/infiniband/hw/mlx4/mad.c |  2 +-
 include/rdma/ib_verbs.h          | 15 +++++++++++++++
 4 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/agent.c b/drivers/infiniband/core/agent.c
index 27f1bec..187514a 100644
--- a/drivers/infiniband/core/agent.c
+++ b/drivers/infiniband/core/agent.c
@@ -156,7 +156,7 @@ int ib_agent_port_open(struct ib_device *device, int port_num)
         goto error1;
     }
 
-    if (rdma_port_ll_is_ib(device, port_num)) {
+    if (cap_smi(device, port_num)) {
         /* Obtain send only MAD agent for SMI QP */
         port_priv->agent[0] = ib_register_mad_agent(device, port_num,
                                 IB_QPT_SMI, NULL, 0,
diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 896b749..c5d1ebb5b 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -2938,7 +2938,7 @@ static int ib_mad_port_open(struct ib_device *device,
     init_mad_qp(port_priv, &port_priv->qp_info[1]);
 
     cq_size = mad_sendq_size + mad_recvq_size;
-    has_smi = rdma_port_ll_is_ib(device, port_num);
+    has_smi = cap_smi(device, port_num);
     if (has_smi)
         cq_size *= 2;
 
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 4736fc7..09874d0 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -1753,7 +1753,7 @@ static int create_pv_resources(struct ib_device *ibdev, int slave, int port,
 
     ctx->state = DEMUX_PV_STATE_STARTING;
     /* have QP0 only if link layer is IB */
-    if (rdma_port_ll_is_ib(ibdev, ctx->port))
+    if (cap_smi(ibdev, ctx->port))
         ctx->has_smi = 1;
 
     if (ctx->has_smi) {
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 7b2bfe8..3d06178 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1796,6 +1796,21 @@ static inline int has_mad(struct ib_device *device)
     return rdma_transport_is_ib(device);
 }
 
+/**
+ * cap_smi - Check if the port of device has the capability
+ * Subnet Management Interface.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * Subnet Management Interface.
+ */
+static inline int cap_smi(struct ib_device *device, u8 port_num)
+{
+    return rdma_port_ll_is_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0

