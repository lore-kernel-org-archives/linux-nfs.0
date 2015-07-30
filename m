Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52731 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754033AbbG3Hdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:31 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 08/15] mlx5: Drop mlx5_ib_alloc_fast_reg_mr
Date: Thu, 30 Jul 2015 10:32:41 +0300
Message-Id: <1438241568-3685-9-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c    |  1 -
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  2 --
 drivers/infiniband/hw/mlx5/mr.c      | 44 ------------------------------------
 3 files changed, 47 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 2c2a461..41d6911 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1490,7 +1490,6 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.detach_mcast	= mlx5_ib_mcg_detach;
 	dev->ib_dev.process_mad		= mlx5_ib_process_mad;
 	dev->ib_dev.alloc_mr		= mlx5_ib_alloc_mr;
-	dev->ib_dev.alloc_fast_reg_mr	= mlx5_ib_alloc_fast_reg_mr;
 	dev->ib_dev.alloc_fast_reg_page_list = mlx5_ib_alloc_fast_reg_page_list;
 	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 3030abe..a5fa0b9 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -575,8 +575,6 @@ int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
 struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 			       enum ib_mr_type mr_type,
 			       u32 max_num_sg);
-struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
-					int max_page_list_len);
 struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
 							       int page_list_len);
 void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index b0b68bb..09e6ae6 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1339,50 +1339,6 @@ err_free:
 	return ERR_PTR(err);
 }
 
-struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
-					int max_page_list_len)
-{
-	struct mlx5_ib_dev *dev = to_mdev(pd->device);
-	struct mlx5_create_mkey_mbox_in *in;
-	struct mlx5_ib_mr *mr;
-	int err;
-
-	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
-	if (!mr)
-		return ERR_PTR(-ENOMEM);
-
-	in = kzalloc(sizeof(*in), GFP_KERNEL);
-	if (!in) {
-		err = -ENOMEM;
-		goto err_free;
-	}
-
-	in->seg.status = MLX5_MKEY_STATUS_FREE;
-	in->seg.xlt_oct_size = cpu_to_be32((max_page_list_len + 1) / 2);
-	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
-	in->seg.flags = MLX5_PERM_UMR_EN | MLX5_ACCESS_MODE_MTT;
-	in->seg.flags_pd = cpu_to_be32(to_mpd(pd)->pdn);
-	/*
-	 * TBD not needed - issue 197292 */
-	in->seg.log2_page_size = PAGE_SHIFT;
-
-	err = mlx5_core_create_mkey(dev->mdev, &mr->mmr, in, sizeof(*in), NULL,
-				    NULL, NULL);
-	kfree(in);
-	if (err)
-		goto err_free;
-
-	mr->ibmr.lkey = mr->mmr.key;
-	mr->ibmr.rkey = mr->mmr.key;
-	mr->umem = NULL;
-
-	return &mr->ibmr;
-
-err_free:
-	kfree(mr);
-	return ERR_PTR(err);
-}
-
 struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
 							       int page_list_len)
 {
-- 
1.8.4.3

