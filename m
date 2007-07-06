From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] SUNRPC client: add interface for binding to	a
	local address
Date: Fri, 06 Jul 2007 09:46:16 -0400
Message-ID: <1183729576.6463.29.camel@heimdal.trondhjem.org>
References: <20070705152634.GC6603@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6o8b-0006kD-E9
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:46:21 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18BuJM1RgpvT0l8yqbUg7qp0WikxAZBRkk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6o8e-0000lx-25
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:46:25 -0700
In-Reply-To: <20070705152634.GC6603@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-07-05 at 17:26 +0200, Frank van Maarseveen wrote:
> In addition to binding to a local privileged port the NFS client should
> allow binding to a specific local address. This is used by the server
> for callbacks. The patch adds the necessary interface.
> 
> Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
> ---
> 
> diff -urp a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> --- a/include/linux/sunrpc/clnt.h	2007-04-27 18:05:33.000000000 +0200
> +++ b/include/linux/sunrpc/clnt.h	2007-07-05 15:33:11.000000000 +0200
> @@ -97,6 +97,7 @@ struct rpc_create_args {
>  	int			protocol;
>  	struct sockaddr		*address;
>  	size_t			addrsize;
> +	struct sockaddr		*saddress;
>  	struct rpc_timeout	*timeout;
>  	char			*servername;
>  	struct rpc_program	*program;
> diff -urp a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> --- a/include/linux/sunrpc/xprt.h	2007-02-27 22:55:35.000000000 +0100
> +++ b/include/linux/sunrpc/xprt.h	2007-07-05 15:33:11.000000000 +0200
> @@ -201,7 +201,8 @@ void			xprt_set_timeout(struct rpc_timeo
>  /*
>   * Generic internal transport functions
>   */
> -struct rpc_xprt *	xprt_create_transport(int proto, struct sockaddr *addr, size_t size, struct rpc_timeout *toparms);
> +struct rpc_xprt *	xprt_create_transport(int proto, struct sockaddr *addr, size_t size,
> +					      struct sockaddr *saddr, struct rpc_timeout *toparms);
>  void			xprt_connect(struct rpc_task *task);
>  void			xprt_reserve(struct rpc_task *task);
>  int			xprt_reserve_xprt(struct rpc_task *task);
> @@ -239,8 +240,10 @@ void			xprt_disconnect(struct rpc_xprt *
>  /*
>   * Socket transport setup operations
>   */
> -struct rpc_xprt *	xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
> -struct rpc_xprt *	xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
> +struct rpc_xprt *	xs_setup_udp(struct sockaddr *addr, size_t addrlen,
> +				     struct sockaddr *saddr, struct rpc_timeout *to);
> +struct rpc_xprt *	xs_setup_tcp(struct sockaddr *addr, size_t addrlen,
> +				     struct sockaddr *saddr, struct rpc_timeout *to);
>  
>  /*
>   * Reserved bit positions in xprt->state
> diff -urp a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> --- a/net/sunrpc/clnt.c	2007-04-27 18:05:39.000000000 +0200
> +++ b/net/sunrpc/clnt.c	2007-07-05 15:33:11.000000000 +0200
> @@ -209,7 +209,8 @@ struct rpc_clnt *rpc_create(struct rpc_c
>  	struct rpc_clnt *clnt;
>  
>  	xprt = xprt_create_transport(args->protocol, args->address,
> -					args->addrsize, args->timeout);
> +				     args->addrsize, args->saddress,
> +				     args->timeout);
>  	if (IS_ERR(xprt))
>  		return (struct rpc_clnt *)xprt;
>  
> diff -urp a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> --- a/net/sunrpc/xprt.c	2007-04-27 18:05:39.000000000 +0200
> +++ b/net/sunrpc/xprt.c	2007-07-05 15:33:11.000000000 +0200
> @@ -893,17 +893,19 @@ void xprt_set_timeout(struct rpc_timeout
>   * @to: timeout parameters
>   *
>   */
> -struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t size, struct rpc_timeout *to)
> +struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap,
> +				       size_t size, struct sockaddr *saddr,
> +				       struct rpc_timeout *to)

Urgh... It might be time to fold all these arguments into a "struct
rpc_xprtsock_create" instead of copying them on the stack.

>  {
>  	struct rpc_xprt	*xprt;
>  	struct rpc_rqst	*req;
>  
>  	switch (proto) {
>  	case IPPROTO_UDP:
> -		xprt = xs_setup_udp(ap, size, to);
> +		xprt = xs_setup_udp(ap, size, saddr, to);
>  		break;
>  	case IPPROTO_TCP:
> -		xprt = xs_setup_tcp(ap, size, to);
> +		xprt = xs_setup_tcp(ap, size, saddr, to);
>  		break;
>  	default:
>  		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
> diff -urp a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> --- a/net/sunrpc/xprtsock.c	2007-04-27 18:05:39.000000000 +0200
> +++ b/net/sunrpc/xprtsock.c	2007-07-05 15:39:29.000000000 +0200
> @@ -235,6 +235,7 @@ struct sock_xprt {
>  	 * Connection of transports
>  	 */
>  	struct delayed_work	connect_worker;
> +	struct sockaddr_storage	saddr;
>  	unsigned short		port;
>  
>  	/*
> @@ -1146,31 +1147,33 @@ static void xs_set_port(struct rpc_xprt 
>  	sap->sin_port = htons(port);
>  }
>  
> -static int xs_bindresvport(struct sock_xprt *transport, struct socket *sock)
> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>  {
>  	struct sockaddr_in myaddr = {
>  		.sin_family = AF_INET,
>  	};
> +	struct sockaddr_in *sa;
>  	int err;
>  	unsigned short port = transport->port;

Instead of forcing two tests of transport->xprt.resvport per loop, why
not just set port to 0 in the case of !transport->xprt.resvport?

>  
> +	sa = (struct sockaddr_in *)&transport->saddr;
> +	myaddr.sin_addr = sa->sin_addr;
>  	do {
> -		myaddr.sin_port = htons(port);
> +		if (transport->xprt.resvport)
> +			myaddr.sin_port = htons(port);
>  		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
>  						sizeof(myaddr));
> -		if (err == 0) {
> +		if (err == 0 || !transport->xprt.resvport) {
>  			transport->port = port;
> -			dprintk("RPC:       xs_bindresvport bound to port %u\n",
> -					port);
> -			return 0;
> +			break;
>  		}
>  		if (port <= xprt_min_resvport)
>  			port = xprt_max_resvport;
>  		else
>  			port--;
>  	} while (err == -EADDRINUSE && port != transport->port);
> -
> -	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
> +	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %d\n",
> +		NIPQUAD(myaddr.sin_addr), port, err);

Hmm... I though you said this was IPv6 clean :-)

>  	return err;
>  }
>  
> @@ -1229,7 +1232,7 @@ static void xs_udp_connect_worker(struct
>  	}
>  	xs_reclassify_socket(sock);
>  
> -	if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
> +	if (xs_bind(transport, sock)) {
>  		sock_release(sock);
>  		goto out;
>  	}
> @@ -1316,7 +1319,7 @@ static void xs_tcp_connect_worker(struct
>  		}
>  		xs_reclassify_socket(sock);
>  
> -		if (xprt->resvport && xs_bindresvport(transport, sock) < 0) {
> +		if (xs_bind(transport, sock)) {
>  			sock_release(sock);
>  			goto out;
>  		}
> @@ -1505,7 +1508,8 @@ static struct rpc_xprt_ops xs_tcp_ops = 
>  	.print_stats		= xs_tcp_print_stats,
>  };
>  
> -static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
> +static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen,
> +				      struct sockaddr *saddr, unsigned int slot_table_size)
>  {
>  	struct rpc_xprt *xprt;
>  	struct sock_xprt *new;
> @@ -1534,6 +1538,8 @@ static struct rpc_xprt *xs_setup_xprt(st
>  
>  	memcpy(&xprt->addr, addr, addrlen);
>  	xprt->addrlen = addrlen;
> +	if (saddr)
> +		memcpy(&new->saddr, saddr, addrlen);

Is it safe to assume that the source and destination sockaddr structures
are always the same size?

>  	new->port = xs_get_random_port();
>  
>  	return xprt;
> @@ -1546,12 +1552,13 @@ static struct rpc_xprt *xs_setup_xprt(st
>   * @to:   timeout parameters
>   *
>   */
> -struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
> +struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen,
> +			      struct sockaddr *saddr, struct rpc_timeout *to)
>  {
>  	struct rpc_xprt *xprt;
>  	struct sock_xprt *transport;
>  
> -	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
> +	xprt = xs_setup_xprt(addr, addrlen, saddr, xprt_udp_slot_table_entries);
>  	if (IS_ERR(xprt))
>  		return xprt;
>  	transport = container_of(xprt, struct sock_xprt, xprt);
> @@ -1591,12 +1598,13 @@ struct rpc_xprt *xs_setup_udp(struct soc
>   * @to: timeout parameters
>   *
>   */
> -struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
> +struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen,
> +			      struct sockaddr *saddr, struct rpc_timeout *to)
>  {
>  	struct rpc_xprt *xprt;
>  	struct sock_xprt *transport;
>  
> -	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
> +	xprt = xs_setup_xprt(addr, addrlen, saddr, xprt_tcp_slot_table_entries);
>  	if (IS_ERR(xprt))
>  		return xprt;
>  	transport = container_of(xprt, struct sock_xprt, xprt);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
