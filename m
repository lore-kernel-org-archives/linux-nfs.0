Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:62158 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbaFWWjw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:39:52 -0400
Subject: [PATCH v1 06/13] xprtrdma: Unclutter struct rpcrdma_mr_seg
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:39:50 -0400
Message-ID: <20140623223950.1634.11937.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/verbs.c     |    6 +++--
 net/sunrpc/xprtrdma/xprt_rdma.h |   44 +++++++++++++++++++++++++++++----------
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 451e100..e8ed81c 100644
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
@@ -1518,7 +1518,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, seg1->mr_chunk.rl_mw, i);
 
-	if (unlikely(seg1->mr_chunk.rl_mw->r.frmr.state == FRMR_IS_VALID)) {
+	if (unlikely(seg1->mr_chunk.rl_mw->r.frmr.fr_state == FRMR_IS_VALID)) {
 		dprintk("RPC:       %s: frmr %x left valid, posting invalidate.\n",
 			__func__,
 			seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c270e59..28c8570 100644
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
+	FRMR_IS_INVALID,
+	FRMR_IS_VALID,
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

