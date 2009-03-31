From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/17] SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listenersockets
Date: Tue, 31 Mar 2009 11:32:58 -0400
Message-ID: <55ECFF39-DA4F-48D5-A0B9-0B37BC53EA02@oracle.com>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net> <20090303223254.2933.70364.stgit@ingres.1015granger.net> <1238451467.23512.11.camel@heimdal.trondhjem.org> <12FE2DFB-2575-4F63-A4E1-69789C34587A@oracle.com> <1238452665.23512.13.camel@heimdal.trondhjem.org> <1238501960.31172.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:65450 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957AbZCaPdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 11:33:40 -0400
In-Reply-To: <1238501960.31172.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 31, 2009, at 8:19 AM, Trond Myklebust wrote:
> On Mon, 2009-03-30 at 18:37 -0400, Trond Myklebust wrote:
>> I'm testing a fix right now...
>
> Here is the patch that was tested. With it applied, I see the  
> listeners
> come up correctly, and locking appears to work as expected.
>
> Cheers
>  Trond
>
> --------------------------------------------------------------------
>> From e13a5357ab5961844e64ec4ade6e4e13bfc33355 Mon Sep 17 00:00:00  
>> 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 30 Mar 2009 18:59:17 -0400
> Subject: [PATCH] SUNRPC: Ensure IPV6_V6ONLY is set on the socket  
> before binding to a port
>
> Also ensure that we use the protocol family instead of the address
> family when calling sock_create_kern().
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

> ---
> net/sunrpc/svcsock.c |   36 ++++++++++++++++++++++++------------
> 1 files changed, 24 insertions(+), 12 deletions(-)
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index ac6cd65..9d50423 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1110,7 +1110,6 @@ static struct svc_sock  
> *svc_setup_socket(struct svc_serv *serv,
> 	struct svc_sock	*svsk;
> 	struct sock	*inet;
> 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
> -	int		val;
>
> 	dprintk("svc: svc_setup_socket %p\n", sock);
> 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
> @@ -1143,16 +1142,6 @@ static struct svc_sock  
> *svc_setup_socket(struct svc_serv *serv,
> 	else
> 		svc_tcp_init(svsk, serv);
>
> -	/*
> -	 * If this is a PF_INET6 listener, we want to avoid
> -	 * getting requests from IPv4 remotes.  Those should
> -	 * be shunted to a PF_INET listener via rpcbind.
> -	 */
> -	val = 1;
> -	if (inet->sk_family == PF_INET6)
> -		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
> -					(char *)&val, sizeof(val));
> -
> 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
> 				svsk, svsk->sk_sk);
>
> @@ -1220,6 +1209,8 @@ static struct svc_xprt  
> *svc_create_socket(struct svc_serv *serv,
> 	struct sockaddr_storage addr;
> 	struct sockaddr *newsin = (struct sockaddr *)&addr;
> 	int		newlen;
> +	int		family;
> +	int		val;
> 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
>
> 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
> @@ -1231,14 +1222,35 @@ static struct svc_xprt  
> *svc_create_socket(struct svc_serv *serv,
> 				"sockets supported\n");
> 		return ERR_PTR(-EINVAL);
> 	}
> +
> 	type = (protocol == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
> +	switch (sin->sa_family) {
> +	case AF_INET6:
> +		family = PF_INET6;
> +		break;
> +	case AF_INET:
> +		family = PF_INET;
> +		break;
> +	default:
> +		return ERR_PTR(-EINVAL);
> +	}
>
> -	error = sock_create_kern(sin->sa_family, type, protocol, &sock);
> +	error = sock_create_kern(family, type, protocol, &sock);
> 	if (error < 0)
> 		return ERR_PTR(error);
>
> 	svc_reclassify_socket(sock);
>
> +	/*
> +	 * If this is an PF_INET6 listener, we want to avoid
> +	 * getting requests from IPv4 remotes.  Those should
> +	 * be shunted to a PF_INET listener via rpcbind.
> +	 */
> +	val = 1;
> +	if (family == PF_INET6)
> +		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
> +					(char *)&val, sizeof(val));
> +
> 	if (type == SOCK_STREAM)
> 		sock->sk->sk_reuse = 1;		/* allow address reuse */
> 	error = kernel_bind(sock, sin, len);
> -- 
> 1.6.0.4
>
>
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
