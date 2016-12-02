Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60882 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751227AbcLBD1F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:27:05 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:26:56 +1100
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4 revised] Remove error messages on xstrdup failure.
In-Reply-To: <148064098431.9179.10389198547881177509.stgit@noble>
References: <148064084082.9179.6570593128436337540.stgit@noble> <148064098431.9179.10389198547881177509.stgit@noble>
Message-ID: <878trz6mf3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


xstrdup() prints a messages and exits, except in statd where is prints
a message and fails.
So there is no point printing an extra message when xstrdup() fails,
and except in statd, no point calling exit() as well.

So remove some pointless code.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Sorry, missed an include file in nfsd.c
The output of 'make' is too noisy :-(
It is easy to miss things (and something about bad workmen and tools).
NeilBrown


 utils/mountd/mountd.c     |  6 +-----
 utils/nfsd/nfsd.c         | 35 ++++++-----------------------------
 utils/nfsidmap/nfsidmap.c |  6 +-----
 utils/statd/statd.c       |  5 +----
 4 files changed, 9 insertions(+), 43 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index a0ab2935136a..d6cebbbd3920 100644
=2D-- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -721,11 +721,7 @@ main(int argc, char **argv)
 			reverse_resolve =3D 1;
 			break;
 		case 's':
=2D			if ((state_dir =3D xstrdup(optarg)) =3D=3D NULL) {
=2D				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
=2D					progname, optarg);
=2D				exit(1);
=2D			}
+			state_dir =3D xstrdup(optarg);
 			break;
 		case 't':
 			num_threads =3D atoi (optarg);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 7b5e67a09bd2..9a65877f30c3 100644
=2D-- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -27,6 +27,7 @@
 #include "nfslib.h"
 #include "nfssvc.h"
 #include "xlog.h"
+#include "xcommon.h"
=20
 #ifndef NFSD_NPROC
 #define NFSD_NPROC 8
@@ -67,23 +68,9 @@ main(int argc, char **argv)
 	int grace =3D -1;
 	int lease =3D -1;
=20
=2D	progname =3D strdup(basename(argv[0]));
=2D	if (!progname) {
=2D		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
=2D		exit(1);
=2D	}
=2D
=2D	port =3D strdup("nfs");
=2D	if (!port) {
=2D		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
=2D		exit(1);
=2D	}
=2D
=2D	haddr =3D malloc(sizeof(char *));
=2D	if (!haddr) {
=2D		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
=2D		exit(1);
=2D	}
+	progname =3D xstrdup(basename(argv[0]));
+	port =3D xstrdup("nfs");
+	haddr =3D xmalloc(sizeof(char *));
 	haddr[0] =3D NULL;
=20
 	xlog_syslog(0);
@@ -103,12 +90,7 @@ main(int argc, char **argv)
 					exit(1);
 				}
 			}
=2D			haddr[hcounter] =3D strdup(optarg);
=2D			if (!haddr[hcounter]) {
=2D				fprintf(stderr, "%s: unable to allocate "
=2D					"memory.\n", progname);
=2D				exit(1);
=2D			}
+			haddr[hcounter] =3D xstrdup(optarg);
 			hcounter++;
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
@@ -121,12 +103,7 @@ main(int argc, char **argv)
 				usage(progname);
 			}
 			free(port);
=2D			port =3D strdup(optarg);
=2D			if (!port) {
=2D				fprintf(stderr, "%s: unable to allocate "
=2D						"memory.\n", progname);
=2D				exit(1);
=2D			}
+			port =3D xstrdup(optarg);
 			break;
 		case 'r':
 			rdma_port =3D "nfsrdma";
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 63545fc09143..a027343a078d 100644
=2D-- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -441,11 +441,7 @@ int main(int argc, char **argv)
=20
 	key =3D strtol(argv[optind++], NULL, 10);
=20
=2D	arg =3D strdup(argv[optind]);
=2D	if (arg =3D=3D NULL) {
=2D		xlog_err("strdup failed: %m");
=2D		return EXIT_FAILURE;
=2D	}
+	arg =3D xstrdup(argv[optind]);
 	type =3D strtok(arg, ":");
 	value =3D strtok(NULL, ":");
 	if (value =3D=3D NULL) {
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index e5b4c980a86b..15f2b18d104d 100644
=2D-- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -332,11 +332,8 @@ int main (int argc, char **argv)
 				exit(1);
 			break;
 		case 'H': /* PRC: specify the ha-callout program */
=2D			if ((ha_callout_prog =3D xstrdup(optarg)) =3D=3D NULL) {
=2D				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
=2D					argv[0], optarg);
+			if ((ha_callout_prog =3D xstrdup(optarg)) =3D=3D NULL)
 				exit(1);
=2D			}
 			break;
 		case '?':	/* heeeeeelllllllpppp? heh */
 		case 'h':
=2D-=20
2.10.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhA6gAACgkQOeye3VZi
gbng+Q//ZGdELZtJNdMtASV82ft1+j5bNvDC2kSZ22aybI5DSmptLB5xjkriIK9n
BDKxPrbwYQUF0PFALX0rVbZoDzIbMigpioQ1qn2kTaBznXfxDqZru1mvJt30dgJh
iS905V8kVdOnT39l2RwnG9qdBS7ZFlCOjNnFDHpUty/CTxzEZ//O4/YcpnDjIZWo
PvVlJ9QLgdBs+LqAMxFe1FYXEwb/xxfZ6qoDUIIqLx+TD0coufUB9sP57U8V2ohc
X4VKkKy5OofeBoqbgVWq/GcX7+kkRZm3qXbivIYHER6+pugtUTB1El1EJs+PMcah
sPeL5qDW+g8R6zQNmcTOYGlLNOIBAd2wU/+37hcuxFjCCtTKaJjL5Bh0gGHtsr7k
ymtyWWg5WjfAs5AseNKp672paWHX3NsLQ1eYRCL4TwQY1u5A+6K0YU+mZeG1ise/
e4Px1WiOze+gNIWN8Lm2uGA1vvsLfzqH0xkdxUUFBvIT2AX/HeS1wL0GyHwCnGOI
0rdhYS6ctKjGExk+CHCsCYBA6CkJUEJwWQXHx4EMgynWge0llf89W2ZoLQN15N0k
hKvuot4Q1qdfRj7fpfV9aRkkIcMNMl5s9lUv1cjP5r5ds34WozeyQ0DRuaPcW4t2
mnER5GdLkTLdbzBKhwWM+LR3mrOLdzSMSgxHZ7LT5AIZjQZHhFA=
=KmmA
-----END PGP SIGNATURE-----
--=-=-=--
