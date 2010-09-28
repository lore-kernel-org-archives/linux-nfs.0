Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54816 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab0I1PlC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 11:41:02 -0400
Subject: Re: [PATCH 2/7] sunrpc: Factor out rpc_xprt freeing
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA206A2.7070409@parallels.com>
Date: Tue, 28 Sep 2010 11:37:48 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <D350167D-9D2F-430B-873E-A1364BE80DD5@oracle.com>
References: <4CA20651.4070605@parallels.com> <4CA206A2.7070409@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 28, 2010, at 11:15 AM, Pavel Emelyanov wrote:

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
> include/linux/sunrpc/xprt.h     |    1 +
> net/sunrpc/xprtrdma/transport.c |    7 ++-----
> net/sunrpc/xprtsock.c           |   19 +++++++++++--------
> 3 files changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 00f6e3f..af4b560 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -281,6 +281,7 @@ void			xprt_release(struct rpc_task *task);
> struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
> void			xprt_put(struct rpc_xprt *xprt);
> struct rpc_xprt *	xprt_alloc(int size, int max_req);
> +void			xprt_free(struct rpc_xprt *);
> 
> static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
> {
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 9d77bf2..0f7a1b9 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -251,9 +251,7 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
> 
> 	xprt_rdma_free_addresses(xprt);
> 
> -	kfree(xprt->slot);
> -	xprt->slot = NULL;
> -	kfree(xprt);
> +	xprt_free(xprt);
> 
> 	dprintk("RPC:       %s: returning\n", __func__);
> 
> @@ -401,8 +399,7 @@ out3:
> out2:
> 	rpcrdma_ia_close(&new_xprt->rx_ia);
> out1:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xprt_free(xprt);
> 	return ERR_PTR(rc);
> }
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 9f2dd3b..77cb595 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -781,6 +781,13 @@ out:
> }
> EXPORT_SYMBOL_GPL(xprt_alloc);
> 
> +void xprt_free(struct rpc_xprt *xprt)
> +{
> +	kfree(xprt->slot);
> +	kfree(xprt);
> +}
> +EXPORT_SYMBOL_GPL(xprt_free);

Likewise: I think xprt_free, being a generic API, belongs in net/sunrpc/xprt.c not in xprtsock.c

If the xprt and slot table were allocated with a single kcalloc request, for example, then you probably wouldn't need xprt_free at all.  Not saying that's a requirement, but simply making an observation.

> +
> /**
>  * xs_destroy - prepare to shutdown a transport
>  * @xprt: doomed transport
> @@ -796,8 +803,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
> 
> 	xs_close(xprt);
> 	xs_free_peer_addresses(xprt);
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xprt_free(xprt);
> 	module_put(THIS_MODULE);
> }
> 
> @@ -2384,8 +2390,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xprt_free(xprt);
> 	return ret;
> }
> 
> @@ -2460,8 +2465,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xprt_free(xprt);
> 	return ret;
> }
> 
> @@ -2541,8 +2545,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xprt_free(xprt);
> 	return ret;
> }
> 
> -- 
> 1.5.5.6
> 

-- 
chuck[dot]lever[at]oracle[dot]com




