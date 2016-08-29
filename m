Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:38524 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753436AbcH2TyZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Aug 2016 15:54:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 20/22] xprtrmda: Report address of frmr, not mw
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
 <20160823175446.13038.58792.stgit@manet.1015granger.net>
Message-ID: <7f92664a-a16c-6c44-b8f8-391e4fec0a89@Netapp.com>
Date: Mon, 29 Aug 2016 15:54:21 -0400
MIME-Version: 1.0
In-Reply-To: <20160823175446.13038.58792.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 08/23/2016 01:54 PM, Chuck Lever wrote:
> Tie frwr debugging messages together by always reporting the address
> of the frwr.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/frwr_ops.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index e82d5cf..2e51ef5 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -163,7 +163,7 @@ __frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
>  		return PTR_ERR(f->fr_mr);
>  	}
>  
> -	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
> +	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, f);
>  	f->fr_state = FRMR_IS_INVALID;
>  	return 0;
>  }
> @@ -397,7 +397,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>  		goto out_mapmr_err;
>  
>  	dprintk("RPC:       %s: Using frmr %p to map %u segments (%u bytes)\n",
> -		__func__, mw, mw->mw_nents, mr->length);
> +		__func__, frmr, mw->mw_nents, mr->length);
>  
>  	key = (u8)(mr->rkey & 0x000000FF);
>  	ib_update_fast_reg_key(mr, ++key);
> @@ -450,6 +450,9 @@ __frwr_prepare_linv_wr(struct rpcrdma_mw *mw)
>  	struct rpcrdma_frmr *f = &mw->frmr;
>  	struct ib_send_wr *invalidate_wr;
>  
> +	dprintk("RPC:       %s: invalidating frmr %p\n",
> +		__func__, f);
> +

Any reason this is broken into two lines?

>  	f->fr_state = FRMR_IS_INVALID;
>  	invalidate_wr = &f->fr_invwr;
>  
> @@ -532,6 +535,8 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  	 */
>  unmap:
>  	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
> +		dprintk("RPC:       %s: unmapping frmr %p\n",
> +			__func__, &mw->frmr);

Same question here.

Thanks,
Anna
>  		list_del_init(&mw->mw_list);
>  		ib_dma_unmap_sg(ia->ri_device,
>  				mw->mw_sg, mw->mw_nents, mw->mw_dir);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

