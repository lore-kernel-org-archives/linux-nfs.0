Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:42281 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab2ARJzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2012 04:55:13 -0500
Date: Wed, 18 Jan 2012 12:56:02 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: [patch] nfsd: don't allow zero length strings in cache_parse()
Message-ID: <20120118095601.GE3356@mwanda>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
 <20120116115258.GC3294@mwanda>
 <20120116155031.GC1750@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DqhR8hV3EnoxUkKN"
In-Reply-To: <20120116155031.GC1750@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--DqhR8hV3EnoxUkKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

There is no point in passing a zero length string here and quite a
few of that cache_parse() implementations will Oops if count is
zero.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 465df9a..8c6598e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -828,6 +828,8 @@ static ssize_t cache_do_downcall(char *kaddr, const cha=
r __user *buf,
 {
 	ssize_t ret;
=20
+	if (count =3D=3D 0)
+		return -EINVAL;
 	if (copy_from_user(kaddr, buf, count))
 		return -EFAULT;
 	kaddr[count] =3D '\0';

--DqhR8hV3EnoxUkKN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPFpcxAAoJEOnZkXI/YHqRIMAQAKhf/4Rm9myX8ijOdJIbcTVx
ix2LK3IrOm6uOzR/8kH5M40JMLJhAG/9DlTwV3+YPOEQEji65TdHXCiDPo5IPUWX
dtgeJy1rH6uEjUEpslL4JT1939/BkI3vimaOdyQH/lENjHXdwGmtYY1NcOR9qIob
NmSK1RTiL72GpvGGQRdSB4ArojquaDrk9uLA5E9iYVY4REplgznIkLOwcmOtVhkY
R7VEIt47hq0RPzqmGigueDa0w7153tSc8JvbcADL2sUmKqaB3jxdhaw075QXiw5k
D5hkadxl9lxATCwZGYe9D9+mAxTo2u7DHXmq51J7/4iLif9uLl5sUAqI5p7tqmSP
ajac9+SOFCLZ840Dubf7WeN7zmXvvGtfKIuR36/27P64PKbS9z4d9fnmNIHTGvhU
BFcDgHJb1fJfTYVw2rq4i7VI3Wp5eZP6AgjFnb2lmI0ysJGe8G9EqLe0du9N55Bm
wfA2HPcUL+Q0b/vH4jORYeMMg9UX9zLHH5fZQ/azPcGzc40nhSpp/1y/ywIaAFg/
hzYDMbmPSUcdA8MqukKzE+xiiQz9jnJS/0d2lrSjrWQDr+XZRyYhEHENWeqtiVGC
ZYJURO2X+tplfKGdTntoYVsaFgRZtJ6KxwBk4Ye6dfrEXHVJ7+Mwc3ZaL7wNx13B
Z5hD6HfnQdfhfzFcsqJX
=FxD+
-----END PGP SIGNATURE-----

--DqhR8hV3EnoxUkKN--
