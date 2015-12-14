Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34270 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbbLNVag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:30:36 -0500
Subject: [PATCH v4 04/11] svcrdma: Improve allocation of struct
 svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:30:34 -0500
Message-ID: <20151214213034.12932.3797.stgit@klimt.1015granger.net>
In-Reply-To: <20151214211951.12932.99017.stgit@klimt.1015granger.net>
References: <20151214211951.12932.99017.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the maximum payload size of NFS READ and WRITE was increased
by commit cc9a903d915c ("svcrdma: Change maximum server payload back
to RPCSVC_MAXPAYLOAD"), the size of struct svc_rdma_op_ctxt
increased to over 6KB (on x86_64). That makes allocating one of
these from a kmem_cache more likely to fail in situations when
system memory is exhausted.

Since I'm about to add a caller where this allocation must always
work _and_ it cannot sleep, pre-allocate ctxts for each connection.

Another motivation for this change is that NFSv4.x servers are
required by specification not to drop NFS requests. Pre-allocating
memory resources reduces the likelihood of a drop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    6 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  102 ++++++++++++++++++++++++++----
 2 files changed, 94 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f869807..be2804b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -69,6 +69,7 @@ extern atomic_t rdma_stat_sq_prod;
  * completes.
  */
 struct svc_rdma_op_ctxt {
+	struct list_head free;
 	struct svc_rdma_op_ctxt *read_hdr;
 	struct svc_rdma_fastreg_mr *frmr;
 	int hdr_count;
@@ -141,7 +142,10 @@ struct svcxprt_rdma {
 	struct ib_pd         *sc_pd;
 
 	atomic_t	     sc_dma_used;
-	atomic_t	     sc_ctxt_used;
+	spinlock_t	     sc_ctxt_lock;
+	struct list_head     sc_ctxts;
+	int		     sc_ctxt_used;
+
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
 	struct ib_qp         *sc_qp;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 0783f6e..58ed9f2 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -153,18 +153,76 @@ static void svc_rdma_bc_free(struct svc_xprt *xprt)
 }
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
-struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+static struct svc_rdma_op_ctxt *alloc_ctxt(struct svcxprt_rdma *xprt,
+					   gfp_t flags)
 {
 	struct svc_rdma_op_ctxt *ctxt;
 
-	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
-				GFP_KERNEL | __GFP_NOFAIL);
-	ctxt->xprt = xprt;
-	INIT_LIST_HEAD(&ctxt->dto_q);
+	ctxt = kmalloc(sizeof(*ctxt), flags);
+	if (ctxt) {
+		ctxt->xprt = xprt;
+		INIT_LIST_HEAD(&ctxt->free);
+		INIT_LIST_HEAD(&ctxt->dto_q);
+	}
+	return ctxt;
+}
+
+static bool svc_rdma_prealloc_ctxts(struct svcxprt_rdma *xprt)
+{
+	int i;
+
+	/* Each RPC/RDMA credit can consume a number of send
+	 * and receive WQEs. One ctxt is allocated for each.
+	 */
+	i = xprt->sc_sq_depth + xprt->sc_max_requests;
+
+	while (i--) {
+		struct svc_rdma_op_ctxt *ctxt;
+
+		ctxt = alloc_ctxt(xprt, GFP_KERNEL);
+		if (!ctxt) {
+			dprintk("svcrdma: No memory for RDMA ctxt\n");
+			return false;
+		}
+		list_add(&ctxt->free, &xprt->sc_ctxts);
+	}
+	return true;
+}
+
+struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_op_ctxt *ctxt = NULL;
+
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	xprt->sc_ctxt_used++;
+	if (list_empty(&xprt->sc_ctxts))
+		goto out_empty;
+
+	ctxt = list_first_entry(&xprt->sc_ctxts,
+				struct svc_rdma_op_ctxt, free);
+	list_del_init(&ctxt->free);
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+
+out:
 	ctxt->count = 0;
 	ctxt->frmr = NULL;
-	atomic_inc(&xprt->sc_ctxt_used);
 	return ctxt;
+
+out_empty:
+	/* Either pre-allocation missed the mark, or send
+	 * queue accounting is broken.
+	 */
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+
+	ctxt = alloc_ctxt(xprt, GFP_NOIO);
+	if (ctxt)
+		goto out;
+
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	xprt->sc_ctxt_used--;
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	WARN_ON_ONCE("svcrdma: empty RDMA ctxt list?\n");
+	return NULL;
 }
 
 void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
@@ -190,16 +248,29 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 
 void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 {
-	struct svcxprt_rdma *xprt;
+	struct svcxprt_rdma *xprt = ctxt->xprt;
 	int i;
 
-	xprt = ctxt->xprt;
 	if (free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	kmem_cache_free(svc_rdma_ctxt_cachep, ctxt);
-	atomic_dec(&xprt->sc_ctxt_used);
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	xprt->sc_ctxt_used--;
+	list_add(&ctxt->free, &xprt->sc_ctxts);
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+}
+
+static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
+{
+	while (!list_empty(&xprt->sc_ctxts)) {
+		struct svc_rdma_op_ctxt *ctxt;
+
+		ctxt = list_first_entry(&xprt->sc_ctxts,
+					struct svc_rdma_op_ctxt, free);
+		list_del(&ctxt->free);
+		kfree(ctxt);
+	}
 }
 
 /*
@@ -521,11 +592,13 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_ctxts);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
+	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 
 	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
@@ -913,6 +986,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 				   (size_t)svcrdma_max_requests);
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
 
+	if (!svc_rdma_prealloc_ctxts(newxprt))
+		goto errout;
+
 	/*
 	 * Limit ORD based on client limit, local device limit, and
 	 * configured svcrdma limit.
@@ -1174,15 +1250,15 @@ static void __svc_rdma_free(struct work_struct *work)
 	}
 
 	/* Warn if we leaked a resource or under-referenced */
-	if (atomic_read(&rdma->sc_ctxt_used) != 0)
+	if (rdma->sc_ctxt_used != 0)
 		pr_err("svcrdma: ctxt still in use? (%d)\n",
-		       atomic_read(&rdma->sc_ctxt_used));
+		       rdma->sc_ctxt_used);
 	if (atomic_read(&rdma->sc_dma_used) != 0)
 		pr_err("svcrdma: dma still in use? (%d)\n",
 		       atomic_read(&rdma->sc_dma_used));
 
-	/* De-allocate fastreg mr */
 	rdma_dealloc_frmr_q(rdma);
+	svc_rdma_destroy_ctxts(rdma);
 
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))

