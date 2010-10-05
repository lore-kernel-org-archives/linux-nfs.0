Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:30184 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab0JEDVc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Oct 2010 23:21:32 -0400
Subject: Re: [PATCH 9/13] sunrpc: Merge the xs_bind code
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA9CEE8.9050404@parallels.com>
Date: Mon, 4 Oct 2010 23:20:46 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com>
References: <4CA9CDA8.4010407@parallels.com> <4CA9CEE8.9050404@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 4, 2010, at 8:56 AM, Pavel Emelyanov wrote:

> There's the only difference betseen the xs_bind4 and the
> xs_bind6 - the size of sockaddr structure they use.
> 
> Fortunately its size can be indirectly get from transport and
> the port in question resides on the same offset within the
> v4 and the v6 sockaddrs.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
> net/sunrpc/xprtsock.c |   65 +++++++++++++-----------------------------------
> 1 files changed, 18 insertions(+), 47 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7fdf2bb..3618cfd 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1534,23 +1534,19 @@ static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned shor
> 		return xprt_max_resvport;
> 	return --port;
> }
> -
> -static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
> {
> -	struct sockaddr_in myaddr = {
> -		.sin_family = AF_INET,
> -	};
> -	struct sockaddr_in *sa;
> +	struct sockaddr myaddr;

You want "struct sockaddr_storage" here.  A "struct sockaddr" is required by standard (iirc) to be only as large as a "struct sockaddr_in".  So this can't possibly hold an IPv6 socket address without overflowing.

> 	int err, nloop = 0;
> 	unsigned short port = xs_get_srcport(transport);
> 	unsigned short last;
> 
> -	sa = (struct sockaddr_in *)&transport->srcaddr;
> -	myaddr.sin_addr = sa->sin_addr;
> +	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
> 	do {
> -		myaddr.sin_port = htons(port);
> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> -						sizeof(myaddr));
> +		BUILD_BUG_ON(offsetof(struct sockaddr_in, sin_port) !=
> +				offsetof(struct sockaddr_in6, sin6_port));
> +		((struct sockaddr_in *)&myaddr)->sin_port = htons(port);

This series of patches looks mostly OK at first blush, but this little change is a bit offensive.  :-)

There should be some static inline helper functions that can get and set the port number in a socket address without a lot of magic, and I would prefer you use those instead.  (I would point you directly to them, but I can't easily access kernel source at the moment -- hotel internet sucks).

There should be one or two code examples in the RPC module or in headers that set and get ports in an automatic struct sockaddr_storage variable to give you an idea of what this needs to look like to avoid stack overruns and bad pointer aliasing.

> +		err = kernel_bind(sock, &myaddr, transport->xprt.addrlen);
> 		if (port == 0)
> 			break;
> 		if (err == 0) {
> @@ -1562,44 +1558,19 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> 		if (port > last)
> 			nloop++;
> 	} while (err == -EADDRINUSE && nloop != 2);
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
> +	if (myaddr.sa_family == PF_INET)
> +		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
> +				&((struct sockaddr_in *)&myaddr)->sin_addr,
> +				port, err ? "failed" : "ok", err);
> +	else
> +		dprintk("RPC:       %s %pI6:%u: %s (%d)\n", __func__,
> +				&((struct sockaddr_in6 *)&myaddr)->sin6_addr,
> +				port, err ? "failed" : "ok", err);
> 	return err;
> }
> 
> +
> #ifdef CONFIG_DEBUG_LOCK_ALLOC
> static struct lock_class_key xs_key[2];
> static struct lock_class_key xs_slock_key[2];
> @@ -1645,7 +1616,7 @@ static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
> 	}
> 	xs_reclassify_socket4(sock);
> 
> -	if (xs_bind4(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
> 		sock_release(sock);
> 		goto out;
> 	}
> @@ -1669,7 +1640,7 @@ static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
> 	}
> 	xs_reclassify_socket6(sock);
> 
> -	if (xs_bind6(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
> 		sock_release(sock);
> 		goto out;
> 	}
> -- 
> 1.5.5.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



