Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56047 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750977AbdFAAWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 May 2017 20:22:48 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 01 Jun 2017 10:22:39 +1000
Subject: [PATCH] mount.nfs: improve version negotiation when vers=4 is specified.
In-Reply-To: <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
References: <20170519222510.31205-1-steved@redhat.com> <87inktk2yg.fsf@notabene.neil.brown.name> <5a0d2640-ec93-279b-9113-228994283923@RedHat.com> <877f18jsx5.fsf@notabene.neil.brown.name> <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
Message-ID: <87lgpceeuo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If NFSv4, in general, is requested (possibly by -t nfs4 or -o v4 or -o
vers=3D4 etc) then we need to negotiate the best minor version, but must
not fallback to v3 or v2.  Internally, this state is reflected in v_mode
=3D=3D V_GENERAL.  This means that a major version was given, but the minor
version still needs to be negotiated.

This is handled by nfs_autonegotiate(). It currently does the right
thing for EPROTONOSUPPORT and EINVAL, but not for other errors.
In particular, ENOENT can cause problems as  NFSv4 might export
a different namespace than NFSv3 (e.g. by using fsid=3D0 in the Linux
NFS server).  Currently a mount request for NFSv4 and a particular path
can result if an NFSv3 mount if the path is available with v3 but
not v4.

So move the special handling of V_GENERAL into the common fall_back:
code, and add extra checking in the ENCONNREFUSED case, which does
not use fall_back:.

Tested-by: Steve Dickson <steved@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/stropts.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0fbb37569ef9..b20ad1c8bf55 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -838,9 +838,6 @@ check_result:
 	case EINVAL:
 		/* A less clear indication that our client
 		 * does not support NFSv4 minor version. */
=2D		if (mi->version.v_mode =3D=3D V_GENERAL &&
=2D			mi->version.minor =3D=3D 0)
=2D				return result;
 		if (mi->version.v_mode !=3D V_SPECIFIC) {
 			if (mi->version.minor > 0) {
 				mi->version.minor--;
@@ -862,6 +859,9 @@ check_result:
 		/* UDP-Only servers won't support v4, but maybe it
 		 * just isn't ready yet.  So try v3, but double-check
 		 * with rpcbind for v4. */
+		if (mi->version.v_mode =3D=3D V_GENERAL)
+			/* Mustn't try v2,v3 */
+			return result;
 		result =3D nfs_try_mount_v3v2(mi, TRUE);
 		if (result =3D=3D 0 && errno =3D=3D EAGAIN) {
 			/* v4 server seems to be registered now. */
@@ -878,6 +878,9 @@ check_result:
 	}
=20
 fall_back:
+	if (mi->version.v_mode =3D=3D V_GENERAL)
+		/* v2,3 fallback not allowed */
+		return result;
 	return nfs_try_mount_v3v2(mi, FALSE);
 }
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkvXlEACgkQOeye3VZi
gbmgIA/9GWG6JW+TEVvI2G8sYe5qCoeUSFzBca8oTjCt91NU83g+lmLe+OLhM9Xt
Ii5eiA9VpXTEBFDHoUlzWaeyPqo/R4Lp6/Jrcuu2VYa9OZzYBqKORBmQiuIJ36yr
Pz35knSU0dicqooljlhA1bStZ+3wa/ohf1yUxvdZQ7xQ/T8bZAlX7H595pFFxhgY
9mBjlwa34yScMF29TeBsUoj0bhTmJyByYBOkmjq770pcmaeB6RQDgURuhSZ0wSH5
CT3A7qwCjzTI/MaIINCmw4mLQuEYLPRu3PcmhMtxYgkQQrz3sJBuYQJ4PhGbLWtf
cgMc7MvSRz3FE5ljCsvP2mafHqAIdmbHcI2qVU0Pngj/BSJ6OI5cKjUHy1TkcN2k
zYH03nD7AVuuw40CD6fQ5VU2D2gO5DfZW0RCkwGwAJ2yRgaQ5o63s+ZTa2xjqNdQ
J/Mkk/tJD6TP0aflp9UyE+glf/Q79LbjjAzAoP3Euhe9g8tcFA8ZBINpDi0kZjiq
4O8e1CKuJd9G/J7jrK7PATusN7U9uWLBU4ap5vyuBm41bDuc+aFZdlAF4wo794mP
TVfaZbP1ahDEknFFshJ25SOArpu2hN6PPznGKbtQaJUyNAN8KFjVF9ie77p3DbvV
nbUAC8Z+UphZu4a67GWGVt9ytEBB0iACpAy5iZkuG4IfoMmlU0I=
=HsGF
-----END PGP SIGNATURE-----
--=-=-=--
