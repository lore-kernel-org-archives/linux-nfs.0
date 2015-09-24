Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41939 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757409AbbIXRgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:46 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 06/26] RDMA/cxgb3: Support the new memory registration API
Date: Thu, 24 Sep 2015 20:34:58 +0300
Message-Id: <1443116118-10730-7-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in iwch_mr and populate it when
iwch_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by duplicating build_fastreg just take the needed information
from different places:
- page_size, iova, length (ib_mr)
- page array (iwch_mr)
- key, access flags (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/cxgb3/iwch_provider.c | 33 ++++++++++++++++++++
 drivers/infiniband/hw/cxgb3/iwch_provider.h |  2 ++
 drivers/infiniband/hw/cxgb3/iwch_qp.c       | 48 +++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 93308c45f298..ee3d5ca7de6c 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -463,6 +463,7 @@ static int iwch_dereg_mr(struct ib_mr *ib_mr)
 		return -EINVAL;
 
 	mhp = to_iwch_mr(ib_mr);
+	kfree(mhp->pages);
 	rhp = mhp->rhp;
 	mmid = mhp->attr.stag >> 8;
 	cxio_dereg_mem(&rhp->rdev, mhp->attr.stag, mhp->attr.pbl_size,
@@ -821,6 +822,12 @@ static struct ib_mr *iwch_alloc_mr(struct ib_pd *pd,
 	if (!mhp)
 		goto err;
 
+	mhp->pages = kcalloc(max_num_sg, sizeof(u64), GFP_KERNEL);
+	if (!mhp->pages) {
+		ret = -ENOMEM;
+		goto pl_err;
+	}
+
 	mhp->rhp = rhp;
 	ret = iwch_alloc_pbl(mhp, max_num_sg);
 	if (ret)
@@ -847,11 +854,36 @@ err3:
 err2:
 	iwch_free_pbl(mhp);
 err1:
+	kfree(mhp->pages);
+pl_err:
 	kfree(mhp);
 err:
 	return ERR_PTR(ret);
 }
 
+static int iwch_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct iwch_mr *mhp = to_iwch_mr(ibmr);
+
+	if (unlikely(mhp->npages == mhp->attr.pbl_size))
+		return -ENOMEM;
+
+	mhp->pages[mhp->npages++] = addr;
+
+	return 0;
+}
+
+static int iwch_map_mr_sg(struct ib_mr *ibmr,
+			  struct scatterlist *sg,
+			  unsigned int sg_nents)
+{
+	struct iwch_mr *mhp = to_iwch_mr(ibmr);
+
+	mhp->npages = 0;
+
+	return ib_sg_to_pages(ibmr, sg, sg_nents, iwch_set_page);
+}
+
 static struct ib_fast_reg_page_list *iwch_alloc_fastreg_pbl(
 					struct ib_device *device,
 					int page_list_len)
@@ -1450,6 +1482,7 @@ int iwch_register_device(struct iwch_dev *dev)
 	dev->ibdev.bind_mw = iwch_bind_mw;
 	dev->ibdev.dealloc_mw = iwch_dealloc_mw;
 	dev->ibdev.alloc_mr = iwch_alloc_mr;
+	dev->ibdev.map_mr_sg = iwch_map_mr_sg;
 	dev->ibdev.alloc_fast_reg_page_list = iwch_alloc_fastreg_pbl;
 	dev->ibdev.free_fast_reg_page_list = iwch_free_fastreg_pbl;
 	dev->ibdev.attach_mcast = iwch_multicast_attach;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.h b/drivers/infiniband/hw/cxgb3/iwch_provider.h
index 87c14b0c5ac0..2ac85b86a680 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.h
@@ -77,6 +77,8 @@ struct iwch_mr {
 	struct iwch_dev *rhp;
 	u64 kva;
 	struct tpt_attributes attr;
+	u64 *pages;
+	u32 npages;
 };
 
 typedef struct iwch_mw iwch_mw_handle;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index bac0508fedd9..a09ea538e990 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -146,6 +146,49 @@ static int build_rdma_read(union t3_wr *wqe, struct ib_send_wr *wr,
 	return 0;
 }
 
+static int build_memreg(union t3_wr *wqe, struct ib_reg_wr *wr,
+			  u8 *flit_cnt, int *wr_cnt, struct t3_wq *wq)
+{
+	struct iwch_mr *mhp = to_iwch_mr(wr->mr);
+	int i;
+	__be64 *p;
+
+	if (mhp->npages > T3_MAX_FASTREG_DEPTH)
+		return -EINVAL;
+	*wr_cnt = 1;
+	wqe->fastreg.stag = cpu_to_be32(wr->key);
+	wqe->fastreg.len = cpu_to_be32(mhp->ibmr.length);
+	wqe->fastreg.va_base_hi = cpu_to_be32(mhp->ibmr.iova >> 32);
+	wqe->fastreg.va_base_lo_fbo =
+				cpu_to_be32(mhp->ibmr.iova & 0xffffffff);
+	wqe->fastreg.page_type_perms = cpu_to_be32(
+		V_FR_PAGE_COUNT(mhp->npages) |
+		V_FR_PAGE_SIZE(ilog2(wr->mr->page_size) - 12) |
+		V_FR_TYPE(TPT_VATO) |
+		V_FR_PERMS(iwch_ib_to_tpt_access(wr->access)));
+	p = &wqe->fastreg.pbl_addrs[0];
+	for (i = 0; i < mhp->npages; i++, p++) {
+
+		/* If we need a 2nd WR, then set it up */
+		if (i == T3_MAX_FASTREG_FRAG) {
+			*wr_cnt = 2;
+			wqe = (union t3_wr *)(wq->queue +
+				Q_PTR2IDX((wq->wptr+1), wq->size_log2));
+			build_fw_riwrh((void *)wqe, T3_WR_FASTREG, 0,
+			       Q_GENBIT(wq->wptr + 1, wq->size_log2),
+			       0, 1 + mhp->npages - T3_MAX_FASTREG_FRAG,
+			       T3_EOP);
+
+			p = &wqe->pbl_frag.pbl_addrs[0];
+		}
+		*p = cpu_to_be64((u64)mhp->pages[i]);
+	}
+	*flit_cnt = 5 + mhp->npages;
+	if (*flit_cnt > 15)
+		*flit_cnt = 15;
+	return 0;
+}
+
 static int build_fastreg(union t3_wr *wqe, struct ib_send_wr *send_wr,
 				u8 *flit_cnt, int *wr_cnt, struct t3_wq *wq)
 {
@@ -419,6 +462,11 @@ int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 			err = build_fastreg(wqe, wr, &t3_wr_flit_cnt,
 						 &wr_cnt, &qhp->wq);
 			break;
+		case IB_WR_REG_MR:
+			t3_wr_opcode = T3_WR_FASTREG;
+			err = build_memreg(wqe, reg_wr(wr), &t3_wr_flit_cnt,
+					   &wr_cnt, &qhp->wq);
+			break;
 		case IB_WR_LOCAL_INV:
 			if (wr->send_flags & IB_SEND_FENCE)
 				t3_wr_flags |= T3_LOCAL_FENCE_FLAG;
-- 
1.8.4.3

