Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56767 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbaBQAS7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Feb 2014 19:18:59 -0500
Date: Mon, 17 Feb 2014 11:18:47 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: xprt_wait_for_buffer_space changes causes a hang.
Message-ID: <20140217111847.61919989@notabene.brown>
In-Reply-To: <20140212150555.60d6d9a7@notabene.brown>
References: <20140210170315.33dfc621@notabene.brown>
	<1392129211.5763.5.camel@leira.trondhjem.org>
	<20140212150555.60d6d9a7@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/2ygr/G23vo3tquHaxqqBRAt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2ygr/G23vo3tquHaxqqBRAt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Feb 2014 15:05:55 +1100 NeilBrown <neilb@suse.de> wrote:

> On Tue, 11 Feb 2014 09:33:31 -0500 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>=20
> > On Mon, 2014-02-10 at 17:03 +1100, NeilBrown wrote:
> > > Hi,
> > >  We have a customer who reports occasional but reproducible hangs on =
our 3.0
> > >  based kernel.
> > >  I managed to deduce that=20
> > >=20
> > > commit a9a6b52ee1baa865283a91eb8d443ee91adfca56
> > > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Date:   Fri Feb 22 14:57:57 2013 -0500
> > >=20
> > >     SUNRPC: Don't start the retransmission timer when out of socket s=
pace
> > > =20
> > > was to blame (it got into our kernel through -stable ... not sure why=
 it
> > > deserved to be in -stable). Reverting that patch fixes the problem.  =
However I
> > > don't fully understand why.
> > >=20
> >=20
> > The reason why that patch was put into stable was that the connection
> > breakage triggered by the timeouts was causing nasty behaviour when
> > servers (or the network) are heavily loaded. Instead of clearing the
> > logjam, breaking the connection and then reconnecting would aggravate
> > it, causing hangs.
>=20
> Ahh, that make sense.  Thanks.
>=20
>=20
> >=20
> > Anyhow, does the following patch help to break the race?
> > 8<------------------------------------------------------------------
> > >From e4c0373be4b8deae2667a7478d34415b99924abc Mon Sep 17 00:00:00 2001
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date: Tue, 11 Feb 2014 09:15:54 -0500
> > Subject: [PATCH] SUNRPC: Fix races in xs_nospace()
> >=20
> > When a send failure occurs due to the socket being out of buffer space,
> > we call xs_nospace() in order to have the RPC task wait until the
> > socket has drained enough to make it worth while trying again.
> > The current patch fixes a race in which the socket is drained before
> > we get round to setting up the machinery in xs_nospace(), and which
> > is reported to cause hangs.
> >=20
> > Link: http://lkml.kernel.org/r/20140210170315.33dfc621@notabene.brown
> > Fixes: a9a6b52ee1ba (SUNRPC: Don't start the retransmission timer...)
> > Reported-by: Neil Brown <neilb@suse.com>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  net/sunrpc/xprtsock.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 6497c221612c..966763d735e9 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -510,6 +510,7 @@ static int xs_nospace(struct rpc_task *task)
> >  	struct rpc_rqst *req =3D task->tk_rqstp;
> >  	struct rpc_xprt *xprt =3D req->rq_xprt;
> >  	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, =
xprt);
> > +	struct sock *sk =3D transport->inet;
> >  	int ret =3D -EAGAIN;
> > =20
> >  	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
> > @@ -527,7 +528,7 @@ static int xs_nospace(struct rpc_task *task)
> >  			 * window size
> >  			 */
> >  			set_bit(SOCK_NOSPACE, &transport->sock->flags);
> > -			transport->inet->sk_write_pending++;
> > +			sk->sk_write_pending++;
> >  			/* ...and wait for more buffer space */
> >  			xprt_wait_for_buffer_space(task, xs_nospace_callback);
> >  		}
> > @@ -537,6 +538,9 @@ static int xs_nospace(struct rpc_task *task)
> >  	}
> > =20
> >  	spin_unlock_bh(&xprt->transport_lock);
> > +
> > +	/* Race breaker in case memory is freed before above code is called */
> > +	sk->sk_write_space(sk);
> >  	return ret;
> >  }
> > =20
>=20
> I looks good.  I've asked if the customer is willing to test it and provi=
ded
> the patch.

Unfortunately the customer was not able to get internal approval to test th=
is
patch, as they already have a working solution.

So we might have to go with this patch without confirmation that it fixes
this particular problem.  I've examined it again and I cannot see any room
for any new races, and it should fix a credible problem.
So
  Reviewed-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

--Sig_/2ygr/G23vo3tquHaxqqBRAt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwFVZznsnt1WYoG5AQKudQ/+LlodeWuLCdNrz404U/UnKiK34E2RQLJJ
LVUFOo0jQKW06UJzuI5VFvutSeYhZoUBAqxb8Tq6N6ZTTc7KV3qd0QSqCidR4v4F
3awnb7+0P+RcNR7Uepnvfh8Cg+VuxbqG+ycmwzJpj3pBr2HbDnE7bQOlgdQLgQwW
p3R7L8WV0GLfddDelUCMXw5mGE3Cdh7tXeTG7M3Ic9TlAFVnKpxEBJyEqD0n0puY
dlzIgB/3kDHs8+2iO+Q6we7EpDPiZuZitJ78iIYCmrUEDNC56dqMUkiuqk4k1Aa+
9NeH/N86zK2PvkGAa0fnDvltSGP5nLaN/04kW0jsB7NsV9WP6GQl9cqFodLem9fw
5syR9anki5IGFh1N4S3mB2IyyJxxwbXk9ZkRbJQ2o6vr4Dsw38ppnjCH8+FyKHTx
LAoU0oInyz8rdZBcy8Y15+XW1pKCd1nYWoU7Cf/1yKD0Y7Xn2GHFBuNf/vpMdsUo
Cpc/XQUhxANgPjQm67D3IwLKw0z7SjFTAEdOCMITQ9zdtcqrmHSNJBLEnoMBzvkT
oksx8/6o5sif5f+EqYYrASCwdtDqQH7fo6Ig/g39wGtIY87gSNuMXWqzIjfSqgGK
d/NZ4BTt9mRMHrxCWzOIS4EhUjHzTnRk9Hm8zfpWnKUdRx6mKybeFcxnKkwZx0pU
LgTgoUtKv0o=
=qRDB
-----END PGP SIGNATURE-----

--Sig_/2ygr/G23vo3tquHaxqqBRAt--
