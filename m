Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34124 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbEDR6t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 13:58:49 -0400
Subject: [PATCH v1 13/14] xprtrdma: Stack relief in fmr_op_map()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 13:58:46 -0400
Message-ID: <20150504175846.3483.32959.stgit@manet.1015granger.net>
In-Reply-To: <20150504174626.3483.97639.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fmr_op_map() declares a 64 element array of u64 in automatic
storage. This is 512 bytes (8 * 64) on the stack.

Instead, when FMR memory registration is in use, pre-allocate a
physaddr array for each rpcrdma_mw.

This is a pre-requisite for increasing the r/wsize maximum for
FMR on platforms with 4KB pages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   32 ++++++++++++++++++++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 ++++++-
 2 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 52f9ad5..4a53ad5 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -72,13 +72,19 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
 	dprintk("RPC:       %s: initializing %d FMRs\n", __func__, i);
 
+	rc = -ENOMEM;
 	while (i--) {
 		r = kzalloc(sizeof(*r), GFP_KERNEL);
 		if (!r)
-			return -ENOMEM;
+			goto out;
+
+		r->r.fmr.physaddrs = kmalloc(RPCRDMA_MAX_FMR_SGES *
+					     sizeof(u64), GFP_KERNEL);
+		if (!r->r.fmr.physaddrs)
+			goto out_free;
 
-		r->r.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
-		if (IS_ERR(r->r.fmr))
+		r->r.fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
+		if (IS_ERR(r->r.fmr.fmr))
 			goto out_fmr_err;
 
 		list_add(&r->mw_list, &buf->rb_mws);
@@ -87,9 +93,12 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	return 0;
 
 out_fmr_err:
-	rc = PTR_ERR(r->r.fmr);
+	rc = PTR_ERR(r->r.fmr.fmr);
 	dprintk("RPC:       %s: ib_alloc_fmr status %i\n", __func__, rc);
+	kfree(r->r.fmr.physaddrs);
+out_free:
 	kfree(r);
+out:
 	return rc;
 }
 
@@ -98,7 +107,7 @@ __fmr_unmap(struct rpcrdma_mw *r)
 {
 	LIST_HEAD(l);
 
-	list_add(&r->r.fmr->list, &l);
+	list_add(&r->r.fmr.fmr->list, &l);
 	return ib_unmap_fmr(&l);
 }
 
@@ -113,7 +122,6 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	struct ib_device *device = ia->ri_device;
 	enum dma_data_direction direction = rpcrdma_data_dir(writing);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
 	int len, pageoff, i, rc;
 	struct rpcrdma_mw *mw;
 
@@ -138,7 +146,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
 		rpcrdma_map_one(device, seg, direction);
-		physaddrs[i] = seg->mr_dma;
+		mw->r.fmr.physaddrs[i] = seg->mr_dma;
 		len += seg->mr_len;
 		++seg;
 		++i;
@@ -148,12 +156,13 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 			break;
 	}
 
-	rc = ib_map_phys_fmr(mw->r.fmr, physaddrs, i, seg1->mr_dma);
+	rc = ib_map_phys_fmr(mw->r.fmr.fmr, mw->r.fmr.physaddrs,
+			     i, seg1->mr_dma);
 	if (rc)
 		goto out_maperr;
 
 	seg1->rl_mw = mw;
-	seg1->mr_rkey = mw->r.fmr->rkey;
+	seg1->mr_rkey = mw->r.fmr.fmr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
 	seg1->mr_len = len;
@@ -207,10 +216,13 @@ fmr_op_destroy(struct rpcrdma_buffer *buf)
 	while (!list_empty(&buf->rb_all)) {
 		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
 		list_del(&r->mw_all);
-		rc = ib_dealloc_fmr(r->r.fmr);
+		kfree(r->r.fmr.physaddrs);
+
+		rc = ib_dealloc_fmr(r->r.fmr.fmr);
 		if (rc)
 			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
 				__func__, rc);
+
 		kfree(r);
 	}
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ae31fc7..e176bae 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -207,9 +207,14 @@ struct rpcrdma_frmr {
 	struct rpcrdma_xprt		*fr_xprt;
 };
 
+struct rpcrdma_fmr {
+	struct ib_fmr		*fmr;
+	u64			*physaddrs;
+};
+
 struct rpcrdma_mw {
 	union {
-		struct ib_fmr		*fmr;
+		struct rpcrdma_fmr	fmr;
 		struct rpcrdma_frmr	frmr;
 	} r;
 	void			(*mw_sendcompletion)(struct ib_wc *);

