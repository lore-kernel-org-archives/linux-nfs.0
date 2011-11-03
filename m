Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756424Ab1KCSWn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 14:22:43 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pA3IMhSE031298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Nov 2011 14:22:43 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pA3IMg9w017767
	for <linux-nfs@vger.kernel.org>; Thu, 3 Nov 2011 14:22:42 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] RDMA: Remove defunct memory window and FMR registrations
Date: Thu,  3 Nov 2011 14:52:39 -0400
Message-Id: <1320346359-1515-2-git-send-email-steved@redhat.com>
In-Reply-To: <1320346359-1515-1-git-send-email-steved@redhat.com>
References: <1320346359-1515-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patch removes support for memory window and FMR registrations
which in turn makes the code a bit easier to read.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/xprtrdma.h |    6 +-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   33 +-----
 net/sunrpc/xprtrdma/transport.c |    5 -
 net/sunrpc/xprtrdma/verbs.c     |  273 +--------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +-
 5 files changed, 7 insertions(+), 315 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index c2f04e1..196992b 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -67,9 +67,9 @@
 enum rpcrdma_memreg {
 	RPCRDMA_BOUNCEBUFFERS = 0,
 	RPCRDMA_REGISTER,
-	RPCRDMA_MEMWINDOWS,
-	RPCRDMA_MEMWINDOWS_ASYNC,
-	RPCRDMA_MTHCAFMR,
+	RPCRDMA_XXX1,			/* defunct - was MEMWINDOWS */
+	RPCRDMA_XXX2,			/* defunct - was MEMWINDOWS_ASYNC */
+	RPCRDMA_XXX3,			/* defunct - was MTHCAFMR */
 	RPCRDMA_FRMR,
 	RPCRDMA_ALLPHYSICAL,
 	RPCRDMA_LAST
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 554d081..caeacf9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -707,16 +707,6 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
 }
 
 /*
- * This function is called when memory window unbind which we are waiting
- * for completes. Just use rr_func (zeroed by upcall) to signal completion.
- */
-static void
-rpcrdma_unbind_func(struct rpcrdma_rep *rep)
-{
-	wake_up(&rep->rr_unbind);
-}
-
-/*
  * Called as a tasklet to do req/reply match and complete a request
  * Errors must result in the RPC task either being awakened, or
  * allowed to timeout, to discover the errors at that time.
@@ -730,7 +720,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpc_xprt *xprt = rep->rr_xprt;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	__be32 *iptr;
-	int i, rdmalen, status;
+	int rdmalen, status;
 
 	/* Check status. If bad, signal disconnect and return rep to pool */
 	if (rep->rr_len == ~0U) {
@@ -854,27 +844,6 @@ badheader:
 		break;
 	}
 
-	/* If using mw bind, start the deregister process now. */
-	/* (Note: if mr_free(), cannot perform it here, in tasklet context) */
-	if (req->rl_nchunks) switch (r_xprt->rx_ia.ri_memreg_strategy) {
-	case RPCRDMA_MEMWINDOWS:
-		for (i = 0; req->rl_nchunks-- > 1;)
-			i += rpcrdma_deregister_external(
-				&req->rl_segments[i], r_xprt, NULL);
-		/* Optionally wait (not here) for unbinds to complete */
-		rep->rr_func = rpcrdma_unbind_func;
-		(void) rpcrdma_deregister_external(&req->rl_segments[i],
-						   r_xprt, rep);
-		break;
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-		for (i = 0; req->rl_nchunks--;)
-			i += rpcrdma_deregister_external(&req->rl_segments[i],
-							 r_xprt, NULL);
-		break;
-	default:
-		break;
-	}
-
 	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
 			__func__, xprt, rqst, status);
 	xprt_complete_rqst(rqst->rq_task, status);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index b446e10..4188f24 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -598,11 +598,6 @@ xprt_rdma_free(void *buffer)
 			&req->rl_segments[i], r_xprt, NULL);
 	}
 
-	if (rep && wait_event_interruptible(rep->rr_unbind, !rep->rr_func)) {
-		rep->rr_func = NULL;	/* abandon the callback */
-		req->rl_reply = NULL;
-	}
-
 	if (req->rl_iov.length == 0) {	/* see allocate above */
 		struct rpcrdma_req *oreq = (struct rpcrdma_req *)req->rl_buffer;
 		oreq->rl_reply = req->rl_reply;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 68ba0fb..e1e0079 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -494,33 +494,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	}
 
 	switch (memreg) {
-	case RPCRDMA_MEMWINDOWS:
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-		if (!(devattr.device_cap_flags & IB_DEVICE_MEM_WINDOW)) {
-			dprintk("RPC:       %s: MEMWINDOWS registration "
-				"specified but not supported by adapter, "
-				"using slower RPCRDMA_REGISTER\n",
-				__func__);
-			memreg = RPCRDMA_REGISTER;
-		}
-		break;
-	case RPCRDMA_MTHCAFMR:
-		if (!ia->ri_id->device->alloc_fmr) {
-#if RPCRDMA_PERSISTENT_REGISTRATION
-			dprintk("RPC:       %s: MTHCAFMR registration "
-				"specified but not supported by adapter, "
-				"using riskier RPCRDMA_ALLPHYSICAL\n",
-				__func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
-#else
-			dprintk("RPC:       %s: MTHCAFMR registration "
-				"specified but not supported by adapter, "
-				"using slower RPCRDMA_REGISTER\n",
-				__func__);
-			memreg = RPCRDMA_REGISTER;
-#endif
-		}
-		break;
 	case RPCRDMA_FRMR:
 		/* Requires both frmr reg and local dma lkey */
 		if ((devattr.device_cap_flags &
@@ -561,18 +534,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		mem_priv = IB_ACCESS_LOCAL_WRITE |
 				IB_ACCESS_REMOTE_WRITE |
 				IB_ACCESS_REMOTE_READ;
-		goto register_setup;
 #endif
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		mem_priv = IB_ACCESS_LOCAL_WRITE |
-				IB_ACCESS_MW_BIND;
-		goto register_setup;
-	case RPCRDMA_MTHCAFMR:
-		if (ia->ri_have_dma_lkey)
-			break;
-		mem_priv = IB_ACCESS_LOCAL_WRITE;
-	register_setup:
 		ia->ri_bind_mem = ib_get_dma_mr(ia->ri_pd, mem_priv);
 		if (IS_ERR(ia->ri_bind_mem)) {
 			printk(KERN_ALERT "%s: ib_get_dma_mr for "
@@ -677,14 +639,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 			ep->rep_attr.cap.max_send_wr = cdata->max_requests * 7;
 		}
 		break;
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		/* Add room for mw_binds+unbinds - overkill! */
-		ep->rep_attr.cap.max_send_wr++;
-		ep->rep_attr.cap.max_send_wr *= (2 * RPCRDMA_MAX_SEGS);
-		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr)
-			return -EINVAL;
-		break;
 	default:
 		break;
 	}
@@ -706,14 +660,6 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* set trigger for requesting send completion */
 	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 /*  - 1*/;
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		ep->rep_cqinit -= RPCRDMA_MAX_SEGS;
-		break;
-	default:
-		break;
-	}
 	if (ep->rep_cqinit <= 2)
 		ep->rep_cqinit = 0;
 	INIT_CQCOUNT(ep);
@@ -980,7 +926,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	 *   2.  arrays of struct rpcrdma_req to fill in pointers
 	 *   3.  array of struct rpcrdma_rep for replies
 	 *   4.  padding, if any
-	 *   5.  mw's, fmr's or frmr's, if any
+	 *   5.  frmr's, if any
 	 * Send/recv buffers in req/rep need to be registered
 	 */
 
@@ -992,16 +938,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 		len += buf->rb_max_requests * RPCRDMA_MAX_SEGS *
 				sizeof(struct rpcrdma_mw);
 		break;
-	case RPCRDMA_MTHCAFMR:
-		/* TBD we are perhaps overallocating here */
-		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
-				sizeof(struct rpcrdma_mw);
-		break;
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
-				sizeof(struct rpcrdma_mw);
-		break;
 	default:
 		break;
 	}
@@ -1033,7 +969,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	p += cdata->padding;
 
 	/*
-	 * Allocate the fmr's, or mw's for mw_bind chunk registration.
+	 * Allocate any frmr's for mw_bind chunk registration.
 	 * We "cycle" the mw's in order to minimize rkey reuse,
 	 * and also reduce unbind-to-bind collision.
 	 */
@@ -1064,39 +1000,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 			++r;
 		}
 		break;
-	case RPCRDMA_MTHCAFMR:
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
-			list_add(&r->mw_list, &buf->rb_mws);
-			++r;
-		}
-		break;
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		/* Allocate one extra request's worth, for full cycling */
-		for (i = (buf->rb_max_requests+1) * RPCRDMA_MAX_SEGS; i; i--) {
-			r->r.mw = ib_alloc_mw(ia->ri_pd);
-			if (IS_ERR(r->r.mw)) {
-				rc = PTR_ERR(r->r.mw);
-				dprintk("RPC:       %s: ib_alloc_mw"
-					" failed %i\n", __func__, rc);
-				goto out;
-			}
-			list_add(&r->mw_list, &buf->rb_mws);
-			++r;
-		}
-		break;
 	default:
 		break;
 	}
@@ -1145,7 +1048,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 		memset(rep, 0, sizeof(struct rpcrdma_rep));
 		buf->rb_recv_bufs[i] = rep;
 		buf->rb_recv_bufs[i]->rr_buffer = buf;
-		init_waitqueue_head(&rep->rr_unbind);
 
 		rc = rpcrdma_register_internal(ia, rep->rr_base,
 				len - offsetof(struct rpcrdma_rep, rr_base),
@@ -1208,23 +1110,6 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 							__func__, rc);
 					ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
 					break;
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
 				default:
 					break;
 				}
@@ -1305,15 +1190,11 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	req->rl_niovs = 0;
 	if (req->rl_reply) {
 		buffers->rb_recv_bufs[--buffers->rb_recv_index] = req->rl_reply;
-		init_waitqueue_head(&req->rl_reply->rr_unbind);
 		req->rl_reply->rr_func = NULL;
 		req->rl_reply = NULL;
 	}
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
-	case RPCRDMA_MTHCAFMR:
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
 		/*
 		 * Cycle mw's back in reverse order, and "spin" them.
 		 * This delays and scrambles reuse as much as possible.
@@ -1593,136 +1474,6 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
 }
 
 static int
-rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg,
-			int *nsegs, int writing, struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
-	int len, pageoff, i, rc;
-
-	pageoff = offset_in_page(seg1->mr_offset);
-	seg1->mr_offset -= pageoff;	/* start of page */
-	seg1->mr_len += pageoff;
-	len = -pageoff;
-	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
-		*nsegs = RPCRDMA_MAX_DATA_SEGS;
-	for (i = 0; i < *nsegs;) {
-		rpcrdma_map_one(ia, seg, writing);
-		physaddrs[i] = seg->mr_dma;
-		len += seg->mr_len;
-		++seg;
-		++i;
-		/* Check for holes */
-		if ((i < *nsegs && offset_in_page(seg->mr_offset)) ||
-		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
-			break;
-	}
-	rc = ib_map_phys_fmr(seg1->mr_chunk.rl_mw->r.fmr,
-				physaddrs, i, seg1->mr_dma);
-	if (rc) {
-		dprintk("RPC:       %s: failed ib_map_phys_fmr "
-			"%u@0x%llx+%i (%d)... status %i\n", __func__,
-			len, (unsigned long long)seg1->mr_dma,
-			pageoff, i, rc);
-		while (i--)
-			rpcrdma_unmap_one(ia, --seg);
-	} else {
-		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.fmr->rkey;
-		seg1->mr_base = seg1->mr_dma + pageoff;
-		seg1->mr_nsegs = i;
-		seg1->mr_len = len;
-	}
-	*nsegs = i;
-	return rc;
-}
-
-static int
-rpcrdma_deregister_fmr_external(struct rpcrdma_mr_seg *seg,
-			struct rpcrdma_ia *ia)
-{
-	struct rpcrdma_mr_seg *seg1 = seg;
-	LIST_HEAD(l);
-	int rc;
-
-	list_add(&seg1->mr_chunk.rl_mw->r.fmr->list, &l);
-	rc = ib_unmap_fmr(&l);
-	while (seg1->mr_nsegs--)
-		rpcrdma_unmap_one(ia, seg++);
-	if (rc)
-		dprintk("RPC:       %s: failed ib_unmap_fmr,"
-			" status %i\n", __func__, rc);
-	return rc;
-}
-
-static int
-rpcrdma_register_memwin_external(struct rpcrdma_mr_seg *seg,
-			int *nsegs, int writing, struct rpcrdma_ia *ia,
-			struct rpcrdma_xprt *r_xprt)
-{
-	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
-				  IB_ACCESS_REMOTE_READ);
-	struct ib_mw_bind param;
-	int rc;
-
-	*nsegs = 1;
-	rpcrdma_map_one(ia, seg, writing);
-	param.mr = ia->ri_bind_mem;
-	param.wr_id = 0ULL;	/* no send cookie */
-	param.addr = seg->mr_dma;
-	param.length = seg->mr_len;
-	param.send_flags = 0;
-	param.mw_access_flags = mem_priv;
-
-	DECR_CQCOUNT(&r_xprt->rx_ep);
-	rc = ib_bind_mw(ia->ri_id->qp, seg->mr_chunk.rl_mw->r.mw, &param);
-	if (rc) {
-		dprintk("RPC:       %s: failed ib_bind_mw "
-			"%u@0x%llx status %i\n",
-			__func__, seg->mr_len,
-			(unsigned long long)seg->mr_dma, rc);
-		rpcrdma_unmap_one(ia, seg);
-	} else {
-		seg->mr_rkey = seg->mr_chunk.rl_mw->r.mw->rkey;
-		seg->mr_base = param.addr;
-		seg->mr_nsegs = 1;
-	}
-	return rc;
-}
-
-static int
-rpcrdma_deregister_memwin_external(struct rpcrdma_mr_seg *seg,
-			struct rpcrdma_ia *ia,
-			struct rpcrdma_xprt *r_xprt, void **r)
-{
-	struct ib_mw_bind param;
-	LIST_HEAD(l);
-	int rc;
-
-	BUG_ON(seg->mr_nsegs != 1);
-	param.mr = ia->ri_bind_mem;
-	param.addr = 0ULL;	/* unbind */
-	param.length = 0;
-	param.mw_access_flags = 0;
-	if (*r) {
-		param.wr_id = (u64) (unsigned long) *r;
-		param.send_flags = IB_SEND_SIGNALED;
-		INIT_CQCOUNT(&r_xprt->rx_ep);
-	} else {
-		param.wr_id = 0ULL;
-		param.send_flags = 0;
-		DECR_CQCOUNT(&r_xprt->rx_ep);
-	}
-	rc = ib_bind_mw(ia->ri_id->qp, seg->mr_chunk.rl_mw->r.mw, &param);
-	rpcrdma_unmap_one(ia, seg);
-	if (rc)
-		dprintk("RPC:       %s: failed ib_(un)bind_mw,"
-			" status %i\n", __func__, rc);
-	else
-		*r = NULL;	/* will upcall on completion */
-	return rc;
-}
-
-static int
 rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 			int *nsegs, int writing, struct rpcrdma_ia *ia)
 {
@@ -1807,17 +1558,6 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 		rc = rpcrdma_register_frmr_external(seg, &nsegs, writing, ia, r_xprt);
 		break;
 
-	/* Registration using fmr memory registration */
-	case RPCRDMA_MTHCAFMR:
-		rc = rpcrdma_register_fmr_external(seg, &nsegs, writing, ia);
-		break;
-
-	/* Registration using memory windows */
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		rc = rpcrdma_register_memwin_external(seg, &nsegs, writing, ia, r_xprt);
-		break;
-
 	/* Default registration each time */
 	default:
 		rc = rpcrdma_register_default_external(seg, &nsegs, writing, ia);
@@ -1850,15 +1590,6 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 		rc = rpcrdma_deregister_frmr_external(seg, ia, r_xprt);
 		break;
 
-	case RPCRDMA_MTHCAFMR:
-		rc = rpcrdma_deregister_fmr_external(seg, ia);
-		break;
-
-	case RPCRDMA_MEMWINDOWS_ASYNC:
-	case RPCRDMA_MEMWINDOWS:
-		rc = rpcrdma_deregister_memwin_external(seg, ia, r_xprt, &r);
-		break;
-
 	default:
 		rc = rpcrdma_deregister_default_external(seg, ia);
 		break;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 8d588f2..10285db 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -125,7 +125,6 @@ struct rpcrdma_rep {
 	struct rpc_xprt	*rr_xprt;	/* needed for request/reply matching */
 	void (*rr_func)(struct rpcrdma_rep *);/* called by tasklet in softint */
 	struct list_head rr_list;	/* tasklet list */
-	wait_queue_head_t rr_unbind;	/* optional unbind wait */
 	struct ib_sge	rr_iov;		/* for posting */
 	struct ib_mr	*rr_handle;	/* handle for mem in rr_iov */
 	char	rr_base[MAX_RPCRDMAHDR]; /* minimal inline receive buffer */
@@ -160,8 +159,6 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 		struct ib_mr	*rl_mr;		/* if registered directly */
 		struct rpcrdma_mw {		/* if registered from region */
 			union {
-				struct ib_mw	*mw;
-				struct ib_fmr	*fmr;
 				struct {
 					struct ib_fast_reg_page_list *fr_pgl;
 					struct ib_mr *fr_mr;
@@ -210,7 +207,7 @@ struct rpcrdma_buffer {
 	atomic_t	rb_credits;	/* most recent server credits */
 	unsigned long	rb_cwndscale;	/* cached framework rpc_cwndscale */
 	int		rb_max_requests;/* client max requests */
-	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
+	struct list_head rb_mws;	/* optional frmrs */
 	int		rb_send_index;
 	struct rpcrdma_req	**rb_send_bufs;
 	int		rb_recv_index;
-- 
1.7.1

