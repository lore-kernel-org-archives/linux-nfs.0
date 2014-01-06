Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39246 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbaAFUU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 15:20:27 -0500
Date: Mon, 6 Jan 2014 15:20:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix memory leak of peer addresses in XPRT
Message-ID: <20140106202024.GD31764@fieldses.org>
References: <52CA8460.6030206@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52CA8460.6030206@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 06:24:32PM +0800, Kinglong Mee wrote:
> If creating xprt failed after xs_format_peer_addresses,
> sunrpc must free those memory of peer addresses in xprt.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/xprtsock.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 25dbfa9..11ceba3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2725,8 +2725,10 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>  		xprt_set_bound(xprt);
>  		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
>  		ret = ERR_PTR(xs_local_setup_socket(transport));
> -		if (ret)
> +		if (ret) {
> +			xs_free_peer_addresses(xprt);
>  			goto out_err;
> +		}
>  		break;
>  	default:
>  		ret = ERR_PTR(-EAFNOSUPPORT);
> @@ -2738,6 +2740,8 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>  
>  	if (try_module_get(THIS_MODULE))
>  		return xprt;
> +
> +	xs_free_peer_addresses(xprt);
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
>  	xprt_free(xprt);

This is getting a little hairy.... Looks like xprts are alloc'd with
kzalloc() and xs_free_peer_addresses is a no-op if
xprt->address_strings[i] is NULL, so it looks safe to call
unconditionally after out_err?

> @@ -2816,6 +2820,8 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>  
>  	if (try_module_get(THIS_MODULE))
>  		return xprt;
> +
> +	xs_free_peer_addresses(xprt);
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
>  	xprt_free(xprt);
> @@ -2893,9 +2899,10 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  				xprt->address_strings[RPC_DISPLAY_ADDR],
>  				xprt->address_strings[RPC_DISPLAY_PROTO]);
>  
> -
>  	if (try_module_get(THIS_MODULE))
>  		return xprt;
> +
> +	xs_free_peer_addresses(xprt);
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
>  	xprt_free(xprt);
> -- 
> 1.8.4.2

And after this we'll end up with

	xs_free_peer_addresses(xprt);
	xprt_free(xprt);

in 4 different places (the above plus xs_destroy), so I might define an
xs_xprt_free() to do that.

--b.
