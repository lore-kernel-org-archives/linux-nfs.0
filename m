Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:59854 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab2ATHr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2012 02:47:27 -0500
Date: Fri, 20 Jan 2012 10:48:18 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: [patch] nfsd: remove some unneeded checks
Message-ID: <20120120074818.GA12039@mwanda>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
 <20120116115258.GC3294@mwanda>
 <20120116155031.GC1750@fieldses.org>
 <20120118095601.GE3356@mwanda>
 <20120118224107.GC27205@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
In-Reply-To: <20120118224107.GC27205@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

We check for zero length strings in the caller now, so these aren't
needed.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index cf8a6bd..8e9689a 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -87,7 +87,7 @@ static int expkey_parse(struct cache_detail *cd, char *me=
sg, int mlen)
 	struct svc_expkey key;
 	struct svc_expkey *ek =3D NULL;
=20
-	if (mlen < 1 || mesg[mlen-1] !=3D '\n')
+	if (mesg[mlen - 1] !=3D '\n')
 		return -EINVAL;
 	mesg[mlen-1] =3D 0;
=20
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 01153ea..6ab3573 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -509,7 +509,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 	time_t expiry;
 	struct unix_gid ug, *ugp;
=20
-	if (mlen <=3D 0 || mesg[mlen-1] !=3D '\n')
+	if (mesg[mlen - 1] !=3D '\n')
 		return -EINVAL;
 	mesg[mlen-1] =3D 0;
=20

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPGRxBAAoJEOnZkXI/YHqRyf8P/i/NqAK8OY+Lbddyd44jVQeZ
FcDAvv4zuiXW9nBYrirVUz5YZ+d/YHsGaK1PYdMdYb/zyy8+ziabdTccLjoEhwei
5TsOq+sXxSexHkZAg0jO4KBaLjEfETVcDzCOkfcWJ5HxknrShXwu9bMK1Vcf8S0n
PxRUK2YywibCb4osejsDZiG60H+f0kb2p33eC5QbaD+jmDCD9fzJrLZ4wkdV2lD0
Gq3J6ZxKYLbjkO9sxgZBf8f34EuDi16KWmbDP3JJuvFXQp+1ylHAswwEeJ7j60HC
mgXJCMiep3t3isEQWEJpa3/YH+/N7saRezLZomLgMYoeHnCL5hpjx7vgmDZhHlfY
jX2bdLDAexkM207IG5E89sV75LBK4MBR+P16bCb7S05GYWD4uHSsHjc5Gv0GetVO
9nj7nMxhiYw2vDPJwH+zvNLZWDfyavZFejPqk/chn0FQtXN7jollLkx6bhNhiDpu
JOkLdxCjDuwCaDJSr86sYHIpBgyAvREFjKWyRdf8iIHEANtnFfXLRD7j28fBoqQQ
fs4N3UP7MoL54WIU4TLnfJF/KR1ZRKZFAUS2SxZBOhgC4Fq9Jz0L0CxQN30fa7eW
yeihJ7gGcotARw14si9aWT9PYFbNdrSx71U1wqGqUeWSPaWpPsjVKnjaTbSiE+S9
O6SCazuAOgvDx0icdklY
=FLA6
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
