From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 02/11] sunrpc: take reference to bc_xprt in sunrpc layer
Date: Tue, 09 Mar 2010 20:03:00 -0500
Message-ID: <1268182980.9419.40.camel@localhost.localdomain>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
	 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
	 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9970 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab0CJBDW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 20:03:22 -0500
In-Reply-To: <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-03-09 at 19:28 -0500, J. Bruce Fields wrote: 
> Currently we're requiring whoever holds the reference to a client set up
> the on the backchannel to also hold a reference to the forechannel
> transport; but this should be the responsibility of the lower level
> code.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/xprtsock.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index a91f0a4..5adc000 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -792,6 +792,8 @@ static void xs_destroy(struct rpc_xprt *xprt)
>  
>  	xs_close(xprt);
>  	xs_free_peer_addresses(xprt);
> +	if (xprt->bc_xprt)
> +		svc_xprt_put(xprt->bc_xprt);
>  	kfree(xprt->slot);
>  	kfree(xprt);
>  	module_put(THIS_MODULE);
> @@ -2510,6 +2512,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>  	 * forechannel
>  	 */
>  	xprt->bc_xprt = args->bc_xprt;
> +	svc_xprt_get(xprt->bc_xprt);
>  	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
>  	bc_sock->sk_bc_xprt = xprt;
>  	transport->sock = bc_sock->sk_sock;
> @@ -2552,6 +2555,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>  		return xprt;
>  	ret = ERR_PTR(-EINVAL);
>  out_err:
> +	svc_xprt_put(xprt->bc_xprt);
>  	kfree(xprt->slot);
>  	kfree(xprt);
>  	return ret;

OK... This makes my head spin.

Why should the back channel socket hold a reference to the svc_sock? The
process that owns both of these things is an RPC server process. It
already holds a reference to the svc_sock and presumably also to the
back channel socket.

No?

Trond
