Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:32833 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932944AbbGJUnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 16:43:43 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for
 RDMA_NOMSG calls
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204305.26247.39173.stgit@manet.1015granger.net>
Message-ID: <55A02E73.7000902@Netapp.com>
Date: Fri, 10 Jul 2015 16:43:31 -0400
MIME-Version: 1.0
In-Reply-To: <20150709204305.26247.39173.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 07/09/2015 04:43 PM, Chuck Lever wrote:
> Only the RPC/RDMA header is sent when making an RDMA_NOMSG call.
> That header resides in the first element of the iovec array
> passed to rpcrdma_ep_post().
> 
> Instead of special casing the iovec element with the pad, just
> sync all the elements in the send iovec. Syncing the zero pad is
> not strictly necessary, but the pad is rarely if ever used these
> days, and the extra cost in that case is small.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index cdf5220..9199436 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1316,22 +1318,15 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
>  
>  	send_wr.next = NULL;
>  	send_wr.wr_id = RPCRDMA_IGNORE_COMPLETION;
> -	send_wr.sg_list = req->rl_send_iov;
> +	send_wr.sg_list = iov;
>  	send_wr.num_sge = req->rl_niovs;
>  	send_wr.opcode = IB_WR_SEND;
> -	if (send_wr.num_sge == 4)	/* no need to sync any pad (constant) */
> -		ib_dma_sync_single_for_device(ia->ri_device,
> -					      req->rl_send_iov[3].addr,
> -					      req->rl_send_iov[3].length,
> -					      DMA_TO_DEVICE);
> -	ib_dma_sync_single_for_device(ia->ri_device,
> -				      req->rl_send_iov[1].addr,
> -				      req->rl_send_iov[1].length,
> -				      DMA_TO_DEVICE);
> -	ib_dma_sync_single_for_device(ia->ri_device,
> -				      req->rl_send_iov[0].addr,
> -				      req->rl_send_iov[0].length,
> -				      DMA_TO_DEVICE);
> +
> +	for (i = 0; i < send_wr.num_sge; i++)
> +		ib_dma_sync_single_for_device(device, iov[i].addr,
> +					      iov[i].length, DMA_TO_DEVICE);

Two questions here:
1) Is syncing order important?  The original code went 3 - 1 - 0, but now we're going 0 - 1 - 2 - 3.
2) Is iov[2] the zero pad you mentioned in your commit message?  If not, do you know why it wasn't already syncing?

Thanks,
Anna

> +	dprintk("RPC:       %s: posting %d s/g entries\n",
> +		__func__, send_wr.num_sge);
>  
>  	if (DECR_CQCOUNT(ep) > 0)
>  		send_wr.send_flags = 0;

