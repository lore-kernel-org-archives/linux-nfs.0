Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52789 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754669AbbG3HeA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:34:00 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 13/15] nes: Support ib_alloc_mr verb
Date: Thu, 30 Jul 2015 10:32:46 +0300
Message-Id: <1438241568-3685-14-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/hw/nes/nes_verbs.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index fbc43e5..44cb513 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -375,9 +375,11 @@ static int alloc_fast_reg_mr(struct nes_device *nesdev, struct nes_pd *nespd,
 }
 
 /*
- * nes_alloc_fast_reg_mr
+ * nes_alloc_mr
  */
-static struct ib_mr *nes_alloc_fast_reg_mr(struct ib_pd *ibpd, int max_page_list_len)
+static struct ib_mr *nes_alloc_mr(struct ib_pd *ibpd,
+				  enum ib_mr_type mr_type,
+				  u32 max_num_sg)
 {
 	struct nes_pd *nespd = to_nespd(ibpd);
 	struct nes_vnic *nesvnic = to_nesvnic(ibpd->device);
@@ -393,11 +395,18 @@ static struct ib_mr *nes_alloc_fast_reg_mr(struct ib_pd *ibpd, int max_page_list
 	u32 stag;
 	int ret;
 	struct ib_mr *ibmr;
+
+	if (mr_type != IB_MR_TYPE_MEM_REG)
+		return ERR_PTR(-EINVAL);
+
+	if (max_num_sg > (NES_4K_PBL_CHUNK_SIZE / sizeof(u64)))
+		return ERR_PTR(-E2BIG);
+
 /*
  * Note:  Set to always use a fixed length single page entry PBL.  This is to allow
  *	 for the fast_reg_mr operation to always know the size of the PBL.
  */
-	if (max_page_list_len > (NES_4K_PBL_CHUNK_SIZE / sizeof(u64)))
+	if (max_num_sg > (NES_4K_PBL_CHUNK_SIZE / sizeof(u64)))
 		return ERR_PTR(-E2BIG);
 
 	get_random_bytes(&next_stag_index, sizeof(next_stag_index));
@@ -424,7 +433,7 @@ static struct ib_mr *nes_alloc_fast_reg_mr(struct ib_pd *ibpd, int max_page_list
 	nes_debug(NES_DBG_MR, "Allocating STag 0x%08X index = 0x%08X\n",
 		  stag, stag_index);
 
-	ret = alloc_fast_reg_mr(nesdev, nespd, stag, max_page_list_len);
+	ret = alloc_fast_reg_mr(nesdev, nespd, stag, max_num_sg);
 
 	if (ret == 0) {
 		nesmr->ibmr.rkey = stag;
@@ -3929,7 +3938,7 @@ struct nes_ib_device *nes_init_ofa_device(struct net_device *netdev)
 	nesibdev->ibdev.dealloc_mw = nes_dealloc_mw;
 	nesibdev->ibdev.bind_mw = nes_bind_mw;
 
-	nesibdev->ibdev.alloc_fast_reg_mr = nes_alloc_fast_reg_mr;
+	nesibdev->ibdev.alloc_mr = nes_alloc_mr;
 	nesibdev->ibdev.alloc_fast_reg_page_list = nes_alloc_fast_reg_page_list;
 	nesibdev->ibdev.free_fast_reg_page_list = nes_free_fast_reg_page_list;
 
-- 
1.8.4.3

