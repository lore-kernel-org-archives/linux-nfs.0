Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52708 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752687AbbG3HdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:25 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 05/15] IB/srp: Convert to ib_alloc_mr
Date: Thu, 30 Jul 2015 10:32:38 +0300
Message-Id: <1438241568-3685-6-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index a800307..4cc2cd4 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -378,7 +378,8 @@ static struct srp_fr_pool *srp_create_fr_pool(struct ib_device *device,
 	INIT_LIST_HEAD(&pool->free_list);
 
 	for (i = 0, d = &pool->desc[0]; i < pool->size; i++, d++) {
-		mr = ib_alloc_fast_reg_mr(pd, max_page_list_len);
+		mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
+				 max_page_list_len);
 		if (IS_ERR(mr)) {
 			ret = PTR_ERR(mr);
 			goto destroy_pool;
-- 
1.8.4.3

