Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35246 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753913AbbJHHwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:52:20 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 21/26] RDMA/ocrdma: Remove old FRWR API
Date: Thu,  8 Oct 2015 10:51:04 +0300
Message-Id: <1444290669-5252-22-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/ocrdma/ocrdma_main.c  |   2 -
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c | 104 +---------------------------
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h |   4 --
 3 files changed, 1 insertion(+), 109 deletions(-)

diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index 874beb4b07a1..9bf430ef8eb6 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -183,8 +183,6 @@ static int ocrdma_register_device(struct ocrdma_dev *dev)
 
 	dev->ibdev.alloc_mr = ocrdma_alloc_mr;
 	dev->ibdev.map_mr_sg = ocrdma_map_mr_sg;
-	dev->ibdev.alloc_fast_reg_page_list = ocrdma_alloc_frmr_page_list;
-	dev->ibdev.free_fast_reg_page_list = ocrdma_free_frmr_page_list;
 
 	/* mandatory to support user space verbs consumer. */
 	dev->ibdev.alloc_ucontext = ocrdma_alloc_ucontext;
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index 66cc15a78f63..0b8598c9d56b 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -2133,41 +2133,6 @@ static void ocrdma_build_read(struct ocrdma_qp *qp, struct ocrdma_hdr_wqe *hdr,
 	ext_rw->len = hdr->total_len;
 }
 
-static void build_frmr_pbes(struct ib_fast_reg_wr *wr,
-			    struct ocrdma_pbl *pbl_tbl,
-			    struct ocrdma_hw_mr *hwmr)
-{
-	int i;
-	u64 buf_addr = 0;
-	int num_pbes;
-	struct ocrdma_pbe *pbe;
-
-	pbe = (struct ocrdma_pbe *)pbl_tbl->va;
-	num_pbes = 0;
-
-	/* go through the OS phy regions & fill hw pbe entries into pbls. */
-	for (i = 0; i < wr->page_list_len; i++) {
-		/* number of pbes can be more for one OS buf, when
-		 * buffers are of different sizes.
-		 * split the ib_buf to one or more pbes.
-		 */
-		buf_addr = wr->page_list->page_list[i];
-		pbe->pa_lo = cpu_to_le32((u32) (buf_addr & PAGE_MASK));
-		pbe->pa_hi = cpu_to_le32((u32) upper_32_bits(buf_addr));
-		num_pbes += 1;
-		pbe++;
-
-		/* if the pbl is full storing the pbes,
-		 * move to next pbl.
-		*/
-		if (num_pbes == (hwmr->pbl_size/sizeof(u64))) {
-			pbl_tbl++;
-			pbe = (struct ocrdma_pbe *)pbl_tbl->va;
-		}
-	}
-	return;
-}
-
 static int get_encoded_page_size(int pg_sz)
 {
 	/* Max size is 256M 4096 << 16 */
@@ -2234,50 +2199,6 @@ static int ocrdma_build_reg(struct ocrdma_qp *qp,
 	return 0;
 }
 
-static int ocrdma_build_fr(struct ocrdma_qp *qp, struct ocrdma_hdr_wqe *hdr,
-			   struct ib_send_wr *send_wr)
-{
-	u64 fbo;
-	struct ib_fast_reg_wr *wr = fast_reg_wr(send_wr);
-	struct ocrdma_ewqe_fr *fast_reg = (struct ocrdma_ewqe_fr *)(hdr + 1);
-	struct ocrdma_mr *mr;
-	struct ocrdma_dev *dev = get_ocrdma_dev(qp->ibqp.device);
-	u32 wqe_size = sizeof(*fast_reg) + sizeof(*hdr);
-
-	wqe_size = roundup(wqe_size, OCRDMA_WQE_ALIGN_BYTES);
-
-	if (wr->page_list_len > dev->attr.max_pages_per_frmr)
-		return -EINVAL;
-
-	hdr->cw |= (OCRDMA_FR_MR << OCRDMA_WQE_OPCODE_SHIFT);
-	hdr->cw |= ((wqe_size / OCRDMA_WQE_STRIDE) << OCRDMA_WQE_SIZE_SHIFT);
-
-	if (wr->page_list_len == 0)
-		BUG();
-	if (wr->access_flags & IB_ACCESS_LOCAL_WRITE)
-		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_LOCAL_WR;
-	if (wr->access_flags & IB_ACCESS_REMOTE_WRITE)
-		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_REMOTE_WR;
-	if (wr->access_flags & IB_ACCESS_REMOTE_READ)
-		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_REMOTE_RD;
-	hdr->lkey = wr->rkey;
-	hdr->total_len = wr->length;
-
-	fbo = wr->iova_start - (wr->page_list->page_list[0] & PAGE_MASK);
-
-	fast_reg->va_hi = upper_32_bits(wr->iova_start);
-	fast_reg->va_lo = (u32) (wr->iova_start & 0xffffffff);
-	fast_reg->fbo_hi = upper_32_bits(fbo);
-	fast_reg->fbo_lo = (u32) fbo & 0xffffffff;
-	fast_reg->num_sges = wr->page_list_len;
-	fast_reg->size_sge =
-		get_encoded_page_size(1 << wr->page_shift);
-	mr = (struct ocrdma_mr *) (unsigned long)
-		dev->stag_arr[(hdr->lkey >> 8) & (OCRDMA_MAX_STAG - 1)];
-	build_frmr_pbes(wr, mr->hwmr.pbl_table, &mr->hwmr);
-	return 0;
-}
-
 static void ocrdma_ring_sq_db(struct ocrdma_qp *qp)
 {
 	u32 val = qp->sq.dbid | (1 << OCRDMA_DB_SQ_SHIFT);
@@ -2357,9 +2278,6 @@ int ocrdma_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				OCRDMA_WQE_STRIDE) << OCRDMA_WQE_SIZE_SHIFT;
 			hdr->lkey = wr->ex.invalidate_rkey;
 			break;
-		case IB_WR_FAST_REG_MR:
-			status = ocrdma_build_fr(qp, hdr, wr);
-			break;
 		case IB_WR_REG_MR:
 			status = ocrdma_build_reg(qp, hdr, reg_wr(wr));
 			break;
@@ -2627,7 +2545,7 @@ static void ocrdma_update_wc(struct ocrdma_qp *qp, struct ib_wc *ibwc,
 		ibwc->opcode = IB_WC_SEND;
 		break;
 	case OCRDMA_FR_MR:
-		ibwc->opcode = IB_WC_FAST_REG_MR;
+		ibwc->opcode = IB_WC_REG_MR;
 		break;
 	case OCRDMA_LKEY_INV:
 		ibwc->opcode = IB_WC_LOCAL_INV;
@@ -3153,26 +3071,6 @@ pl_err:
 	return ERR_PTR(-ENOMEM);
 }
 
-struct ib_fast_reg_page_list *ocrdma_alloc_frmr_page_list(struct ib_device
-							  *ibdev,
-							  int page_list_len)
-{
-	struct ib_fast_reg_page_list *frmr_list;
-	int size;
-
-	size = sizeof(*frmr_list) + (page_list_len * sizeof(u64));
-	frmr_list = kzalloc(size, GFP_KERNEL);
-	if (!frmr_list)
-		return ERR_PTR(-ENOMEM);
-	frmr_list->page_list = (u64 *)(frmr_list + 1);
-	return frmr_list;
-}
-
-void ocrdma_free_frmr_page_list(struct ib_fast_reg_page_list *page_list)
-{
-	kfree(page_list);
-}
-
 #define MAX_KERNEL_PBE_SIZE 65536
 static inline int count_kernel_pbes(struct ib_phys_buf *buf_list,
 				    int buf_cnt, u32 *pbe_size)
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
index 4edf63f9c6c7..62d6608830cb 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
@@ -128,9 +128,5 @@ struct ib_mr *ocrdma_alloc_mr(struct ib_pd *pd,
 int ocrdma_map_mr_sg(struct ib_mr *ibmr,
 		     struct scatterlist *sg,
 		     unsigned int sg_nents);
-struct ib_fast_reg_page_list *ocrdma_alloc_frmr_page_list(struct ib_device
-							*ibdev,
-							int page_list_len);
-void ocrdma_free_frmr_page_list(struct ib_fast_reg_page_list *page_list);
 
 #endif				/* __OCRDMA_VERBS_H__ */
-- 
1.8.4.3

