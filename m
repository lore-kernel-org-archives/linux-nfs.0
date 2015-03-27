Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35133 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030284AbbC0Ps0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:48:26 -0400
Received: by wgdm6 with SMTP id m6so103868081wgd.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:48:25 -0700 (PDT)
Message-ID: <55157BC6.70400@profitbricks.com>
Date: Fri, 27 Mar 2015 16:48:22 +0100
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
Subject: [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib() and,
 cap_ipoib() for ipoib-check
References: <551579CA.4030901@profitbricks.com>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper has_ipoib() and cap_ipoib() to help us check if an
IB device or it's port support IP over Infiniband.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |  6 +++---
 include/rdma/ib_verbs.h                   | 28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3341754..fcd7558 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1655,7 +1655,7 @@ static void ipoib_add_one(struct ib_device *device)
     struct ipoib_dev_priv *priv;
     int s, e, p;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_ipoib(device))
         return;
 
     dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
@@ -1673,7 +1673,7 @@ static void ipoib_add_one(struct ib_device *device)
     }
 
     for (p = s; p <= e; ++p) {
-        if (!rdma_port_ll_is_ib(device, p))
+        if (!cap_ipoib(device, p))
             continue;
         dev = ipoib_add_port("ib%d", device, p);
         if (!IS_ERR(dev)) {
@@ -1690,7 +1690,7 @@ static void ipoib_remove_one(struct ib_device *device)
     struct ipoib_dev_priv *priv, *tmp;
     struct list_head *dev_list;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_ipoib(device))
         return;
 
     dev_list = ib_get_client_data(device, &ipoib_client);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 0ef9cd7..eead588 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1849,6 +1849,19 @@ static inline int has_iwarp(struct ib_device *device)
 }
 
 /**
+ * has_ipoib - Check if a device support IP over Infiniband.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * IP over Infiniband.
+ */
+static inline int has_ipoib(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
@@ -1893,6 +1906,21 @@ static inline int cap_mcast(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
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
+    return rdma_port_ll_is_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0

