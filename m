Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35035 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbbC0Ptz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:49:55 -0400
Received: by wgdm6 with SMTP id m6so103912581wgd.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:49:53 -0700 (PDT)
Message-ID: <55157C1E.7070905@profitbricks.com>
Date: Fri, 27 Mar 2015 16:49:50 +0100
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
Subject: [RFC PATCH 11/11] IB/Verbs: Use management helper cap_eth() for eth-check
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
 drivers/infiniband/core/cma.c        |  2 +-
 drivers/infiniband/core/sa_query.c   |  2 +-
 drivers/infiniband/core/verbs.c      |  4 ++--
 drivers/infiniband/hw/mlx4/ah.c      |  2 +-
 drivers/infiniband/hw/mlx4/cq.c      |  2 +-
 drivers/infiniband/hw/mlx4/mad.c     |  2 +-
 drivers/infiniband/hw/mlx4/main.c    |  2 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h |  2 +-
 drivers/infiniband/hw/mlx4/qp.c      | 15 +++++++--------
 drivers/infiniband/hw/mlx4/sysfs.c   |  4 ++--
 include/rdma/ib_verbs.h              |  8 ++++++++
 11 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 1f68816..8b9386b6 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -632,7 +632,7 @@ static int cma_modify_qp_rtr(struct rdma_id_private *id_priv,
         goto out;
 
     if (has_cm(id_priv->cma_dev->device) &&
-        rdma_port_ll_is_eth(id_priv->id.device, id_priv->id.port_num)) {
+        cap_eth(id_priv->id.device, id_priv->id.port_num)) {
         ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
 
         if (ret)
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 89c27da..7b32c47 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
     ah_attr->port_num = port_num;
     ah_attr->static_rate = rec->rate;
 
-    force_grh = rdma_port_ll_is_eth(device, port_num);
+    force_grh = cap_eth(device, port_num);
 
     if (rec->hop_limit > 1 || force_grh) {
         ah_attr->ah_flags = IB_AH_GRH;
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index d8d015a..4944460 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -198,7 +198,7 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
     u32 flow_class;
     u16 gid_index;
     int ret;
-    int is_eth = (rdma_port_ll_is_eth(device, port_num));
+    int is_eth = cap_eth(device, port_num);
 
     memset(ah_attr, 0, sizeof *ah_attr);
     if (is_eth) {
@@ -870,7 +870,7 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
     union ib_gid  sgid;
 
     if ((*qp_attr_mask & IB_QP_AV)  &&
-        (rdma_port_ll_is_eth(qp->device, qp_attr->ah_attr.port_num))) {
+        (cap_eth(qp->device, qp_attr->ah_attr.port_num))) {
         ret = ib_query_gid(qp->device, qp_attr->ah_attr.port_num,
                    qp_attr->ah_attr.grh.sgid_index, &sgid);
         if (ret)
diff --git a/drivers/infiniband/hw/mlx4/ah.c b/drivers/infiniband/hw/mlx4/ah.c
index 829eb60..c314c2d 100644
--- a/drivers/infiniband/hw/mlx4/ah.c
+++ b/drivers/infiniband/hw/mlx4/ah.c
@@ -118,7 +118,7 @@ struct ib_ah *mlx4_ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
     if (!ah)
         return ERR_PTR(-ENOMEM);
 
-    if (rdma_port_ll_is_eth(pd->device, ah_attr->port_num)) {
+    if (cap_eth(pd->device, ah_attr->port_num)) {
         if (!(ah_attr->ah_flags & IB_AH_GRH)) {
             ret = ERR_PTR(-EINVAL);
         } else {
diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index 0417f03..01922a9 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -789,7 +789,7 @@ repoll:
             break;
         }
 
-        is_eth = (rdma_port_ll_is_eth(wc->qp->device, (*cur_qp)->port));
+        is_eth = cap_eth(wc->qp->device, (*cur_qp)->port);
         if (mlx4_is_mfunc(to_mdev(cq->ibcq.device)->dev)) {
             if ((*cur_qp)->mlx4_ib_qp_type &
                 (MLX4_IB_QPT_PROXY_SMI_OWNER |
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 2a867fd..f544325 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -606,7 +606,7 @@ static int mlx4_ib_demux_mad(struct ib_device *ibdev, u8 port,
     int err;
     int slave;
     u8 *slave_id;
-    int is_eth = rdma_port_ll_is_eth(ibdev, port);
+    int is_eth = cap_eth(ibdev, port);
 
     if (is_eth) {
         if (!(wc->wc_flags & IB_WC_GRH)) {
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 1acc1c1..b007510 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1801,7 +1801,7 @@ static int mlx4_ib_init_gid_table(struct mlx4_ib_dev *ibdev)
     int err = 0;
 
     for (i = 1; i <= ibdev->num_ports; ++i) {
-        if (rdma_port_ll_is_eth(&ibdev->ib_dev, i)) {
+        if (cap_eth(&ibdev->ib_dev, i)) {
             err = reset_gid_table(ibdev, i);
             if (err)
                 goto out;
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 1befeb8..6958ffc 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -712,7 +712,7 @@ static inline bool mlx4_ib_ah_grh_present(struct mlx4_ib_ah *ah)
 {
     u8 port = be32_to_cpu(ah->av.ib.port_pd) >> 24 & 3;
 
-    if (rdma_port_ll_is_eth(ah->ibah.device, port))
+    if (cap_eth(ah->ibah.device, port))
         return true;
 
     return !!(ah->av.ib.g_slid & 0x80);
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index bd2f557..4d8172b 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1248,7 +1248,7 @@ static int _mlx4_set_path(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah,
               u64 smac, u16 vlan_tag, struct mlx4_qp_path *path,
               struct mlx4_roce_smac_vlan_info *smac_info, u8 port)
 {
-    int is_eth = rdma_port_ll_is_eth(&dev->ib_dev, port);
+    int is_eth = cap_eth(&dev->ib_dev, port);
     int vidx;
     int smac_index;
     int err;
@@ -1431,8 +1431,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
     int err = -EINVAL;
 
     /* APM is not supported under RoCE */
-    if (attr_mask & IB_QP_ALT_PATH &&
-        rdma_port_ll_is_eth(&dev->ib_dev, qp->port))
+    if (attr_mask & IB_QP_ALT_PATH && cap_eth(&dev->ib_dev, qp->port))
         return -ENOTSUPP;
 
     context = kzalloc(sizeof *context, GFP_KERNEL);
@@ -1662,7 +1661,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
                 context->pri_path.fl = 0x80;
             context->pri_path.sched_queue |= MLX4_IB_DEFAULT_SCHED_QUEUE;
         }
-        if (rdma_port_ll_is_eth(&dev->ib_dev, qp->port)) {
+        if (cap_eth(&dev->ib_dev, qp->port)) {
             if (qp->mlx4_ib_qp_type == MLX4_IB_QPT_TUN_GSI ||
                 qp->mlx4_ib_qp_type == MLX4_IB_QPT_GSI)
                 context->pri_path.feup = 1 << 7; /* don't fsm */
@@ -1692,7 +1691,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
     }
 
     if (ibqp->qp_type == IB_QPT_UD && (new_state == IB_QPS_RTR)) {
-        int is_eth = rdma_port_ll_is_eth(&dev->ib_dev, qp->port);
+        int is_eth = cap_eth(&dev->ib_dev, qp->port);
         if (is_eth) {
             context->pri_path.ackto = MLX4_IB_LINK_TYPE_ETH;
             optpar |= MLX4_QP_OPTPAR_PRIMARY_ADDR_PATH;
@@ -1922,7 +1921,7 @@ int mlx4_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
     }
 
     if ((attr_mask & IB_QP_PORT) && (ibqp->qp_type == IB_QPT_RAW_PACKET) &&
-        !rdma_port_ll_is_eth(&dev->ib_dev, attr->port_num))
+        !cap_eth(&dev->ib_dev, attr->port_num))
         goto out;
 
     if (attr_mask & IB_QP_PKEY_INDEX) {
@@ -2126,7 +2125,7 @@ static int build_mlx_header(struct mlx4_ib_sqp *sqp, struct ib_send_wr *wr,
     for (i = 0; i < wr->num_sge; ++i)
         send_size += wr->sg_list[i].length;
 
-    is_eth = rdma_port_ll_is_eth(sqp->qp.ibqp.device, sqp->qp.port);
+    is_eth = cap_eth(sqp->qp.ibqp.device, sqp->qp.port);
     is_grh = mlx4_ib_ah_grh_present(ah);
     if (is_eth) {
         if (mlx4_is_mfunc(to_mdev(ib_dev)->dev)) {
@@ -3023,7 +3022,7 @@ static void to_ib_ah_attr(struct mlx4_ib_dev *ibdev, struct ib_ah_attr *ib_ah_at
     if (ib_ah_attr->port_num == 0 || ib_ah_attr->port_num > dev->caps.num_ports)
         return;
 
-    is_eth = rdma_port_ll_is_eth(&ibdev->ib_dev, ib_ah_attr->port_num);
+    is_eth = cap_eth(&ibdev->ib_dev, ib_ah_attr->port_num);
     if (is_eth)
         ib_ah_attr->sl = ((path->sched_queue >> 3) & 0x7) |
         ((path->sched_queue & 4) << 1);
diff --git a/drivers/infiniband/hw/mlx4/sysfs.c b/drivers/infiniband/hw/mlx4/sysfs.c
index d339b55..83e0cf3 100644
--- a/drivers/infiniband/hw/mlx4/sysfs.c
+++ b/drivers/infiniband/hw/mlx4/sysfs.c
@@ -610,7 +610,7 @@ static ssize_t sysfs_store_enable_smi_admin(struct device *dev,
 
 static int add_vf_smi_entries(struct mlx4_port *p)
 {
-    int is_eth = rdma_port_ll_is_eth(&p->dev->ib_dev, p->port_num);
+    int is_eth = cap_eth(&p->dev->ib_dev, p->port_num);
     int ret;
 
     /* do not display entries if eth transport, or if master */
@@ -644,7 +644,7 @@ static int add_vf_smi_entries(struct mlx4_port *p)
 
 static void remove_vf_smi_entries(struct mlx4_port *p)
 {
-    int is_eth = rdma_port_ll_is_eth(&p->dev->ib_dev, p->port_num);
+    int is_eth = cap_eth(&p->dev->ib_dev, p->port_num);
 
     if (is_eth || p->slave == mlx4_master_func_num(p->dev->dev))
         return;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index deeaa52..e4a4b21 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1929,6 +1929,14 @@ static inline int cap_ib(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
 }
 
+/**
+ * TO BE CLASSIFIED
+ */
+static inline int cap_eth(struct ib_device *device, u8 port_num)
+{
+    return rdma_port_ll_is_eth(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0

