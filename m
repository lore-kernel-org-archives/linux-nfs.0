From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] svcrdma: dma unmap the correct length for the
 RPCRDMA	header page.
Date: Tue, 26 May 2009 15:41:24 -0500
Message-ID: <4A1C53F4.1080701@opengridcomputing.com>
References: <20090514213428.19282.27658.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:54559 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbZEZUkW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2009 16:40:22 -0400
In-Reply-To: <20090514213428.19282.27658.stgit-T4OLL4TyM9aNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

Do you think this can make 2.6.30?

Thanks,

Steve.


Steve Wise wrote:
> The svcrdma module was incorrectly unmapping the RPCRDMA header page.
> On IBM pserver systems this causes a resource leak that results in
> running out of bus address space (10 cthon iterations will reproduce it).
> The code was mapping the full page but only unmapping the actual header
> length.  The fix is to only map the header length.
>
> I also cleaned up the use of ib_dma_map_page() calls since the unmap
> logic always uses ib_dma_unmap_single().  I made these symmetrical.
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   12 ++++++------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +++++-----
>  2 files changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 8b510c5..f071b7e 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -128,7 +128,8 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
>  		page_bytes -= sge_bytes;
>  
>  		frmr->page_list->page_list[page_no] =
> -			ib_dma_map_page(xprt->sc_cm_id->device, page, 0,
> +			ib_dma_map_single(xprt->sc_cm_id->device, 
> +					  page_address(page),
>  					  PAGE_SIZE, DMA_TO_DEVICE);
>  		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
>  					 frmr->page_list->page_list[page_no]))
> @@ -532,18 +533,17 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
>  
>  	/* Prepare the SGE for the RPCRDMA Header */
> +	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
> +	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
>  	ctxt->sge[0].addr =
> -		ib_dma_map_page(rdma->sc_cm_id->device,
> -				page, 0, PAGE_SIZE, DMA_TO_DEVICE);
> +		ib_dma_map_single(rdma->sc_cm_id->device, page_address(page),
> +				  ctxt->sge[0].length, DMA_TO_DEVICE);
>  	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr))
>  		goto err;
>  	atomic_inc(&rdma->sc_dma_used);
>  
>  	ctxt->direction = DMA_TO_DEVICE;
>  
> -	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
> -	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
> -
>  	/* Determine how many of our SGE are to be transmitted */
>  	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
>  		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 4b0c2fa..5151f9f 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -500,8 +500,8 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
>  		BUG_ON(sge_no >= xprt->sc_max_sge);
>  		page = svc_rdma_get_page();
>  		ctxt->pages[sge_no] = page;
> -		pa = ib_dma_map_page(xprt->sc_cm_id->device,
> -				     page, 0, PAGE_SIZE,
> +		pa = ib_dma_map_single(xprt->sc_cm_id->device,
> +				     page_address(page), PAGE_SIZE,
>  				     DMA_FROM_DEVICE);
>  		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
>  			goto err_put_ctxt;
> @@ -1315,8 +1315,8 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
>  	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
>  
>  	/* Prepare SGE for local address */
> -	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
> -				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
> +	sge.addr = ib_dma_map_single(xprt->sc_cm_id->device,
> +				   page_address(p), PAGE_SIZE, DMA_FROM_DEVICE);
>  	if (ib_dma_mapping_error(xprt->sc_cm_id->device, sge.addr)) {
>  		put_page(p);
>  		return;
> @@ -1343,7 +1343,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
>  	if (ret) {
>  		dprintk("svcrdma: Error %d posting send for protocol error\n",
>  			ret);
> -		ib_dma_unmap_page(xprt->sc_cm_id->device,
> +		ib_dma_unmap_single(xprt->sc_cm_id->device,
>  				  sge.addr, PAGE_SIZE,
>  				  DMA_FROM_DEVICE);
>  		svc_rdma_put_context(ctxt, 1);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

