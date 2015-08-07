Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58740 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945898AbbHGRgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 13:36:17 -0400
Date: Fri, 7 Aug 2015 13:36:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: limit FRMR page list lengths to device max
Message-ID: <20150807173616.GD15313@fieldses.org>
References: <20150807163539.EFDEFE0ACC@smtp.ogc.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150807163539.EFDEFE0ACC@smtp.ogc.us>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 07, 2015 at 11:11:20AM -0500, Steve Wise wrote:
> Svcrdma was incorrectly allocating fastreg MRs and page lists using
> RPCSVC_MAXPAGES, which can exceed the device capabilities.  So limit
> the depth to the minimum of RPCSVC_MAXPAGES and xprt->sc_frmr_pg_list_len.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> Doug, this patch needs to be added after this commit:
> 
> e20684a xprtrdma, svcrdma: Convert to ib_alloc_mr
> 
> and before these commits:
> 
> af78181 cxgb3: Support ib_alloc_mr verb
> b7e06cd iw_cxgb4: Support ib_alloc_mr verb
> 
> This will avoid a bisect window where NFSRDMA over cxgb4 is broken.
> 
> Bruce, please ACK if this commit looks good, and also if you're ok with
> this flowing through Doug's rdma tree due to the dependencies.

Fine by me.  On a quick check the only pending change in my tree nearby
there is 31193fe5f6fb "svcrdma: Remove svc_rdma_fastreg()", which
shouldn't conflict.

	Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 8752a2d..11d5133 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -733,17 +733,19 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>  	struct ib_mr *mr;
>  	struct ib_fast_reg_page_list *pl;
>  	struct svc_rdma_fastreg_mr *frmr;
> +	u32 num_sg;
>  
>  	frmr = kmalloc(sizeof(*frmr), GFP_KERNEL);
>  	if (!frmr)
>  		goto err;
>  
> -	mr = ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, RPCSVC_MAXPAGES);
> +	num_sg = min_t(u32, RPCSVC_MAXPAGES, xprt->sc_frmr_pg_list_len);
> +	mr = ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, num_sg);
>  	if (IS_ERR(mr))
>  		goto err_free_frmr;
>  
>  	pl = ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
> -					 RPCSVC_MAXPAGES);
> +					 num_sg);
>  	if (IS_ERR(pl))
>  		goto err_free_mr;
>  
> -- 
> 1.7.1
