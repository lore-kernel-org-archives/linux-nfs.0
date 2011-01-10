Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33049 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab1AJMol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 07:44:41 -0500
Message-ID: <4D2AFF29.4060008@pengutronix.de>
Date: Mon, 10 Jan 2011 13:44:25 +0100
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        =?UTF-8?B?VXdlIA==?= =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
References: <20110105210448.GM8638@n2100.arm.linux.org.uk>	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>	 <1294262208.2952.4.camel@heimdal.trondhjem.org>	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>	 <1294268808.2952.18.camel@heimdal.trondhjem.org>	 <1294270104.16957.73.camel@mulgrave.site>	 <1294335614.22825.154.camel@mulgrave.site>	 <1294336054.2905.1.camel@heimdal.trondhjem.org>	 <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>	 <1294426405.2929.23.camel@heimdal.trondhjem.org>	 <20110107190229.GX31708@n2100.arm.linux.org.uk>	 <1294427467.4895.66.camel@mulgrave.site>	 <1294505384.4181.14.camel@heimdal.trondhjem.org> <1294528551.4181.19.camel@heimdal.trondhjem.org>
In-Reply-To: <1294528551.4181.19.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAA42886BC7558FC86E191B1B"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enigAA42886BC7558FC86E191B1B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/09/2011 12:15 AM, Trond Myklebust wrote:
> From 8b2e60cef5c65eef41ab61286f62dec6bfb1ac27 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sat, 8 Jan 2011 17:45:38 -0500
> Subject: [PATCH] NFS: Don't use vm_map_ram() in readdir
>=20
> vm_map_ram() is not available on NOMMU platforms, and causes trouble
> on incoherrent architectures such as ARM when we access the page data
> through both the direct and the virtual mapping.
>=20
> The alternative is to use the direct mapping to access page data
> for the case when we are not crossing a page boundary, but to copy
> the data into a linear scratch buffer when we are accessing data
> that spans page boundaries.
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Tested-by: Marc Kleine-Budde <mkl@pengutronix.de>

=2E.on AT91 (armv5)

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAA42886BC7558FC86E191B1B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0q/ywACgkQjTAFq1RaXHPKVACfSbwPgXZNF3YdnU/W6Auad80e
/c0An3M92CG7Kp5W7OS1nHc/jof1yoS1
=1Bum
-----END PGP SIGNATURE-----

--------------enigAA42886BC7558FC86E191B1B--
