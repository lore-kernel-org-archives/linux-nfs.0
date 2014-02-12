Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58365 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbaBLEGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 23:06:07 -0500
Date: Wed, 12 Feb 2014 15:05:55 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: xprt_wait_for_buffer_space changes causes a hang.
Message-ID: <20140212150555.60d6d9a7@notabene.brown>
In-Reply-To: <1392129211.5763.5.camel@leira.trondhjem.org>
References: <20140210170315.33dfc621@notabene.brown>
	<1392129211.5763.5.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aRTkJCbknvz9sD7vrGi/yBo"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aRTkJCbknvz9sD7vrGi/yBo
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Feb 2014 09:33:31 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, 2014-02-10 at 17:03 +1100, NeilBrown wrote:
> > Hi,
> >  We have a customer who reports occasional but reproducible hangs on ou=
r 3.0
> >  based kernel.
> >  I managed to deduce that=20
> >=20
> > commit a9a6b52ee1baa865283a91eb8d443ee91adfca56
> > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date:   Fri Feb 22 14:57:57 2013 -0500
> >=20
> >     SUNRPC: Don't start the retransmission timer when out of socket spa=
ce
> > =20
> > was to blame (it got into our kernel through -stable ... not sure why it
> > deserved to be in -stable). Reverting that patch fixes the problem.  Ho=
wever I
> > don't fully understand why.
> >=20
>=20
> The reason why that patch was put into stable was that the connection
> breakage triggered by the timeouts was causing nasty behaviour when
> servers (or the network) are heavily loaded. Instead of clearing the
> logjam, breaking the connection and then reconnecting would aggravate
> it, causing hangs.

Ahh, that make sense.  Thanks.


>=20
> Anyhow, does the following patch help to break the race?
> 8<------------------------------------------------------------------
> >From e4c0373be4b8deae2667a7478d34415b99924abc Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Tue, 11 Feb 2014 09:15:54 -0500
> Subject: [PATCH] SUNRPC: Fix races in xs_nospace()
>=20
> When a send failure occurs due to the socket being out of buffer space,
> we call xs_nospace() in order to have the RPC task wait until the
> socket has drained enough to make it worth while trying again.
> The current patch fixes a race in which the socket is drained before
> we get round to setting up the machinery in xs_nospace(), and which
> is reported to cause hangs.
>=20
> Link: http://lkml.kernel.org/r/20140210170315.33dfc621@notabene.brown
> Fixes: a9a6b52ee1ba (SUNRPC: Don't start the retransmission timer...)
> Reported-by: Neil Brown <neilb@suse.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprtsock.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 6497c221612c..966763d735e9 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -510,6 +510,7 @@ static int xs_nospace(struct rpc_task *task)
>  	struct rpc_rqst *req =3D task->tk_rqstp;
>  	struct rpc_xprt *xprt =3D req->rq_xprt;
>  	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, xp=
rt);
> +	struct sock *sk =3D transport->inet;
>  	int ret =3D -EAGAIN;
> =20
>  	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
> @@ -527,7 +528,7 @@ static int xs_nospace(struct rpc_task *task)
>  			 * window size
>  			 */
>  			set_bit(SOCK_NOSPACE, &transport->sock->flags);
> -			transport->inet->sk_write_pending++;
> +			sk->sk_write_pending++;
>  			/* ...and wait for more buffer space */
>  			xprt_wait_for_buffer_space(task, xs_nospace_callback);
>  		}
> @@ -537,6 +538,9 @@ static int xs_nospace(struct rpc_task *task)
>  	}
> =20
>  	spin_unlock_bh(&xprt->transport_lock);
> +
> +	/* Race breaker in case memory is freed before above code is called */
> +	sk->sk_write_space(sk);
>  	return ret;
>  }
> =20

I looks good.  I've asked if the customer is willing to test it and provided
the patch.

By the way, this bug is the first time that I've found the tasklisk - print=
ed
when you enable rpc debuging - useful.  And it was *really* useful!

There were lots of

nfsv3 WRITE a:call_reserveresult q:xprt_backlog

and a few

nfsv3 WRITE a:call_status q:xprt_sending

and one

nfsv3 WRITE a:call_transmit_status q:xprt_pending

That last one was put to sleep by xprt_wait_for_buffer_space() and
is blocking all the rest.


Now I've got another bug with vaguely similar symptoms and only

9bfb000   (null)        0 ffffffffa03aa0a0 nfsv3 READ a:call_reserveresult =
q:xprt_sending
9bfb000   (null)        0 ffffffffa03aa0a0 nfsv3 READ a:call_reserveresult =
q:xprt_sending
a933000   (null)        0 ffffffffa03084e0 nfsv3 ACCESS a:call_reserveresul=
t q:xprt_sending

I suspect it is a different bug.  Maybe some missing backports or something,
though we have 961a828df64979d2a which is related code.

Thanks,
NeilBrown

--Sig_/aRTkJCbknvz9sD7vrGi/yBo
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvrzIznsnt1WYoG5AQI4sw//TviZccU5qiKzgNKOAhnJlCvEDlQbt0np
KhznjmpU+xh8ovtafSVka5z7bfIzcLlLzLPPRWEphUw5HEBOUDYlyZq1VBNOqZv/
T/d/GGc1MHhW3H0xBgMGUDOcYDYD1jhp00tKD0oPu2UoD3RWgjl09udEPauA1Tcm
PXAucY3zl8w5WsVpbhZkRhNSpCaDO+k8VVDMEimWjtJwUDJFYvw6MJp6IYnMdozx
1J8bgw4oC48iiVRdY6KiS9YSMNI0dy+XANcWenapiDbqTFaq1aU0fRXZhsofPlG8
8+Ur7uGNUyppfyg1JKrnFszzbQ4302QhAO9L5UeUEjy3/YeYt5m35LHT+dRDMNEe
9bSHBKgmOSvVm0OATND35Fw3fy0EF58neEdK9hEA/VKu4jVR9griIIzI42pA8Zq+
k0XH8fTIVaIv9buV6DChtyUuQXtChkFNmIAWdCSHQW6tSOw8GYJctNXiuq3FPY1k
PEo4V5yWDKbUcaMzOKt5XO9zsuwDsfDw8n/Q0BJlvIKT+Pfzo59HC9/OTmtWKwEF
1aftTI+UrUfdvNCDMZkBCGwURUnv/1cvRZd/PXHtWN6kph0oNMf8GzWiM3LHaIbI
LqCY5W/6Zz+3BeR1rc+DRMpy+jEIDxO3lfvDwfCRzPO6CbgEUtrvcnDv+e1mdk3L
53tnkFeIPRA=
=7qz9
-----END PGP SIGNATURE-----

--Sig_/aRTkJCbknvz9sD7vrGi/yBo--
