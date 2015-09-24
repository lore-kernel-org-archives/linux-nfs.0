Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:43716 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbbIXM56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 08:57:58 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH rdma-rc v2 1/4] xprtrdma: Replace global lkey with lkey
 local to PD
To: Sagi Grimberg <sagig@mellanox.com>, Doug Ledford <dledford@redhat.com>
References: <1443080064-28760-1-git-send-email-sagig@mellanox.com>
 <1443080064-28760-2-git-send-email-sagig@mellanox.com>
CC: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <5603F34F.3050505@Netapp.com>
Date: Thu, 24 Sep 2015 08:57:51 -0400
MIME-Version: 1.0
In-Reply-To: <1443080064-28760-2-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi,

On 09/24/2015 03:34 AM, Sagi Grimberg wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> The core API has changed so that devices that do not have a global
> DMA lkey automatically create an mr, per-PD, and make that lkey
> available. The global DMA lkey interface is going away in favor of
> the per-PD DMA lkey.
> 
> The per-PD DMA lkey is always available. Convert xprtrdma to use the
> device's per-PD DMA lkey for regbufs, no matter which memory
> registration scheme is in use.

This is going through an RDMA tree somewhere, correct?  You can add my:

Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> Cc: linux-nfs <linux-nfs@vger.kernel.org>
> ---
>  net/sunrpc/xprtrdma/fmr_ops.c      | 19 -------------------
>  net/sunrpc/xprtrdma/frwr_ops.c     |  5 -----
>  net/sunrpc/xprtrdma/physical_ops.c | 10 +---------
>  net/sunrpc/xprtrdma/verbs.c        |  2 +-
>  net/sunrpc/xprtrdma/xprt_rdma.h    |  1 -
>  5 files changed, 2 insertions(+), 35 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index cb25c89da623..f1e8dafbd507 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -39,25 +39,6 @@ static int
>  fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>  	    struct rpcrdma_create_data_internal *cdata)
>  {
> -	struct ib_device_attr *devattr = &ia->ri_devattr;
> -	struct ib_mr *mr;
> -
> -	/* Obtain an lkey to use for the regbufs, which are
> -	 * protected from remote access.
> -	 */
> -	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
> -		ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -	} else {
> -		mr = ib_get_dma_mr(ia->ri_pd, IB_ACCESS_LOCAL_WRITE);
> -		if (IS_ERR(mr)) {
> -			pr_err("%s: ib_get_dma_mr for failed with %lX\n",
> -			       __func__, PTR_ERR(mr));
> -			return -ENOMEM;
> -		}
> -		ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
> -		ia->ri_dma_mr = mr;
> -	}
> -
>  	return 0;
>  }
>  
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index d6653f5d0830..5318951b3b53 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -189,11 +189,6 @@ frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>  	struct ib_device_attr *devattr = &ia->ri_devattr;
>  	int depth, delta;
>  
> -	/* Obtain an lkey to use for the regbufs, which are
> -	 * protected from remote access.
> -	 */
> -	ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -
>  	ia->ri_max_frmr_depth =
>  			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
>  			      devattr->max_fast_reg_page_list_len);
> diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
> index 72cf8b15bbb4..617b76f22154 100644
> --- a/net/sunrpc/xprtrdma/physical_ops.c
> +++ b/net/sunrpc/xprtrdma/physical_ops.c
> @@ -23,7 +23,6 @@ static int
>  physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>  		 struct rpcrdma_create_data_internal *cdata)
>  {
> -	struct ib_device_attr *devattr = &ia->ri_devattr;
>  	struct ib_mr *mr;
>  
>  	/* Obtain an rkey to use for RPC data payloads.
> @@ -37,15 +36,8 @@ physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>  		       __func__, PTR_ERR(mr));
>  		return -ENOMEM;
>  	}
> -	ia->ri_dma_mr = mr;
> -
> -	/* Obtain an lkey to use for regbufs.
> -	 */
> -	if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)
> -		ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -	else
> -		ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
>  
> +	ia->ri_dma_mr = mr;
>  	return 0;
>  }
>  
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 682996779970..eb081ad05e33 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1252,7 +1252,7 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
>  		goto out_free;
>  
>  	iov->length = size;
> -	iov->lkey = ia->ri_dma_lkey;
> +	iov->lkey = ia->ri_pd->local_dma_lkey;
>  	rb->rg_size = size;
>  	rb->rg_owner = NULL;
>  	return rb;
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index d252457ff21a..df5ad4e15702 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -66,7 +66,6 @@ struct rpcrdma_ia {
>  	struct rdma_cm_id 	*ri_id;
>  	struct ib_pd		*ri_pd;
>  	struct ib_mr		*ri_dma_mr;
> -	u32			ri_dma_lkey;
>  	struct completion	ri_done;
>  	int			ri_async_rc;
>  	unsigned int		ri_max_frmr_depth;
> 

