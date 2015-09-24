Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42009 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757512AbbIXRhh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:37 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 22/26] iw_cxgb4: Remove old FRWR API
Date: Thu, 24 Sep 2015 20:35:14 +0300
Message-Id: <1443116118-10730-23-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/cxgb4/cq.c       |  2 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h | 18 --------
 drivers/infiniband/hw/cxgb4/mem.c      | 45 --------------------
 drivers/infiniband/hw/cxgb4/provider.c |  2 -
 drivers/infiniband/hw/cxgb4/qp.c       | 77 ----------------------------------
 5 files changed, 1 insertion(+), 143 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index c7aab48f07cd..4f8c3ff3da5e 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -752,7 +752,7 @@ static int c4iw_poll_cq_one(struct c4iw_cq *chp, struct ib_wc *wc)
 			wc->opcode = IB_WC_LOCAL_INV;
 			break;
 		case FW_RI_FAST_REGISTER:
-			wc->opcode = IB_WC_FAST_REG_MR;
+			wc->opcode = IB_WC_REG_MR;
 			break;
 		default:
 			printk(KERN_ERR MOD "Unexpected opcode %d "
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 032f90aa8ac9..699c52b875b1 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -409,20 +409,6 @@ static inline struct c4iw_mw *to_c4iw_mw(struct ib_mw *ibmw)
 	return container_of(ibmw, struct c4iw_mw, ibmw);
 }
 
-struct c4iw_fr_page_list {
-	struct ib_fast_reg_page_list ibpl;
-	DEFINE_DMA_UNMAP_ADDR(mapping);
-	dma_addr_t dma_addr;
-	struct c4iw_dev *dev;
-	int pll_len;
-};
-
-static inline struct c4iw_fr_page_list *to_c4iw_fr_page_list(
-					struct ib_fast_reg_page_list *ibpl)
-{
-	return container_of(ibpl, struct c4iw_fr_page_list, ibpl);
-}
-
 struct c4iw_cq {
 	struct ib_cq ibcq;
 	struct c4iw_dev *rhp;
@@ -970,10 +956,6 @@ int c4iw_accept_cr(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param);
 int c4iw_reject_cr(struct iw_cm_id *cm_id, const void *pdata, u8 pdata_len);
 void c4iw_qp_add_ref(struct ib_qp *qp);
 void c4iw_qp_rem_ref(struct ib_qp *qp);
-void c4iw_free_fastreg_pbl(struct ib_fast_reg_page_list *page_list);
-struct ib_fast_reg_page_list *c4iw_alloc_fastreg_pbl(
-					struct ib_device *device,
-					int page_list_len);
 struct ib_mr *c4iw_alloc_mr(struct ib_pd *pd,
 			    enum ib_mr_type mr_type,
 			    u32 max_num_sg);
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 86ec65721797..ada42ed425a0 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -945,51 +945,6 @@ int c4iw_map_mr_sg(struct ib_mr *ibmr,
 	return ib_sg_to_pages(ibmr, sg, sg_nents, c4iw_set_page);
 }
 
-struct ib_fast_reg_page_list *c4iw_alloc_fastreg_pbl(struct ib_device *device,
-						     int page_list_len)
-{
-	struct c4iw_fr_page_list *c4pl;
-	struct c4iw_dev *dev = to_c4iw_dev(device);
-	dma_addr_t dma_addr;
-	int pll_len = roundup(page_list_len * sizeof(u64), 32);
-
-	c4pl = kmalloc(sizeof(*c4pl), GFP_KERNEL);
-	if (!c4pl)
-		return ERR_PTR(-ENOMEM);
-
-	c4pl->ibpl.page_list = dma_alloc_coherent(&dev->rdev.lldi.pdev->dev,
-						  pll_len, &dma_addr,
-						  GFP_KERNEL);
-	if (!c4pl->ibpl.page_list) {
-		kfree(c4pl);
-		return ERR_PTR(-ENOMEM);
-	}
-	dma_unmap_addr_set(c4pl, mapping, dma_addr);
-	c4pl->dma_addr = dma_addr;
-	c4pl->dev = dev;
-	c4pl->pll_len = pll_len;
-
-	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %pad\n",
-	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
-	     &c4pl->dma_addr);
-
-	return &c4pl->ibpl;
-}
-
-void c4iw_free_fastreg_pbl(struct ib_fast_reg_page_list *ibpl)
-{
-	struct c4iw_fr_page_list *c4pl = to_c4iw_fr_page_list(ibpl);
-
-	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %pad\n",
-	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
-	     &c4pl->dma_addr);
-
-	dma_free_coherent(&c4pl->dev->rdev.lldi.pdev->dev,
-			  c4pl->pll_len,
-			  c4pl->ibpl.page_list, dma_unmap_addr(c4pl, mapping));
-	kfree(c4pl);
-}
-
 int c4iw_dereg_mr(struct ib_mr *ib_mr)
 {
 	struct c4iw_dev *rhp;
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 55dedadcffaa..8f115b405d76 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -558,8 +558,6 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	dev->ibdev.dealloc_mw = c4iw_dealloc_mw;
 	dev->ibdev.alloc_mr = c4iw_alloc_mr;
 	dev->ibdev.map_mr_sg = c4iw_map_mr_sg;
-	dev->ibdev.alloc_fast_reg_page_list = c4iw_alloc_fastreg_pbl;
-	dev->ibdev.free_fast_reg_page_list = c4iw_free_fastreg_pbl;
 	dev->ibdev.attach_mcast = c4iw_multicast_attach;
 	dev->ibdev.detach_mcast = c4iw_multicast_detach;
 	dev->ibdev.process_mad = c4iw_process_mad;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 12a23bc935f3..c7d05a933e2d 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -670,75 +670,6 @@ static int build_memreg(struct t4_sq *sq, union t4_wr *wqe,
 	return 0;
 }
 
-static int build_fastreg(struct t4_sq *sq, union t4_wr *wqe,
-			 struct ib_send_wr *send_wr, u8 *len16, u8 t5dev)
-{
-	struct ib_fast_reg_wr *wr = fast_reg_wr(send_wr);
-
-	struct fw_ri_immd *imdp;
-	__be64 *p;
-	int i;
-	int pbllen = roundup(wr->page_list_len * sizeof(u64), 32);
-	int rem;
-
-	if (wr->page_list_len > t4_max_fr_depth(use_dsgl))
-		return -EINVAL;
-
-	wqe->fr.qpbinde_to_dcacpu = 0;
-	wqe->fr.pgsz_shift = wr->page_shift - 12;
-	wqe->fr.addr_type = FW_RI_VA_BASED_TO;
-	wqe->fr.mem_perms = c4iw_ib_to_tpt_access(wr->access_flags);
-	wqe->fr.len_hi = 0;
-	wqe->fr.len_lo = cpu_to_be32(wr->length);
-	wqe->fr.stag = cpu_to_be32(wr->rkey);
-	wqe->fr.va_hi = cpu_to_be32(wr->iova_start >> 32);
-	wqe->fr.va_lo_fbo = cpu_to_be32(wr->iova_start & 0xffffffff);
-
-	if (t5dev && use_dsgl && (pbllen > max_fr_immd)) {
-		struct c4iw_fr_page_list *c4pl =
-			to_c4iw_fr_page_list(wr->page_list);
-		struct fw_ri_dsgl *sglp;
-
-		for (i = 0; i < wr->page_list_len; i++) {
-			wr->page_list->page_list[i] = (__force u64)
-				cpu_to_be64((u64)wr->page_list->page_list[i]);
-		}
-
-		sglp = (struct fw_ri_dsgl *)(&wqe->fr + 1);
-		sglp->op = FW_RI_DATA_DSGL;
-		sglp->r1 = 0;
-		sglp->nsge = cpu_to_be16(1);
-		sglp->addr0 = cpu_to_be64(c4pl->dma_addr);
-		sglp->len0 = cpu_to_be32(pbllen);
-
-		*len16 = DIV_ROUND_UP(sizeof(wqe->fr) + sizeof(*sglp), 16);
-	} else {
-		imdp = (struct fw_ri_immd *)(&wqe->fr + 1);
-		imdp->op = FW_RI_DATA_IMMD;
-		imdp->r1 = 0;
-		imdp->r2 = 0;
-		imdp->immdlen = cpu_to_be32(pbllen);
-		p = (__be64 *)(imdp + 1);
-		rem = pbllen;
-		for (i = 0; i < wr->page_list_len; i++) {
-			*p = cpu_to_be64((u64)wr->page_list->page_list[i]);
-			rem -= sizeof(*p);
-			if (++p == (__be64 *)&sq->queue[sq->size])
-				p = (__be64 *)sq->queue;
-		}
-		BUG_ON(rem < 0);
-		while (rem) {
-			*p = 0;
-			rem -= sizeof(*p);
-			if (++p == (__be64 *)&sq->queue[sq->size])
-				p = (__be64 *)sq->queue;
-		}
-		*len16 = DIV_ROUND_UP(sizeof(wqe->fr) + sizeof(*imdp)
-				      + pbllen, 16);
-	}
-	return 0;
-}
-
 static int build_inv_stag(union t4_wr *wqe, struct ib_send_wr *wr,
 			  u8 *len16)
 {
@@ -875,14 +806,6 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 			if (!qhp->wq.sq.oldest_read)
 				qhp->wq.sq.oldest_read = swsqe;
 			break;
-		case IB_WR_FAST_REG_MR:
-			fw_opcode = FW_RI_FR_NSMR_WR;
-			swsqe->opcode = FW_RI_FAST_REGISTER;
-			err = build_fastreg(&qhp->wq.sq, wqe, wr, &len16,
-					    is_t5(
-					    qhp->rhp->rdev.lldi.adapter_type) ?
-					    1 : 0);
-			break;
 		case IB_WR_REG_MR:
 			fw_opcode = FW_RI_FR_NSMR_WR;
 			swsqe->opcode = FW_RI_FAST_REGISTER;
-- 
1.8.4.3

