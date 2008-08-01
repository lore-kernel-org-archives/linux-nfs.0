From: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: mount issue with Mac OSX and --manage-gids, client hangs
Date: Fri, 1 Aug 2008 17:27:15 +1000
Message-ID: <20080801072715.GA10831@samad.com.au>
References: <20080731204701.GE26609@samad.com.au> <18578.41640.740866.153235@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail13.tpgi.com.au ([203.12.160.181]:39166 "EHLO
	mail13.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbYHAH11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 03:27:27 -0400
In-Reply-To: <18578.41640.740866.153235-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 01, 2008 at 03:44:08PM +1000, Neil Brown wrote:
> On Friday August 1, alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org wrote:
> >=20
> > I tracked it down to --manage-gids - when I remove this from
> > /etc/defaults/nfs-kernel-server everything works fine.
> >=20
> > Note though, the UID's, GIDs are not synced between the linux box and
> > the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
> > exist on the nas box
>=20
> Yes... I never tested that case, did I :-(
>=20
> This patch should fix it.  Are you able to compile a new nfs-utils
> with this patch applied and test the mountd from there?

I will give it a try

>=20
> Thanks,
> NeilBrown
>=20
>=20
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index f555dcc..48d737b 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -158,7 +158,8 @@ void auth_unix_gid(FILE *f)
>  		qword_printint(f, ngroups);
>  		for (i=3D0; i<ngroups; i++)
>  			qword_printint(f, groups[i]);
> -	}
> +	} else
> +		qword_printint(f, 0);
>  	qword_eol(f);
>  	if (groups !=3D glist)
>  		free(groups);
>=20

--=20
ink, n.:
	A villainous compound of tannogallate of iron, gum-arabic,
	and water, chiefly used to facilitate the infection of
	idiocy and promote intellectual crime.
		-- H. L. Mencken

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiSutAACgkQkZz88chpJ2PFtwCggSQrcvajFWdOg+lZiTxU/Fgl
BZ8Ani1MX9kZWEVy3uWH2ibFIwJWs8/u
=/jzE
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
