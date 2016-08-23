Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50393 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752826AbcHWW3Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Aug 2016 18:29:24 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 24 Aug 2016 08:29:16 +1000
Subject: [PATCH/nfs-utils] Make location of nfs-utils_env.sh configurable.
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <8737lvglvn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


A recent patch moved this file to /usr/libexec/...
That directory isn't universal, and doesn't exist on openSUSE or
Debian for example.
So change it to use the $libexecdir directory determined by configure

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Steve,
 thanks for processing the server startup patches nice and promptly,
 and for fixing the little details.
 Here is another patches:-)  I really should have tried out the latest
 nfs-utils in openSUSE *before* the release instead of just after.
 Maybe next time.

 It took me a while to get this configure.ac magic to work, but it does
 work nicely for me.  I haven't testing it on a RH distro, but I think
 it should default to the same behavior as before.

 Note that there is a 'rename' in this patch.  Presumably "git am" will
 handle that correctly.  Worth verifying though.

Thanks,
NeilBrown


 configure.ac                                          | 6 ++++++
 systemd/{nfs-config.service =3D> nfs-config.service.in} | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)
 rename systemd/{nfs-config.service =3D> nfs-config.service.in} (86%)

diff --git a/configure.ac b/configure.ac
index 1daf5b8130e2..4fb108fb68d2 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -511,8 +511,14 @@ AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 # Make sure that $ACLOCAL_FLAGS are used during a rebuild
 AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
=20
+# make libexecdir available for substituion in config files
+# 2 "evals" needed late to expand variable names.
+AC_SUBST([_libexecdir])
+AC_CONFIG_COMMANDS_PRE([eval eval _libexecdir=3D$libexecdir])
+
 AC_CONFIG_FILES([
 	Makefile
+	systemd/nfs-config.service
 	linux-nfs/Makefile
 	support/Makefile
 	support/export/Makefile
diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service.in
similarity index 86%
rename from systemd/nfs-config.service
rename to systemd/nfs-config.service.in
index bd69e84a7233..e89dc54209aa 100644
=2D-- a/systemd/nfs-config.service
+++ b/systemd/nfs-config.service.in
@@ -10,4 +10,4 @@ Type=3Doneshot
 # incorporated.  Having "RemainAfterExit=3Dno" (the default)
 # ensures this happens.
 RemainAfterExit=3Dno
=2DExecStart=3D/usr/libexec/nfs-utils/nfs-utils_env.sh
+ExecStart=3D@_libexecdir@/nfs-utils/nfs-utils_env.sh
=2D-=20
2.9.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXvM48AAoJEDnsnt1WYoG55W8QAIXibuZg0ydy+OAaeR0JMtJl
mNvDe63RakHAWk2kOOxkLOp0HLZGgAFEmSnopiwJ8Gls5JOqrYlfaE9Ck5yumnx2
tvOlqlq4d2g8bSW6CWfU0TI4IGR8x2atqf3xHkVLXRrQedKYLalkoM27iG+ZbXrq
2ID+ySeQR4RJDLH8mlFq+iPm2LyU/ao9GA7lWGR78qtuV1UG15Pj5/yCYmcmyrVd
0cq1WpSF0jGq9WxJQK45FodJuPv3fGLDFyfADyF3NoQ4kdU0ThjD/OY31Gq58zc/
Bu7uFDfb3L3ycw5okne1f3jsEuPY1o8cTW+/zDylkodcB9sq2X7ev33AeOh7xGJE
4CdLylNXWOCft6GOvcPCOEofjdg4cCL59+t7gnQ6Z7xG013wrsHAKFdtXqBmyCXu
jfNrXhCNazSnSO8jNGDrbVFbfa+9tX6yCE9cqj3ZfPYGk8xFG6t7KvKh/XkzrvcS
6APpsGzNc1NkCB9goFrCpT7+J3r+FInZ/zfwtTotJWtPNPHFfe1PWNtUhHyR862w
SNHnsHe5uKHuwJKXsqWZfr03NOw+S1/0sMqGIaUzHeVIwfrggmoOtkohDAMBblo5
rrqTAVhgpgDT7WY8RLmVMqCUuTsrwr7hZ8vVFHEJvr7+3Ebbp9OQIyNMVK3MFchN
Nm06hNcww64X9nAgD2Rr
=ctnM
-----END PGP SIGNATURE-----
--=-=-=--
