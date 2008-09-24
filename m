From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/10] svcrdma: Add FRMR get/put services
Date: Wed, 24 Sep 2008 15:45:38 -0400
Message-ID: <20080924194538.GM5772@fieldses.org>
References: <1221564879-85046-1-git-send-email-tom@opengridcomputing.com> <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbYIXTpk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 15:45:40 -0400
In-Reply-To: <1221564879-85046-3-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2008 at 06:34:31AM -0500, Tom Tucker wrote:
> Add services for the allocating, freeing, and unmapping Fast Reg MR. These
> services will be used by the transport connection setup, send and receive
> routines.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  include/linux/sunrpc/svc_rdma.h          |    3 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  125 ++++++++++++++++++++++++++++-
>  2 files changed, 123 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 295ebbc..100754e 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -219,6 +219,9 @@ extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
>  extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
>  extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
> +extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
> +extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
> +			      struct svc_rdma_fastreg_mr *);
>  extern void svc_sq_reap(struct svcxprt_rdma *);
>  extern void svc_rq_reap(struct svcxprt_rdma *);
>  extern struct svc_xprt_class svc_rdma_class;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 900cb69..f200345 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -100,6 +100,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>  	ctxt->xprt = xprt;
>  	INIT_LIST_HEAD(&ctxt->dto_q);
>  	ctxt->count = 0;
> +	ctxt->frmr = NULL;
>  	atomic_inc(&xprt->sc_ctxt_used);
>  	return ctxt;
>  }
> @@ -109,11 +110,19 @@ static void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
>  	struct svcxprt_rdma *xprt = ctxt->xprt;
>  	int i;
>  	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
> -		atomic_dec(&xprt->sc_dma_used);
> -		ib_dma_unmap_single(xprt->sc_cm_id->device,
> -				    ctxt->sge[i].addr,
> -				    ctxt->sge[i].length,
> -				    ctxt->direction);
> +		/*
> +		 * Unmap the DMA addr in the SGE if the lkey matches
> +		 * the sc_dma_lkey, otherwise, ignore it since it is
> +		 * an FRMR lkey and will be unmapped later when the
> +		 * last WR that uses it completes.

I kinda wish at the start of this that we'd made a rule that any acronym
that won't doesn't have a definition in the first page of its google
results should have at least its expansion added to a glossary someplace
in Documentation/ or the c source.  Maybe it's too late now.

> +		 */
> +		if (ctxt->sge[i].lkey == xprt->sc_dma_lkey) {

I'd probably have done

		if (ctx->sge[i].lkey != xprt->sc_dma_lkey)
			continue;

and left the rest alone; but OK.

(By the way, is it ever possible this test will return different results
on different passes through the loop, or could we just as well break out
the first time we see this?:

		if (ctx->sge[i].lkey != xprt->sc_dma_lkey)
			break;

)

> +			atomic_dec(&xprt->sc_dma_used);
> +			ib_dma_unmap_single(xprt->sc_cm_id->device,
> +					    ctxt->sge[i].addr,
> +					    ctxt->sge[i].length,
> +					    ctxt->direction);
> +		}
>  	}
>  }
>  
> @@ -150,6 +159,7 @@ struct svc_rdma_req_map *svc_rdma_get_req_map(void)
>  		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
>  	}
>  	map->count = 0;
> +	map->frmr = NULL;
>  	return map;
>  }
>  
> @@ -425,10 +435,12 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
>  	INIT_LIST_HEAD(&cma_xprt->sc_dto_q);
>  	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
>  	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
> +	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
>  	init_waitqueue_head(&cma_xprt->sc_send_wait);
>  
>  	spin_lock_init(&cma_xprt->sc_lock);
>  	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
> +	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
>  
>  	cma_xprt->sc_ord = svcrdma_ord;
>  
> @@ -686,6 +698,106 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  	return ERR_PTR(ret);
>  }
>  
> +static int rdma_alloc_frmr(struct svcxprt_rdma *xprt)
> +{
> +	struct ib_mr *mr;
> +	struct ib_fast_reg_page_list *pl;
> +	struct svc_rdma_fastreg_mr *frmr;
> +
> +	mr = ib_alloc_fast_reg_mr(xprt->sc_pd, RPCSVC_MAXPAGES);
> +	if (!mr)
> +		goto errout;
> +	pl = ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
> +					 RPCSVC_MAXPAGES);
> +	if (!pl) {
> +		ib_dereg_mr(mr);
> +		goto errout;
> +	}
> +	frmr = kmalloc(sizeof(*frmr), GFP_KERNEL);
> +	if (!frmr) {
> +		ib_dereg_mr(mr);
> +		ib_free_fast_reg_page_list(pl);
> +		goto errout;
> +	}
> +	frmr->mr = mr;
> +	frmr->page_list = pl;
> +	INIT_LIST_HEAD(&frmr->frmr_list);

This INIT_LIST_HEAD() is redundant given the following list_add().

> +	spin_lock_bh(&xprt->sc_frmr_q_lock);
> +	list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
> +	spin_unlock_bh(&xprt->sc_frmr_q_lock);
> +
> +	return 0;
> +
> + errout:
> +	return -ENOMEM;

Just a style nit: I like the exit-in-one-place thing, but if it's just a
bare "return" I don't see much advantage over replacing each goto by a
bare return.  The standard kernel style here would be:

	...
	if (!mr)
		goto errout;
	...
	if (!pl)
		goto err_free_mr;
	...
	if (!frmr)
		goto err_free_frmr;
	...
	return 0;
err_free_frmr:
	ib_free_fast_reg_page_list(pl);
err_free_mr:
	ib_dereg_mr(mr);
errout:
	return -ENOMEM;
}

> +}
> +
> +static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
> +{
> +	struct svc_rdma_fastreg_mr *frmr;
> +
> +	while (!list_empty(&xprt->sc_frmr_q)) {
> +		frmr = list_entry(xprt->sc_frmr_q.next,
> +				  struct svc_rdma_fastreg_mr, frmr_list);
> +		list_del_init(&frmr->frmr_list);
> +		ib_dereg_mr(frmr->mr);
> +		ib_free_fast_reg_page_list(frmr->page_list);
> +		kfree(frmr);
> +	}
> +}
> +
> +struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
> +{
> +	struct svc_rdma_fastreg_mr *frmr = NULL;
> +
> +	while (1) {
> +		spin_lock_bh(&rdma->sc_frmr_q_lock);
> +		if (!list_empty(&rdma->sc_frmr_q)) {
> +			frmr = list_entry(rdma->sc_frmr_q.next,
> +					  struct svc_rdma_fastreg_mr, frmr_list);
> +			list_del_init(&frmr->frmr_list);
> +		}
> +		spin_unlock_bh(&rdma->sc_frmr_q_lock);
> +		if (frmr)
> +			break;
> +		if (rdma_alloc_frmr(rdma))
> +			return ERR_PTR(-ENOMEM);

This business with allocating stuff and adding it to the list, then
looking for it next time around, seems a little more clever than
necessary.  Why not ditch the loop, take the list_add() out of
rdma_alloc_frmr() and have it return the newly allocated frmr or NULL
instead, and then do something like this?:

	spin_lock_bh(&rdma->sc_frmr_q_lock);
	if (!list_empty(&rdma->sc_frmr_q)) {
		frmr = list_entry(rdma->sc_frmr_q.next, struct
				  svc_rdma_fastreg_mr, frmr_list);
		list_del_init(&frmr->frmr_list);
	}
	spin_unlock_bh(&rdma->sc_frmr_q_lock);
	if (!frmr) {
		frmr = rdma_alloc_frmr(rdma);
		if (!frmr)
			return ERR_PTR(-ENOMEM);
	}
	frmr->map_len = 0;
	...


There doesn't seem to be much point to adding to sc_frmr_q just to take
it right back off again immediately.  Maybe I'm missing something.

> +	}
> +	frmr->map_len = 0;
> +	frmr->page_list_len = 0;
> +
> +	return frmr;
> +}
> +
> +static void frmr_unmap_dma(struct svcxprt_rdma *xprt,
> +			   struct svc_rdma_fastreg_mr *frmr)
> +{
> +	int page_no;
> +	dprintk("svcrdma:%s: xprt %p page_list_len %d\n",
> +		__func__, xprt, frmr->page_list_len);
> +	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
> +		dma_addr_t addr = frmr->page_list->page_list[page_no];
> +		dprintk("svcrdma:      %08x %llx\n", frmr->mr->lkey, addr);

Are these dprintk's going to be useful for debugging user issues
remotely, or were they just for your personal use while writing the
code?

We saw recently that we may already have too many dprintk's for them to
be useful in production, and the above seem likely to be rather
frequent.

--b.

> +		if (ib_dma_mapping_error(frmr->mr->device, addr))
> +			continue;
> +		atomic_dec(&xprt->sc_dma_used);
> +		ib_dma_unmap_single(frmr->mr->device, addr, PAGE_SIZE,
> +				    frmr->direction);
> +	}
> +}
> +
> +void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
> +		       struct svc_rdma_fastreg_mr *frmr)
> +{
> +	if (frmr) {
> +		frmr_unmap_dma(rdma, frmr);
> +		spin_lock_bh(&rdma->sc_frmr_q_lock);
> +		BUG_ON(!list_empty(&frmr->frmr_list));
> +		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
> +		spin_unlock_bh(&rdma->sc_frmr_q_lock);
> +	}
> +}
> +
>  /*
>   * This is the xpo_recvfrom function for listening endpoints. Its
>   * purpose is to accept incoming connections. The CMA callback handler
> @@ -961,6 +1073,9 @@ static void __svc_rdma_free(struct work_struct *work)
>  	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
>  	WARN_ON(atomic_read(&rdma->sc_dma_used) != 0);
>  
> +	/* De-allocate fastreg mr */
> +	rdma_dealloc_frmr_q(rdma);
> +
>  	/* Destroy the QP if present (not a listener) */
>  	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
>  		ib_destroy_qp(rdma->sc_qp);
