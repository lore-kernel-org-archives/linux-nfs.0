Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33122 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753007AbcKRO7V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 09:59:21 -0500
Subject: [PATCH v2 03/12] xprtrdma: Support for SG_GAP devices
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 09:59:20 -0500
Message-ID: <20161118145919.10592.23011.stgit@manet.1015granger.net>
In-Reply-To: <20161118145547.10592.66470.stgit@manet.1015granger.net>
References: <20161118145547.10592.66470.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some devices (such as the Mellanox CX-4) can register, under a
single R_key, a set of memory regions that are not contiguous. When
this is done, all the segments in a Reply list, say, can then be
invalidated in a single LocalInv Work Request (or via Remote
Invalidation, which can invalidate exactly one R_key when completing
a Receive).

This means a single FastReg WR is used to register, and one or zero
LocalInv WRs can invalidate, the memory involved with RDMA transfers
on behalf of an RPC.

In addition, xprtrdma constructs some Reply chunks from three or
more segments. By registering them with SG_GAP, only one segment
is needed for the Reply chunk, allowing the whole chunk to be
invalidated remotely.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   20 +++++++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index adbf52c..e99bf61 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -101,7 +101,7 @@
 	struct rpcrdma_frmr *f = &r->frmr;
 	int rc;
 
-	f->fr_mr = ib_alloc_mr(ia->ri_pd, IB_MR_TYPE_MEM_REG, depth);
+	f->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype, depth);
 	if (IS_ERR(f->fr_mr))
 		goto out_mr_err;
 
@@ -157,7 +157,7 @@
 		return rc;
 	}
 
-	f->fr_mr = ib_alloc_mr(ia->ri_pd, IB_MR_TYPE_MEM_REG,
+	f->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype,
 			       ia->ri_max_frmr_depth);
 	if (IS_ERR(f->fr_mr)) {
 		pr_warn("rpcrdma: ib_alloc_mr status %ld, frwr %p orphaned\n",
@@ -210,11 +210,16 @@
 frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	     struct rpcrdma_create_data_internal *cdata)
 {
+	struct ib_device_attr *attrs = &ia->ri_device->attrs;
 	int depth, delta;
 
+	ia->ri_mrtype = IB_MR_TYPE_MEM_REG;
+	if (attrs->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
+		ia->ri_mrtype = IB_MR_TYPE_SG_GAPS;
+
 	ia->ri_max_frmr_depth =
 			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-			      ia->ri_device->attrs.max_fast_reg_page_list_len);
+			      attrs->max_fast_reg_page_list_len);
 	dprintk("RPC:       %s: device's max FR page list len = %u\n",
 		__func__, ia->ri_max_frmr_depth);
 
@@ -241,8 +246,8 @@
 	}
 
 	ep->rep_attr.cap.max_send_wr *= depth;
-	if (ep->rep_attr.cap.max_send_wr > ia->ri_device->attrs.max_qp_wr) {
-		cdata->max_requests = ia->ri_device->attrs.max_qp_wr / depth;
+	if (ep->rep_attr.cap.max_send_wr > attrs->max_qp_wr) {
+		cdata->max_requests = attrs->max_qp_wr / depth;
 		if (!cdata->max_requests)
 			return -EINVAL;
 		ep->rep_attr.cap.max_send_wr = cdata->max_requests *
@@ -348,6 +353,7 @@
 	    int nsegs, bool writing, struct rpcrdma_mw **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
 	struct rpcrdma_mw *mw;
 	struct rpcrdma_frmr *frmr;
 	struct ib_mr *mr;
@@ -383,8 +389,8 @@
 
 		++seg;
 		++i;
-
-		/* Check for holes */
+		if (holes_ok)
+			continue;
 		if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f6ae1b2..b8424fa 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -75,6 +75,7 @@ struct rpcrdma_ia {
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
 	bool			ri_reminv_expected;
+	enum ib_mr_type		ri_mrtype;
 	struct ib_qp_attr	ri_qp_attr;
 	struct ib_qp_init_attr	ri_qp_init_attr;
 };

