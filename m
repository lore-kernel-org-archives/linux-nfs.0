Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51037 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752786AbbGEXWH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jul 2015 19:22:07 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V3 2/5] RDMA/iser: Use transport independent MR allocation
To: dledford@redhat.com
Cc: sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Date: Sun, 05 Jul 2015 18:22:06 -0500
Message-ID: <20150705232205.12029.45386.stgit@build2.ogc.int>
In-Reply-To: <20150705231831.12029.80307.stgit@build2.ogc.int>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use rdma_get_dma_mr() to allocate the DMA MR.

Use rdma_fast_reg_access_flags() to set the access_flags for fast
register work requests.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/iser/iser_memory.c |    7 +++----
 drivers/infiniband/ulp/iser/iser_verbs.c  |    7 ++++---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iser_memory.c b/drivers/infiniband/ulp/iser/iser_memory.c
index f0cdc96..3a19483 100644
--- a/drivers/infiniband/ulp/iser/iser_memory.c
+++ b/drivers/infiniband/ulp/iser/iser_memory.c
@@ -757,10 +757,9 @@ static int iser_fast_reg_mr(struct iscsi_iser_task *iser_task,
 	fastreg_wr.wr.fast_reg.page_shift = SHIFT_4K;
 	fastreg_wr.wr.fast_reg.length = size;
 	fastreg_wr.wr.fast_reg.rkey = mr->rkey;
-	fastreg_wr.wr.fast_reg.access_flags = (IB_ACCESS_LOCAL_WRITE  |
-					       IB_ACCESS_REMOTE_WRITE |
-					       IB_ACCESS_REMOTE_READ);
-
+	fastreg_wr.wr.fast_reg.access_flags =
+		rdma_fast_reg_access_flags(device->pd, RDMA_MRR_WRITE_DEST |
+					   RDMA_MRR_READ_SOURCE, 0);
 	if (!wr)
 		wr = &fastreg_wr;
 	else
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 5c9f565..4da368c 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -80,6 +80,7 @@ static int iser_create_device_ib_res(struct iser_device *device)
 {
 	struct ib_device_attr *dev_attr = &device->dev_attr;
 	int ret, i, max_cqe;
+	int mr_roles;
 
 	ret = ib_query_device(device->ib_device, dev_attr);
 	if (ret) {
@@ -149,9 +150,9 @@ static int iser_create_device_ib_res(struct iser_device *device)
 			     (unsigned long)comp);
 	}
 
-	device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE |
-				   IB_ACCESS_REMOTE_WRITE |
-				   IB_ACCESS_REMOTE_READ);
+	mr_roles = RDMA_MRR_SEND | RDMA_MRR_RECV | RDMA_MRR_WRITE_DEST |
+		   RDMA_MRR_READ_SOURCE;
+	device->mr = rdma_get_dma_mr(device->pd, mr_roles, 0);
 	if (IS_ERR(device->mr))
 		goto dma_mr_err;
 

