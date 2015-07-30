Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52683 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751301AbbG3HdS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:18 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 01/15] IB/core: Get rid of redundant verb ib_destroy_mr
Date: Thu, 30 Jul 2015 10:32:34 +0300
Message-Id: <1438241568-3685-2-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was added in a thought of uniting all mr allocation
and deallocation routines but the fact is we have a single
deallocation routine already, ib_dereg_mr.

And, move mlx5_ib_destroy_mr specific logic into mlx5_ib_dereg_mr
(includes only signature stuff for now).

And, fixup the only callers (iser/isert) accordingly.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/core/verbs.c          | 17 -------------
 drivers/infiniband/hw/mlx5/main.c        |  1 -
 drivers/infiniband/hw/mlx5/mlx5_ib.h     |  1 -
 drivers/infiniband/hw/mlx5/mr.c          | 43 ++++++++++----------------------
 drivers/infiniband/ulp/iser/iser_verbs.c |  2 +-
 drivers/infiniband/ulp/isert/ib_isert.c  |  2 +-
 include/rdma/ib_verbs.h                  | 10 --------
 7 files changed, 15 insertions(+), 61 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index bb561c8..003bb62 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1294,23 +1294,6 @@ struct ib_mr *ib_create_mr(struct ib_pd *pd,
 }
 EXPORT_SYMBOL(ib_create_mr);
 
-int ib_destroy_mr(struct ib_mr *mr)
-{
-	struct ib_pd *pd;
-	int ret;
-
-	if (atomic_read(&mr->usecnt))
-		return -EBUSY;
-
-	pd = mr->pd;
-	ret = mr->device->destroy_mr(mr);
-	if (!ret)
-		atomic_dec(&pd->usecnt);
-
-	return ret;
-}
-EXPORT_SYMBOL(ib_destroy_mr);
-
 struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
 {
 	struct ib_mr *mr;
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 5cfb0b1..46d1383 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1486,7 +1486,6 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.get_dma_mr		= mlx5_ib_get_dma_mr;
 	dev->ib_dev.reg_user_mr		= mlx5_ib_reg_user_mr;
 	dev->ib_dev.dereg_mr		= mlx5_ib_dereg_mr;
-	dev->ib_dev.destroy_mr		= mlx5_ib_destroy_mr;
 	dev->ib_dev.attach_mcast	= mlx5_ib_mcg_attach;
 	dev->ib_dev.detach_mcast	= mlx5_ib_mcg_detach;
 	dev->ib_dev.process_mad		= mlx5_ib_process_mad;
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 446d804..537f42e 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -572,7 +572,6 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index,
 		       int npages, int zap);
 int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
-int mlx5_ib_destroy_mr(struct ib_mr *ibmr);
 struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
 				struct ib_mr_init_attr *mr_init_attr);
 struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 4c92ca8..03cf74e 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1172,6 +1172,19 @@ static int clean_mr(struct mlx5_ib_mr *mr)
 	int umred = mr->umred;
 	int err;
 
+	if (mr->sig) {
+		if (mlx5_core_destroy_psv(dev->mdev,
+					  mr->sig->psv_memory.psv_idx))
+			mlx5_ib_warn(dev, "failed to destroy mem psv %d\n",
+				     mr->sig->psv_memory.psv_idx);
+		if (mlx5_core_destroy_psv(dev->mdev,
+					  mr->sig->psv_wire.psv_idx))
+			mlx5_ib_warn(dev, "failed to destroy wire psv %d\n",
+				     mr->sig->psv_wire.psv_idx);
+		kfree(mr->sig);
+		mr->sig = NULL;
+	}
+
 	if (!umred) {
 		err = destroy_mkey(dev, mr);
 		if (err) {
@@ -1319,36 +1332,6 @@ err_free:
 	return ERR_PTR(err);
 }
 
-int mlx5_ib_destroy_mr(struct ib_mr *ibmr)
-{
-	struct mlx5_ib_dev *dev = to_mdev(ibmr->device);
-	struct mlx5_ib_mr *mr = to_mmr(ibmr);
-	int err;
-
-	if (mr->sig) {
-		if (mlx5_core_destroy_psv(dev->mdev,
-					  mr->sig->psv_memory.psv_idx))
-			mlx5_ib_warn(dev, "failed to destroy mem psv %d\n",
-				     mr->sig->psv_memory.psv_idx);
-		if (mlx5_core_destroy_psv(dev->mdev,
-					  mr->sig->psv_wire.psv_idx))
-			mlx5_ib_warn(dev, "failed to destroy wire psv %d\n",
-				     mr->sig->psv_wire.psv_idx);
-		kfree(mr->sig);
-	}
-
-	err = destroy_mkey(dev, mr);
-	if (err) {
-		mlx5_ib_warn(dev, "failed to destroy mkey 0x%x (%d)\n",
-			     mr->mmr.key, err);
-		return err;
-	}
-
-	kfree(mr);
-
-	return err;
-}
-
 struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
 					int max_page_list_len)
 {
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 5226835..255321c 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -334,7 +334,7 @@ iser_free_pi_ctx(struct iser_pi_context *pi_ctx)
 {
 	ib_free_fast_reg_page_list(pi_ctx->prot_frpl);
 	ib_dereg_mr(pi_ctx->prot_mr);
-	ib_destroy_mr(pi_ctx->sig_mr);
+	ib_dereg_mr(pi_ctx->sig_mr);
 	kfree(pi_ctx);
 }
 
diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 00d75d9..559e6be 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -480,7 +480,7 @@ isert_conn_free_fastreg_pool(struct isert_conn *isert_conn)
 		if (fr_desc->pi_ctx) {
 			ib_free_fast_reg_page_list(fr_desc->pi_ctx->prot_frpl);
 			ib_dereg_mr(fr_desc->pi_ctx->prot_mr);
-			ib_destroy_mr(fr_desc->pi_ctx->sig_mr);
+			ib_dereg_mr(fr_desc->pi_ctx->sig_mr);
 			kfree(fr_desc->pi_ctx);
 		}
 		kfree(fr_desc);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index eaec308..a534ee5 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1670,7 +1670,6 @@ struct ib_device {
 	int                        (*query_mr)(struct ib_mr *mr,
 					       struct ib_mr_attr *mr_attr);
 	int                        (*dereg_mr)(struct ib_mr *mr);
-	int                        (*destroy_mr)(struct ib_mr *mr);
 	struct ib_mr *		   (*create_mr)(struct ib_pd *pd,
 						struct ib_mr_init_attr *mr_init_attr);
 	struct ib_mr *		   (*alloc_fast_reg_mr)(struct ib_pd *pd,
@@ -2827,15 +2826,6 @@ struct ib_mr *ib_create_mr(struct ib_pd *pd,
 			   struct ib_mr_init_attr *mr_init_attr);
 
 /**
- * ib_destroy_mr - Destroys a memory region that was created using
- *     ib_create_mr and removes it from HW translation tables.
- * @mr: The memory region to destroy.
- *
- * This function can fail, if the memory region has memory windows bound to it.
- */
-int ib_destroy_mr(struct ib_mr *mr);
-
-/**
  * ib_alloc_fast_reg_mr - Allocates memory region usable with the
  *   IB_WR_FAST_REG_MR send work request.
  * @pd: The protection domain associated with the region.
-- 
1.8.4.3

