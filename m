Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49520 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450AbcFTFo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 01:44:59 -0400
Date: Mon, 20 Jun 2016 08:44:53 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Sagi Grimberg <sagigrim@gmail.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160620054453.GA1172@leon.nu>
Reply-To: leon@kernel.org
References: <20160616143518.GX5408@leon.nu>
 <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu>
 <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com>
 <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
 <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ew6BAiZeqk4r7MaW"
In-Reply-To: <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 19, 2016 at 04:02:23PM -0400, Chuck Lever wrote:
>=20

Thanks Chuck and Sagi for the help.

<...>

>=20
> > I
> > didn't see such note along the thread, basically, I think this is
> > where we should be starting, thoughts? I also added the mlx4 core/IB
> > maintainer.
>=20
> Yishai was notified about this issue on May 25:
>=20
> http://marc.info/?l=3Dlinux-rdma&m=3D146419192913960&w=3D2

Yishai and me follow this thread closely and we work on finding the
root cause of this issue.

Thanks

>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20

--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZ4LVAAoJEORje4g2clinX2MQALc5XUJL6yV70MznegmDYPXd
jjiO+3YD/Of9IVzX4wRYiV24F/4Q3lgFutP5NQx6kowF8GL4oiPjpJb3F19KdW0n
zfRTmXnZUDs+JpSGVb6pzGSXxxk1PIeVtvV3KUM2oaCzxvdg9acvzLiKBZnFNDFw
00VbB1WKRuKOqe+9FCavJXnNxq1bgyxZ14zEOtZD3qpQjMCttRfLE0VRnQuKaLD+
9JbJWivg+MEgona4iObZJHOIahJkseMVNO4wxSnbCPAoByLdEk8Xu+wImy5xW6zM
SO5+ArYqb5vMRh37FqC2mCOczwckZAtzT4Zrs3CI/ypGeUzoROEi6eCSBfqjPsiO
Q3KzUo3mKw9WljV2UgATAQ1VoKaxze/GPIKVOZalLFdU268XHwp1hA0bjX/8vV9+
TO6sJqLZ9NZVi2IVMnfDSjCfio7ZABm07GvwaZ8V56CvtvyuKcr8mjeZ90y2PhpQ
Njoyu0tMFIJgK+fRcL0WF5aKinFuQREUb2/UN3Zd7V3KbxxTWGmzwmYGFmczL8Ev
hWzUjd1/PzCe8/7dMi/RwNcI3yQgaXnQSeuwo6gaZkdR2Du2glKHpKOUgj2pc7Dk
xYdBxQYWpRsvkLeHLHLUY94cBnnn3nLc/ukmLhyFvNwkSotoIWMpha1wUiYPQ7mi
l0WNLlBjwxU1JeW7POx4
=R5VF
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--
