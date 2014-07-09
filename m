Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40425 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756579AbaGIQ5c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:57:32 -0400
Subject: [PATCH v2 07/21] xprtrdma: Unclutter struct rpcrdma_mr_seg
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:57:30 -0400
Message-ID: <20140709165730.3496.30188.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean ups:
 - make it obvious that the rl_mw field is a pointer -- allocated
   separately, not as part of struct rpcrdma_mr_seg
 - promote "struct {} frmr;" to a named type
 - promote the state enum to a named type
 - name the MW state field the same way other fields in
   rpcrdma_mw are named

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   33 ++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   44 +++++++++++++++++++++++++++++----------
 2 files changed, 49 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7fd457e..ce847d2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -156,9 +156,9 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 		return;
 
 	if (wc->opcode == IB_WC_FAST_REG_MR)
-		frmr->r.frmr.state = FRMR_IS_VALID;
+		frmr->r.frmr.fr_state = FRMR_IS_VALID;
 	else if (wc->opcode == IB_WC_LOCAL_INV)
-		frmr->r.frmr.state = FRMR_IS_INVALID;
+		frmr->r.frmr.fr_state = FRMR_IS_INVALID;
 }
 
 static int
@@ -1493,6 +1493,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
+	struct rpcrdma_frmr *frmr = &mw->r.frmr;
 	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
 
 	u8 key;
@@ -1512,8 +1514,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		rpcrdma_map_one(ia, seg, writing);
 		pa = seg->mr_dma;
 		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
-			seg1->mr_chunk.rl_mw->r.frmr.fr_pgl->
-				page_list[page_no++] = pa;
+			frmr->fr_pgl->page_list[page_no++] = pa;
 			pa += PAGE_SIZE;
 		}
 		len += seg->mr_len;
@@ -1525,20 +1526,18 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			break;
 	}
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
-		__func__, seg1->mr_chunk.rl_mw, i);
+		__func__, mw, i);
 
-	if (unlikely(seg1->mr_chunk.rl_mw->r.frmr.state == FRMR_IS_VALID)) {
+	if (unlikely(frmr->fr_state == FRMR_IS_VALID)) {
 		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
-			__func__,
-			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey);
+			__func__, frmr->fr_mr->rkey);
 		/* Invalidate before using. */
 		memset(&invalidate_wr, 0, sizeof invalidate_wr);
-		invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
+		invalidate_wr.wr_id = (unsigned long)(void *)mw;
 		invalidate_wr.next = &frmr_wr;
 		invalidate_wr.opcode = IB_WR_LOCAL_INV;
 		invalidate_wr.send_flags = IB_SEND_SIGNALED;
-		invalidate_wr.ex.invalidate_rkey =
-			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+		invalidate_wr.ex.invalidate_rkey = frmr->fr_mr->rkey;
 		DECR_CQCOUNT(&r_xprt->rx_ep);
 		post_wr = &invalidate_wr;
 	} else
@@ -1546,11 +1545,11 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 
 	/* Prepare FRMR WR */
 	memset(&frmr_wr, 0, sizeof frmr_wr);
-	frmr_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
+	frmr_wr.wr_id = (unsigned long)(void *)mw;
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
 	frmr_wr.send_flags = IB_SEND_SIGNALED;
 	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
-	frmr_wr.wr.fast_reg.page_list = seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
+	frmr_wr.wr.fast_reg.page_list = frmr->fr_pgl;
 	frmr_wr.wr.fast_reg.page_list_len = page_no;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
@@ -1560,13 +1559,13 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	}
 
 	/* Bump the key */
-	key = (u8)(seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey & 0x000000FF);
-	ib_update_fast_reg_key(seg1->mr_chunk.rl_mw->r.frmr.fr_mr, ++key);
+	key = (u8)(frmr->fr_mr->rkey & 0x000000FF);
+	ib_update_fast_reg_key(frmr->fr_mr, ++key);
 
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
-	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+	frmr_wr.wr.fast_reg.rkey = frmr->fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
 	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
@@ -1576,7 +1575,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			" status %i\n", __func__, rc);
 		goto out_err;
 	} else {
-		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+		seg1->mr_rkey = frmr->fr_mr->rkey;
 		seg1->mr_base = seg1->mr_dma + pageoff;
 		seg1->mr_nsegs = i;
 		seg1->mr_len = len;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c270e59..84c3455 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -146,6 +146,38 @@ struct rpcrdma_rep {
 };
 
 /*
+ * struct rpcrdma_mw - external memory region metadata
+ *
+ * An external memory region is any buffer or page that is registered
+ * on the fly (ie, not pre-registered).
+ *
+ * Each rpcrdma_buffer has a list of these anchored in rb_mws. During
+ * call_allocate, rpcrdma_buffer_get() assigns one to each segment in
+ * an rpcrdma_req. Then rpcrdma_register_external() grabs these to keep
+ * track of registration metadata while each RPC is pending.
+ * rpcrdma_deregister_external() uses this metadata to unmap and
+ * release these resources when an RPC is complete.
+ */
+enum rpcrdma_frmr_state {
+	FRMR_IS_INVALID,	/* ready to be used */
+	FRMR_IS_VALID,		/* in use */
+};
+
+struct rpcrdma_frmr {
+	struct ib_fast_reg_page_list	*fr_pgl;
+	struct ib_mr			*fr_mr;
+	enum rpcrdma_frmr_state		fr_state;
+};
+
+struct rpcrdma_mw {
+	union {
+		struct ib_fmr		*fmr;
+		struct rpcrdma_frmr	frmr;
+	} r;
+	struct list_head	mw_list;
+};
+
+/*
  * struct rpcrdma_req -- structure central to the request/reply sequence.
  *
  * N of these are associated with a transport instance, and stored in
@@ -172,17 +204,7 @@ struct rpcrdma_rep {
 struct rpcrdma_mr_seg {		/* chunk descriptors */
 	union {				/* chunk memory handles */
 		struct ib_mr	*rl_mr;		/* if registered directly */
-		struct rpcrdma_mw {		/* if registered from region */
-			union {
-				struct ib_fmr	*fmr;
-				struct {
-					struct ib_fast_reg_page_list *fr_pgl;
-					struct ib_mr *fr_mr;
-					enum { FRMR_IS_INVALID, FRMR_IS_VALID  } state;
-				} frmr;
-			} r;
-			struct list_head mw_list;
-		} *rl_mw;
+		struct rpcrdma_mw *rl_mw;	/* if registered from region */
 	} mr_chunk;
 	u64		mr_base;	/* registration result */
 	u32		mr_rkey;	/* registration result */

