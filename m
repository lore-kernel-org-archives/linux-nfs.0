Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52754 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754630AbbG3Hdp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:45 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 10/15] ocrdma: Support ib_alloc_mr verb
Date: Thu, 30 Jul 2015 10:32:43 +0300
Message-Id: <1438241568-3685-11-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/hw/ocrdma/ocrdma_main.c  |  2 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c | 11 ++++++++---
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h |  4 +++-
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index d98a707..62086ba 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -294,7 +294,7 @@ static int ocrdma_register_device(struct ocrdma_dev *dev)
 	dev->ibdev.dereg_mr = ocrdma_dereg_mr;
 	dev->ibdev.reg_user_mr = ocrdma_reg_user_mr;
 
-	dev->ibdev.alloc_fast_reg_mr = ocrdma_alloc_frmr;
+	dev->ibdev.alloc_mr = ocrdma_alloc_mr;
 	dev->ibdev.alloc_fast_reg_page_list = ocrdma_alloc_frmr_page_list;
 	dev->ibdev.free_fast_reg_page_list = ocrdma_free_frmr_page_list;
 
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index 5bb61eb..7a5260f 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -2983,21 +2983,26 @@ int ocrdma_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags cq_flags)
 	return 0;
 }
 
-struct ib_mr *ocrdma_alloc_frmr(struct ib_pd *ibpd, int max_page_list_len)
+struct ib_mr *ocrdma_alloc_mr(struct ib_pd *ibpd,
+			      enum ib_mr_type mr_type,
+			      u32 max_num_sg)
 {
 	int status;
 	struct ocrdma_mr *mr;
 	struct ocrdma_pd *pd = get_ocrdma_pd(ibpd);
 	struct ocrdma_dev *dev = get_ocrdma_dev(ibpd->device);
 
-	if (max_page_list_len > dev->attr.max_pages_per_frmr)
+	if (mr_type != IB_MR_TYPE_MEM_REG)
+		return ERR_PTR(-EINVAL);
+
+	if (max_num_sg > dev->attr.max_pages_per_frmr)
 		return ERR_PTR(-EINVAL);
 
 	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
 		return ERR_PTR(-ENOMEM);
 
-	status = ocrdma_get_pbl_info(dev, mr, max_page_list_len);
+	status = ocrdma_get_pbl_info(dev, mr, max_num_sg);
 	if (status)
 		goto pbl_err;
 	mr->hwmr.fr_mr = 1;
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
index b15c608..50d8d47 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.h
@@ -96,7 +96,9 @@ struct ib_mr *ocrdma_reg_kernel_mr(struct ib_pd *,
 				   int num_phys_buf, int acc, u64 *iova_start);
 struct ib_mr *ocrdma_reg_user_mr(struct ib_pd *, u64 start, u64 length,
 				 u64 virt, int acc, struct ib_udata *);
-struct ib_mr *ocrdma_alloc_frmr(struct ib_pd *pd, int max_page_list_len);
+struct ib_mr *ocrdma_alloc_mr(struct ib_pd *pd,
+			      enum ib_mr_type mr_type,
+			      u32 max_num_sg);
 struct ib_fast_reg_page_list *ocrdma_alloc_frmr_page_list(struct ib_device
 							*ibdev,
 							int page_list_len);
-- 
1.8.4.3

