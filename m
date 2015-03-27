Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34596 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbbC0PtJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:49:09 -0400
Received: by wgs2 with SMTP id 2so103934397wgs.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:49:08 -0700 (PDT)
Message-ID: <55157BF1.8020303@profitbricks.com>
Date: Fri, 27 Mar 2015 16:49:05 +0100
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
Subject: [RFC PATCH 10/11] IB/Verbs: Use management helper cap_ib() for ib-check
References: <551579CA.4030901@profitbricks.com>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


TODO:
    We need to classify these check into the management helper.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cma.c     | 5 ++---
 drivers/infiniband/hw/mlx4/mad.c  | 4 ++--
 drivers/infiniband/hw/mlx4/main.c | 5 ++---
 include/rdma/ib_verbs.h           | 8 ++++++++
 4 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index cbbc85b..1f68816 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -696,7 +696,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
     int ret;
     u16 pkey;
 
-    if (rdma_port_ll_is_ib(id_priv->id.device, id_priv->id.port_num))
+    if (cap_ib(id_priv->id.device, id_priv->id.port_num))
         pkey = ib_addr_get_pkey(dev_addr);
     else
         pkey = 0xffff;
@@ -2053,8 +2053,7 @@ port_found:
         goto out;
 
     id_priv->id.route.addr.dev_addr.dev_type =
-        (rdma_port_ll_is_ib(cma_dev->device, p)) ?
-        ARPHRD_INFINIBAND : ARPHRD_ETHER;
+        (cap_ib(cma_dev->device, p)) ? ARPHRD_INFINIBAND : ARPHRD_ETHER;
 
     rdma_addr_set_sgid(&id_priv->id.route.addr.dev_addr, &gid);
     ib_addr_set_pkey(&id_priv->id.route.addr.dev_addr, pkey);
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 09874d0..2a867fd 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -1247,7 +1247,7 @@ out:
 
 static int get_slave_base_gid_ix(struct mlx4_ib_dev *dev, int slave, int port)
 {
-    if (rdma_port_ll_is_ib(&dev->ib_dev, port))
+    if (cap_ib(&dev->ib_dev, port))
         return slave;
     return mlx4_get_base_gid_ix(dev->dev, slave, port);
 }
@@ -1255,7 +1255,7 @@ static int get_slave_base_gid_ix(struct mlx4_ib_dev *dev, int slave, int port)
 static void fill_in_real_sgid_index(struct mlx4_ib_dev *dev, int slave, int port,
                     struct ib_ah_attr *ah_attr)
 {
-    if (rdma_port_ll_is_ib(&dev->ib_dev, port))
+    if (cap_ib(&dev->ib_dev, port))
         ah_attr->grh.sgid_index = slave;
     else
         ah_attr->grh.sgid_index += get_slave_base_gid_ix(dev, slave, port);
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index f445f4c..1acc1c1 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -482,7 +482,7 @@ static int iboe_query_gid(struct ib_device *ibdev, u8 port, int index,
 static int mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
                  union ib_gid *gid)
 {
-    if (rdma_port_ll_is_ib(ibdev, port))
+    if (cap_ib(ibdev, port))
         return __mlx4_ib_query_gid(ibdev, port, index, gid, 0);
     else
         return iboe_query_gid(ibdev, port, index, gid);
@@ -2552,8 +2552,7 @@ static void mlx4_ib_event(struct mlx4_dev *dev, void *ibdev_ptr,
     case MLX4_DEV_EVENT_PORT_UP:
         if (p > ibdev->num_ports)
             return;
-        if (mlx4_is_master(dev) &&
-            rdma_port_ll_is_ib(&ibdev->ib_dev, p)) {
+        if (mlx4_is_master(dev) && cap_ib(&ibdev->ib_dev, p)) {
             mlx4_ib_invalidate_all_guid_record(ibdev, p);
         }
         ibev.event = IB_EVENT_PORT_ACTIVE;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index eead588..deeaa52 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1921,6 +1921,14 @@ static inline int cap_ipoib(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
 }
 
+/**
+ * TO BE CLASSIFIED
+ */
+static inline int cap_ib(struct ib_device *device, u8 port_num)
+{
+    return rdma_port_ll_is_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0

