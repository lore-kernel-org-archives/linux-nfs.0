Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:51833 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207Ab3CYS26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 14:28:58 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH [nfs-utils]] locktes/rpcgen: tweak how we override compiler settings
Date: Mon, 25 Mar 2013 14:33:18 -0400
Cc: linux-nfs@vger.kernel.org
References: <1364163668-15490-1-git-send-email-vapier@gentoo.org> <201303251219.06502.vapier@gentoo.org> <5150807B.2070402@RedHat.com>
In-Reply-To: <5150807B.2070402@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3238110.2pWBxzoaDj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201303251433.19752.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart3238110.2pWBxzoaDj
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 25 March 2013 12:51:07 Steve Dickson wrote:
> On 25/03/13 12:19, Mike Frysinger wrote:
> > On Monday 25 March 2013 08:42:32 Steve Dickson wrote:
> >> Also what exactly broke that this patch fixes?
> >=20
> > also in my summary:
> > 	Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
> > 	the <target>.
> >=20
> > so when you cross-compile (e.g. --build=3Dx86_64-linux-gnu
> > --host=3Darm-linux- gnu), and you set CFLAGS to include settings which =
are
> > valid only for the host (e.g. -mfloat-abi=3Dhard -mfp=3Dneon), those fl=
ags
> > will also get passed to the build compiler when compiling these tools
> > and they'll error out (because the build gcc doesn't recognize these
> > flags).
>=20
> And setting AM_CFLAGS does on take care of this problem...
>=20
> I'm just trying to get rid of those warnings...

yeah, i don't know how to make it work w/out triggering the warnings :(. =20
AM_CFLAGS is appended to CFLAGS rather than clobber it.

the concept of having build time tools is a bit foreign to automake atm, so=
 we=20
have to open code this stuff :/.
=2Dmike

--nextPart3238110.2pWBxzoaDj
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJRUJhvAAoJEEFjO5/oN/WB1V0P/19EvOiXsUMooDM813WLP/L1
OmEpqpb5iD0O97M/AruYSwvHnvJl5IR5QT2h+lB4VYoM1yEb3i41PZXM5ShL4Hf9
n4SoLdkcDylXv06ax1VOwhj2bYgPQoVAHfqK6lkWq2blGlEIhp/asg+79tjg5pY3
Nz2KtsEVF7yRhQcAVX3Fqg3ibQ9iSS30bnRmQxRYUTWAO3JqLqiiOPF7b2SPvz2R
cnaECoJgT8Z5xRNV/uxGoY0gQxko5sS5iyEHR5K8huIwmL0iOO8JZ1vtrUwLRsI0
DoaB3epNMmSnkcFukFX/T0V3PPXtpukOMe3Cx/LGmc9HZ5iR3aRg1D3YNo23Im2Y
mvbymXiSjeWPRVuzn8Ew6jQEKEroQjzvjsfx/1jlwKlfX4/P8jK/TQDOpjvkJdHb
z0oSJn/i0doOHJ2muLnwqoGneHlI2IG+wOA7E9eP7VbPnetvjyQk4ral3ek4bor3
t8khoLnrYJqbK2ecP4YO05UonCs1AATTXY13YoSD4NXnZPPVeSXWZO/9vu3iKeGI
GFI4z6NOhRY92YCBKUVRTZOth0CjXy//O57X7d09hUXWJ041wBCrg92p7mp4cL4V
5n2wbR2ItO3DoruDFNUrRCtSqVKYRHyXN3GWgPYrxC0d0LCOc2+ibTmYeRWZNjfi
OjcwzUlR9jTFww0Myzo5
=GwQE
-----END PGP SIGNATURE-----

--nextPart3238110.2pWBxzoaDj--
