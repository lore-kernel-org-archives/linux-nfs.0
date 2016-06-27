Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:62047 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbcF0RrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2016 13:47:08 -0400
Subject: Re: [PATCH v3 01/25] xprtrdma: Remove FMRs from the unmap list after
 unmapping
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620160843.10809.96379.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <bf577252-3786-9ee8-be3b-036922eb0507@Netapp.com>
Date: Mon, 27 Jun 2016 13:47:04 -0400
MIME-Version: 1.0
In-Reply-To: <20160620160843.10809.96379.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 06/20/2016 12:08 PM, Chuck Lever wrote:
> ib_unmap_fmr() takes a list of FMRs to unmap. However, it does not
> remove the FMRs from this list as it processes them. Other
> ib_unmap_fmr() call sites are careful to remove FMRs from the list
> after ib_unmap_fmr() returns.
> 
> Since commit 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
> fmr_op_unmap_sync passes more than one FMR to ib_unmap_fmr(), but
> it didn't bother to remove the FMRs from that list once the call was
> complete.
> 
> I've noticed some instability that could be related to list
> tangling by the new fmr_op_unmap_sync() logic. In an abundance
> of caution, add some defensive logic to clean up properly after
> ib_unmap_fmr().
> 
> Fixes: 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/fmr_ops.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 6326ebe..958c792 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -63,9 +63,12 @@ static int
>  __fmr_unmap(struct rpcrdma_mw *mw)
>  {
>  	LIST_HEAD(l);
> +	int rc;
>  
>  	list_add(&mw->fmr.fmr->list, &l);
> -	return ib_unmap_fmr(&l);
> +	rc = ib_unmap_fmr(&l);
> +	list_del_init(&mw->fmr.fmr->list);
> +	return rc;
>  }
>  
>  /* Deferred reset of a single FMR. Generate a fresh rkey by
> @@ -149,6 +152,7 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
>  		r->fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
>  		if (IS_ERR(r->fmr.fmr))
>  			goto out_fmr_err;
> +		INIT_LIST_HEAD(&r->fmr.fmr->list);

I'm a little surprised to see that ib_alloc_fmr() isn't initializing this list.  Do you know of any plans to add the INIT_LIST_HEAD() into the infiniband code, that way it's always initialized when an ib_fmr is allocated?

Anna

>  
>  		r->mw_xprt = r_xprt;
>  		list_add(&r->mw_list, &buf->rb_mws);
> @@ -267,7 +271,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  		seg = &req->rl_segments[i];
>  		mw = seg->rl_mw;
>  
> -		list_add(&mw->fmr.fmr->list, &unmap_list);
> +		list_add_tail(&mw->fmr.fmr->list, &unmap_list);
>  
>  		i += seg->mr_nsegs;
>  	}
> @@ -280,7 +284,9 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  	 */
>  	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
>  		seg = &req->rl_segments[i];
> +		mw = seg->rl_mw;
>  
> +		list_del_init(&mw->fmr.fmr->list);
>  		__fmr_dma_unmap(r_xprt, seg);
>  		rpcrdma_put_mw(r_xprt, seg->rl_mw);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

