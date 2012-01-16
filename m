Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:16720 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271Ab2APLxH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Jan 2012 06:53:07 -0500
Date: Mon, 16 Jan 2012 14:52:58 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: [patch] nfsd: oopses in cache_parse()
Message-ID: <20120116115258.GC3294@mwanda>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
In-Reply-To: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

We fixed expkey_parse() in b2ea70afad "nfsd: Fix oops when parsing a
0 length export" but there are other cache_parse() implimentations
which have the same issue.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Since half of the implimentations get this wrong, maybe we should
just check for this in cache_do_downcall().  Is there ever a valid
reason to pass a zero length string to cache_parse()?

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index cf8a6bd..1d147a8 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -496,7 +496,7 @@ static int svc_export_parse(struct cache_detail *cd, ch=
ar *mesg, int mlen)
 	struct svc_export exp =3D {}, *expp;
 	int an_int;
=20
-	if (mesg[mlen-1] !=3D '\n')
+	if (mlen < 1 || mesg[mlen - 1] !=3D '\n')
 		return -EINVAL;
 	mesg[mlen-1] =3D 0;
=20
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index a6e711a..d945d71 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 	ssize_t len;
 	int ret =3D -EINVAL;
=20
-	if (buf[buflen-1] !=3D '\n')
+	if (buflen < 1 || buf[buflen - 1] !=3D '\n')
 		goto out;
 	buf[buflen-1] =3D '\0';
=20
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 9409627..f8456a4 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -202,7 +202,7 @@ idtoname_parse(struct cache_detail *cd, char *buf, int =
buflen)
 	int len;
 	int error =3D -EINVAL;
=20
-	if (buf[buflen - 1] !=3D '\n')
+	if (buflen < 1 || buf[buflen - 1] !=3D '\n')
 		return (-EINVAL);
 	buf[buflen - 1]=3D '\0';
=20
@@ -378,7 +378,7 @@ nametoid_parse(struct cache_detail *cd, char *buf, int =
buflen)
 	char *buf1;
 	int error =3D -EINVAL;
=20
-	if (buf[buflen - 1] !=3D '\n')
+	if (buflen < 1 || buf[buflen - 1] !=3D '\n')
 		return (-EINVAL);
 	buf[buflen - 1]=3D '\0';
=20


--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPFA+ZAAoJEOnZkXI/YHqRKCUP/ipCvCv63JE5c116KQynw2KA
W4uqcUUWouUC9Zi1RWvdqSQPHKrZyaCuUaI1Eou8KSL3rh/f+VfxP7dQY2386i5a
m4WMIzkOuzQzUhrh9OwED6icTsa/GGne4gHudBfCOHc3SfaL676RvQStLVTRTAkh
n8Vu09x9q2IBkbLosffjnCVrHnnqiZuhrbSAYQruzmGZnAPOhfzY+eGGRYd0Ri+N
57urc0oWBjJ7y2yq+faqHDsb8SdO6O7c+nkGDPFivmthUN7JbyOLgh8gzWfmPU+Q
91HoLst6F1vamlmgUPRtUcqBTFopE+rePGH69PH+hs5Cpo02/DDRZUvoCsGaiBzT
NYcrMi78aGJIae5DIt6WgrGSl5X+fahdf1h7at4jHAonnBbrazAHwaGSXEBJSpD1
X+sZV2CCi4ckIfmYSNpRsJ6XrhLu48GAGLgil3SoKhko9zxJTrsrj+vj8U4WumJO
yuOTumVBGSc/tIKfOTDf96LViYwXW4KYe/ACchFIA+oLAZQvM94tQW47rXYuc7mk
BTnAAIVgAjN4kQuz2YQxig++xAOKSgNdOrh2dg5he4larJ+G/g5GfZut7NPVbxRV
UUyX2cYOs8hzYxxdXzyl/IKZZMl3dvKR6kErMEoWK7pwKVefMoBRZ1P021jltr46
3leX0BXD2ePyM4Mujmee
=Vqr+
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--
