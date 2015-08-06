Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:27002 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755036AbbHFOXF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2015 10:23:05 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH for-4.3 06/15] xprtrdma, svcrdma: Convert to ib_alloc_mr
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <target-devel@vger.kernel.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <1438241568-3685-7-git-send-email-sagig@mellanox.com>
Message-ID: <55C36D9F.1040705@Netapp.com>
Date: Thu, 6 Aug 2015 10:22:23 -0400
MIME-Version: 1.0
In-Reply-To: <1438241568-3685-7-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks good to me:

	Signed-off-by:  Anna Schumaker <Anna.Schumaker@Netapp.com>

Thanks,
Anna

On 07/30/2015 03:32 AM, Sagi Grimberg wrote:
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> ---
>  net/sunrpc/xprtrdma/frwr_ops.c           | 6 +++---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 63f282e..d6653f5 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -117,7 +117,7 @@ __frwr_recovery_worker(struct work_struct *work)
>  	if (ib_dereg_mr(r->r.frmr.fr_mr))
>  		goto out_fail;
>  
> -	r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(pd, depth);
> +	r->r.frmr.fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
>  	if (IS_ERR(r->r.frmr.fr_mr))
>  		goto out_fail;
>  
> @@ -148,7 +148,7 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
>  	struct rpcrdma_frmr *f = &r->r.frmr;
>  	int rc;
>  
> -	f->fr_mr = ib_alloc_fast_reg_mr(pd, depth);
> +	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
>  	if (IS_ERR(f->fr_mr))
>  		goto out_mr_err;
>  	f->fr_pgl = ib_alloc_fast_reg_page_list(device, depth);
> @@ -158,7 +158,7 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
>  
>  out_mr_err:
>  	rc = PTR_ERR(f->fr_mr);
> -	dprintk("RPC:       %s: ib_alloc_fast_reg_mr status %i\n",
> +	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
>  		__func__, rc);
>  	return rc;
>  
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 6b36279..adcf904 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -738,7 +738,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>  	if (!frmr)
>  		goto err;
>  
> -	mr = ib_alloc_fast_reg_mr(xprt->sc_pd, RPCSVC_MAXPAGES);
> +	mr = ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, RPCSVC_MAXPAGES);
>  	if (IS_ERR(mr))
>  		goto err_free_frmr;
>  
> 

