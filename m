Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35130 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbbDGM3c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:29:32 -0400
Received: by wgyo15 with SMTP id o15so43388633wgy.2
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2015 05:29:31 -0700 (PDT)
Message-ID: <5523CDA7.8090902@profitbricks.com>
Date: Tue, 07 Apr 2015 14:29:27 +0200
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
Subject: [PATCH v2 02/17] IB/Verbs: Implement raw management helpers
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add raw helpers:
	rdma_transport_ib
	rdma_transport_iboe
	rdma_transport_iwarp
	rdma_ib_mgmt
To help us checking transport type.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 include/rdma/ib_verbs.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index d54f91e..780b3b7 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1748,6 +1748,31 @@ int ib_query_port(struct ib_device *device,
 enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device,
 					       u8 port_num);
 
+static inline int rdma_transport_ib(struct ib_device *device, u8 port_num)
+{
+	return device->query_transport(device, port_num)
+			== RDMA_TRANSPORT_IB;
+}
+
+static inline int rdma_transport_iboe(struct ib_device *device, u8 port_num)
+{
+	return device->query_transport(device, port_num)
+			== RDMA_TRANSPORT_IBOE;
+}
+
+static inline int rdma_transport_iwarp(struct ib_device *device, u8 port_num)
+{
+	return device->query_transport(device, port_num)
+			== RDMA_TRANSPORT_IWARP;
+}
+
+static inline int rdma_ib_mgmt(struct ib_device *device, u8 port_num)
+{
+	enum rdma_transport_type tp = device->query_transport(device, port_num);
+
+	return (tp == RDMA_TRANSPORT_IB || tp == RDMA_TRANSPORT_IBOE);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
