Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38783 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbbEGKa7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:30:59 -0400
Received: by wiun10 with SMTP id n10so54251833wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:30:57 -0700 (PDT)
Message-ID: <554B3EEB.7070302@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:31:07 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 08/14] xprtrdma: Acquire MRs in rpcrdma_register_external()
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175758.3483.44890.stgit@manet.1015granger.net>
In-Reply-To: <20150504175758.3483.44890.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:57 PM, Chuck Lever wrote:
> Acquiring 64 MRs in rpcrdma_buffer_get() while holding the buffer
> pool lock is expensive, and unnecessary because most modern adapters
> can transfer 100s of KBs of payload using just a single MR.
>
> Instead, acquire MRs one-at-a-time as chunks are registered, and
> return them to rb_mws immediately during deregistration.
>
> Note: commit 539431a437d2 ("xprtrdma: Don't invalidate FRMRs if
> registration fails") is reverted: There is now a valid case where
> registration can fail (with -ENOMEM) but the QP is still in RTS.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/frwr_ops.c |  120 ++++++++++++++++++++++++++++------------
>   net/sunrpc/xprtrdma/rpc_rdma.c |    3 -
>   net/sunrpc/xprtrdma/verbs.c    |   21 -------
>   3 files changed, 86 insertions(+), 58 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index a06d9a3..6f93a89 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -11,6 +11,62 @@
>    * but most complex memory registration mode.
>    */
>
> +/* Normal operation
> + *
> + * A Memory Region is prepared for RDMA READ or WRITE using a FAST_REG
> + * Work Request (frmr_op_map). When the RDMA operation is finished, this
> + * Memory Region is invalidated using a LOCAL_INV Work Request
> + * (frmr_op_unmap).
> + *
> + * Typically these Work Requests are not signaled, and neither are RDMA
> + * SEND Work Requests (with the exception of signaling occasionally to
> + * prevent provider work queue overflows). This greatly reduces HCA
> + * interrupt workload.
> + *
> + * As an optimization, frwr_op_unmap marks MRs INVALID before the
> + * LOCAL_INV WR is posted. If posting succeeds, the MR is placed on
> + * rb_mws immediately so that no work (like managing a linked list
> + * under a spinlock) is needed in the completion upcall.
> + *
> + * But this means that frwr_op_map() can occasionally encounter an MR
> + * that is INVALID but the LOCAL_INV WR has not completed. Work Queue
> + * ordering prevents a subsequent FAST_REG WR from executing against
> + * that MR while it is still being invalidated.
> + */
> +
> +/* Transport recovery
> + *
> + * ->op_map and the transport connect worker cannot run at the same
> + * time, but ->op_unmap can fire while the transport connect worker
> + * is running. Thus MR recovery is handled in ->op_map, to guarantee
> + * that recovered MRs are owned by a sending RPC, and not one where
> + * ->op_unmap could fire at the same time transport reconnect is
> + * being done.
> + *
> + * When the underlying transport disconnects, MRs are left in one of
> + * three states:
> + *
> + * INVALID:	The MR was not in use before the QP entered ERROR state.
> + *		(Or, the LOCAL_INV WR has not completed or flushed yet).
> + *
> + * STALE:	The MR was being registered or unregistered when the QP
> + *		entered ERROR state, and the pending WR was flushed.
> + *
> + * VALID:	The MR was registered before the QP entered ERROR state.
> + *
> + * When frwr_op_map encounters STALE and VALID MRs, they are recovered
> + * with ib_dereg_mr and then are re-initialized. Beause MR recovery
> + * allocates fresh resources, it is deferred to a workqueue, and the
> + * recovered MRs are placed back on the rb_mws list when recovery is
> + * complete. frwr_op_map allocates another MR for the current RPC while
> + * the broken MR is reset.
> + *
> + * To ensure that frwr_op_map doesn't encounter an MR that is marked
> + * INVALID but that is about to be flushed due to a previous transport
> + * disconnect, the transport connect worker attempts to drain all
> + * pending send queue WRs before the transport is reconnected.
> + */
> +
>   #include "xprt_rdma.h"
>
>   #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> @@ -250,9 +306,9 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	struct ib_device *device = ia->ri_device;
>   	enum dma_data_direction direction = rpcrdma_data_dir(writing);
>   	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct rpcrdma_mw *mw = seg1->rl_mw;
> -	struct rpcrdma_frmr *frmr = &mw->r.frmr;
> -	struct ib_mr *mr = frmr->fr_mr;
> +	struct rpcrdma_mw *mw;
> +	struct rpcrdma_frmr *frmr;
> +	struct ib_mr *mr;
>   	struct ib_send_wr fastreg_wr, *bad_wr;
>   	u8 key;
>   	int len, pageoff;
> @@ -261,12 +317,25 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	u64 pa;
>   	int page_no;
>
> +	mw = seg1->rl_mw;
> +	seg1->rl_mw = NULL;
> +	do {
> +		if (mw)
> +			__frwr_queue_recovery(mw);
> +		mw = rpcrdma_get_mw(r_xprt);
> +		if (!mw)
> +			return -ENOMEM;
> +	} while (mw->r.frmr.fr_state != FRMR_IS_INVALID);
> +	frmr = &mw->r.frmr;
> +	frmr->fr_state = FRMR_IS_VALID;
> +
>   	pageoff = offset_in_page(seg1->mr_offset);
>   	seg1->mr_offset -= pageoff;	/* start of page */
>   	seg1->mr_len += pageoff;
>   	len = -pageoff;
>   	if (nsegs > ia->ri_max_frmr_depth)
>   		nsegs = ia->ri_max_frmr_depth;
> +
>   	for (page_no = i = 0; i < nsegs;) {
>   		rpcrdma_map_one(device, seg, direction);
>   		pa = seg->mr_dma;
> @@ -285,8 +354,6 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	dprintk("RPC:       %s: Using frmr %p to map %d segments (%d bytes)\n",
>   		__func__, mw, i, len);
>
> -	frmr->fr_state = FRMR_IS_VALID;
> -
>   	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
>   	fastreg_wr.wr_id = (unsigned long)(void *)mw;
>   	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
> @@ -298,6 +365,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	fastreg_wr.wr.fast_reg.access_flags = writing ?
>   				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
>   				IB_ACCESS_REMOTE_READ;
> +	mr = frmr->fr_mr;
>   	key = (u8)(mr->rkey & 0x000000FF);
>   	ib_update_fast_reg_key(mr, ++key);
>   	fastreg_wr.wr.fast_reg.rkey = mr->rkey;
> @@ -307,6 +375,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	if (rc)
>   		goto out_senderr;
>
> +	seg1->rl_mw = mw;
>   	seg1->mr_rkey = mr->rkey;
>   	seg1->mr_base = seg1->mr_dma + pageoff;
>   	seg1->mr_nsegs = i;
> @@ -315,10 +384,9 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>
>   out_senderr:
>   	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
> -	ib_update_fast_reg_key(mr, --key);
> -	frmr->fr_state = FRMR_IS_INVALID;
>   	while (i--)
>   		rpcrdma_unmap_one(device, --seg);
> +	__frwr_queue_recovery(mw);
>   	return rc;
>   }
>
> @@ -330,15 +398,19 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>   {
>   	struct rpcrdma_mr_seg *seg1 = seg;
>   	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
> +	struct rpcrdma_mw *mw = seg1->rl_mw;
>   	struct ib_send_wr invalidate_wr, *bad_wr;
>   	int rc, nsegs = seg->mr_nsegs;
>
> -	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_INVALID;
> +	dprintk("RPC:       %s: FRMR %p\n", __func__, mw);
> +
> +	seg1->rl_mw = NULL;
> +	mw->r.frmr.fr_state = FRMR_IS_INVALID;
>
>   	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
> -	invalidate_wr.wr_id = (unsigned long)(void *)seg1->rl_mw;
> +	invalidate_wr.wr_id = (unsigned long)(void *)mw;
>   	invalidate_wr.opcode = IB_WR_LOCAL_INV;
> -	invalidate_wr.ex.invalidate_rkey = seg1->rl_mw->r.frmr.fr_mr->rkey;
> +	invalidate_wr.ex.invalidate_rkey = mw->r.frmr.fr_mr->rkey;
>   	DECR_CQCOUNT(&r_xprt->rx_ep);
>
>   	while (seg1->mr_nsegs--)
> @@ -348,12 +420,13 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>   	read_unlock(&ia->ri_qplock);
>   	if (rc)
>   		goto out_err;
> +
> +	rpcrdma_put_mw(r_xprt, mw);
>   	return nsegs;
>
>   out_err:
> -	/* Force rpcrdma_buffer_get() to retry */
> -	seg1->rl_mw->r.frmr.fr_state = FRMR_IS_STALE;
>   	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
> +	__frwr_queue_recovery(mw);
>   	return nsegs;
>   }
>
> @@ -370,29 +443,6 @@ out_err:
>   static void
>   frwr_op_reset(struct rpcrdma_xprt *r_xprt)
>   {
> -	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
> -	struct ib_device *device = r_xprt->rx_ia.ri_device;
> -	unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
> -	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
> -	struct rpcrdma_mw *r;
> -	int rc;
> -
> -	list_for_each_entry(r, &buf->rb_all, mw_all) {
> -		if (r->r.frmr.fr_state == FRMR_IS_INVALID)
> -			continue;
> -
> -		__frwr_release(r);
> -		rc = __frwr_init(r, pd, device, depth);
> -		if (rc) {
> -			dprintk("RPC:       %s: mw %p left %s\n",
> -				__func__, r,
> -				(r->r.frmr.fr_state == FRMR_IS_STALE ?
> -					"stale" : "valid"));
> -			continue;
> -		}
> -
> -		r->r.frmr.fr_state = FRMR_IS_INVALID;
> -	}
>   }
>
>   static void
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 98a3b95..35ead0b 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -284,9 +284,6 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
>   	return (unsigned char *)iptr - (unsigned char *)headerp;
>
>   out:
> -	if (r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
> -		return n;
> -
>   	for (pos = 0; nchunks--;)
>   		pos += r_xprt->rx_ia.ri_ops->ro_unmap(r_xprt,
>   						      &req->rl_segments[pos]);
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 8a43c7ef..5226161 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1343,12 +1343,11 @@ rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
>   struct rpcrdma_req *
>   rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
>   {
> -	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
> -	struct list_head stale;
>   	struct rpcrdma_req *req;
>   	unsigned long flags;
>
>   	spin_lock_irqsave(&buffers->rb_lock, flags);
> +
>   	if (buffers->rb_send_index == buffers->rb_max_requests) {
>   		spin_unlock_irqrestore(&buffers->rb_lock, flags);
>   		dprintk("RPC:       %s: out of request buffers\n", __func__);
> @@ -1367,17 +1366,7 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
>   	}
>   	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
>
> -	INIT_LIST_HEAD(&stale);
> -	switch (ia->ri_memreg_strategy) {
> -	case RPCRDMA_FRMR:
> -		req = rpcrdma_buffer_get_frmrs(req, buffers, &stale);
> -		break;
> -	default:
> -		break;
> -	}
>   	spin_unlock_irqrestore(&buffers->rb_lock, flags);
> -	if (!list_empty(&stale))
> -		rpcrdma_retry_flushed_linv(&stale, buffers);
>   	return req;
>   }
>
> @@ -1389,18 +1378,10 @@ void
>   rpcrdma_buffer_put(struct rpcrdma_req *req)
>   {
>   	struct rpcrdma_buffer *buffers = req->rl_buffer;
> -	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
>   	unsigned long flags;
>
>   	spin_lock_irqsave(&buffers->rb_lock, flags);
>   	rpcrdma_buffer_put_sendbuf(req, buffers);
> -	switch (ia->ri_memreg_strategy) {
> -	case RPCRDMA_FRMR:
> -		rpcrdma_buffer_put_mrs(req, buffers);
> -		break;
> -	default:
> -		break;
> -	}
>   	spin_unlock_irqrestore(&buffers->rb_lock, flags);
>   }
>
>

Don't you need a call to flush_workqueue(frwr_recovery_wq) when you're
about to destroy the endpoint (and the buffers and the MRs...)?
