Return-Path: linux-nfs-owner@vger.kernel.org
Received: from the.earth.li ([46.43.34.31]:60482 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070Ab3H2XJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Aug 2013 19:09:47 -0400
Date: Thu, 29 Aug 2013 15:48:03 -0700
From: Jonathan McDowell <noodles@earth.li>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Karl Schmidt <karl@xtronics.com>, Dave Kleikamp <dave.kleikamp@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        linux-nfs@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>
Subject: Re: [PATCH] jfs: fix readdir cookie incompatibility with NFSv4
Message-ID: <20130829224803.GO29286@earth.li>
References: <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
 <20130812162924.GB2395@fieldses.org>
 <520C50F7.3010209@oracle.com>
 <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
 <520D3EA7.1010109@oracle.com>
 <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
 <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="NKoe5XOeduwbEQHU"
In-Reply-To: <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--NKoe5XOeduwbEQHU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 17, 2013 at 10:01:31PM +0200, Ben Hutchings wrote:
> On Thu, 2013-08-15 at 14:26 -0700, Christian Kujau wrote:
> > On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
> > > This patch replaces the one I posted yesterday. I like this better si=
nce
> > > it doesn't require fixing existing on-disk cookies or skipping a
> > > position in the in-inode index table.
> >=20
> > Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop" messages=
=20
> > and with unique inode numbers, great!
> >=20
> >   Tested-by: Christian Kujau <lists@nerdbynature.de>
>=20
> Karl and Jonathan, could you test the attached backport to 3.2?

I finally managed to be able to schedule some downtime yesterday for one
of the machines I've been seeing this issue with. So far since the
reboot to this kernel (3.2.46-1 + the patch) I haven't seen a recurrence
of the problem; will update if I see anything.

J.

--=20
Just 'cause I remembered one thing doesn't make me smart!

--NKoe5XOeduwbEQHU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJSH8+iAAoJEP8WL8XPP7rRyJYP/2srf6Leuf7Lr8tW7aQqy59i
Smy4oPW98L++zSL0/0DO/eV2ay/tu0pOzzmhXU4W+jdCcrweA8paBlLypZ3IaHEk
cflM5DO3AHBZglPXFwXwpYSrO9AxWkNq54KeURy9aLj6st2Mm44OanajBbs3swsK
lCePCIxovGEazpfSTWh2cYHXB9LLYH8ePygJl2hxn/wq7zWufe3ih7YCuGkO55FE
bXQspPx6oG6PAIt8GxYPfuzI6IJRVOLDMiVYk9afQCSTBm4aY+UThKUXHXHu3WHT
uEc8uayXUmHZsLSgD84f3C7Cv4Db8EJCapC2LoKdWr+eFjYZdvbHRwlXn8EixtME
5tgnU4PtBJv/VMjfeboT3lz0wzFH1awcR9tkhHKFeSQ2uTKsZcn9Y/fJQeZI8JkR
wjd8khqNcLyUlGkM5U7OgdIeJl9rRKtYqjZOZyr4inr1EuQH8pOJY9JAqG2JSTs3
E86D2oykCvBdngfP9u/S4E7RcgAxllH0T4/eAvo5nV+RjXTe1dyyNBQr8DQT8rSg
KUFE7gK0HqNpSA7RspiGh/hzdo46YzQoVrKiaWJmiEJgwFnxqhfnKqwIGnm1kGwi
L7o72jwTKcASsjgePaw2GiGLz7rLaS/KYTmzPxouPHNO8z9vh5t/YWrePC8d0eTb
G6k2RRObiAVofJve71EM
=1inD
-----END PGP SIGNATURE-----

--NKoe5XOeduwbEQHU--
