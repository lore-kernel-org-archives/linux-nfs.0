Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44060 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756311AbaGIURJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jul 2014 16:17:09 -0400
Message-ID: <53BDA10B.6030506@netapp.com>
Date: Wed, 9 Jul 2014 16:07:39 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 08/21] xprtrdma: Back off rkey when FAST_REG_MR fails
References: <20140709163326.3496.37893.stgit@manet.1015granger.net> <20140709165739.3496.39485.stgit@manet.1015granger.net>
In-Reply-To: <20140709165739.3496.39485.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/09/2014 12:57 PM, Chuck Lever wrote:
> If posting a FAST_REG_MR Work Reqeust fails, revert the rkey update
> to avoid subsequent IB_WC_MW_BIND_ERR completions.
>
> Suggested-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |   27 ++++++++++++++++++++-------
>  1 file changed, 20 insertions(+), 7 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index ce847d2..14d24ec 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1487,6 +1487,24 @@ rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
>  				seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
>  }
>  
> +static void
> +rpcrdma_increment_frmr_rkey(struct rpcrdma_mw *mw)
> +{
> +	struct ib_mr *mr = mw->r.frmr.fr_mr;
> +	u8 key = mr->rkey & 0x000000FF;

It's not super obvious to be how this key is being calculated.  Can you change 0x000000FF into a named constant to help?

It might also be useful to have an frmr_get_rkey() function rather than doing this calculation in two different places.

Anna

> +
> +	ib_update_fast_reg_key(mr, ++key);
> +}
> +
> +static void
> +rpcrdma_decrement_frmr_rkey(struct rpcrdma_mw *mw)
> +{
> +	struct ib_mr *mr = mw->r.frmr.fr_mr;
> +	u8 key = mr->rkey & 0x000000FF;
> +
> +	ib_update_fast_reg_key(mr, --key);
> +}
> +
>  static int
>  rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>  			int *nsegs, int writing, struct rpcrdma_ia *ia,
> @@ -1496,8 +1514,6 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>  	struct rpcrdma_mw *mw = seg1->mr_chunk.rl_mw;
>  	struct rpcrdma_frmr *frmr = &mw->r.frmr;
>  	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
> -
> -	u8 key;
>  	int len, pageoff;
>  	int i, rc;
>  	int seg_len;
> @@ -1557,14 +1573,10 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>  		rc = -EIO;
>  		goto out_err;
>  	}
> -
> -	/* Bump the key */
> -	key = (u8)(frmr->fr_mr->rkey & 0x000000FF);
> -	ib_update_fast_reg_key(frmr->fr_mr, ++key);
> -
>  	frmr_wr.wr.fast_reg.access_flags = (writing ?
>  				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
>  				IB_ACCESS_REMOTE_READ);
> +	rpcrdma_increment_frmr_rkey(mw);
>  	frmr_wr.wr.fast_reg.rkey = frmr->fr_mr->rkey;
>  	DECR_CQCOUNT(&r_xprt->rx_ep);
>  
> @@ -1573,6 +1585,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>  	if (rc) {
>  		dprintk("RPC:       %s: failed ib_post_send for register,"
>  			" status %i\n", __func__, rc);
> +		rpcrdma_decrement_frmr_rkey(seg1->mr_chunk.rl_mw);
>  		goto out_err;
>  	} else {
>  		seg1->mr_rkey = frmr->fr_mr->rkey;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

