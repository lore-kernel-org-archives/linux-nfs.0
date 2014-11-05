Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37139 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbaKEDFl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 22:05:41 -0500
Date: Wed, 5 Nov 2014 14:05:22 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [nfs-utils PATCH 2/2] Include systemd unit files in "dist" and
 "install".
Message-ID: <20141105140522.5cffda9e@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/qjcMMUsBVkGIorMYuvbuBzV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qjcMMUsBVkGIorMYuvbuBzV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


New configure option "--with-systemd" will causes systemd
unit files to be installed in /usr/lib/systemd/system.
Alternalte a path can be given:
    --with-systemd=3D/lib/systemd/system

Also, systemd files get included in "make dist" now.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 Makefile.am         |  2 +-
 configure.ac        | 11 +++++++++++
 systemd/Makefile.am | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 44 insertions(+), 1 deletion(-)
 create mode 100644 systemd/Makefile.am

diff --git a/Makefile.am b/Makefile.am
index 392e7b364359..4a2edc682de8 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -2,7 +2,7 @@
=20
 AUTOMAKE_OPTIONS =3D foreign
=20
-SUBDIRS =3D tools support utils linux-nfs tests
+SUBDIRS =3D tools support utils linux-nfs tests systemd
=20
 MAINTAINERCLEANFILES =3D Makefile.in
=20
diff --git a/configure.ac b/configure.ac
index 59fd14d253ff..db1c261c8ce1 100644
--- a/configure.ac
+++ b/configure.ac
@@ -55,6 +55,16 @@ AC_ARG_WITH(start-statd,
 	)
 	AC_SUBST(startstatd)
 	AC_DEFINE_UNQUOTED(START_STATD, "$startstatd", [Define this to a script w=
hich can start statd on mount])
+unitdir=3D/usr/lib/systemd/system
+AC_ARG_WITH(systemd,
+	[AC_HELP_STRING([--with-systemd@<:@=3Dunit-dir-path@:>@],
+			[install systemd unit files @<:@Default: no, and path defaults to /usr/=
lib/systemd/system if not given@:>@])],
+	test "$withval" =3D "no" && use_systemd=3D0 || unitdir=3D$withval use_sys=
temd=3D1
+	use_systemd=3D0
+	)
+	AM_CONDITIONAL(INSTALL_SYSTEMD, [test "$use_systemd" =3D 1])
+	AC_SUBST(unitdir)
+
 AC_ARG_ENABLE(nfsv4,
 	[AC_HELP_STRING([--enable-nfsv4],
                         [enable support for NFSv4 @<:@default=3Dyes@:>@])],
@@ -518,6 +528,7 @@ AC_CONFIG_FILES([
 	utils/showmount/Makefile
 	utils/statd/Makefile
 	utils/osd_login/Makefile
+	systemd/Makefile
 	tests/Makefile
 	tests/nsm_client/Makefile])
 AC_OUTPUT
diff --git a/systemd/Makefile.am b/systemd/Makefile.am
new file mode 100644
index 000000000000..16cf5e667fa2
--- /dev/null
+++ b/systemd/Makefile.am
@@ -0,0 +1,32 @@
+## Process this file with automake to produce Makefile.in
+
+MAINTAINERCLEANFILES =3D Makefile.in
+
+unit_files =3D  \
+    nfs-blkmap.target \
+    nfs-client.target \
+    \
+    auth-rpcgss-module.service \
+    nfs-blkmap.service \
+    nfs-config.service \
+    nfs-idmapd.service \
+    nfs-mountd.service \
+    nfs-server.service \
+    nfs-utils.service \
+    rpc-gssd.service \
+    rpc-statd-notify.service \
+    rpc-statd.service \
+    rpc-svcgssd.service \
+    \
+    proc-fs-nfsd.mount \
+    var-lib-nfs-rpc_pipefs.mount
+
+EXTRA_DIST =3D $(unit_files)
+
+unit_dir =3D /usr/lib/systemd/system
+
+if INSTALL_SYSTEMD
+install-data-hook: $(unit_files)
+	mkdir -p $(DESTDIR)/$(unitdir)
+	cp $(unit_files) $(DESTDIR)/$(unitdir)
+endif
--=20
2.1.1


--Sig_/qjcMMUsBVkGIorMYuvbuBzV
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFmT8jnsnt1WYoG5AQIWpQ/9EkCR5EDDeaJ1nsow23QBLiyhXEK5iEtZ
VRl/z84zrgBmBeGzZQTyki3RvYDeYQ9jqdQJmDvAs1cW2ju75NPomU6xn908dvqy
i+iocA5WcIprNLuemOtGnS48Gm4duvyHF8BqQB+Ye6PQPSgCKlgAaBU6FlmmP5yT
B8KokehAougSveUOGn4XOJd68j2HmqLCzIGg6bQdhASRIBoT92JKdbrqlLVRwj0l
liDQoq0Sgfl8lDQ9187JCL39NAFavjRUCeh2xHG3s6XBIF8FteIAaLxavBAFDmjV
IhTnuznwx6YpDnOZBwWDKF+Ka9CPWZZkl14rQPam4iSRjryA1bMMbhl+2xss+9oq
9iQBgRE9v+GgMVvZYM3SDsfsKPmLNBnXBsYNtajeqkl8+btInKQlCbcv/6EstDSM
0PqZ14GP3rkP62O7uC9EvMJp+wT346PJYfJhMG+VpgCtInL+J5KvT3Ty8T6ohcJu
WppAXys1Czg13B+hqPR541Gw7ZOsj7iu2Y80kn6wCvICfZ2ywkqUhWfRN0HtOfP9
3UC4/KUFxucyWeHtbuLd5gePmO/nptt56tBA5mLGqUpour80I4bceZPEGDZXrgAV
CF1zUellyNL4skAzHmYSQtia4mIAOLjsYpeduXBkUjhiOwa//Fd9HGhVO3YRc67p
Q3+7Sv+KLW8=
=QbgX
-----END PGP SIGNATURE-----

--Sig_/qjcMMUsBVkGIorMYuvbuBzV--
