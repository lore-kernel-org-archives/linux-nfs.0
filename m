Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34819 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbaC1Vwf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 17:52:35 -0400
Date: Fri, 28 Mar 2014 17:52:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] svcrdma: fix offset calculation for non-page aligned
 sge entries
Message-ID: <20140328215234.GJ6041@fieldses.org>
References: <1395076205-26658-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1395076205-26658-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 17, 2014 at 01:10:05PM -0400, Jeff Layton wrote:
> The xdr_off value in dma_map_xdr gets passed to ib_dma_map_page as the
> offset into the page to be mapped. This calculation does not correctly
> take into account the case where the data starts at some offset into
> the page. Increment the xdr_off by the page_base to ensure that it is
> respected.

Thanks, applying.--b.

> 
> Cc: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index c1d124dc772b..5f14609b6336 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -265,6 +265,7 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
>  		xdr_off -= xdr->head[0].iov_len;
>  		if (xdr_off < xdr->page_len) {
>  			/* This offset is in the page list */
> +			xdr_off += xdr->page_base;
>  			page = xdr->pages[xdr_off >> PAGE_SHIFT];
>  			xdr_off &= ~PAGE_MASK;
>  		} else {
> -- 
> 1.8.5.3
> 
