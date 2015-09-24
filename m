Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41962 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757448AbbIXRhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:07 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 09/26] RDMA/nes: Support the new memory registration API
Date: Thu, 24 Sep 2015 20:35:01 +0300
Message-Id: <1443116118-10730-10-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the new memory registration API by allocating a
private page list array in nes_mr and populate it when
nes_map_mr_sg is invoked. Also, support IB_WR_REG_MR
by duplicating IB_WR_FAST_REG_MR handling and take the
needed information from different places:
- page_size, iova, length (ib_mr)
- page array (nes_mr)
- key, access flags (ib_reg_wr)

The IB_WR_FAST_REG_MR handlers will be removed later when
all the ULPs will be converted.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/nes/nes_verbs.c | 117 +++++++++++++++++++++++++++++++++-
 drivers/infiniband/hw/nes/nes_verbs.h |   4 ++
 2 files changed, 120 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index f71b37b75f82..f5b0cc972403 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -51,6 +51,7 @@ atomic_t qps_created;
 atomic_t sw_qps_destroyed;
 
 static void nes_unregister_ofa_device(struct nes_ib_device *nesibdev);
+static int nes_dereg_mr(struct ib_mr *ib_mr);
 
 /**
  * nes_alloc_mw
@@ -443,9 +444,46 @@ static struct ib_mr *nes_alloc_mr(struct ib_pd *ibpd,
 	} else {
 		kfree(nesmr);
 		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
-		ibmr = ERR_PTR(-ENOMEM);
+		return ERR_PTR(-ENOMEM);
 	}
+
+	nesmr->pages = pci_alloc_consistent(nesdev->pcidev,
+					    max_num_sg * sizeof(u64),
+					    &nesmr->paddr);
+	if (!nesmr->paddr)
+		goto err;
+
+	nesmr->max_pages = max_num_sg;
+
 	return ibmr;
+
+err:
+	nes_dereg_mr(ibmr);
+
+	return ERR_PTR(-ENOMEM);
+}
+
+static int nes_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct nes_mr *nesmr = to_nesmr(ibmr);
+
+	if (unlikely(nesmr->npages == nesmr->max_pages))
+		return -ENOMEM;
+
+	nesmr->pages[nesmr->npages++] = cpu_to_le64(addr);
+
+	return 0;
+}
+
+static int nes_map_mr_sg(struct ib_mr *ibmr,
+			 struct scatterlist *sg,
+			 unsigned int sg_nents)
+{
+	struct nes_mr *nesmr = to_nesmr(ibmr);
+
+	nesmr->npages = 0;
+
+	return ib_sg_to_pages(ibmr, sg, sg_nents, nes_set_page);
 }
 
 /*
@@ -2683,6 +2721,13 @@ static int nes_dereg_mr(struct ib_mr *ib_mr)
 	u16 major_code;
 	u16 minor_code;
 
+
+	if (nesmr->pages)
+		pci_free_consistent(nesdev->pcidev,
+				    nesmr->max_pages * sizeof(u64),
+				    nesmr->pages,
+				    nesmr->paddr);
+
 	if (nesmr->region) {
 		ib_umem_release(nesmr->region);
 	}
@@ -3513,6 +3558,75 @@ static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
 				  wqe_misc);
 			break;
 		}
+		case IB_WR_REG_MR:
+		{
+			struct nes_mr *mr = to_nesmr(reg_wr(ib_wr)->mr);
+			int page_shift = ilog2(reg_wr(ib_wr)->mr->page_size);
+			int flags = reg_wr(ib_wr)->access;
+
+			if (mr->npages > (NES_4K_PBL_CHUNK_SIZE / sizeof(u64))) {
+				nes_debug(NES_DBG_IW_TX, "SQ_FMR: bad page_list_len\n");
+				err = -EINVAL;
+				break;
+			}
+			wqe_misc = NES_IWARP_SQ_OP_FAST_REG;
+			set_wqe_64bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_VA_FBO_LOW_IDX,
+					    mr->ibmr.iova);
+			set_wqe_32bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_LENGTH_LOW_IDX,
+					    mr->ibmr.length);
+			set_wqe_32bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_LENGTH_HIGH_IDX, 0);
+			set_wqe_32bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_MR_STAG_IDX,
+					    reg_wr(ib_wr)->key);
+
+			if (page_shift == 12) {
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_PAGE_SIZE_4K;
+			} else if (page_shift == 21) {
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_PAGE_SIZE_2M;
+			} else {
+				nes_debug(NES_DBG_IW_TX, "Invalid page shift,"
+					  " ib_wr=%u, max=1\n", ib_wr->num_sge);
+				err = -EINVAL;
+				break;
+			}
+
+			/* Set access_flags */
+			wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_LOCAL_READ;
+			if (flags & IB_ACCESS_LOCAL_WRITE)
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_LOCAL_WRITE;
+
+			if (flags & IB_ACCESS_REMOTE_WRITE)
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_REMOTE_WRITE;
+
+			if (flags & IB_ACCESS_REMOTE_READ)
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_REMOTE_READ;
+
+			if (flags & IB_ACCESS_MW_BIND)
+				wqe_misc |= NES_IWARP_SQ_FMR_WQE_RIGHTS_ENABLE_WINDOW_BIND;
+
+			/* Fill in PBL info: */
+			set_wqe_64bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_PBL_ADDR_LOW_IDX,
+					    mr->paddr);
+
+			set_wqe_32bit_value(wqe->wqe_words,
+					    NES_IWARP_SQ_FMR_WQE_PBL_LENGTH_IDX,
+					    mr->npages * 8);
+
+			nes_debug(NES_DBG_IW_TX, "SQ_REG_MR: iova_start: %llx, "
+				  "length: %d, rkey: %0x, pgl_paddr: %llx, "
+				  "page_list_len: %u, wqe_misc: %x\n",
+				  (unsigned long long) mr->ibmr.iova,
+				  mr->ibmr.length,
+				  reg_wr(ib_wr)->key,
+				  (unsigned long long) mr->paddr,
+				  mr->npages,
+				  wqe_misc);
+			break;
+		}
 		default:
 			/* error */
 			err = -EINVAL;
@@ -3940,6 +4054,7 @@ struct nes_ib_device *nes_init_ofa_device(struct net_device *netdev)
 	nesibdev->ibdev.bind_mw = nes_bind_mw;
 
 	nesibdev->ibdev.alloc_mr = nes_alloc_mr;
+	nesibdev->ibdev.map_mr_sg = nes_map_mr_sg;
 	nesibdev->ibdev.alloc_fast_reg_page_list = nes_alloc_fast_reg_page_list;
 	nesibdev->ibdev.free_fast_reg_page_list = nes_free_fast_reg_page_list;
 
diff --git a/drivers/infiniband/hw/nes/nes_verbs.h b/drivers/infiniband/hw/nes/nes_verbs.h
index 309b31c31ae1..a204b677af22 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.h
+++ b/drivers/infiniband/hw/nes/nes_verbs.h
@@ -79,6 +79,10 @@ struct nes_mr {
 	u16               pbls_used;
 	u8                mode;
 	u8                pbl_4k;
+	__le64            *pages;
+	dma_addr_t        paddr;
+	u32               max_pages;
+	u32		  npages;
 };
 
 struct nes_hw_pb {
-- 
1.8.4.3

