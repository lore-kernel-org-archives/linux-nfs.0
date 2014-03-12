Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36529 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbaCLUnK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 16:43:10 -0400
Message-ID: <5320C6DE.4090807@opengridcomputing.com>
Date: Wed, 12 Mar 2014 15:43:10 -0500
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, bfields@fieldses.org
CC: linux-nfs@vger.kernel.org, swise@opengridcomputing.com,
        Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH] svcrdma: fix offset calculation for non-page aligned
 sge entries
References: <1394635867-19089-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1394635867-19089-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,


On 3/12/14 9:51 AM, Jeff Layton wrote:
> The xdr_off value in dma_map_xdr gets passed to ib_dma_map_page as the
> offset into the page to be mapped. For the case of the pages array, the
> existing calculation always seems to end up at 0, which causes data
> corruption when a non-page-aligned READ request comes in. The server ends
> up doing the RDMA_WRITE from the wrong part of the page.
>
> Override the xdr_off value with the page_base in that situation to fix
> the issue. Obviously, this method can't contend with a page_base that is
> larger than PAGE_SIZE.
I think we saw page base > PAGE_SIZE when inter-operating with Sun, but 
maybe someone else on the list has a clearer recollection.

I am curious, however, why xdr_off was always zero if in fact, page_base 
was not page aligned.

Thanks,
Tom
> I'm not sure if that's ever the case, but add a
> WARN_ON in the event that that ever happens.
>
> Cc: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>   net/sunrpc/xprtrdma/svc_rdma_sendto.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index c1d124dc772b..76e524b428d0 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -265,8 +265,11 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
>   		xdr_off -= xdr->head[0].iov_len;
>   		if (xdr_off < xdr->page_len) {
>   			/* This offset is in the page list */
> -			page = xdr->pages[xdr_off >> PAGE_SHIFT];
> -			xdr_off &= ~PAGE_MASK;
> +			int pgnum = xdr_off >> PAGE_SHIFT;
> +
> +			page = xdr->pages[pgnum];
> +			WARN_ON(xdr->page_base > PAGE_SIZE);
> +			xdr_off = pgnum ? 0 : xdr->page_base;
>   		} else {
>   			/* This offset is in the tail */
>   			xdr_off -= xdr->page_len;

