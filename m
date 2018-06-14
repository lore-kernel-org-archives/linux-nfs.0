Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:33734 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754616AbeFNRTX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jun 2018 13:19:23 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH] SUNRPC: Move inline xprt_alloc_xid() up to fix compiler
 warning
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1528891298-26694-1-git-send-email-geert@linux-m68k.org>
Date: Thu, 14 Jun 2018 13:19:07 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <675726D3-9273-4051-B38F-6377B8445A27@oracle.com>
References: <1528891298-26694-1-git-send-email-geert@linux-m68k.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 13, 2018, at 8:01 AM, Geert Uytterhoeven <geert@linux-m68k.org> =
wrote:
>=20
> With gcc 4.1.2:
>=20
>    net/sunrpc/xprt.c:69: warning: =E2=80=98xprt_alloc_xid=E2=80=99 =
declared inline after being called
>    net/sunrpc/xprt.c:69: warning: previous declaration of =
=E2=80=98xprt_alloc_xid=E2=80=99 was here
>=20
> To fix this, move the function up, before its caller, and remove the =
no
> longer needed forward declaration.
>=20
> Fixes: 37ac86c3a76c1136 ("SUNRPC: Initialize rpc_rqst outside of =
xprt->reserve_lock")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> net/sunrpc/xprt.c | 11 +++++------
> 1 file changed, 5 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3c85af058227d14b..60a8b9f91cf94b54 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -66,7 +66,6 @@
>  * Local functions
>  */
> static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
> -static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
> static void	xprt_connect_status(struct rpc_task *task);
> static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
> static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
> @@ -956,6 +955,11 @@ static void xprt_timer(struct rpc_task *task)
> 		task->tk_status =3D 0;
> }
>=20
> +static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
> +{
> +	return (__force __be32)xprt->xid++;
> +}
> +
> /**
>  * xprt_prepare_transmit - reserve the transport before sending a =
request
>  * @task: RPC task about to send a request
> @@ -1296,11 +1300,6 @@ void xprt_retry_reserve(struct rpc_task *task)
> 	xprt->ops->alloc_slot(xprt, task);
> }
>=20
> -static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
> -{
> -	return (__force __be32)xprt->xid++;
> -}
> -

For code organization, we might want to keep xprt_alloc_xid
together with xprt_init_xid. Would it be better to simply
remove the "inline" directive from these two and let the
compiler choose the best optimization?


> static inline void xprt_init_xid(struct rpc_xprt *xprt)
> {
> 	xprt->xid =3D prandom_u32();
> --=20
> 2.7.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



