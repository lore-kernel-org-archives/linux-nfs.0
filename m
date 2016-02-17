Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:59943 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423662AbcBQVTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 16:19:25 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 4/8] xprtrdma: Properly handle RDMA_ERROR replies
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net>
 <20160212210627.5278.89517.stgit@manet.1015granger.net>
Message-ID: <56C4E3D6.1040605@Netapp.com>
Date: Wed, 17 Feb 2016 16:19:18 -0500
MIME-Version: 1.0
In-Reply-To: <20160212210627.5278.89517.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Can you combine this patch with 3/8, that way we're using RPCRDMA_HDRLEN_ERR in the same patch it's introduced?  It's only a one line difference :)

Thanks,
Anna

On 02/12/2016 04:06 PM, Chuck Lever wrote:
> These are shorter than RPCRDMA_HDRLEN_MIN, and they need to
> complete the waiting RPC.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/rpc_rdma.h |   11 ++++++-----
>  net/sunrpc/xprtrdma/rpc_rdma.c  |   38 +++++++++++++++++++++++++++++++++-----
>  2 files changed, 39 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
> index 8c6d23c..3b1ff38 100644
> --- a/include/linux/sunrpc/rpc_rdma.h
> +++ b/include/linux/sunrpc/rpc_rdma.h
> @@ -93,6 +93,12 @@ struct rpcrdma_msg {
>  			__be32 rm_pempty[3];	/* 3 empty chunk lists */
>  		} rm_padded;
>  
> +		struct {
> +			__be32 rm_err;
> +			__be32 rm_vers_low;
> +			__be32 rm_vers_high;
> +		} rm_error;
> +
>  		__be32 rm_chunks[0];	/* read, write and reply chunks */
>  
>  	} rm_body;
> @@ -109,11 +115,6 @@ enum rpcrdma_errcode {
>  	ERR_CHUNK = 2
>  };
>  
> -struct rpcrdma_err_vers {
> -	uint32_t rdma_vers_low;	/* Version range supported by peer */
> -	uint32_t rdma_vers_high;
> -};
> -
>  enum rpcrdma_proc {
>  	RDMA_MSG = 0,		/* An RPC call or reply msg */
>  	RDMA_NOMSG = 1,		/* An RPC call or reply msg - separate body */
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index add1f98..c341225 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -795,7 +795,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>  	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
>  	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
>  	__be32 *iptr;
> -	int rdmalen, status;
> +	int rdmalen, status, rmerr;
>  	unsigned long cwnd;
>  	u32 credits;
>  
> @@ -803,12 +803,10 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>  
>  	if (rep->rr_len == RPCRDMA_BAD_LEN)
>  		goto out_badstatus;
> -	if (rep->rr_len < RPCRDMA_HDRLEN_MIN)
> +	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
>  		goto out_shortreply;
>  
>  	headerp = rdmab_to_msg(rep->rr_rdmabuf);
> -	if (headerp->rm_vers != rpcrdma_version)
> -		goto out_badversion;
>  #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>  	if (rpcrdma_is_bcall(headerp))
>  		goto out_bcall;
> @@ -840,6 +838,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>  	req->rl_reply = rep;
>  	xprt->reestablish_timeout = 0;
>  
> +	if (headerp->rm_vers != rpcrdma_version)
> +		goto out_badversion;
> +
>  	/* check for expected message types */
>  	/* The order of some of these tests is important. */
>  	switch (headerp->rm_type) {
> @@ -900,6 +901,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>  		status = rdmalen;
>  		break;
>  
> +	case rdma_error:
> +		goto out_rdmaerr;
> +
>  badheader:
>  	default:
>  		dprintk("%s: invalid rpcrdma reply header (type %d):"
> @@ -915,6 +919,7 @@ badheader:
>  		break;
>  	}
>  
> +out:
>  	/* Invalidate and flush the data payloads before waking the
>  	 * waiting application. This guarantees the memory region is
>  	 * properly fenced from the server before the application
> @@ -957,6 +962,27 @@ out_bcall:
>  	return;
>  #endif
>  
> +out_rdmaerr:
> +	rmerr = be32_to_cpu(headerp->rm_body.rm_error.rm_err);
> +	switch (rmerr) {
> +	case ERR_VERS:
> +		pr_err("%s: server reports header version error (%u-%u)\n",
> +		       __func__,
> +		       be32_to_cpu(headerp->rm_body.rm_error.rm_vers_low),
> +		       be32_to_cpu(headerp->rm_body.rm_error.rm_vers_high));
> +		break;
> +	case ERR_CHUNK:
> +		pr_err("%s: server reports header decoding error\n",
> +		       __func__);
> +		break;
> +	default:
> +		pr_err("%s: server reports unknown error %d\n",
> +		       __func__, rmerr);
> +	}
> +	status = -EREMOTEIO;
> +	r_xprt->rx_stats.bad_reply_count++;
> +	goto out;
> +
>  out_shortreply:
>  	dprintk("RPC:       %s: short/invalid reply\n", __func__);
>  	goto repost;
> @@ -964,7 +990,9 @@ out_shortreply:
>  out_badversion:
>  	dprintk("RPC:       %s: invalid version %d\n",
>  		__func__, be32_to_cpu(headerp->rm_vers));
> -	goto repost;
> +	status = -EIO;
> +	r_xprt->rx_stats.bad_reply_count++;
> +	goto out;
>  
>  out_nomatch:
>  	spin_unlock_bh(&xprt->transport_lock);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

