From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 02/09] svcrdma: Add FRMR get/put services
Date: Wed, 13 Aug 2008 11:10:14 -0500
Message-ID: <48A30766.2000308@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44618 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYHMQKP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:10:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add services for the allocating, freeing, and unmapping Fast Reg MR. These
services will be used by the transport connection setup, send and receive
routines.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h          |    3 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  125 ++++++++++++++++++++++++++++-
 2 files changed, 123 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 295ebbc..100754e 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -219,6 +219,9 @@ extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
 extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
+extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
+extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
+			      struct svc_rdma_fastreg_mr *);
 extern void svc_sq_reap(struct svcxprt_rdma *);
 extern void svc_rq_reap(struct svcxprt_rdma *);
 extern struct svc_xprt_class svc_rdma_class;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 900cb69..f200345 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -100,6 +100,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	ctxt->xprt = xprt;
 	INIT_LIST_HEAD(&ctxt->dto_q);
 	ctxt->count = 0;
+	ctxt->frmr = NULL;
 	atomic_inc(&xprt->sc_ctxt_used);
 	return ctxt;
 }
@@ -109,11 +110,19 @@ static void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 	struct svcxprt_rdma *xprt = ctxt->xprt;
 	int i;
 	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
-		atomic_dec(&xprt->sc_dma_used);
-		ib_dma_unmap_single(xprt->sc_cm_id->device,
-				    ctxt->sge[i].addr,
-				    ctxt->sge[i].length,
-				    ctxt->direction);
+		/*
+		 * Unmap the DMA addr in the SGE if the lkey matches
+		 * the sc_dma_lkey, otherwise, ignore it since it is
+		 * an FRMR lkey and will be unmapped later when the
+		 * last WR that uses it completes.
+		 */
+		if (ctxt->sge[i].lkey == xprt->sc_dma_lkey) {
+			atomic_dec(&xprt->sc_dma_used);
+			ib_dma_unmap_single(xprt->sc_cm_id->device,
+					    ctxt->sge[i].addr,
+					    ctxt->sge[i].length,
+					    ctxt->direction);
+		}
 	}
 }
 
@@ -150,6 +159,7 @@ struct svc_rdma_req_map *svc_rdma_get_req_map(void)
 		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
 	}
 	map->count = 0;
+	map->frmr = NULL;
 	return map;
 }
 
@@ -425,10 +435,12 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
+	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 
 	cma_xprt->sc_ord = svcrdma_ord;
 
@@ -686,6 +698,106 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	return ERR_PTR(ret);
 }
 
+static int rdma_alloc_frmr(struct svcxprt_rdma *xprt)
+{
+	struct ib_mr *mr;
+	struct ib_fast_reg_page_list *pl;
+	struct svc_rdma_fastreg_mr *frmr;
+
+	mr = ib_alloc_fast_reg_mr(xprt->sc_pd, RPCSVC_MAXPAGES);
+	if (!mr)
+		goto errout;
+	pl = ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
+					 RPCSVC_MAXPAGES);
+	if (!pl) {
+		ib_dereg_mr(mr);
+		goto errout;
+	}
+	frmr = kmalloc(sizeof(*frmr), GFP_KERNEL);
+	if (!frmr) {
+		ib_dereg_mr(mr);
+		ib_free_fast_reg_page_list(pl);
+		goto errout;
+	}
+	frmr->mr = mr;
+	frmr->page_list = pl;
+	INIT_LIST_HEAD(&frmr->frmr_list);
+	spin_lock_bh(&xprt->sc_frmr_q_lock);
+	list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
+	spin_unlock_bh(&xprt->sc_frmr_q_lock);
+
+	return 0;
+
+ errout:
+	return -ENOMEM;
+}
+
+static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_fastreg_mr *frmr;
+
+	while (!list_empty(&xprt->sc_frmr_q)) {
+		frmr = list_entry(xprt->sc_frmr_q.next,
+				  struct svc_rdma_fastreg_mr, frmr_list);
+		list_del_init(&frmr->frmr_list);
+		ib_dereg_mr(frmr->mr);
+		ib_free_fast_reg_page_list(frmr->page_list);
+		kfree(frmr);
+	}
+}
+
+struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_fastreg_mr *frmr = NULL;
+
+	while (1) {
+		spin_lock_bh(&rdma->sc_frmr_q_lock);
+		if (!list_empty(&rdma->sc_frmr_q)) {
+			frmr = list_entry(rdma->sc_frmr_q.next,
+					  struct svc_rdma_fastreg_mr, frmr_list);
+			list_del_init(&frmr->frmr_list);
+		}
+		spin_unlock_bh(&rdma->sc_frmr_q_lock);
+		if (frmr)
+			break;
+		if (rdma_alloc_frmr(rdma))
+			return ERR_PTR(-ENOMEM);
+	}
+	frmr->map_len = 0;
+	frmr->page_list_len = 0;
+
+	return frmr;
+}
+
+static void frmr_unmap_dma(struct svcxprt_rdma *xprt,
+			   struct svc_rdma_fastreg_mr *frmr)
+{
+	int page_no;
+	dprintk("svcrdma:%s: xprt %p page_list_len %d\n",
+		__func__, xprt, frmr->page_list_len);
+	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
+		dma_addr_t addr = frmr->page_list->page_list[page_no];
+		dprintk("svcrdma:      %08x %llx\n", frmr->mr->lkey, addr);
+		if (ib_dma_mapping_error(frmr->mr->device, addr))
+			continue;
+		atomic_dec(&xprt->sc_dma_used);
+		ib_dma_unmap_single(frmr->mr->device, addr, PAGE_SIZE,
+				    frmr->direction);
+	}
+}
+
+void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
+		       struct svc_rdma_fastreg_mr *frmr)
+{
+	if (frmr) {
+		frmr_unmap_dma(rdma, frmr);
+		spin_lock_bh(&rdma->sc_frmr_q_lock);
+		BUG_ON(!list_empty(&frmr->frmr_list));
+		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
+		spin_unlock_bh(&rdma->sc_frmr_q_lock);
+	}
+}
+
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -961,6 +1073,9 @@ static void __svc_rdma_free(struct work_struct *work)
 	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
 	WARN_ON(atomic_read(&rdma->sc_dma_used) != 0);
 
+	/* De-allocate fastreg mr */
+	rdma_dealloc_frmr_q(rdma);
+
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
 		ib_destroy_qp(rdma->sc_qp);

