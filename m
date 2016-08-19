Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56776 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752435AbcHSUiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 16:38:08 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Sat, 20 Aug 2016 06:37:59 +1000
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: [PATCH 0.5/2] Move export_d_read() to support/export/export.c
In-Reply-To: <147157095612.26568.14161646901346011334.stgit@noble>
References: <147157095612.26568.14161646901346011334.stgit@noble>
Message-ID: <87twegh4uw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This places it in the same place as the similar export_read(),
and allows it to be called from other programs.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Sorry I missed this when I posted the other two patches.  It is
needed for the first one to compile.

NeilBrown


 support/export/export.c    | 65 ++++++++++++++++++++++++++++++++++++++++++=
++++
 support/include/exportfs.h |  1 +
 utils/exportfs/exportfs.c  | 59 -----------------------------------------
 3 files changed, 66 insertions(+), 59 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index e1bebcec12ef..0b8a858c2c74 100644
=2D-- a/support/export/export.c
+++ b/support/export/export.c
@@ -15,6 +15,8 @@
 #include <sys/param.h>
 #include <netinet/in.h>
 #include <stdlib.h>
+#include <dirent.h>
+#include <errno.h>
 #include "xmalloc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -96,6 +98,69 @@ export_read(char *fname)
 }
=20
 /**
+ * export_d_read - read entries from /etc/exports.
+ * @fname: name of directory to read from
+ *
+ * Returns number of read entries.
+ * Based on mnt_table_parse_dir() in
+ *  util-linux-ng/shlibs/mount/src/tab_parse.c
+ */
+int
+export_d_read(const char *dname)
+{
+	int n =3D 0, i;
+	struct dirent **namelist =3D NULL;
+	int volumes =3D 0;
+
+
+	n =3D scandir(dname, &namelist, NULL, versionsort);
+	if (n < 0) {
+		if (errno =3D=3D ENOENT)
+			/* Silently return */
+			return volumes;
+		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
+	} else if (n =3D=3D 0)
+		return volumes;
+
+	for (i =3D 0; i < n; i++) {
+		struct dirent *d =3D namelist[i];
+		size_t namesz;
+		char fname[PATH_MAX + 1];
+		int fname_len;
+
+
+		if (d->d_type !=3D DT_UNKNOWN
+		    && d->d_type !=3D DT_REG
+		    && d->d_type !=3D DT_LNK)
+			continue;
+		if (*d->d_name =3D=3D '.')
+			continue;
+
+#define _EXT_EXPORT_SIZ   (sizeof(_EXT_EXPORT) - 1)
+		namesz =3D strlen(d->d_name);
+		if (!namesz
+		    || namesz < _EXT_EXPORT_SIZ + 1
+		    || strcmp(d->d_name + (namesz - _EXT_EXPORT_SIZ),
+			      _EXT_EXPORT))
+			continue;
+
+		fname_len =3D snprintf(fname, PATH_MAX +1, "%s/%s", dname, d->d_name);
+		if (fname_len > PATH_MAX) {
+			xlog(L_WARNING, "Too long file name: %s in %s", d->d_name, dname);
+			continue;
+		}
+
+		volumes +=3D export_read(fname);
+	}
+
+	for (i =3D 0; i < n; i++)
+		free(namelist[i]);
+	free(namelist);
+
+	return volumes;
+}
+
+/**
  * export_create - create an in-core nfs_export record from an export entry
  * @xep: export entry to lookup
  * @canonical: if set, e_hostname is known to be canonical DNS name
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 4cac203fbc29..f033329b5fd2 100644
=2D-- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -135,6 +135,7 @@ int 				client_member(const char *client,
 						const char *name);
=20
 int				export_read(char *fname);
+int				export_d_read(const char *dname);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(const struct addrinfo *ai,
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index a00b5ea1853e..4ac2c15ae13e 100644
=2D-- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -26,7 +26,6 @@
 #include <fcntl.h>
 #include <netdb.h>
 #include <errno.h>
=2D#include <dirent.h>
 #include <limits.h>
 #include <time.h>
=20
@@ -47,7 +46,6 @@ static void	error(nfs_export *exp, int err);
 static void	usage(const char *progname, int n);
 static void	validate_export(nfs_export *exp);
 static int	matchhostname(const char *hostname1, const char *hostname2);
=2Dstatic int	export_d_read(const char *dname);
 static void grab_lockfile(void);
 static void release_lockfile(void);
=20
@@ -700,63 +698,6 @@ out:
 	return result;
 }
=20
=2D/* Based on mnt_table_parse_dir() in
=2D   util-linux-ng/shlibs/mount/src/tab_parse.c */
=2Dstatic int
=2Dexport_d_read(const char *dname)
=2D{
=2D	int n =3D 0, i;
=2D	struct dirent **namelist =3D NULL;
=2D	int volumes =3D 0;
=2D
=2D
=2D	n =3D scandir(dname, &namelist, NULL, versionsort);
=2D	if (n < 0) {
=2D		if (errno =3D=3D ENOENT)
=2D			/* Silently return */
=2D			return volumes;
=2D		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
=2D	} else if (n =3D=3D 0)
=2D		return volumes;
=2D
=2D	for (i =3D 0; i < n; i++) {
=2D		struct dirent *d =3D namelist[i];
=2D		size_t namesz;
=2D		char fname[PATH_MAX + 1];
=2D		int fname_len;
=2D
=2D
=2D		if (d->d_type !=3D DT_UNKNOWN
=2D		    && d->d_type !=3D DT_REG
=2D		    && d->d_type !=3D DT_LNK)
=2D			continue;
=2D		if (*d->d_name =3D=3D '.')
=2D			continue;
=2D
=2D#define _EXT_EXPORT_SIZ   (sizeof(_EXT_EXPORT) - 1)
=2D		namesz =3D strlen(d->d_name);
=2D		if (!namesz
=2D		    || namesz < _EXT_EXPORT_SIZ + 1
=2D		    || strcmp(d->d_name + (namesz - _EXT_EXPORT_SIZ),
=2D			      _EXT_EXPORT))
=2D			continue;
=2D
=2D		fname_len =3D snprintf(fname, PATH_MAX +1, "%s/%s", dname, d->d_name);
=2D		if (fname_len > PATH_MAX) {
=2D			xlog(L_WARNING, "Too long file name: %s in %s", d->d_name, dname);
=2D			continue;
=2D		}
=2D
=2D		volumes +=3D export_read(fname);
=2D	}
=2D
=2D	for (i =3D 0; i < n; i++)
=2D		free(namelist[i]);
=2D	free(namelist);
=2D
=2D	return volumes;
=2D}
=2D
 static char
 dumpopt(char c, char *fmt, ...)
 {
=2D-=20
2.9.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXt24nAAoJEDnsnt1WYoG5N8gP/jELPt1fMbFFifzKO+CezmNc
TP7BuB/x5Mbx9A5lcFJiXTMrMB5IZ2c2O54+18UkmsGQDx2GXdrGq340ou85tk4X
iEy/Rr8CdXCqwQZnjtWVFHp0Vi1o9QpXXlXPaFFtwL8EMp0S3CYAsQ0ifxP22S1q
NV242pwvdSWEZjeJVKes1dpvaQawzX74QCnZ2lvqidtVmRTjSqMgGiKrqsJJ6yay
G2v/vhFouXRXthFpwvApws9XywyOYEq8ramOfx3dlKRyPI4I7csPmzn44EBo6/0T
mVCDfJVFuM/WITudcTcHUk73Qu4cyhw8W0Ipn4t0WdZdZZ0JaVN4/gzofNdDAVG4
RZazgGVPvoj8K/zLauzjwse2COaO5qgdwVQZfvFBQ9AoUX0KxtHrOK4JyMTK+amZ
yv+82GLwy/HDRM4eEoxAF3NnimYI+c6f2XRuHvhmNiERH1zOmwxM0dmjpxG37nWF
rwya/n3NEYw8Z7yESZnp5Mjo8nfYEBvLRQt+Q1G6Sb4YL2IT7Truq1mnsp1frNij
Ct0hclrKmKcFNVBDsbrYO2Ox0FYZyeDmJeKifcHlAf2EzOD/I1GtmB90rl3A9WLp
uWWrn23I1VWuaHcMOztJX35c7WB1+y1x1SJwPYFgTro4ibkGuOuaP7n6rdeeHALD
UIuyRJXj1d9XOXjU3AYV
=i0Ia
-----END PGP SIGNATURE-----
--=-=-=--
