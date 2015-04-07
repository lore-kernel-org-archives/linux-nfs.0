Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:32868 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbbDGMmG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:42:06 -0400
Received: by wgin8 with SMTP id n8so54660118wgi.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:42:05 -0700 (PDT)
Message-ID: <5523D098.3020007@profitbricks.com>
Date: Tue, 07 Apr 2015 14:42:00 +0200
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
Subject: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add new callback query_transport() and implement for each HW.

Mapping List:
		node-type	link-layer	old-transport	new-transport
nes		RNIC		ETH		IWARP		IWARP
amso1100	RNIC		ETH		IWARP		IWARP
cxgb3   	RNIC		ETH		IWARP		IWARP
cxgb4   	RNIC		ETH		IWARP		IWARP
usnic   	USNIC_UDP	ETH		USNIC_UDP	USNIC_UDP
ocrdma  	IB_CA		ETH		IB		IBOE
mlx4    	IB_CA		IB/ETH		IB		IB/IBOE
mlx5    	IB_CA		IB		IB		IB
ehca    	IB_CA		IB		IB		IB
ipath   	IB_CA		IB		IB		IB
mthca   	IB_CA		IB		IB		IB
qib     	IB_CA		IB		IB		IB

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/device.c             |  1 +
 drivers/infiniband/core/verbs.c              |  4 +++-
 drivers/infiniband/hw/amso1100/c2_provider.c |  7 +++++++
 drivers/infiniband/hw/cxgb3/iwch_provider.c  |  7 +++++++
 drivers/infiniband/hw/cxgb4/provider.c       |  7 +++++++
 drivers/infiniband/hw/ehca/ehca_hca.c        |  6 ++++++
 drivers/infiniband/hw/ehca/ehca_iverbs.h     |  3 +++
 drivers/infiniband/hw/ehca/ehca_main.c       |  1 +
 drivers/infiniband/hw/ipath/ipath_verbs.c    |  7 +++++++
 drivers/infiniband/hw/mlx4/main.c            | 10 ++++++++++
 drivers/infiniband/hw/mlx5/main.c            |  7 +++++++
 drivers/infiniband/hw/mthca/mthca_provider.c |  7 +++++++
 drivers/infiniband/hw/nes/nes_verbs.c        |  6 ++++++
 drivers/infiniband/hw/ocrdma/ocrdma_main.c   |  1 +
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c  |  6 ++++++
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h  |  3 +++
 drivers/infiniband/hw/qib/qib_verbs.c        |  7 +++++++
 drivers/infiniband/hw/usnic/usnic_ib_main.c  |  1 +
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c |  6 ++++++
 drivers/infiniband/hw/usnic/usnic_ib_verbs.h |  2 ++
 include/rdma/ib_verbs.h                      |  7 ++++++-
 21 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 18c1ece..a9587c4 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -76,6 +76,7 @@ static int ib_device_check_mandatory(struct ib_device *device)
 	} mandatory_table[] = {
 		IB_MANDATORY_FUNC(query_device),
 		IB_MANDATORY_FUNC(query_port),
+		IB_MANDATORY_FUNC(query_transport),
 		IB_MANDATORY_FUNC(query_pkey),
 		IB_MANDATORY_FUNC(query_gid),
 		IB_MANDATORY_FUNC(alloc_pd),
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index f93eb8d..83370de 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -133,14 +133,16 @@ enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device, u8 port_
 	if (device->get_link_layer)
 		return device->get_link_layer(device, port_num);
 
-	switch (rdma_node_get_transport(device->node_type)) {
+	switch (device->query_transport(device, port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_IBOE:
 		return IB_LINK_LAYER_INFINIBAND;
 	case RDMA_TRANSPORT_IWARP:
 	case RDMA_TRANSPORT_USNIC:
 	case RDMA_TRANSPORT_USNIC_UDP:
 		return IB_LINK_LAYER_ETHERNET;
 	default:
+		BUG();
 		return IB_LINK_LAYER_UNSPECIFIED;
 	}
 }
diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c b/drivers/infiniband/hw/amso1100/c2_provider.c
index bdf3507..d46bbb0 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -99,6 +99,12 @@ static int c2_query_port(struct ib_device *ibdev,
 	return 0;
 }
 
+static enum rdma_transport_type
+c2_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IWARP;
+}
+
 static int c2_query_pkey(struct ib_device *ibdev,
 			 u8 port, u16 index, u16 * pkey)
 {
@@ -801,6 +807,7 @@ int c2_register_device(struct c2_dev *dev)
 	dev->ibdev.dma_device = &dev->pcidev->dev;
 	dev->ibdev.query_device = c2_query_device;
 	dev->ibdev.query_port = c2_query_port;
+	dev->ibdev.query_transport = c2_query_transport;
 	dev->ibdev.query_pkey = c2_query_pkey;
 	dev->ibdev.query_gid = c2_query_gid;
 	dev->ibdev.alloc_ucontext = c2_alloc_ucontext;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 811b24a..09682e9e 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1232,6 +1232,12 @@ static int iwch_query_port(struct ib_device *ibdev,
 	return 0;
 }
 
+static enum rdma_transport_type
+iwch_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IWARP;
+}
+
 static ssize_t show_rev(struct device *dev, struct device_attribute *attr,
 			char *buf)
 {
@@ -1385,6 +1391,7 @@ int iwch_register_device(struct iwch_dev *dev)
 	dev->ibdev.dma_device = &(dev->rdev.rnic_info.pdev->dev);
 	dev->ibdev.query_device = iwch_query_device;
 	dev->ibdev.query_port = iwch_query_port;
+	dev->ibdev.query_transport = iwch_query_transport;
 	dev->ibdev.query_pkey = iwch_query_pkey;
 	dev->ibdev.query_gid = iwch_query_gid;
 	dev->ibdev.alloc_ucontext = iwch_alloc_ucontext;
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 66bd6a2..a445e0d 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -390,6 +390,12 @@ static int c4iw_query_port(struct ib_device *ibdev, u8 port,
 	return 0;
 }
 
+static enum rdma_transport_type
+c4iw_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IWARP;
+}
+
 static ssize_t show_rev(struct device *dev, struct device_attribute *attr,
 			char *buf)
 {
@@ -506,6 +512,7 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	dev->ibdev.dma_device = &(dev->rdev.lldi.pdev->dev);
 	dev->ibdev.query_device = c4iw_query_device;
 	dev->ibdev.query_port = c4iw_query_port;
+	dev->ibdev.query_transport = c4iw_query_transport;
 	dev->ibdev.query_pkey = c4iw_query_pkey;
 	dev->ibdev.query_gid = c4iw_query_gid;
 	dev->ibdev.alloc_ucontext = c4iw_alloc_ucontext;
diff --git a/drivers/infiniband/hw/ehca/ehca_hca.c b/drivers/infiniband/hw/ehca/ehca_hca.c
index 9ed4d25..d5a34a6 100644
--- a/drivers/infiniband/hw/ehca/ehca_hca.c
+++ b/drivers/infiniband/hw/ehca/ehca_hca.c
@@ -242,6 +242,12 @@ query_port1:
 	return ret;
 }
 
+enum rdma_transport_type
+ehca_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IB;
+}
+
 int ehca_query_sma_attr(struct ehca_shca *shca,
 			u8 port, struct ehca_sma_attr *attr)
 {
diff --git a/drivers/infiniband/hw/ehca/ehca_iverbs.h b/drivers/infiniband/hw/ehca/ehca_iverbs.h
index 22f79af..cec945f 100644
--- a/drivers/infiniband/hw/ehca/ehca_iverbs.h
+++ b/drivers/infiniband/hw/ehca/ehca_iverbs.h
@@ -49,6 +49,9 @@ int ehca_query_device(struct ib_device *ibdev, struct ib_device_attr *props);
 int ehca_query_port(struct ib_device *ibdev, u8 port,
 		    struct ib_port_attr *props);
 
+enum rdma_transport_type
+ehca_query_transport(struct ib_device *device, u8 port_num);
+
 int ehca_query_sma_attr(struct ehca_shca *shca, u8 port,
 			struct ehca_sma_attr *attr);
 
diff --git a/drivers/infiniband/hw/ehca/ehca_main.c b/drivers/infiniband/hw/ehca/ehca_main.c
index cd8d290..60e0a09 100644
--- a/drivers/infiniband/hw/ehca/ehca_main.c
+++ b/drivers/infiniband/hw/ehca/ehca_main.c
@@ -467,6 +467,7 @@ static int ehca_init_device(struct ehca_shca *shca)
 	shca->ib_device.dma_device          = &shca->ofdev->dev;
 	shca->ib_device.query_device        = ehca_query_device;
 	shca->ib_device.query_port          = ehca_query_port;
+	shca->ib_device.query_transport     = ehca_query_transport;
 	shca->ib_device.query_gid           = ehca_query_gid;
 	shca->ib_device.query_pkey          = ehca_query_pkey;
 	/* shca->in_device.modify_device    = ehca_modify_device    */
diff --git a/drivers/infiniband/hw/ipath/ipath_verbs.c b/drivers/infiniband/hw/ipath/ipath_verbs.c
index 44ea939..58d36e3 100644
--- a/drivers/infiniband/hw/ipath/ipath_verbs.c
+++ b/drivers/infiniband/hw/ipath/ipath_verbs.c
@@ -1638,6 +1638,12 @@ static int ipath_query_port(struct ib_device *ibdev,
 	return 0;
 }
 
+static enum rdma_transport_type
+ipath_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IB;
+}
+
 static int ipath_modify_device(struct ib_device *device,
 			       int device_modify_mask,
 			       struct ib_device_modify *device_modify)
@@ -2140,6 +2146,7 @@ int ipath_register_ib_device(struct ipath_devdata *dd)
 	dev->query_device = ipath_query_device;
 	dev->modify_device = ipath_modify_device;
 	dev->query_port = ipath_query_port;
+	dev->query_transport = ipath_query_transport;
 	dev->modify_port = ipath_modify_port;
 	dev->query_pkey = ipath_query_pkey;
 	dev->query_gid = ipath_query_gid;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 0b280b1..28100bd 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -413,6 +413,15 @@ static int mlx4_ib_query_port(struct ib_device *ibdev, u8 port,
 	return __mlx4_ib_query_port(ibdev, port, props, 0);
 }
 
+static enum rdma_transport_type
+mlx4_ib_query_transport(struct ib_device *device, u8 port_num)
+{
+	struct mlx4_dev *dev = to_mdev(device)->dev;
+
+	return dev->caps.port_mask[port_num] == MLX4_PORT_TYPE_IB ?
+		RDMA_TRANSPORT_IB : RDMA_TRANSPORT_IBOE;
+}
+
 int __mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
 			union ib_gid *gid, int netw_view)
 {
@@ -2121,6 +2130,7 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 
 	ibdev->ib_dev.query_device	= mlx4_ib_query_device;
 	ibdev->ib_dev.query_port	= mlx4_ib_query_port;
+	ibdev->ib_dev.query_transport	= mlx4_ib_query_transport;
 	ibdev->ib_dev.get_link_layer	= mlx4_ib_port_link_layer;
 	ibdev->ib_dev.query_gid		= mlx4_ib_query_gid;
 	ibdev->ib_dev.query_pkey	= mlx4_ib_query_pkey;
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index cc4ac1e..209c796 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -351,6 +351,12 @@ out:
 	return err;
 }
 
+static enum rdma_transport_type
+mlx5_ib_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IB;
+}
+
 static int mlx5_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
 			     union ib_gid *gid)
 {
@@ -1336,6 +1342,7 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 
 	dev->ib_dev.query_device	= mlx5_ib_query_device;
 	dev->ib_dev.query_port		= mlx5_ib_query_port;
+	dev->ib_dev.query_transport	= mlx5_ib_query_transport;
 	dev->ib_dev.query_gid		= mlx5_ib_query_gid;
 	dev->ib_dev.query_pkey		= mlx5_ib_query_pkey;
 	dev->ib_dev.modify_device	= mlx5_ib_modify_device;
diff --git a/drivers/infiniband/hw/mthca/mthca_provider.c b/drivers/infiniband/hw/mthca/mthca_provider.c
index 415f8e1..67ac6a4 100644
--- a/drivers/infiniband/hw/mthca/mthca_provider.c
+++ b/drivers/infiniband/hw/mthca/mthca_provider.c
@@ -179,6 +179,12 @@ static int mthca_query_port(struct ib_device *ibdev,
 	return err;
 }
 
+static enum rdma_transport_type
+mthca_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IB;
+}
+
 static int mthca_modify_device(struct ib_device *ibdev,
 			       int mask,
 			       struct ib_device_modify *props)
@@ -1281,6 +1287,7 @@ int mthca_register_device(struct mthca_dev *dev)
 	dev->ib_dev.dma_device           = &dev->pdev->dev;
 	dev->ib_dev.query_device         = mthca_query_device;
 	dev->ib_dev.query_port           = mthca_query_port;
+	dev->ib_dev.query_transport      = mthca_query_transport;
 	dev->ib_dev.modify_device        = mthca_modify_device;
 	dev->ib_dev.modify_port          = mthca_modify_port;
 	dev->ib_dev.query_pkey           = mthca_query_pkey;
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index c0d0296..8df5b61 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -606,6 +606,11 @@ static int nes_query_port(struct ib_device *ibdev, u8 port, struct ib_port_attr
 	return 0;
 }
 
+static enum rdma_transport_type
+nes_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IWARP;
+}
 
 /**
  * nes_query_pkey
@@ -3879,6 +3884,7 @@ struct nes_ib_device *nes_init_ofa_device(struct net_device *netdev)
 	nesibdev->ibdev.dev.parent = &nesdev->pcidev->dev;
 	nesibdev->ibdev.query_device = nes_query_device;
 	nesibdev->ibdev.query_port = nes_query_port;
+	nesibdev->ibdev.query_transport = nes_query_transport;
 	nesibdev->ibdev.query_pkey = nes_query_pkey;
 	nesibdev->ibdev.query_gid = nes_query_gid;
 	nesibdev->ibdev.alloc_ucontext = nes_alloc_ucontext;
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index 7a2b59a..9f4d182 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -244,6 +244,7 @@ static int ocrdma_register_device(struct ocrdma_dev *dev)
 	/* mandatory verbs. */
 	dev->ibdev.query_device = ocrdma_query_device;
 	dev->ibdev.query_port = ocrdma_query_port;
+	dev->ibdev.query_transport = ocrdma_query_transport;
 	dev->ibdev.modify_port = ocrdma_modify_port;
 	dev->ibdev.query_gid = ocrdma_query_gid;
 	dev->ibdev.get_link_layer = ocrdma_link_layer;
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index 8771755..73bace4 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -187,6 +187,12 @@ int ocrdma_query_port(struct ib_device *ibdev,
 	return 0;
 }
 
+enum rdma_transport_type
+ocrdma_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IBOE;
+}
+
 int ocrdma_modify_port(struct ib_device *ibdev, u8 port, int mask,
 		       struct ib_port_modify *props)
 {
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
index b8f7853..4a81b63 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
@@ -41,6 +41,9 @@ int ocrdma_query_port(struct ib_device *, u8 port, struct ib_port_attr *props);
 int ocrdma_modify_port(struct ib_device *, u8 port, int mask,
 		       struct ib_port_modify *props);
 
+enum rdma_transport_type
+ocrdma_query_transport(struct ib_device *device, u8 port_num);
+
 void ocrdma_get_guid(struct ocrdma_dev *, u8 *guid);
 int ocrdma_query_gid(struct ib_device *, u8 port,
 		     int index, union ib_gid *gid);
diff --git a/drivers/infiniband/hw/qib/qib_verbs.c b/drivers/infiniband/hw/qib/qib_verbs.c
index 4a35998..caad665 100644
--- a/drivers/infiniband/hw/qib/qib_verbs.c
+++ b/drivers/infiniband/hw/qib/qib_verbs.c
@@ -1650,6 +1650,12 @@ static int qib_query_port(struct ib_device *ibdev, u8 port,
 	return 0;
 }
 
+static enum rdma_transport_type
+qib_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_IB;
+}
+
 static int qib_modify_device(struct ib_device *device,
 			     int device_modify_mask,
 			     struct ib_device_modify *device_modify)
@@ -2184,6 +2190,7 @@ int qib_register_ib_device(struct qib_devdata *dd)
 	ibdev->query_device = qib_query_device;
 	ibdev->modify_device = qib_modify_device;
 	ibdev->query_port = qib_query_port;
+	ibdev->query_transport = qib_query_transport;
 	ibdev->modify_port = qib_modify_port;
 	ibdev->query_pkey = qib_query_pkey;
 	ibdev->query_gid = qib_query_gid;
diff --git a/drivers/infiniband/hw/usnic/usnic_ib_main.c b/drivers/infiniband/hw/usnic/usnic_ib_main.c
index 0d0f986..03ea9f3 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_main.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_main.c
@@ -360,6 +360,7 @@ static void *usnic_ib_device_add(struct pci_dev *dev)
 
 	us_ibdev->ib_dev.query_device = usnic_ib_query_device;
 	us_ibdev->ib_dev.query_port = usnic_ib_query_port;
+	us_ibdev->ib_dev.query_transport = usnic_ib_query_transport;
 	us_ibdev->ib_dev.query_pkey = usnic_ib_query_pkey;
 	us_ibdev->ib_dev.query_gid = usnic_ib_query_gid;
 	us_ibdev->ib_dev.get_link_layer = usnic_ib_port_link_layer;
diff --git a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
index 53bd6a2..ff9a5f7 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
@@ -348,6 +348,12 @@ int usnic_ib_query_port(struct ib_device *ibdev, u8 port,
 	return 0;
 }
 
+enum rdma_transport_type
+usnic_ib_query_transport(struct ib_device *device, u8 port_num)
+{
+	return RDMA_TRANSPORT_USNIC_UDP;
+}
+
 int usnic_ib_query_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
 				int qp_attr_mask,
 				struct ib_qp_init_attr *qp_init_attr)
diff --git a/drivers/infiniband/hw/usnic/usnic_ib_verbs.h b/drivers/infiniband/hw/usnic/usnic_ib_verbs.h
index bb864f5..0b1633b 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_verbs.h
+++ b/drivers/infiniband/hw/usnic/usnic_ib_verbs.h
@@ -27,6 +27,8 @@ int usnic_ib_query_device(struct ib_device *ibdev,
 				struct ib_device_attr *props);
 int usnic_ib_query_port(struct ib_device *ibdev, u8 port,
 				struct ib_port_attr *props);
+enum rdma_transport_type
+usnic_ib_query_transport(struct ib_device *device, u8 port_num);
 int usnic_ib_query_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
 				int qp_attr_mask,
 				struct ib_qp_init_attr *qp_init_attr);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 65994a1..d54f91e 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -75,10 +75,13 @@ enum rdma_node_type {
 };
 
 enum rdma_transport_type {
+	/* legacy for users */
 	RDMA_TRANSPORT_IB,
 	RDMA_TRANSPORT_IWARP,
 	RDMA_TRANSPORT_USNIC,
-	RDMA_TRANSPORT_USNIC_UDP
+	RDMA_TRANSPORT_USNIC_UDP,
+	/* new transport */
+	RDMA_TRANSPORT_IBOE,
 };
 
 __attribute_const__ enum rdma_transport_type
@@ -1501,6 +1504,8 @@ struct ib_device {
 	int		           (*query_port)(struct ib_device *device,
 						 u8 port_num,
 						 struct ib_port_attr *port_attr);
+	enum rdma_transport_type   (*query_transport)(struct ib_device *device,
+						      u8 port_num);
 	enum rdma_link_layer	   (*get_link_layer)(struct ib_device *device,
 						     u8 port_num);
 	int		           (*query_gid)(struct ib_device *device,
-- 
2.1.0
