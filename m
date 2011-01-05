Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38043 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab1AEOmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 09:42:36 -0500
Message-ID: <4D248343.2000407@pengutronix.de>
Date: Wed, 05 Jan 2011 15:42:11 +0100
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Jim Rees <rees@umich.edu>
CC: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
References: <20101230171453.GA5787@pengutronix.de> <1293731992.4919.5.camel@heimdal.trondhjem.org> <20101230191846.GB14221@pengutronix.de> <20110103213850.GC25121@pengutronix.de> <1294100558.25100.8.camel@heimdal.trondhjem.org> <20110105084014.GN25121@pengutronix.de> <20110105110517.GQ25121@pengutronix.de> <20110105112701.GA8638@n2100.arm.linux.org.uk> <20110105134045.GS25121@pengutronix.de> <20110105142902.GA9278@merit.edu>
In-Reply-To: <20110105142902.GA9278@merit.edu>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6813EAE19DB28705FC9809E8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig6813EAE19DB28705FC9809E8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/05/2011 03:29 PM, Jim Rees wrote:
> Uwe Kleine-K=F6nig wrote:
>=20
>   > The "fileid changed" messages popped up after mounting an export wi=
th
>   > 'nolock,intr,rsize=3D4096,soft', and then trying to use bash comple=
tion
>   > and 'ls' in a few subdirectories - and entries were missing from th=
e
>   > directory lists without 'ls' reporting any errors (which I think is=
 bad
>   > behaviour in itself.)
>   There was a bug in at least -rc5[1] that was considered already fixed=
 in
>   -rc4[2]. The later announcements didn't mention it anymore.=20
>  =20
>   > I don't know why it's stopped producing the errors, although once i=
t
>   > went I never investigated it any further (was far too busy trying t=
o
>   > get AMBA DMA support working.)
>   It seems it was fixed for most users though. Trond?
>=20
> Trond sent a fix to the nfs list on 27 Nov for "fileid changed" but I d=
on't
> know if this is the same bug you're seeing.  The patch was to
> nfs_same_file() and I can send it if you want.  As far as I know the pa=
tch
> made it upstream.

Are you sure it's in .37?

The pick-axe just found one commit so far
(although it's still searching):

$ git log -Snfs_same_file
commit d39ab9de3b80da5835049b1c3b49da4e84e01c07
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 18:50:01 2010 -0400

    NFS: re-add readdir plus

    This patch adds readdir plus support to the cache array.

    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Would you please be so kind and send the patch to this thread?

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6813EAE19DB28705FC9809E8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0kg0cACgkQjTAFq1RaXHN4WACfe0K0NRwiAVAUOfDmcQjMvd/j
l40AnicjQxr/J7QbLL73vpdl3PDm11SR
=l0gn
-----END PGP SIGNATURE-----

--------------enig6813EAE19DB28705FC9809E8--
