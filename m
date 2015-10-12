Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35525 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751986AbbJLPax (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 11:30:53 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 24/26] IB/qib: Remove old FRWR API
Date: Mon, 12 Oct 2015 18:29:37 +0300
Message-Id: <1444663779-1522-25-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
References: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/qib/qib_keys.c  | 56 -----------------------------------
 drivers/infiniband/hw/qib/qib_mr.c    | 32 +-------------------
 drivers/infiniband/hw/qib/qib_verbs.c |  8 -----
 drivers/infiniband/hw/qib/qib_verbs.h |  7 -----
 4 files changed, 1 insertion(+), 102 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_keys.c b/drivers/infiniband/hw/qib/qib_keys.c
index 95b8b9110fc6..d725c565518d 100644
--- a/drivers/infiniband/hw/qib/qib_keys.c
+++ b/drivers/infiniband/hw/qib/qib_keys.c
@@ -336,62 +336,6 @@ bail:
 }
 
 /*
- * Initialize the memory region specified by the work reqeust.
- */
-int qib_fast_reg_mr(struct qib_qp *qp, struct ib_send_wr *send_wr)
-{
-	struct ib_fast_reg_wr *wr = fast_reg_wr(send_wr);
-	struct qib_lkey_table *rkt = &to_idev(qp->ibqp.device)->lk_table;
-	struct qib_pd *pd = to_ipd(qp->ibqp.pd);
-	struct qib_mregion *mr;
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
-		rkt->table[(rkey >> (32 - ib_qib_lkey_table_size))],
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
-		if (++n == QIB_SEGSZ) {
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
-
-/*
  * Initialize the memory region specified by the work request.
  */
 int qib_reg_mr(struct qib_qp *qp, struct ib_reg_wr *wr)
diff --git a/drivers/infiniband/hw/qib/qib_mr.c b/drivers/infiniband/hw/qib/qib_mr.c
index 0fa4b0de8074..73f78c0f9522 100644
--- a/drivers/infiniband/hw/qib/qib_mr.c
+++ b/drivers/infiniband/hw/qib/qib_mr.c
@@ -324,7 +324,7 @@ out:
 
 /*
  * Allocate a memory region usable with the
- * IB_WR_FAST_REG_MR send work request.
+ * IB_WR_REG_MR send work request.
  *
  * Return the memory region on success, otherwise return an errno.
  */
@@ -375,36 +375,6 @@ int qib_map_mr_sg(struct ib_mr *ibmr,
 	return ib_sg_to_pages(ibmr, sg, sg_nents, qib_set_page);
 }
 
-struct ib_fast_reg_page_list *
-qib_alloc_fast_reg_page_list(struct ib_device *ibdev, int page_list_len)
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
-void qib_free_fast_reg_page_list(struct ib_fast_reg_page_list *pl)
-{
-	kfree(pl->page_list);
-	kfree(pl);
-}
-
 /**
  * qib_alloc_fmr - allocate a fast memory region
  * @pd: the protection domain for this memory region
diff --git a/drivers/infiniband/hw/qib/qib_verbs.c b/drivers/infiniband/hw/qib/qib_verbs.c
index a1e53d7b662b..de6cb6fcda8d 100644
--- a/drivers/infiniband/hw/qib/qib_verbs.c
+++ b/drivers/infiniband/hw/qib/qib_verbs.c
@@ -365,9 +365,6 @@ static int qib_post_one_send(struct qib_qp *qp, struct ib_send_wr *wr,
 	if (wr->opcode == IB_WR_REG_MR) {
 		if (qib_reg_mr(qp, reg_wr(wr)))
 			goto bail_inval;
-	} else if (wr->opcode == IB_WR_FAST_REG_MR) {
-		if (qib_fast_reg_mr(qp, wr))
-			goto bail_inval;
 	} else if (qp->ibqp.qp_type == IB_QPT_UC) {
 		if ((unsigned) wr->opcode >= IB_WR_RDMA_READ)
 			goto bail_inval;
@@ -407,9 +404,6 @@ static int qib_post_one_send(struct qib_qp *qp, struct ib_send_wr *wr,
 	else if (wr->opcode == IB_WR_REG_MR)
 		memcpy(&wqe->reg_wr, reg_wr(wr),
 			sizeof(wqe->reg_wr));
-	else if (wr->opcode == IB_WR_FAST_REG_MR)
-		memcpy(&wqe->fast_reg_wr, fast_reg_wr(wr),
-			sizeof(wqe->fast_reg_wr));
 	else if (wr->opcode == IB_WR_RDMA_WRITE_WITH_IMM ||
 		 wr->opcode == IB_WR_RDMA_WRITE ||
 		 wr->opcode == IB_WR_RDMA_READ)
@@ -2267,8 +2261,6 @@ int qib_register_ib_device(struct qib_devdata *dd)
 	ibdev->dereg_mr = qib_dereg_mr;
 	ibdev->alloc_mr = qib_alloc_mr;
 	ibdev->map_mr_sg = qib_map_mr_sg;
-	ibdev->alloc_fast_reg_page_list = qib_alloc_fast_reg_page_list;
-	ibdev->free_fast_reg_page_list = qib_free_fast_reg_page_list;
 	ibdev->alloc_fmr = qib_alloc_fmr;
 	ibdev->map_phys_fmr = qib_map_phys_fmr;
 	ibdev->unmap_fmr = qib_unmap_fmr;
diff --git a/drivers/infiniband/hw/qib/qib_verbs.h b/drivers/infiniband/hw/qib/qib_verbs.h
index dbc81c5761e3..bb11fe56ac6e 100644
--- a/drivers/infiniband/hw/qib/qib_verbs.h
+++ b/drivers/infiniband/hw/qib/qib_verbs.h
@@ -344,7 +344,6 @@ struct qib_swqe {
 		struct ib_send_wr wr;   /* don't use wr.sg_list */
 		struct ib_ud_wr ud_wr;
 		struct ib_reg_wr reg_wr;
-		struct ib_fast_reg_wr fast_reg_wr;
 		struct ib_rdma_wr rdma_wr;
 		struct ib_atomic_wr atomic_wr;
 	};
@@ -1051,12 +1050,6 @@ int qib_map_mr_sg(struct ib_mr *ibmr,
 		  struct scatterlist *sg,
 		  unsigned int sg_nents);
 
-struct ib_fast_reg_page_list *qib_alloc_fast_reg_page_list(
-				struct ib_device *ibdev, int page_list_len);
-
-void qib_free_fast_reg_page_list(struct ib_fast_reg_page_list *pl);
-
-int qib_fast_reg_mr(struct qib_qp *qp, struct ib_send_wr *wr);
 int qib_reg_mr(struct qib_qp *qp, struct ib_reg_wr *wr);
 
 struct ib_fmr *qib_alloc_fmr(struct ib_pd *pd, int mr_access_flags,
-- 
1.8.4.3

