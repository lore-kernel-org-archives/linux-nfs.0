Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35199 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753870AbbJHHvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:51:55 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/26] iser-target: Port to new memory registration API
Date: Thu,  8 Oct 2015 10:50:54 +0300
Message-Id: <1444290669-5252-12-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove fastreg page list allocation as the page vector
is now private to the provider. Instead of constructing
the page list and fast_req work request, call ib_map_mr_sg
and construct ib_reg_wr.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/ulp/isert/ib_isert.c | 130 +++++++-------------------------
 drivers/infiniband/ulp/isert/ib_isert.h |   2 -
 2 files changed, 28 insertions(+), 104 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 70d55d381515..7dbae56e576a 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -473,10 +473,8 @@ isert_conn_free_fastreg_pool(struct isert_conn *isert_conn)
 	list_for_each_entry_safe(fr_desc, tmp,
 				 &isert_conn->fr_pool, list) {
 		list_del(&fr_desc->list);
-		ib_free_fast_reg_page_list(fr_desc->data_frpl);
 		ib_dereg_mr(fr_desc->data_mr);
 		if (fr_desc->pi_ctx) {
-			ib_free_fast_reg_page_list(fr_desc->pi_ctx->prot_frpl);
 			ib_dereg_mr(fr_desc->pi_ctx->prot_mr);
 			ib_dereg_mr(fr_desc->pi_ctx->sig_mr);
 			kfree(fr_desc->pi_ctx);
@@ -504,22 +502,13 @@ isert_create_pi_ctx(struct fast_reg_descriptor *desc,
 		return -ENOMEM;
 	}
 
-	pi_ctx->prot_frpl = ib_alloc_fast_reg_page_list(device,
-					    ISCSI_ISER_SG_TABLESIZE);
-	if (IS_ERR(pi_ctx->prot_frpl)) {
-		isert_err("Failed to allocate prot frpl err=%ld\n",
-			  PTR_ERR(pi_ctx->prot_frpl));
-		ret = PTR_ERR(pi_ctx->prot_frpl);
-		goto err_pi_ctx;
-	}
-
 	pi_ctx->prot_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
 				      ISCSI_ISER_SG_TABLESIZE);
 	if (IS_ERR(pi_ctx->prot_mr)) {
 		isert_err("Failed to allocate prot frmr err=%ld\n",
 			  PTR_ERR(pi_ctx->prot_mr));
 		ret = PTR_ERR(pi_ctx->prot_mr);
-		goto err_prot_frpl;
+		goto err_pi_ctx;
 	}
 	desc->ind |= ISERT_PROT_KEY_VALID;
 
@@ -539,8 +528,6 @@ isert_create_pi_ctx(struct fast_reg_descriptor *desc,
 
 err_prot_mr:
 	ib_dereg_mr(pi_ctx->prot_mr);
-err_prot_frpl:
-	ib_free_fast_reg_page_list(pi_ctx->prot_frpl);
 err_pi_ctx:
 	kfree(pi_ctx);
 
@@ -551,34 +538,18 @@ static int
 isert_create_fr_desc(struct ib_device *ib_device, struct ib_pd *pd,
 		     struct fast_reg_descriptor *fr_desc)
 {
-	int ret;
-
-	fr_desc->data_frpl = ib_alloc_fast_reg_page_list(ib_device,
-							 ISCSI_ISER_SG_TABLESIZE);
-	if (IS_ERR(fr_desc->data_frpl)) {
-		isert_err("Failed to allocate data frpl err=%ld\n",
-			  PTR_ERR(fr_desc->data_frpl));
-		return PTR_ERR(fr_desc->data_frpl);
-	}
-
 	fr_desc->data_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG,
 				       ISCSI_ISER_SG_TABLESIZE);
 	if (IS_ERR(fr_desc->data_mr)) {
 		isert_err("Failed to allocate data frmr err=%ld\n",
 			  PTR_ERR(fr_desc->data_mr));
-		ret = PTR_ERR(fr_desc->data_mr);
-		goto err_data_frpl;
+		return PTR_ERR(fr_desc->data_mr);
 	}
 	fr_desc->ind |= ISERT_DATA_KEY_VALID;
 
 	isert_dbg("Created fr_desc %p\n", fr_desc);
 
 	return 0;
-
-err_data_frpl:
-	ib_free_fast_reg_page_list(fr_desc->data_frpl);
-
-	return ret;
 }
 
 static int
@@ -2535,45 +2506,6 @@ unmap_cmd:
 	return ret;
 }
 
-static int
-isert_map_fr_pagelist(struct ib_device *ib_dev,
-		      struct scatterlist *sg_start, int sg_nents, u64 *fr_pl)
-{
-	u64 start_addr, end_addr, page, chunk_start = 0;
-	struct scatterlist *tmp_sg;
-	int i = 0, new_chunk, last_ent, n_pages;
-
-	n_pages = 0;
-	new_chunk = 1;
-	last_ent = sg_nents - 1;
-	for_each_sg(sg_start, tmp_sg, sg_nents, i) {
-		start_addr = ib_sg_dma_address(ib_dev, tmp_sg);
-		if (new_chunk)
-			chunk_start = start_addr;
-		end_addr = start_addr + ib_sg_dma_len(ib_dev, tmp_sg);
-
-		isert_dbg("SGL[%d] dma_addr: 0x%llx len: %u\n",
-			  i, (unsigned long long)tmp_sg->dma_address,
-			  tmp_sg->length);
-
-		if ((end_addr & ~PAGE_MASK) && i < last_ent) {
-			new_chunk = 0;
-			continue;
-		}
-		new_chunk = 1;
-
-		page = chunk_start & PAGE_MASK;
-		do {
-			fr_pl[n_pages++] = page;
-			isert_dbg("Mapped page_list[%d] page_addr: 0x%llx\n",
-				  n_pages - 1, page);
-			page += PAGE_SIZE;
-		} while (page < end_addr);
-	}
-
-	return n_pages;
-}
-
 static inline void
 isert_inv_rkey(struct ib_send_wr *inv_wr, struct ib_mr *mr)
 {
@@ -2599,11 +2531,9 @@ isert_fast_reg_mr(struct isert_conn *isert_conn,
 	struct isert_device *device = isert_conn->device;
 	struct ib_device *ib_dev = device->ib_device;
 	struct ib_mr *mr;
-	struct ib_fast_reg_page_list *frpl;
-	struct ib_fast_reg_wr fr_wr;
+	struct ib_reg_wr reg_wr;
 	struct ib_send_wr inv_wr, *bad_wr, *wr = NULL;
-	int ret, pagelist_len;
-	u32 page_off;
+	int ret, n;
 
 	if (mem->dma_nents == 1) {
 		sge->lkey = device->pd->local_dma_lkey;
@@ -2614,45 +2544,41 @@ isert_fast_reg_mr(struct isert_conn *isert_conn,
 		return 0;
 	}
 
-	if (ind == ISERT_DATA_KEY_VALID) {
+	if (ind == ISERT_DATA_KEY_VALID)
 		/* Registering data buffer */
 		mr = fr_desc->data_mr;
-		frpl = fr_desc->data_frpl;
-	} else {
+	else
 		/* Registering protection buffer */
 		mr = fr_desc->pi_ctx->prot_mr;
-		frpl = fr_desc->pi_ctx->prot_frpl;
-	}
-
-	page_off = mem->offset % PAGE_SIZE;
-
-	isert_dbg("Use fr_desc %p sg_nents %d offset %u\n",
-		  fr_desc, mem->nents, mem->offset);
-
-	pagelist_len = isert_map_fr_pagelist(ib_dev, mem->sg, mem->nents,
-					     &frpl->page_list[0]);
 
 	if (!(fr_desc->ind & ind)) {
 		isert_inv_rkey(&inv_wr, mr);
 		wr = &inv_wr;
 	}
 
-	/* Prepare FASTREG WR */
-	memset(&fr_wr, 0, sizeof(fr_wr));
-	fr_wr.wr.wr_id = ISER_FASTREG_LI_WRID;
-	fr_wr.wr.opcode = IB_WR_FAST_REG_MR;
-	fr_wr.iova_start = frpl->page_list[0] + page_off;
-	fr_wr.page_list = frpl;
-	fr_wr.page_list_len = pagelist_len;
-	fr_wr.page_shift = PAGE_SHIFT;
-	fr_wr.length = mem->len;
-	fr_wr.rkey = mr->rkey;
-	fr_wr.access_flags = IB_ACCESS_LOCAL_WRITE;
+	n = ib_map_mr_sg(mr, mem->sg, mem->nents, PAGE_SIZE);
+	if (unlikely(n != mem->nents)) {
+		isert_err("failed to map mr sg (%d/%d)\n",
+			 n, mem->nents);
+		return n < 0 ? n : -EINVAL;
+	}
+
+	isert_dbg("Use fr_desc %p sg_nents %d offset %u\n",
+		  fr_desc, mem->nents, mem->offset);
+
+	reg_wr.wr.next = NULL;
+	reg_wr.wr.opcode = IB_WR_REG_MR;
+	reg_wr.wr.wr_id = ISER_FASTREG_LI_WRID;
+	reg_wr.wr.send_flags = 0;
+	reg_wr.wr.num_sge = 0;
+	reg_wr.mr = mr;
+	reg_wr.key = mr->lkey;
+	reg_wr.access = IB_ACCESS_LOCAL_WRITE;
 
 	if (!wr)
-		wr = &fr_wr.wr;
+		wr = &reg_wr.wr;
 	else
-		wr->next = &fr_wr.wr;
+		wr->next = &reg_wr.wr;
 
 	ret = ib_post_send(isert_conn->qp, wr, &bad_wr);
 	if (ret) {
@@ -2662,8 +2588,8 @@ isert_fast_reg_mr(struct isert_conn *isert_conn,
 	fr_desc->ind &= ~ind;
 
 	sge->lkey = mr->lkey;
-	sge->addr = frpl->page_list[0] + page_off;
-	sge->length = mem->len;
+	sge->addr = mr->iova;
+	sge->length = mr->length;
 
 	isert_dbg("sge: addr: 0x%llx  length: %u lkey: %x\n",
 		  sge->addr, sge->length, sge->lkey);
diff --git a/drivers/infiniband/ulp/isert/ib_isert.h b/drivers/infiniband/ulp/isert/ib_isert.h
index 360461819452..3d7fbc47c343 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.h
+++ b/drivers/infiniband/ulp/isert/ib_isert.h
@@ -84,14 +84,12 @@ enum isert_indicator {
 
 struct pi_context {
 	struct ib_mr		       *prot_mr;
-	struct ib_fast_reg_page_list   *prot_frpl;
 	struct ib_mr		       *sig_mr;
 };
 
 struct fast_reg_descriptor {
 	struct list_head		list;
 	struct ib_mr		       *data_mr;
-	struct ib_fast_reg_page_list   *data_frpl;
 	u8				ind;
 	struct pi_context	       *pi_ctx;
 };
-- 
1.8.4.3

