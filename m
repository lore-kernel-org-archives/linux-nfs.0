Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35108 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932938AbdC3MaQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2017 08:30:16 -0400
Date: Thu, 30 Mar 2017 05:30:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 05/13] svcrdma: Introduce local rdma_rw API helpers
Message-ID: <20170330123014.GA32364@infradead.org>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
 <20170327134835.5585.76603.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170327134835.5585.76603.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	spinlock_t	     sc_rw_ctxt_lock;
> +	struct list_head     sc_rw_ctxts;

It's a little sad that we always need a list and a spinlock when
most requests should need a single context only.

> + * Each WR chain handles a single contiguous server-side buffer,
> + * because some registration modes (eg. FRWR) do not support a
> + * discontiguous scatterlist.

Both FRWR and FMR have no problem with a discontiguous page list,
they only have a problem with any segment but the first not starting
page aligned.  For NFS you'll need vectored direct I/O to hit that
case.

> +	spin_lock(&rdma->sc_rw_ctxt_lock);
> +	if (list_empty(&rdma->sc_rw_ctxts))
> +		goto out_empty;
> +
> +	ctxt = list_first_entry(&rdma->sc_rw_ctxts,
> +				struct svc_rdma_rw_ctxt, rw_list);

Use list_first_entry_or_null?

> +	struct svc_rdma_rw_ctxt *ctxt;
> +
> +	while (!list_empty(&rdma->sc_rw_ctxts)) {
> +		ctxt = list_first_entry(&rdma->sc_rw_ctxts,
> +					struct svc_rdma_rw_ctxt, rw_list);

Same here.


> +	if (wc->status != IB_WC_SUCCESS)
> +		goto flush;
> +
> +out:
> +	rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp, rdma->sc_port_num,
> +			    ctxt->rw_sg_table.sgl, ctxt->rw_nents,
> +			    DMA_TO_DEVICE);
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

This would seem cleaner without the gotos (but maybe an unlikely
for the if above).

> +	struct svc_xprt *xprt = &rdma->sc_xprt;
> +	struct ib_send_wr *bad_wr;
> +	int ret;
> +
> +	do {
> +		if ((atomic_sub_return(num_wrs, &rdma->sc_sq_avail) > 0)) {

No need for the inner braces.


Except for these minor nitpicks the patch looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>
