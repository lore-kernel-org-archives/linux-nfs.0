Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35121 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753762AbbJHHvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:51:37 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/26] IB/mlx5: Remove dead fmr code
Date: Thu,  8 Oct 2015 10:50:45 +0300
Message-Id: <1444290669-5252-3-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just function declarations - no need for those
laying arround. If for some reason someone will want
FMR support in mlx5, it should be easy enough to restore
a few structs.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Bart Van Assche <bart.vanassche@sandisk.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h | 25 -------------------------
 1 file changed, 25 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 29f3ecdbe790..f789a3e6c215 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -364,20 +364,6 @@ enum {
 	MLX5_FMR_BUSY,
 };
 
-struct mlx5_ib_fmr {
-	struct ib_fmr			ibfmr;
-	struct mlx5_core_mr		mr;
-	int				access_flags;
-	int				state;
-	/* protect fmr state
-	 */
-	spinlock_t			lock;
-	u64				wrid;
-	struct ib_send_wr		wr[2];
-	u8				page_shift;
-	struct ib_fast_reg_page_list	page_list;
-};
-
 struct mlx5_cache_ent {
 	struct list_head	head;
 	/* sync access to the cahce entry
@@ -462,11 +448,6 @@ static inline struct mlx5_ib_dev *to_mdev(struct ib_device *ibdev)
 	return container_of(ibdev, struct mlx5_ib_dev, ib_dev);
 }
 
-static inline struct mlx5_ib_fmr *to_mfmr(struct ib_fmr *ibfmr)
-{
-	return container_of(ibfmr, struct mlx5_ib_fmr, ibfmr);
-}
-
 static inline struct mlx5_ib_cq *to_mcq(struct ib_cq *ibcq)
 {
 	return container_of(ibcq, struct mlx5_ib_cq, ibcq);
@@ -582,12 +563,6 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
 							       int page_list_len);
 void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
-struct ib_fmr *mlx5_ib_fmr_alloc(struct ib_pd *pd, int acc,
-				 struct ib_fmr_attr *fmr_attr);
-int mlx5_ib_map_phys_fmr(struct ib_fmr *ibfmr, u64 *page_list,
-		      int npages, u64 iova);
-int mlx5_ib_unmap_fmr(struct list_head *fmr_list);
-int mlx5_ib_fmr_dealloc(struct ib_fmr *ibfmr);
 int mlx5_ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 			const struct ib_wc *in_wc, const struct ib_grh *in_grh,
 			const struct ib_mad_hdr *in, size_t in_mad_size,
-- 
1.8.4.3

