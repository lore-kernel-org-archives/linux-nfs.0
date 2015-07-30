Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52784 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754643AbbG3Hdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:54 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 15/15] IB/core: Drop ib_alloc_fast_reg_mr
Date: Thu, 30 Jul 2015 10:32:48 +0300
Message-Id: <1438241568-3685-16-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fully replaced by a more generic and suitable
ib_alloc_mr.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/core/verbs.c | 32 +++-----------------------------
 include/rdma/ib_verbs.h         | 11 -----------
 2 files changed, 3 insertions(+), 40 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index 2ac599b..2e5fd89 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1290,36 +1290,10 @@ struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
 {
 	struct ib_mr *mr;
 
-	if (pd->device->alloc_mr) {
-		mr = pd->device->alloc_mr(pd, mr_type, max_num_sg);
-	} else {
-		if (mr_type != IB_MR_TYPE_MEM_REG ||
-		    !pd->device->alloc_fast_reg_mr)
-			return ERR_PTR(-ENOSYS);
-		mr = pd->device->alloc_fast_reg_mr(pd, max_num_sg);
-	}
-
-	if (!IS_ERR(mr)) {
-		mr->device  = pd->device;
-		mr->pd      = pd;
-		mr->uobject = NULL;
-		atomic_inc(&pd->usecnt);
-		atomic_set(&mr->usecnt, 0);
-	}
-
-	return mr;
-}
-EXPORT_SYMBOL(ib_alloc_mr);
-
-struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
-{
-	struct ib_mr *mr;
-
-	if (!pd->device->alloc_fast_reg_mr)
+	if (!pd->device->alloc_mr)
 		return ERR_PTR(-ENOSYS);
 
-	mr = pd->device->alloc_fast_reg_mr(pd, max_page_list_len);
-
+	mr = pd->device->alloc_mr(pd, mr_type, max_num_sg);
 	if (!IS_ERR(mr)) {
 		mr->device  = pd->device;
 		mr->pd      = pd;
@@ -1330,7 +1304,7 @@ struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
 
 	return mr;
 }
-EXPORT_SYMBOL(ib_alloc_fast_reg_mr);
+EXPORT_SYMBOL(ib_alloc_mr);
 
 struct ib_fast_reg_page_list *ib_alloc_fast_reg_page_list(struct ib_device *device,
 							  int max_page_list_len)
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 110044d..a2c328b 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1671,8 +1671,6 @@ struct ib_device {
 	struct ib_mr *		   (*alloc_mr)(struct ib_pd *pd,
 					       enum ib_mr_type mr_type,
 					       u32 max_num_sg);
-	struct ib_mr *		   (*alloc_fast_reg_mr)(struct ib_pd *pd,
-					       int max_page_list_len);
 	struct ib_fast_reg_page_list * (*alloc_fast_reg_page_list)(struct ib_device *device,
 								   int page_list_len);
 	void			   (*free_fast_reg_page_list)(struct ib_fast_reg_page_list *page_list);
@@ -2819,15 +2817,6 @@ struct ib_mr *ib_alloc_mr(struct ib_pd *pd,
 			  u32 max_num_sg);
 
 /**
- * ib_alloc_fast_reg_mr - Allocates memory region usable with the
- *   IB_WR_FAST_REG_MR send work request.
- * @pd: The protection domain associated with the region.
- * @max_page_list_len: requested max physical buffer list length to be
- *   used with fast register work requests for this MR.
- */
-struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len);
-
-/**
  * ib_alloc_fast_reg_page_list - Allocates a page list array
  * @device - ib device pointer.
  * @page_list_len - size of the page list array to be allocated.
-- 
1.8.4.3

