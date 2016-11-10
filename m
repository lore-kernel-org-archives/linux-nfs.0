Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35491 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751498AbcKJE61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Nov 2016 23:58:27 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>
Date: Thu, 10 Nov 2016 15:58:19 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC nfs-utils] nfsdcltrack: read configuration from a file
In-Reply-To: <1478739358.2442.1.camel@redhat.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <1478739358.2442.1.camel@redhat.com>
Message-ID: <8737j0lyms.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


As nfsdcltrack is normally run directly from the kernel
there is no opportunity to change the default
storage directory.  This can be useful in a cluster to
locate the "storage directory" on shared storage.

The easiest alternative is to allow configuration to be read from a
file, particularly as nfs-utils already has code for parsing a config file.

So read the config file "/etc/nfs.conf" (or as set by ./configure) and
look for "storagedir" and "debug" in the "nfsdcltrack" section.
These values can still be over-ridden by command line options.

A generic name (nfs.conf) was changes for the config file so that
other daemons can be enhanced to read configuration from there.
This may be easier than passing command line arguments through systemd.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 configure.ac                      |  7 +++++++
 utils/nfsdcltrack/nfsdcltrack.c   | 12 ++++++++++++
 utils/nfsdcltrack/nfsdcltrack.man | 14 ++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/configure.ac b/configure.ac
index d60f3a2f7efa..8a5aa2e5203b 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -24,6 +24,12 @@ AC_ARG_WITH(statedir,
 	statedir=3D$withval,
 	statedir=3D/var/lib/nfs)
 	AC_SUBST(statedir)
+AC_ARG_WITH(nfsconfig,
+	[AC_HELP_STRING([--with-nfsconfig=3D/config/file],
+			[use general config file /config/file @<:@default=3D/etc/nfs.conf@:>@])=
],
+	nfsconfig=3D$withval,
+	nfsconfig=3D/etc/nfs.conf)
+	AC_SUBST(nfsconfig)
 AC_ARG_WITH(statdpath,
 	[AC_HELP_STRING([--with-statdpath=3D/foo],
 			[define the statd state dir as /foo instead of the NFS statedir @<:@def=
ault=3D/var/lib/nfs@:>@])],
@@ -468,6 +474,7 @@ dnl Export some path names to config.h
 dnl *************************************************************
 AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location o=
f the NFS state files. Warning: this must match definitions in config.mk!])
 AC_DEFINE_UNQUOTED(NSM_DEFAULT_STATEDIR, "$statdpath", [Define this to the=
 pathname where statd keeps its state file])
+AC_DEFINE_UNQUOTED(NFS_CONFFILE, "$nfsconfig", [This defines the location =
of NFS daemon config file])
=20
 if test "x$cross_compiling" =3D "xno"; then
 	CFLAGS_FOR_BUILD=3D${CFLAGS_FOR_BUILD-"$CFLAGS"}
diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrac=
k.c
index fcdda7f66b8b..e6e514b78316 100644
=2D-- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -43,6 +43,7 @@
 #include <sys/capability.h>
 #endif
=20
+#include "conffile.h"
 #include "xlog.h"
 #include "sqlite.h"
=20
@@ -55,6 +56,8 @@
 /* defined by RFC 3530 */
 #define NFS4_OPAQUE_LIMIT	1024
=20
+char *conf_path =3D NFS_CONFFILE;
+
 /* private data structures */
 struct cltrack_cmd {
 	char *name;
@@ -553,6 +556,7 @@ int
 main(int argc, char **argv)
 {
 	char arg;
+	char *val;
 	int rc =3D 0;
 	char *progname, *cmdarg =3D NULL;
 	struct cltrack_cmd *cmd;
@@ -562,6 +566,14 @@ main(int argc, char **argv)
 	xlog_syslog(1);
 	xlog_stderr(0);
=20
+	conf_init();
+	val =3D conf_get_str("nfsdcltrack", "storagedir");
+	if (val)
+		storagedir =3D val;
+	rc =3D conf_get_num("nfsdcltrack", "debug", 0);
+	if (rc > 0)
+		xlog_config(D_ALL, 1);
+
 	/* process command-line options */
 	while ((arg =3D getopt_long(argc, argv, "hdfs:", longopts,
 				  NULL)) !=3D EOF) {
diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdcltr=
ack.man
index 4b8f4d762a00..cc24b7a2c32e 100644
=2D-- a/utils/nfsdcltrack/nfsdcltrack.man
+++ b/utils/nfsdcltrack/nfsdcltrack.man
@@ -67,6 +67,20 @@ Check to see if a nfs_client_id4 is allowed to reclaim. =
This command requires a
 .IP "\fBgracedone\fR" 4
 .IX Item "gracedone"
 Remove any unreclaimed client records from the database. This command requ=
ires a epoch boot time as an argument.
+.SH "EXTERNAL CONFIGURATION"
+The directory for stable storage information can be set via the file
+.B /etc/nfs.conf
+by setting the
+.B storagedir
+value in the
+.B nfsdcltrack
+section.  For example:
+.in +5
+[nfsdcltrack]
+.br
+  storagedir =3D /shared/nfs/nfsdcltrack
+.in -5
+Debuging to syslog can also be enabled by setting "debug =3D 1" in this fi=
le.
 .SH "LEGACY TRANSITION MECHANISM"
 .IX Header "LEGACY TRANSITION MECHANISM"
 The Linux kernel NFSv4 server has historically tracked this information
=2D-=20
2.10.1


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYI/5rAAoJEDnsnt1WYoG5IfAP/jvx2js1lChZx/1gBpuSpFul
6OSXv9gDZJNWUi8sRi6I6cWH7l33E/PfplN1eZpyq+WUWLtjQVQhFosmt2XHk88q
xOCJ56jn3vtvrtmJpSwuQ3je6vMms+NeYCrRHvFVtUBwH7XUmvJEmbYJ6EKNEdG+
T+XuTVmkM7bFZNgsgQr6svK0JOXq6nEfFzQIk6xpAqjwsUV8dj1+GVzCUEpF80t4
DSanZ5oohIw5YCYGh5EctGfthaGgrAstlGmUxfo6Gjmlt/hvXCu1mb8tKuUi9iXZ
hmLMYMkrQQDlPuE/p+FtlLeTfTLvAbIUGVZ2aO03OWHxOQmsAxbncYVt7EsjsoR0
zzpx5eEcNhg7KrbhILgMWMvjGIXIYzD42zH3jpkC9Kpq46v9oTkurkW0nF1pkY6D
Pq1JIreTZnwsXAQ+x7CmcARtaKm9484CJ2aWHseJOAQN68LfwKjdiPelOOjKmNwl
phNbmAciBl5fn5Pz6BWPRzCOthY4sZUPQBeHdH0vMELvQ2mwIMeMn6ylezsFQVI1
rKXZ9Mde6F34WqPE+eIU9NboNW541+lPPPr6Z78q8xs7oV+7msrcHdo3CLW63aFo
ifikGDrhd2Pt+FLGIu08WuWkz+RU/kVJfqpK4DZ1aSz7DHFv4UA3fYyW52KM0D/S
QDkd9tqYBCnpwRIqPXoa
=rNug
-----END PGP SIGNATURE-----
--=-=-=--
