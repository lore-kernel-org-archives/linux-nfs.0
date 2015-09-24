Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41740 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755635AbbIXRfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:35:39 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 10/26] IB/iser: Port to new fast registration API
Date: Thu, 24 Sep 2015 20:34:38 +0300
Message-Id: <1443116094-7969-11-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove fastreg page list allocation as the page vector
is now private to the provider. Instead of constructing
the page list and fast_req work request, call ib_map_mr_sg
and construct ib_reg_wr.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/ulp/iser/iscsi_iser.h  |  8 ++---
 drivers/infiniband/ulp/iser/iser_memory.c | 54 ++++++++++++++-----------------
 drivers/infiniband/ulp/iser/iser_verbs.c  | 16 +--------
 3 files changed, 27 insertions(+), 51 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iscsi_iser.h b/drivers/infiniband/ulp/iser/iscsi_iser.h
index 2484bee993ec..271aa71e827c 100644
--- a/drivers/infiniband/ulp/iser/iscsi_iser.h
+++ b/drivers/infiniband/ulp/iser/iscsi_iser.h
@@ -297,7 +297,7 @@ struct iser_tx_desc {
 	u8                           wr_idx;
 	union iser_wr {
 		struct ib_send_wr		send;
-		struct ib_fast_reg_wr		fast_reg;
+		struct ib_reg_wr		fast_reg;
 		struct ib_sig_handover_wr	sig;
 	} wrs[ISER_MAX_WRS];
 	struct iser_mem_reg          data_reg;
@@ -412,7 +412,6 @@ struct iser_device {
  *
  * @mr:         memory region
  * @fmr_pool:   pool of fmrs
- * @frpl:       fast reg page list used by frwrs
  * @page_vec:   fast reg page list used by fmr pool
  * @mr_valid:   is mr valid indicator
  */
@@ -421,10 +420,7 @@ struct iser_reg_resources {
 		struct ib_mr             *mr;
 		struct ib_fmr_pool       *fmr_pool;
 	};
-	union {
-		struct ib_fast_reg_page_list     *frpl;
-		struct iser_page_vec             *page_vec;
-	};
+	struct iser_page_vec             *page_vec;
 	u8				  mr_valid:1;
 };
 
diff --git a/drivers/infiniband/ulp/iser/iser_memory.c b/drivers/infiniband/ulp/iser/iser_memory.c
index b29fda3e8e74..ea765fb9664d 100644
--- a/drivers/infiniband/ulp/iser/iser_memory.c
+++ b/drivers/infiniband/ulp/iser/iser_memory.c
@@ -472,7 +472,7 @@ iser_reg_sig_mr(struct iscsi_iser_task *iser_task,
 	sig_reg->sge.addr = 0;
 	sig_reg->sge.length = scsi_transfer_length(iser_task->sc);
 
-	iser_dbg("sig reg: lkey: 0x%x, rkey: 0x%x, addr: 0x%llx, length: %u\n",
+	iser_dbg("lkey=0x%x rkey=0x%x addr=0x%llx length=%u\n",
 		 sig_reg->sge.lkey, sig_reg->rkey, sig_reg->sge.addr,
 		 sig_reg->sge.length);
 err:
@@ -484,47 +484,41 @@ static int iser_fast_reg_mr(struct iscsi_iser_task *iser_task,
 			    struct iser_reg_resources *rsc,
 			    struct iser_mem_reg *reg)
 {
-	struct ib_conn *ib_conn = &iser_task->iser_conn->ib_conn;
-	struct iser_device *device = ib_conn->device;
-	struct ib_mr *mr = rsc->mr;
-	struct ib_fast_reg_page_list *frpl = rsc->frpl;
 	struct iser_tx_desc *tx_desc = &iser_task->desc;
-	struct ib_fast_reg_wr *wr;
-	int offset, size, plen;
-
-	plen = iser_sg_to_page_vec(mem, device->ib_device, frpl->page_list,
-				   &offset, &size);
-	if (plen * SIZE_4K < size) {
-		iser_err("fast reg page_list too short to hold this SG\n");
-		return -EINVAL;
-	}
+	struct ib_mr *mr = rsc->mr;
+	struct ib_reg_wr *wr;
+	int n;
 
 	if (!rsc->mr_valid)
 		iser_inv_rkey(iser_tx_next_wr(tx_desc), mr);
 
-	wr = fast_reg_wr(iser_tx_next_wr(tx_desc));
-	wr->wr.opcode = IB_WR_FAST_REG_MR;
+	n = ib_map_mr_sg(mr, mem->sg, mem->size, SIZE_4K);
+	if (unlikely(n != mem->size)) {
+		iser_err("failed to map sg (%d/%d)\n",
+			 n, mem->size);
+		return n < 0 ? n : -EINVAL;
+	}
+
+	wr = reg_wr(iser_tx_next_wr(tx_desc));
+	wr->wr.opcode = IB_WR_REG_MR;
 	wr->wr.wr_id = ISER_FASTREG_LI_WRID;
 	wr->wr.send_flags = 0;
-	wr->iova_start = frpl->page_list[0] + offset;
-	wr->page_list = frpl;
-	wr->page_list_len = plen;
-	wr->page_shift = SHIFT_4K;
-	wr->length = size;
-	wr->rkey = mr->rkey;
-	wr->access_flags = (IB_ACCESS_LOCAL_WRITE  |
-			    IB_ACCESS_REMOTE_WRITE |
-			    IB_ACCESS_REMOTE_READ);
+	wr->wr.num_sge = 0;
+	wr->mr = mr;
+	wr->key = mr->rkey;
+	wr->access = IB_ACCESS_LOCAL_WRITE  |
+		     IB_ACCESS_REMOTE_WRITE |
+		     IB_ACCESS_REMOTE_READ;
+
 	rsc->mr_valid = 0;
 
 	reg->sge.lkey = mr->lkey;
 	reg->rkey = mr->rkey;
-	reg->sge.addr = frpl->page_list[0] + offset;
-	reg->sge.length = size;
+	reg->sge.addr = mr->iova;
+	reg->sge.length = mr->length;
 
-	iser_dbg("fast reg: lkey=0x%x, rkey=0x%x, addr=0x%llx,"
-		 " length=0x%x\n", reg->sge.lkey, reg->rkey,
-		 reg->sge.addr, reg->sge.length);
+	iser_dbg("lkey=0x%x rkey=0x%x addr=0x%llx length=0x%x\n",
+		 reg->sge.lkey, reg->rkey, reg->sge.addr, reg->sge.length);
 
 	return 0;
 }
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index b26022e30af1..a66b9dea96d8 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -293,35 +293,21 @@ iser_alloc_reg_res(struct ib_device *ib_device,
 {
 	int ret;
 
-	res->frpl = ib_alloc_fast_reg_page_list(ib_device, size);
-	if (IS_ERR(res->frpl)) {
-		ret = PTR_ERR(res->frpl);
-		iser_err("Failed to allocate ib_fast_reg_page_list err=%d\n",
-			 ret);
-		return PTR_ERR(res->frpl);
-	}
-
 	res->mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, size);
 	if (IS_ERR(res->mr)) {
 		ret = PTR_ERR(res->mr);
 		iser_err("Failed to allocate ib_fast_reg_mr err=%d\n", ret);
-		goto fast_reg_mr_failure;
+		return ret;
 	}
 	res->mr_valid = 1;
 
 	return 0;
-
-fast_reg_mr_failure:
-	ib_free_fast_reg_page_list(res->frpl);
-
-	return ret;
 }
 
 static void
 iser_free_reg_res(struct iser_reg_resources *rsc)
 {
 	ib_dereg_mr(rsc->mr);
-	ib_free_fast_reg_page_list(rsc->frpl);
 }
 
 static int
-- 
1.8.4.3

