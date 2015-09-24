Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41800 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756816AbbIXRfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:35:45 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 15/26] IB/srp: Split srp_map_sg
Date: Thu, 24 Sep 2015 20:34:43 +0300
Message-Id: <1443116094-7969-16-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a perparation patch for the new registration API
conversion. It splits srp_map_sg per registration strategy
(srp_map_sg[fmr|fr|dma]. On its own it adds some code duplication,
but it makes the API switch easier to comprehend.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 156 ++++++++++++++++++++++++------------
 1 file changed, 105 insertions(+), 51 deletions(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index f8b9c18da03d..74748d1075fc 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -1286,6 +1286,17 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
 	if (WARN_ON_ONCE(state->fmr.next >= state->fmr.end))
 		return -ENOMEM;
 
+	WARN_ON_ONCE(!dev->use_fmr);
+
+	if (state->npages == 0)
+		return 0;
+
+	if (state->npages == 1 && target->global_mr) {
+		srp_map_desc(state, state->base_dma_addr, state->dma_len,
+			     target->global_mr->rkey);
+		return 0;
+	}
+
 	fmr = ib_fmr_pool_map_phys(ch->fmr_pool, state->pages,
 				   state->npages, io_addr);
 	if (IS_ERR(fmr))
@@ -1297,6 +1308,9 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
 	srp_map_desc(state, state->base_dma_addr & ~dev->mr_page_mask,
 		     state->dma_len, fmr->fmr->rkey);
 
+	state->npages = 0;
+	state->dma_len = 0;
+
 	return 0;
 }
 
@@ -1309,10 +1323,23 @@ static int srp_map_finish_fr(struct srp_map_state *state,
 	struct ib_fast_reg_wr wr;
 	struct srp_fr_desc *desc;
 	u32 rkey;
+	int err;
+
 
 	if (WARN_ON_ONCE(state->fr.next >= state->fr.end))
 		return -ENOMEM;
 
+	WARN_ON_ONCE(!dev->use_fast_reg);
+
+	if (state->npages == 0)
+		return 0;
+
+	if (state->npages == 1 && target->global_mr) {
+		srp_map_desc(state, state->base_dma_addr, state->dma_len,
+			     target->global_mr->rkey);
+		return 0;
+	}
+
 	desc = srp_fr_pool_get(ch->fr_pool);
 	if (!desc)
 		return -ENOMEM;
@@ -1342,7 +1369,14 @@ static int srp_map_finish_fr(struct srp_map_state *state,
 	srp_map_desc(state, state->base_dma_addr, state->dma_len,
 		     desc->mr->rkey);
 
-	return ib_post_send(ch->qp, &wr.wr, &bad_wr);
+	err = ib_post_send(ch->qp, &wr.wr, &bad_wr);
+	if (err)
+		return err;
+
+	state->npages = 0;
+	state->dma_len = 0;
+
+	return 0;
 }
 
 static int srp_finish_mapping(struct srp_map_state *state,
@@ -1350,26 +1384,9 @@ static int srp_finish_mapping(struct srp_map_state *state,
 {
 	struct srp_target_port *target = ch->target;
 	struct srp_device *dev = target->srp_host->srp_dev;
-	int ret = 0;
-
-	WARN_ON_ONCE(!dev->use_fast_reg && !dev->use_fmr);
-
-	if (state->npages == 0)
-		return 0;
 
-	if (state->npages == 1 && target->global_mr)
-		srp_map_desc(state, state->base_dma_addr, state->dma_len,
-			     target->global_mr->rkey);
-	else
-		ret = dev->use_fast_reg ? srp_map_finish_fr(state, ch) :
-			srp_map_finish_fmr(state, ch);
-
-	if (ret == 0) {
-		state->npages = 0;
-		state->dma_len = 0;
-	}
-
-	return ret;
+	return dev->use_fast_reg ? srp_map_finish_fr(state, ch) :
+				   srp_map_finish_fmr(state, ch);
 }
 
 static int srp_map_sg_entry(struct srp_map_state *state,
@@ -1415,47 +1432,79 @@ static int srp_map_sg_entry(struct srp_map_state *state,
 	return ret;
 }
 
-static int srp_map_sg(struct srp_map_state *state, struct srp_rdma_ch *ch,
-		      struct srp_request *req, struct scatterlist *scat,
-		      int count)
+static int srp_map_sg_fmr(struct srp_map_state *state, struct srp_rdma_ch *ch,
+			  struct srp_request *req, struct scatterlist *scat,
+			  int count)
 {
-	struct srp_target_port *target = ch->target;
-	struct srp_device *dev = target->srp_host->srp_dev;
 	struct scatterlist *sg;
 	int i, ret;
 
-	state->desc	= req->indirect_desc;
-	state->pages	= req->map_page;
-	if (dev->use_fast_reg) {
-		state->fr.next = req->fr_list;
-		state->fr.end = req->fr_list + target->cmd_sg_cnt;
-	} else if (dev->use_fmr) {
-		state->fmr.next = req->fmr_list;
-		state->fmr.end = req->fmr_list + target->cmd_sg_cnt;
+	state->desc = req->indirect_desc;
+	state->pages = req->map_page;
+	state->fmr.next = req->fmr_list;
+	state->fmr.end = req->fmr_list + ch->target->cmd_sg_cnt;
+
+	for_each_sg(scat, sg, count, i) {
+		ret = srp_map_sg_entry(state, ch, sg, i);
+		if (ret)
+			return ret;
 	}
 
-	if (dev->use_fast_reg || dev->use_fmr) {
-		for_each_sg(scat, sg, count, i) {
-			ret = srp_map_sg_entry(state, ch, sg, i);
-			if (ret)
-				goto out;
-		}
-		ret = srp_finish_mapping(state, ch);
+	ret = srp_finish_mapping(state, ch);
+	if (ret)
+		return ret;
+
+	req->nmdesc = state->nmdesc;
+
+	return 0;
+}
+
+static int srp_map_sg_fr(struct srp_map_state *state, struct srp_rdma_ch *ch,
+			 struct srp_request *req, struct scatterlist *scat,
+			 int count)
+{
+	struct scatterlist *sg;
+	int i, ret;
+
+	state->desc = req->indirect_desc;
+	state->pages = req->map_page;
+	state->fmr.next = req->fmr_list;
+	state->fmr.end = req->fmr_list + ch->target->cmd_sg_cnt;
+
+	for_each_sg(scat, sg, count, i) {
+		ret = srp_map_sg_entry(state, ch, sg, i);
 		if (ret)
-			goto out;
-	} else {
-		for_each_sg(scat, sg, count, i) {
-			srp_map_desc(state, ib_sg_dma_address(dev->dev, sg),
-				     ib_sg_dma_len(dev->dev, sg),
-				     target->global_mr->rkey);
-		}
+			return ret;
+	}
+
+	ret = srp_finish_mapping(state, ch);
+	if (ret)
+		return ret;
+
+	req->nmdesc = state->nmdesc;
+
+	return 0;
+}
+
+static int srp_map_sg_dma(struct srp_map_state *state, struct srp_rdma_ch *ch,
+			  struct srp_request *req, struct scatterlist *scat,
+			  int count)
+{
+	struct srp_target_port *target = ch->target;
+	struct srp_device *dev = target->srp_host->srp_dev;
+	struct scatterlist *sg;
+	int i;
+
+	state->desc = req->indirect_desc;
+	for_each_sg(scat, sg, count, i) {
+		srp_map_desc(state, ib_sg_dma_address(dev->dev, sg),
+			     ib_sg_dma_len(dev->dev, sg),
+			     target->global_mr->rkey);
 	}
 
 	req->nmdesc = state->nmdesc;
-	ret = 0;
 
-out:
-	return ret;
+	return 0;
 }
 
 /*
@@ -1563,7 +1612,12 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 				   target->indirect_size, DMA_TO_DEVICE);
 
 	memset(&state, 0, sizeof(state));
-	srp_map_sg(&state, ch, req, scat, count);
+	if (dev->use_fast_reg)
+		srp_map_sg_fr(&state, ch, req, scat, count);
+	else if (dev->use_fmr)
+		srp_map_sg_fmr(&state, ch, req, scat, count);
+	else
+		srp_map_sg_dma(&state, ch, req, scat, count);
 
 	/* We've mapped the request, now pull as much of the indirect
 	 * descriptor table as we can into the command buffer. If this
-- 
1.8.4.3

