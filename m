Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33617 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932884AbcFTQJJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:09:09 -0400
Subject: [PATCH v3 04/25] xprtrdma: Rename fields in rpcrdma_fmr
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:09:07 -0400
Message-ID: <20160620160907.10809.31155.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use the same naming convention used in other
RPC/RDMA-related data structures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |   36 ++++++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 ++--
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index b3f8699..a6a67b4 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -74,9 +74,9 @@ __fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
 		.page_shift	= PAGE_SHIFT
 	};
 
-	mw->fmr.physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
-				    sizeof(u64), GFP_KERNEL);
-	if (!mw->fmr.physaddrs)
+	mw->fmr.fm_physaddrs = kcalloc(RPCRDMA_MAX_FMR_SGES,
+				       sizeof(u64), GFP_KERNEL);
+	if (!mw->fmr.fm_physaddrs)
 		goto out_free;
 
 	mw->mw_sg = kcalloc(RPCRDMA_MAX_FMR_SGES,
@@ -86,21 +86,21 @@ __fmr_init(struct rpcrdma_mw *mw, struct ib_pd *pd)
 
 	sg_init_table(mw->mw_sg, RPCRDMA_MAX_FMR_SGES);
 
-	mw->fmr.fmr = ib_alloc_fmr(pd, RPCRDMA_FMR_ACCESS_FLAGS,
-				   &fmr_attr);
-	if (IS_ERR(mw->fmr.fmr))
+	mw->fmr.fm_mr = ib_alloc_fmr(pd, RPCRDMA_FMR_ACCESS_FLAGS,
+				     &fmr_attr);
+	if (IS_ERR(mw->fmr.fm_mr))
 		goto out_fmr_err;
 
-	INIT_LIST_HEAD(&mw->fmr.fmr->list);
+	INIT_LIST_HEAD(&mw->fmr.fm_mr->list);
 	return 0;
 
 out_fmr_err:
 	dprintk("RPC:       %s: ib_alloc_fmr returned %ld\n", __func__,
-		PTR_ERR(mw->fmr.fmr));
+		PTR_ERR(mw->fmr.fm_mr));
 
 out_free:
 	kfree(mw->mw_sg);
-	kfree(mw->fmr.physaddrs);
+	kfree(mw->fmr.fm_physaddrs);
 	return -ENOMEM;
 }
 
@@ -110,9 +110,9 @@ __fmr_unmap(struct rpcrdma_mw *mw)
 	LIST_HEAD(l);
 	int rc;
 
-	list_add(&mw->fmr.fmr->list, &l);
+	list_add(&mw->fmr.fm_mr->list, &l);
 	rc = ib_unmap_fmr(&l);
-	list_del_init(&mw->fmr.fmr->list);
+	list_del_init(&mw->fmr.fm_mr->list);
 	return rc;
 }
 
@@ -131,10 +131,10 @@ __fmr_release(struct rpcrdma_mw *r)
 {
 	int rc;
 
-	kfree(r->fmr.physaddrs);
+	kfree(r->fmr.fm_physaddrs);
 	kfree(r->mw_sg);
 
-	rc = ib_dealloc_fmr(r->fmr.fmr);
+	rc = ib_dealloc_fmr(r->fmr.fm_mr);
 	if (rc)
 		pr_err("rpcrdma: final ib_dealloc_fmr for %p returned %i\n",
 		       r, rc);
@@ -254,7 +254,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		nsegs = RPCRDMA_MAX_FMR_SGES;
 	for (i = 0; i < nsegs;) {
 		rpcrdma_map_one(device, seg, direction);
-		mw->fmr.physaddrs[i] = seg->mr_dma;
+		mw->fmr.fm_physaddrs[i] = seg->mr_dma;
 		len += seg->mr_len;
 		++seg;
 		++i;
@@ -264,13 +264,13 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 			break;
 	}
 
-	rc = ib_map_phys_fmr(mw->fmr.fmr, mw->fmr.physaddrs,
+	rc = ib_map_phys_fmr(mw->fmr.fm_mr, mw->fmr.fm_physaddrs,
 			     i, seg1->mr_dma);
 	if (rc)
 		goto out_maperr;
 
 	seg1->rl_mw = mw;
-	seg1->mr_rkey = mw->fmr.fmr->rkey;
+	seg1->mr_rkey = mw->fmr.fm_mr->rkey;
 	seg1->mr_base = seg1->mr_dma + pageoff;
 	seg1->mr_nsegs = i;
 	seg1->mr_len = len;
@@ -310,7 +310,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		list_add_tail(&mw->fmr.fmr->list, &unmap_list);
+		list_add_tail(&mw->fmr.fm_mr->list, &unmap_list);
 
 		i += seg->mr_nsegs;
 	}
@@ -325,7 +325,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		list_del_init(&mw->fmr.fmr->list);
+		list_del_init(&mw->fmr.fm_mr->list);
 		__fmr_dma_unmap(r_xprt, seg);
 		rpcrdma_put_mw(r_xprt, seg->rl_mw);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c53abd1..04696c0 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -232,8 +232,8 @@ struct rpcrdma_frmr {
 };
 
 struct rpcrdma_fmr {
-	struct ib_fmr		*fmr;
-	u64			*physaddrs;
+	struct ib_fmr		*fm_mr;
+	u64			*fm_physaddrs;
 };
 
 struct rpcrdma_mw {

