Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49334 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753150AbbIQJnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 05:43:22 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v1 08/24] IB/qib: Support the new memory registration API
Date: Thu, 17 Sep 2015 12:42:11 +0300
Message-Id: <1442482947-27785-9-git-send-email-sagig@mellanox.com>
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in qib_mr and populate it when
qib_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by duplicating qib_fastreg_mr just take the needed information
from different places:
- page_size, iova, length (ib_mr)
- page array (qib_mr)
- key, access flags (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/hw/qib/qib_keys.c  | 56 +++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/qib/qib_mr.c    | 32 ++++++++++++++++++++
 drivers/infiniband/hw/qib/qib_verbs.c |  9 +++++-
 drivers/infiniband/hw/qib/qib_verbs.h |  8 +++++
 4 files changed, 104 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/qib/qib_keys.c b/drivers/infiniband/hw/qib/qib_keys.c
index eaf139a33b2e..a5057efc7faf 100644
--- a/drivers/infiniband/hw/qib/qib_keys.c
+++ b/drivers/infiniband/hw/qib/qib_keys.c
@@ -390,3 +390,59 @@ bail:
 	spin_unlock_irqrestore(&rkt->lock, flags);
 	return ret;
 }
+
+/*
+ * Initialize the memory region specified by the work reqeust.
+ */
+int qib_reg_mr(struct qib_qp *qp, struct ib_reg_wr *wr)
+{
+	struct qib_lkey_table *rkt = &to_idev(qp->ibqp.device)->lk_table;
+	struct qib_pd *pd = to_ipd(qp->ibqp.pd);
+	struct qib_mr *mr = to_imr(wr->mr);
+	struct qib_mregion *mrg;
+	u32 key = wr->key;
+	unsigned i, n, m;
+	int ret = -EINVAL;
+	unsigned long flags;
+	u64 *page_list;
+	size_t ps;
+
+	spin_lock_irqsave(&rkt->lock, flags);
+	if (pd->user || key == 0)
+		goto bail;
+
+	mrg = rcu_dereference_protected(
+		rkt->table[(key >> (32 - ib_qib_lkey_table_size))],
+		lockdep_is_held(&rkt->lock));
+	if (unlikely(mrg == NULL || qp->ibqp.pd != mrg->pd))
+		goto bail;
+
+	if (mr->npages > mrg->max_segs)
+		goto bail;
+
+	ps = mr->ibmr.page_size;
+	if (mr->ibmr.length > ps * mr->npages)
+		goto bail;
+
+	mrg->user_base = mr->ibmr.iova;
+	mrg->iova = mr->ibmr.iova;
+	mrg->lkey = key;
+	mrg->length = mr->ibmr.length;
+	mrg->access_flags = wr->access;
+	page_list = mr->pages;
+	m = 0;
+	n = 0;
+	for (i = 0; i < mr->npages; i++) {
+		mrg->map[m]->segs[n].vaddr = (void *) page_list[i];
+		mrg->map[m]->segs[n].length = ps;
+		if (++n == QIB_SEGSZ) {
+			m++;
+			n = 0;
+		}
+	}
+
+	ret = 0;
+bail:
+	spin_unlock_irqrestore(&rkt->lock, flags);
+	return ret;
+}
diff --git a/drivers/infiniband/hw/qib/qib_mr.c b/drivers/infiniband/hw/qib/qib_mr.c
index 19220dcb9a3b..0fa4b0de8074 100644
--- a/drivers/infiniband/hw/qib/qib_mr.c
+++ b/drivers/infiniband/hw/qib/qib_mr.c
@@ -303,6 +303,7 @@ int qib_dereg_mr(struct ib_mr *ibmr)
 	int ret = 0;
 	unsigned long timeout;
 
+	kfree(mr->pages);
 	qib_free_lkey(&mr->mr);
 
 	qib_put_mr(&mr->mr); /* will set completion if last */
@@ -340,7 +341,38 @@ struct ib_mr *qib_alloc_mr(struct ib_pd *pd,
 	if (IS_ERR(mr))
 		return (struct ib_mr *)mr;
 
+	mr->pages = kcalloc(max_num_sg, sizeof(u64), GFP_KERNEL);
+	if (!mr->pages)
+		goto err;
+
 	return &mr->ibmr;
+
+err:
+	qib_dereg_mr(&mr->ibmr);
+	return ERR_PTR(-ENOMEM);
+}
+
+static int qib_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct qib_mr *mr = to_imr(ibmr);
+
+	if (unlikely(mr->npages == mr->mr.max_segs))
+		return -ENOMEM;
+
+	mr->pages[mr->npages++] = addr;
+
+	return 0;
+}
+
+int qib_map_mr_sg(struct ib_mr *ibmr,
+		  struct scatterlist *sg,
+		  unsigned int sg_nents)
+{
+	struct qib_mr *mr = to_imr(ibmr);
+
+	mr->npages = 0;
+
+	return ib_sg_to_pages(ibmr, sg, sg_nents, qib_set_page);
 }
 
 struct ib_fast_reg_page_list *
diff --git a/drivers/infiniband/hw/qib/qib_verbs.c b/drivers/infiniband/hw/qib/qib_verbs.c
index a6b0b098ff30..a1e53d7b662b 100644
--- a/drivers/infiniband/hw/qib/qib_verbs.c
+++ b/drivers/infiniband/hw/qib/qib_verbs.c
@@ -362,7 +362,10 @@ static int qib_post_one_send(struct qib_qp *qp, struct ib_send_wr *wr,
 	 * undefined operations.
 	 * Make sure buffer is large enough to hold the result for atomics.
 	 */
-	if (wr->opcode == IB_WR_FAST_REG_MR) {
+	if (wr->opcode == IB_WR_REG_MR) {
+		if (qib_reg_mr(qp, reg_wr(wr)))
+			goto bail_inval;
+	} else if (wr->opcode == IB_WR_FAST_REG_MR) {
 		if (qib_fast_reg_mr(qp, wr))
 			goto bail_inval;
 	} else if (qp->ibqp.qp_type == IB_QPT_UC) {
@@ -401,6 +404,9 @@ static int qib_post_one_send(struct qib_qp *qp, struct ib_send_wr *wr,
 	if (qp->ibqp.qp_type != IB_QPT_UC &&
 	    qp->ibqp.qp_type != IB_QPT_RC)
 		memcpy(&wqe->ud_wr, ud_wr(wr), sizeof(wqe->ud_wr));
+	else if (wr->opcode == IB_WR_REG_MR)
+		memcpy(&wqe->reg_wr, reg_wr(wr),
+			sizeof(wqe->reg_wr));
 	else if (wr->opcode == IB_WR_FAST_REG_MR)
 		memcpy(&wqe->fast_reg_wr, fast_reg_wr(wr),
 			sizeof(wqe->fast_reg_wr));
@@ -2260,6 +2266,7 @@ int qib_register_ib_device(struct qib_devdata *dd)
 	ibdev->reg_user_mr = qib_reg_user_mr;
 	ibdev->dereg_mr = qib_dereg_mr;
 	ibdev->alloc_mr = qib_alloc_mr;
+	ibdev->map_mr_sg = qib_map_mr_sg;
 	ibdev->alloc_fast_reg_page_list = qib_alloc_fast_reg_page_list;
 	ibdev->free_fast_reg_page_list = qib_free_fast_reg_page_list;
 	ibdev->alloc_fmr = qib_alloc_fmr;
diff --git a/drivers/infiniband/hw/qib/qib_verbs.h b/drivers/infiniband/hw/qib/qib_verbs.h
index 8aa16851a5e6..dbc81c5761e3 100644
--- a/drivers/infiniband/hw/qib/qib_verbs.h
+++ b/drivers/infiniband/hw/qib/qib_verbs.h
@@ -330,6 +330,8 @@ struct qib_mr {
 	struct ib_mr ibmr;
 	struct ib_umem *umem;
 	struct qib_mregion mr;  /* must be last */
+	u64 *pages;
+	u32 npages;
 };
 
 /*
@@ -341,6 +343,7 @@ struct qib_swqe {
 	union {
 		struct ib_send_wr wr;   /* don't use wr.sg_list */
 		struct ib_ud_wr ud_wr;
+		struct ib_reg_wr reg_wr;
 		struct ib_fast_reg_wr fast_reg_wr;
 		struct ib_rdma_wr rdma_wr;
 		struct ib_atomic_wr atomic_wr;
@@ -1044,12 +1047,17 @@ struct ib_mr *qib_alloc_mr(struct ib_pd *pd,
 			   enum ib_mr_type mr_type,
 			   u32 max_entries);
 
+int qib_map_mr_sg(struct ib_mr *ibmr,
+		  struct scatterlist *sg,
+		  unsigned int sg_nents);
+
 struct ib_fast_reg_page_list *qib_alloc_fast_reg_page_list(
 				struct ib_device *ibdev, int page_list_len);
 
 void qib_free_fast_reg_page_list(struct ib_fast_reg_page_list *pl);
 
 int qib_fast_reg_mr(struct qib_qp *qp, struct ib_send_wr *wr);
+int qib_reg_mr(struct qib_qp *qp, struct ib_reg_wr *wr);
 
 struct ib_fmr *qib_alloc_fmr(struct ib_pd *pd, int mr_access_flags,
 			     struct ib_fmr_attr *fmr_attr);
-- 
1.8.4.3

