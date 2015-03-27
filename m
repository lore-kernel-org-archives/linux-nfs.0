Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37613 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262AbbC0PrB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:47:01 -0400
Received: by wiaa2 with SMTP id a2so36751109wia.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:46:59 -0700 (PDT)
Message-ID: <55157B71.6040505@profitbricks.com>
Date: Fri, 27 Mar 2015 16:46:57 +0100
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
Subject: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and,
 cap_mcast() for mcast-check
References: <551579CA.4030901@profitbricks.com>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper has_mcast() and cap_mcast() to help us check if an
IB device or it's port support Multicast.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cma.c       |  2 +-
 drivers/infiniband/core/multicast.c |  8 ++++----
 include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 276fb76..cbbc85b 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
                 ib_detach_mcast(id->qp,
                         &mc->multicast.ib->rec.mgid,
                         be16_to_cpu(mc->multicast.ib->rec.mlid));
-            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
+            if (has_mcast(id_priv->cma_dev->device)) {
                 switch (rdma_port_get_link_layer(id->device, id->port_num)) {
                 case IB_LINK_LAYER_INFINIBAND:
                     ib_sa_free_multicast(mc->multicast.ib);
diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index 17573ff..ffeaf27 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
     int index;
 
     dev = container_of(handler, struct mcast_device, event_handler);
-    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
+    if (!cap_mcast(dev->device, event->element.port_num))
         return;
 
     index = event->element.port_num - dev->start_port;
@@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
     int i;
     int count = 0;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_mcast(device))
         return;
 
     dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
@@ -823,7 +823,7 @@ static void mcast_add_one(struct ib_device *device)
     }
 
     for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-        if (!rdma_port_ll_is_ib(device, dev->start_port + i))
+        if (!cap_mcast(device, dev->start_port + i))
             continue;
         port = &dev->port[i];
         port->dev = dev;
@@ -861,7 +861,7 @@ static void mcast_remove_one(struct ib_device *device)
     flush_workqueue(mcast_wq);
 
     for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-        if (rdma_port_ll_is_ib(device, dev->start_port + i)) {
+        if (cap_mcast(device, dev->start_port + i)) {
             port = &dev->port[i];
             deref_port(port);
             wait_for_completion(&port->comp);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index fa8ffa3..e796104 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1823,6 +1823,19 @@ static inline int has_sa(struct ib_device *device)
 }
 
 /**
+ * has_mcast - Check if a device support Multicast.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * Multicast.
+ */
+static inline int has_mcast(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
@@ -1852,6 +1865,21 @@ static inline int cap_sa(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
 }
 
+/**
+ * cap_mcast - Check if the port of device has the capability
+ * Multicast.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * Multicast.
+ */
+static inline int cap_mcast(struct ib_device *device, u8 port_num)
+{
+    return rdma_port_ll_is_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0

