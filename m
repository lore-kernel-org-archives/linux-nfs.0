Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46137 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbaC2Azk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 20:55:40 -0400
Date: Fri, 28 Mar 2014 20:55:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RESEND] SUNRPC: fix memory leak of peer addresses in XPRT
Message-ID: <20140329005540.GN6041@fieldses.org>
References: <52CA8460.6030206@gmail.com>
 <20140106202024.GD31764@fieldses.org>
 <52CB793A.1040501@gmail.com>
 <CAB6yy36XqHUw-xddMtDx6MBazBQTbfG0v5ujf5pC0mjmgm=HBQ@mail.gmail.com>
 <532FA16A.9070509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <532FA16A.9070509@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 24, 2014 at 11:07:22AM +0800, Kinglong Mee wrote:
> Creating xprt failed after xs_format_peer_addresses,
> sunrpc must free those memory of peer addresses in xprt.

Looks right, thanks--applying.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/xprtsock.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 0addefc..2cbafa7 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -909,6 +909,12 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
>  		xs_tcp_shutdown(xprt);
>  }
>  
> +static void xs_xprt_free(struct rpc_xprt *xprt)
> +{
> +	xs_free_peer_addresses(xprt);
> +	xprt_free(xprt);
> +}
> +
>  /**
>   * xs_destroy - prepare to shutdown a transport
>   * @xprt: doomed transport
> @@ -919,8 +925,7 @@ static void xs_destroy(struct rpc_xprt *xprt)
>  	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
>  
>  	xs_close(xprt);
> -	xs_free_peer_addresses(xprt);
> -	xprt_free(xprt);
> +	xs_xprt_free(xprt);
>  	module_put(THIS_MODULE);
>  }
>  
> @@ -2744,7 +2749,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>  		return xprt;
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
> -	xprt_free(xprt);
> +	xs_xprt_free(xprt);
>  	return ret;
>  }
>  
> @@ -2822,7 +2827,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>  		return xprt;
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
> -	xprt_free(xprt);
> +	xs_xprt_free(xprt);
>  	return ret;
>  }
>  
> @@ -2897,12 +2902,11 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  				xprt->address_strings[RPC_DISPLAY_ADDR],
>  				xprt->address_strings[RPC_DISPLAY_PROTO]);
>  
> -
>  	if (try_module_get(THIS_MODULE))
>  		return xprt;
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
> -	xprt_free(xprt);
> +	xs_xprt_free(xprt);
>  	return ret;
>  }
>  
> @@ -2985,13 +2989,12 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>  	 */
>  	xprt_set_connected(xprt);
>  
> -
>  	if (try_module_get(THIS_MODULE))
>  		return xprt;
>  	xprt_put(xprt);
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
> -	xprt_free(xprt);
> +	xs_xprt_free(xprt);
>  	return ret;
>  }
>  
> -- 
> 1.8.5.3
> 
