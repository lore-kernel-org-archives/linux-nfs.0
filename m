Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41945 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757409AbbIXRgw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:52 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 04/26] IB/mlx4: Support the new memory registration API
Date: Thu, 24 Sep 2015 20:34:56 +0300
Message-Id: <1443116118-10730-5-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in mlx4_ib_mr and populate it when
mlx4_ib_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by setting the exact WQE as IB_WR_FAST_REG_MR, just take the
needed information from different places:
- page_size, iova, length, access flags (ib_mr)
- page array (mlx4_ib_mr)
- key (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Christoph Hellwig <hch@lst.de>
Tested-by: Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 drivers/infiniband/hw/mlx4/cq.c      |  1 +
 drivers/infiniband/hw/mlx4/main.c    |  1 +
 drivers/infiniband/hw/mlx4/mlx4_ib.h |  7 +++
 drivers/infiniband/hw/mlx4/mr.c      | 95 +++++++++++++++++++++++++++++++++---
 drivers/infiniband/hw/mlx4/qp.c      | 25 ++++++++++
 5 files changed, 123 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index 2f4259525bb1..b62236e24708 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -819,6 +819,7 @@ repoll:
 			break;
 		case MLX4_OPCODE_FMR:
 			wc->opcode    = IB_WC_FAST_REG_MR;
+			/* TODO: wc->opcode    = IB_WC_REG_MR; */
 			break;
 		case MLX4_OPCODE_LOCAL_INVAL:
 			wc->opcode    = IB_WC_LOCAL_INV;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index efecdf0216d8..bb82f5fa1612 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2247,6 +2247,7 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	ibdev->ib_dev.rereg_user_mr	= mlx4_ib_rereg_user_mr;
 	ibdev->ib_dev.dereg_mr		= mlx4_ib_dereg_mr;
 	ibdev->ib_dev.alloc_mr		= mlx4_ib_alloc_mr;
+	ibdev->ib_dev.map_mr_sg		= mlx4_ib_map_mr_sg;
 	ibdev->ib_dev.alloc_fast_reg_page_list = mlx4_ib_alloc_fast_reg_page_list;
 	ibdev->ib_dev.free_fast_reg_page_list  = mlx4_ib_free_fast_reg_page_list;
 	ibdev->ib_dev.attach_mcast	= mlx4_ib_mcg_attach;
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 1e7b23bb2eb0..07fcf3a49256 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -131,6 +131,10 @@ struct mlx4_ib_cq {
 
 struct mlx4_ib_mr {
 	struct ib_mr		ibmr;
+	__be64			*pages;
+	dma_addr_t		page_map;
+	u32			npages;
+	u32			max_pages;
 	struct mlx4_mr		mmr;
 	struct ib_umem	       *umem;
 };
@@ -706,6 +710,9 @@ int mlx4_ib_dealloc_mw(struct ib_mw *mw);
 struct ib_mr *mlx4_ib_alloc_mr(struct ib_pd *pd,
 			       enum ib_mr_type mr_type,
 			       u32 max_num_sg);
+int mlx4_ib_map_mr_sg(struct ib_mr *ibmr,
+		      struct scatterlist *sg,
+		      unsigned int sg_nents);
 struct ib_fast_reg_page_list *mlx4_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
 							       int page_list_len);
 void mlx4_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 5bba176e9dfa..c361a0d52b1f 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -59,7 +59,7 @@ struct ib_mr *mlx4_ib_get_dma_mr(struct ib_pd *pd, int acc)
 	struct mlx4_ib_mr *mr;
 	int err;
 
-	mr = kmalloc(sizeof *mr, GFP_KERNEL);
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
 		return ERR_PTR(-ENOMEM);
 
@@ -140,7 +140,7 @@ struct ib_mr *mlx4_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 	int err;
 	int n;
 
-	mr = kmalloc(sizeof *mr, GFP_KERNEL);
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
 		return ERR_PTR(-ENOMEM);
 
@@ -271,11 +271,53 @@ release_mpt_entry:
 	return err;
 }
 
+static int
+mlx4_alloc_priv_pages(struct ib_device *device,
+		      struct mlx4_ib_mr *mr,
+		      int max_pages)
+{
+	int size = max_pages * sizeof(u64);
+	int ret;
+
+	mr->pages = kzalloc(size, GFP_KERNEL);
+	if (!mr->pages)
+		return -ENOMEM;
+
+	mr->page_map = dma_map_single(device->dma_device, mr->pages,
+				      size, DMA_TO_DEVICE);
+
+	if (dma_mapping_error(device->dma_device, mr->page_map)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	return 0;
+err:
+	kfree(mr->pages);
+	return ret;
+}
+
+static void
+mlx4_free_priv_pages(struct mlx4_ib_mr *mr)
+{
+	struct ib_device *device = mr->ibmr.device;
+	int size = mr->max_pages * sizeof(u64);
+
+	if (mr->pages) {
+		dma_unmap_single(device->dma_device, mr->page_map,
+				 size, DMA_TO_DEVICE);
+		kfree(mr->pages);
+		mr->pages = NULL;
+	}
+}
+
 int mlx4_ib_dereg_mr(struct ib_mr *ibmr)
 {
 	struct mlx4_ib_mr *mr = to_mmr(ibmr);
 	int ret;
 
+	mlx4_free_priv_pages(mr);
+
 	ret = mlx4_mr_free(to_mdev(ibmr->device)->dev, &mr->mmr);
 	if (ret)
 		return ret;
@@ -362,7 +404,7 @@ struct ib_mr *mlx4_ib_alloc_mr(struct ib_pd *pd,
 	    max_num_sg > MLX4_MAX_FAST_REG_PAGES)
 		return ERR_PTR(-EINVAL);
 
-	mr = kmalloc(sizeof *mr, GFP_KERNEL);
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
 		return ERR_PTR(-ENOMEM);
 
@@ -371,18 +413,25 @@ struct ib_mr *mlx4_ib_alloc_mr(struct ib_pd *pd,
 	if (err)
 		goto err_free;
 
+	err = mlx4_alloc_priv_pages(pd->device, mr, max_num_sg);
+	if (err)
+		goto err_free_mr;
+
+	mr->max_pages = max_num_sg;
+
 	err = mlx4_mr_enable(dev->dev, &mr->mmr);
 	if (err)
-		goto err_mr;
+		goto err_free_pl;
 
 	mr->ibmr.rkey = mr->ibmr.lkey = mr->mmr.key;
 	mr->umem = NULL;
 
 	return &mr->ibmr;
 
-err_mr:
+err_free_pl:
+	mlx4_free_priv_pages(mr);
+err_free_mr:
 	(void) mlx4_mr_free(dev->dev, &mr->mmr);
-
 err_free:
 	kfree(mr);
 	return ERR_PTR(err);
@@ -528,3 +577,37 @@ int mlx4_ib_fmr_dealloc(struct ib_fmr *ibfmr)
 
 	return err;
 }
+
+static int mlx4_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct mlx4_ib_mr *mr = to_mmr(ibmr);
+
+	if (unlikely(mr->npages == mr->max_pages))
+		return -ENOMEM;
+
+	mr->pages[mr->npages++] = cpu_to_be64(addr | MLX4_MTT_FLAG_PRESENT);
+
+	return 0;
+}
+
+int mlx4_ib_map_mr_sg(struct ib_mr *ibmr,
+		      struct scatterlist *sg,
+		      unsigned int sg_nents)
+{
+	struct mlx4_ib_mr *mr = to_mmr(ibmr);
+	int rc;
+
+	mr->npages = 0;
+
+	ib_dma_sync_single_for_cpu(ibmr->device, mr->page_map,
+				   sizeof(u64) * mr->max_pages,
+				   DMA_TO_DEVICE);
+
+	rc = ib_sg_to_pages(ibmr, sg, sg_nents, mlx4_set_page);
+
+	ib_dma_sync_single_for_device(ibmr->device, mr->page_map,
+				      sizeof(u64) * mr->max_pages,
+				      DMA_TO_DEVICE);
+
+	return rc;
+}
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 3831cddb551f..850d4e9c13c5 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -112,6 +112,7 @@ static const __be32 mlx4_ib_opcode[] = {
 	[IB_WR_SEND_WITH_INV]			= cpu_to_be32(MLX4_OPCODE_SEND_INVAL),
 	[IB_WR_LOCAL_INV]			= cpu_to_be32(MLX4_OPCODE_LOCAL_INVAL),
 	[IB_WR_FAST_REG_MR]			= cpu_to_be32(MLX4_OPCODE_FMR),
+	[IB_WR_REG_MR]				= cpu_to_be32(MLX4_OPCODE_FMR),
 	[IB_WR_MASKED_ATOMIC_CMP_AND_SWP]	= cpu_to_be32(MLX4_OPCODE_MASKED_ATOMIC_CS),
 	[IB_WR_MASKED_ATOMIC_FETCH_AND_ADD]	= cpu_to_be32(MLX4_OPCODE_MASKED_ATOMIC_FA),
 	[IB_WR_BIND_MW]				= cpu_to_be32(MLX4_OPCODE_BIND_MW),
@@ -2405,6 +2406,22 @@ static __be32 convert_access(int acc)
 		cpu_to_be32(MLX4_WQE_FMR_PERM_LOCAL_READ);
 }
 
+static void set_reg_seg(struct mlx4_wqe_fmr_seg *fseg,
+			struct ib_reg_wr *wr)
+{
+	struct mlx4_ib_mr *mr = to_mmr(wr->mr);
+
+	fseg->flags		= convert_access(wr->access);
+	fseg->mem_key		= cpu_to_be32(wr->key);
+	fseg->buf_list		= cpu_to_be64(mr->page_map);
+	fseg->start_addr	= cpu_to_be64(mr->ibmr.iova);
+	fseg->reg_len		= cpu_to_be64(mr->ibmr.length);
+	fseg->offset		= 0; /* XXX -- is this just for ZBVA? */
+	fseg->page_size		= cpu_to_be32(ilog2(mr->ibmr.page_size));
+	fseg->reserved[0]	= 0;
+	fseg->reserved[1]	= 0;
+}
+
 static void set_fmr_seg(struct mlx4_wqe_fmr_seg *fseg,
 		struct ib_fast_reg_wr *wr)
 {
@@ -2766,6 +2783,14 @@ int mlx4_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				size += sizeof (struct mlx4_wqe_fmr_seg) / 16;
 				break;
 
+			case IB_WR_REG_MR:
+				ctrl->srcrb_flags |=
+					cpu_to_be32(MLX4_WQE_CTRL_STRONG_ORDER);
+				set_reg_seg(wqe, reg_wr(wr));
+				wqe  += sizeof(struct mlx4_wqe_fmr_seg);
+				size += sizeof(struct mlx4_wqe_fmr_seg) / 16;
+				break;
+
 			case IB_WR_BIND_MW:
 				ctrl->srcrb_flags |=
 					cpu_to_be32(MLX4_WQE_CTRL_STRONG_ORDER);
-- 
1.8.4.3

