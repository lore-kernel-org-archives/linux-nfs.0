Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36595 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbbCMVXM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:23:12 -0400
Received: by iegc3 with SMTP id c3so130696802ieg.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:23:12 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id 192sm1992208ioo.38.2015.03.13.14.23.10
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:23:11 -0700 (PDT)
Subject: [PATCH v1 12/16] xprtrdma: Acquire FMRs in
 rpcrdma_fmr_register_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:23:09 -0400
Message-ID: <20150313212309.22471.8989.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acquiring 64 FMRs in rpcrdma_buffer_get() while holding the buffer
pool lock is expensive, and unnecessary because FMR mode can
transfer up to a 1MB payload using just a single ib_fmr.

Instead, acquire ib_fmrs one-at-a-time as chunks are registered, and
return them to rb_mws immediately during deregistration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   41 ++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/verbs.c     |   41 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 3 files changed, 54 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 96e6cd3..9c6c2e8 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -28,10 +28,11 @@ __fmr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
 	int rc, nsegs = seg->mr_nsegs;
 	LIST_HEAD(l);
 
-	list_add(&seg1->rl_mw->r.fmr->list, &l);
+	list_add(&mw->r.fmr->list, &l);
 	rc = ib_unmap_fmr(&l);
 	read_lock(&ia->ri_qplock);
 	while (seg1->mr_nsegs--)
@@ -39,11 +40,14 @@ __fmr_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
 	read_unlock(&ia->ri_qplock);
 	if (rc)
 		goto out_err;
+out:
+	seg1->rl_mw = NULL;
+	rpcrdma_put_mw(r_xprt, mw);
 	return nsegs;
 
 out_err:
 	dprintk("RPC:       %s: ib_unmap_fmr status %i\n", __func__, rc);
-	return nsegs;
+	goto out;
 }
 
 static int
@@ -117,6 +121,27 @@ out_fmr_err:
 	return rc;
 }
 
+static struct rpcrdma_mw *
+__fmr_get_mw(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_mw *mw = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+
+	if (!list_empty(&buf->rb_mws)) {
+		mw = list_entry(buf->rb_mws.next,
+				struct rpcrdma_mw, mw_list);
+		list_del_init(&mw->mw_list);
+	} else {
+		pr_err("RPC:       %s: no MWs available\n", __func__);
+	}
+
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+	return mw;
+}
+
 /* Use the ib_map_phys_fmr() verb to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
  */
@@ -126,10 +151,18 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->rl_mw;
+	struct rpcrdma_mw *mw;
 	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
 	int len, pageoff, i, rc;
 
+	mw = __fmr_get_mw(r_xprt);
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
@@ -152,6 +185,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (rc)
 		goto out_maperr;
 
+	seg1->rl_mw = mw;
 	seg1->mr_rkey = mw->r.fmr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
@@ -164,6 +198,7 @@ out_maperr:
 		pageoff, i, rc);
 	while (i--)
 		rpcrdma_unmap_one(ia, --seg);
+	rpcrdma_put_mw(r_xprt, mw);
 	return rc;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f108a57..f2316d8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1171,6 +1171,21 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
+void
+rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	unsigned long flags;
+
+	if (!list_empty(&mw->mw_list))
+		pr_warn("RPC:       %s: mw %p still on a list!\n",
+			__func__, mw);
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	list_add_tail(&mw->mw_list, &buf->rb_mws);
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+}
+
 /* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
  * some req segments uninitialized.
  */
@@ -1292,28 +1307,6 @@ rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
 	return NULL;
 }
 
-static struct rpcrdma_req *
-rpcrdma_buffer_get_fmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-	int i;
-
-	i = RPCRDMA_MAX_SEGS - 1;
-	while (!list_empty(&buf->rb_mws)) {
-		r = list_entry(buf->rb_mws.next,
-			       struct rpcrdma_mw, mw_list);
-		list_del(&r->mw_list);
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
@@ -1355,9 +1348,6 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 	case RPCRDMA_FRMR:
 		req = rpcrdma_buffer_get_frmrs(req, buffers, &stale);
 		break;
-	case RPCRDMA_MTHCAFMR:
-		req = rpcrdma_buffer_get_fmrs(req, buffers);
-		break;
 	default:
 		break;
 	}
@@ -1382,7 +1372,6 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	rpcrdma_buffer_put_sendbuf(req, buffers);
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-	case RPCRDMA_MTHCAFMR:
 		rpcrdma_buffer_put_mrs(req, buffers);
 		break;
 	default:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 40a0ee8..d5aa5b4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -426,6 +426,7 @@ void rpcrdma_free_regbuf(struct rpcrdma_ia *,
 unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
 void rpcrdma_map_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *, bool);
 void rpcrdma_unmap_one(struct rpcrdma_ia *, struct rpcrdma_mr_seg *);
+void rpcrdma_put_mw(struct rpcrdma_xprt *, struct rpcrdma_mw *);
 
 /*
  * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c

