Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52745 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754608AbbG3Hdi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:38 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
Date: Thu, 30 Jul 2015 10:32:44 +0300
Message-Id: <1438241568-3685-12-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |  4 +++-
 drivers/infiniband/hw/cxgb4/mem.c      | 12 +++++++++---
 drivers/infiniband/hw/cxgb4/provider.c |  2 +-
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index cc77844..c7bb38c 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -970,7 +970,9 @@ void c4iw_free_fastreg_pbl(struct ib_fast_reg_page_list *page_list);
 struct ib_fast_reg_page_list *c4iw_alloc_fastreg_pbl(
 					struct ib_device *device,
 					int page_list_len);
-struct ib_mr *c4iw_alloc_fast_reg_mr(struct ib_pd *pd, int pbl_depth);
+struct ib_mr *c4iw_alloc_mr(struct ib_pd *pd,
+			    enum ib_mr_type mr_type,
+			    u32 max_num_sg);
 int c4iw_dealloc_mw(struct ib_mw *mw);
 struct ib_mw *c4iw_alloc_mw(struct ib_pd *pd, enum ib_mw_type type);
 struct ib_mr *c4iw_reg_user_mr(struct ib_pd *pd, u64 start,
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index cff815b..026b91e 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -853,7 +853,9 @@ int c4iw_dealloc_mw(struct ib_mw *mw)
 	return 0;
 }
 
-struct ib_mr *c4iw_alloc_fast_reg_mr(struct ib_pd *pd, int pbl_depth)
+struct ib_mr *c4iw_alloc_mr(struct ib_pd *pd,
+			    enum ib_mr_type mr_type,
+			    u32 max_num_sg)
 {
 	struct c4iw_dev *rhp;
 	struct c4iw_pd *php;
@@ -862,6 +864,10 @@ struct ib_mr *c4iw_alloc_fast_reg_mr(struct ib_pd *pd, int pbl_depth)
 	u32 stag = 0;
 	int ret = 0;
 
+	if (mr_type != IB_MR_TYPE_MEM_REG ||
+	    max_num_sg > t4_max_fr_depth(use_dsgl))
+		return ERR_PTR(-EINVAL);
+
 	php = to_c4iw_pd(pd);
 	rhp = php->rhp;
 	mhp = kzalloc(sizeof(*mhp), GFP_KERNEL);
@@ -871,10 +877,10 @@ struct ib_mr *c4iw_alloc_fast_reg_mr(struct ib_pd *pd, int pbl_depth)
 	}
 
 	mhp->rhp = rhp;
-	ret = alloc_pbl(mhp, pbl_depth);
+	ret = alloc_pbl(mhp, max_num_sg);
 	if (ret)
 		goto err1;
-	mhp->attr.pbl_size = pbl_depth;
+	mhp->attr.pbl_size = max_num_sg;
 	ret = allocate_stag(&rhp->rdev, &stag, php->pdid,
 				 mhp->attr.pbl_size, mhp->attr.pbl_addr);
 	if (ret)
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 6eee3d3..7746113 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -556,7 +556,7 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	dev->ibdev.alloc_mw = c4iw_alloc_mw;
 	dev->ibdev.bind_mw = c4iw_bind_mw;
 	dev->ibdev.dealloc_mw = c4iw_dealloc_mw;
-	dev->ibdev.alloc_fast_reg_mr = c4iw_alloc_fast_reg_mr;
+	dev->ibdev.alloc_mr = c4iw_alloc_mr;
 	dev->ibdev.alloc_fast_reg_page_list = c4iw_alloc_fastreg_pbl;
 	dev->ibdev.free_fast_reg_page_list = c4iw_free_fastreg_pbl;
 	dev->ibdev.attach_mcast = c4iw_multicast_attach;
-- 
1.8.4.3

