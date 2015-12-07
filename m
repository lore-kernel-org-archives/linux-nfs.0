Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38159 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932839AbbLGUmm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 15:42:42 -0500
Subject: [PATCH v3 2/6] svcrdma: Improve allocation of struct
 svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 Dec 2015 15:42:40 -0500
Message-ID: <20151207204240.12988.888.stgit@klimt.1015granger.net>
In-Reply-To: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turns out that when the maximum payload size of NFS READ and WRITE
was increased to 1MB, the size of struct svc_rdma_op_ctxt
increased to 6KB (x86_64). That makes allocating one of these from
a kmem_cache more likely to fail.

Allocating one of these has to be fast in general, and none of the
current caller sites expect allocation failure. The existing logic
ensures no failure by looping and sleeping.

Since I'm about to add a caller where this allocation must always
work _and_ it cannot sleep, pre-allocate them for each connection,
like other RDMA transport-related resources.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    4 ++
 net/sunrpc/xprtrdma/svc_rdma.c           |   17 -------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   76 ++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h          |    2 -
 4 files changed, 70 insertions(+), 29 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f869807..2bb0ff3 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -69,6 +69,7 @@ extern atomic_t rdma_stat_sq_prod;
  * completes.
  */
 struct svc_rdma_op_ctxt {
+	struct list_head free_q;
 	struct svc_rdma_op_ctxt *read_hdr;
 	struct svc_rdma_fastreg_mr *frmr;
 	int hdr_count;
@@ -142,6 +143,9 @@ struct svcxprt_rdma {
 
 	atomic_t	     sc_dma_used;
 	atomic_t	     sc_ctxt_used;
+	struct list_head     sc_ctxt_q;
+	spinlock_t	     sc_ctxt_lock;
+
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
 	struct ib_qp         *sc_qp;
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 1b7051b..aed1d96 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -71,9 +71,7 @@ atomic_t rdma_stat_rq_prod;
 atomic_t rdma_stat_sq_poll;
 atomic_t rdma_stat_sq_prod;
 
-/* Temporary NFS request map and context caches */
 struct kmem_cache *svc_rdma_map_cachep;
-struct kmem_cache *svc_rdma_ctxt_cachep;
 
 struct workqueue_struct *svc_rdma_wq;
 
@@ -244,7 +242,6 @@ void svc_rdma_cleanup(void)
 #endif
 	svc_unreg_xprt_class(&svc_rdma_class);
 	kmem_cache_destroy(svc_rdma_map_cachep);
-	kmem_cache_destroy(svc_rdma_ctxt_cachep);
 }
 
 int svc_rdma_init(void)
@@ -275,26 +272,12 @@ int svc_rdma_init(void)
 		goto err0;
 	}
 
-	/* Create the temporary context cache */
-	svc_rdma_ctxt_cachep =
-		kmem_cache_create("svc_rdma_ctxt_cache",
-				  sizeof(struct svc_rdma_op_ctxt),
-				  0,
-				  SLAB_HWCACHE_ALIGN,
-				  NULL);
-	if (!svc_rdma_ctxt_cachep) {
-		printk(KERN_INFO "Could not allocate WR ctxt cache.\n");
-		goto err1;
-	}
-
 	/* Register RDMA with the SVC transport switch */
 	svc_reg_xprt_class(&svc_rdma_class);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	svc_reg_xprt_class(&svc_rdma_bc_class);
 #endif
 	return 0;
- err1:
-	kmem_cache_destroy(svc_rdma_map_cachep);
  err0:
 	unregister_sysctl_table(svcrdma_table_header);
 	destroy_workqueue(svc_rdma_wq);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index b348b4a..ede88f3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -155,16 +155,27 @@ static void svc_rdma_bc_free(struct svc_xprt *xprt)
 
 struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
-	struct svc_rdma_op_ctxt *ctxt;
+	struct svc_rdma_op_ctxt *ctxt = NULL;
+
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	if (list_empty(&xprt->sc_ctxt_q))
+		goto out_empty;
+
+	ctxt = list_first_entry(&xprt->sc_ctxt_q,
+				       struct svc_rdma_op_ctxt, free_q);
+	list_del_init(&ctxt->free_q);
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
 
-	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
-				GFP_KERNEL | __GFP_NOFAIL);
-	ctxt->xprt = xprt;
-	INIT_LIST_HEAD(&ctxt->dto_q);
 	ctxt->count = 0;
 	ctxt->frmr = NULL;
+
 	atomic_inc(&xprt->sc_ctxt_used);
 	return ctxt;
+
+out_empty:
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	pr_err("svcrdma: empty RDMA ctxt list?\n");
+	return NULL;
 }
 
 void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
@@ -198,7 +209,27 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	kmem_cache_free(svc_rdma_ctxt_cachep, ctxt);
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	list_add(&ctxt->free_q, &xprt->sc_ctxt_q);
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+
+	atomic_dec(&xprt->sc_ctxt_used);
+}
+
+static void svc_rdma_put_context_irq(struct svc_rdma_op_ctxt *ctxt, int free_pages)
+{
+	struct svcxprt_rdma *xprt;
+	int i;
+
+	xprt = ctxt->xprt;
+	if (free_pages)
+		for (i = 0; i < ctxt->count; i++)
+			put_page(ctxt->pages[i]);
+
+	spin_lock(&xprt->sc_ctxt_lock);
+	list_add(&ctxt->free_q, &xprt->sc_ctxt_q);
+	spin_unlock(&xprt->sc_ctxt_lock);
+
 	atomic_dec(&xprt->sc_ctxt_used);
 }
 
@@ -357,7 +388,7 @@ static void rq_cq_reap(struct svcxprt_rdma *xprt)
 			/* Close the transport */
 			dprintk("svcrdma: transport closing putting ctxt %p\n", ctxt);
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-			svc_rdma_put_context(ctxt, 1);
+			svc_rdma_put_context_irq(ctxt, 1);
 			svc_xprt_put(&xprt->sc_xprt);
 			continue;
 		}
@@ -392,13 +423,13 @@ static void process_context(struct svcxprt_rdma *xprt,
 	case IB_WR_SEND:
 		if (ctxt->frmr)
 			pr_err("svcrdma: SEND: ctxt->frmr != NULL\n");
-		svc_rdma_put_context(ctxt, 1);
+		svc_rdma_put_context_irq(ctxt, 1);
 		break;
 
 	case IB_WR_RDMA_WRITE:
 		if (ctxt->frmr)
 			pr_err("svcrdma: WRITE: ctxt->frmr != NULL\n");
-		svc_rdma_put_context(ctxt, 0);
+		svc_rdma_put_context_irq(ctxt, 0);
 		break;
 
 	case IB_WR_RDMA_READ:
@@ -417,7 +448,7 @@ static void process_context(struct svcxprt_rdma *xprt,
 			}
 			svc_xprt_enqueue(&xprt->sc_xprt);
 		}
-		svc_rdma_put_context(ctxt, 0);
+		svc_rdma_put_context_irq(ctxt, 0);
 		break;
 
 	default:
@@ -523,9 +554,11 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_ctxt_q);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
+	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 
@@ -927,6 +960,21 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 				   (size_t)svcrdma_max_requests);
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
 
+	for (i = newxprt->sc_sq_depth; i; i--) {
+		struct svc_rdma_op_ctxt *ctxt;
+
+		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
+		if (!ctxt) {
+			dprintk("svcrdma: No memory for RDMA ctxt\n");
+			goto errout;
+		}
+
+		ctxt->xprt = newxprt;
+		INIT_LIST_HEAD(&ctxt->free_q);
+		INIT_LIST_HEAD(&ctxt->dto_q);
+		list_add(&ctxt->free_q, &newxprt->sc_ctxt_q);
+	}
+
 	/*
 	 * Limit ORD based on client limit, local device limit, and
 	 * configured svcrdma limit.
@@ -1222,6 +1270,14 @@ static void __svc_rdma_free(struct work_struct *work)
 	/* Destroy the CM ID */
 	rdma_destroy_id(rdma->sc_cm_id);
 
+	while (!list_empty(&rdma->sc_ctxt_q)) {
+		struct svc_rdma_op_ctxt *ctxt;
+		ctxt = list_first_entry(&rdma->sc_ctxt_q,
+				       struct svc_rdma_op_ctxt, free_q);
+		list_del(&ctxt->free_q);
+		kfree(ctxt);
+	}
+
 	kfree(rdma);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ac7f8d4..a1fd74a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -531,8 +531,6 @@ void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);
 
 /* Temporary NFS request map cache. Created in svc_rdma.c  */
 extern struct kmem_cache *svc_rdma_map_cachep;
-/* WR context cache. Created in svc_rdma.c  */
-extern struct kmem_cache *svc_rdma_ctxt_cachep;
 /* Workqueue created in svc_rdma.c */
 extern struct workqueue_struct *svc_rdma_wq;
 

