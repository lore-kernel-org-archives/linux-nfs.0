Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-08.prod.phx3.secureserver.net ([173.201.192.237]:38506
	"EHLO p3plsmtpa07-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751847AbbGTUds (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 16:33:48 -0400
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
From: Tom Talpey <tom@talpey.com>
Message-ID: <55AD5B48.3010906@talpey.com>
Date: Mon, 20 Jul 2015 13:34:16 -0700
MIME-Version: 1.0
In-Reply-To: <20150720190311.10997.12636.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/20/2015 12:03 PM, Chuck Lever wrote:
> All HCA providers have an ib_get_dma_mr() verb. Thus
> rpcrdma_ia_open() will either grab the device's local_dma_key if one
> is available, or it will call ib_get_dma_mr() which is a 100%
> guaranteed fallback.

I recall that in the past, some providers did not support mapping
all of the machine's potential physical memory with a single dma_mr.
If an rnic did/does not support 44-ish bits of length per region,
for example.

Have you verified that all current providers do in fact support the
necessary physical address range for this, and that the requirement
is stated in the verbs going forward?


>
> There is never any need to use the ib_reg_phys_mr() code path in
> rpcrdma_register_internal(), so it can be removed. The remaining
> logic in rpcrdma_{de}register_internal() is folded into
> rpcrdma_{alloc,free}_regbuf().
>
> This is clean up only. No behavior change is expected.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
> Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
> Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
> ---
>   net/sunrpc/xprtrdma/verbs.c     |  102 ++++++++-------------------------------
>   net/sunrpc/xprtrdma/xprt_rdma.h |    1
>   2 files changed, 21 insertions(+), 82 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 1065808..da184f9 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1229,75 +1229,6 @@ rpcrdma_mapping_error(struct rpcrdma_mr_seg *seg)
>   		(unsigned long long)seg->mr_dma, seg->mr_dmalen);
>   }
>
> -static int
> -rpcrdma_register_internal(struct rpcrdma_ia *ia, void *va, int len,
> -				struct ib_mr **mrp, struct ib_sge *iov)
> -{
> -	struct ib_phys_buf ipb;
> -	struct ib_mr *mr;
> -	int rc;
> -
> -	/*
> -	 * All memory passed here was kmalloc'ed, therefore phys-contiguous.
> -	 */
> -	iov->addr = ib_dma_map_single(ia->ri_device,
> -			va, len, DMA_BIDIRECTIONAL);
> -	if (ib_dma_mapping_error(ia->ri_device, iov->addr))
> -		return -ENOMEM;
> -
> -	iov->length = len;
> -
> -	if (ia->ri_have_dma_lkey) {
> -		*mrp = NULL;
> -		iov->lkey = ia->ri_dma_lkey;
> -		return 0;
> -	} else if (ia->ri_bind_mem != NULL) {
> -		*mrp = NULL;
> -		iov->lkey = ia->ri_bind_mem->lkey;
> -		return 0;
> -	}
> -
> -	ipb.addr = iov->addr;
> -	ipb.size = iov->length;
> -	mr = ib_reg_phys_mr(ia->ri_pd, &ipb, 1,
> -			IB_ACCESS_LOCAL_WRITE, &iov->addr);
> -
> -	dprintk("RPC:       %s: phys convert: 0x%llx "
> -			"registered 0x%llx length %d\n",
> -			__func__, (unsigned long long)ipb.addr,
> -			(unsigned long long)iov->addr, len);
> -
> -	if (IS_ERR(mr)) {
> -		*mrp = NULL;
> -		rc = PTR_ERR(mr);
> -		dprintk("RPC:       %s: failed with %i\n", __func__, rc);
> -	} else {
> -		*mrp = mr;
> -		iov->lkey = mr->lkey;
> -		rc = 0;
> -	}
> -
> -	return rc;
> -}
> -
> -static int
> -rpcrdma_deregister_internal(struct rpcrdma_ia *ia,
> -				struct ib_mr *mr, struct ib_sge *iov)
> -{
> -	int rc;
> -
> -	ib_dma_unmap_single(ia->ri_device,
> -			    iov->addr, iov->length, DMA_BIDIRECTIONAL);
> -
> -	if (NULL == mr)
> -		return 0;
> -
> -	rc = ib_dereg_mr(mr);
> -	if (rc)
> -		dprintk("RPC:       %s: ib_dereg_mr failed %i\n", __func__, rc);
> -	return rc;
> -}
> -
>   /**
>    * rpcrdma_alloc_regbuf - kmalloc and register memory for SEND/RECV buffers
>    * @ia: controlling rpcrdma_ia
> @@ -1317,26 +1248,30 @@ struct rpcrdma_regbuf *
>   rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
>   {
>   	struct rpcrdma_regbuf *rb;
> -	int rc;
> +	struct ib_sge *iov;
>
> -	rc = -ENOMEM;
>   	rb = kmalloc(sizeof(*rb) + size, flags);
>   	if (rb == NULL)
>   		goto out;
>
> -	rb->rg_size = size;
> -	rb->rg_owner = NULL;
> -	rc = rpcrdma_register_internal(ia, rb->rg_base, size,
> -				       &rb->rg_mr, &rb->rg_iov);
> -	if (rc)
> +	iov = &rb->rg_iov;
> +	iov->addr = ib_dma_map_single(ia->ri_device,
> +				      (void *)rb->rg_base, size,
> +				      DMA_BIDIRECTIONAL);
> +	if (ib_dma_mapping_error(ia->ri_device, iov->addr))
>   		goto out_free;
>
> +	iov->length = size;
> +	iov->lkey = ia->ri_have_dma_lkey ?
> +				ia->ri_dma_lkey : ia->ri_bind_mem->lkey;
> +	rb->rg_size = size;
> +	rb->rg_owner = NULL;
>   	return rb;
>
>   out_free:
>   	kfree(rb);
>   out:
> -	return ERR_PTR(rc);
> +	return ERR_PTR(-ENOMEM);
>   }
>
>   /**
> @@ -1347,10 +1282,15 @@ out:
>   void
>   rpcrdma_free_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
>   {
> -	if (rb) {
> -		rpcrdma_deregister_internal(ia, rb->rg_mr, &rb->rg_iov);
> -		kfree(rb);
> -	}
> +	struct ib_sge *iov;
> +
> +	if (!rb)
> +		return;
> +
> +	iov = &rb->rg_iov;
> +	ib_dma_unmap_single(ia->ri_device,
> +			    iov->addr, iov->length, DMA_BIDIRECTIONAL);
> +	kfree(rb);
>   }
>
>   /*
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index abee472..ce4e79e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -119,7 +119,6 @@ struct rpcrdma_ep {
>   struct rpcrdma_regbuf {
>   	size_t			rg_size;
>   	struct rpcrdma_req	*rg_owner;
> -	struct ib_mr		*rg_mr;
>   	struct ib_sge		rg_iov;
>   	__be32			rg_base[0] __attribute__ ((aligned(256)));
>   };
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
