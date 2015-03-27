Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38590 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbC0Pp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:45:29 -0400
Received: by wibgn9 with SMTP id gn9so36700367wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:45:28 -0700 (PDT)
Message-ID: <55157B15.3040400@profitbricks.com>
Date: Fri, 27 Mar 2015 16:45:25 +0100
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
Subject: [RFC PATCH 05/11] IB/Verbs: Use management helper has_cm() for cm-check
References: <551579CA.4030901@profitbricks.com>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Introduce helper has_cm() to help us check if an IB device
support Communication Manager.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cm.c  |  2 +-
 drivers/infiniband/core/cma.c | 10 ++++------
 drivers/infiniband/core/ucm.c |  2 +-
 include/rdma/ib_verbs.h       | 13 +++++++++++++
 4 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 2c72e9e..5c1f01b 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3762,7 +3762,7 @@ static void cm_add_one(struct ib_device *ib_device)
     int ret;
     u8 i;
 
-    if (!rdma_transport_is_ib(ib_device))
+    if (!has_cm(ib_device))
         return;
 
     cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 280cfe3..276fb76 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -433,7 +433,7 @@ static int cma_resolve_ib_dev(struct rdma_id_private *id_priv)
     pkey = ntohs(addr->sib_pkey);
 
     list_for_each_entry(cur_dev, &dev_list, list) {
-        if (!rdma_transport_is_ib(cur_dev->device))
+        if (!has_cm(cur_dev->device))
             continue;
 
         for (p = 1; p <= cur_dev->device->phys_port_cnt; ++p) {
@@ -631,7 +631,7 @@ static int cma_modify_qp_rtr(struct rdma_id_private *id_priv,
     if (ret)
         goto out;
 
-    if (rdma_transport_is_ib(id_priv->cma_dev->device) &&
+    if (has_cm(id_priv->cma_dev->device) &&
         rdma_port_ll_is_eth(id_priv->id.device, id_priv->id.port_num)) {
         ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
 
@@ -1620,8 +1620,7 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
     struct rdma_cm_id *id;
     int ret;
 
-    if (cma_family(id_priv) == AF_IB &&
-        !rdma_transport_is_ib(cma_dev->device))
+    if (cma_family(id_priv) == AF_IB && !has_cm(cma_dev->device))
         return;
 
     id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
@@ -2022,8 +2021,7 @@ static int cma_bind_loopback(struct rdma_id_private *id_priv)
     cma_dev = NULL;
     mutex_lock(&lock);
     list_for_each_entry(cur_dev, &dev_list, list) {
-        if (cma_family(id_priv) == AF_IB &&
-            !rdma_transport_is_ib(cur_dev->device))
+        if (cma_family(id_priv) == AF_IB && !has_cm(cur_dev->device))
             continue;
 
         if (!cma_dev)
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index ddbe0b4..7084181 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -1253,7 +1253,7 @@ static void ib_ucm_add_one(struct ib_device *device)
     dev_t base;
     struct ib_ucm_device *ucm_dev;
 
-    if (!device->alloc_ucontext || !rdma_transport_is_ib(device))
+    if (!device->alloc_ucontext || !has_cm(device))
         return;
 
     ucm_dev = kzalloc(sizeof *ucm_dev, GFP_KERNEL);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 3d06178..c0a63f8 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1797,6 +1797,19 @@ static inline int has_mad(struct ib_device *device)
 }
 
 /**
+ * has_cm - Check if a device support Communication Manager.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support Communication
+ * Manager.
+ */
+static inline int has_cm(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
-- 
2.1.0

