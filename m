From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 09/10] SUNRPC: Update xprt address strings after an
 rpcbind completes
Date: Thu, 06 Aug 2009 17:19:23 -0400
Message-ID: <1249593563.5876.18.camel@heimdal.trondhjem.org>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
	 <20090806185538.3458.20717.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44858 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755728AbZHFVTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 17:19:34 -0400
In-Reply-To: <20090806185538.3458.20717.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-06 at 14:55 -0400, Chuck Lever wrote:
> After a bind completes, update the transport instance's address
> strings so debugging messages display the current port the transport
> is connected to.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtsock.c |   82 +++++++++++++++++++++++++------------------------
>  1 files changed, 41 insertions(+), 41 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index eee5ac9..8aaf900 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -299,11 +299,34 @@ static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
>  static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
>  {
>  	struct sockaddr *sap = xs_addr(xprt);
> +	struct sockaddr_in6 *sin6;
> +	struct sockaddr_in *sin;
>  	char buf[128];
>  
>  	(void)rpc_ntop(sap, buf, sizeof(buf));
>  	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
>  
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		sin = xs_addr_in(xprt);
> +		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
> +					NIPQUAD(sin->sin_addr.s_addr));
> +		break;
> +	case AF_INET6:
> +		sin6 = xs_addr_in6(xprt);
> +		(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
> +		break;

Hmm... Doesn't it make sense to convert this to use rpc_ntop() now that
I've applied those patches?

Trond

