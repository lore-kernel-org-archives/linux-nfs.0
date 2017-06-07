Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45308 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750766AbdFGAdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 20:33:00 -0400
From: NeilBrown <neilb@suse.com>
To: Ian Kent <raven@themaw.net>
Date: Wed, 07 Jun 2017 10:32:49 +1000
Cc: autofs mailing list <autofs@vger.kernel.org>
Subject: [autofs PATCH] Add -c option when calling /bin/umount - if supported.
cc: linux-nfs@vger.kernel.org
cc: util-linux@vger.kernel.org
Message-ID: <87d1agd4cu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The "-c" option has been supported by umount since util-linux 2.17.
It tells umount that the path name is "canonical", meaning no
symlinks or ".." etc.
This is appropriate for autofs to use and it always uses canonical
path names.
The advantage of "-c" is that it means umount doesn't need to
'lstat()' the path so much.
From=20util-linux 2.30, umount doesn't lstat the path at all when
"-c" is passed.  This is particularly beneficial when unmounting
an NFS filesystem for which the server is no reachable. In that
case an 'lstat()' will hang, but the umount(2) can succeed.

So check if "-c" is supported, and if so, use it.
Prior to 2.30 this doesn't help much, but doesn't hurt.
After 2.30 (and a similar small change to nfs-utils),
"-c" will mean that unmounting NFS filesystems will not hang.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 aclocal.m4          | 18 ++++++++++++++++++
 configure           | 33 +++++++++++++++++++++++++++++++++
 configure.in        | 14 ++++++++++++++
 daemon/spawn.c      | 23 +++++++++++++++--------
 include/config.h.in |  3 +++
 5 files changed, 83 insertions(+), 8 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 00811e08dabe..40e1ee97e905 100644
=2D-- a/aclocal.m4
+++ b/aclocal.m4
@@ -73,6 +73,24 @@ AC_DEFUN(AF_SLOPPY_MOUNT,
   fi
 fi])
=20
+dnl ----------------------------------------------------------------------=
----
+dnl AF_NO_CANON_UMOUNT
+dnl
+dnl Check to see if umount(8) supports the no-canonicalize (-c) option, an=
d define
+dnl the cpp variable HAVE_NO_CANON_UMOUNT if so.  This requires that UMOUN=
T is
+dnl already defined by a call to AF_PATH_INCLUDE or AC_PATH_PROGS.
+dnl ----------------------------------------------------------------------=
----
+AC_DEFUN(AF_NO_CANON_UMOUNT,
+[if test -n "$UMOUNT" ; then
+  AC_MSG_CHECKING([if umount accepts the -c option])
+  if "$UMOUNT" -h 2>&1 | grep -e '-c.*--no-canonicalize' > /dev/null 2>&1 =
; then
+    enable_no_canon_umount=3Dyes
+    AC_MSG_RESULT(yes)
+  else
+    AC_MSG_RESULT(no)
+  fi
+fi])
+
=20
 dnl ----------------------------------------------------------------------=
----
 dnl AF_LINUX_PROCFS
diff --git a/configure b/configure
index 10f907e36a9b..9ba267073e62 100755
=2D-- a/configure
+++ b/configure
@@ -737,6 +737,7 @@ with_flagdir
 with_libtirpc
 with_dmalloc
 enable_sloppy_mount
+enable_no_canon_umount
 with_hesiod
 with_openldap
 with_sasl
@@ -1363,6 +1364,7 @@ Optional Features:
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=
=3Dno)
   --enable-FEATURE[=3DARG]  include FEATURE [ARG=3Dyes]
   --enable-sloppy-mount         enable the use of the -s option to mount
+  --enable-no-canon-umount         enable the use of the -c option to umou=
nt
   --disable-ext-env	        disable search in environment for substitution=
 variable
   --disable-mount-locking       disable use of locking when spawning mount=
 command
   --enable-force-shutdown       enable USR1 signal to force unlink umount =
of any
@@ -3993,6 +3995,37 @@ $as_echo "#define HAVE_SLOPPY_MOUNT 1" >>confdefs.h
=20
 fi
=20
+#
+# Newer umounts have the -c (--no-canonicalize) option to avoid
+# stating the path and possible blocking.  Good for NFS.
+#
+# Check whether --enable-no-canon-umount was given.
+if test "${enable_no_canon_umount+set}" =3D set; then :
+  enableval=3D$enable_no_canon_umount;
+else
+  enable_no_canon_umount=3Dauto
+fi
+
+if test x$enable_no_canon_umount =3D xauto; then
+	if test -n "$UMOUNT" ; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking if umount accepts the =
-c option" >&5
+$as_echo_n "checking if umount accepts the -c option... " >&6; }
+  if "$UMOUNT" -h 2>&1 | grep -e '-c.*--no-canonicalize' > /dev/null 2>&1 =
; then
+    enable_no_canon_umount=3Dyes
+    { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+  else
+    { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+  fi
+fi
+fi
+if test x$enable_no_canon_umount =3D xyes; then
+
+$as_echo "#define HAVE_NO_CANON_UMOUNT 1" >>confdefs.h
+
+fi
+
 # LDAP SASL auth needs libxml and Kerberos
 for ac_prog in xml2-config
 do
diff --git a/configure.in b/configure.in
index 05212521b2a9..d408b209cace 100644
=2D-- a/configure.in
+++ b/configure.in
@@ -167,6 +167,20 @@ if test x$enable_sloppy_mount =3D xyes; then
 	AC_DEFINE(HAVE_SLOPPY_MOUNT, 1, [define if the mount command supports the=
 -s option])
 fi
=20
+#
+# Newer umounts have the -c (--no-canonicalize) option to avoid
+# stating the path and possible blocking.  Good for NFS.
+#
+AC_ARG_ENABLE(no-canon-umount,
+[  --enable-no-canon-umount         enable the use of the -c option to umo=
unt],,
+	enable_no_canon_umount=3Dauto)
+if test x$enable_no_canon_umount =3D xauto; then
+	AF_NO_CANON_UMOUNT()
+fi
+if test x$enable_no_canon_umount =3D xyes; then
+	AC_DEFINE(HAVE_NO_CANON_UMOUNT, 1, [define if the umount command supports=
 the -c option])
+fi
+
 # LDAP SASL auth needs libxml and Kerberos
 AF_CHECK_LIBXML()
 AF_CHECK_KRB5()
diff --git a/daemon/spawn.c b/daemon/spawn.c
index c640d97601da..4515607ba022 100644
=2D-- a/daemon/spawn.c
+++ b/daemon/spawn.c
@@ -592,6 +592,11 @@ int spawn_umount(unsigned logopt, ...)
 	char **argv, **p;
 	char prog[] =3D PATH_UMOUNT;
 	char arg0[] =3D PATH_UMOUNT;
+#ifdef HAVE_NO_CANON_UMOUNT
+	char * const arg_c =3D "-c";
+#else
+	char * const arg_c =3D NULL;
+#endif
 	char argn[] =3D "-n";
 	unsigned int options;
 	unsigned int retries =3D MTAB_LOCK_RETRIES;
@@ -620,19 +625,21 @@ int spawn_umount(unsigned logopt, ...)
 			update_mtab =3D 0;
 		}
 	}
+	if (arg_c)
+		argc++;;
=20
=2D	if (!(argv =3D alloca(sizeof(char *) * argc + 1)))
+	if (!(argv =3D alloca(sizeof(char *) * (argc + 1))))
 		return -1;
=20
=2D	argv[0] =3D arg0;
+	p =3D argv;
+	*p++ =3D arg0;
+	if (arg_c)
+		*p++ =3D arg_c;
+
+	if (!update_mtab)
+		*p++ =3D argn;
=20
 	va_start(arg, logopt);
=2D	if (update_mtab)
=2D		p =3D argv + 1;
=2D	else {
=2D		argv[1] =3D argn;
=2D		p =3D argv + 2;
=2D	}
 	while ((*p++ =3D va_arg(arg, char *)));
 	va_end(arg);
=20
diff --git a/include/config.h.in b/include/config.h.in
index e8885092f858..6ed0d832bb60 100644
=2D-- a/include/config.h.in
+++ b/include/config.h.in
@@ -57,6 +57,9 @@
 /* define if you have MOUNT_NFS */
 #undef HAVE_MOUNT_NFS
=20
+/* define if the umount command supports the -c option */
+#undef HAVE_NO_CANON_UMOUNT
+
 /* define if the mount command supports the -s option */
 #undef HAVE_SLOPPY_MOUNT
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk3SbMACgkQOeye3VZi
gbngDxAAutFgEa3DflICsz5VJPdXS6vxqYtoVUve3et4FIaPttlcGz14tERDqWq3
cUenU1Y/zAdzcYXyU/vBbEMuvq4/dMtNbOvzGghQrJXQmdLxK2aFpD6c16akXfNO
fuqM7kDlji0oMd45TXdJHL4QNwM+nVamvWWQ1A/suON/gv2QEXAYwpFZjJnLeZuK
hJCEUlGKGw4WXkYKUhMZg7QyZwXYOMdKT22OsOuCaYeB5s7AMZkIa4H3CPVqvd42
x4zI1ZoOMlETrM3cjfYjKBCD70JCc7fnwzySxIOd0dWyGvoSq+DwttT2iG8DAfb+
uOe1yrf9MDR0XOAv1UH9S/oAKDiGgsBelFGmfPUQcJXLEchE+cAkaRPnBvQKuGgK
g7vJYUJdbPvAjC6sZh647c3cqe9cFj7IHhUb246c0bcyX6cHz3k1+tNW0QttNJ5P
cT23Lks6A1BN5eAT31Oa8pZ/HNdMthoUdTHwE90HQBdu7p1K7bqZHnx2pe6vCl6x
t8YLIS5siGl9ozRsxz4q1fbMMVe1o7JlVjb08gSjtDx26HGO14sd0CejQLKACgaL
41Ox08BPy9SgO/5lVad6xmBWYgsUVurnWIkCLmJvfhw34ni/U3nweW+n92K7jYGM
IgRvY3o1CmVkmkeK0zZOIIsHuGJuYs3jAFi+FPzp+kZsEQx8Fao=
=bB9O
-----END PGP SIGNATURE-----
--=-=-=--
