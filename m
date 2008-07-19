From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 7/8] SUNRPC: Set V6ONLY socket option for RPC listener
	sockets
Date: Fri, 18 Jul 2008 21:05:50 -0400
Message-ID: <20080719010550.GA18907@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net> <20080630224616.24887.13171.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbYGSBGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2008 21:06:01 -0400
In-Reply-To: <20080630224616.24887.13171.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:46:17PM -0400, Chuck Lever wrote:
> My plan is to use an AF_INET listener on systems that support only IPv4,
> and an AF_INET6 listener on systems that can support IPv6. Incoming
> IPv4 packets will be posted to an AF_INET6 listener with a mapped IPv4
> address.
> 
> Max Matveev <makc@sgi.com> says:
>   Creating a single listener can be dangerous - if net.ipv6.bindv6only
>   is enabled then it's possible to create another listener in v4
>   namespace on the same port and steal the traffic from the "unifed"
>   listener. You need to disable V6ONLY explicitly via a sockopt to stop
>   that.

Is the V6ONLY option documented anywhere?  A quick grep through the
kernel sources and a couple man pages didn't turn up anything.

--b.

> 
> Set appropriate socket option on RPC server listener sockets to prevent
> this.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svcsock.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 3e65719..43c21f7 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1114,6 +1114,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>  	struct svc_sock	*svsk;
>  	struct sock	*inet;
>  	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
> +	int zero	= 0;
>  
>  	dprintk("svc: svc_setup_socket %p\n", sock);
>  	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
> @@ -1146,6 +1147,17 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>  	else
>  		svc_tcp_init(svsk, serv);
>  
> +	/*
> +	 * We start one listener per sv_serv.  We want AF_INET
> +	 * requests to be automatically shunted to our AF_INET6
> +	 * listener using a mapped IPv4 address.  Make sure
> +	 * no-one starts an equivalent IPv4 listener, which
> +	 * would steal our incoming connections.
> +	 */
> +	if (serv->sv_family == AF_INET6)
> +		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
> +					(char *)&zero, sizeof(zero));
> +
>  	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>  				svsk, svsk->sk_sk);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
