Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41879 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757239AbbIXRgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:05 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 19/26] IB/mlx4: Remove old FRWR API support
Date: Thu, 24 Sep 2015 20:34:47 +0300
Message-Id: <1443116094-7969-20-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/mlx4/cq.c      |  3 +--
 drivers/infiniband/hw/mlx4/main.c    |  2 --
 drivers/infiniband/hw/mlx4/mlx4_ib.h | 15 -----------
 drivers/infiniband/hw/mlx4/mr.c      | 48 ------------------------------------
 drivers/infiniband/hw/mlx4/qp.c      | 31 -----------------------
 5 files changed, 1 insertion(+), 98 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index b62236e24708..84ff03618e31 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -818,8 +818,7 @@ repoll:
 			wc->opcode    = IB_WC_LSO;
 			break;
 		case MLX4_OPCODE_FMR:
-			wc->opcode    = IB_WC_FAST_REG_MR;
-			/* TODO: wc->opcode    = IB_WC_REG_MR; */
+			wc->opcode    = IB_WC_REG_MR;
 			break;
 		case MLX4_OPCODE_LOCAL_INVAL:
 			wc->opcode    = IB_WC_LOCAL_INV;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index bb82f5fa1612..a25048bf9913 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2248,8 +2248,6 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	ibdev->ib_dev.dereg_mr		= mlx4_ib_dereg_mr;
 	ibdev->ib_dev.alloc_mr		= mlx4_ib_alloc_mr;
 	ibdev->ib_dev.map_mr_sg		= mlx4_ib_map_mr_sg;
-	ibdev->ib_dev.alloc_fast_reg_page_list = mlx4_ib_alloc_fast_reg_page_list;
-	ibdev->ib_dev.free_fast_reg_page_list  = mlx4_ib_free_fast_reg_page_list;
 	ibdev->ib_dev.attach_mcast	= mlx4_ib_mcg_attach;
 	ibdev->ib_dev.detach_mcast	= mlx4_ib_mcg_detach;
 	ibdev->ib_dev.process_mad	= mlx4_ib_process_mad;
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 07fcf3a49256..de6eab38b024 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -144,12 +144,6 @@ struct mlx4_ib_mw {
 	struct mlx4_mw		mmw;
 };
 
-struct mlx4_ib_fast_reg_page_list {
-	struct ib_fast_reg_page_list	ibfrpl;
-	__be64			       *mapped_page_list;
-	dma_addr_t			map;
-};
-
 struct mlx4_ib_fmr {
 	struct ib_fmr           ibfmr;
 	struct mlx4_fmr         mfmr;
@@ -642,11 +636,6 @@ static inline struct mlx4_ib_mw *to_mmw(struct ib_mw *ibmw)
 	return container_of(ibmw, struct mlx4_ib_mw, ibmw);
 }
 
-static inline struct mlx4_ib_fast_reg_page_list *to_mfrpl(struct ib_fast_reg_page_list *ibfrpl)
-{
-	return container_of(ibfrpl, struct mlx4_ib_fast_reg_page_list, ibfrpl);
-}
-
 static inline struct mlx4_ib_fmr *to_mfmr(struct ib_fmr *ibfmr)
 {
 	return container_of(ibfmr, struct mlx4_ib_fmr, ibfmr);
@@ -713,10 +702,6 @@ struct ib_mr *mlx4_ib_alloc_mr(struct ib_pd *pd,
 int mlx4_ib_map_mr_sg(struct ib_mr *ibmr,
 		      struct scatterlist *sg,
 		      unsigned int sg_nents);
-struct ib_fast_reg_page_list *mlx4_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
-							       int page_list_len);
-void mlx4_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
-
 int mlx4_ib_modify_cq(struct ib_cq *cq, u16 cq_count, u16 cq_period);
 int mlx4_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata);
 struct ib_cq *mlx4_ib_create_cq(struct ib_device *ibdev,
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index c361a0d52b1f..fa01f7560e08 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -437,54 +437,6 @@ err_free:
 	return ERR_PTR(err);
 }
 
-struct ib_fast_reg_page_list *mlx4_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
-							       int page_list_len)
-{
-	struct mlx4_ib_dev *dev = to_mdev(ibdev);
-	struct mlx4_ib_fast_reg_page_list *mfrpl;
-	int size = page_list_len * sizeof (u64);
-
-	if (page_list_len > MLX4_MAX_FAST_REG_PAGES)
-		return ERR_PTR(-EINVAL);
-
-	mfrpl = kmalloc(sizeof *mfrpl, GFP_KERNEL);
-	if (!mfrpl)
-		return ERR_PTR(-ENOMEM);
-
-	mfrpl->ibfrpl.page_list = kmalloc(size, GFP_KERNEL);
-	if (!mfrpl->ibfrpl.page_list)
-		goto err_free;
-
-	mfrpl->mapped_page_list = dma_alloc_coherent(&dev->dev->persist->
-						     pdev->dev,
-						     size, &mfrpl->map,
-						     GFP_KERNEL);
-	if (!mfrpl->mapped_page_list)
-		goto err_free;
-
-	WARN_ON(mfrpl->map & 0x3f);
-
-	return &mfrpl->ibfrpl;
-
-err_free:
-	kfree(mfrpl->ibfrpl.page_list);
-	kfree(mfrpl);
-	return ERR_PTR(-ENOMEM);
-}
-
-void mlx4_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list)
-{
-	struct mlx4_ib_dev *dev = to_mdev(page_list->device);
-	struct mlx4_ib_fast_reg_page_list *mfrpl = to_mfrpl(page_list);
-	int size = page_list->max_page_list_len * sizeof (u64);
-
-	dma_free_coherent(&dev->dev->persist->pdev->dev, size,
-			  mfrpl->mapped_page_list,
-			  mfrpl->map);
-	kfree(mfrpl->ibfrpl.page_list);
-	kfree(mfrpl);
-}
-
 struct ib_fmr *mlx4_ib_fmr_alloc(struct ib_pd *pd, int acc,
 				 struct ib_fmr_attr *fmr_attr)
 {
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 850d4e9c13c5..b88a2b78ee88 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -111,7 +111,6 @@ static const __be32 mlx4_ib_opcode[] = {
 	[IB_WR_ATOMIC_FETCH_AND_ADD]		= cpu_to_be32(MLX4_OPCODE_ATOMIC_FA),
 	[IB_WR_SEND_WITH_INV]			= cpu_to_be32(MLX4_OPCODE_SEND_INVAL),
 	[IB_WR_LOCAL_INV]			= cpu_to_be32(MLX4_OPCODE_LOCAL_INVAL),
-	[IB_WR_FAST_REG_MR]			= cpu_to_be32(MLX4_OPCODE_FMR),
 	[IB_WR_REG_MR]				= cpu_to_be32(MLX4_OPCODE_FMR),
 	[IB_WR_MASKED_ATOMIC_CMP_AND_SWP]	= cpu_to_be32(MLX4_OPCODE_MASKED_ATOMIC_CS),
 	[IB_WR_MASKED_ATOMIC_FETCH_AND_ADD]	= cpu_to_be32(MLX4_OPCODE_MASKED_ATOMIC_FA),
@@ -2422,28 +2421,6 @@ static void set_reg_seg(struct mlx4_wqe_fmr_seg *fseg,
 	fseg->reserved[1]	= 0;
 }
 
-static void set_fmr_seg(struct mlx4_wqe_fmr_seg *fseg,
-		struct ib_fast_reg_wr *wr)
-{
-	struct mlx4_ib_fast_reg_page_list *mfrpl = to_mfrpl(wr->page_list);
-	int i;
-
-	for (i = 0; i < wr->page_list_len; ++i)
-		mfrpl->mapped_page_list[i] =
-			cpu_to_be64(wr->page_list->page_list[i] |
-				    MLX4_MTT_FLAG_PRESENT);
-
-	fseg->flags		= convert_access(wr->access_flags);
-	fseg->mem_key		= cpu_to_be32(wr->rkey);
-	fseg->buf_list		= cpu_to_be64(mfrpl->map);
-	fseg->start_addr	= cpu_to_be64(wr->iova_start);
-	fseg->reg_len		= cpu_to_be64(wr->length);
-	fseg->offset		= 0; /* XXX -- is this just for ZBVA? */
-	fseg->page_size		= cpu_to_be32(wr->page_shift);
-	fseg->reserved[0]	= 0;
-	fseg->reserved[1]	= 0;
-}
-
 static void set_bind_seg(struct mlx4_wqe_bind_seg *bseg,
 		struct ib_bind_mw_wr *wr)
 {
@@ -2775,14 +2752,6 @@ int mlx4_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				size += sizeof (struct mlx4_wqe_local_inval_seg) / 16;
 				break;
 
-			case IB_WR_FAST_REG_MR:
-				ctrl->srcrb_flags |=
-					cpu_to_be32(MLX4_WQE_CTRL_STRONG_ORDER);
-				set_fmr_seg(wqe, fast_reg_wr(wr));
-				wqe  += sizeof (struct mlx4_wqe_fmr_seg);
-				size += sizeof (struct mlx4_wqe_fmr_seg) / 16;
-				break;
-
 			case IB_WR_REG_MR:
 				ctrl->srcrb_flags |=
 					cpu_to_be32(MLX4_WQE_CTRL_STRONG_ORDER);
-- 
1.8.4.3

