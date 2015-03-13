Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38879 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbCMVXW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:23:22 -0400
Received: by igbhl2 with SMTP id hl2so842igb.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:23:21 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id p143sm1490379ioe.33.2015.03.13.14.23.19
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:23:20 -0700 (PDT)
Subject: [PATCH v1 13/16] xprtrdma: Acquire MRs in
 rpcrdma_register_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:23:19 -0400
Message-ID: <20150313212319.22471.37842.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acquiring 64 MRs in rpcrdma_buffer_get() while holding the buffer
pool lock is expensive, and unnecessary because most modern adapters
can transfer 100s of KBs of payload using just a single MR.

Instead, acquire MRs one-at-a-time as chunks are registered, and
return them to rb_mws immediately during deregistration.

Note: commit 539431a437d2 ("xprtrdma: Don't invalidate FRMRs if
registration fails") is reverted: There is now a valid case where
registration can fail (with -ENOMEM) but the QP is still in RTS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |  126 ++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/rpc_rdma.c |    3 -
 net/sunrpc/xprtrdma/verbs.c    |  130 ----------------------------------------
 3 files changed, 120 insertions(+), 139 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 6e6d8ba..d23e064 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -54,15 +54,16 @@ __frwr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc, nsegs = seg->mr_nsegs;
 
-	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
+	mw->r.frmr.fr_state = FRMR_IS_INVALID;
 
 	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
-	invalidate_wr.wr_id = (unsigned long)(void *)seg1->rl_mw;
+	invalidate_wr.wr_id = (unsigned long)(void *)mw;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
+	invalidate_wr.ex.invalidate_rkey = mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
 	read_lock(&ia->ri_qplock);
@@ -72,13 +73,17 @@ __frwr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	read_unlock(&ia->ri_qplock);
 	if (rc)
 		goto out_err;
+
+out:
+	seg1->rl_mw = NULL;
+	rpcrdma_put_mw(r_xprt, mw);
 	return nsegs;
 
 out_err:
 	/* Force rpcrdma_buffer_get() to retry */
-	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
+	mw->r.frmr.fr_state = FRMR_IS_STALE;
 	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
-	return nsegs;
+	goto out;
 }
 
 static void
@@ -217,6 +222,99 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 	return 0;
 }
 
+/* rpcrdma_unmap_one() was already done by rpcrdma_frwr_releasesge().
+ * Redo only the ib_post_send().
+ */
+static void
+__retry_local_inv(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
+{
+	struct rpcrdma_xprt *r_xprt =
+				container_of(ia, struct rpcrdma_xprt, rx_ia);
+	struct ib_send_wr invalidate_wr, *bad_wr;
+	int rc;
+
+	pr_warn("RPC:       %s: FRMR %p is stale\n", __func__, r);
+
+	/* When this FRMR is re-inserted into rb_mws, it is no longer stale */
+	r->r.frmr.fr_state = FRMR_IS_INVALID;
+
+	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
+	invalidate_wr.wr_id = (unsigned long)(void *)r;
+	invalidate_wr.opcode = IB_WR_LOCAL_INV;
+	invalidate_wr.ex.invalidate_rkey = r->r.frmr.fr_mr->rkey;
+	DECR_CQCOUNT(&r_xprt->rx_ep);
+
+	pr_warn("RPC:       %s: frmr %p invalidating rkey %08x\n",
+		__func__, r, r->r.frmr.fr_mr->rkey);
+
+	read_lock(&ia->ri_qplock);
+	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	read_unlock(&ia->ri_qplock);
+	if (rc) {
+		/* Force __frwr_get_mw() to retry */
+		r->r.frmr.fr_state = FRMR_IS_STALE;
+		dprintk("RPC:       %s: ib_post_send status %i\n",
+			__func__, rc);
+	}
+}
+
+static void
+__retry_flushed_linv(struct rpcrdma_buffer *buf, struct list_head *stale)
+{
+	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
+	struct list_head *pos;
+	struct rpcrdma_mw *r;
+	unsigned long flags;
+	unsigned count;
+
+	count = 0;
+	list_for_each(pos, stale) {
+		r = list_entry(pos, struct rpcrdma_mw, mw_list);
+		__retry_local_inv(ia, r);
+		++count;
+	}
+
+	pr_warn("RPC:       %s: adding %u MRs to rb_mws\n",
+		__func__, count);
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	list_splice_tail(stale, &buf->rb_mws);
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+}
+
+static struct rpcrdma_mw *
+__frwr_get_mw(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_mw *mw;
+	unsigned long flags;
+	LIST_HEAD(stale);
+	int count;
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	count = 0;
+	while (!list_empty(&buf->rb_mws)) {
+		mw = list_entry(buf->rb_mws.next, struct rpcrdma_mw, mw_list);
+		list_del_init(&mw->mw_list);
+		if (mw->r.frmr.fr_state == FRMR_IS_INVALID)
+			goto out_unlock;
+		list_add_tail(&mw->mw_list, &stale);
+		count++;
+	}
+
+	pr_err("RPC:       %s: no INVALID MWs available\n", __func__);
+	mw = NULL;
+
+out_unlock:
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+	if (!list_empty(&stale)) {
+		dprintk("RPC:       %s: found %d unsuitable MWs\n",
+			__func__, count);
+		__retry_flushed_linv(buf, &stale);
+	}
+	return mw;
+}
+
 /* Post a FAST_REG Work Request to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -226,9 +324,9 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
-	struct rpcrdma_frmr *frmr = &mw->r.frmr;
-	struct ib_mr *mr = frmr->fr_mr;
+	struct rpcrdma_frmr *frmr;
+	struct rpcrdma_mw *mw;
+	struct ib_mr *mr;
 	struct ib_send_wr fastreg_wr, *bad_wr;
 	u8 key;
 	int len, pageoff;
@@ -237,12 +335,21 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	u64 pa;
 	int page_no;
 
+	mw = __frwr_get_mw(r_xprt);
+	if (!mw)
+		return -ENOMEM;
+	if (seg1->rl_mw) {
+		rpcrdma_put_mw(r_xprt, seg1->rl_mw);
+		seg1->rl_mw = NULL;
+	}
+
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
 	seg1->mr_len += pageoff;
 	len = -pageoff;
 	if (nsegs > ia->ri_max_frmr_depth)
 		nsegs = ia->ri_max_frmr_depth;
+	frmr = &mw->r.frmr;
 	for (page_no = i = 0; i < nsegs;) {
 		rpcrdma_map_one(ia, seg, writing);
 		pa = seg->mr_dma;
@@ -278,6 +385,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	fastreg_wr.wr.fast_reg.access_flags = writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ;
+	mr = frmr->fr_mr;
 	key = (u8)(mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(mr, ++key);
 	fastreg_wr.wr.fast_reg.rkey = mr->rkey;
@@ -287,6 +395,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_senderr;
 
+	seg1->rl_mw = mw;
 	seg1->mr_rkey = mr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
@@ -301,6 +410,7 @@ out_err:
 	frmr->fr_state = FRMR_IS_INVALID;
 	while (i--)
 		rpcrdma_unmap_one(ia, --seg);
+	rpcrdma_put_mw(r_xprt, mw);
 	return rc;
 }
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 7b51d9d..b9689ca 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -284,8 +284,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	return (unsigned char *)iptr - (unsigned char *)headerp;
 
 out:
-	if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_FRMR)
-		r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt, req, nchunks);
+	r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt, req, nchunks);
 	return n;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f2316d8..5b9c104 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1186,33 +1186,6 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 	spin_unlock_irqrestore(&buf->rb_lock, flags);
 }
 
-/* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
- * some req segments uninitialized.
- */
-static void
-rpcrdma_buffer_put_mr(struct rpcrdma_mw **mw, struct rpcrdma_buffer *buf)
-{
-	if (*mw) {
-		list_add_tail(&(*mw)->mw_list, &buf->rb_mws);
-		*mw = NULL;
-	}
-}
-
-/* Cycle mw's back in reverse order, and "spin" them.
- * This delays and scrambles reuse as much as possible.
- */
-static void
-rpcrdma_buffer_put_mrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mr_seg *seg = req->rl_segments;
-	struct rpcrdma_mr_seg *seg1 = seg;
-	int i;
-
-	for (i = 1, seg++; i < RPCRDMA_MAX_SEGS; seg++, i++)
-		rpcrdma_buffer_put_mr(&seg->rl_mw, buf);
-	rpcrdma_buffer_put_mr(&seg1->rl_mw, buf);
-}
-
 static void
 rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 {
@@ -1225,88 +1198,6 @@ rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	}
 }
 
-/* rpcrdma_unmap_one() was already done during deregistration.
- * Redo only the ib_post_send().
- */
-static void
-rpcrdma_retry_local_inv(struct rpcrdma_mw *r, struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_xprt *r_xprt =
-				container_of(ia, struct rpcrdma_xprt, rx_ia);
-	struct ib_send_wr invalidate_wr, *bad_wr;
-	int rc;
-
-	dprintk("RPC:       %s: FRMR %p is stale\n", __func__, r);
-
-	/* When this FRMR is re-inserted into rb_mws, it is no longer stale */
-	r->r.frmr.fr_state = FRMR_IS_INVALID;
-
-	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
-	invalidate_wr.wr_id = (unsigned long)(void *)r;
-	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.ex.invalidate_rkey = r->r.frmr.fr_mr->rkey;
-	DECR_CQCOUNT(&r_xprt->rx_ep);
-
-	dprintk("RPC:       %s: frmr %p invalidating rkey %08x\n",
-		__func__, r, r->r.frmr.fr_mr->rkey);
-
-	read_lock(&ia->ri_qplock);
-	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
-	read_unlock(&ia->ri_qplock);
-	if (rc) {
-		/* Force rpcrdma_buffer_get() to retry */
-		r->r.frmr.fr_state = FRMR_IS_STALE;
-		dprintk("RPC:       %s: ib_post_send failed, %i\n",
-			__func__, rc);
-	}
-}
-
-static void
-rpcrdma_retry_flushed_linv(struct list_head *stale,
-			   struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
-	struct list_head *pos;
-	struct rpcrdma_mw *r;
-	unsigned long flags;
-
-	list_for_each(pos, stale) {
-		r = list_entry(pos, struct rpcrdma_mw, mw_list);
-		rpcrdma_retry_local_inv(r, ia);
-	}
-
-	spin_lock_irqsave(&buf->rb_lock, flags);
-	list_splice_tail(stale, &buf->rb_mws);
-	spin_unlock_irqrestore(&buf->rb_lock, flags);
-}
-
-static struct rpcrdma_req *
-rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
-			 struct list_head *stale)
-{
-	struct rpcrdma_mw *r;
-	int i;
-
-	i = RPCRDMA_MAX_SEGS - 1;
-	while (!list_empty(&buf->rb_mws)) {
-		r = list_entry(buf->rb_mws.next,
-			       struct rpcrdma_mw, mw_list);
-		list_del(&r->mw_list);
-		if (r->r.frmr.fr_state == FRMR_IS_STALE) {
-			list_add(&r->mw_list, stale);
-			continue;
-		}
-		req->rl_segments[i].rl_mw = r;
-		if (unlikely(i-- == 0))
-			return req;	/* Success */
-	}
-
-	/* Not enough entries on rb_mws for this req */
-	rpcrdma_buffer_put_sendbuf(req, buf);
-	rpcrdma_buffer_put_mrs(req, buf);
-	return NULL;
-}
-
 /*
  * Get a set of request/reply buffers.
  *
@@ -1319,12 +1210,11 @@ rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 {
-	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
-	struct list_head stale;
 	struct rpcrdma_req *req;
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
+
 	if (buffers->rb_send_index == buffers->rb_max_requests) {
 		spin_unlock_irqrestore(&buffers->rb_lock, flags);
 		dprintk("RPC:       %s: out of request buffers\n", __func__);
@@ -1343,17 +1233,7 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 	}
 	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
 
-	INIT_LIST_HEAD(&stale);
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR:
-		req = rpcrdma_buffer_get_frmrs(req, buffers, &stale);
-		break;
-	default:
-		break;
-	}
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
-	if (!list_empty(&stale))
-		rpcrdma_retry_flushed_linv(&stale, buffers);
 	return req;
 }
 
@@ -1365,18 +1245,10 @@ void
 rpcrdma_buffer_put(struct rpcrdma_req *req)
 {
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
-	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
 	rpcrdma_buffer_put_sendbuf(req, buffers);
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR:
-		rpcrdma_buffer_put_mrs(req, buffers);
-		break;
-	default:
-		break;
-	}
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 }
 

