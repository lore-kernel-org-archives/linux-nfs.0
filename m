Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:49971 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbaGOOWk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:22:40 -0400
Subject: [PATCH v3 17/21] xprtrdma: Allocate each struct rpcrdma_mw
 separately
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 15 Jul 2014 10:22:37 -0400
Message-ID: <20140715142237.8908.48493.stgit@manet.1015granger.net>
In-Reply-To: <20140715142020.8908.80969.stgit@manet.1015granger.net>
References: <20140715142020.8908.80969.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently rpcrdma_buffer_create() allocates struct rpcrdma_mw's as
a single contiguous area of memory. It amounts to quite a bit of
memory, and there's no requirement for these to be carved from a
single piece of contiguous memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c |  242 +++++++++++++++++++++++++------------------
 1 file changed, 143 insertions(+), 99 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1294338..f7691be 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1005,9 +1005,91 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	return rc;
 }
 
-/*
- * Initialize buffer memory
- */
+static int
+rpcrdma_init_fmrs(struct rpcrdma_ia *ia, struct rpcrdma_buffer *buf)
+{
+	int mr_access_flags = IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ;
+	struct ib_fmr_attr fmr_attr = {
+		.max_pages	= RPCRDMA_MAX_DATA_SEGS,
+		.max_maps	= 1,
+		.page_shift	= PAGE_SHIFT
+	};
+	struct rpcrdma_mw *r;
+	int i, rc;
+
+	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
+	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
+
+	while (i--) {
+		r = kzalloc(sizeof(*r), GFP_KERNEL);
+		if (r == NULL)
+			return -ENOMEM;
+
+		r->r.fmr = ib_alloc_fmr(ia->ri_pd, mr_access_flags, &fmr_attr);
+		if (IS_ERR(r->r.fmr)) {
+			rc = PTR_ERR(r->r.fmr);
+			dprintk("RPC:       %s: ib_alloc_fmr failed %i\n",
+				__func__, rc);
+			goto out_free;
+		}
+
+		list_add(&r->mw_list, &buf->rb_mws);
+		list_add(&r->mw_all, &buf->rb_all);
+	}
+	return 0;
+
+out_free:
+	kfree(r);
+	return rc;
+}
+
+static int
+rpcrdma_init_frmrs(struct rpcrdma_ia *ia, struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_frmr *f;
+	struct rpcrdma_mw *r;
+	int i, rc;
+
+	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
+	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
+
+	while (i--) {
+		r = kzalloc(sizeof(*r), GFP_KERNEL);
+		if (r == NULL)
+			return -ENOMEM;
+		f = &r->r.frmr;
+
+		f->fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
+						ia->ri_max_frmr_depth);
+		if (IS_ERR(f->fr_mr)) {
+			rc = PTR_ERR(f->fr_mr);
+			dprintk("RPC:       %s: ib_alloc_fast_reg_mr "
+				"failed %i\n", __func__, rc);
+			goto out_free;
+		}
+
+		f->fr_pgl = ib_alloc_fast_reg_page_list(ia->ri_id->device,
+							ia->ri_max_frmr_depth);
+		if (IS_ERR(f->fr_pgl)) {
+			rc = PTR_ERR(f->fr_pgl);
+			dprintk("RPC:       %s: ib_alloc_fast_reg_page_list "
+				"failed %i\n", __func__, rc);
+
+			ib_dereg_mr(f->fr_mr);
+			goto out_free;
+		}
+
+		list_add(&r->mw_list, &buf->rb_mws);
+		list_add(&r->mw_all, &buf->rb_all);
+	}
+
+	return 0;
+
+out_free:
+	kfree(r);
+	return rc;
+}
+
 int
 rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	struct rpcrdma_ia *ia, struct rpcrdma_create_data_internal *cdata)
@@ -1015,7 +1097,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	char *p;
 	size_t len, rlen, wlen;
 	int i, rc;
-	struct rpcrdma_mw *r;
 
 	buf->rb_max_requests = cdata->max_requests;
 	spin_lock_init(&buf->rb_lock);
@@ -1026,28 +1107,12 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	 *   2.  arrays of struct rpcrdma_req to fill in pointers
 	 *   3.  array of struct rpcrdma_rep for replies
 	 *   4.  padding, if any
-	 *   5.  mw's, fmr's or frmr's, if any
 	 * Send/recv buffers in req/rep need to be registered
 	 */
-
 	len = buf->rb_max_requests *
 		(sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
 	len += cdata->padding;
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR:
-		len += buf->rb_max_requests * RPCRDMA_MAX_SEGS *
-				sizeof(struct rpcrdma_mw);
-		break;
-	case RPCRDMA_MTHCAFMR:
-		/* TBD we are perhaps overallocating here */
-		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
-				sizeof(struct rpcrdma_mw);
-		break;
-	default:
-		break;
-	}
 
-	/* allocate 1, 4 and 5 in one shot */
 	p = kzalloc(len, GFP_KERNEL);
 	if (p == NULL) {
 		dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
@@ -1075,53 +1140,16 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
-	r = (struct rpcrdma_mw *)p;
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-		for (i = buf->rb_max_requests * RPCRDMA_MAX_SEGS; i; i--) {
-			r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
-						ia->ri_max_frmr_depth);
-			if (IS_ERR(r->r.frmr.fr_mr)) {
-				rc = PTR_ERR(r->r.frmr.fr_mr);
-				dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
-					" failed %i\n", __func__, rc);
-				goto out;
-			}
-			r->r.frmr.fr_pgl = ib_alloc_fast_reg_page_list(
-						ia->ri_id->device,
-						ia->ri_max_frmr_depth);
-			if (IS_ERR(r->r.frmr.fr_pgl)) {
-				rc = PTR_ERR(r->r.frmr.fr_pgl);
-				dprintk("RPC:       %s: "
-					"ib_alloc_fast_reg_page_list "
-					"failed %i\n", __func__, rc);
-
-				ib_dereg_mr(r->r.frmr.fr_mr);
-				goto out;
-			}
-			list_add(&r->mw_all, &buf->rb_all);
-			list_add(&r->mw_list, &buf->rb_mws);
-			++r;
-		}
+		rc = rpcrdma_init_frmrs(ia, buf);
+		if (rc)
+			goto out;
 		break;
 	case RPCRDMA_MTHCAFMR:
-		/* TBD we are perhaps overallocating here */
-		for (i = (buf->rb_max_requests+1) * RPCRDMA_MAX_SEGS; i; i--) {
-			static struct ib_fmr_attr fa =
-				{ RPCRDMA_MAX_DATA_SEGS, 1, PAGE_SHIFT };
-			r->r.fmr = ib_alloc_fmr(ia->ri_pd,
-				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ,
-				&fa);
-			if (IS_ERR(r->r.fmr)) {
-				rc = PTR_ERR(r->r.fmr);
-				dprintk("RPC:       %s: ib_alloc_fmr"
-					" failed %i\n", __func__, rc);
-				goto out;
-			}
-			list_add(&r->mw_all, &buf->rb_all);
-			list_add(&r->mw_list, &buf->rb_mws);
-			++r;
-		}
+		rc = rpcrdma_init_fmrs(ia, buf);
+		if (rc)
+			goto out;
 		break;
 	default:
 		break;
@@ -1189,24 +1217,57 @@ out:
 	return rc;
 }
 
-/*
- * Unregister and destroy buffer memory. Need to deal with
- * partial initialization, so it's callable from failed create.
- * Must be called before destroying endpoint, as registrations
- * reference it.
- */
+static void
+rpcrdma_destroy_fmrs(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mw *r;
+	int rc;
+
+	while (!list_empty(&buf->rb_all)) {
+		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
+		list_del(&r->mw_all);
+		list_del(&r->mw_list);
+
+		rc = ib_dealloc_fmr(r->r.fmr);
+		if (rc)
+			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
+				__func__, rc);
+
+		kfree(r);
+	}
+}
+
+static void
+rpcrdma_destroy_frmrs(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mw *r;
+	int rc;
+
+	while (!list_empty(&buf->rb_all)) {
+		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
+		list_del(&r->mw_all);
+		list_del(&r->mw_list);
+
+		rc = ib_dereg_mr(r->r.frmr.fr_mr);
+		if (rc)
+			dprintk("RPC:       %s: ib_dereg_mr failed %i\n",
+				__func__, rc);
+		ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
+
+		kfree(r);
+	}
+}
+
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
-	int rc, i;
 	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
-	struct rpcrdma_mw *r;
+	int i;
 
 	/* clean up in reverse order from create
 	 *   1.  recv mr memory (mr free, then kfree)
 	 *   2.  send mr memory (mr free, then kfree)
-	 *   3.  padding (if any) [moved to rpcrdma_ep_destroy]
-	 *   4.  arrays
+	 *   3.  MWs
 	 */
 	dprintk("RPC:       %s: entering\n", __func__);
 
@@ -1225,32 +1286,15 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		}
 	}
 
-	while (!list_empty(&buf->rb_mws)) {
-		r = list_entry(buf->rb_mws.next,
-			struct rpcrdma_mw, mw_list);
-		list_del(&r->mw_all);
-		list_del(&r->mw_list);
-		switch (ia->ri_memreg_strategy) {
-		case RPCRDMA_FRMR:
-			rc = ib_dereg_mr(r->r.frmr.fr_mr);
-			if (rc)
-				dprintk("RPC:       %s:"
-					" ib_dereg_mr"
-					" failed %i\n",
-					__func__, rc);
-			ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
-			break;
-		case RPCRDMA_MTHCAFMR:
-			rc = ib_dealloc_fmr(r->r.fmr);
-			if (rc)
-				dprintk("RPC:       %s:"
-					" ib_dealloc_fmr"
-					" failed %i\n",
-					__func__, rc);
-			break;
-		default:
-			break;
-		}
+	switch (ia->ri_memreg_strategy) {
+	case RPCRDMA_FRMR:
+		rpcrdma_destroy_frmrs(buf);
+		break;
+	case RPCRDMA_MTHCAFMR:
+		rpcrdma_destroy_fmrs(buf);
+		break;
+	default:
+		break;
 	}
 
 	kfree(buf->rb_pool);

