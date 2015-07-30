Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52671 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751296AbbG3HdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:13 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 03/15] IB/iser: Convert to ib_alloc_mr
Date: Thu, 30 Jul 2015 10:32:36 +0300
Message-Id: <1438241568-3685-4-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/iser/iser_verbs.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 9bef5a7..0a7ceb9 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -299,8 +299,8 @@ iser_alloc_pi_ctx(struct ib_device *ib_device, struct ib_pd *pd,
 		goto prot_frpl_failure;
 	}
 
-	pi_ctx->prot_mr = ib_alloc_fast_reg_mr(pd,
-					ISCSI_ISER_SG_TABLESIZE + 1);
+	pi_ctx->prot_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
+				      ISCSI_ISER_SG_TABLESIZE + 1);
 	if (IS_ERR(pi_ctx->prot_mr)) {
 		ret = PTR_ERR(pi_ctx->prot_mr);
 		goto prot_mr_failure;
@@ -351,7 +351,8 @@ iser_create_fastreg_desc(struct ib_device *ib_device, struct ib_pd *pd,
 		return PTR_ERR(desc->data_frpl);
 	}
 
-	desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE + 1);
+	desc->data_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
+				    ISCSI_ISER_SG_TABLESIZE + 1);
 	if (IS_ERR(desc->data_mr)) {
 		ret = PTR_ERR(desc->data_mr);
 		iser_err("Failed to allocate ib_fast_reg_mr err=%d\n", ret);
-- 
1.8.4.3

