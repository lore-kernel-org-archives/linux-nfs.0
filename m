Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49591 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753446AbbIQJn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 05:43:59 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v1 24/24] IB/core: Remove old fast registration API
Date: Thu, 17 Sep 2015 12:42:27 +0300
Message-Id: <1442482947-27785-25-git-send-email-sagig@mellanox.com>
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No callers and no providers left, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/core/verbs.c | 25 --------------------
 include/rdma/ib_verbs.h         | 52 -----------------------------------------
 2 files changed, 77 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index d99f57f1f737..bbbfd597f060 100644
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
index 97c73359ade8..ed3f181407ff 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1068,12 +1068,6 @@ struct ib_sge {
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
@@ -1147,22 +1141,6 @@ static inline struct ib_ud_wr *ud_wr(struct ib_send_wr *wr)
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
@@ -1777,9 +1755,6 @@ struct ib_device {
 	int                        (*map_mr_sg)(struct ib_mr *mr,
 						struct scatterlist *sg,
 						unsigned int sg_nents);
-	struct ib_fast_reg_page_list * (*alloc_fast_reg_page_list)(struct ib_device *device,
-								   int page_list_len);
-	void			   (*free_fast_reg_page_list)(struct ib_fast_reg_page_list *page_list);
 	int                        (*rereg_phys_mr)(struct ib_mr *mr,
 						    int mr_rereg_mask,
 						    struct ib_pd *pd,
@@ -2888,33 +2863,6 @@ struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
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

