Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49690 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdAIGmh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2017 01:42:37 -0500
Date: Mon, 9 Jan 2017 08:42:25 +0200
From: Yuval Shaia <yuval.shaia@oracle.com>
To: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: avoid duplicate dma unmapping during error
 recovery
Message-ID: <20170109064224.GA3820@yuval-lap>
References: <20170109103044.5590-1-sriharsha.basavapatna@broadcom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170109103044.5590-1-sriharsha.basavapatna@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 09, 2017 at 04:00:44PM +0530, Sriharsha Basavapatna wrote:
> In rdma_read_chunk_frmr() when ib_post_send() fails, the error code path
> invokes ib_dma_unmap_sg() to unmap the sg list. It then invokes
> svc_rdma_put_frmr() which in turn tries to unmap the same sg list through
> ib_dma_unmap_sg() again. This second unmap is invalid and could lead to
> problems when the iova being unmapped is subsequently reused. Remove
> the call to unmap in rdma_read_chunk_frmr() and let svc_rdma_put_frmr()
> handle it.
> 
> Fixes: 412a15c0fe53 ("svcrdma: Port to new memory registration API")
> Cc: stable@vger.kernel.org
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 57d35fbb1c28..172b537f8cfc 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -347,8 +347,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>  	atomic_inc(&rdma_stat_read);
>  	return ret;
>   err:
> -	ib_dma_unmap_sg(xprt->sc_cm_id->device,
> -			frmr->sg, frmr->sg_nents, frmr->direction);
>  	svc_rdma_put_context(ctxt, 0);
>  	svc_rdma_put_frmr(xprt, frmr);
>  	return ret;

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

> -- 
> 2.11.0.258.ge05806da9
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
