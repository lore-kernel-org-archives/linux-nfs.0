Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42019 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757518AbbIXRhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:40 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 26/26] IB/core: Remove old fast registration API
Date: Thu, 24 Sep 2015 20:35:18 +0300
Message-Id: <1443116118-10730-27-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No callers and no providers left, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/core/verbs.c | 25 -------------------
 include/rdma/ib_verbs.h         | 54 -----------------------------------------
 2 files changed, 79 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index b84d168f6e21..e0368fcf5fdb 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1253,31 +1253,6 @@ struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
 }
 EXPORT_SYMBOL(ib_alloc_mr);
 
-struct ib_fast_reg_page_list *ib_alloc_fast_reg_page_list(struct ib_device *device,
-							  int max_page_list_len)
-{
-	struct ib_fast_reg_page_list *page_list;
-
-	if (!device->alloc_fast_reg_page_list)
-		return ERR_PTR(-ENOSYS);
-
-	page_list = device->alloc_fast_reg_page_list(device, max_page_list_len);
-
-	if (!IS_ERR(page_list)) {
-		page_list->device = device;
-		page_list->max_page_list_len = max_page_list_len;
-	}
-
-	return page_list;
-}
-EXPORT_SYMBOL(ib_alloc_fast_reg_page_list);
-
-void ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list)
-{
-	page_list->device->free_fast_reg_page_list(page_list);
-}
-EXPORT_SYMBOL(ib_free_fast_reg_page_list);
-
 /* Memory windows */
 
 struct ib_mw *ib_alloc_mw(struct ib_pd *pd, enum ib_mw_type type)
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index f9a3436702c8..c1b5bfa66b84 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -736,7 +736,6 @@ enum ib_wc_opcode {
 	IB_WC_BIND_MW,
 	IB_WC_LSO,
 	IB_WC_LOCAL_INV,
-	IB_WC_FAST_REG_MR,
 	IB_WC_REG_MR,
 	IB_WC_MASKED_COMP_SWAP,
 	IB_WC_MASKED_FETCH_ADD,
@@ -1029,7 +1028,6 @@ enum ib_wr_opcode {
 	IB_WR_SEND_WITH_INV,
 	IB_WR_RDMA_READ_WITH_INV,
 	IB_WR_LOCAL_INV,
-	IB_WR_FAST_REG_MR,
 	IB_WR_REG_MR,
 	IB_WR_MASKED_ATOMIC_CMP_AND_SWP,
 	IB_WR_MASKED_ATOMIC_FETCH_AND_ADD,
@@ -1068,12 +1066,6 @@ struct ib_sge {
 	u32	lkey;
 };
 
-struct ib_fast_reg_page_list {
-	struct ib_device       *device;
-	u64		       *page_list;
-	unsigned int		max_page_list_len;
-};
-
 /**
  * struct ib_mw_bind_info - Parameters for a memory window bind operation.
  * @mr: A memory region to bind the memory window to.
@@ -1147,22 +1139,6 @@ static inline struct ib_ud_wr *ud_wr(struct ib_send_wr *wr)
 	return container_of(wr, struct ib_ud_wr, wr);
 }
 
-struct ib_fast_reg_wr {
-	struct ib_send_wr	wr;
-	u64			iova_start;
-	struct ib_fast_reg_page_list *page_list;
-	unsigned int		page_shift;
-	unsigned int		page_list_len;
-	u32			length;
-	int			access_flags;
-	u32			rkey;
-};
-
-static inline struct ib_fast_reg_wr *fast_reg_wr(struct ib_send_wr *wr)
-{
-	return container_of(wr, struct ib_fast_reg_wr, wr);
-}
-
 struct ib_reg_wr {
 	struct ib_send_wr	wr;
 	struct ib_mr		*mr;
@@ -1777,9 +1753,6 @@ struct ib_device {
 	int                        (*map_mr_sg)(struct ib_mr *mr,
 						struct scatterlist *sg,
 						unsigned int sg_nents);
-	struct ib_fast_reg_page_list * (*alloc_fast_reg_page_list)(struct ib_device *device,
-								   int page_list_len);
-	void			   (*free_fast_reg_page_list)(struct ib_fast_reg_page_list *page_list);
 	int                        (*rereg_phys_mr)(struct ib_mr *mr,
 						    int mr_rereg_mask,
 						    struct ib_pd *pd,
@@ -2888,33 +2861,6 @@ struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
 			  u32 max_num_sg);
 
 /**
- * ib_alloc_fast_reg_page_list - Allocates a page list array
- * @device - ib device pointer.
- * @page_list_len - size of the page list array to be allocated.
- *
- * This allocates and returns a struct ib_fast_reg_page_list * and a
- * page_list array that is at least page_list_len in size.  The actual
- * size is returned in max_page_list_len.  The caller is responsible
- * for initializing the contents of the page_list array before posting
- * a send work request with the IB_WC_FAST_REG_MR opcode.
- *
- * The page_list array entries must be translated using one of the
- * ib_dma_*() functions just like the addresses passed to
- * ib_map_phys_fmr().  Once the ib_post_send() is issued, the struct
- * ib_fast_reg_page_list must not be modified by the caller until the
- * IB_WC_FAST_REG_MR work request completes.
- */
-struct ib_fast_reg_page_list *ib_alloc_fast_reg_page_list(
-				struct ib_device *device, int page_list_len);
-
-/**
- * ib_free_fast_reg_page_list - Deallocates a previously allocated
- *   page list array.
- * @page_list - struct ib_fast_reg_page_list pointer to be deallocated.
- */
-void ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
-
-/**
  * ib_update_fast_reg_key - updates the key portion of the fast_reg MR
  *   R_Key and L_Key.
  * @mr - struct ib_mr pointer to be updated.
-- 
1.8.4.3

