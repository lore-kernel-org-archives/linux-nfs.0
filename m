Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41992 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757491AbbIXRh3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:37:29 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 17/26] IB/srp: Dont allocate a page vector when using fast_reg
Date: Thu, 24 Sep 2015 20:35:09 +0300
Message-Id: <1443116118-10730-18-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new fast registration API does not reuqire a page vector
so we can't avoid allocating it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 8b3cbf9b6f40..f5a365395c23 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -840,11 +840,12 @@ static void srp_free_req_data(struct srp_target_port *target,
 
 	for (i = 0; i < target->req_ring_size; ++i) {
 		req = &ch->req_ring[i];
-		if (dev->use_fast_reg)
+		if (dev->use_fast_reg) {
 			kfree(req->fr_list);
-		else
+		} else {
 			kfree(req->fmr_list);
-		kfree(req->map_page);
+			kfree(req->map_page);
+		}
 		if (req->indirect_dma_addr) {
 			ib_dma_unmap_single(ibdev, req->indirect_dma_addr,
 					    target->indirect_size,
@@ -878,14 +879,15 @@ static int srp_alloc_req_data(struct srp_rdma_ch *ch)
 				  GFP_KERNEL);
 		if (!mr_list)
 			goto out;
-		if (srp_dev->use_fast_reg)
+		if (srp_dev->use_fast_reg) {
 			req->fr_list = mr_list;
-		else
+		} else {
 			req->fmr_list = mr_list;
-		req->map_page = kmalloc(srp_dev->max_pages_per_mr *
-					sizeof(void *), GFP_KERNEL);
-		if (!req->map_page)
-			goto out;
+			req->map_page = kmalloc(srp_dev->max_pages_per_mr *
+						sizeof(void *), GFP_KERNEL);
+			if (!req->map_page)
+				goto out;
+		}
 		req->indirect_desc = kmalloc(target->indirect_size, GFP_KERNEL);
 		if (!req->indirect_desc)
 			goto out;
-- 
1.8.4.3

