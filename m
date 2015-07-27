Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:54226 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754525AbbG0W5y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 18:57:54 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 1/4] mlx4, mlx5, mthca: Expose max_sge_rd correctly
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Mon, 27 Jul 2015 17:57:54 -0500
Message-ID: <20150727225753.9959.76615.stgit@build2.ogc.int>
In-Reply-To: <20150727225408.9959.78916.stgit@build2.ogc.int>
References: <20150727225408.9959.78916.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sagi Grimberg <sagig@mellanox.com>

Applications must not assume that max_sge and max_sge_rd are the same,
Hence expose max_sge_rd correctly as well.

Reported-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---

 drivers/infiniband/hw/mlx4/main.c            |    1 +
 drivers/infiniband/hw/mlx5/main.c            |    1 +
 drivers/infiniband/hw/mthca/mthca_provider.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8be6db8..05166b7 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -229,6 +229,7 @@ static int mlx4_ib_query_device(struct ib_device *ibdev,
 	props->max_qp_wr	   = dev->dev->caps.max_wqes - MLX4_IB_SQ_MAX_SPARE;
 	props->max_sge		   = min(dev->dev->caps.max_sq_sg,
 					 dev->dev->caps.max_rq_sg);
+	props->max_sge_rd = props->max_sge;
 	props->max_cq		   = dev->dev->quotas.cq;
 	props->max_cqe		   = dev->dev->caps.max_cqes;
 	props->max_mr		   = dev->dev->quotas.mpt;
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 085c24b..bf27f21 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -273,6 +273,7 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 		     sizeof(struct mlx5_wqe_ctrl_seg)) /
 		     sizeof(struct mlx5_wqe_data_seg);
 	props->max_sge = min(max_rq_sg, max_sq_sg);
+	props->max_sge_rd = props->max_sge;
 	props->max_cq		   = 1 << MLX5_CAP_GEN(mdev, log_max_cq);
 	props->max_cqe = (1 << MLX5_CAP_GEN(mdev, log_max_eq_sz)) - 1;
 	props->max_mr		   = 1 << MLX5_CAP_GEN(mdev, log_max_mkey);
diff --git a/drivers/infiniband/hw/mthca/mthca_provider.c b/drivers/infiniband/hw/mthca/mthca_provider.c
index 93ae51d..dc2d48c 100644
--- a/drivers/infiniband/hw/mthca/mthca_provider.c
+++ b/drivers/infiniband/hw/mthca/mthca_provider.c
@@ -97,6 +97,7 @@ static int mthca_query_device(struct ib_device *ibdev, struct ib_device_attr *pr
 	props->max_qp              = mdev->limits.num_qps - mdev->limits.reserved_qps;
 	props->max_qp_wr           = mdev->limits.max_wqes;
 	props->max_sge             = mdev->limits.max_sg;
+	props->max_sge_rd          = props->max_sge;
 	props->max_cq              = mdev->limits.num_cqs - mdev->limits.reserved_cqs;
 	props->max_cqe             = mdev->limits.max_cqes;
 	props->max_mr              = mdev->limits.num_mpts - mdev->limits.reserved_mrws;

