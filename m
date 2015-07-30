Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52712 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753897AbbG3Hd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:28 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 04/15] iser-target: Convert to ib_alloc_mr
Date: Thu, 30 Jul 2015 10:32:37 +0300
Message-Id: <1438241568-3685-5-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/isert/ib_isert.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 23a793a..bf094cc 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -515,7 +515,8 @@ isert_create_pi_ctx(struct fast_reg_descriptor *desc,
 		goto err_pi_ctx;
 	}
 
-	pi_ctx->prot_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE);
+	pi_ctx->prot_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
+				      ISCSI_ISER_SG_TABLESIZE);
 	if (IS_ERR(pi_ctx->prot_mr)) {
 		isert_err("Failed to allocate prot frmr err=%ld\n",
 			  PTR_ERR(pi_ctx->prot_mr));
@@ -562,7 +563,8 @@ isert_create_fr_desc(struct ib_device *ib_device, struct ib_pd *pd,
 		return PTR_ERR(fr_desc->data_frpl);
 	}
 
-	fr_desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE);
+	fr_desc->data_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
+				       ISCSI_ISER_SG_TABLESIZE);
 	if (IS_ERR(fr_desc->data_mr)) {
 		isert_err("Failed to allocate data frmr err=%ld\n",
 			  PTR_ERR(fr_desc->data_mr));
-- 
1.8.4.3

