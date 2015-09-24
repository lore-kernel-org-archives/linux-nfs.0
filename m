Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42034 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757535AbbIXRhr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:47 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 24/26] RDMA/nes: Remove old FRWR API
Date: Thu, 24 Sep 2015 20:35:16 +0300
Message-Id: <1443116118-10730-25-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No ULP uses it anymore, go ahead and remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/nes/nes_hw.h    |   6 --
 drivers/infiniband/hw/nes/nes_verbs.c | 162 +---------------------------------
 2 files changed, 1 insertion(+), 167 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_hw.h b/drivers/infiniband/hw/nes/nes_hw.h
index d748e4b31b8d..c9080208aad2 100644
--- a/drivers/infiniband/hw/nes/nes_hw.h
+++ b/drivers/infiniband/hw/nes/nes_hw.h
@@ -1200,12 +1200,6 @@ struct nes_fast_mr_wqe_pbl {
 	dma_addr_t	paddr;
 };
 
-struct nes_ib_fast_reg_page_list {
-	struct ib_fast_reg_page_list	ibfrpl;
-	struct nes_fast_mr_wqe_pbl 	nes_wqe_pbl;
-	u64 				pbl;
-};
-
 struct nes_listener {
 	struct work_struct      work;
 	struct workqueue_struct *wq;
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index f5b0cc972403..c58091a6635f 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -486,76 +486,6 @@ static int nes_map_mr_sg(struct ib_mr *ibmr,
 	return ib_sg_to_pages(ibmr, sg, sg_nents, nes_set_page);
 }
 
-/*
- * nes_alloc_fast_reg_page_list
- */
-static struct ib_fast_reg_page_list *nes_alloc_fast_reg_page_list(
-							struct ib_device *ibdev,
-							int page_list_len)
-{
-	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
-	struct nes_device *nesdev = nesvnic->nesdev;
-	struct ib_fast_reg_page_list *pifrpl;
-	struct nes_ib_fast_reg_page_list *pnesfrpl;
-
-	if (page_list_len > (NES_4K_PBL_CHUNK_SIZE / sizeof(u64)))
-		return ERR_PTR(-E2BIG);
-	/*
-	 * Allocate the ib_fast_reg_page_list structure, the
-	 * nes_fast_bpl structure, and the PLB table.
-	 */
-	pnesfrpl = kmalloc(sizeof(struct nes_ib_fast_reg_page_list) +
-			   page_list_len * sizeof(u64), GFP_KERNEL);
-
-	if (!pnesfrpl)
-		return ERR_PTR(-ENOMEM);
-
-	pifrpl = &pnesfrpl->ibfrpl;
-	pifrpl->page_list = &pnesfrpl->pbl;
-	pifrpl->max_page_list_len = page_list_len;
-	/*
-	 * Allocate the WQE PBL
-	 */
-	pnesfrpl->nes_wqe_pbl.kva = pci_alloc_consistent(nesdev->pcidev,
-							 page_list_len * sizeof(u64),
-							 &pnesfrpl->nes_wqe_pbl.paddr);
-
-	if (!pnesfrpl->nes_wqe_pbl.kva) {
-		kfree(pnesfrpl);
-		return ERR_PTR(-ENOMEM);
-	}
-	nes_debug(NES_DBG_MR, "nes_alloc_fast_reg_pbl: nes_frpl = %p, "
-		  "ibfrpl = %p, ibfrpl.page_list = %p, pbl.kva = %p, "
-		  "pbl.paddr = %llx\n", pnesfrpl, &pnesfrpl->ibfrpl,
-		  pnesfrpl->ibfrpl.page_list, pnesfrpl->nes_wqe_pbl.kva,
-		  (unsigned long long) pnesfrpl->nes_wqe_pbl.paddr);
-
-	return pifrpl;
-}
-
-/*
- * nes_free_fast_reg_page_list
- */
-static void nes_free_fast_reg_page_list(struct ib_fast_reg_page_list *pifrpl)
-{
-	struct nes_vnic *nesvnic = to_nesvnic(pifrpl->device);
-	struct nes_device *nesdev = nesvnic->nesdev;
-	struct nes_ib_fast_reg_page_list *pnesfrpl;
-
-	pnesfrpl = container_of(pifrpl, struct nes_ib_fast_reg_page_list, ibfrpl);
-	/*
-	 * Free the WQE PBL.
-	 */
-	pci_free_consistent(nesdev->pcidev,
-			    pifrpl->max_page_list_len * sizeof(u64),
-			    pnesfrpl->nes_wqe_pbl.kva,
-			    pnesfrpl->nes_wqe_pbl.paddr);
-	/*
-	 * Free the PBL structure
-	 */
-	kfree(pnesfrpl);
-}
-
 /**
  * nes_query_device
  */
@@ -3470,94 +3400,6 @@ static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
 					    NES_IWARP_SQ_LOCINV_WQE_INV_STAG_IDX,
 					    ib_wr->ex.invalidate_rkey);
 			break;
-		case IB_WR_FAST_REG_MR:
-		{
-			int i;
-			struct ib_fast_reg_wr *fwr = fast_reg_wr(ib_wr);
-			int flags = fwr->access_flags;
-			struct nes_ib_fast_reg_page_list *pnesfrpl =
-				container_of(fwr->page_list,
-					     struct nes_ib_fast_reg_page_list,
-					     ibfrpl);
-			u64 *src_page_list = pnesfrpl->ibfrpl.page_list;
-			u64 *dst_page_list = pnesfrpl->nes_wqe_pbl.kva;
-
-			if (fwr->page_list_len >
-			    (NES_4K_PBL_CHUNK_SIZE / sizeof(u64))) {
-				nes_debug(NES_DBG_IW_TX, "SQ_FMR: bad page_list_len\n");
-				err = -EINVAL;
-				break;
-			}
-			wqe_misc = NES_IWARP_SQ_OP_FAST_REG;
-			set_wqe_64bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_VA_FBO_LOW_IDX,
-					    fwr->iova_start);
-			set_wqe_32bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_LENGTH_LOW_IDX,
-					    fwr->length);
-			set_wqe_32bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_LENGTH_HIGH_IDX, 0);
-			set_wqe_32bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_MR_STAG_IDX,
-					    fwr->rkey);
-			/* Set page size: */
-			if (fwr->page_shift == 12) {
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_PAGE_SIZE_4K;
-			} else if (fwr->page_shift == 21) {
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_PAGE_SIZE_2M;
-			} else {
-				nes_debug(NES_DBG_IW_TX, "Invalid page shift,"
-					  " ib_wr=%u, max=1\n", ib_wr->num_sge);
-				err = -EINVAL;
-				break;
-			}
-			/* Set access_flags */
-			wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_LOCAL_READ;
-			if (flags & IB_ACCESS_LOCAL_WRITE)
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_LOCAL_WRITE;
-
-			if (flags & IB_ACCESS_REMOTE_WRITE)
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_REMOTE_WRITE;
-
-			if (flags & IB_ACCESS_REMOTE_READ)
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_REMOTE_READ;
-
-			if (flags & IB_ACCESS_MW_BIND)
-				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_WINDOW_BIND;
-
-			/* Fill in PBL info: */
-			if (fwr->page_list_len >
-			    pnesfrpl->ibfrpl.max_page_list_len) {
-				nes_debug(NES_DBG_IW_TX, "Invalid page list length,"
-					  " ib_wr=%p, value=%u, max=%u\n",
-					  ib_wr, fwr->page_list_len,
-					  pnesfrpl->ibfrpl.max_page_list_len);
-				err = -EINVAL;
-				break;
-			}
-
-			set_wqe_64bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_PBL_ADDR_LOW_IDX,
-					    pnesfrpl->nes_wqe_pbl.paddr);
-
-			set_wqe_32bit_value(wqe->wqe_words,
-					    NES_IWARP_SQ_FMR_WQE_PBL_LENGTH_IDX,
-					    fwr->page_list_len * 8);
-
-			for (i = 0; i < fwr->page_list_len; i++)
-				dst_page_list[i] = cpu_to_le64(src_page_list[i]);
-
-			nes_debug(NES_DBG_IW_TX, "SQ_FMR: iova_start: %llx, "
-				  "length: %d, rkey: %0x, pgl_paddr: %llx, "
-				  "page_list_len: %u, wqe_misc: %x\n",
-				  (unsigned long long) fwr->iova_start,
-				  fwr->length,
-				  fwr->rkey,
-				  (unsigned long long) pnesfrpl->nes_wqe_pbl.paddr,
-				  fwr->page_list_len,
-				  wqe_misc);
-			break;
-		}
 		case IB_WR_REG_MR:
 		{
 			struct nes_mr *mr = to_nesmr(reg_wr(ib_wr)->mr);
@@ -3866,7 +3708,7 @@ static int nes_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *entry)
 						entry->opcode = IB_WC_LOCAL_INV;
 						break;
 					case NES_IWARP_SQ_OP_FAST_REG:
-						entry->opcode = IB_WC_FAST_REG_MR;
+						entry->opcode = IB_WC_REG_MR;
 						break;
 				}
 
@@ -4055,8 +3897,6 @@ struct nes_ib_device *nes_init_ofa_device(struct net_device *netdev)
 
 	nesibdev->ibdev.alloc_mr = nes_alloc_mr;
 	nesibdev->ibdev.map_mr_sg = nes_map_mr_sg;
-	nesibdev->ibdev.alloc_fast_reg_page_list = nes_alloc_fast_reg_page_list;
-	nesibdev->ibdev.free_fast_reg_page_list = nes_free_fast_reg_page_list;
 
 	nesibdev->ibdev.attach_mcast = nes_multicast_attach;
 	nesibdev->ibdev.detach_mcast = nes_multicast_detach;
-- 
1.8.4.3

