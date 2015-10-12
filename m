Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35479 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752651AbbJLPab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 11:30:31 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 18/26] IB/srp: Dont allocate a page vector when using fast_reg
Date: Mon, 12 Oct 2015 18:29:31 +0300
Message-Id: <1444663779-1522-19-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
References: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new fast registration API does not reuqire a page vector
so we can't avoid allocating it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Bart Van Assche <bart.vanassche@sandisk.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index d4a5a9b86390..d00f819c09b0 100644
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

