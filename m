Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33568 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbbDGMeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:34:07 -0400
Received: by wiax7 with SMTP id x7so9725157wia.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:34:06 -0700 (PDT)
Message-ID: <5523CEBA.7010808@profitbricks.com>
Date: Tue, 07 Apr 2015 14:34:02 +0200
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
Subject: [PATCH v2 08/17] IB/Verbs: Use management helper cap_ipoib() for
 ipoib-check
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper cap_ipoib() to help us check if the port of an
IB device support IP over Infiniband.

Reform ipoib_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 17 ++++++++++-------
 include/rdma/ib_verbs.h                   | 15 +++++++++++++++
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 58b5aa3..e36a926 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1654,9 +1654,7 @@ static void ipoib_add_one(struct ib_device *device)
 	struct net_device *dev;
 	struct ipoib_dev_priv *priv;
 	int s, e, p;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
 	if (!dev_list)
@@ -1673,13 +1671,21 @@ static void ipoib_add_one(struct ib_device *device)
 	}
 
 	for (p = s; p <= e; ++p) {
-		if (rdma_port_get_link_layer(device, p) != IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ipoib(device, p))
 			continue;
+
 		dev = ipoib_add_port("ib%d", device, p);
 		if (!IS_ERR(dev)) {
 			priv = netdev_priv(dev);
 			list_add_tail(&priv->list, dev_list);
 		}
+
+		count++;
+	}
+
+	if (!count) {
+		kfree(dev_list);
+		return;
 	}
 
 	ib_set_client_data(device, &ipoib_client, dev_list);
@@ -1690,9 +1696,6 @@ static void ipoib_remove_one(struct ib_device *device)
 	struct ipoib_dev_priv *priv, *tmp;
 	struct list_head *dev_list;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev_list = ib_get_client_data(device, &ipoib_client);
 	if (!dev_list)
 		return;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 5a5f6d5..9db8966 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1848,6 +1848,21 @@ static inline int cap_ib_mcast(struct ib_device *device, u8 port_num)
 	return cap_ib_sa(device, port_num);
 }
 
+/**
+ * cap_ipoib - Check if the port of device has the capability
+ * IP over Infiniband.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * IP over Infiniband.
+ */
+static inline int cap_ipoib(struct ib_device *device, u8 port_num)
+{
+	return rdma_transport_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
