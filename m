Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38462 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbbDGMiu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:38:50 -0400
Received: by wiun10 with SMTP id n10so16872698wiu.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:38:48 -0700 (PDT)
Message-ID: <5523CFD5.30704@profitbricks.com>
Date: Tue, 07 Apr 2015 14:38:45 +0200
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
Subject: [PATCH v2 15/17] IB/Verbs: Reform cma_acquire_dev() with management
 helpers
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Reform cma_acquire_dev() with management helpers, introduce
cma_validate_port() to make the code more clean.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/cma.c | 69 +++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 28 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e26b42e..dc05cd0 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -370,18 +370,36 @@ static int cma_translate_addr(struct sockaddr *addr, struct rdma_dev_addr *dev_a
 	return ret;
 }
 
+static inline int cma_validate_port(struct ib_device *device, u8 port,
+				      union ib_gid *gid, int dev_type)
+{
+	u8 found_port;
+	int ret = -ENODEV;
+
+	if ((dev_type == ARPHRD_INFINIBAND) && !rdma_transport_ib(device, port))
+		return ret;
+
+	if ((dev_type != ARPHRD_INFINIBAND) && rdma_transport_ib(device, port))
+		return ret;
+
+	ret = ib_find_cached_gid(device, gid, &found_port, NULL);
+
+	if (!ret && (port == found_port))
+		return 0;
+
+	return ret;
+}
+
 static int cma_acquire_dev(struct rdma_id_private *id_priv,
 			   struct rdma_id_private *listen_id_priv)
 {
 	struct rdma_dev_addr *dev_addr = &id_priv->id.route.addr.dev_addr;
 	struct cma_device *cma_dev;
-	union ib_gid gid, iboe_gid;
+	union ib_gid gid, iboe_gid, *gidp;
 	int ret = -ENODEV;
-	u8 port, found_port;
-	enum rdma_link_layer dev_ll = dev_addr->dev_type == ARPHRD_INFINIBAND ?
-		IB_LINK_LAYER_INFINIBAND : IB_LINK_LAYER_ETHERNET;
+	u8 port;
 
-	if (dev_ll != IB_LINK_LAYER_INFINIBAND &&
+	if (dev_addr->dev_type != ARPHRD_INFINIBAND &&
 	    id_priv->id.ps == RDMA_PS_IPOIB)
 		return -EINVAL;
 
@@ -391,41 +409,36 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv,
 
 	memcpy(&gid, dev_addr->src_dev_addr +
 	       rdma_addr_gid_offset(dev_addr), sizeof gid);
-	if (listen_id_priv &&
-	    rdma_port_get_link_layer(listen_id_priv->id.device,
-				     listen_id_priv->id.port_num) == dev_ll) {
+
+	if (listen_id_priv) {
 		cma_dev = listen_id_priv->cma_dev;
 		port = listen_id_priv->id.port_num;
-		if (rdma_node_get_transport(cma_dev->device->node_type) == RDMA_TRANSPORT_IB &&
-		    rdma_port_get_link_layer(cma_dev->device, port) == IB_LINK_LAYER_ETHERNET)
-			ret = ib_find_cached_gid(cma_dev->device, &iboe_gid,
-						 &found_port, NULL);
-		else
-			ret = ib_find_cached_gid(cma_dev->device, &gid,
-						 &found_port, NULL);
+		gidp = rdma_transport_iboe(cma_dev->device, port) ?
+		       &iboe_gid : &gid;
 
-		if (!ret && (port  == found_port)) {
-			id_priv->id.port_num = found_port;
+		ret = cma_validate_port(cma_dev->device, port, gidp,
+					dev_addr->dev_type);
+		if (!ret) {
+			id_priv->id.port_num = port;
 			goto out;
 		}
 	}
+
 	list_for_each_entry(cma_dev, &dev_list, list) {
 		for (port = 1; port <= cma_dev->device->phys_port_cnt; ++port) {
 			if (listen_id_priv &&
 			    listen_id_priv->cma_dev == cma_dev &&
 			    listen_id_priv->id.port_num == port)
 				continue;
-			if (rdma_port_get_link_layer(cma_dev->device, port) == dev_ll) {
-				if (rdma_node_get_transport(cma_dev->device->node_type) == RDMA_TRANSPORT_IB &&
-				    rdma_port_get_link_layer(cma_dev->device, port) == IB_LINK_LAYER_ETHERNET)
-					ret = ib_find_cached_gid(cma_dev->device, &iboe_gid, &found_port, NULL);
-				else
-					ret = ib_find_cached_gid(cma_dev->device, &gid, &found_port, NULL);
-
-				if (!ret && (port == found_port)) {
-					id_priv->id.port_num = found_port;
-					goto out;
-				}
+
+			gidp = rdma_transport_iboe(cma_dev->device, port) ?
+			       &iboe_gid : &gid;
+
+			ret = cma_validate_port(cma_dev->device, port, gidp,
+						dev_addr->dev_type);
+			if (!ret) {
+				id_priv->id.port_num = port;
+				goto out;
 			}
 		}
 	}
-- 
2.1.0
