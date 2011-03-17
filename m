Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52998 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753354Ab1CQSh5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 14:37:57 -0400
Date: Thu, 17 Mar 2011 14:37:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        Chuck Lever <chuck.lever@oracle.com>, Tejun Heo <tj@kernel.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] SUNRPC: Remove resource leak in svc_rdma_send_error()
Message-ID: <20110317183752.GH30180@fieldses.org>
References: <alpine.LNX.2.00.1101222233260.7746@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.00.1101222233260.7746@swampdragon.chaosbits.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jan 22, 2011 at 10:40:20PM +0100, Jesper Juhl wrote:
> We leak the memory allocated to 'ctxt' when we return after 
> 'ib_dma_mapping_error()' returns !=0.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

I don't know this code, but I can't see how that could be wrong....
Applying unless Tom tells me otherwise.

--b.

> ---
>  svc_rdma_transport.c |    1 +
>  1 file changed, 1 insertion(+)
> 
>   compile tested only
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 9df1ead..1a10dcd 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1335,6 +1335,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
>  					    p, 0, length, DMA_FROM_DEVICE);
>  	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
>  		put_page(p);
> +		svc_rdma_put_context(ctxt, 1);
>  		return;
>  	}
>  	atomic_inc(&xprt->sc_dma_used);
> 
> 
> -- 
> Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
> 
