Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32973 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754564AbdFWVS7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:18:59 -0400
Subject: [PATCH v3 14/18] svcrdma: Remove frmr cache
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 23 Jun 2017 17:18:57 -0400
Message-ID: <20170623211857.5162.14443.stgit@klimt.1015granger.net>
In-Reply-To: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that the svc_rdma_recvfrom path uses the rdma_rw API,
the details of Read sink buffer registration are dealt with by the
kernel's RDMA core. This cache is no longer used, and can be
removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   18 ------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   86 ------------------------------
 2 files changed, 104 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 06d58a3..fd7775f 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -77,7 +77,6 @@ enum {
  */
 struct svc_rdma_op_ctxt {
 	struct list_head list;
-	struct svc_rdma_fastreg_mr *frmr;
 	struct xdr_buf arg;
 	struct ib_cqe cqe;
 	u32 byte_len;
@@ -91,17 +90,6 @@ struct svc_rdma_op_ctxt {
 	struct page *pages[RPCSVC_MAXPAGES];
 };
 
-struct svc_rdma_fastreg_mr {
-	struct ib_mr *mr;
-	struct scatterlist *sg;
-	int sg_nents;
-	unsigned long access_flags;
-	enum dma_data_direction direction;
-	struct list_head frmr_list;
-};
-
-#define RDMACTXT_F_LAST_CTXT	2
-
 #define	SVCRDMA_DEVCAP_FAST_REG		1	/* fast mr registration */
 #define	SVCRDMA_DEVCAP_READ_W_INV	2	/* read w/ invalidate */
 
@@ -136,9 +124,6 @@ struct svcxprt_rdma {
 	struct ib_cq         *sc_rq_cq;
 	struct ib_cq         *sc_sq_cq;
 	u32		     sc_dev_caps;	/* distilled device caps */
-	unsigned int	     sc_frmr_pg_list_len;
-	struct list_head     sc_frmr_q;
-	spinlock_t	     sc_frmr_q_lock;
 
 	spinlock_t	     sc_lock;		/* transport lock */
 
@@ -210,9 +195,6 @@ extern int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
-extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
-extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
-			      struct svc_rdma_fastreg_mr *);
 extern void svc_sq_reap(struct svcxprt_rdma *);
 extern void svc_rq_reap(struct svcxprt_rdma *);
 extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index c915cba..8864105 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -202,7 +202,6 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 out:
 	ctxt->count = 0;
 	ctxt->mapped_sges = 0;
-	ctxt->frmr = NULL;
 	return ctxt;
 
 out_empty:
@@ -387,14 +386,12 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
-	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_ctxts);
 	INIT_LIST_HEAD(&cma_xprt->sc_rw_ctxts);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
-	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_rw_ctxt_lock);
 
@@ -705,86 +702,6 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	return ERR_PTR(ret);
 }
 
-static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
-{
-	struct ib_mr *mr;
-	struct scatterlist *sg;
-	struct svc_rdma_fastreg_mr *frmr;
-	u32 num_sg;
-
-	frmr = kmalloc(sizeof(*frmr), GFP_KERNEL);
-	if (!frmr)
-		goto err;
-
-	num_sg = min_t(u32, RPCSVC_MAXPAGES, xprt->sc_frmr_pg_list_len);
-	mr = ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, num_sg);
-	if (IS_ERR(mr))
-		goto err_free_frmr;
-
-	sg = kcalloc(RPCSVC_MAXPAGES, sizeof(*sg), GFP_KERNEL);
-	if (!sg)
-		goto err_free_mr;
-
-	sg_init_table(sg, RPCSVC_MAXPAGES);
-
-	frmr->mr = mr;
-	frmr->sg = sg;
-	INIT_LIST_HEAD(&frmr->frmr_list);
-	return frmr;
-
- err_free_mr:
-	ib_dereg_mr(mr);
- err_free_frmr:
-	kfree(frmr);
- err:
-	return ERR_PTR(-ENOMEM);
-}
-
-static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
-{
-	struct svc_rdma_fastreg_mr *frmr;
-
-	while (!list_empty(&xprt->sc_frmr_q)) {
-		frmr = list_entry(xprt->sc_frmr_q.next,
-				  struct svc_rdma_fastreg_mr, frmr_list);
-		list_del_init(&frmr->frmr_list);
-		kfree(frmr->sg);
-		ib_dereg_mr(frmr->mr);
-		kfree(frmr);
-	}
-}
-
-struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
-{
-	struct svc_rdma_fastreg_mr *frmr = NULL;
-
-	spin_lock(&rdma->sc_frmr_q_lock);
-	if (!list_empty(&rdma->sc_frmr_q)) {
-		frmr = list_entry(rdma->sc_frmr_q.next,
-				  struct svc_rdma_fastreg_mr, frmr_list);
-		list_del_init(&frmr->frmr_list);
-		frmr->sg_nents = 0;
-	}
-	spin_unlock(&rdma->sc_frmr_q_lock);
-	if (frmr)
-		return frmr;
-
-	return rdma_alloc_frmr(rdma);
-}
-
-void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
-		       struct svc_rdma_fastreg_mr *frmr)
-{
-	if (frmr) {
-		ib_dma_unmap_sg(rdma->sc_cm_id->device,
-				frmr->sg, frmr->sg_nents, frmr->direction);
-		spin_lock(&rdma->sc_frmr_q_lock);
-		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
-		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
-		spin_unlock(&rdma->sc_frmr_q_lock);
-	}
-}
-
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -922,8 +839,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 *	of an RDMA_READ. IB does not.
 	 */
 	if (dev->attrs.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
-		newxprt->sc_frmr_pg_list_len =
-			dev->attrs.max_fast_reg_page_list_len;
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
 	} else
 		newxprt->sc_snd_w_inv = false;
@@ -1063,7 +978,6 @@ static void __svc_rdma_free(struct work_struct *work)
 		xprt->xpt_bc_xprt = NULL;
 	}
 
-	rdma_dealloc_frmr_q(rdma);
 	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_destroy_ctxts(rdma);
 

