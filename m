Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:44336 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbcEDS16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2016 14:27:58 -0400
Subject: Re: [PATCH] xprtrdma: Remove qplock
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160504144108.15760.95228.stgit@manet.1015granger.net>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <42a5d6b3-b861-2af3-7ab8-d09bda142923@Netapp.com>
Date: Wed, 4 May 2016 14:27:54 -0400
MIME-Version: 1.0
In-Reply-To: <20160504144108.15760.95228.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/04/2016 10:41 AM, Chuck Lever wrote:
> Clean up.
> 
> After "xprtrdma: Remove ro_unmap() from all registration modes",
> there are no longer any sites that take rpcrdma_ia::qplock for read.
> The one site that takes it for write is always single-threaded. It
> is safe to remove it.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Anna-
> 
> One more simple clean up for 4.7?

Sure, it looks okay to me.

Anna

> 
>  net/sunrpc/xprtrdma/verbs.c     |    3 ---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
>  2 files changed, 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index be66f65..b044d98a 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -433,7 +433,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
>  	dprintk("RPC:       %s: memory registration strategy is '%s'\n",
>  		__func__, ia->ri_ops->ro_displayname);
>  
> -	rwlock_init(&ia->ri_qplock);
>  	return 0;
>  
>  out3:
> @@ -672,10 +671,8 @@ retry:
>  			goto out;
>  		}
>  
> -		write_lock(&ia->ri_qplock);
>  		old = ia->ri_id;
>  		ia->ri_id = id;
> -		write_unlock(&ia->ri_qplock);
>  
>  		rdma_destroy_qp(old);
>  		rpcrdma_destroy_id(old);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 512bbdc..95cdc66 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -65,7 +65,6 @@
>   */
>  struct rpcrdma_ia {
>  	const struct rpcrdma_memreg_ops	*ri_ops;
> -	rwlock_t		ri_qplock;
>  	struct ib_device	*ri_device;
>  	struct rdma_cm_id 	*ri_id;
>  	struct ib_pd		*ri_pd;
> 

