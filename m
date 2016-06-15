Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36250 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225AbcFODP1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:15:27 -0400
Subject: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:15:25 -0400
Message-ID: <20160615031525.14794.69066.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sagi Grimberg <sagi@grimberg.me>

kmalloc doesn't guarantee the returned memory is all on one page.

Fixes: 1b2cd0fc673c ("IB/mlx4: Support the new memory ... ")
Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    1 -
 drivers/infiniband/hw/mlx4/mr.c      |   42 +++++-----------------------------
 2 files changed, 6 insertions(+), 37 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 6c5ac5d..4a8bbe4 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -139,7 +139,6 @@ struct mlx4_ib_mr {
 	u32			max_pages;
 	struct mlx4_mr		mmr;
 	struct ib_umem	       *umem;
-	void			*pages_alloc;
 };
 
 struct mlx4_ib_mw {
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 6312721..c4c2044 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -278,30 +278,13 @@ mlx4_alloc_priv_pages(struct ib_device *device,
 		      int max_pages)
 {
 	int size = max_pages * sizeof(u64);
-	int add_size;
-	int ret;
-
-	add_size = max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
 
-	mr->pages_alloc = kzalloc(size + add_size, GFP_KERNEL);
-	if (!mr->pages_alloc)
+	mr->pages = dma_alloc_coherent(device->dma_device, size,
+				       &mr->page_map, GFP_KERNEL);
+	if (!mr->pages)
 		return -ENOMEM;
 
-	mr->pages = PTR_ALIGN(mr->pages_alloc, MLX4_MR_PAGES_ALIGN);
-
-	mr->page_map = dma_map_single(device->dma_device, mr->pages,
-				      size, DMA_TO_DEVICE);
-
-	if (dma_mapping_error(device->dma_device, mr->page_map)) {
-		ret = -ENOMEM;
-		goto err;
-	}
-
 	return 0;
-err:
-	kfree(mr->pages_alloc);
-
-	return ret;
 }
 
 static void
@@ -311,9 +294,8 @@ mlx4_free_priv_pages(struct mlx4_ib_mr *mr)
 		struct ib_device *device = mr->ibmr.device;
 		int size = mr->max_pages * sizeof(u64);
 
-		dma_unmap_single(device->dma_device, mr->page_map,
-				 size, DMA_TO_DEVICE);
-		kfree(mr->pages_alloc);
+		dma_free_coherent(device->dma_device, size,
+				  mr->pages, mr->page_map);
 		mr->pages = NULL;
 	}
 }
@@ -532,19 +514,7 @@ int mlx4_ib_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg, int sg_nents,
 		      unsigned int *sg_offset)
 {
 	struct mlx4_ib_mr *mr = to_mmr(ibmr);
-	int rc;
 
 	mr->npages = 0;
-
-	ib_dma_sync_single_for_cpu(ibmr->device, mr->page_map,
-				   sizeof(u64) * mr->max_pages,
-				   DMA_TO_DEVICE);
-
-	rc = ib_sg_to_pages(ibmr, sg, sg_nents, sg_offset, mlx4_set_page);
-
-	ib_dma_sync_single_for_device(ibmr->device, mr->page_map,
-				      sizeof(u64) * mr->max_pages,
-				      DMA_TO_DEVICE);
-
-	return rc;
+	return ib_sg_to_pages(ibmr, sg, sg_nents, sg_offset, mlx4_set_page);
 }

