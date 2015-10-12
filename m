Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35463 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752417AbbJLPa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 11:30:27 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 14/26] RDS/IW: Convert to new memory registration API
Date: Mon, 12 Oct 2015 18:29:27 +0300
Message-Id: <1444663779-1522-15-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
References: <1444663779-1522-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of fast_reg page list and its construction.
Instead, just pass the RDS sg list to ib_map_mr_sg
and post the new ib_reg_wr.

This is done both for server IW RDMA_READ registration
and the client remote key registration.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Acked-by: Christoph Hellwig <hch@lst.de>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/iw.h      |   5 +--
 net/rds/iw_rdma.c | 128 +++++++++++++++++++-----------------------------------
 net/rds/iw_send.c |  57 ++++++++++++------------
 3 files changed, 75 insertions(+), 115 deletions(-)

diff --git a/net/rds/iw.h b/net/rds/iw.h
index fe858e5dd8d1..5af01d1758b3 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -74,13 +74,12 @@ struct rds_iw_send_work {
 	struct rm_rdma_op	*s_op;
 	struct rds_iw_mapping	*s_mapping;
 	struct ib_mr		*s_mr;
-	struct ib_fast_reg_page_list *s_page_list;
 	unsigned char		s_remap_count;
 
 	union {
 		struct ib_send_wr	s_send_wr;
 		struct ib_rdma_wr	s_rdma_wr;
-		struct ib_fast_reg_wr	s_fast_reg_wr;
+		struct ib_reg_wr	s_reg_wr;
 	};
 	struct ib_sge		s_sge[RDS_IW_MAX_SGE];
 	unsigned long		s_queued;
@@ -199,7 +198,7 @@ struct rds_iw_device {
 
 /* Magic WR_ID for ACKs */
 #define RDS_IW_ACK_WR_ID	((u64)0xffffffffffffffffULL)
-#define RDS_IW_FAST_REG_WR_ID	((u64)0xefefefefefefefefULL)
+#define RDS_IW_REG_WR_ID	((u64)0xefefefefefefefefULL)
 #define RDS_IW_LOCAL_INV_WR_ID	((u64)0xdfdfdfdfdfdfdfdfULL)
 
 struct rds_iw_statistics {
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index f8a612cc69e6..47bd68451ff7 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -47,7 +47,6 @@ struct rds_iw_mr {
 	struct rdma_cm_id	*cm_id;
 
 	struct ib_mr	*mr;
-	struct ib_fast_reg_page_list *page_list;
 
 	struct rds_iw_mapping	mapping;
 	unsigned char		remap_count;
@@ -77,8 +76,8 @@ struct rds_iw_mr_pool {
 
 static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all);
 static void rds_iw_mr_pool_flush_worker(struct work_struct *work);
-static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
-static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
+static int rds_iw_init_reg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
+static int rds_iw_map_reg(struct rds_iw_mr_pool *pool,
 			  struct rds_iw_mr *ibmr,
 			  struct scatterlist *sg, unsigned int nents);
 static void rds_iw_free_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
@@ -258,19 +257,18 @@ static void rds_iw_set_scatterlist(struct rds_iw_scatterlist *sg,
 	sg->bytes = 0;
 }
 
-static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
-			struct rds_iw_scatterlist *sg)
+static int rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
+				  struct rds_iw_scatterlist *sg)
 {
 	struct ib_device *dev = rds_iwdev->dev;
-	u64 *dma_pages = NULL;
-	int i, j, ret;
+	int i, ret;
 
 	WARN_ON(sg->dma_len);
 
 	sg->dma_len = ib_dma_map_sg(dev, sg->list, sg->len, DMA_BIDIRECTIONAL);
 	if (unlikely(!sg->dma_len)) {
 		printk(KERN_WARNING "RDS/IW: dma_map_sg failed!\n");
-		return ERR_PTR(-EBUSY);
+		return -EBUSY;
 	}
 
 	sg->bytes = 0;
@@ -303,31 +301,14 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 	if (sg->dma_npages > fastreg_message_size)
 		goto out_unmap;
 
-	dma_pages = kmalloc(sizeof(u64) * sg->dma_npages, GFP_ATOMIC);
-	if (!dma_pages) {
-		ret = -ENOMEM;
-		goto out_unmap;
-	}
 
-	for (i = j = 0; i < sg->dma_len; ++i) {
-		unsigned int dma_len = ib_sg_dma_len(dev, &sg->list[i]);
-		u64 dma_addr = ib_sg_dma_address(dev, &sg->list[i]);
-		u64 end_addr;
 
-		end_addr = dma_addr + dma_len;
-		dma_addr &= ~PAGE_MASK;
-		for (; dma_addr < end_addr; dma_addr += PAGE_SIZE)
-			dma_pages[j++] = dma_addr;
-		BUG_ON(j > sg->dma_npages);
-	}
-
-	return dma_pages;
+	return 0;
 
 out_unmap:
 	ib_dma_unmap_sg(rds_iwdev->dev, sg->list, sg->len, DMA_BIDIRECTIONAL);
 	sg->dma_len = 0;
-	kfree(dma_pages);
-	return ERR_PTR(ret);
+	return ret;
 }
 
 
@@ -440,7 +421,7 @@ static struct rds_iw_mr *rds_iw_alloc_mr(struct rds_iw_device *rds_iwdev)
 	INIT_LIST_HEAD(&ibmr->mapping.m_list);
 	ibmr->mapping.m_mr = ibmr;
 
-	err = rds_iw_init_fastreg(pool, ibmr);
+	err = rds_iw_init_reg(pool, ibmr);
 	if (err)
 		goto out_no_cigar;
 
@@ -622,7 +603,7 @@ void *rds_iw_get_mr(struct scatterlist *sg, unsigned long nents,
 	ibmr->cm_id = cm_id;
 	ibmr->device = rds_iwdev;
 
-	ret = rds_iw_map_fastreg(rds_iwdev->mr_pool, ibmr, sg, nents);
+	ret = rds_iw_map_reg(rds_iwdev->mr_pool, ibmr, sg, nents);
 	if (ret == 0)
 		*key_ret = ibmr->mr->rkey;
 	else
@@ -638,7 +619,7 @@ out:
 }
 
 /*
- * iWARP fastreg handling
+ * iWARP reg handling
  *
  * The life cycle of a fastreg registration is a bit different from
  * FMRs.
@@ -650,7 +631,7 @@ out:
  * This creates a bit of a problem for us, as we do not have the destination
  * IP in GET_MR, so the connection must be setup prior to the GET_MR call for
  * RDMA to be correctly setup.  If a fastreg request is present, rds_iw_xmit
- * will try to queue a LOCAL_INV (if needed) and a FAST_REG_MR work request
+ * will try to queue a LOCAL_INV (if needed) and a REG_MR work request
  * before queuing the SEND. When completions for these arrive, they are
  * dispatched to the MR has a bit set showing that RDMa can be performed.
  *
@@ -659,11 +640,10 @@ out:
  * The expectation there is that this invalidation step includes ALL
  * PREVIOUSLY FREED MRs.
  */
-static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool,
-				struct rds_iw_mr *ibmr)
+static int rds_iw_init_reg(struct rds_iw_mr_pool *pool,
+			   struct rds_iw_mr *ibmr)
 {
 	struct rds_iw_device *rds_iwdev = pool->device;
-	struct ib_fast_reg_page_list *page_list = NULL;
 	struct ib_mr *mr;
 	int err;
 
@@ -676,56 +656,44 @@ static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool,
 		return err;
 	}
 
-	/* FIXME - this is overkill, but mapping->m_sg.dma_len/mapping->m_sg.dma_npages
-	 * is not filled in.
-	 */
-	page_list = ib_alloc_fast_reg_page_list(rds_iwdev->dev, pool->max_message_size);
-	if (IS_ERR(page_list)) {
-		err = PTR_ERR(page_list);
-
-		printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_page_list failed (err=%d)\n", err);
-		ib_dereg_mr(mr);
-		return err;
-	}
-
-	ibmr->page_list = page_list;
 	ibmr->mr = mr;
 	return 0;
 }
 
-static int rds_iw_rdma_build_fastreg(struct rds_iw_mapping *mapping)
+static int rds_iw_rdma_reg_mr(struct rds_iw_mapping *mapping)
 {
 	struct rds_iw_mr *ibmr = mapping->m_mr;
-	struct ib_fast_reg_wr f_wr;
+	struct rds_iw_scatterlist *m_sg = &mapping->m_sg;
+	struct ib_reg_wr reg_wr;
 	struct ib_send_wr *failed_wr;
-	int ret;
+	int ret, n;
+
+	n = ib_map_mr_sg_zbva(ibmr->mr, m_sg->list, m_sg->len, PAGE_SIZE);
+	if (unlikely(n != m_sg->len))
+		return n < 0 ? n : -EINVAL;
+
+	reg_wr.wr.next = NULL;
+	reg_wr.wr.opcode = IB_WR_REG_MR;
+	reg_wr.wr.wr_id = RDS_IW_REG_WR_ID;
+	reg_wr.wr.num_sge = 0;
+	reg_wr.mr = ibmr->mr;
+	reg_wr.key = mapping->m_rkey;
+	reg_wr.access = IB_ACCESS_LOCAL_WRITE |
+			IB_ACCESS_REMOTE_READ |
+			IB_ACCESS_REMOTE_WRITE;
 
 	/*
-	 * Perform a WR for the fast_reg_mr. Each individual page
+	 * Perform a WR for the reg_mr. Each individual page
 	 * in the sg list is added to the fast reg page list and placed
-	 * inside the fast_reg_mr WR.  The key used is a rolling 8bit
+	 * inside the reg_mr WR.  The key used is a rolling 8bit
 	 * counter, which should guarantee uniqueness.
 	 */
 	ib_update_fast_reg_key(ibmr->mr, ibmr->remap_count++);
 	mapping->m_rkey = ibmr->mr->rkey;
 
-	memset(&f_wr, 0, sizeof(f_wr));
-	f_wr.wr.wr_id = RDS_IW_FAST_REG_WR_ID;
-	f_wr.wr.opcode = IB_WR_FAST_REG_MR;
-	f_wr.length = mapping->m_sg.bytes;
-	f_wr.rkey = mapping->m_rkey;
-	f_wr.page_list = ibmr->page_list;
-	f_wr.page_list_len = mapping->m_sg.dma_len;
-	f_wr.page_shift = PAGE_SHIFT;
-	f_wr.access_flags = IB_ACCESS_LOCAL_WRITE |
-				IB_ACCESS_REMOTE_READ |
-				IB_ACCESS_REMOTE_WRITE;
-	f_wr.iova_start = 0;
-	f_wr.wr.send_flags = IB_SEND_SIGNALED;
-
-	failed_wr = &f_wr.wr;
-	ret = ib_post_send(ibmr->cm_id->qp, &f_wr.wr, &failed_wr);
-	BUG_ON(failed_wr != &f_wr.wr);
+	failed_wr = &reg_wr.wr;
+	ret = ib_post_send(ibmr->cm_id->qp, &reg_wr.wr, &failed_wr);
+	BUG_ON(failed_wr != &reg_wr.wr);
 	if (ret)
 		printk_ratelimited(KERN_WARNING "RDS/IW: %s:%d ib_post_send returned %d\n",
 			__func__, __LINE__, ret);
@@ -757,21 +725,20 @@ out:
 	return ret;
 }
 
-static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
-			struct rds_iw_mr *ibmr,
-			struct scatterlist *sg,
-			unsigned int sg_len)
+static int rds_iw_map_reg(struct rds_iw_mr_pool *pool,
+			  struct rds_iw_mr *ibmr,
+			  struct scatterlist *sg,
+			  unsigned int sg_len)
 {
 	struct rds_iw_device *rds_iwdev = pool->device;
 	struct rds_iw_mapping *mapping = &ibmr->mapping;
 	u64 *dma_pages;
-	int i, ret = 0;
+	int ret = 0;
 
 	rds_iw_set_scatterlist(&mapping->m_sg, sg, sg_len);
 
-	dma_pages = rds_iw_map_scatterlist(rds_iwdev, &mapping->m_sg);
-	if (IS_ERR(dma_pages)) {
-		ret = PTR_ERR(dma_pages);
+	ret = rds_iw_map_scatterlist(rds_iwdev, &mapping->m_sg);
+	if (ret) {
 		dma_pages = NULL;
 		goto out;
 	}
@@ -781,10 +748,7 @@ static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
 		goto out;
 	}
 
-	for (i = 0; i < mapping->m_sg.dma_npages; ++i)
-		ibmr->page_list->page_list[i] = dma_pages[i];
-
-	ret = rds_iw_rdma_build_fastreg(mapping);
+	ret = rds_iw_rdma_reg_mr(mapping);
 	if (ret)
 		goto out;
 
@@ -870,8 +834,6 @@ static unsigned int rds_iw_unmap_fastreg_list(struct rds_iw_mr_pool *pool,
 static void rds_iw_destroy_fastreg(struct rds_iw_mr_pool *pool,
 		struct rds_iw_mr *ibmr)
 {
-	if (ibmr->page_list)
-		ib_free_fast_reg_page_list(ibmr->page_list);
 	if (ibmr->mr)
 		ib_dereg_mr(ibmr->mr);
 }
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index f6e23c515b44..e20bd503f4bd 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -159,13 +159,6 @@ void rds_iw_send_init_ring(struct rds_iw_connection *ic)
 			printk(KERN_WARNING "RDS/IW: ib_alloc_mr failed\n");
 			break;
 		}
-
-		send->s_page_list = ib_alloc_fast_reg_page_list(
-			ic->i_cm_id->device, fastreg_message_size);
-		if (IS_ERR(send->s_page_list)) {
-			printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_page_list failed\n");
-			break;
-		}
 	}
 }
 
@@ -177,8 +170,6 @@ void rds_iw_send_clear_ring(struct rds_iw_connection *ic)
 	for (i = 0, send = ic->i_sends; i < ic->i_send_ring.w_nr; i++, send++) {
 		BUG_ON(!send->s_mr);
 		ib_dereg_mr(send->s_mr);
-		BUG_ON(!send->s_page_list);
-		ib_free_fast_reg_page_list(send->s_page_list);
 		if (send->s_send_wr.opcode == 0xdead)
 			continue;
 		if (send->s_rm)
@@ -227,7 +218,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, void *context)
 			continue;
 		}
 
-		if (wc.opcode == IB_WC_FAST_REG_MR && wc.wr_id == RDS_IW_FAST_REG_WR_ID) {
+		if (wc.opcode == IB_WC_REG_MR && wc.wr_id == RDS_IW_REG_WR_ID) {
 			ic->i_fastreg_posted = 1;
 			continue;
 		}
@@ -252,7 +243,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, void *context)
 				if (send->s_rm)
 					rds_iw_send_unmap_rm(ic, send, wc.status);
 				break;
-			case IB_WR_FAST_REG_MR:
+			case IB_WR_REG_MR:
 			case IB_WR_RDMA_WRITE:
 			case IB_WR_RDMA_READ:
 			case IB_WR_RDMA_READ_WITH_INV:
@@ -770,24 +761,26 @@ out:
 	return ret;
 }
 
-static void rds_iw_build_send_fastreg(struct rds_iw_device *rds_iwdev, struct rds_iw_connection *ic, struct rds_iw_send_work *send, int nent, int len, u64 sg_addr)
+static int rds_iw_build_send_reg(struct rds_iw_send_work *send,
+				 struct scatterlist *sg,
+				 int sg_nents)
 {
-	BUG_ON(nent > send->s_page_list->max_page_list_len);
-	/*
-	 * Perform a WR for the fast_reg_mr. Each individual page
-	 * in the sg list is added to the fast reg page list and placed
-	 * inside the fast_reg_mr WR.
-	 */
-	send->s_fast_reg_wr.wr.opcode = IB_WR_FAST_REG_MR;
-	send->s_fast_reg_wr.length = len;
-	send->s_fast_reg_wr.rkey = send->s_mr->rkey;
-	send->s_fast_reg_wr.page_list = send->s_page_list;
-	send->s_fast_reg_wr.page_list_len = nent;
-	send->s_fast_reg_wr.page_shift = PAGE_SHIFT;
-	send->s_fast_reg_wr.access_flags = IB_ACCESS_REMOTE_WRITE;
-	send->s_fast_reg_wr.iova_start = sg_addr;
+	int n;
+
+	n = ib_map_mr_sg(send->s_mr, sg, sg_nents, PAGE_SIZE);
+	if (unlikely(n != sg_nents))
+		return n < 0 ? n : -EINVAL;
+
+	send->s_reg_wr.wr.opcode = IB_WR_REG_MR;
+	send->s_reg_wr.wr.wr_id = 0;
+	send->s_reg_wr.wr.num_sge = 0;
+	send->s_reg_wr.mr = send->s_mr;
+	send->s_reg_wr.key = send->s_mr->rkey;
+	send->s_reg_wr.access = IB_ACCESS_REMOTE_WRITE;
 
 	ib_update_fast_reg_key(send->s_mr, send->s_remap_count++);
+
+	return 0;
 }
 
 int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
@@ -808,6 +801,7 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 	int sent;
 	int ret;
 	int num_sge;
+	int sg_nents;
 
 	rds_iwdev = ib_get_client_data(ic->i_cm_id->device, &rds_iw_client);
 
@@ -861,6 +855,7 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 	scat = &op->op_sg[0];
 	sent = 0;
 	num_sge = op->op_count;
+	sg_nents = 0;
 
 	for (i = 0; i < work_alloc && scat != &op->op_sg[op->op_count]; i++) {
 		send->s_rdma_wr.wr.send_flags = 0;
@@ -904,7 +899,7 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 			len = ib_sg_dma_len(ic->i_cm_id->device, scat);
 
 			if (send->s_rdma_wr.wr.opcode == IB_WR_RDMA_READ_WITH_INV)
-				send->s_page_list->page_list[j] = ib_sg_dma_address(ic->i_cm_id->device, scat);
+				sg_nents++;
 			else {
 				send->s_sge[j].addr = ib_sg_dma_address(ic->i_cm_id->device, scat);
 				send->s_sge[j].length = len;
@@ -951,8 +946,12 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 	 * fastreg_mr (or possibly a dma_mr)
 	 */
 	if (!op->op_write) {
-		rds_iw_build_send_fastreg(rds_iwdev, ic, &ic->i_sends[fr_pos],
-			op->op_count, sent, conn->c_xmit_rm->m_rs->rs_user_addr);
+		ret = rds_iw_build_send_reg(&ic->i_sends[fr_pos],
+					    &op->op_sg[0], sg_nents);
+		if (ret) {
+			printk(KERN_WARNING "RDS/IW: failed to reg send mem\n");
+			goto out;
+		}
 		work_alloc++;
 	}
 
-- 
1.8.4.3

