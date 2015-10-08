Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35109 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752837AbbJHHvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:51:37 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/26] IB/mlx5: Support the new memory registration API
Date: Thu,  8 Oct 2015 10:50:46 +0300
Message-Id: <1444290669-5252-4-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in mlx5_ib_mr and populate it when
mlx5_ib_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by setting the exact WQE as IB_WR_FAST_REG_MR, just take the
needed information from different places:
- page_size, iova, length, access flags (ib_mr)
- page array (mlx5_ib_mr)
- key (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/mlx5/cq.c      |  3 ++
 drivers/infiniband/hw/mlx5/main.c    |  1 +
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  9 ++++
 drivers/infiniband/hw/mlx5/mr.c      | 93 ++++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/qp.c      | 83 ++++++++++++++++++++++++++++++++
 5 files changed, 189 insertions(+)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 2d0dbbf38ceb..206930096d56 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -109,6 +109,9 @@ static enum ib_wc_opcode get_umr_comp(struct mlx5_ib_wq *wq, int idx)
 	case IB_WR_LOCAL_INV:
 		return IB_WC_LOCAL_INV;
 
+	case IB_WR_REG_MR:
+		return IB_WC_REG_MR;
+
 	case IB_WR_FAST_REG_MR:
 		return IB_WC_FAST_REG_MR;
 
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index f1ccd40beae9..7e93044ea6ce 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1425,6 +1425,7 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.detach_mcast	= mlx5_ib_mcg_detach;
 	dev->ib_dev.process_mad		= mlx5_ib_process_mad;
 	dev->ib_dev.alloc_mr		= mlx5_ib_alloc_mr;
+	dev->ib_dev.map_mr_sg		= mlx5_ib_map_mr_sg;
 	dev->ib_dev.alloc_fast_reg_page_list = mlx5_ib_alloc_fast_reg_page_list;
 	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index f789a3e6c215..72672ae48296 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -319,6 +319,11 @@ enum mlx5_ib_mtt_access_flags {
 
 struct mlx5_ib_mr {
 	struct ib_mr		ibmr;
+	void			*descs;
+	dma_addr_t		desc_map;
+	int			ndescs;
+	int			max_descs;
+	int			desc_size;
 	struct mlx5_core_mr	mmr;
 	struct ib_umem	       *umem;
 	struct mlx5_shared_mr_info	*smr_info;
@@ -330,6 +335,7 @@ struct mlx5_ib_mr {
 	struct mlx5_create_mkey_mbox_out out;
 	struct mlx5_core_sig_ctx    *sig;
 	int			live;
+	void			*descs_alloc;
 };
 
 struct mlx5_ib_fast_reg_page_list {
@@ -560,6 +566,9 @@ int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
 struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 			       enum ib_mr_type mr_type,
 			       u32 max_num_sg);
+int mlx5_ib_map_mr_sg(struct ib_mr *ibmr,
+		      struct scatterlist *sg,
+		      unsigned int sg_nents);
 struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
 							       int page_list_len);
 void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 6a2fed3015ab..cabfe4190657 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1153,6 +1153,52 @@ error:
 	return err;
 }
 
+static int
+mlx5_alloc_priv_descs(struct ib_device *device,
+		      struct mlx5_ib_mr *mr,
+		      int ndescs,
+		      int desc_size)
+{
+	int size = ndescs * desc_size;
+	int add_size;
+	int ret;
+
+	add_size = max_t(int, MLX5_UMR_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
+
+	mr->descs_alloc = kzalloc(size + add_size, GFP_KERNEL);
+	if (!mr->descs_alloc)
+		return -ENOMEM;
+
+	mr->descs = PTR_ALIGN(mr->descs_alloc, MLX5_UMR_ALIGN);
+
+	mr->desc_map = dma_map_single(device->dma_device, mr->descs,
+				      size, DMA_TO_DEVICE);
+	if (dma_mapping_error(device->dma_device, mr->desc_map)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	return 0;
+err:
+	kfree(mr->descs_alloc);
+
+	return ret;
+}
+
+static void
+mlx5_free_priv_descs(struct mlx5_ib_mr *mr)
+{
+	if (mr->descs) {
+		struct ib_device *device = mr->ibmr.device;
+		int size = mr->max_descs * mr->desc_size;
+
+		dma_unmap_single(device->dma_device, mr->desc_map,
+				 size, DMA_TO_DEVICE);
+		kfree(mr->descs_alloc);
+		mr->descs = NULL;
+	}
+}
+
 static int clean_mr(struct mlx5_ib_mr *mr)
 {
 	struct mlx5_ib_dev *dev = to_mdev(mr->ibmr.device);
@@ -1172,6 +1218,8 @@ static int clean_mr(struct mlx5_ib_mr *mr)
 		mr->sig = NULL;
 	}
 
+	mlx5_free_priv_descs(mr);
+
 	if (!umred) {
 		err = destroy_mkey(dev, mr);
 		if (err) {
@@ -1261,6 +1309,14 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 	if (mr_type == IB_MR_TYPE_MEM_REG) {
 		access_mode = MLX5_ACCESS_MODE_MTT;
 		in->seg.log2_page_size = PAGE_SHIFT;
+
+		err = mlx5_alloc_priv_descs(pd->device, mr,
+					    ndescs, sizeof(u64));
+		if (err)
+			goto err_free_in;
+
+		mr->desc_size = sizeof(u64);
+		mr->max_descs = ndescs;
 	} else if (mr_type == IB_MR_TYPE_SIGNATURE) {
 		u32 psv_index[2];
 
@@ -1317,6 +1373,7 @@ err_destroy_psv:
 			mlx5_ib_warn(dev, "failed to destroy wire psv %d\n",
 				     mr->sig->psv_wire.psv_idx);
 	}
+	mlx5_free_priv_descs(mr);
 err_free_sig:
 	kfree(mr->sig);
 err_free_in:
@@ -1408,3 +1465,39 @@ int mlx5_ib_check_mr_status(struct ib_mr *ibmr, u32 check_mask,
 done:
 	return ret;
 }
+
+static int mlx5_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct mlx5_ib_mr *mr = to_mmr(ibmr);
+	__be64 *descs;
+
+	if (unlikely(mr->ndescs == mr->max_descs))
+		return -ENOMEM;
+
+	descs = mr->descs;
+	descs[mr->ndescs++] = cpu_to_be64(addr | MLX5_EN_RD | MLX5_EN_WR);
+
+	return 0;
+}
+
+int mlx5_ib_map_mr_sg(struct ib_mr *ibmr,
+		      struct scatterlist *sg,
+		      unsigned int sg_nents)
+{
+	struct mlx5_ib_mr *mr = to_mmr(ibmr);
+	int n;
+
+	mr->ndescs = 0;
+
+	ib_dma_sync_single_for_cpu(ibmr->device, mr->desc_map,
+				   mr->desc_size * mr->max_descs,
+				   DMA_TO_DEVICE);
+
+	n = ib_sg_to_pages(ibmr, sg, sg_nents, mlx5_set_page);
+
+	ib_dma_sync_single_for_device(ibmr->device, mr->desc_map,
+				      mr->desc_size * mr->max_descs,
+				      DMA_TO_DEVICE);
+
+	return n;
+}
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index d4c36af4270f..a71e43a4f028 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -65,6 +65,7 @@ static const u32 mlx5_ib_opcode[] = {
 	[IB_WR_SEND_WITH_INV]			= MLX5_OPCODE_SEND_INVAL,
 	[IB_WR_LOCAL_INV]			= MLX5_OPCODE_UMR,
 	[IB_WR_FAST_REG_MR]			= MLX5_OPCODE_UMR,
+	[IB_WR_REG_MR]				= MLX5_OPCODE_UMR,
 	[IB_WR_MASKED_ATOMIC_CMP_AND_SWP]	= MLX5_OPCODE_ATOMIC_MASKED_CS,
 	[IB_WR_MASKED_ATOMIC_FETCH_AND_ADD]	= MLX5_OPCODE_ATOMIC_MASKED_FA,
 	[MLX5_IB_WR_UMR]			= MLX5_OPCODE_UMR,
@@ -1896,6 +1897,17 @@ static __be64 sig_mkey_mask(void)
 	return cpu_to_be64(result);
 }
 
+static void set_reg_umr_seg(struct mlx5_wqe_umr_ctrl_seg *umr,
+				struct mlx5_ib_mr *mr)
+{
+	int ndescs = mr->ndescs;
+
+	memset(umr, 0, sizeof(*umr));
+	umr->flags = MLX5_UMR_CHECK_NOT_FREE;
+	umr->klm_octowords = get_klm_octo(ndescs);
+	umr->mkey_mask = frwr_mkey_mask();
+}
+
 static void set_frwr_umr_segment(struct mlx5_wqe_umr_ctrl_seg *umr,
 				 struct ib_send_wr *wr, int li)
 {
@@ -1987,6 +1999,22 @@ static u8 get_umr_flags(int acc)
 		MLX5_PERM_LOCAL_READ | MLX5_PERM_UMR_EN;
 }
 
+static void set_reg_mkey_seg(struct mlx5_mkey_seg *seg,
+			     struct mlx5_ib_mr *mr,
+			     u32 key, int access)
+{
+	int ndescs = ALIGN(mr->ndescs, 8) >> 1;
+
+	memset(seg, 0, sizeof(*seg));
+	seg->flags = get_umr_flags(access) | MLX5_ACCESS_MODE_MTT;
+	seg->qpn_mkey7_0 = cpu_to_be32((key & 0xff) | 0xffffff00);
+	seg->flags_pd = cpu_to_be32(MLX5_MKEY_REMOTE_INVAL);
+	seg->start_addr = cpu_to_be64(mr->ibmr.iova);
+	seg->len = cpu_to_be64(mr->ibmr.length);
+	seg->xlt_oct_size = cpu_to_be32(ndescs);
+	seg->log2_page_size = ilog2(mr->ibmr.page_size);
+}
+
 static void set_mkey_segment(struct mlx5_mkey_seg *seg, struct ib_send_wr *wr,
 			     int li, int *writ)
 {
@@ -2028,6 +2056,17 @@ static void set_reg_mkey_segment(struct mlx5_mkey_seg *seg, struct ib_send_wr *w
 				       mlx5_mkey_variant(umrwr->mkey));
 }
 
+static void set_reg_data_seg(struct mlx5_wqe_data_seg *dseg,
+			     struct mlx5_ib_mr *mr,
+			     struct mlx5_ib_pd *pd)
+{
+	int bcount = mr->desc_size * mr->ndescs;
+
+	dseg->addr = cpu_to_be64(mr->desc_map);
+	dseg->byte_count = cpu_to_be32(ALIGN(bcount, 64));
+	dseg->lkey = cpu_to_be32(pd->ibpd.local_dma_lkey);
+}
+
 static void set_frwr_pages(struct mlx5_wqe_data_seg *dseg,
 			   struct ib_send_wr *wr,
 			   struct mlx5_core_dev *mdev,
@@ -2433,6 +2472,38 @@ static int set_psv_wr(struct ib_sig_domain *domain,
 	return 0;
 }
 
+static int set_reg_wr(struct mlx5_ib_qp *qp,
+		      struct ib_reg_wr *wr,
+		      void **seg, int *size)
+{
+	struct mlx5_ib_mr *mr = to_mmr(wr->mr);
+	struct mlx5_ib_pd *pd = to_mpd(qp->ibqp.pd);
+
+	if (unlikely(wr->wr.send_flags & IB_SEND_INLINE)) {
+		mlx5_ib_warn(to_mdev(qp->ibqp.device),
+			     "Invalid IB_SEND_INLINE send flag\n");
+		return -EINVAL;
+	}
+
+	set_reg_umr_seg(*seg, mr);
+	*seg += sizeof(struct mlx5_wqe_umr_ctrl_seg);
+	*size += sizeof(struct mlx5_wqe_umr_ctrl_seg) / 16;
+	if (unlikely((*seg == qp->sq.qend)))
+		*seg = mlx5_get_send_wqe(qp, 0);
+
+	set_reg_mkey_seg(*seg, mr, wr->key, wr->access);
+	*seg += sizeof(struct mlx5_mkey_seg);
+	*size += sizeof(struct mlx5_mkey_seg) / 16;
+	if (unlikely((*seg == qp->sq.qend)))
+		*seg = mlx5_get_send_wqe(qp, 0);
+
+	set_reg_data_seg(*seg, mr, pd);
+	*seg += sizeof(struct mlx5_wqe_data_seg);
+	*size += (sizeof(struct mlx5_wqe_data_seg) / 16);
+
+	return 0;
+}
+
 static int set_frwr_li_wr(void **seg, struct ib_send_wr *wr, int *size,
 			  struct mlx5_core_dev *mdev, struct mlx5_ib_pd *pd, struct mlx5_ib_qp *qp)
 {
@@ -2676,6 +2747,18 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				num_sge = 0;
 				break;
 
+			case IB_WR_REG_MR:
+				next_fence = MLX5_FENCE_MODE_INITIATOR_SMALL;
+				qp->sq.wr_data[idx] = IB_WR_REG_MR;
+				ctrl->imm = cpu_to_be32(reg_wr(wr)->key);
+				err = set_reg_wr(qp, reg_wr(wr), &seg, &size);
+				if (err) {
+					*bad_wr = wr;
+					goto out;
+				}
+				num_sge = 0;
+				break;
+
 			case IB_WR_REG_SIG_MR:
 				qp->sq.wr_data[idx] = IB_WR_REG_SIG_MR;
 				mr = to_mmr(sig_handover_wr(wr)->sig_mr);
-- 
1.8.4.3

