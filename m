Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41497 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab0I1PfT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 11:35:19 -0400
Subject: Re: [PATCH 1/7] sunrpc: Factor out rpc_xprt allocation
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA20689.6060405@parallels.com>
Date: Tue, 28 Sep 2010 11:34:57 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <10FA0502-F580-460A-BADC-9AEEA7ADE4A3@oracle.com>
References: <4CA20651.4070605@parallels.com> <4CA20689.6060405@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 28, 2010, at 11:15 AM, Pavel Emelyanov wrote:

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> include/linux/sunrpc/xprt.h     |    1 +
> net/sunrpc/xprtrdma/transport.c |   13 ++-----------
> net/sunrpc/xprtsock.c           |   37 +++++++++++++++++++++++++------------
> 3 files changed, 28 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index ff5a77b..00f6e3f 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -280,6 +280,7 @@ void			xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
> void			xprt_release(struct rpc_task *task);
> struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
> void			xprt_put(struct rpc_xprt *xprt);
> +struct rpc_xprt *	xprt_alloc(int size, int max_req);
> 
> static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
> {
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index a85e866..9d77bf2 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -285,23 +285,14 @@ xprt_setup_rdma(struct xprt_create *args)
> 		return ERR_PTR(-EBADF);
> 	}
> 
> -	xprt = kzalloc(sizeof(struct rpcrdma_xprt), GFP_KERNEL);
> +	xprt = xprt_alloc(sizeof(struct rpcrdma_xprt),
> +			xprt_rdma_slot_table_entries);
> 	if (xprt == NULL) {
> 		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
> 			__func__);
> 		return ERR_PTR(-ENOMEM);
> 	}
> 
> -	xprt->max_reqs = xprt_rdma_slot_table_entries;
> -	xprt->slot = kcalloc(xprt->max_reqs,
> -				sizeof(struct rpc_rqst), GFP_KERNEL);
> -	if (xprt->slot == NULL) {
> -		dprintk("RPC:       %s: couldn't allocate %d slots\n",
> -			__func__, xprt->max_reqs);
> -		kfree(xprt);
> -		return ERR_PTR(-ENOMEM);
> -	}
> -
> 	/* 60 second timeout, no retries */
> 	xprt->timeout = &xprt_rdma_default_timeout;
> 	xprt->bind_timeout = (60U * HZ);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index b6309db..9f2dd3b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -759,6 +759,28 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
> 		xs_tcp_shutdown(xprt);
> }
> 
> +struct rpc_xprt *xprt_alloc(int size, int max_req)
> +{
> +	struct rpc_xprt *xprt;
> +
> +	xprt = kzalloc(size, GFP_KERNEL);
> +	if (xprt == NULL)
> +		goto out;
> +
> +	xprt->max_reqs = max_req;
> +	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
> +	if (xprt->slot == NULL)
> +		goto out_free;
> +
> +	return xprt;
> +
> +out_free:
> +	kfree(xprt);
> +out:
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(xprt_alloc);

If xprt_alloc is a generic function, used by different transport capabilities, then it belongs in net/sunrpc/xprt.c, not in a transport-specific source file like xprtsock.c .

Also, would it makes sense to allocate these via a single kcalloc request, or would that possibly result in a high-order (ie non-zero) allocation in some cases?

> +
> /**
>  * xs_destroy - prepare to shutdown a transport
>  * @xprt: doomed transport
> @@ -2273,23 +2295,14 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
> 		return ERR_PTR(-EBADF);
> 	}
> 
> -	new = kzalloc(sizeof(*new), GFP_KERNEL);
> -	if (new == NULL) {
> +	xprt = xprt_alloc(sizeof(*new), slot_table_size);
> +	if (xprt == NULL) {
> 		dprintk("RPC:       xs_setup_xprt: couldn't allocate "
> 				"rpc_xprt\n");
> 		return ERR_PTR(-ENOMEM);
> 	}
> -	xprt = &new->xprt;
> -
> -	xprt->max_reqs = slot_table_size;
> -	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
> -	if (xprt->slot == NULL) {
> -		kfree(xprt);
> -		dprintk("RPC:       xs_setup_xprt: couldn't allocate slot "
> -				"table\n");
> -		return ERR_PTR(-ENOMEM);
> -	}
> 
> +	new = container_of(xprt, struct sock_xprt, xprt);
> 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
> 	xprt->addrlen = args->addrlen;
> 	if (args->srcaddr)
> -- 
> 1.5.5.6
> 

-- 
chuck[dot]lever[at]oracle[dot]com




