Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38631 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbbCYLQN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 07:16:13 -0400
Received: by wibgn9 with SMTP id gn9so33446073wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 04:16:12 -0700 (PDT)
Message-ID: <551298F9.8030306@profitbricks.com>
Date: Wed, 25 Mar 2015 12:16:09 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Ira Weiny <ira.weiny@intel.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Colin Ian King <colin.king@canonical.com>,
        Mel Gorman <mgorman@suse.de>, Majd Dibbiny <majd@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>, Matan Barak <matanb@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Doug Ledford <dledford@redhat.com>,
        Alex Estrin <alex.estrin@intel.com>,
        Erez Shitrit <erezsh@mellanox.com>, Eric Dumazet <edumazet@google.com>,
        Tom Gundersen <teg@jklm.no>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] IB/Verbs: Use helpers to check IBoE technology
References: <55129832.2070707@profitbricks.com>
In-Reply-To: <55129832.2070707@profitbricks.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch will introduce rdma_tech_is_iboe() and use it to save some code.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
  drivers/infiniband/core/cma.c | 6 ++----
  include/rdma/ib_verbs.h       | 6 ++++++
  2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 668e955..d354857 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -375,8 +375,7 @@ static int cma_acquire_dev(struct rdma_id_private 
*id_priv,
                       listen_id_priv->id.port_num) == dev_ll) {
          cma_dev = listen_id_priv->cma_dev;
          port = listen_id_priv->id.port_num;
-        if (rdma_transport_is_ib(cma_dev->device) &&
-            rdma_port_ll_is_eth(cma_dev->device, port))
+        if (rdma_tech_is_iboe(cma_dev->device, port))
              ret = ib_find_cached_gid(cma_dev->device, &iboe_gid,
                           &found_port, NULL);
          else
@@ -395,8 +394,7 @@ static int cma_acquire_dev(struct rdma_id_private 
*id_priv,
                  listen_id_priv->id.port_num == port)
                  continue;
              if (rdma_port_get_link_layer(cma_dev->device, port) == 
dev_ll) {
-                if (rdma_transport_is_ib(cma_dev->device) &&
-                    rdma_port_ll_is_eth(cma_dev->device, port))
+                if (rdma_tech_is_iboe(cma_dev->device, port))
                      ret = ib_find_cached_gid(cma_dev->device, 
&iboe_gid, &found_port, NULL);
                  else
                      ret = ib_find_cached_gid(cma_dev->device, &gid, 
&found_port, NULL);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 2bf9094..9a811f8 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1767,6 +1767,12 @@ static inline int rdma_port_ll_is_eth(struct 
ib_device *device, u8 port_num)
              == IB_LINK_LAYER_ETHERNET;
  }

+static inline int rdma_tech_is_iboe(struct ib_device *device, u8 port_num)
+{
+    return rdma_transport_is_ib(device) &&
+            rdma_port_ll_is_eth(device, port_num);
+}
+
  int ib_query_gid(struct ib_device *device,
           u8 port_num, int index, union ib_gid *gid);

-- 
2.1.0

