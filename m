Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42041 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757518AbbIXRhy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:54 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 25/26] IB/hfi1: Remove Old fast registraion API support
Date: Thu, 24 Sep 2015 20:35:17 +0300
Message-Id: <1443116118-10730-26-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It wasn't supported before as well (post_send
returned -EINVAL for IB_WR_FAST_REG_MR). Perhaps
the new API adoption will be joint for all IB SW
implementations.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/staging/hfi1/keys.c  | 55 --------------------------------------------
 drivers/staging/hfi1/mr.c    | 32 +-------------------------
 drivers/staging/hfi1/verbs.c |  9 +-------
 drivers/staging/hfi1/verbs.h |  8 -------
 4 files changed, 2 insertions(+), 102 deletions(-)

diff --git a/drivers/staging/hfi1/keys.c b/drivers/staging/hfi1/keys.c
index 82c21b1c0263..cb4e6087dfdb 100644
--- a/drivers/staging/hfi1/keys.c
+++ b/drivers/staging/hfi1/keys.c
@@ -354,58 +354,3 @@ bail:
 	rcu_read_unlock();
 	return 0;
 }
-
-/*
- * Initialize the memory region specified by the work request.
- */
-int hfi1_fast_reg_mr(struct hfi1_qp *qp, struct ib_fast_reg_wr *wr)
-{
-	struct hfi1_lkey_table *rkt = &to_idev(qp->ibqp.device)->lk_table;
-	struct hfi1_pd *pd = to_ipd(qp->ibqp.pd);
-	struct hfi1_mregion *mr;
-	u32 rkey = wr->rkey;
-	unsigned i, n, m;
-	int ret = -EINVAL;
-	unsigned long flags;
-	u64 *page_list;
-	size_t ps;
-
-	spin_lock_irqsave(&rkt->lock, flags);
-	if (pd->user || rkey == 0)
-		goto bail;
-
-	mr = rcu_dereference_protected(
-		rkt->table[(rkey >> (32 - hfi1_lkey_table_size))],
-		lockdep_is_held(&rkt->lock));
-	if (unlikely(mr == NULL || qp->ibqp.pd != mr->pd))
-		goto bail;
-
-	if (wr->page_list_len > mr->max_segs)
-		goto bail;
-
-	ps = 1UL << wr->page_shift;
-	if (wr->length > ps * wr->page_list_len)
-		goto bail;
-
-	mr->user_base = wr->iova_start;
-	mr->iova = wr->iova_start;
-	mr->lkey = rkey;
-	mr->length = wr->length;
-	mr->access_flags = wr->access_flags;
-	page_list = wr->page_list->page_list;
-	m = 0;
-	n = 0;
-	for (i = 0; i < wr->page_list_len; i++) {
-		mr->map[m]->segs[n].vaddr = (void *) page_list[i];
-		mr->map[m]->segs[n].length = ps;
-		if (++n == HFI1_SEGSZ) {
-			m++;
-			n = 0;
-		}
-	}
-
-	ret = 0;
-bail:
-	spin_unlock_irqrestore(&rkt->lock, flags);
-	return ret;
-}
diff --git a/drivers/staging/hfi1/mr.c b/drivers/staging/hfi1/mr.c
index bd64e4f986f9..3f5623add3df 100644
--- a/drivers/staging/hfi1/mr.c
+++ b/drivers/staging/hfi1/mr.c
@@ -344,7 +344,7 @@ out:
 
 /*
  * Allocate a memory region usable with the
- * IB_WR_FAST_REG_MR send work request.
+ * IB_WR_REG_MR send work request.
  *
  * Return the memory region on success, otherwise return an errno.
  */
@@ -364,36 +364,6 @@ struct ib_mr *hfi1_alloc_mr(struct ib_pd *pd,
 	return &mr->ibmr;
 }
 
-struct ib_fast_reg_page_list *
-hfi1_alloc_fast_reg_page_list(struct ib_device *ibdev, int page_list_len)
-{
-	unsigned size = page_list_len * sizeof(u64);
-	struct ib_fast_reg_page_list *pl;
-
-	if (size > PAGE_SIZE)
-		return ERR_PTR(-EINVAL);
-
-	pl = kzalloc(sizeof(*pl), GFP_KERNEL);
-	if (!pl)
-		return ERR_PTR(-ENOMEM);
-
-	pl->page_list = kzalloc(size, GFP_KERNEL);
-	if (!pl->page_list)
-		goto err_free;
-
-	return pl;
-
-err_free:
-	kfree(pl);
-	return ERR_PTR(-ENOMEM);
-}
-
-void hfi1_free_fast_reg_page_list(struct ib_fast_reg_page_list *pl)
-{
-	kfree(pl->page_list);
-	kfree(pl);
-}
-
 /**
  * hfi1_alloc_fmr - allocate a fast memory region
  * @pd: the protection domain for this memory region
diff --git a/drivers/staging/hfi1/verbs.c b/drivers/staging/hfi1/verbs.c
index 542ad803bfce..a6c9bf88a4c4 100644
--- a/drivers/staging/hfi1/verbs.c
+++ b/drivers/staging/hfi1/verbs.c
@@ -380,9 +380,7 @@ static int post_one_send(struct hfi1_qp *qp, struct ib_send_wr *wr)
 	 * undefined operations.
 	 * Make sure buffer is large enough to hold the result for atomics.
 	 */
-	if (wr->opcode == IB_WR_FAST_REG_MR) {
-		return -EINVAL;
-	} else if (qp->ibqp.qp_type == IB_QPT_UC) {
+	if (qp->ibqp.qp_type == IB_QPT_UC) {
 		if ((unsigned) wr->opcode >= IB_WR_RDMA_READ)
 			return -EINVAL;
 	} else if (qp->ibqp.qp_type != IB_QPT_RC) {
@@ -417,9 +415,6 @@ static int post_one_send(struct hfi1_qp *qp, struct ib_send_wr *wr)
 	if (qp->ibqp.qp_type != IB_QPT_UC &&
 	    qp->ibqp.qp_type != IB_QPT_RC)
 		memcpy(&wqe->ud_wr, ud_wr(wr), sizeof(wqe->ud_wr));
-	else if (wr->opcode == IB_WR_FAST_REG_MR)
-		memcpy(&wqe->fast_reg_wr, fast_reg_wr(wr),
-			sizeof(wqe->fast_reg_wr));
 	else if (wr->opcode == IB_WR_RDMA_WRITE_WITH_IMM ||
 		 wr->opcode == IB_WR_RDMA_WRITE ||
 		 wr->opcode == IB_WR_RDMA_READ)
@@ -2063,8 +2058,6 @@ int hfi1_register_ib_device(struct hfi1_devdata *dd)
 	ibdev->reg_user_mr = hfi1_reg_user_mr;
 	ibdev->dereg_mr = hfi1_dereg_mr;
 	ibdev->alloc_mr = hfi1_alloc_mr;
-	ibdev->alloc_fast_reg_page_list = hfi1_alloc_fast_reg_page_list;
-	ibdev->free_fast_reg_page_list = hfi1_free_fast_reg_page_list;
 	ibdev->alloc_fmr = hfi1_alloc_fmr;
 	ibdev->map_phys_fmr = hfi1_map_phys_fmr;
 	ibdev->unmap_fmr = hfi1_unmap_fmr;
diff --git a/drivers/staging/hfi1/verbs.h b/drivers/staging/hfi1/verbs.h
index cf5a3c956284..159ec08bfcd8 100644
--- a/drivers/staging/hfi1/verbs.h
+++ b/drivers/staging/hfi1/verbs.h
@@ -353,7 +353,6 @@ struct hfi1_swqe {
 		struct ib_rdma_wr rdma_wr;
 		struct ib_atomic_wr atomic_wr;
 		struct ib_ud_wr ud_wr;
-		struct ib_fast_reg_wr fast_reg_wr;
 	};
 	u32 psn;                /* first packet sequence number */
 	u32 lpsn;               /* last packet sequence number */
@@ -1026,13 +1025,6 @@ struct ib_mr *hfi1_alloc_mr(struct ib_pd *pd,
 			    enum ib_mr_type mr_type,
 			    u32 max_entries);
 
-struct ib_fast_reg_page_list *hfi1_alloc_fast_reg_page_list(
-				struct ib_device *ibdev, int page_list_len);
-
-void hfi1_free_fast_reg_page_list(struct ib_fast_reg_page_list *pl);
-
-int hfi1_fast_reg_mr(struct hfi1_qp *qp, struct ib_fast_reg_wr *wr);
-
 struct ib_fmr *hfi1_alloc_fmr(struct ib_pd *pd, int mr_access_flags,
 			      struct ib_fmr_attr *fmr_attr);
 
-- 
1.8.4.3

