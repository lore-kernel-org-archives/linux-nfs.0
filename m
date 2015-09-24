Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41874 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757285AbbIXRgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:05 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 18/26] IB/mlx5: Remove old FRWR API support
Date: Thu, 24 Sep 2015 20:34:46 +0300
Message-Id: <1443116094-7969-19-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.
Keep only the local invalidate part of the handlers.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/mlx5/cq.c      |  3 --
 drivers/infiniband/hw/mlx5/main.c    |  2 -
 drivers/infiniband/hw/mlx5/mlx5_ib.h | 14 ------
 drivers/infiniband/hw/mlx5/mr.c      | 42 ----------------
 drivers/infiniband/hw/mlx5/qp.c      | 97 ++++--------------------------------
 5 files changed, 9 insertions(+), 149 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 90daf791d51d..640c54ef5eed 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -111,9 +111,6 @@ static enum ib_wc_opcode get_umr_comp(struct mlx5_ib_wq *wq, int idx)
 	case IB_WR_REG_MR:
 		return IB_WC_REG_MR;
 
-	case IB_WR_FAST_REG_MR:
-		return IB_WC_FAST_REG_MR;
-
 	default:
 		pr_warn("unknown completion status\n");
 		return 0;
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 7ebce545daf1..32f20d0fd632 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1433,8 +1433,6 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.process_mad		= mlx5_ib_process_mad;
 	dev->ib_dev.alloc_mr		= mlx5_ib_alloc_mr;
 	dev->ib_dev.map_mr_sg		= mlx5_ib_map_mr_sg;
-	dev->ib_dev.alloc_fast_reg_page_list = mlx5_ib_alloc_fast_reg_page_list;
-	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
 	dev->ib_dev.get_port_immutable  = mlx5_port_immutable;
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index bc1853f8e67d..91062d648125 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -337,12 +337,6 @@ struct mlx5_ib_mr {
 	int			live;
 };
 
-struct mlx5_ib_fast_reg_page_list {
-	struct ib_fast_reg_page_list	ibfrpl;
-	__be64			       *mapped_page_list;
-	dma_addr_t			map;
-};
-
 struct mlx5_ib_umr_context {
 	enum ib_wc_status	status;
 	struct completion	done;
@@ -493,11 +487,6 @@ static inline struct mlx5_ib_mr *to_mmr(struct ib_mr *ibmr)
 	return container_of(ibmr, struct mlx5_ib_mr, ibmr);
 }
 
-static inline struct mlx5_ib_fast_reg_page_list *to_mfrpl(struct ib_fast_reg_page_list *ibfrpl)
-{
-	return container_of(ibfrpl, struct mlx5_ib_fast_reg_page_list, ibfrpl);
-}
-
 struct mlx5_ib_ah {
 	struct ib_ah		ibah;
 	struct mlx5_av		av;
@@ -568,9 +557,6 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 int mlx5_ib_map_mr_sg(struct ib_mr *ibmr,
 		      struct scatterlist *sg,
 		      unsigned int sg_nents);
-struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
-							       int page_list_len);
-void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
 int mlx5_ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 			const struct ib_wc *in_wc, const struct ib_grh *in_grh,
 			const struct ib_mad_hdr *in, size_t in_mad_size,
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index e071685e192d..580c19b9fd66 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1389,48 +1389,6 @@ err_free:
 	return ERR_PTR(err);
 }
 
-struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
-							       int page_list_len)
-{
-	struct mlx5_ib_fast_reg_page_list *mfrpl;
-	int size = page_list_len * sizeof(u64);
-
-	mfrpl = kmalloc(sizeof(*mfrpl), GFP_KERNEL);
-	if (!mfrpl)
-		return ERR_PTR(-ENOMEM);
-
-	mfrpl->ibfrpl.page_list = kmalloc(size, GFP_KERNEL);
-	if (!mfrpl->ibfrpl.page_list)
-		goto err_free;
-
-	mfrpl->mapped_page_list = dma_alloc_coherent(ibdev->dma_device,
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
-void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list)
-{
-	struct mlx5_ib_fast_reg_page_list *mfrpl = to_mfrpl(page_list);
-	struct mlx5_ib_dev *dev = to_mdev(page_list->device);
-	int size = page_list->max_page_list_len * sizeof(u64);
-
-	dma_free_coherent(&dev->mdev->pdev->dev, size, mfrpl->mapped_page_list,
-			  mfrpl->map);
-	kfree(mfrpl->ibfrpl.page_list);
-	kfree(mfrpl);
-}
-
 int mlx5_ib_check_mr_status(struct ib_mr *ibmr, u32 check_mask,
 			    struct ib_mr_status *mr_status)
 {
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 61d3aa9a6ca9..96adc6f13dcb 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -64,7 +64,6 @@ static const u32 mlx5_ib_opcode[] = {
 	[IB_WR_ATOMIC_FETCH_AND_ADD]		= MLX5_OPCODE_ATOMIC_FA,
 	[IB_WR_SEND_WITH_INV]			= MLX5_OPCODE_SEND_INVAL,
 	[IB_WR_LOCAL_INV]			= MLX5_OPCODE_UMR,
-	[IB_WR_FAST_REG_MR]			= MLX5_OPCODE_UMR,
 	[IB_WR_REG_MR]				= MLX5_OPCODE_UMR,
 	[IB_WR_MASKED_ATOMIC_CMP_AND_SWP]	= MLX5_OPCODE_ATOMIC_MASKED_CS,
 	[IB_WR_MASKED_ATOMIC_FETCH_AND_ADD]	= MLX5_OPCODE_ATOMIC_MASKED_FA,
@@ -1913,20 +1912,11 @@ static void set_reg_umr_seg(struct mlx5_wqe_umr_ctrl_seg *umr,
 	umr->mkey_mask = frwr_mkey_mask();
 }
 
-static void set_frwr_umr_segment(struct mlx5_wqe_umr_ctrl_seg *umr,
-				 struct ib_send_wr *wr, int li)
+static void set_linv_umr_seg(struct mlx5_wqe_umr_ctrl_seg *umr)
 {
 	memset(umr, 0, sizeof(*umr));
-
-	if (li) {
-		umr->mkey_mask = cpu_to_be64(MLX5_MKEY_MASK_FREE);
-		umr->flags = 1 << 7;
-		return;
-	}
-
-	umr->flags = (1 << 5); /* fail if not free */
-	umr->klm_octowords = get_klm_octo(fast_reg_wr(wr)->page_list_len);
-	umr->mkey_mask = frwr_mkey_mask();
+	umr->mkey_mask = cpu_to_be64(MLX5_MKEY_MASK_FREE);
+	umr->flags = 1 << 7;
 }
 
 static __be64 get_umr_reg_mr_mask(void)
@@ -2020,24 +2010,10 @@ static void set_reg_mkey_seg(struct mlx5_mkey_seg *seg,
 	seg->log2_page_size = ilog2(mr->ibmr.page_size);
 }
 
-static void set_mkey_segment(struct mlx5_mkey_seg *seg, struct ib_send_wr *wr,
-			     int li, int *writ)
+static void set_linv_mkey_seg(struct mlx5_mkey_seg *seg)
 {
 	memset(seg, 0, sizeof(*seg));
-	if (li) {
-		seg->status = MLX5_MKEY_STATUS_FREE;
-		return;
-	}
-
-	seg->flags = get_umr_flags(fast_reg_wr(wr)->access_flags) |
-		     MLX5_ACCESS_MODE_MTT;
-	*writ = seg->flags & (MLX5_PERM_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE);
-	seg->qpn_mkey7_0 = cpu_to_be32((fast_reg_wr(wr)->rkey & 0xff) | 0xffffff00);
-	seg->flags_pd = cpu_to_be32(MLX5_MKEY_REMOTE_INVAL);
-	seg->start_addr = cpu_to_be64(fast_reg_wr(wr)->iova_start);
-	seg->len = cpu_to_be64(fast_reg_wr(wr)->length);
-	seg->xlt_oct_size = cpu_to_be32((fast_reg_wr(wr)->page_list_len + 1) / 2);
-	seg->log2_page_size = fast_reg_wr(wr)->page_shift;
+	seg->status = MLX5_MKEY_STATUS_FREE;
 }
 
 static void set_reg_mkey_segment(struct mlx5_mkey_seg *seg, struct ib_send_wr *wr)
@@ -2072,24 +2048,6 @@ static void set_reg_data_seg(struct mlx5_wqe_data_seg *dseg,
 	dseg->lkey = cpu_to_be32(pd->ibpd.local_dma_lkey);
 }
 
-static void set_frwr_pages(struct mlx5_wqe_data_seg *dseg,
-			   struct ib_send_wr *wr,
-			   struct mlx5_core_dev *mdev,
-			   struct mlx5_ib_pd *pd,
-			   int writ)
-{
-	struct mlx5_ib_fast_reg_page_list *mfrpl = to_mfrpl(fast_reg_wr(wr)->page_list);
-	u64 *page_list = fast_reg_wr(wr)->page_list->page_list;
-	u64 perm = MLX5_EN_RD | (writ ? MLX5_EN_WR : 0);
-	int i;
-
-	for (i = 0; i < fast_reg_wr(wr)->page_list_len; i++)
-		mfrpl->mapped_page_list[i] = cpu_to_be64(page_list[i] | perm);
-	dseg->addr = cpu_to_be64(mfrpl->map);
-	dseg->byte_count = cpu_to_be32(ALIGN(sizeof(u64) * fast_reg_wr(wr)->page_list_len, 64));
-	dseg->lkey = cpu_to_be32(pd->ibpd.local_dma_lkey);
-}
-
 static __be32 send_ieth(struct ib_send_wr *wr)
 {
 	switch (wr->opcode) {
@@ -2509,36 +2467,18 @@ static int set_reg_wr(struct mlx5_ib_qp *qp,
 	return 0;
 }
 
-static int set_frwr_li_wr(void **seg, struct ib_send_wr *wr, int *size,
-			  struct mlx5_core_dev *mdev, struct mlx5_ib_pd *pd, struct mlx5_ib_qp *qp)
+static void set_linv_wr(struct mlx5_ib_qp *qp, void **seg, int *size)
 {
-	int writ = 0;
-	int li;
-
-	li = wr->opcode == IB_WR_LOCAL_INV ? 1 : 0;
-	if (unlikely(wr->send_flags & IB_SEND_INLINE))
-		return -EINVAL;
-
-	set_frwr_umr_segment(*seg, wr, li);
+	set_linv_umr_seg(*seg);
 	*seg += sizeof(struct mlx5_wqe_umr_ctrl_seg);
 	*size += sizeof(struct mlx5_wqe_umr_ctrl_seg) / 16;
 	if (unlikely((*seg == qp->sq.qend)))
 		*seg = mlx5_get_send_wqe(qp, 0);
-	set_mkey_segment(*seg, wr, li, &writ);
+	set_linv_mkey_seg(*seg);
 	*seg += sizeof(struct mlx5_mkey_seg);
 	*size += sizeof(struct mlx5_mkey_seg) / 16;
 	if (unlikely((*seg == qp->sq.qend)))
 		*seg = mlx5_get_send_wqe(qp, 0);
-	if (!li) {
-		if (unlikely(fast_reg_wr(wr)->page_list_len >
-			     fast_reg_wr(wr)->page_list->max_page_list_len))
-			return	-ENOMEM;
-
-		set_frwr_pages(*seg, wr, mdev, pd, writ);
-		*seg += sizeof(struct mlx5_wqe_data_seg);
-		*size += (sizeof(struct mlx5_wqe_data_seg) / 16);
-	}
-	return 0;
 }
 
 static void dump_wqe(struct mlx5_ib_qp *qp, int idx, int size_16)
@@ -2654,7 +2594,6 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 {
 	struct mlx5_wqe_ctrl_seg *ctrl = NULL;  /* compiler warning */
 	struct mlx5_ib_dev *dev = to_mdev(ibqp->device);
-	struct mlx5_core_dev *mdev = dev->mdev;
 	struct mlx5_ib_qp *qp = to_mqp(ibqp);
 	struct mlx5_ib_mr *mr;
 	struct mlx5_wqe_data_seg *dpseg;
@@ -2729,25 +2668,7 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				next_fence = MLX5_FENCE_MODE_INITIATOR_SMALL;
 				qp->sq.wr_data[idx] = IB_WR_LOCAL_INV;
 				ctrl->imm = cpu_to_be32(wr->ex.invalidate_rkey);
-				err = set_frwr_li_wr(&seg, wr, &size, mdev, to_mpd(ibqp->pd), qp);
-				if (err) {
-					mlx5_ib_warn(dev, "\n");
-					*bad_wr = wr;
-					goto out;
-				}
-				num_sge = 0;
-				break;
-
-			case IB_WR_FAST_REG_MR:
-				next_fence = MLX5_FENCE_MODE_INITIATOR_SMALL;
-				qp->sq.wr_data[idx] = IB_WR_FAST_REG_MR;
-				ctrl->imm = cpu_to_be32(fast_reg_wr(wr)->rkey);
-				err = set_frwr_li_wr(&seg, wr, &size, mdev, to_mpd(ibqp->pd), qp);
-				if (err) {
-					mlx5_ib_warn(dev, "\n");
-					*bad_wr = wr;
-					goto out;
-				}
+				set_linv_wr(qp, &seg, &size);
 				num_sge = 0;
 				break;
 
-- 
1.8.4.3

