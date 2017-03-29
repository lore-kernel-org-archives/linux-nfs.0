Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55890 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932654AbdC2B1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Mar 2017 21:27:18 -0400
Date: Tue, 28 Mar 2017 21:27:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
Message-ID: <20170329012717.GC20963@fieldses.org>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170326231254.1319.26075.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 26, 2017 at 07:27:35PM -0400, Chuck Lever wrote:
> Same change as Kinglong Mee's fix for the TCP backchannel service.

Thanks, applying!

And, apologies to all, I've let a few patches pile up the last week,
hoping to catch up and pass along a bugfix pull to Linus before next
week (when I'll need to be mostly offline again).

--b.

> 
> Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Some (perhaps late) review comments on 5283b03ee5cd:
> 
> I have reservations about returning RPC_PROG_MISMATCH in this case.
> RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
> not an RPC-level error, thus reporting the problem here seems like a
> layering violation.
> 
> I'm not sure why an explicit check is needed: if the server isn't
> listening on UDP, wouldn't clients see a transport-level rejection
> (like ECONNREFUSED)?
> 
> Are we certain that all client implementations (including
> backchannel clients) will do something useful when presented with
> such a rejection? At least in the backchannel case, the Linux server
> had no idea what to do with RPC_PROG_MISMATCH on the backchannel.
> The workload stopped dead, no error report anywhere.
> 
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index c13a5c3..fc8f14c 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -127,6 +127,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
>  	xprt = &cma_xprt->sc_xprt;
>  
>  	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
> +	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
>  	serv->sv_bc_xprt = xprt;
>  
>  	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
