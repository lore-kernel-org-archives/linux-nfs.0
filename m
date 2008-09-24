From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/10] svcrdma: Modify post recv path to use local dma
	key
Date: Wed, 24 Sep 2008 16:31:11 -0400
Message-ID: <20080924203111.GC10841@fieldses.org>
References: <1221564879-85046-1-git-send-email-tom@opengridcomputing.com> <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com> <1221564879-85046-4-git-send-email-tom@opengridcomputing.com> <1221564879-85046-5-git-send-email-tom@opengridcomputing.com> <1221564879-85046-6-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60714 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbYIXUbM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 16:31:12 -0400
In-Reply-To: <1221564879-85046-6-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2008 at 06:34:34AM -0500, Tom Tucker wrote:
> Update the svc_rdma_post_recv routine to use the adapter's global LKEY
> instead of sc_phys_mr which is only valid when using a DMA MR.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index b8c642d..a61caa7 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -476,7 +476,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
>  	struct ib_recv_wr recv_wr, *bad_recv_wr;
>  	struct svc_rdma_op_ctxt *ctxt;
>  	struct page *page;
> -	unsigned long pa;
> +	dma_addr_t pa;
>  	int sge_no;
>  	int buflen;
>  	int ret;
> @@ -488,13 +488,17 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
>  		BUG_ON(sge_no >= xprt->sc_max_sge);
>  		page = svc_rdma_get_page();
>  		ctxt->pages[sge_no] = page;
> -		atomic_inc(&xprt->sc_dma_used);
>  		pa = ib_dma_map_page(xprt->sc_cm_id->device,
>  				     page, 0, PAGE_SIZE,
>  				     DMA_FROM_DEVICE);
> +		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa)) {
> +			svc_rdma_put_context(ctxt, 1);
> +			return -ENOMEM;
> +		}

Might be a tad nicer to do a "goto out_put_ctx" here and consolidate the
cleanup with the similar cleanup done after the later ib_post_recv
failure.

--b.

> +		atomic_inc(&xprt->sc_dma_used);
>  		ctxt->sge[sge_no].addr = pa;
>  		ctxt->sge[sge_no].length = PAGE_SIZE;
> -		ctxt->sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
> +		ctxt->sge[sge_no].lkey = xprt->sc_dma_lkey;
>  		buflen += PAGE_SIZE;
>  	}
>  	ctxt->count = sge_no;
