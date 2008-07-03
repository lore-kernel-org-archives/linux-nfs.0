From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 11/11] svcrdma: Change WR context get/put to use the kmem cache
Date: Wed,  2 Jul 2008 21:27:43 -0500
Message-ID: <1215052063-7330-12-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-7-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-8-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-9-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-10-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-11-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48843 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-11-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the WR context pool to be shared across mount points. This
reduces the RDMA transport memory footprint significantly since
idle mounts don't consume WR context memory.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h          |    6 --
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  121 +++---------------------------
 2 files changed, 12 insertions(+), 115 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index d8d74c4..ef2e3a2 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -73,7 +73,6 @@ extern atomic_t rdma_stat_sq_prod;
 struct svc_rdma_op_ctxt {
 	struct svc_rdma_op_ctxt *read_hdr;
 	int hdr_count;
-	struct list_head free_list;
 	struct xdr_buf arg;
 	struct list_head dto_q;
 	enum ib_wr_opcode wr_op;
@@ -131,11 +130,6 @@ struct svcxprt_rdma {
 
 	atomic_t	     sc_dma_used;
 	atomic_t	     sc_ctxt_used;
-	struct list_head     sc_ctxt_free;
-	int		     sc_ctxt_cnt;
-	int		     sc_ctxt_bump;
-	int		     sc_ctxt_max;
-	spinlock_t	     sc_ctxt_lock;
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
 	struct ib_qp         *sc_qp;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 80104f4..19ddc38 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -84,69 +84,23 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
-static int rdma_bump_context_cache(struct svcxprt_rdma *xprt)
-{
-	int target;
-	int at_least_one = 0;
-	struct svc_rdma_op_ctxt *ctxt;
-
-	target = min(xprt->sc_ctxt_cnt + xprt->sc_ctxt_bump,
-		     xprt->sc_ctxt_max);
-
-	spin_lock_bh(&xprt->sc_ctxt_lock);
-	while (xprt->sc_ctxt_cnt < target) {
-		xprt->sc_ctxt_cnt++;
-		spin_unlock_bh(&xprt->sc_ctxt_lock);
-
-		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
-
-		spin_lock_bh(&xprt->sc_ctxt_lock);
-		if (ctxt) {
-			at_least_one = 1;
-			INIT_LIST_HEAD(&ctxt->free_list);
-			list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
-		} else {
-			/* kmalloc failed...give up for now */
-			xprt->sc_ctxt_cnt--;
-			break;
-		}
-	}
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
-	dprintk("svcrdma: sc_ctxt_max=%d, sc_ctxt_cnt=%d\n",
-		xprt->sc_ctxt_max, xprt->sc_ctxt_cnt);
-	return at_least_one;
-}
+/* WR context cache. Created in svc_rdma.c  */
+extern struct kmem_cache *svc_rdma_ctxt_cachep;
 
 struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt;
 
 	while (1) {
-		spin_lock_bh(&xprt->sc_ctxt_lock);
-		if (unlikely(list_empty(&xprt->sc_ctxt_free))) {
-			/* Try to bump my cache. */
-			spin_unlock_bh(&xprt->sc_ctxt_lock);
-
-			if (rdma_bump_context_cache(xprt))
-				continue;
-
-			printk(KERN_INFO "svcrdma: sleeping waiting for "
-			       "context memory on xprt=%p\n",
-			       xprt);
-			schedule_timeout_uninterruptible(msecs_to_jiffies(500));
-			continue;
-		}
-		ctxt = list_entry(xprt->sc_ctxt_free.next,
-				  struct svc_rdma_op_ctxt,
-				  free_list);
-		list_del_init(&ctxt->free_list);
-		spin_unlock_bh(&xprt->sc_ctxt_lock);
-		ctxt->xprt = xprt;
-		INIT_LIST_HEAD(&ctxt->dto_q);
-		ctxt->count = 0;
-		atomic_inc(&xprt->sc_ctxt_used);
-		break;
+		ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, GFP_KERNEL);
+		if (ctxt)
+			break;
+		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
 	}
+	ctxt->xprt = xprt;
+	INIT_LIST_HEAD(&ctxt->dto_q);
+	ctxt->count = 0;
+	atomic_inc(&xprt->sc_ctxt_used);
 	return ctxt;
 }
 
@@ -174,9 +128,7 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
-	list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	kmem_cache_free(svc_rdma_ctxt_cachep, ctxt);
 	atomic_dec(&xprt->sc_ctxt_used);
 }
 
@@ -461,40 +413,6 @@ static void sq_comp_handler(struct ib_cq *cq, void *cq_context)
 	tasklet_schedule(&dto_tasklet);
 }
 
-static void create_context_cache(struct svcxprt_rdma *xprt,
-				 int ctxt_count, int ctxt_bump, int ctxt_max)
-{
-	struct svc_rdma_op_ctxt *ctxt;
-	int i;
-
-	xprt->sc_ctxt_max = ctxt_max;
-	xprt->sc_ctxt_bump = ctxt_bump;
-	xprt->sc_ctxt_cnt = 0;
-	atomic_set(&xprt->sc_ctxt_used, 0);
-
-	INIT_LIST_HEAD(&xprt->sc_ctxt_free);
-	for (i = 0; i < ctxt_count; i++) {
-		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
-		if (ctxt) {
-			INIT_LIST_HEAD(&ctxt->free_list);
-			list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
-			xprt->sc_ctxt_cnt++;
-		}
-	}
-}
-
-static void destroy_context_cache(struct svcxprt_rdma *xprt)
-{
-	while (!list_empty(&xprt->sc_ctxt_free)) {
-		struct svc_rdma_op_ctxt *ctxt;
-		ctxt = list_entry(xprt->sc_ctxt_free.next,
-				  struct svc_rdma_op_ctxt,
-				  free_list);
-		list_del_init(&ctxt->free_list);
-		kfree(ctxt);
-	}
-}
-
 static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 					     int listener)
 {
@@ -511,7 +429,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 
 	spin_lock_init(&cma_xprt->sc_lock);
 	spin_lock_init(&cma_xprt->sc_read_complete_lock);
-	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 
 	cma_xprt->sc_ord = svcrdma_ord;
@@ -522,20 +439,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	atomic_set(&cma_xprt->sc_sq_count, 0);
 	atomic_set(&cma_xprt->sc_ctxt_used, 0);
 
-	if (!listener) {
-		int reqs = cma_xprt->sc_max_requests;
-		create_context_cache(cma_xprt,
-				     reqs << 1, /* starting size */
-				     reqs,	/* bump amount */
-				     reqs +
-				     cma_xprt->sc_sq_depth +
-				     RPCRDMA_MAX_THREADS + 1); /* max */
-		if (list_empty(&cma_xprt->sc_ctxt_free)) {
-			kfree(cma_xprt);
-			return NULL;
-		}
-		clear_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
-	} else
+	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
 
 	return cma_xprt;
@@ -1077,7 +981,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	/* Destroy the CM ID */
 	rdma_destroy_id(rdma->sc_cm_id);
 
-	destroy_context_cache(rdma);
 	kfree(rdma);
 }
 
