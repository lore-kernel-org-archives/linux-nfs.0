Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39238 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752401AbdADVdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 16:33:04 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 05 Jan 2017 08:32:46 +1100
Subject: [nfs-utils PATCH] nfsstats: fix some exit codes.
cc: linux-nfs@vger.kernel.org
Message-ID: <87zij6lddt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


"nfsstat -m" always exits with "1" (unless there is an error opening
/proc/mounts).  It should exist "0".

Also, a few usage errors cause an exit of "255" when it should probably
be "1".

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/nfsstat/nfsstat.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 8376347d5af4..eddbe9a14f25 100644
=2D-- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -389,7 +389,7 @@ main(int argc, char **argv)
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
=2D			return -1;
+			return 1;
 		case 'c':
 			opt_clt =3D 1;
 			break;
@@ -455,7 +455,7 @@ main(int argc, char **argv)
 					"not yet supported\n");
 			return 2;
 		case 'm':
=2D			return mounts(MOUNTSFILE);
+			return ! mounts(MOUNTSFILE);
 		case '\1':
 			usage(progname);
 			return 0;
@@ -464,7 +464,7 @@ main(int argc, char **argv)
 			return 0;
 		default:
 			printf("Try `%s --help' for more information.\n", progname);
=2D			return -1;
+			return 1;
 		}
 	}
=20
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhtaf4ACgkQOeye3VZi
gbn8bQ//U0NuK0t/F8Fq6zIPkadOUttgzEsRB84Z4qKZ/6X6zbHzFRfg4V3nhtnV
dQ1Or+QyJJfzqVgIpnJ9e5a56LAsVgJ5uYMLIbuvisqxdldQIYZuIogzxXonQvAF
/H38fW3dq2Fo9sD3V9TOMTuXWOFpWItJUAyfFYDsWWgaaH+JhfScySsbfmbMKXeo
b1A0Q9sNyQ478FW6vHplXd4tVcDaF5XDppVflO771zYyjlgQk/mpCzL1g51/0yXb
8RQ15c2DQMoRyXJpEeUdq12y9QmRmw4PEQybA6SFYAffuQGg6Rg2OHyDB402ZNeD
+nCp8hlp6Mi5cQEHk0R21JF/E7455GlhqCZRlx1BWr086NwVf6sy4T5IwoWcqTE1
r0Gg1t1ma67PkTT6EE3ZwRL/Irc5avFNIxsrshrLqMFa5diw1De1sJD7FA86eDYN
1q16aTEbhqmXDuORgxxX/UU6UcM5IVS1UYf/n/NcN9Z7BWBXQ8sbkWr+BcCj6u5C
UyX9lxEO9zaPntYdai1l598k5qr4zCJPN/q/vOxR5GNq5wTP/qQJTPcHJRGYQsoa
d+3Bsup2zyXPTWq0WP0c6o9r+V6q9UGE5Z65hmVYrEKV9PpdYZEAxpq8Rch7vRs9
T/XYRbaiaskS0sqcFr2XJH7fw/8bNyoiuuT3exFtMBpS2D4J+H8=
=w6jn
-----END PGP SIGNATURE-----
--=-=-=--
