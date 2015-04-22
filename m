Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38412 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755742AbbDVFHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2015 01:07:25 -0400
Date: Wed, 22 Apr 2015 15:07:14 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150422150714.657893e4@notabene.brown>
In-Reply-To: <20150421215417.GE13782@fieldses.org>
References: <553663B7.7030506@gmail.com>
	<20150421215417.GE13782@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/k.nhQCgFH3nP7kVqhUcMdbd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/k.nhQCgFH3nP7kVqhUcMdbd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 21 Apr 2015 17:54:17 -0400 "J. Bruce Fields" <bfields@fieldses.org>

>=20
> Unfortunately ex_path is part of the key--it's what we need to do
> lookups in this cache.  I'm surprised something like ls /mnt/ still
> works after this.
>=20
> I'm not sure what to do.  I wonder if we really need the struct path as
> part of the key, or if we could get away with just a string path?
> That's what we're actually passing to userspace, after all.

I wonder if we can use Al's new 'fs_pin' stuff, so that when the filesystem
is unmounted we get a call-back and can release the filesystem...

NeilBrown


--Sig_/k.nhQCgFH3nP7kVqhUcMdbd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVTcsgznsnt1WYoG5AQIpJQ//YmeMzuM6LycUx1wrefyag4LeZEGLZnEB
vhUHUclnyaNnSXI9zS0+BBpvFRKJo/VegrAhWSvcEg+uU1syEcNQBuUOhb3uJqY4
7etBUSBOuCbRH4UJaWpNsDAUiVISbYoOEQRF79RZD8FpgZFoD7W7JKKRerru/kJx
nc4Y0JAnYi/pGOUIKIMUEFP3ghJLjIK+NQcw6YbD0bH5TP5iO/6sN7qgNI7Jq33U
463vuMTWO9mM3XjEcLs3hPFNxTzN399qEnpbOIWTjtk/oQAphMBZUN5fsJgKkmzK
yAQfk5ep/OPv2rMaCfqMSeCJSRXJjNIz5je+0lN80R4F1q2eaFHEiOON70a1E8x4
F4ItawaLnUBOY0XY0X2ys/3VoC52+9uO1Ibml1INVUVA2Xq897yxB7oIF6rthbiT
HK0VGG3N3+LGPrM2AUm5I+NCbITN/emdiS6OPu6x3RToe8LnlW4NnB/lzoSXlfuk
Ril3byEYY9fZXYidijjP0c3P9qPpYO4DFGjcCVTVs+/rLCNWEbbvwZd6r9Lm33+/
D6Z7/8q9tbbainqTj2VF43WPuQTvFzZEiNORBK0Wh1SpiK/qN9lUAyf5WPZTq4vR
iZ8DCI/0VInPBpD+H1ee5lnnMTvp8kvaDTynwRk5jK315OsMzmp2ImvQxJoAZopj
hgY3jq1ghGo=
=up2r
-----END PGP SIGNATURE-----

--Sig_/k.nhQCgFH3nP7kVqhUcMdbd--
