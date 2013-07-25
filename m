Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:32879 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753586Ab3GYUdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 16:33:17 -0400
Date: Fri, 26 Jul 2013 06:33:03 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to
 memory pressure.
Message-ID: <20130726063303.0d1495b3@notabene.brown>
In-Reply-To: <20130725201805.GB17962@fieldses.org>
References: <20130710022735.GI8281@fieldses.org>
	<20130710143233.77e35721@notabene.brown>
	<20130710190727.GA22305@fieldses.org>
	<20130715143203.51bc583b@notabene.brown>
	<20130716015803.GA5271@fieldses.org>
	<20130716140021.312b5b07@notabene.brown>
	<20130716142430.GA11977@fieldses.org>
	<20130718000319.GL1681@sgi.com>
	<20130724210746.GB5777@fieldses.org>
	<20130725113023.7bcbc347@notabene.brown>
	<20130725201805.GB17962@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/f4iNN=6iMiMSDHoJRoo_lFx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/f4iNN=6iMiMSDHoJRoo_lFx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 25 Jul 2013 16:18:05 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
wrote:

> On Thu, Jul 25, 2013 at 11:30:23AM +1000, NeilBrown wrote:
> >=20
> > Since we enabled auto-tuning for sunrpc TCP connections we do not
> > guarantee that there is enough write-space on each connection to
> > queue a reply.
> >=20
> > If memory pressure causes the window to shrink too small, the request
> > throttling in sunrpc/svc will not accept any requests so no more reques=
ts
> > will be handled.  Even when pressure decreases the window will not
> > grow again until data is sent on the connection.
> > This means we get a deadlock:  no requests will be handled until there
> > is more space, and no space will be allocated until a request is
> > handled.
> >=20
> > This can be simulated by modifying svc_tcp_has_wspace to inflate the
> > number of byte required and removing the 'svc_sock_setbufsize' calls
> > in svc_setup_socket.
>=20
> Ah-hah!
>=20
> > I found that multiplying by 16 was enough to make the requirement
> > exceed the default allocation.  With this modification in place:
> >    mount -o vers=3D3,proto=3Dtcp 127.0.0.1:/home /mnt
> > would block and eventually time out because the nfs server could not
> > accept any requests.
>=20
> So, this?:

Close enough.  I just put "//" in front of the lines I didn't want rather
than delete them.  But yes: exactly that effect.


>=20
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 305374d..36de50d 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1193,6 +1193,7 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
>  	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
>  		return 1;
>  	required =3D atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
> +	required *=3D 16;
>  	if (sk_stream_wspace(svsk->sk_sk) >=3D required)
>  		return 1;
>  	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> @@ -1378,14 +1379,8 @@ static struct svc_sock *svc_setup_socket(struct sv=
c_serv *serv,
>  	/* Initialize the socket */
>  	if (sock->type =3D=3D SOCK_DGRAM)
>  		svc_udp_init(svsk, serv);
> -	else {
> -		/* initialise setting must have enough space to
> -		 * receive and respond to one request.
> -		 */
> -		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
> -					4 * serv->sv_max_mesg);
> +	else
>  		svc_tcp_init(svsk, serv);
> -	}
> =20
>  	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>  				svsk, svsk->sk_sk);
>=20
> > This patch relaxes the request throttling to always allow at least one
> > request through per connection.  It does this by checking both
> >   sk_stream_min_wspace() and xprt->xpt_reserved
> > are zero.
> > The first is zero when the TCP transmit queue is empty.
> > The second is zero when there are no RPC requests being processed.
> > When both of these are zero the socket is idle and so one more
> > request can safely be allowed through.
> >=20
> > Applying this patch allows the above mount command to succeed cleanly.
> > Tracing shows that the allocated write buffer space quickly grows and
> > after a few requests are handled, the extra tests are no longer needed
> > to permit further requests to be processed.
> >=20
> > The main purpose of request throttling is to handle the case when one
> > client is slow at collecting replies and the send queue gets full of
> > replies that the client hasn't acknowledged (at the TCP level) yet.
> > As we only change behaviour when the send queue is empty this main
> > purpose is still preserved.
> >=20
> > Reported-by: Ben Myers <bpm@sgi.com>
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >=20
> > --
> > As you can see I've changed the patch.  While writing up the above=20
> > description realised there was a weakness and so added the sk_stream_mi=
n_wspace
> > test.  That allowed me to write the final paragraph.
>=20
> This is great, thanks!
>=20
> Inclined to queue it up for 3.11 and stable....

I'd agree for 3.11.
It feels a bit border-line for stable.  "dead-lock" and "has been seen in t=
he
wild" are technically enough justification...
I'd probably mark it as "pleas don't apply to -stable until 3.11 is release=
d"
or something like that, just for a bit of breathing space.
Your call though.

NeilBrown

>=20
> --b.
>=20
> >=20
> > NeilBrown
> >=20
> >=20
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 305374d..7762b9f 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1193,7 +1193,9 @@ static int svc_tcp_has_wspace(struct svc_xprt *xp=
rt)
> >  	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
> >  		return 1;
> >  	required =3D atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
> > -	if (sk_stream_wspace(svsk->sk_sk) >=3D required)
> > +	if (sk_stream_wspace(svsk->sk_sk) >=3D required ||
> > +	    (sk_stream_min_wspace(svsk->sk_sk) =3D=3D 0 &&
> > +	     atomic_read(&xprt->xpt_reserved) =3D=3D 0))
> >  		return 1;
> >  	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> >  	return 0;
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/f4iNN=6iMiMSDHoJRoo_lFx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUfGLfznsnt1WYoG5AQJtORAAjXoOuuAoDDQ2rscbbEZAQ516h+pQoI2I
zQegccJAWE1KhQ6lvX/rQUpoCpx/oi+ryOZzEPdC6Is0DJXLUxMme+5fvrSpkntO
BkqiNI3blrLA9ULU6D7bMaNIIBuYvKfqgGEwiAKZvdjQ82zB6zlwdPYhDoweh8B3
fjyMFXSoUSzQdliZx43Fql4M4svkHhNeB9h10cHULR4hxVfvKisAAOiOcfiMsbqh
7NYUjl/FcjnPGybaZkHNrB2v7LcSRr+Z8AcFv5mIaPoNfFQle3PDUst6zgnoiANs
GhzRBYyrx0a8B0DIps6Rw6SZCGmlknKRuruYMAbhj4P/Aprt6zBu9392JBpOb/FG
cELOJ5YHG5hpkfMyA6OBtAS2ftqzdDmc4bZdU5BETqL54bIN9iBz84+o8ufJKQQQ
0D13C6gyIrvkYjPcecG59qvGlntA21corFJkWveP8rLD4mtloeAGOveiZ+drXX2x
B6wgZsEycfP/aXOztJT/ME5UEMxeqDk/onlapWbb9ckW7EUuQ0EuETpULZFFsKpF
FOqnPic5QWTv4iS7YSjl4dg7oUIKs7UX4BavwS1eu9wdAArDUGMCv+iB0tQVp3f9
fDjXnVcAyQR8U+K1G4P7o2RfuGS8CTc0upA2NdfE+Zl6hCO1+zgHWVtbAxx0ZQ6N
FY+N95o6gL4=
=A6lP
-----END PGP SIGNATURE-----

--Sig_/f4iNN=6iMiMSDHoJRoo_lFx--
