Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41886 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757187AbbIXRgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:09 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 21/26] RDMA/cxgb3: Remove old FRWR API
Date: Thu, 24 Sep 2015 20:34:49 +0300
Message-Id: <1443116094-7969-22-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/cxgb3/iwch_cq.c       |  2 +-
 drivers/infiniband/hw/cxgb3/iwch_provider.c | 24 ---------------
 drivers/infiniband/hw/cxgb3/iwch_qp.c       | 47 -----------------------------
 3 files changed, 1 insertion(+), 72 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cq.c b/drivers/infiniband/hw/cxgb3/iwch_cq.c
index cf5474ae68ff..cfe404925a39 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cq.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cq.c
@@ -123,7 +123,7 @@ static int iwch_poll_cq_one(struct iwch_dev *rhp, struct iwch_cq *chp,
 			wc->opcode = IB_WC_LOCAL_INV;
 			break;
 		case T3_FAST_REGISTER:
-			wc->opcode = IB_WC_FAST_REG_MR;
+			wc->opcode = IB_WC_REG_MR;
 			break;
 		default:
 			printk(KERN_ERR MOD "Unexpected opcode %d "
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index ee3d5ca7de6c..99ae2ab14b9e 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -884,28 +884,6 @@ static int iwch_map_mr_sg(struct ib_mr *ibmr,
 	return ib_sg_to_pages(ibmr, sg, sg_nents, iwch_set_page);
 }
 
-static struct ib_fast_reg_page_list *iwch_alloc_fastreg_pbl(
-					struct ib_device *device,
-					int page_list_len)
-{
-	struct ib_fast_reg_page_list *page_list;
-
-	page_list = kmalloc(sizeof *page_list + page_list_len * sizeof(u64),
-			    GFP_KERNEL);
-	if (!page_list)
-		return ERR_PTR(-ENOMEM);
-
-	page_list->page_list = (u64 *)(page_list + 1);
-	page_list->max_page_list_len = page_list_len;
-
-	return page_list;
-}
-
-static void iwch_free_fastreg_pbl(struct ib_fast_reg_page_list *page_list)
-{
-	kfree(page_list);
-}
-
 static int iwch_destroy_qp(struct ib_qp *ib_qp)
 {
 	struct iwch_dev *rhp;
@@ -1483,8 +1461,6 @@ int iwch_register_device(struct iwch_dev *dev)
 	dev->ibdev.dealloc_mw = iwch_dealloc_mw;
 	dev->ibdev.alloc_mr = iwch_alloc_mr;
 	dev->ibdev.map_mr_sg = iwch_map_mr_sg;
-	dev->ibdev.alloc_fast_reg_page_list = iwch_alloc_fastreg_pbl;
-	dev->ibdev.free_fast_reg_page_list = iwch_free_fastreg_pbl;
 	dev->ibdev.attach_mcast = iwch_multicast_attach;
 	dev->ibdev.detach_mcast = iwch_multicast_detach;
 	dev->ibdev.process_mad = iwch_process_mad;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index a09ea538e990..d0548fc6395e 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -189,48 +189,6 @@ static int build_memreg(union t3_wr *wqe, struct ib_reg_wr *wr,
 	return 0;
 }
 
-static int build_fastreg(union t3_wr *wqe, struct ib_send_wr *send_wr,
-				u8 *flit_cnt, int *wr_cnt, struct t3_wq *wq)
-{
-	struct ib_fast_reg_wr *wr = fast_reg_wr(send_wr);
-	int i;
-	__be64 *p;
-
-	if (wr->page_list_len > T3_MAX_FASTREG_DEPTH)
-		return -EINVAL;
-	*wr_cnt = 1;
-	wqe->fastreg.stag = cpu_to_be32(wr->rkey);
-	wqe->fastreg.len = cpu_to_be32(wr->length);
-	wqe->fastreg.va_base_hi = cpu_to_be32(wr->iova_start >> 32);
-	wqe->fastreg.va_base_lo_fbo = cpu_to_be32(wr->iova_start & 0xffffffff);
-	wqe->fastreg.page_type_perms = cpu_to_be32(
-		V_FR_PAGE_COUNT(wr->page_list_len) |
-		V_FR_PAGE_SIZE(wr->page_shift-12) |
-		V_FR_TYPE(TPT_VATO) |
-		V_FR_PERMS(iwch_ib_to_tpt_access(wr->access_flags)));
-	p = &wqe->fastreg.pbl_addrs[0];
-	for (i = 0; i < wr->page_list_len; i++, p++) {
-
-		/* If we need a 2nd WR, then set it up */
-		if (i == T3_MAX_FASTREG_FRAG) {
-			*wr_cnt = 2;
-			wqe = (union t3_wr *)(wq->queue +
-				Q_PTR2IDX((wq->wptr+1), wq->size_log2));
-			build_fw_riwrh((void *)wqe, T3_WR_FASTREG, 0,
-			       Q_GENBIT(wq->wptr + 1, wq->size_log2),
-			       0, 1 + wr->page_list_len - T3_MAX_FASTREG_FRAG,
-			       T3_EOP);
-
-			p = &wqe->pbl_frag.pbl_addrs[0];
-		}
-		*p = cpu_to_be64((u64)wr->page_list->page_list[i]);
-	}
-	*flit_cnt = 5 + wr->page_list_len;
-	if (*flit_cnt > 15)
-		*flit_cnt = 15;
-	return 0;
-}
-
 static int build_inv_stag(union t3_wr *wqe, struct ib_send_wr *wr,
 				u8 *flit_cnt)
 {
@@ -457,11 +415,6 @@ int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 			if (!qhp->wq.oldest_read)
 				qhp->wq.oldest_read = sqp;
 			break;
-		case IB_WR_FAST_REG_MR:
-			t3_wr_opcode = T3_WR_FASTREG;
-			err = build_fastreg(wqe, wr, &t3_wr_flit_cnt,
-						 &wr_cnt, &qhp->wq);
-			break;
 		case IB_WR_REG_MR:
 			t3_wr_opcode = T3_WR_FASTREG;
 			err = build_memreg(wqe, reg_wr(wr), &t3_wr_flit_cnt,
-- 
1.8.4.3

