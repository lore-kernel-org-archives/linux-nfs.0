Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49322 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753167AbbIQJnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 05:43:20 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v1 13/24] svcrdma: Port to new memory registration API
Date: Thu, 17 Sep 2015 12:42:16 +0300
Message-Id: <1442482947-27785-14-git-send-email-sagig@mellanox.com>
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of maintaining a fastreg page list, keep an sg table
and convert an array of pages to a sg list. Then call ib_map_mr_sg
and construct ib_reg_wr.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 include/linux/sunrpc/svc_rdma.h          |  6 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 76 ++++++++++++++++++--------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 34 +++++---------
 3 files changed, 55 insertions(+), 61 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 83211bc9219e..e240d102a911 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -105,11 +105,9 @@ struct svc_rdma_chunk_sge {
 };
 struct svc_rdma_fastreg_mr {
 	struct ib_mr *mr;
-	void *kva;
-	struct ib_fast_reg_page_list *page_list;
-	int page_list_len;
+	struct scatterlist *sg;
+	unsigned int sg_nents;
 	unsigned long access_flags;
-	unsigned long map_len;
 	enum dma_data_direction direction;
 	struct list_head frmr_list;
 };
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 7be42d0da19e..303f194970f9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -220,12 +220,12 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 {
 	struct ib_rdma_wr read_wr;
 	struct ib_send_wr inv_wr;
-	struct ib_fast_reg_wr fastreg_wr;
+	struct ib_reg_wr reg_wr;
 	u8 key;
-	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
+	unsigned int nents = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
 	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
 	struct svc_rdma_fastreg_mr *frmr = svc_rdma_get_frmr(xprt);
-	int ret, read, pno;
+	int ret, read, pno, dma_nents, n;
 	u32 pg_off = *page_offset;
 	u32 pg_no = *page_no;
 
@@ -234,16 +234,14 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 
 	ctxt->direction = DMA_FROM_DEVICE;
 	ctxt->frmr = frmr;
-	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
-	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
+	nents = min_t(unsigned int, nents, xprt->sc_frmr_pg_list_len);
+	read = min_t(int, nents << PAGE_SHIFT, rs_length);
 
-	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
 	frmr->direction = DMA_FROM_DEVICE;
 	frmr->access_flags = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
-	frmr->map_len = pages_needed << PAGE_SHIFT;
-	frmr->page_list_len = pages_needed;
+	frmr->sg_nents = nents;
 
-	for (pno = 0; pno < pages_needed; pno++) {
+	for (pno = 0; pno < nents; pno++) {
 		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
 
 		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
@@ -251,17 +249,12 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 		head->arg.len += len;
 		if (!pg_off)
 			head->count++;
+
+		sg_set_page(&frmr->sg[pno], rqstp->rq_arg.pages[pg_no],
+			    len, pg_off);
+
 		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
 		rqstp->rq_next_page = rqstp->rq_respages + 1;
-		frmr->page_list->page_list[pno] =
-			ib_dma_map_page(xprt->sc_cm_id->device,
-					head->arg.pages[pg_no], 0,
-					PAGE_SIZE, DMA_FROM_DEVICE);
-		ret = ib_dma_mapping_error(xprt->sc_cm_id->device,
-					   frmr->page_list->page_list[pno]);
-		if (ret)
-			goto err;
-		atomic_inc(&xprt->sc_dma_used);
 
 		/* adjust offset and wrap to next page if needed */
 		pg_off += len;
@@ -277,28 +270,42 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	else
 		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
 
+	dma_nents = ib_dma_map_sg(xprt->sc_cm_id->device,
+				  frmr->sg, frmr->sg_nents,
+				  frmr->direction);
+	if (!dma_nents) {
+		pr_err("svcrdma: failed to dma map sg %p\n",
+		       frmr->sg);
+		return -ENOMEM;
+	}
+	atomic_inc(&xprt->sc_dma_used);
+
+	n = ib_map_mr_sg(frmr->mr, frmr->sg, frmr->sg_nents, PAGE_SIZE);
+	if (unlikely(n != frmr->sg_nents)) {
+		pr_err("svcrdma: failed to map mr %p (%d/%d elements)\n",
+		       frmr->mr, n, frmr->sg_nents);
+		return n < 0 ? n : -EINVAL;
+	}
+
 	/* Bump the key */
 	key = (u8)(frmr->mr->lkey & 0x000000FF);
 	ib_update_fast_reg_key(frmr->mr, ++key);
 
-	ctxt->sge[0].addr = (unsigned long)frmr->kva + *page_offset;
+	ctxt->sge[0].addr = frmr->mr->iova;
 	ctxt->sge[0].lkey = frmr->mr->lkey;
-	ctxt->sge[0].length = read;
+	ctxt->sge[0].length = frmr->mr->length;
 	ctxt->count = 1;
 	ctxt->read_hdr = head;
 
-	/* Prepare FASTREG WR */
-	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
-	fastreg_wr.wr.opcode = IB_WR_FAST_REG_MR;
-	fastreg_wr.wr.send_flags = IB_SEND_SIGNALED;
-	fastreg_wr.iova_start = (unsigned long)frmr->kva;
-	fastreg_wr.page_list = frmr->page_list;
-	fastreg_wr.page_list_len = frmr->page_list_len;
-	fastreg_wr.page_shift = PAGE_SHIFT;
-	fastreg_wr.length = frmr->map_len;
-	fastreg_wr.access_flags = frmr->access_flags;
-	fastreg_wr.rkey = frmr->mr->lkey;
-	fastreg_wr.wr.next = &read_wr.wr;
+	/* Prepare REG WR */
+	reg_wr.wr.opcode = IB_WR_REG_MR;
+	reg_wr.wr.wr_id = 0;
+	reg_wr.wr.send_flags = IB_SEND_SIGNALED;
+	reg_wr.wr.num_sge = 0;
+	reg_wr.mr = frmr->mr;
+	reg_wr.key = frmr->mr->lkey;
+	reg_wr.access = frmr->access_flags;
+	reg_wr.wr.next = &read_wr.wr;
 
 	/* Prepare RDMA_READ */
 	memset(&read_wr, 0, sizeof(read_wr));
@@ -324,7 +331,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	ctxt->wr_op = read_wr.wr.opcode;
 
 	/* Post the chain */
-	ret = svc_rdma_send(xprt, &fastreg_wr.wr);
+	ret = svc_rdma_send(xprt, &reg_wr.wr);
 	if (ret) {
 		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
 		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
@@ -338,7 +345,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	atomic_inc(&rdma_stat_read);
 	return ret;
  err:
-	svc_rdma_unmap_dma(ctxt);
+	ib_dma_unmap_sg(xprt->sc_cm_id->device,
+			frmr->sg, frmr->sg_nents, frmr->direction);
 	svc_rdma_put_context(ctxt, 0);
 	svc_rdma_put_frmr(xprt, frmr);
 	return ret;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index b9fe134bb416..13d26a7ddee4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -731,7 +731,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
 {
 	struct ib_mr *mr;
-	struct ib_fast_reg_page_list *pl;
+	struct scatterlist *sg;
 	struct svc_rdma_fastreg_mr *frmr;
 	u32 num_sg;
 
@@ -744,13 +744,14 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
 	if (IS_ERR(mr))
 		goto err_free_frmr;
 
-	pl = ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
-					 num_sg);
-	if (IS_ERR(pl))
+	sg = kcalloc(sizeof(*sg), RPCSVC_MAXPAGES, GFP_KERNEL);
+	if (IS_ERR(sg))
 		goto err_free_mr;
 
+	sg_init_table(sg, RPCSVC_MAXPAGES);
+
 	frmr->mr = mr;
-	frmr->page_list = pl;
+	frmr->sg = sg;
 	INIT_LIST_HEAD(&frmr->frmr_list);
 	return frmr;
 
@@ -770,8 +771,8 @@ static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
 		frmr = list_entry(xprt->sc_frmr_q.next,
 				  struct svc_rdma_fastreg_mr, frmr_list);
 		list_del_init(&frmr->frmr_list);
+		kfree(frmr->sg);
 		ib_dereg_mr(frmr->mr);
-		ib_free_fast_reg_page_list(frmr->page_list);
 		kfree(frmr);
 	}
 }
@@ -785,8 +786,7 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 		frmr = list_entry(rdma->sc_frmr_q.next,
 				  struct svc_rdma_fastreg_mr, frmr_list);
 		list_del_init(&frmr->frmr_list);
-		frmr->map_len = 0;
-		frmr->page_list_len = 0;
+		frmr->sg_nents = 0;
 	}
 	spin_unlock_bh(&rdma->sc_frmr_q_lock);
 	if (frmr)
@@ -795,25 +795,13 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 	return rdma_alloc_frmr(rdma);
 }
 
-static void frmr_unmap_dma(struct svcxprt_rdma *xprt,
-			   struct svc_rdma_fastreg_mr *frmr)
-{
-	int page_no;
-	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
-		dma_addr_t addr = frmr->page_list->page_list[page_no];
-		if (ib_dma_mapping_error(frmr->mr->device, addr))
-			continue;
-		atomic_dec(&xprt->sc_dma_used);
-		ib_dma_unmap_page(frmr->mr->device, addr, PAGE_SIZE,
-				  frmr->direction);
-	}
-}
-
 void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 		       struct svc_rdma_fastreg_mr *frmr)
 {
 	if (frmr) {
-		frmr_unmap_dma(rdma, frmr);
+		ib_dma_unmap_sg(rdma->sc_cm_id->device,
+				frmr->sg, frmr->sg_nents, frmr->direction);
+		atomic_dec(&rdma->sc_dma_used);
 		spin_lock_bh(&rdma->sc_frmr_q_lock);
 		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
 		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
-- 
1.8.4.3

