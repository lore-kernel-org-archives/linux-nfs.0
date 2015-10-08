Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35112 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752551AbbJHHvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:51:37 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/26] RDMA/ocrdma: Support the new memory registration API
Date: Thu,  8 Oct 2015 10:50:48 +0300
Message-Id: <1444290669-5252-6-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in ocrdma_mr and populate it when
ocrdma_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by duplicating IB_WR_FAST_REG_MR, but take the needed
information from different places:
- page_size, iova, length, access flags (ib_mr)
- page array (ocrdma_mr)
- key (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/ocrdma/ocrdma.h       |  2 +
 drivers/infiniband/hw/ocrdma/ocrdma_main.c  |  1 +
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c | 90 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h |  3 +
 4 files changed, 96 insertions(+)

diff --git a/drivers/infiniband/hw/ocrdma/ocrdma.h b/drivers/infiniband/hw/ocrdma/ocrdma.h
index b4091ab48db0..c2f3af5d5194 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma.h
@@ -193,6 +193,8 @@ struct ocrdma_mr {
 	struct ib_mr ibmr;
 	struct ib_umem *umem;
 	struct ocrdma_hw_mr hwmr;
+	u64 *pages;
+	u32 npages;
 };
 
 struct ocrdma_stats {
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index 87aa55df7c82..874beb4b07a1 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -182,6 +182,7 @@ static int ocrdma_register_device(struct ocrdma_dev *dev)
 	dev->ibdev.reg_user_mr = ocrdma_reg_user_mr;
 
 	dev->ibdev.alloc_mr = ocrdma_alloc_mr;
+	dev->ibdev.map_mr_sg = ocrdma_map_mr_sg;
 	dev->ibdev.alloc_fast_reg_page_list = ocrdma_alloc_frmr_page_list;
 	dev->ibdev.free_fast_reg_page_list = ocrdma_free_frmr_page_list;
 
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index eb09e224acb9..66cc15a78f63 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -1013,6 +1013,7 @@ int ocrdma_dereg_mr(struct ib_mr *ib_mr)
 
 	(void) ocrdma_mbx_dealloc_lkey(dev, mr->hwmr.fr_mr, mr->hwmr.lkey);
 
+	kfree(mr->pages);
 	ocrdma_free_mr_pbl_tbl(dev, &mr->hwmr);
 
 	/* it could be user registered memory. */
@@ -2177,6 +2178,61 @@ static int get_encoded_page_size(int pg_sz)
 	return i;
 }
 
+static int ocrdma_build_reg(struct ocrdma_qp *qp,
+			    struct ocrdma_hdr_wqe *hdr,
+			    struct ib_reg_wr *wr)
+{
+	u64 fbo;
+	struct ocrdma_ewqe_fr *fast_reg = (struct ocrdma_ewqe_fr *)(hdr + 1);
+	struct ocrdma_mr *mr = get_ocrdma_mr(wr->mr);
+	struct ocrdma_pbl *pbl_tbl = mr->hwmr.pbl_table;
+	struct ocrdma_pbe *pbe;
+	u32 wqe_size = sizeof(*fast_reg) + sizeof(*hdr);
+	int num_pbes = 0, i;
+
+	wqe_size = roundup(wqe_size, OCRDMA_WQE_ALIGN_BYTES);
+
+	hdr->cw |= (OCRDMA_FR_MR << OCRDMA_WQE_OPCODE_SHIFT);
+	hdr->cw |= ((wqe_size / OCRDMA_WQE_STRIDE) << OCRDMA_WQE_SIZE_SHIFT);
+
+	if (wr->access & IB_ACCESS_LOCAL_WRITE)
+		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_LOCAL_WR;
+	if (wr->access & IB_ACCESS_REMOTE_WRITE)
+		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_REMOTE_WR;
+	if (wr->access & IB_ACCESS_REMOTE_READ)
+		hdr->rsvd_lkey_flags |= OCRDMA_LKEY_FLAG_REMOTE_RD;
+	hdr->lkey = wr->key;
+	hdr->total_len = mr->ibmr.length;
+
+	fbo = mr->ibmr.iova - mr->pages[0];
+
+	fast_reg->va_hi = upper_32_bits(mr->ibmr.iova);
+	fast_reg->va_lo = (u32) (mr->ibmr.iova & 0xffffffff);
+	fast_reg->fbo_hi = upper_32_bits(fbo);
+	fast_reg->fbo_lo = (u32) fbo & 0xffffffff;
+	fast_reg->num_sges = mr->npages;
+	fast_reg->size_sge = get_encoded_page_size(mr->ibmr.page_size);
+
+	pbe = pbl_tbl->va;
+	for (i = 0; i < mr->npages; i++) {
+		u64 buf_addr = mr->pages[i];
+
+		pbe->pa_lo = cpu_to_le32((u32) (buf_addr & PAGE_MASK));
+		pbe->pa_hi = cpu_to_le32((u32) upper_32_bits(buf_addr));
+		num_pbes += 1;
+		pbe++;
+
+		/* if the pbl is full storing the pbes,
+		 * move to next pbl.
+		*/
+		if (num_pbes == (mr->hwmr.pbl_size/sizeof(u64))) {
+			pbl_tbl++;
+			pbe = (struct ocrdma_pbe *)pbl_tbl->va;
+		}
+	}
+
+	return 0;
+}
 
 static int ocrdma_build_fr(struct ocrdma_qp *qp, struct ocrdma_hdr_wqe *hdr,
 			   struct ib_send_wr *send_wr)
@@ -2304,6 +2360,9 @@ int ocrdma_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		case IB_WR_FAST_REG_MR:
 			status = ocrdma_build_fr(qp, hdr, wr);
 			break;
+		case IB_WR_REG_MR:
+			status = ocrdma_build_reg(qp, hdr, reg_wr(wr));
+			break;
 		default:
 			status = -EINVAL;
 			break;
@@ -3059,6 +3118,12 @@ struct ib_mr *ocrdma_alloc_mr(struct ib_pd *ibpd,
 	if (!mr)
 		return ERR_PTR(-ENOMEM);
 
+	mr->pages = kcalloc(max_num_sg, sizeof(u64), GFP_KERNEL);
+	if (!mr->pages) {
+		status = -ENOMEM;
+		goto pl_err;
+	}
+
 	status = ocrdma_get_pbl_info(dev, mr, max_num_sg);
 	if (status)
 		goto pbl_err;
@@ -3082,6 +3147,8 @@ struct ib_mr *ocrdma_alloc_mr(struct ib_pd *ibpd,
 mbx_err:
 	ocrdma_free_mr_pbl_tbl(dev, &mr->hwmr);
 pbl_err:
+	kfree(mr->pages);
+pl_err:
 	kfree(mr);
 	return ERR_PTR(-ENOMEM);
 }
@@ -3268,3 +3335,26 @@ pbl_err:
 	kfree(mr);
 	return ERR_PTR(status);
 }
+
+static int ocrdma_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct ocrdma_mr *mr = get_ocrdma_mr(ibmr);
+
+	if (unlikely(mr->npages == mr->hwmr.num_pbes))
+		return -ENOMEM;
+
+	mr->pages[mr->npages++] = addr;
+
+	return 0;
+}
+
+int ocrdma_map_mr_sg(struct ib_mr *ibmr,
+		     struct scatterlist *sg,
+		     unsigned int sg_nents)
+{
+	struct ocrdma_mr *mr = get_ocrdma_mr(ibmr);
+
+	mr->npages = 0;
+
+	return ib_sg_to_pages(ibmr, sg, sg_nents, ocrdma_set_page);
+}
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
index 308c16857a5d..4edf63f9c6c7 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
@@ -125,6 +125,9 @@ struct ib_mr *ocrdma_reg_user_mr(struct ib_pd *, u64 start, u64 length,
 struct ib_mr *ocrdma_alloc_mr(struct ib_pd *pd,
 			      enum ib_mr_type mr_type,
 			      u32 max_num_sg);
+int ocrdma_map_mr_sg(struct ib_mr *ibmr,
+		     struct scatterlist *sg,
+		     unsigned int sg_nents);
 struct ib_fast_reg_page_list *ocrdma_alloc_frmr_page_list(struct ib_device
 							*ibdev,
 							int page_list_len);
-- 
1.8.4.3

