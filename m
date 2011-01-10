Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34279 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab1AJRJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 12:09:10 -0500
Message-ID: <4D2B3D03.8050504@pengutronix.de>
Date: Mon, 10 Jan 2011 18:08:19 +0100
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
References: <1294268808.2952.18.camel@heimdal.trondhjem.org>	 <1294270104.16957.73.camel@mulgrave.site>	 <1294335614.22825.154.camel@mulgrave.site>	 <1294336054.2905.1.camel@heimdal.trondhjem.org>	 <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>	 <1294426405.2929.23.camel@heimdal.trondhjem.org>	 <20110107190229.GX31708@n2100.arm.linux.org.uk>	 <1294427467.4895.66.camel@mulgrave.site>	 <1294505384.4181.14.camel@heimdal.trondhjem.org>	 <1294528551.4181.19.camel@heimdal.trondhjem.org>	 <20110110105019.GC24920@pengutronix.de> <1294676734.3349.10.camel@heimdal.trondhjem.org>
In-Reply-To: <1294676734.3349.10.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig534B58FE496CACCAD7436DD7"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig534B58FE496CACCAD7436DD7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/10/2011 05:25 PM, Trond Myklebust wrote:
> On Mon, 2011-01-10 at 11:50 +0100, Uwe Kleine-K=C3=B6nig wrote:=20
>> Hi Trond,
>>
>> On Sat, Jan 08, 2011 at 06:15:51PM -0500, Trond Myklebust wrote:
>>> ---------------------------------------------------------------------=
--------------=20
>> It would be great if you could add a "8<" in the line above next time.=

>> Then git-am -c does the right thing (at least I think so).
>=20
> Sorry. I wasn't aware of that particular idiom. So something like
>=20
> 8<------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Subject: .....

Yes.

=46rom "man git-mailinfo":
"A line that mainly consists of scissors (either ">8" or "8<") and
perforation (dash "-")"

BTW:
Is this patch a candidate for stable?

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig534B58FE496CACCAD7436DD7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0rPQYACgkQjTAFq1RaXHP/EQCfbaFRmy8UKv7kl4gfOuQoA60g
JMMAniTSFmoSq+LmU6ka2ylzC4XZa35c
=hVyS
-----END PGP SIGNATURE-----

--------------enig534B58FE496CACCAD7436DD7--
