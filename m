Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zak.futurequest.net ([69.5.6.152]:38586 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S934979Ab3FSWDs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jun 2013 18:03:48 -0400
Date: Wed, 19 Jun 2013 15:57:04 -0600
From: Bruce Guenter <bruce@untroubled.org>
To: linux-nfs@vger.kernel.org
Subject: Re: Looping NFSv4 traffic
Message-ID: <20130619215704.GA32209@untroubled.org>
References: <20130513202220.GA16969@untroubled.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
In-Reply-To: <20130513202220.GA16969@untroubled.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 13, 2013 at 02:22:20PM -0600, Bruce Guenter wrote:
> I'm seeing repeated duplicated queries going on between a NFSv4 client
> and server. Both client and server are running linux v3.9.2, but I have
> observed this with other versions on both.
>=20
> Wireshark decodes it as (copied by hand):
>=20
> V4 Call (Reply In 3) WRITE StateID:0x1c7c Offset:0 Len:8192
> V4 Reply (Call In 2) WRITE Status: NFS4ERR_OLD_STATEID

I am still seeing this behavior with the client running v3.10-rc6 and
server on v3.9.3. The last two times I've seen it, gvfsd-metadata has
been blocked in D state.

Does anybody have any idea what's going on here?

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRwikwAAoJEFFRvcnBTTxnF0QP/iCk2IBUB34Fgy9K17gCtPwr
agAumzHJ99fYGoBRiGH7lNXWaKg7ia4gzzkvNhTU3n4pp90NCPIKallHNXTGFxY2
/1JCRiS8e1+6a7U+42GyAYk/07QglqQ/hSViKZeJDB0p6Fx5xNJbfNfmzk0x3SUn
tq25v1s+hXzYuzQ7NtYyIIPVEGxvcEg80hjo+jAKFfo2CNmxk/6aaQC86yWuM7wD
Bzzoe8+jwavmUG5lMIEXDaSYBd6+v0F4wwR8LJacvKD92DNMoWt+Bvjgf3gNyaZR
O/oG0Hpig0S0sKqlIFLcSSuQSs2F2WuRvEp7kTZ/Ffw/Hhg153WvHoVq4FLDxjub
5i3xyMYALRv/NQCLtWr45YR8xlcHMOL85lJOC4IoyicRXketR6n18DZdKnXyQjQf
+kRbZsCIZr+a5mB8ln3KeCAoM+/lhLeuGlHBh0cshbU0rDFj7W5Ke6QveP84kU0y
koz9Q3wkte4AFBwpsyV/Toeo9M+SKEiDMmxLVJSVq7xr/w+iVcjs8udrDLyayQhm
+VF45tc8WPQzj2RsAOsSNbib/TxquJD3C79juzRYbiYuuVeEsIL3xEX5N7gqXn6Q
rqGeFfGOPmFgNx9Jh/RGQK763eiA7CvPHrgkHudle1t3XF3i1Zf2p8ANSn441Xue
kMQX6aQ0tABCqBs2oOuY
=iDpN
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
