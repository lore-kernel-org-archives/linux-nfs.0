Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34299 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759834AbdCVORn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 10:17:43 -0400
From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [PATCH v1 05/14] svcrdma: Introduce local rdma_rw API helpers
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
 <20170316155306.4482.68041.stgit@klimt.1015granger.net>
Message-ID: <cfa49433-ab26-d2f0-27d4-2a96ff0adaba@grimberg.me>
Date: Wed, 22 Mar 2017 16:17:38 +0200
MIME-Version: 1.0
In-Reply-To: <20170316155306.4482.68041.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The plan is to replace the local bespoke code that constructs and
> posts RDMA Read and Write Work Requests with calls to the rdma_rw
> API. This shares code with other RDMA-enabled ULPs that manages the
> gory details of buffer registration and posting Work Requests.
>
> Some design notes:
>
>  o svc_xprt reference counting is modified, since one rdma_rw_ctx
>    generates one completion, no matter how many Write WRs are
>    posted. To accommodate the new reference counting scheme, a new
>    version of svc_rdma_send() is introduced.
>
>  o The structure of RPC-over-RDMA transport headers is flexible,
>    allowing multiple segments per Reply with arbitrary alignment.
>    Thus I did not take the further step of chaining Write WRs with
>    the Send WR containing the RPC Reply message. The Write and Send
>    WRs continue to be built by separate pieces of code.
>
>  o The current code builds the transport header as it is construct-
>    ing Write WRs. I've replaced that with marshaling of transport
>    header data items in a separate step. This is because the exact
>    structure of client-provided segments may not align with the
>    components of the server's reply xdr_buf, or the pages in the
>    page list. Thus parts of each client-provided segment may be
>    written at different points in the send path.
>
>  o Since the Write list and Reply chunk marshaling code is being
>    replaced, I took the opportunity to replace some of the C
>    structure-based XDR encoding code with more portable code that
>    instead uses pointer arithmetic.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

To be honest its difficult to review this patch, but its probably
difficult to split it too...

> +
> +/* One Write chunk is copied from Call transport header to Reply
> + * transport header. Each segment's length field is updated to
> + * reflect number of bytes consumed in the segment.
> + *
> + * Returns number of segments in this chunk.
> + */
> +static unsigned int xdr_encode_write_chunk(__be32 *dst, __be32 *src,
> +					   unsigned int remaining)

Is this only for data-in-reply (send operation)? I don't see why you
would need to modify that for RDMA operations.

Perhaps I'd try to split the data-in-reply code from the actual rdma
conversion. It might be helpful to comprehend.

> +{
> +	unsigned int i, nsegs;
> +	u32 seg_len;
> +
> +	/* Write list discriminator */
> +	*dst++ = *src++;

I had to actually run a test program to understand the precedence
here so parenthesis would've helped :)

> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> new file mode 100644
> index 0000000..1e76227
> --- /dev/null
> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> @@ -0,0 +1,785 @@
> +/*
> + * Copyright (c) 2016 Oracle.  All rights reserved.
> + *
> + * Use the core R/W API to move RPC-over-RDMA Read and Write chunks.
> + */
> +
> +#include <linux/sunrpc/rpc_rdma.h>
> +#include <linux/sunrpc/svc_rdma.h>
> +#include <linux/sunrpc/debug.h>
> +
> +#include <rdma/rw.h>
> +
> +#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
> +
> +/* Each R/W context contains state for one chain of RDMA Read or
> + * Write Work Requests (one RDMA segment to be read from or written
> + * back to the client).
> + *
> + * Each WR chain handles a single contiguous server-side buffer,
> + * because some registration modes (eg. FRWR) do not support a
> + * discontiguous scatterlist.
> + *
> + * Each WR chain handles only one R_key. Each RPC-over-RDMA segment
> + * from a client may contain a unique R_key, so each WR chain moves
> + * one segment (or less) at a time.
> + *
> + * The scatterlist makes this data structure just over 8KB in size
> + * on 4KB-page platforms. As the size of this structure increases
> + * past one page, it becomes more likely that allocating one of these
> + * will fail. Therefore, these contexts are created on demand, but
> + * cached and reused until the controlling svcxprt_rdma is destroyed.
> + */
> +struct svc_rdma_rw_ctxt {
> +	struct list_head	rw_list;
> +	struct ib_cqe		rw_cqe;
> +	struct svcxprt_rdma	*rw_rdma;
> +	int			rw_nents;
> +	int			rw_wrcount;
> +	enum dma_data_direction	rw_dir;
> +	struct svc_rdma_op_ctxt	*rw_readctxt;
> +	struct rdma_rw_ctx	rw_ctx;
> +	struct scatterlist	rw_sg[RPCSVC_MAXPAGES];

Have you considered using sg_table with sg_alloc_table_chained?

See lib/sg_pool.c and nvme-rdma as a consumer.

> +};
> +
> +static struct svc_rdma_rw_ctxt *
> +svc_rdma_get_rw_ctxt(struct svcxprt_rdma *rdma)
> +{
> +	struct svc_rdma_rw_ctxt *ctxt;
> +
> +	svc_xprt_get(&rdma->sc_xprt);
> +
> +	spin_lock(&rdma->sc_rw_ctxt_lock);
> +	if (list_empty(&rdma->sc_rw_ctxts))
> +		goto out_empty;
> +
> +	ctxt = list_first_entry(&rdma->sc_rw_ctxts,
> +				struct svc_rdma_rw_ctxt, rw_list);
> +	list_del_init(&ctxt->rw_list);
> +	spin_unlock(&rdma->sc_rw_ctxt_lock);
> +
> +out:
> +	ctxt->rw_dir = DMA_NONE;
> +	return ctxt;
> +
> +out_empty:
> +	spin_unlock(&rdma->sc_rw_ctxt_lock);
> +
> +	ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> +	if (!ctxt) {
> +		svc_xprt_put(&rdma->sc_xprt);
> +		return NULL;
> +	}
> +
> +	ctxt->rw_rdma = rdma;
> +	INIT_LIST_HEAD(&ctxt->rw_list);
> +	sg_init_table(ctxt->rw_sg, ARRAY_SIZE(ctxt->rw_sg));
> +	goto out;
> +}
> +
> +static void svc_rdma_put_rw_ctxt(struct svc_rdma_rw_ctxt *ctxt)
> +{
> +	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
> +
> +	if (ctxt->rw_dir != DMA_NONE)
> +		rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp,
> +				    rdma->sc_port_num,
> +				    ctxt->rw_sg, ctxt->rw_nents,
> +				    ctxt->rw_dir);
> +

its a bit odd to see put_rw_ctxt that also destroys the context
which isn't exactly pairs with get_rw_ctxt.

Maybe it'd be useful to explicitly do that outside the put.

> +/**
> + * svc_rdma_destroy_rw_ctxts - Free write contexts
> + * @rdma: xprt about to be destroyed
> + *
> + */
> +void svc_rdma_destroy_rw_ctxts(struct svcxprt_rdma *rdma)
> +{
> +	struct svc_rdma_rw_ctxt *ctxt;
> +
> +	while (!list_empty(&rdma->sc_rw_ctxts)) {
> +		ctxt = list_first_entry(&rdma->sc_rw_ctxts,
> +					struct svc_rdma_rw_ctxt, rw_list);
> +		list_del(&ctxt->rw_list);
> +		kfree(ctxt);
> +	}
> +}
> +
> +/**
> + * svc_rdma_wc_write_ctx - Handle completion of an RDMA Write ctx
> + * @cq: controlling Completion Queue
> + * @wc: Work Completion
> + *
> + * Invoked in soft IRQ context.
> + *
> + * Assumptions:
> + * - Write completion is not responsible for freeing pages under
> + *   I/O.
> + */
> +static void svc_rdma_wc_write_ctx(struct ib_cq *cq, struct ib_wc *wc)
> +{
> +	struct ib_cqe *cqe = wc->wr_cqe;
> +	struct svc_rdma_rw_ctxt *ctxt =
> +			container_of(cqe, struct svc_rdma_rw_ctxt, rw_cqe);
> +	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
> +
> +	atomic_add(ctxt->rw_wrcount, &rdma->sc_sq_avail);
> +	wake_up(&rdma->sc_send_wait);
> +
> +	if (wc->status != IB_WC_SUCCESS)
> +		goto flush;
> +
> +out:
> +	svc_rdma_put_rw_ctxt(ctxt);
> +	return;
> +
> +flush:
> +	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
> +	if (wc->status != IB_WC_WR_FLUSH_ERR)
> +		pr_err("svcrdma: write ctx: %s (%u/0x%x)\n",
> +		       ib_wc_status_msg(wc->status),
> +		       wc->status, wc->vendor_err);
> +	goto out;
> +}
> +
> +/**
> + * svc_rdma_wc_read_ctx - Handle completion of an RDMA Read ctx
> + * @cq: controlling Completion Queue
> + * @wc: Work Completion
> + *
> + * Invoked in soft IRQ context.

? in soft IRQ?

> + */
> +static void svc_rdma_wc_read_ctx(struct ib_cq *cq, struct ib_wc *wc)
> +{
> +	struct ib_cqe *cqe = wc->wr_cqe;
> +	struct svc_rdma_rw_ctxt *ctxt =
> +			container_of(cqe, struct svc_rdma_rw_ctxt, rw_cqe);
> +	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
> +	struct svc_rdma_op_ctxt *head;
> +
> +	atomic_add(ctxt->rw_wrcount, &rdma->sc_sq_avail);
> +	wake_up(&rdma->sc_send_wait);
> +
> +	if (wc->status != IB_WC_SUCCESS)
> +		goto flush;
> +
> +	head = ctxt->rw_readctxt;
> +	if (!head)
> +		goto out;
> +
> +	spin_lock(&rdma->sc_rq_dto_lock);
> +	list_add_tail(&head->list, &rdma->sc_read_complete_q);
> +	spin_unlock(&rdma->sc_rq_dto_lock);

Not sure what sc_read_complete_q does... what post processing is
needed for completed reads?

> +/* This function sleeps when the transport's Send Queue is congested.

Is this easy to trigger?
