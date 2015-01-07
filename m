Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:55930 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbbAGXMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:12:46 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so112099igd.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:12:45 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id q10sm1685225iga.12.2015.01.07.15.12.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:12:45 -0800 (PST)
Subject: [PATCH v1 07/20] xprtrdma: Remove rl_mr field,
 and the mr_chunk union
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:12:44 -0500
Message-ID: <20150107231244.13466.8212.stgit@manet.1015granger.net>
In-Reply-To: <20150107230859.13466.67723.stgit@manet.1015granger.net>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Since commit 0ac531c18323 ("xprtrdma: Remove REGISTER memory
registration mode"), the rl_mr pointer is no longer used anywhere.

After removal, there's only a single member of the mr_chunk union,
so mr_chunk can be removed as well, in favor of a single pointer
field.

Fixes: 0ac531c18323 ("xprtrdma: Remove REGISTER memory ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   25 ++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +----
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 56e14b3..1000f63 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1493,8 +1493,8 @@ rpcrdma_buffer_put_mrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	int i;
 
 	for (i = 1, seg++; i < RPCRDMA_MAX_SEGS; seg++, i++)
-		rpcrdma_buffer_put_mr(&seg->mr_chunk.rl_mw, buf);
-	rpcrdma_buffer_put_mr(&seg1->mr_chunk.rl_mw, buf);
+		rpcrdma_buffer_put_mr(&seg->rl_mw, buf);
+	rpcrdma_buffer_put_mr(&seg1->rl_mw, buf);
 }
 
 static void
@@ -1580,7 +1580,7 @@ rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
 			list_add(&r->mw_list, stale);
 			continue;
 		}
-		req->rl_segments[i].mr_chunk.rl_mw = r;
+		req->rl_segments[i].rl_mw = r;
 		if (unlikely(i-- == 0))
 			return req;	/* Success */
 	}
@@ -1602,7 +1602,7 @@ rpcrdma_buffer_get_fmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 		r = list_entry(buf->rb_mws.next,
 			       struct rpcrdma_mw, mw_list);
 		list_del(&r->mw_list);
-		req->rl_segments[i].mr_chunk.rl_mw = r;
+		req->rl_segments[i].rl_mw = r;
 		if (unlikely(i-- == 0))
 			return req;	/* Success */
 	}
@@ -1842,7 +1842,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 			struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
+	struct rpcrdma_mw *mw = seg1->rl_mw;
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
 	struct ib_mr *mr = frmr->fr_mr;
 	struct ib_send_wr fastreg_wr, *bad_wr;
@@ -1931,12 +1931,12 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc;
 
-	seg1->mr_chunk.rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
+	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
 
 	memset(&invalidate_wr, 0, sizeof invalidate_wr);
-	invalidate_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
+	invalidate_wr.wr_id = (unsigned long)(void *)seg1->rl_mw;
 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
-	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
+	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
 	read_lock(&ia->ri_qplock);
@@ -1946,7 +1946,7 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 	read_unlock(&ia->ri_qplock);
 	if (rc) {
 		/* Force rpcrdma_buffer_get() to retry */
-		seg1->mr_chunk.rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
+		seg1->rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
 			" status %i\n", __func__, rc);
 	}
@@ -1978,8 +1978,7 @@ rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg,
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
-	rc = ib_map_phys_fmr(seg1->mr_chunk.rl_mw->r.fmr,
-				physaddrs, i, seg1->mr_dma);
+	rc = ib_map_phys_fmr(seg1->rl_mw->r.fmr, physaddrs, i, seg1->mr_dma);
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_map_phys_fmr "
 			"%u@0x%llx+%i (%d)... status %i\n", __func__,
@@ -1988,7 +1987,7 @@ rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg,
 		while (i--)
 			rpcrdma_unmap_one(ia, --seg);
 	} else {
-		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.fmr->rkey;
+		seg1->mr_rkey = seg1->rl_mw->r.fmr->rkey;
 		seg1->mr_base = seg1->mr_dma + pageoff;
 		seg1->mr_nsegs = i;
 		seg1->mr_len = len;
@@ -2005,7 +2004,7 @@ rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
 	LIST_HEAD(l);
 	int rc;
 
-	list_add(&seg1->mr_chunk.rl_mw->r.fmr->list, &l);
+	list_add(&seg1->rl_mw->r.fmr->list, &l);
 	rc = ib_unmap_fmr(&l);
 	read_lock(&ia->ri_qplock);
 	while (seg1->mr_nsegs--)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5160a84..532d586 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -210,10 +210,7 @@ struct rpcrdma_mw {
  */
 
 struct rpcrdma_mr_seg {		/* chunk descriptors */
-	union {				/* chunk memory handles */
-		struct ib_mr	*rl_mr;		/* if registered directly */
-		struct rpcrdma_mw *rl_mw;	/* if registered from region */
-	} mr_chunk;
+	struct rpcrdma_mw *rl_mw;	/* registered MR */
 	u64		mr_base;	/* registration result */
 	u32		mr_rkey;	/* registration result */
 	u32		mr_len;		/* length of chunk or segment */

