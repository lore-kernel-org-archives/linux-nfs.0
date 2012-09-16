Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57217 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751213Ab2IPOAq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Sep 2012 10:00:46 -0400
Message-ID: <1347804028.13258.267.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#669314: NFS: kernel forces trailing slash for export in
 /proc/self/mounts
From: Ben Hutchings <ben@decadent.org.uk>
To: Chris Hiestand <chiestand@salk.edu>, 669314@bugs.debian.org
Cc: viro@zeniv.linux.org.uk, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Micheal Waltz <mwaltz@qualcomm.com>,
        Gabriel Evanoff <gevanoff@salk.edu>
Date: Sun, 16 Sep 2012 15:00:28 +0100
In-Reply-To: <254E1AAA-BDE2-41A8-94D8-6E677860AD72@salk.edu>
References: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu>
	 <1347762073.13258.188.camel@deadeye.wl.decadent.org.uk>
	 <254E1AAA-BDE2-41A8-94D8-6E677860AD72@salk.edu>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-n+BfwSVAvDw0y/3YwQyg"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-n+BfwSVAvDw0y/3YwQyg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-09-16 at 03:24 -0700, Chris Hiestand wrote:
> I had a couple friends over today and we made a trivial patch to
> remove trailing slashes. We do not know C and have never created a
> patch for the kernel before, so there is undoubtedly a better way to
> do it. However we hope this helps in your efforts.
>=20
> This patch was created from the offending commit (c7f404b40a366). But
> I've also applied it to to Linus Torvalds' master HEAD (3f0c3c8fe30c7)
> with success.

This was my first thought - but what if userland provides a device name
with a slash on the end?  I think we have to report it back with the
slash in that case.

Ben.

--=20
Ben Hutchings
Experience is what causes a person to make new mistakes instead of old ones=
.

--=-n+BfwSVAvDw0y/3YwQyg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFXbfee/yOyVhhEJAQor2g//ddQieC/wRMkV6K/zX/wYOfWoLT1MR1SX
gQR3cdv8ehwh7vw+xHiI57j5jcjmUsv1Ko8q6WjC59OV/7D+2fE3uAEzT46CnDLs
/H2qX2GT91Ljm3ZMDx8dSnA+5JnXYMHvoVFlybHajL01LL9JO+gW+hVaBxIgYkIq
K89kRwnF6YSKNdb0+bTAUkN7EDQM2fSEapqxX+cPn51DNZ1VTgGPwDGkpgadCBQn
GEr6FdqptgjwudlsmSXPE6A63+ejei/30c7igOlluCp/IPO6DQfJfV8LjZTyvDUN
3AbVwmw6f82iGil0BLka1CaA5zQ6f2U8vauUU+wJ/o6C3dSfPPkngZyc/82MDpKg
jrv4q3nUIbYxeK//XbTjCF7qugmmnvi2lk2Bdq7/bDAOkGD29/0SH/141Hha7knl
fE4ENxH+74PCRIcbsRlLoxwwo2vnRLDfnx+WWw3lEZ5NV05+ycuT1AmArdrVeG8m
pha1m1LEQuroPvCKoiEUR8W2wuowREHsTVbzHp+PxH1RElKIJy92SjtHsTBkuDYX
FTN3JqDs37xwRWhKNQXrL4nUQZk/BcFwfPigmtwESaQwPRCfUxTl+eTcFYrGE2b1
WkPB7Tcj1weMwFSjelkRBUjImEWfT59S4NOXJh4M4UJ+uoL4Ue8Fm5Gxj26v+6C+
s2KCqQpUdtk=
=2qOZ
-----END PGP SIGNATURE-----

--=-n+BfwSVAvDw0y/3YwQyg--
