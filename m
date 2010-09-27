Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42374 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757289Ab0I0Tkq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 15:40:46 -0400
Subject: Re: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA06CA0.6060606@parallels.com>
Date: Mon, 27 Sep 2010 15:40:26 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>
References: <4CA06C7A.5060307@parallels.com> <4CA06CA0.6060606@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 27, 2010, at 6:06 AM, Pavel Emelyanov wrote:

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
> net/sunrpc/xprtsock.c |   20 ++++++++++++--------
> 1 files changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index b6309db..98d4b7b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -759,6 +759,8 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
> 		xs_tcp_shutdown(xprt);
> }
> 
> +static void xs_free_xprt(struct rpc_xprt *xprt);

Style nit: we usually like forward declarations at the top of source files.

Do you need to fix up xprtrdma too?  (eg. xprt_rdma_destroy)  It looks like it has similar logic around freeing xprts.  Even though it doesn't use sockets, do we need to be concerned about net namespaces for RDMA transports?

> +
> /**
>  * xs_destroy - prepare to shutdown a transport
>  * @xprt: doomed transport
> @@ -774,8 +776,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
> 
> 	xs_close(xprt);
> 	xs_free_peer_addresses(xprt);
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xs_free_xprt(xprt);
> 	module_put(THIS_MODULE);
> }
> 
> @@ -2298,6 +2299,12 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
> 	return xprt;
> }
> 
> +static void xs_free_xprt(struct rpc_xprt *xprt)
> +{
> +	kfree(xprt->slot);
> +	kfree(xprt);
> +}
> +
> static const struct rpc_timeout xs_udp_default_timeout = {
> 	.to_initval = 5 * HZ,
> 	.to_maxval = 30 * HZ,
> @@ -2371,8 +2378,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xs_free_xprt(xprt);
> 	return ret;
> }
> 
> @@ -2447,8 +2453,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xs_free_xprt(xprt);
> 	return ret;
> }
> 
> @@ -2528,8 +2533,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> 		return xprt;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> -	kfree(xprt->slot);
> -	kfree(xprt);
> +	xs_free_xprt(xprt);
> 	return ret;
> }
> 
> -- 
> 1.5.5.6
> 

-- 
chuck[dot]lever[at]oracle[dot]com




