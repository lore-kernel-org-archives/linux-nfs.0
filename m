Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55595 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424050AbcBRC7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 21:59:24 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 18 Feb 2016 13:59:17 +1100
Subject: [PATCH] mount.nfs - hide EBUSY errors.
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <877fi2raey.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Linux only returns EBUSY for a non-remount mount if the exact
requested filesystem is already mounted.  Arguably this is not an
error.

"mount -a" tries to see if each requested filesystem is already mounted.
Sometimes it gets it wrong - e.g. hostname aliases can confuse it.
So "mount -a" will report a failure "already mounted", which is
wrong because it should filter those out.

An easy fix it just to be silent about EBUSY.  As the requested
result (a given filesystem being mounted at a given location) is in
effect after the EBUSY return, we can just treat it as success.

This removes the confusing "already mounted" errors.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/stropts.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 86829a902bfd..320dde2fab92 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -960,6 +960,15 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
=20
+		if (errno =3D=3D EBUSY)
+			/* The only cause of EBUSY is if exactly the desired
+			 * filesystem is already mounted.  That can arguably
+			 * be seen as success.  "mount -a" tries to optimise
+			 * out this case but sometimes fails.  Help it out
+			 * by pretending everything is rosy
+			 */
+			return EX_SUCCESS;
+
 		if (nfs_is_permanent_error(errno))
 			break;
=20
=2D-=20
2.7.1


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWxTOFAAoJEDnsnt1WYoG5BZcQAKuuKhQT9bTeG2KLr9blgTjy
bh2xpS4aggpqcxaEXchunhVEK5k25RSqryyz1bVFXPakoWY9qJPhRXT9HinfLklS
T1OwsVwt1w7oVNncYx2vkA9lRmwZscaUqad5qGO760dkjHsSvLWxA3RXkLi6bUng
aMHO3HGjfJGTsL1q8IzBXuU+EKo7SVR+gOiwiCMxOG1O2WKKSnirGTd6XqRkQDPm
yoe2EKWgPERkw6rinX8Ft7JRnItio2O3iz6msoEWNbcAcqKLG+wHSWxcMvPul68P
c8DvnTjfObqv+WsaM9/b9YUOkx8aG+PnK4/h/51LpNTBDMTolFk73MiXAb3bgK53
9hY2VHBz9/nSZXZg8RQ8Ba2olmFonUnGQJbb14ZTn3VjIUWuKHgPseORf9G8Z7tv
8nYvTP9Smf00gykF0ZoPaZhiJr5iPGC9FYIyO1sb1q9KyGZRVJ5jg/NpBeAE3bd6
4HDAmO0TCA/QHkSInRZ4wnsuza7I+sN8Mi/NmAdwSESF8JAuKdgNH2USUmej45w8
FW67FW/iqyhpvyw5MJHMcnx21mvdpOL/Qc8b+0OM6t+IMESfAf+Cf9iWMtXGYQ9b
i0CNOyO/PX4g8EFBq396eG6TKFkOhDEirrBayXn6Vk5m/sAfAU1Gp/YDa0Npqsll
V0DfKVRU1N1ttGvJas3+
=oj5S
-----END PGP SIGNATURE-----
--=-=-=--
