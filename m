Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43650 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbcDQQRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 12:17:09 -0400
Date: Sun, 17 Apr 2016 12:17:08 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Felix Janda <felix.janda@posteo.de>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH 1/7] des_impl: Use bzero instead of
 __bzero
Message-ID: <20160417161708.GF5369@vapier.lan>
References: <20160417091004.GA2737@nyan>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="QXO0/MSS4VvK6f+D"
In-Reply-To: <20160417091004.GA2737@nyan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--QXO0/MSS4VvK6f+D
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 17 Apr 2016 11:10, Felix Janda wrote:
> Fixes compilation error with musl libc:
>=20
> .libs/libtirpc_la-des_impl.o: In function `_des_crypt':
> src/des_impl.c:591: undefined reference to `__bzero'
>
> --- a/src/des_impl.c
> +++ b/src/des_impl.c
> @@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct desparams=
 *desp)
>      }
>    tin0 =3D tin1 =3D tout0 =3D tout1 =3D xor0 =3D xor1 =3D 0;
>    tbuf[0] =3D tbuf[1] =3D 0;
> -  __bzero (schedule, sizeof (schedule));
> +  bzero (schedule, sizeof (schedule));

might as well convert to memset while you're at it since bzero is deprecated
-mike

--QXO0/MSS4VvK6f+D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXE7cEAAoJEEFjO5/oN/WBJjIP/27/kdRoL1dKz2E2xajXKiHy
mQa1vcAHCaZPyqVA5/T2TjTC3LHSHO+qb7wIx4xGcRqbfe7poUGF72n3KpfJJaEM
0USfAIPF+oWgsNxKHNBuUbsglV+TS1NGoObbiu3IkcgnEXGijl+PohwdCuurJlF7
J+J5k1rvQGPmY/P1doVsMqwnkuj+EElE1JKnXxLAG6gPSf5TLA+dXUFn6h6FIfLf
KCzEymWGS+igCsiX1mgKt5IXRftr624vXvpvCnlm1GIQjnt0hNU9Bk3mtFjvNdDo
V+mGXK2RK6D4qf9/k52UJO4DH5leBIve8rbmnOARTvPsFNbq71yckzxo2gHkB3Ea
iBypGVPh2+apQriZZT4Ex0lh2heCda7LwBTLMzAoU3SGOHjMhvxo2V/Mg/r+78vF
h9QtCZYAFAghd5l+Yk7wvYRqR9tg10x+IZX2gu3tnFzKGBN3sq4TUmRkhNzHx372
b+8835S/VgzHFeKg6pR9mmRaq/fTMcMp5a9Dprcpic2Va5ISMWGmfnv4tjdhFLWy
AODjVmyp3aNE+bmHSL7wdBV42d6dMrONUe09bHaHoi41nqwqsQHrxWXJUACkEgn1
Dc/xzfyZzefxi3aeMYb/WHgZf1TLeqVVt3RftkS4PHybNFU38YA0ESsUwNDqmhlS
cFyBGiZxs2VX9p3YU7Ut
=XIVa
-----END PGP SIGNATURE-----

--QXO0/MSS4VvK6f+D--
