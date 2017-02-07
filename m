Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34626 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbdBGQ66 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 11:58:58 -0500
Subject: [PATCH v3 6/7] svcrdma: Combine list fields in struct
 svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Feb 2017 11:58:56 -0500
Message-ID: <20170207165856.14422.75768.stgit@klimt.1015granger.net>
In-Reply-To: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The free list and the dto_q list fields are never used at
the same time. Reduce the size of struct svc_rdma_op_ctxt by
combining these fields.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/svc_rdma.h          |    3 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   14 +++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   33 ++++++++++++++----------------
 3 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f77a7bc..b105f73 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -70,7 +70,7 @@
  * completes.
  */
 struct svc_rdma_op_ctxt {
-	struct list_head free;
+	struct list_head list;
 	struct svc_rdma_op_ctxt *read_hdr;
 	struct svc_rdma_fastreg_mr *frmr;
 	int hdr_count;
@@ -78,7 +78,6 @@ struct svc_rdma_op_ctxt {
 	struct ib_cqe cqe;
 	struct ib_cqe reg_cqe;
 	struct ib_cqe inv_cqe;
-	struct list_head dto_q;
 	u32 byte_len;
 	u32 position;
 	struct svcxprt_rdma *xprt;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 172b537..b9ccd73 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -608,18 +608,16 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
-		ctxt = list_entry(rdma_xprt->sc_read_complete_q.next,
-				  struct svc_rdma_op_ctxt,
-				  dto_q);
-		list_del_init(&ctxt->dto_q);
+		ctxt = list_first_entry(&rdma_xprt->sc_read_complete_q,
+					struct svc_rdma_op_ctxt, list);
+		list_del(&ctxt->list);
 		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
 		rdma_read_complete(rqstp, ctxt);
 		goto complete;
 	} else if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
-		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
-				  struct svc_rdma_op_ctxt,
-				  dto_q);
-		list_del_init(&ctxt->dto_q);
+		ctxt = list_first_entry(&rdma_xprt->sc_rq_dto_q,
+					struct svc_rdma_op_ctxt, list);
+		list_del(&ctxt->list);
 	} else {
 		atomic_inc(&rdma_stat_rq_starve);
 		clear_bit(XPT_DATA, &xprt->xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 023eaa0..87b8b5a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -157,8 +157,7 @@ static struct svc_rdma_op_ctxt *alloc_ctxt(struct svcxprt_rdma *xprt,
 	ctxt = kmalloc(sizeof(*ctxt), flags);
 	if (ctxt) {
 		ctxt->xprt = xprt;
-		INIT_LIST_HEAD(&ctxt->free);
-		INIT_LIST_HEAD(&ctxt->dto_q);
+		INIT_LIST_HEAD(&ctxt->list);
 	}
 	return ctxt;
 }
@@ -180,7 +179,7 @@ static bool svc_rdma_prealloc_ctxts(struct svcxprt_rdma *xprt)
 			dprintk("svcrdma: No memory for RDMA ctxt\n");
 			return false;
 		}
-		list_add(&ctxt->free, &xprt->sc_ctxts);
+		list_add(&ctxt->list, &xprt->sc_ctxts);
 	}
 	return true;
 }
@@ -195,8 +194,8 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 		goto out_empty;
 
 	ctxt = list_first_entry(&xprt->sc_ctxts,
-				struct svc_rdma_op_ctxt, free);
-	list_del_init(&ctxt->free);
+				struct svc_rdma_op_ctxt, list);
+	list_del(&ctxt->list);
 	spin_unlock_bh(&xprt->sc_ctxt_lock);
 
 out:
@@ -256,7 +255,7 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 
 	spin_lock_bh(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used--;
-	list_add(&ctxt->free, &xprt->sc_ctxts);
+	list_add(&ctxt->list, &xprt->sc_ctxts);
 	spin_unlock_bh(&xprt->sc_ctxt_lock);
 }
 
@@ -266,8 +265,8 @@ static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
 		struct svc_rdma_op_ctxt *ctxt;
 
 		ctxt = list_first_entry(&xprt->sc_ctxts,
-					struct svc_rdma_op_ctxt, free);
-		list_del(&ctxt->free);
+					struct svc_rdma_op_ctxt, list);
+		list_del(&ctxt->list);
 		kfree(ctxt);
 	}
 }
@@ -404,7 +403,7 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	/* All wc fields are now known to be valid */
 	ctxt->byte_len = wc->byte_len;
 	spin_lock(&xprt->sc_rq_dto_lock);
-	list_add_tail(&ctxt->dto_q, &xprt->sc_rq_dto_q);
+	list_add_tail(&ctxt->list, &xprt->sc_rq_dto_q);
 	spin_unlock(&xprt->sc_rq_dto_lock);
 
 	set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
@@ -525,7 +524,7 @@ void svc_rdma_wc_read(struct ib_cq *cq, struct ib_wc *wc)
 
 		read_hdr = ctxt->read_hdr;
 		spin_lock(&xprt->sc_rq_dto_lock);
-		list_add_tail(&read_hdr->dto_q,
+		list_add_tail(&read_hdr->list,
 			      &xprt->sc_read_complete_q);
 		spin_unlock(&xprt->sc_rq_dto_lock);
 
@@ -1213,20 +1212,18 @@ static void __svc_rdma_free(struct work_struct *work)
 	 */
 	while (!list_empty(&rdma->sc_read_complete_q)) {
 		struct svc_rdma_op_ctxt *ctxt;
-		ctxt = list_entry(rdma->sc_read_complete_q.next,
-				  struct svc_rdma_op_ctxt,
-				  dto_q);
-		list_del_init(&ctxt->dto_q);
+		ctxt = list_first_entry(&rdma->sc_read_complete_q,
+					struct svc_rdma_op_ctxt, list);
+		list_del(&ctxt->list);
 		svc_rdma_put_context(ctxt, 1);
 	}
 
 	/* Destroy queued, but not processed recv completions */
 	while (!list_empty(&rdma->sc_rq_dto_q)) {
 		struct svc_rdma_op_ctxt *ctxt;
-		ctxt = list_entry(rdma->sc_rq_dto_q.next,
-				  struct svc_rdma_op_ctxt,
-				  dto_q);
-		list_del_init(&ctxt->dto_q);
+		ctxt = list_first_entry(&rdma->sc_rq_dto_q,
+					struct svc_rdma_op_ctxt, list);
+		list_del(&ctxt->list);
 		svc_rdma_put_context(ctxt, 1);
 	}
 

