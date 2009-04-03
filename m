From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] svcrdma: Fix dma map direction for rdma read targets
Date: Fri, 03 Apr 2009 15:23:47 -0500
Message-ID: <49D67053.2080105@opengridcomputing.com>
References: <20090403201824.18102.62915.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:51494 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759255AbZDCUXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 16:23:49 -0400
In-Reply-To: <20090403201824.18102.62915.stgit-T4OLL4TyM9aNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Wise wrote:
> The nfs server rdma transport was mapping rdma read target pages for
> TO_DEVICE instead of FROM_DEVICE.  This causes data corruption on non
> cache-coherent systems if frmrs are used.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 629a287..42a6f9f 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -265,7 +265,7 @@ static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
>  		frmr->page_list->page_list[page_no] =
>  			ib_dma_map_single(xprt->sc_cm_id->device,
>  					  page_address(rqstp->rq_arg.pages[page_no]),
> -					  PAGE_SIZE, DMA_TO_DEVICE);
> +					  PAGE_SIZE, DMA_FROM_DEVICE);

FWIW, this looks good to me.

>  		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
>  					 frmr->page_list->page_list[page_no]))
>  			goto fatal_err;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

