From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCHv2, RFC] xprtrdma: Update the RPC memory registration to use
 FRMR
Date: Thu, 21 Aug 2008 20:26:42 -0500
Message-ID: <48AE15D2.1060906@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Tom Talpey <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60980 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751236AbYHVB0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 21:26:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond:

This is an updated version of the xprtrdma client patch that supports FRMR. The
only difference is a slight refactoring to remove the local block variable allocation
in the affected switch statements. There are many other bits of code that do this,
but I believe that this level of editing should be done in a separate patch set.

This patch is also available here:
git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git

Use FRMR when registering client memory if the memory registration
strategy is FRMR.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  net/sunrpc/xprtrdma/verbs.c |  298 +++++++++++++++++++++++++++++++++++++-----
  1 files changed, 262 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8ea283e..edf520c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -423,6 +423,7 @@ rpcrdma_clean_cq(struct ib_cq *cq)
  int
  rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
  {
+	struct ib_device_attr devattr;
  	int rc;
  	struct rpcrdma_ia *ia = &xprt->rx_ia;

@@ -443,6 +444,49 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
  	}

  	/*
+	 * Query the device to determine if the requested memory
+	 * registration strategy is supported. If it isnt't, set the
+	 * strategy to a globally supported model.
+	 */
+	rc = ib_query_device(ia->ri_id->device, &devattr);
+	if (rc) {
+		dprintk("RPC:       %s: ib_query_device failed %d\n",
+			__func__, rc);
+		goto out2;
+	}
+	switch (memreg) {
+	case RPCRDMA_MEMWINDOWS:
+	case RPCRDMA_MEMWINDOWS_ASYNC:
+		if (!(devattr.device_cap_flags & IB_DEVICE_MEM_WINDOW)) {
+			dprintk("RPC:       %s: MEMWINDOWS specified but not "
+				"supported, using RPCRDMA_ALLPHYSICAL",
+				__func__);
+			memreg = RPCRDMA_ALLPHYSICAL;
+		}
+		break;
+	case RPCRDMA_MTHCAFMR:
+		if (!ia->ri_id->device->alloc_fmr) {
+			dprintk("RPC:       %s: MTHCAFMR specified but not "
+				"supported, using RPCRDMA_ALLPHYSICAL",
+				__func__);
+			memreg = RPCRDMA_ALLPHYSICAL;
+		}
+		break;
+	case RPCRDMA_FASTREG:
+		/* Requires both fast reg and global dma lkey */
+		if ((0 ==
+		     (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS)) ||
+		    (0 == (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY))) {
+			dprintk("RPC:       %s: FASTREG specified but not "
+				"supported, using RPCRDMA_ALLPHYSICAL",
+				__func__);
+			memreg = RPCRDMA_ALLPHYSICAL;
+		}
+		break;
+	}
+	dprintk("RPC:       memory registration strategy is %d\n", memreg);
+
+	/*
  	 * Optionally obtain an underlying physical identity mapping in
  	 * order to do a memory window-based bind. This base registration
  	 * is protected from remote access - that is enabled only by binding
@@ -450,7 +494,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
  	 * revoked after the corresponding completion similar to a storage
  	 * adapter.
  	 */
-	if (memreg > RPCRDMA_REGISTER) {
+	if ((memreg > RPCRDMA_REGISTER) && (memreg != RPCRDMA_FASTREG)) {
  		int mem_priv = IB_ACCESS_LOCAL_WRITE;
  		switch (memreg) {
  #if RPCRDMA_PERSISTENT_REGISTRATION
@@ -475,7 +519,10 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
  			memreg = RPCRDMA_REGISTER;
  			ia->ri_bind_mem = NULL;
  		}
+		ia->ri_dma_lkey = ia->ri_bind_mem->lkey;
  	}
+	if (memreg == RPCRDMA_FASTREG)
+		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;

  	/* Else will do memory reg/dereg for each chunk */
  	ia->ri_memreg_strategy = memreg;
@@ -541,6 +588,12 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
  	ep->rep_attr.srq = NULL;
  	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
  	switch (ia->ri_memreg_strategy) {
+	case RPCRDMA_FASTREG:
+		/* Add room for fast reg and invalidate */
+		ep->rep_attr.cap.max_send_wr *= 3;
+		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr)
+			return -EINVAL;
+		break;
  	case RPCRDMA_MEMWINDOWS_ASYNC:
  	case RPCRDMA_MEMWINDOWS:
  		/* Add room for mw_binds+unbinds - overkill! */
@@ -623,6 +676,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
  		break;
  	case RPCRDMA_MTHCAFMR:
  	case RPCRDMA_REGISTER:
+	case RPCRDMA_FASTREG:
  		ep->rep_remote_cma.responder_resources = cdata->max_requests *
  				(RPCRDMA_MAX_DATA_SEGS / 8);
  		break;
@@ -863,9 +917,11 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
  	char *p;
  	size_t len;
  	int i, rc;
+	struct rpcrdma_frmr *fr;

  	buf->rb_max_requests = cdata->max_requests;
  	spin_lock_init(&buf->rb_lock);
+	spin_lock_init(&buf->rb_frs_lock);
  	atomic_set(&buf->rb_credits, 1);

  	/* Need to allocate:
@@ -874,6 +930,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
  	 *   3.  array of struct rpcrdma_rep for replies
  	 *   4.  padding, if any
  	 *   5.  mw's, if any
+	 *   6.  frmr's, if any
  	 * Send/recv buffers in req/rep need to be registered
  	 */

@@ -881,6 +938,10 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
  		(sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
  	len += cdata->padding;
  	switch (ia->ri_memreg_strategy) {
+	case RPCRDMA_FASTREG:
+		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
+				sizeof(struct rpcrdma_frmr);
+		break;
  	case RPCRDMA_MTHCAFMR:
  		/* TBD we are perhaps overallocating here */
  		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
@@ -895,7 +956,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
  		break;
  	}

-	/* allocate 1, 4 and 5 in one shot */
+	/* allocate 1, 4, 5 and 6 in one shot */
  	p = kzalloc(len, GFP_KERNEL);
  	if (p == NULL) {
  		dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
@@ -927,7 +988,36 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
  	 * and also reduce unbind-to-bind collision.
  	 */
  	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_frs);
  	switch (ia->ri_memreg_strategy) {
+	case RPCRDMA_FASTREG:
+		fr = (struct rpcrdma_frmr *)p;
+		for (i = (buf->rb_max_requests+1) * RPCRDMA_MAX_SEGS; i; i--) {
+			fr->fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
+							 RPCRDMA_MAX_SEGS);
+			if (IS_ERR(fr->fr_mr)) {
+				rc = PTR_ERR(fr->fr_mr);
+				printk("RPC:       %s: ib_alloc_fast_reg_mr"
+					" failed %i\n", __func__, rc);
+				goto out;
+			}
+			fr->fr_pgl =
+				ib_alloc_fast_reg_page_list(ia->ri_id->device,
+							    RPCRDMA_MAX_SEGS);
+			if (IS_ERR(fr->fr_pgl)) {
+				rc = PTR_ERR(fr->fr_pgl);
+				printk("RPC:       %s: "
+					"ib_alloc_fast_reg_page_list "
+					"failed %i\n", __func__, rc);
+				goto out;
+			}
+			INIT_LIST_HEAD(&fr->fr_list);
+			list_add(&fr->fr_list, &buf->rb_frs);
+			dprintk("RPC:       %s alloc fmr %p pgl %p\n", __func__,
+				fr->fr_mr, fr->fr_pgl);
+			++fr;
+		}
+		break;
  	case RPCRDMA_MTHCAFMR:
  		{
  		struct rpcrdma_mw *r = (struct rpcrdma_mw *)p;
@@ -1056,6 +1146,49 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
  	 */
  	dprintk("RPC:       %s: entering\n", __func__);

+	while (!list_empty(&buf->rb_frs)) {
+		struct rpcrdma_frmr *fr =
+			list_entry(buf->rb_frs.next,
+				   struct rpcrdma_frmr, fr_list);
+		list_del(&fr->fr_list);
+		rc = ib_dereg_mr(fr->fr_mr);
+		if (rc)
+			dprintk("RPC:       %s:"
+				" ib_dereg_mr"
+				" failed %i\n",
+				__func__, rc);
+		ib_free_fast_reg_page_list(fr->fr_pgl);
+	}
+
+	while (!list_empty(&buf->rb_mws)) {
+		struct rpcrdma_mw *r;
+		switch (ia->ri_memreg_strategy) {
+		case RPCRDMA_MTHCAFMR:
+			r = list_entry(buf->rb_mws.next,
+				       struct rpcrdma_mw, mw_list);
+			list_del(&r->mw_list);
+			rc = ib_dealloc_fmr(r->r.fmr);
+			if (rc)
+				dprintk("RPC:       %s:"
+					" ib_dealloc_fmr"
+					" failed %i\n",
+					__func__, rc);
+			break;
+		case RPCRDMA_MEMWINDOWS_ASYNC:
+		case RPCRDMA_MEMWINDOWS:
+			r = list_entry(buf->rb_mws.next,
+				       struct rpcrdma_mw, mw_list);
+			list_del(&r->mw_list);
+			rc = ib_dealloc_mw(r->r.mw);
+			if (rc)
+				dprintk("RPC:       %s: ib_dealloc_mw "
+					"failed %i\n", __func__, rc);
+			break;
+		default:
+			break;
+		}
+	}
+
  	for (i = 0; i < buf->rb_max_requests; i++) {
  		if (buf->rb_recv_bufs && buf->rb_recv_bufs[i]) {
  			rpcrdma_deregister_internal(ia,
@@ -1064,33 +1197,6 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
  			kfree(buf->rb_recv_bufs[i]);
  		}
  		if (buf->rb_send_bufs && buf->rb_send_bufs[i]) {
-			while (!list_empty(&buf->rb_mws)) {
-				struct rpcrdma_mw *r;
-				r = list_entry(buf->rb_mws.next,
-					struct rpcrdma_mw, mw_list);
-				list_del(&r->mw_list);
-				switch (ia->ri_memreg_strategy) {
-				case RPCRDMA_MTHCAFMR:
-					rc = ib_dealloc_fmr(r->r.fmr);
-					if (rc)
-						dprintk("RPC:       %s:"
-							" ib_dealloc_fmr"
-							" failed %i\n",
-							__func__, rc);
-					break;
-				case RPCRDMA_MEMWINDOWS_ASYNC:
-				case RPCRDMA_MEMWINDOWS:
-					rc = ib_dealloc_mw(r->r.mw);
-					if (rc)
-						dprintk("RPC:       %s:"
-							" ib_dealloc_mw"
-							" failed %i\n",
-							__func__, rc);
-					break;
-				default:
-					break;
-				}
-			}
  			rpcrdma_deregister_internal(ia,
  					buf->rb_send_bufs[i]->rl_handle,
  					&buf->rb_send_bufs[i]->rl_iov);
@@ -1115,6 +1221,7 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
  {
  	struct rpcrdma_req *req;
  	unsigned long flags;
+	int i;

  	spin_lock_irqsave(&buffers->rb_lock, flags);
  	if (buffers->rb_send_index == buffers->rb_max_requests) {
@@ -1134,8 +1241,11 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
  		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
  	}
  	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
+	for (i = 0; i < RPCRDMA_MAX_SEGS; i++)
+		req->rl_segments[i].mr_chunk.rl_fr = NULL;
+
  	if (!list_empty(&buffers->rb_mws)) {
-		int i = RPCRDMA_MAX_SEGS - 1;
+		i = RPCRDMA_MAX_SEGS - 1;
  		do {
  			struct rpcrdma_mw *r;
  			r = list_entry(buffers->rb_mws.next,
@@ -1148,6 +1258,31 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
  	return req;
  }

+static void
+rpcrdma_free_frmr(struct rpcrdma_buffer *buf, struct rpcrdma_frmr *fr_mr)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&buf->rb_frs_lock, flags);
+	list_add(&fr_mr->fr_list, &buf->rb_frs);
+	spin_unlock_irqrestore(&buf->rb_frs_lock, flags);
+}
+
+static struct rpcrdma_frmr *
+rpcrdma_alloc_frmr(struct rpcrdma_buffer *buf)
+{
+	unsigned long flags;
+	struct rpcrdma_frmr *fr_mr = NULL;
+
+	spin_lock_irqsave(&buf->rb_frs_lock, flags);
+	if (!list_empty(&buf->rb_frs)) {
+		fr_mr = list_entry(buf->rb_frs.next,
+				   struct rpcrdma_frmr, fr_list);
+		list_del_init(&fr_mr->fr_list);
+	}
+	spin_unlock_irqrestore(&buf->rb_frs_lock, flags);
+	return fr_mr;
+}
+
  /*
   * Put request/reply buffers back into pool.
   * Pre-decrement counter/array index.
@@ -1252,9 +1387,10 @@ rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
  			va, len, DMA_BIDIRECTIONAL);
  	iov->length = len;

-	if (ia->ri_bind_mem != NULL) {
+	if (RPCRDMA_FASTREG == ia->ri_memreg_strategy ||
+	    ia->ri_bind_mem) {
  		*mrp = NULL;
-		iov->lkey = ia->ri_bind_mem->lkey;
+		iov->lkey = ia->ri_dma_lkey;
  		return 0;
  	}

@@ -1302,6 +1438,43 @@ rpcrdma_deregister_internal(struct rpcrdma_ia *ia,
  /*
   * Wrappers for chunk registration, shared by read/write chunk code.
   */
+static int
+rpcrdma_fastreg_seg(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *mr,
+		    int nsegs, u32 access)
+{
+	struct ib_send_wr invalidate_wr, fastreg_wr, *bad_wr;
+	u8 key;
+	u32 rkey = mr->mr_chunk.rl_fr->fr_mr->rkey;
+	int ret;
+
+	/* Prepare INVALIDATE WR */
+	memset(&invalidate_wr, 0, sizeof invalidate_wr);
+	invalidate_wr.opcode = IB_WR_LOCAL_INV;
+	invalidate_wr.send_flags = IB_SEND_SIGNALED;
+	invalidate_wr.ex.invalidate_rkey = rkey;
+	invalidate_wr.next = &fastreg_wr;
+
+	/* Bump the key */
+	key = (u8)(mr->mr_chunk.rl_fr->fr_mr->rkey & 0x000000FF);
+	ib_update_fast_reg_key(mr->mr_chunk.rl_fr->fr_mr, ++key);
+
+	/* Prepare FASTREG WR */
+	memset(&fastreg_wr, 0, sizeof fastreg_wr);
+	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
+	fastreg_wr.send_flags = IB_SEND_SIGNALED;
+	fastreg_wr.wr.fast_reg.iova_start = (unsigned long)mr->mr_dma;
+	fastreg_wr.wr.fast_reg.page_list = mr->mr_chunk.rl_fr->fr_pgl;
+	fastreg_wr.wr.fast_reg.page_list_len = nsegs;
+	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
+	fastreg_wr.wr.fast_reg.length = nsegs << PAGE_SHIFT;
+	fastreg_wr.wr.fast_reg.access_flags = access;
+	fastreg_wr.wr.fast_reg.rkey = mr->mr_chunk.rl_fr->fr_mr->rkey;
+	ret = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	dprintk("RPC:       %s fast reg rkey %08x kva %llx map_len "
+		"%d page_list_len %d ret %d\n", __func__,
+		rkey, mr->mr_dma, nsegs << PAGE_SHIFT, nsegs, ret);
+	return ret;
+}

  static void
  rpcrdma_map_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg, int writing)
@@ -1337,6 +1510,8 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
  				  IB_ACCESS_REMOTE_READ);
  	struct rpcrdma_mr_seg *seg1 = seg;
+	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
+	int len, pageoff;
  	int i;
  	int rc = 0;

@@ -1353,10 +1528,52 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
  #endif

  	/* Registration using fast memory registration */
+	case RPCRDMA_FASTREG:
+		pageoff = offset_in_page(seg->mr_offset);
+		seg1->mr_chunk.rl_fr = rpcrdma_alloc_frmr(&r_xprt->rx_buf);
+		if (!seg1->mr_chunk.rl_fr) {
+			printk("RPC:       Failed to allocate frmr\n");
+			rc = -ENOMEM;
+			break;
+		}
+		seg1->mr_offset -= pageoff;	/* start of page */
+		seg1->mr_len += pageoff;
+		len = -pageoff;
+		if (nsegs > RPCRDMA_MAX_DATA_SEGS)
+			nsegs = RPCRDMA_MAX_DATA_SEGS;
+		for (i = 0; i < nsegs;) {
+			rpcrdma_map_one(ia, seg, writing);
+			seg1->mr_chunk.rl_fr->fr_pgl->page_list[i] = seg->mr_dma;
+			len += seg->mr_len;
+			++seg;
+			++i;
+			/* Check for holes */
+			if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
+			    offset_in_page((seg-1)->mr_offset+(seg-1)->mr_len))
+				break;
+		}
+		nsegs = i;
+		dprintk("RPC:       %s: Using fmr %p to map %d segments\n",
+			__func__, seg1->mr_chunk.rl_fr, nsegs);
+		rc = rpcrdma_fastreg_seg(ia, seg1, nsegs, mem_priv);
+		if (rc) {
+			printk("RPC:       %s: failed ib_map_phys_fmr "
+				"%u@0x%llx+%i (%d)... status %i\n", __func__,
+				len, (unsigned long long)seg1->mr_dma,
+				pageoff, nsegs, rc);
+			while (nsegs--)
+				rpcrdma_unmap_one(ia, --seg);
+		} else {
+			seg1->mr_rkey = seg1->mr_chunk.rl_fr->fr_mr->rkey;
+			seg1->mr_base = seg1->mr_dma + pageoff;
+			seg1->mr_nsegs = nsegs;
+			seg1->mr_len = len;
+		}
+		break;
+
+	/* Registration using MTHCA FMR */
  	case RPCRDMA_MTHCAFMR:
-		{
-		u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
-		int len, pageoff = offset_in_page(seg->mr_offset);
+		pageoff = offset_in_page(seg->mr_offset);
  		seg1->mr_offset -= pageoff;	/* start of page */
  		seg1->mr_len += pageoff;
  		len = -pageoff;
@@ -1389,7 +1606,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
  			seg1->mr_nsegs = nsegs;
  			seg1->mr_len = len;
  		}
-		}
  		break;

  	/* Registration using memory windows */
@@ -1486,6 +1702,16 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
  		break;
  #endif

+	case RPCRDMA_FASTREG:
+		while (seg1->mr_nsegs--) {
+			if (seg1->mr_chunk.rl_fr) {
+				rpcrdma_free_frmr(&r_xprt->rx_buf, seg1->mr_chunk.rl_fr);
+				seg1->mr_chunk.rl_fr = NULL;
+			}
+			rpcrdma_unmap_one(ia, seg++);
+		}
+		break;
+
  	case RPCRDMA_MTHCAFMR:
  		{
  		LIST_HEAD(l);
