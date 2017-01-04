Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22451 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761650AbdADSUZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2017 13:20:25 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] svcrdma: avoid duplicate dma unmapping during error recovery
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170104160329.24436-1-sriharsha.basavapatna@broadcom.com>
Date: Wed, 4 Jan 2017 13:20:04 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Sagi Grimberg <sagi@grimberg.me>
Message-Id: <AA723EBA-9C66-4E47-A8D7-D2625F0300B4@oracle.com>
References: <20170104160329.24436-1-sriharsha.basavapatna@broadcom.com>
To: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 4, 2017, at 11:03 AM, Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com> wrote:
> 
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

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 --
> 1 file changed, 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 57d35fbb1c28..172b537f8cfc 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -347,8 +347,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> 	atomic_inc(&rdma_stat_read);
> 	return ret;
>  err:
> -	ib_dma_unmap_sg(xprt->sc_cm_id->device,
> -			frmr->sg, frmr->sg_nents, frmr->direction);
> 	svc_rdma_put_context(ctxt, 0);
> 	svc_rdma_put_frmr(xprt, frmr);
> 	return ret;
> -- 
> 2.11.0.258.ge05806da9
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



