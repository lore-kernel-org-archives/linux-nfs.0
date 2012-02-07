Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44069 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756370Ab2BGWjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 17:39:41 -0500
Date: Wed, 8 Feb 2012 09:39:30 +1100
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] lockd: fix arg parsing for grace_period and timeout.
Message-ID: <20120208093930.65892fbc@notabene.brown>
In-Reply-To: <20120207144956.GA4868@fieldses.org>
References: <20120207153542.3df498ad@notabene.brown>
	<1328623124.4124.5.camel@lade.trondhjem.org>
	<20120207144956.GA4868@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.IlAHuzAjWZ2VH6g0ZNwIIn"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.IlAHuzAjWZ2VH6g0ZNwIIn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 7 Feb 2012 09:49:56 -0500 "J.Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Feb 07, 2012 at 01:58:43PM +0000, Myklebust, Trond wrote:
> > On Tue, 2012-02-07 at 15:35 +1100, NeilBrown wrote:
> > > If you try to set grace_period or timeout via a module parameter
> > > to lockd, and do this on a big-endian machine where
> > >=20
> > >    sizeof(int) !=3D sizeof(unsigned long)
> > >=20
> > > it won't work.  This number given will be effectively shifted right
> > > by the difference in those two sizes.
> > >=20
> > > So cast kp->arg properly to get correct result.
> > >=20
> > > Signed-off-by: NeilBrown <neilb@suse.de>
> > >=20
> > > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > > index c061b9a..2444780 100644
> > > --- a/fs/lockd/svc.c
> > > +++ b/fs/lockd/svc.c
> > > @@ -440,7 +440,7 @@ static int param_set_##name(const char *val, stru=
ct kernel_param *kp)	\
> > >  	__typeof__(type) num =3D which_strtol(val, &endp, 0);		\
> > >  	if (endp =3D=3D val || *endp || num < (min) || num > (max))		\
> > >  		return -EINVAL;						\
> > > -	*((int *) kp->arg) =3D num;					\
> > > +	*((type *) kp->arg) =3D num;					\
> > >  	return 0;							\
> > >  }
> > > =20
> > Wow, that's a seriously old bug...
>=20
> Looking at a historical git repo, it was probably from "[PATCH] make NFS
> lockd port numbers assignable at run time", attributed to Jamie Lokier
> in August 2003, in 2.6.0.
>=20
> Anyway:
>=20
> > Bruce, do you want to carry it?
>=20
> Sure.  I'm a little slow getting stuff pushed out while I track down a
> couple very tricky bugs, but it should show up in my git tree in a few
> days....

Thanks.. just goes to show how well big-endian is tested I guess :-)
especially the more obscure options.

NeilBrown

--Sig_/.IlAHuzAjWZ2VH6g0ZNwIIn
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTzGoIjnsnt1WYoG5AQK5uQ/9FoOuunnHrETheug0e1xd4la3W7BrIK98
ERRLkLa4RPDuDRA6sNDSDwVkPjujepRmJSCzI9fV4BBmKySBzDFReJjgtSNnGkx5
CAVBDO34r/Gf7kkqYDi5IJDAvvHRJZsRq26ueYJ7j+DqUbqRVsQo7RSKw6mYx+RE
3sKkl5DnE/MCk8exybmmpS3e3jgaH9ZSSsDWFGEjC/IM0AjVut1Z0WexEFZ780HL
TrgywoFd+tJJ25dayP23HfuqFEY2TgXFfMwfUvDdjeIOaQ5AOkgBQNzdZ0ObMe7v
Yx/yNAUMR1u+xG1oiigcwWAOiE82N5cjBt0uelV38X47XhEsRTTYRLrbvzSg3QJa
oaRmJ4I3fq8fvpcvsthtBgn4k9Dh1KS1Dg8ISkD/I/pcMA4u1d3dq/5ilGL1mc80
9F44bqmjBd1juhoUzqIPL0bK/BhcTLdOL4aLvDq48P1omlNiW18dqeGDtsYB+E0F
Ny1Uul8xdGPfagsnhkMT2fh82KzCLFPIZo1dgPhh6PYE/vec1K2oLKiWKYebI140
QHuK891q2Mf+k3vzq7yE9GsKhDxwiwbRi92w0uL95OihS3eqyKIihtBubNSjiQAd
GhAnkIbK2H3Icy1+MAMHE2Pk75ZyMtoZjlS/pkEdubcBrJCE6JpOvENZmypc4ACf
U3b3D4NJp9U=
=AXIK
-----END PGP SIGNATURE-----

--Sig_/.IlAHuzAjWZ2VH6g0ZNwIIn--
