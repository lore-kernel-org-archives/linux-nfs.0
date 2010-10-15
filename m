Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55326 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202Ab0JOQFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 12:05:50 -0400
Date: Fri, 15 Oct 2010 12:05:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 9/13] sunrpc: Merge the xs_bind code
Message-ID: <20101015160545.GB12268@fieldses.org>
References: <4CA9CDA8.4010407@parallels.com>
 <4CA9CEE8.9050404@parallels.com>
 <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com>
 <4CAABAAB.8040608@parallels.com>
 <4CAB11A4.7000306@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CAB11A4.7000306@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 05, 2010 at 03:53:08PM +0400, Pavel Emelyanov wrote:
> There's the only difference betseen the xs_bind4 and the
> xs_bind6 - the size of sockaddr structure they use.
> 
> Fortunatelly its size can be indirectly get from the transport.
> 
> Change since v1:
> * use sockaddr_storage instead of sockaddr
> * use rpc_set_port instead of manual port assigning

Whoops, dropping this; it breaks nfsd startup.  I haven't figured out
why yet, but I get

RPC: server localhost requires stronger authentication.
svc: failed to register nfsdv2 RPC service (errno 13).

--b.

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
>  net/sunrpc/xprtsock.c |   64 +++++++++++++------------------------------------
>  1 files changed, 17 insertions(+), 47 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7fdf2bb..bab808f 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1534,23 +1534,18 @@ static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned shor
>  		return xprt_max_resvport;
>  	return --port;
>  }
> -
> -static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>  {
> -	struct sockaddr_in myaddr = {
> -		.sin_family = AF_INET,
> -	};
> -	struct sockaddr_in *sa;
> +	struct sockaddr_storage myaddr;
>  	int err, nloop = 0;
>  	unsigned short port = xs_get_srcport(transport);
>  	unsigned short last;
>  
> -	sa = (struct sockaddr_in *)&transport->srcaddr;
> -	myaddr.sin_addr = sa->sin_addr;
> +	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
>  	do {
> -		myaddr.sin_port = htons(port);
> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> -						sizeof(myaddr));
> +		rpc_set_port((struct sockaddr *)&myaddr, port);
> +		err = kernel_bind(sock, (struct sockaddr *)&myaddr,
> +				transport->xprt.addrlen);
>  		if (port == 0)
>  			break;
>  		if (err == 0) {
> @@ -1562,44 +1557,19 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
>  		if (port > last)
>  			nloop++;
>  	} while (err == -EADDRINUSE && nloop != 2);
> -	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
> -			__func__, &myaddr.sin_addr,
> -			port, err ? "failed" : "ok", err);
> -	return err;
> -}
> -
> -static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
> -{
> -	struct sockaddr_in6 myaddr = {
> -		.sin6_family = AF_INET6,
> -	};
> -	struct sockaddr_in6 *sa;
> -	int err, nloop = 0;
> -	unsigned short port = xs_get_srcport(transport);
> -	unsigned short last;
>  
> -	sa = (struct sockaddr_in6 *)&transport->srcaddr;
> -	myaddr.sin6_addr = sa->sin6_addr;
> -	do {
> -		myaddr.sin6_port = htons(port);
> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> -						sizeof(myaddr));
> -		if (port == 0)
> -			break;
> -		if (err == 0) {
> -			transport->srcport = port;
> -			break;
> -		}
> -		last = port;
> -		port = xs_next_srcport(transport, port);
> -		if (port > last)
> -			nloop++;
> -	} while (err == -EADDRINUSE && nloop != 2);
> -	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
> -		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
> +	if (myaddr.ss_family == PF_INET)
> +		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
> +				&((struct sockaddr_in *)&myaddr)->sin_addr,
> +				port, err ? "failed" : "ok", err);
> +	else
> +		dprintk("RPC:       %s %pI6:%u: %s (%d)\n", __func__,
> +				&((struct sockaddr_in6 *)&myaddr)->sin6_addr,
> +				port, err ? "failed" : "ok", err);
>  	return err;
>  }
>  
> +
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>  static struct lock_class_key xs_key[2];
>  static struct lock_class_key xs_slock_key[2];
> @@ -1645,7 +1615,7 @@ static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
>  	}
>  	xs_reclassify_socket4(sock);
>  
> -	if (xs_bind4(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
>  		sock_release(sock);
>  		goto out;
>  	}
> @@ -1669,7 +1639,7 @@ static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
>  	}
>  	xs_reclassify_socket6(sock);
>  
> -	if (xs_bind6(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
>  		sock_release(sock);
>  		goto out;
>  	}
> -- 
> 1.5.5.6
> 
