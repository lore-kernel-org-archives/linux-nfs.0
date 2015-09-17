Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49359 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753150AbbIQJn0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 05:43:26 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v1 15/24] IB/srp: Convert to new memory registration API
Date: Thu, 17 Sep 2015 12:42:18 +0300
Message-Id: <1442482947-27785-16-git-send-email-sagig@mellanox.com>
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since SRP supports both FMRs and FRWR, the new API conversion
includes splitting the sg list mapping routines in srp_map_data to
srp_map_sg_fr that works with the new memory registration API,
srp_map_sg_fmr which constructs a page vector and calls
ib_fmr_pool_map_phys, and srp_map_sg_dma which is used only
if no FRWR nor FMR are supported (which I'm not sure is a valid
use-case anymore).

The srp protocol is able to pass to the target multiple descriptors
for remote access, so it basically calls registers muleitple sg list
partials the entire sg list is mapped and registered (each time maps
a prefix of an sg list).

Note that now the per request page vector is allocated only when FMR
mode is used as it is not needed for the new registration API.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 248 +++++++++++++++++++++---------------
 drivers/infiniband/ulp/srp/ib_srp.h |  11 +-
 2 files changed, 156 insertions(+), 103 deletions(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index f8b9c18da03d..35cddbb120ea 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -340,8 +340,6 @@ static void srp_destroy_fr_pool(struct srp_fr_pool *pool)
 		return;
 
 	for (i = 0, d = &pool->desc[0]; i < pool->size; i++, d++) {
-		if (d->frpl)
-			ib_free_fast_reg_page_list(d->frpl);
 		if (d->mr)
 			ib_dereg_mr(d->mr);
 	}
@@ -362,7 +360,6 @@ static struct srp_fr_pool *srp_create_fr_pool(struct ib_device *device,
 	struct srp_fr_pool *pool;
 	struct srp_fr_desc *d;
 	struct ib_mr *mr;
-	struct ib_fast_reg_page_list *frpl;
 	int i, ret = -EINVAL;
 
 	if (pool_size <= 0)
@@ -385,12 +382,6 @@ static struct srp_fr_pool *srp_create_fr_pool(struct ib_device *device,
 			goto destroy_pool;
 		}
 		d->mr = mr;
-		frpl = ib_alloc_fast_reg_page_list(device, max_page_list_len);
-		if (IS_ERR(frpl)) {
-			ret = PTR_ERR(frpl);
-			goto destroy_pool;
-		}
-		d->frpl = frpl;
 		list_add_tail(&d->entry, &pool->free_list);
 	}
 
@@ -887,14 +878,16 @@ static int srp_alloc_req_data(struct srp_rdma_ch *ch)
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
+
 		req->indirect_desc = kmalloc(target->indirect_size, GFP_KERNEL);
 		if (!req->indirect_desc)
 			goto out;
@@ -1283,6 +1276,15 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
 	struct ib_pool_fmr *fmr;
 	u64 io_addr = 0;
 
+	if (state->npages == 0)
+		return 0;
+
+	if (state->npages == 1 && target->global_mr) {
+		srp_map_desc(state, state->base_dma_addr, state->dma_len,
+			     target->global_mr->rkey);
+		return 0;
+	}
+
 	if (WARN_ON_ONCE(state->fmr.next >= state->fmr.end))
 		return -ENOMEM;
 
@@ -1297,6 +1299,9 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
 	srp_map_desc(state, state->base_dma_addr & ~dev->mr_page_mask,
 		     state->dma_len, fmr->fmr->rkey);
 
+	state->npages = 0;
+	state->dma_len = 0;
+
 	return 0;
 }
 
@@ -1306,9 +1311,17 @@ static int srp_map_finish_fr(struct srp_map_state *state,
 	struct srp_target_port *target = ch->target;
 	struct srp_device *dev = target->srp_host->srp_dev;
 	struct ib_send_wr *bad_wr;
-	struct ib_fast_reg_wr wr;
+	struct ib_reg_wr wr;
 	struct srp_fr_desc *desc;
 	u32 rkey;
+	int n, err;
+
+	if (state->sg_nents == 1 && target->global_mr) {
+		srp_map_desc(state, sg_dma_address(state->sg),
+			     sg_dma_len(state->sg),
+			     target->global_mr->rkey);
+		return 1;
+	}
 
 	if (WARN_ON_ONCE(state->fr.next >= state->fr.end))
 		return -ENOMEM;
@@ -1320,56 +1333,32 @@ static int srp_map_finish_fr(struct srp_map_state *state,
 	rkey = ib_inc_rkey(desc->mr->rkey);
 	ib_update_fast_reg_key(desc->mr, rkey);
 
-	memcpy(desc->frpl->page_list, state->pages,
-	       sizeof(state->pages[0]) * state->npages);
+	n = ib_map_mr_sg(desc->mr, state->sg, state->sg_nents,
+			 dev->mr_page_size);
+	if (unlikely(n < 0))
+		return n;
 
-	memset(&wr, 0, sizeof(wr));
-	wr.wr.opcode = IB_WR_FAST_REG_MR;
+	wr.wr.opcode = IB_WR_REG_MR;
 	wr.wr.wr_id = FAST_REG_WR_ID_MASK;
-	wr.iova_start = state->base_dma_addr;
-	wr.page_list = desc->frpl;
-	wr.page_list_len = state->npages;
-	wr.page_shift = ilog2(dev->mr_page_size);
-	wr.length = state->dma_len;
-	wr.access_flags = (IB_ACCESS_LOCAL_WRITE |
-			   IB_ACCESS_REMOTE_READ |
-			   IB_ACCESS_REMOTE_WRITE);
-	wr.rkey = desc->mr->lkey;
+	wr.wr.num_sge = 0;
+	wr.wr.send_flags = 0;
+	wr.mr = desc->mr;
+	wr.key = desc->mr->rkey;
+	wr.access = (IB_ACCESS_LOCAL_WRITE |
+		     IB_ACCESS_REMOTE_READ |
+		     IB_ACCESS_REMOTE_WRITE);
 
 	*state->fr.next++ = desc;
 	state->nmdesc++;
 
-	srp_map_desc(state, state->base_dma_addr, state->dma_len,
-		     desc->mr->rkey);
-
-	return ib_post_send(ch->qp, &wr.wr, &bad_wr);
-}
-
-static int srp_finish_mapping(struct srp_map_state *state,
-			      struct srp_rdma_ch *ch)
-{
-	struct srp_target_port *target = ch->target;
-	struct srp_device *dev = target->srp_host->srp_dev;
-	int ret = 0;
-
-	WARN_ON_ONCE(!dev->use_fast_reg && !dev->use_fmr);
+	srp_map_desc(state, desc->mr->iova,
+		     desc->mr->length, desc->mr->rkey);
 
-	if (state->npages == 0)
-		return 0;
+	err = ib_post_send(ch->qp, &wr.wr, &bad_wr);
+	if (unlikely(err))
+		return err;
 
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
+	return n;
 }
 
 static int srp_map_sg_entry(struct srp_map_state *state,
@@ -1389,7 +1378,7 @@ static int srp_map_sg_entry(struct srp_map_state *state,
 	while (dma_len) {
 		unsigned offset = dma_addr & ~dev->mr_page_mask;
 		if (state->npages == dev->max_pages_per_mr || offset != 0) {
-			ret = srp_finish_mapping(state, ch);
+			ret = srp_map_finish_fmr(state, ch);
 			if (ret)
 				return ret;
 		}
@@ -1411,51 +1400,91 @@ static int srp_map_sg_entry(struct srp_map_state *state,
 	 */
 	ret = 0;
 	if (len != dev->mr_page_size)
-		ret = srp_finish_mapping(state, ch);
+		ret = srp_map_finish_fmr(state, ch);
+
 	return ret;
 }
 
-static int srp_map_sg(struct srp_map_state *state, struct srp_rdma_ch *ch,
-		      struct srp_request *req, struct scatterlist *scat,
-		      int count)
+static int srp_map_sg_fmr(struct srp_map_state *state,
+			  struct srp_rdma_ch *ch,
+			  struct srp_request *req,
+			  struct scatterlist *scat,
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
-	}
+	state->desc = req->indirect_desc;
+	state->pages = req->map_page;
+	state->fmr.next = req->fmr_list;
+	state->fmr.end = req->fmr_list + ch->target->cmd_sg_cnt;
 
-	if (dev->use_fast_reg || dev->use_fmr) {
-		for_each_sg(scat, sg, count, i) {
-			ret = srp_map_sg_entry(state, ch, sg, i);
-			if (ret)
-				goto out;
-		}
-		ret = srp_finish_mapping(state, ch);
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
 	}
 
+	ret = srp_map_finish_fmr(state, ch);
+	if (ret)
+		return ret;
+
 	req->nmdesc = state->nmdesc;
-	ret = 0;
 
-out:
-	return ret;
+	return 0;
+}
+
+static int srp_map_sg_fr(struct srp_map_state *state,
+			 struct srp_rdma_ch *ch,
+			 struct srp_request *req,
+			 struct scatterlist *scat,
+			 int count)
+{
+
+	state->desc = req->indirect_desc;
+	state->fr.next = req->fr_list;
+	state->fr.end = req->fr_list + ch->target->cmd_sg_cnt;
+	state->sg = scat;
+	state->sg_nents = scsi_sg_count(req->scmnd);
+
+	while (state->sg_nents) {
+		int i, n;
+
+		n = srp_map_finish_fr(state, ch);
+		if (unlikely(n < 0))
+			return n;
+
+		state->sg_nents -= n;
+		for (i = 0; i < n; i++)
+			state->sg = sg_next(state->sg);
+	}
+
+	req->nmdesc = state->nmdesc;
+
+	return 0;
+}
+
+static int srp_map_sg_dma(struct srp_map_state *state,
+			  struct srp_rdma_ch *ch,
+			  struct srp_request *req,
+			  struct scatterlist *scat,
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
+	}
+
+	req->nmdesc = state->nmdesc;
+
+	return 0;
 }
 
 /*
@@ -1474,6 +1503,7 @@ static int srp_map_idb(struct srp_rdma_ch *ch, struct srp_request *req,
 	struct srp_map_state state;
 	struct srp_direct_buf idb_desc;
 	u64 idb_pages[1];
+	struct scatterlist idb_sg[1];
 	int ret;
 
 	memset(&state, 0, sizeof(state));
@@ -1481,19 +1511,31 @@ static int srp_map_idb(struct srp_rdma_ch *ch, struct srp_request *req,
 	state.gen.next = next_mr;
 	state.gen.end = end_mr;
 	state.desc = &idb_desc;
-	state.pages = idb_pages;
-	state.pages[0] = (req->indirect_dma_addr &
-			  dev->mr_page_mask);
-	state.npages = 1;
 	state.base_dma_addr = req->indirect_dma_addr;
 	state.dma_len = idb_len;
-	ret = srp_finish_mapping(&state, ch);
-	if (ret < 0)
-		goto out;
+
+	if (dev->use_fast_reg) {
+		state.sg = idb_sg;
+		state.sg_nents = 1;
+		sg_set_buf(idb_sg, req->indirect_desc, idb_len);
+		idb_sg->dma_address = req->indirect_dma_addr; /* hack! */
+		ret = srp_map_finish_fr(&state, ch);
+		if (ret < 0)
+			return ret;
+	} else if (dev->use_fmr) {
+		state.pages = idb_pages;
+		state.pages[0] = (req->indirect_dma_addr &
+				  dev->mr_page_mask);
+		state.npages = 1;
+		ret = srp_map_finish_fmr(&state, ch);
+		if (ret < 0)
+			return ret;
+	} else {
+		return -EINVAL;
+	}
 
 	*idb_rkey = idb_desc.key;
 
-out:
 	return ret;
 }
 
@@ -1563,7 +1605,13 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 				   target->indirect_size, DMA_TO_DEVICE);
 
 	memset(&state, 0, sizeof(state));
-	srp_map_sg(&state, ch, req, scat, count);
+
+	if (dev->use_fast_reg)
+		srp_map_sg_fr(&state, ch, req, scat, count);
+	else if (dev->use_fmr)
+		srp_map_sg_fmr(&state, ch, req, scat, count);
+	else
+		srp_map_sg_dma(&state, ch, req, scat, count);
 
 	/* We've mapped the request, now pull as much of the indirect
 	 * descriptor table as we can into the command buffer. If this
diff --git a/drivers/infiniband/ulp/srp/ib_srp.h b/drivers/infiniband/ulp/srp/ib_srp.h
index 3608f2e4819c..a31a93716f3f 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.h
+++ b/drivers/infiniband/ulp/srp/ib_srp.h
@@ -242,7 +242,6 @@ struct srp_iu {
 struct srp_fr_desc {
 	struct list_head		entry;
 	struct ib_mr			*mr;
-	struct ib_fast_reg_page_list	*frpl;
 };
 
 /**
@@ -294,11 +293,17 @@ struct srp_map_state {
 		} gen;
 	};
 	struct srp_direct_buf  *desc;
-	u64		       *pages;
+	union {
+		u64			*pages;
+		struct scatterlist	*sg;
+	};
 	dma_addr_t		base_dma_addr;
 	u32			dma_len;
 	u32			total_len;
-	unsigned int		npages;
+	union {
+		unsigned int		npages;
+		unsigned int		sg_nents;
+	};
 	unsigned int		nmdesc;
 	unsigned int		ndesc;
 };
-- 
1.8.4.3

