Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:34931 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471Ab0JRWh3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 18:37:29 -0400
Subject: Re: [PATCH v2 9/13] sunrpc: Merge the xs_bind code
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101018215758.GH4740@fieldses.org>
Date: Mon, 18 Oct 2010 18:37:01 -0400
Cc: Pavel Emelyanov <xemul@parallels.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C254B855-0C70-4989-8559-143EB388D2EA@oracle.com>
References: <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com> <4CAABAAB.8040608@parallels.com> <4CAB11A4.7000306@parallels.com> <20101015160545.GB12268@fieldses.org> <9D130D08-1FD3-4088-AB43-8CEFFE6476B3@oracle.com> <20101015180852.GC18869@fieldses.org> <068F3C9A-2930-46F7-AC15-EB71ADA1933F@oracle.com> <20101018211537.GC4740@fieldses.org> <20101018214305.GE4740@fieldses.org> <4480316F-74A4-4157-B685-056FD958890E@oracle.com> <20101018215758.GH4740@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 18, 2010, at 5:57 PM, J. Bruce Fields wrote:

> On Mon, Oct 18, 2010 at 05:53:45PM -0400, Chuck Lever wrote:
>> Can you post the full revised patch?  I'm wondering if it's OK to init the sockaddr's family that way, but I can't tell from just the snippet.
> 
> I end up modifying these two patches (then the change propagates through
> the others without conflicts).
> 
> --b.
> 
> commit c923f8c579bd65e4d4096cdcc1ca2b17780143ce
> Author: Pavel Emelyanov <xemul@parallels.com>
> Date:   Tue Oct 5 15:53:08 2010 +0400
> 
>    sunrpc: Merge the xs_bind code
> 
>    There's the only difference betseen the xs_bind4 and the
>    xs_bind6 - the size of sockaddr structure they use.
> 
>    Fortunatelly its size can be indirectly get from the transport.
> 
>    Change since v1:
>    * use sockaddr_storage instead of sockaddr
>    * use rpc_set_port instead of manual port assigning
> 
>    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>    [bfields@redhat.com: fix address family initialization]
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7fdf2bb..fc1e767 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1534,23 +1534,18 @@ static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned shor
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
> +	struct sockaddr_storage myaddr;
> 	int err, nloop = 0;
> 	unsigned short port = xs_get_srcport(transport);
> 	unsigned short last;
> 
> -	sa = (struct sockaddr_in *)&transport->srcaddr;
> -	myaddr.sin_addr = sa->sin_addr;
> +	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);

This routine used to construct my_addr by hand in automatic storage by copying just the address part from srcaddr.  Since there was a separate xs_bind for IPv4 and one for IPv6, we already had the source address family planted in my_addr.

Now we're copying the full source address, including sa_family, from the passed in srcaddr.  But most ULPs don't actually set up srcaddr.  In fact, I think only lockd does.

The calling convention for rpc_create() allows this.  Notice in xs_setup_xprt() the source address is copied only if the args->srcaddr pointer is not NULL.  If it _is_ NULL, then the sock_xprt's srcaddr field should be filled with all zeros (which is the ANYADDR in both IPv4 and IPv6) because we allocate the new sock_xprt structure via kzalloc().  But the sa_family field is left zero as well in this case.

This is where the actual bug is, I think.  When srcaddr is NULL, instead of leaving that srcaddr field uninitialized in xs_setup_xprt(), it should plant an appropriate ANYADDR address there.  The family of that ANYADDR address is determined by the family of dstaddr, which is always initialized before this function is called.  I can send you a simple example patch that might apply before Pavel's work, if you like.

In the current code, the fact that ANYADDR just happens to be all zeroes saved our ass on this one.

> 	do {
> -		myaddr.sin_port = htons(port);
> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> -						sizeof(myaddr));
> +		rpc_set_port((struct sockaddr *)&myaddr, port);
> +		err = kernel_bind(sock, (struct sockaddr *)&myaddr,
> +				transport->xprt.addrlen);
> 		if (port == 0)
> 			break;
> 		if (err == 0) {
> @@ -1562,44 +1557,19 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
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
> +	if (myaddr.ss_family == PF_INET)
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
> @@ -1643,9 +1613,10 @@ static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
> 				protocol, -err);
> 		goto out;
> 	}
> +	transport->srcaddr.ss_family = AF_INET;
> 	xs_reclassify_socket4(sock);
> 
> -	if (xs_bind4(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
> 		sock_release(sock);
> 		goto out;
> 	}
> @@ -1667,9 +1638,10 @@ static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
> 				protocol, -err);
> 		goto out;
> 	}
> +	transport->srcaddr.ss_family = AF_INET6;
> 	xs_reclassify_socket6(sock);
> 
> -	if (xs_bind6(transport, sock)) {
> +	if (xs_bind(transport, sock)) {
> 		sock_release(sock);
> 		goto out;
> 	}
> commit fa8045a09755f64f8a74c7a8f5046da9d632d4c5
> Author: Pavel Emelyanov <xemul@parallels.com>
> Date:   Mon Oct 4 16:56:38 2010 +0400
> 
>    sunrpc: Merge xs_create_sock code
> 
>    After xs_bind is merged it's easy to merge its callers.
> 
>    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>    [bfields@redhat.com: fix address family initialization]
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index fc1e767..324d97a 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1591,6 +1591,14 @@ static inline void xs_reclassify_socket6(struct socket *sock)
> 	sock_lock_init_class_and_name(sk, "slock-AF_INET6-RPC",
> 		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
> }
> +
> +static inline void xs_reclassify_socket(int family, struct socket *sock)
> +{
> +	if (family == PF_INET)
> +		xs_reclassify_socket4(sock);
> +	else
> +		xs_reclassify_socket6(sock);


Just noticed: This should be a switch, just like this type of logic is everywhere else in this code.



> +}
> #else
> static inline void xs_reclassify_socket4(struct socket *sock)
> {
> @@ -1599,22 +1607,26 @@ static inline void xs_reclassify_socket4(struct socket *sock)
> static inline void xs_reclassify_socket6(struct socket *sock)
> {
> }
> +
> +static inline void xs_reclassify_socket(int family, struct socket *sock)
> +{
> +}
> #endif
> 
> -static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
> -		struct sock_xprt *transport, int type, int protocol)
> +static struct socket *xs_create_sock(struct rpc_xprt *xprt,
> +		struct sock_xprt *transport, int family, int type, int protocol)
> {
> 	struct socket *sock;
> 	int err;
> 
> -	err = __sock_create(xprt->xprt_net, PF_INET, type, protocol, &sock, 1);
> +	err = __sock_create(xprt->xprt_net, family, type, protocol, &sock, 1);
> 	if (err < 0) {
> 		dprintk("RPC:       can't create %d transport socket (%d).\n",
> 				protocol, -err);
> 		goto out;
> 	}
> -	transport->srcaddr.ss_family = AF_INET;
> -	xs_reclassify_socket4(sock);
> +	transport->srcaddr.ss_family = family;
> +	xs_reclassify_socket(family, sock);


See above.  I think this just covers up the problem, and the real fix is in xs_setup_xprt().



> 	if (xs_bind(transport, sock)) {
> 		sock_release(sock);
> @@ -1626,29 +1638,16 @@ out:
> 	return ERR_PTR(err);
> }
> 
> -static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
> +static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
> 		struct sock_xprt *transport, int type, int protocol)
> {
> -	struct socket *sock;
> -	int err;
> -
> -	err = __sock_create(xprt->xprt_net, PF_INET6, type, protocol, &sock, 1);
> -	if (err < 0) {
> -		dprintk("RPC:       can't create %d transport socket (%d).\n",
> -				protocol, -err);
> -		goto out;
> -	}
> -	transport->srcaddr.ss_family = AF_INET6;
> -	xs_reclassify_socket6(sock);
> -
> -	if (xs_bind(transport, sock)) {
> -		sock_release(sock);
> -		goto out;
> -	}
> +	return xs_create_sock(xprt, transport, PF_INET, type, protocol);
> +}
> 
> -	return sock;
> -out:
> -	return ERR_PTR(err);
> +static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
> +		struct sock_xprt *transport, int type, int protocol)
> +{
> +	return xs_create_sock(xprt, transport, PF_INET6, type, protocol);
> }
> 
> static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)

-- 
chuck[dot]lever[at]oracle[dot]com




