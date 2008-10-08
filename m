From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 10/15] RPC/RDMA: return a consistent error to mount,
	when connect fails.
Date: Wed, 08 Oct 2008 13:31:22 -0400
Message-ID: <1223487082.7361.17.camel@localhost>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
	 <20081008154835.1336.85484.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Tom Talpey <talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35487 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbYJHRbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:31:25 -0400
In-Reply-To: <20081008154835.1336.85484.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
> The mount system call path does not expect such errors as ECONNREFUSED
> to be returned from failed transport connection attempts, otherwise it
> prints simply "internal error". Translate all such errors to ENOTCONN
> from RPC/RDMA to match sockets behavior.

Hmm... Shouldn't we be passing the ECONNREFUSED error here, and rather
fix the downstream error paths?

> Signed-off-by: Tom Talpey <talpey@netapp.com>
> ---
> 
>  net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index c4b8011..11ea8da 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -700,7 +700,7 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
>  			xprt_wake_pending_tasks(xprt, 0);
>  	} else {
>  		if (xprt_test_and_clear_connected(xprt))
> -			xprt_wake_pending_tasks(xprt, ep->rep_connected);
> +			xprt_wake_pending_tasks(xprt, -ENOTCONN);
>  	}
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

