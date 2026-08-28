Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9C833B894B
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 18:37:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787942278; cv=none; b=ApUjNjy2DMLygtowyvJB9NeAXUd/KMA24N64cxKo2dJTF7F0wX9mK9TRSftX/scjYN7RWSxAUl4AAf0OP172iFeGST/gMjSUk37tKV1vx19GnKwyf3L12ic7krOBbZOEc7BxEenz64X5zCKjQIYtWwhMrz17HvGkaLTglpmC9t0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787942278; c=relaxed/simple;
	bh=h8YHEawLJvzd7vWgkgzoZTzOynn28fLfzyKzJbKGp5c=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=UIA+dTNlg4AZT8uNeRpc537TSg7j/awTASDlkE4CDXS8XAzrLO491Sa/EW4m4FTn1i5mvWv5FY2IO92VbG3K8rQjhNg3Wxwq7J7A7PYVDkJapvWpyZ+YiI/8hVlkbtuGKJvpb1RYoeT7NSXeNHXnSaKY0HTa4IjoI/okshyXwFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NSeTwgjt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NSeTwgjt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E2C881F000E9;
	Fri, 28 Aug 2026 18:37:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787942276;
	bh=ND2XHLRYjBYiZ+bSHhOLltAMSywv7k80GK7CnHhpP7Y=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=NSeTwgjtFHTvsHL0nbNtLz/FBFQs0L7kaKWwNVFclasC2qWkk7Nh4BB1QRD9oNDYJ
	 4gTOwiZ2bfMYOOMmPGt3aRi10sDOCcgKwyy0V4nC/R/GzhYOKNhXjaw9H7UIS7ZIZP
	 Qii9nqkO/HKwoMXyInv+2r1OkVvKP1Os6LgP65uSLsE7jVAZOU1ReWklwP+xZ5sqaG
	 C1SCG/JevMURj5q3PR1Sy7Un+WATzdnenvAaTRFN3tRtCClTSI/9PHbzCe/OMU7u1J
	 gqsX9SW9Oua5XBhKwaJH165jmwsxyH+QM+hbYLORpbHoUkE+62e/qgWW9LthNyHZSO
	 n8bU7XtPqoV7w==
Message-ID: <45e98e76b1739b5440f2250a20c922eb0d1bca23.camel@kernel.org>
Subject: Re: [PATCH v2 1/7] SUNRPC: Assign a unique identifier to each
 svc_xprt
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Date: Fri, 28 Aug 2026 14:37:54 -0400
In-Reply-To: <20260828-duplicate-reply-cache-v2-1-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
	 <20260828-duplicate-reply-cache-v2-1-25069e660a7b@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Fri, 2026-08-28 at 12:17 -0400, Chuck Lever wrote:
> A consumer that associates state with a transport without holding a
> reference cannot detect ABA collisions: once a transport is freed,
> SLUB may hand out a new svc_xprt at the same address.
>=20
> Allocate a per-netns identifier for each transport in svc_xprt_init()
> from a cyclic IDR, which delays reuse of an identifier after its
> transport is freed. svc_xprt_init() now returns a boolean, and its
> callers unwind when allocation fails. The NFSD duplicate reply cache
> is the first consumer.
>
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  include/linux/sunrpc/svc_xprt.h          |  3 +-
>  include/trace/events/sunrpc.h            |  8 ++++--
>  net/sunrpc/netns.h                       |  4 +++
>  net/sunrpc/sunrpc_syms.c                 |  3 ++
>  net/sunrpc/svc_xprt.c                    | 47 ++++++++++++++++++++++++++=
++----
>  net/sunrpc/svcsock.c                     | 40 +++++++++++++++++++-------=
-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  5 +++-
>  7 files changed, 89 insertions(+), 21 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_x=
prt.h
> index da2a2531e110..88d73da5f46f 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -53,6 +53,7 @@ struct svc_xprt {
>  	struct svc_xprt_class	*xpt_class;
>  	const struct svc_xprt_ops *xpt_ops;
>  	struct kref		xpt_ref;
> +	unsigned int		xpt_id;
>  	ktime_t			xpt_qtime;
>  	struct list_head	xpt_list;
>  	struct lwq_node		xpt_ready;
> @@ -159,7 +160,7 @@ static inline bool svc_xprt_is_dead(const struct svc_=
xprt *xprt)
> =20
>  int	svc_reg_xprt_class(struct svc_xprt_class *);
>  void	svc_unreg_xprt_class(struct svc_xprt_class *);
> -void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xpr=
t *,
> +bool	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xpr=
t *,
>  		      struct svc_serv *);
>  int	svc_xprt_create_from_sa(struct svc_serv *serv, const char *xprt_name=
,
>  				struct net *net, struct sockaddr *sap,
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.=
h
> index ff855197880d..180346e520ff 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -1986,7 +1986,8 @@ TRACE_EVENT(svc_xprt_create_err,
>  		__sockaddr(server, (x)->xpt_locallen) \
>  		__sockaddr(client, (x)->xpt_remotelen) \
>  		__field(unsigned long, flags) \
> -		__field(unsigned int, netns_ino)
> +		__field(unsigned int, netns_ino) \
> +		__field(unsigned int, xpt_id)
> =20
>  #define SVC_XPRT_ENDPOINT_ASSIGNMENTS(x) \
>  		do { \
> @@ -1996,13 +1997,15 @@ TRACE_EVENT(svc_xprt_create_err,
>  					  (x)->xpt_remotelen); \
>  			__entry->flags =3D (x)->xpt_flags; \
>  			__entry->netns_ino =3D (x)->xpt_net->ns.inum; \
> +			__entry->xpt_id =3D (x)->xpt_id; \
>  		} while (0)
> =20
>  #define SVC_XPRT_ENDPOINT_FORMAT \
> -		"server=3D%pISpc client=3D%pISpc flags=3D%s"
> +		"server=3D%pISpc client=3D%pISpc xpt_id=3D%u flags=3D%s"
> =20
>  #define SVC_XPRT_ENDPOINT_VARARGS \
>  		__get_sockaddr(server), __get_sockaddr(client), \
> +		__entry->xpt_id, \
>  		show_svc_xprt_flags(__entry->flags)
> =20
>  TRACE_EVENT(svc_xprt_enqueue,
> @@ -2024,6 +2027,7 @@ TRACE_EVENT(svc_xprt_enqueue,
>  				  xprt->xpt_remotelen);
>  		__entry->flags =3D flags;
>  		__entry->netns_ino =3D xprt->xpt_net->ns.inum;
> +		__entry->xpt_id =3D xprt->xpt_id;
>  	),
> =20
>  	TP_printk(SVC_XPRT_ENDPOINT_FORMAT, SVC_XPRT_ENDPOINT_VARARGS)
> diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
> index 4efb5f28d881..53432d759ae8 100644
> --- a/net/sunrpc/netns.h
> +++ b/net/sunrpc/netns.h
> @@ -2,6 +2,7 @@
>  #ifndef __SUNRPC_NETNS_H__
>  #define __SUNRPC_NETNS_H__
> =20
> +#include <linux/idr.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> =20
> @@ -34,6 +35,9 @@ struct sunrpc_net {
>  	atomic_t pipe_users;
>  	struct proc_dir_entry *use_gssp_proc;
>  	struct proc_dir_entry *gss_krb5_enctypes;
> +
> +	struct idr	svc_xprt_ids;
> +	spinlock_t	svc_xprt_ids_lock;
>  };
> =20
>  extern unsigned int sunrpc_net_id;
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index 1a3884a0376a..d9ddf5b716cc 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -58,6 +58,8 @@ static __net_init int sunrpc_init_net(struct net *net)
>  	spin_lock_init(&sn->rpc_client_lock);
>  	spin_lock_init(&sn->rpcb_clnt_lock);
>  	mutex_init(&sn->gssp_lock);
> +	idr_init(&sn->svc_xprt_ids);
> +	spin_lock_init(&sn->svc_xprt_ids_lock);
>  	return 0;
> =20
>  err_pipefs:
> @@ -74,6 +76,7 @@ static __net_exit void sunrpc_exit_net(struct net *net)
>  {
>  	struct sunrpc_net *sn =3D net_generic(net, sunrpc_net_id);
> =20
> +	idr_destroy(&sn->svc_xprt_ids);
>  	rpc_pipefs_exit_net(net);
>  	unix_gid_cache_destroy(net);
>  	ip_map_cache_destroy(net);
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 40040af588fb..ca10ef965443 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -21,6 +21,8 @@
>  #include <linux/netdevice.h>
>  #include <trace/events/sunrpc.h>
> =20
> +#include "netns.h"
> +
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
> =20
>  static unsigned int svc_rpc_per_connection_limit __read_mostly;
> @@ -167,7 +169,12 @@ static void svc_xprt_free(struct kref *kref)
>  {
>  	struct svc_xprt *xprt =3D
>  		container_of(kref, struct svc_xprt, xpt_ref);
> +	struct sunrpc_net *sn =3D net_generic(xprt->xpt_net, sunrpc_net_id);
>  	struct module *owner =3D xprt->xpt_class->xcl_owner;
> +
> +	spin_lock(&sn->svc_xprt_ids_lock);
> +	idr_remove(&sn->svc_xprt_ids, xprt->xpt_id);
> +	spin_unlock(&sn->svc_xprt_ids_lock);
>  	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
>  		svcauth_unix_info_release(xprt);
>  	put_cred(xprt->xpt_cred);
> @@ -188,13 +195,31 @@ void svc_xprt_put(struct svc_xprt *xprt)
>  }
>  EXPORT_SYMBOL_GPL(svc_xprt_put);
> =20
> -/*
> - * Called by transport drivers to initialize the transport independent
> - * portion of the transport instance.
> +/**
> + * svc_xprt_init - initialize transport-independent portion of a transpo=
rt
> + * @net: network namespace in which the transport operates
> + * @xcl: transport class providing operations and metadata
> + * @xprt: svc_xprt to initialize
> + * @serv: RPC service that owns this transport
> + *
> + * Assigns @xprt->xpt_id, unique among the transports live in @net. The
> + * value is reused once @xprt is freed.
> + *
> + * On failure, the caller has only to free @xprt's containing structure.
> + *
> + * Context: Process context. May sleep. Takes and releases the
> + *          per-net svc_xprt_ids_lock.
> + *
> + * Return:
> + *   %true: initialization succeeded
> + *   %false: initialization failed
>   */
> -void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
> +bool svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
>  		   struct svc_xprt *xprt, struct svc_serv *serv)
>  {
> +	struct sunrpc_net *sn =3D net_generic(net, sunrpc_net_id);
> +	int id;
> +
>  	memset(xprt, 0, sizeof(*xprt));
>  	xprt->xpt_class =3D xcl;
>  	xprt->xpt_ops =3D xcl->xcl_ops;
> @@ -206,8 +231,20 @@ void svc_xprt_init(struct net *net, struct svc_xprt_=
class *xcl,
>  	mutex_init(&xprt->xpt_mutex);
>  	spin_lock_init(&xprt->xpt_lock);
>  	set_bit(XPT_BUSY, &xprt->xpt_flags);
> -	xprt->xpt_net =3D get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
> +	xprt->xpt_net =3D get_net_track(net, &xprt->ns_tracker, GFP_KERNEL);
>  	strcpy(xprt->xpt_remotebuf, "uninitialized");
> +
> +	idr_preload(GFP_KERNEL);
> +	spin_lock(&sn->svc_xprt_ids_lock);
> +	id =3D idr_alloc_cyclic(&sn->svc_xprt_ids, xprt, 1, 0, GFP_NOWAIT);
> +	spin_unlock(&sn->svc_xprt_ids_lock);
> +	idr_preload_end();
> +	if (id < 0) {
> +		put_net_track(xprt->xpt_net, &xprt->ns_tracker);
> +		return false;
> +	}
> +	xprt->xpt_id =3D id;
> +	return true;
>  }
>  EXPORT_SYMBOL_GPL(svc_xprt_init);
> =20
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index ef7ac080fcd3..840bec53e1ee 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -802,10 +802,11 @@ static struct svc_xprt_class svc_udp_class =3D {
>  	.xcl_ident =3D XPRT_TRANSPORT_UDP,
>  };
> =20
> -static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
> +static bool svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
>  {
> -	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_udp_class,
> -		      &svsk->sk_xprt, serv);
> +	if (!svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_udp_class,
> +			   &svsk->sk_xprt, serv))
> +		return false;
>  	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
>  	svsk->sk_sk->sk_data_ready =3D svc_data_ready;
>  	svsk->sk_sk->sk_write_space =3D svc_write_space;
> @@ -832,6 +833,7 @@ static void svc_udp_init(struct svc_sock *svsk, struc=
t svc_serv *serv)
>  	default:
>  		BUG();
>  	}
> +	return true;
>  }
> =20
>  /*
> @@ -1475,12 +1477,13 @@ void svc_cleanup_xprt_sock(void)
>  	svc_unreg_xprt_class(&svc_udp_class);
>  }
> =20
> -static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
> +static bool svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>  {
>  	struct sock	*sk =3D svsk->sk_sk;
> =20
> -	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
> -		      &svsk->sk_xprt, serv);
> +	if (!svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
> +			   &svsk->sk_xprt, serv))
> +		return false;
>  	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
>  	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>  	if (sk->sk_state =3D=3D TCP_LISTEN) {
> @@ -1511,6 +1514,7 @@ static void svc_tcp_init(struct svc_sock *svsk, str=
uct svc_serv *serv)
>  			svc_xprt_deferred_close(&svsk->sk_xprt);
>  		}
>  	}
> +	return true;
>  }
> =20
>  void svc_sock_update_bufs(struct svc_serv *serv)
> @@ -1553,6 +1557,7 @@ static struct svc_sock *svc_setup_socket(struct svc=
_serv *serv,
>  	int		pmap_register =3D !(flags & SVC_SOCK_ANONYMOUS);
>  	int		sendpages;
>  	unsigned long	pages;
> +	int		err;

Why move this variable to the outer scope? ^^^

> =20
>  	sendpages =3D svc_sock_sendpages(serv, sock, flags);
>  	if (sendpages < 0)
> @@ -1576,8 +1581,6 @@ static struct svc_sock *svc_setup_socket(struct svc=
_serv *serv,
>  	inet =3D sock->sk;
> =20
>  	if (pmap_register) {
> -		int err;
> -
>  		err =3D svc_register(serv, sock_net(sock->sk), inet->sk_family,
>  				     inet->sk_protocol,
>  				     ntohs(inet_sk(inet)->inet_sport));
> @@ -1602,13 +1605,26 @@ static struct svc_sock *svc_setup_socket(struct s=
vc_serv *serv,
>  	inet->sk_user_data =3D svsk;
> =20
>  	/* Initialize the socket */
> -	if (sock->type =3D=3D SOCK_DGRAM)
> -		svc_udp_init(svsk, serv);
> -	else
> -		svc_tcp_init(svsk, serv);
> +	if (sock->type =3D=3D SOCK_DGRAM) {
> +		if (!svc_udp_init(svsk, serv))
> +			goto out_free;
> +	} else {
> +		if (!svc_tcp_init(svsk, serv))
> +			goto out_free;
> +	}
> =20
>  	trace_svcsock_new(svsk, sock);
>  	return svsk;
> +
> +out_free:
> +	/* Port zero asks rpcbind to UNSET the registration made above. */
> +	if (pmap_register)
> +		svc_register(serv, sock_net(sock->sk), inet->sk_family,
> +			     inet->sk_protocol, 0);
> +	inet->sk_user_data =3D NULL;
> +	kfree(svsk->sk_bvec);
> +	kfree(svsk);
> +	return ERR_PTR(-ENOMEM);
>  }
> =20
>  /**
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrd=
ma/svc_rdma_transport.c
> index 093371f9d245..fabdfd891a41 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -189,7 +189,10 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(str=
uct svc_serv *serv,
>  	if (!cma_xprt)
>  		return NULL;
> =20
> -	svc_xprt_init(net, &svc_rdma_class, &cma_xprt->sc_xprt, serv);
> +	if (!svc_xprt_init(net, &svc_rdma_class, &cma_xprt->sc_xprt, serv)) {
> +		kfree(cma_xprt);
> +		return NULL;
> +	}
>  	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
>  	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
>  	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);

--=20
Jeff Layton <jlayton@kernel.org>
