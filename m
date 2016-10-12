Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49991 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932284AbcJLKpt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Oct 2016 06:45:49 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 12 Oct 2016 17:01:15 +1100
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: [PATCH - rpcbind] Provide systemd unit files for rpcbind
Message-ID: <87oa2q14yc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable



To encourage uniformity across distributions, provide
systemd unit files.

If extra arguments are wanted for rpcbind, a drop-in should be used
to set the Environment=3D or read and EnvironmentFile=3D

As the "run" directory could be /run or /var/run we RequiresMountsFor
both of these.

rpcbind.service pulls in rpcbind.socket so that the listening sockets
chosen there will always be used.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 .gitignore                 |  1 +
 Makefile.am                |  4 ++++
 configure.ac               |  7 ++++++-
 systemd/rpcbind.service.in | 17 +++++++++++++++++
 systemd/rpcbind.socket     | 19 +++++++++++++++++++
 5 files changed, 47 insertions(+), 1 deletion(-)
 create mode 100644 systemd/rpcbind.service.in
 create mode 100644 systemd/rpcbind.socket

hi,
 these are based on the unit files in use a SUSE, though I have made a
 few "improvements".
 If anyone has differences in their distros that you think we should
 have in mainline, I'd love to hear about it.

Thanks,
NeilBrown


diff --git a/.gitignore b/.gitignore
index 321dff64a57d..a8f1fed2acb6 100644
=2D-- a/.gitignore
+++ b/.gitignore
@@ -27,3 +27,4 @@ rpcbind
 rpcinfo
 # cscope database files
 cscope.*
+systemd/rpcbind.service
diff --git a/Makefile.am b/Makefile.am
index 5ec8cd66b689..43c27100ceae 100644
=2D-- a/Makefile.am
+++ b/Makefile.am
@@ -50,6 +50,10 @@ if SYSTEMD
 AM_CPPFLAGS +=3D $(SYSTEMD_CFLAGS) -DSYSTEMD
=20
 rpcbind_LDADD +=3D $(SYSTEMD_LIBS)
+
+systemdsystemunit_DATA =3D \
+	systemd/rpcbind.service \
+	systemd/rpcbind.socket
 endif
=20
 rpcinfo_SOURCES =3D       src/rpcinfo.c
diff --git a/configure.ac b/configure.ac
index af4b74b31c9a..0892d8246a12 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -61,4 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
=20
 AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
=20
=2DAC_OUTPUT([Makefile])
+# make bindir available for substitution in config file
+# 2 "evals" needed to expand variable names
+AC_SUBST([_bindir])
+AC_CONFIG_COMMANDS_PRE([eval eval _bindir=3D$bindir])
+
+AC_OUTPUT([Makefile systemd/rpcbind.service])
diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
new file mode 100644
index 000000000000..4706b5a77abf
=2D-- /dev/null
+++ b/systemd/rpcbind.service.in
@@ -0,0 +1,17 @@
+[Unit]
+Description=3DRPC Bind
+Documentation=3Dman:rpcbind(8)
+DefaultDependencies=3Dno
+RequiresMountsFor=3D/var/run /run
+# Make sure we use the IP addresses listed for
+# rpcbind.socket, no matter how this unit is started.
+Wants=3Drpcbind.socket
+After=3Drpcbind.socket
+
+[Service]
+Type=3Dnotify
+# distro can provide a drop-in adding EnvironmentFile=3D-/??? if needed.
+ExecStart=3D@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
+
+[Install]
+WantedBy=3Dmulti-user.target
diff --git a/systemd/rpcbind.socket b/systemd/rpcbind.socket
new file mode 100644
index 000000000000..7204c97efa6f
=2D-- /dev/null
+++ b/systemd/rpcbind.socket
@@ -0,0 +1,19 @@
+[Unit]
+Description=3DRPCbind Server Activation Socket
+DefaultDependencies=3Dno
+RequiresMountsFor=3D/var/run /run
+Wants=3Drpcbind.target
+Before=3Drpcbind.target
+
+[Socket]
+ListenStream=3D/var/run/rpcbind.sock
+
+# RPC netconfig can't handle ipv6/ipv4 dual sockets
+BindIPv6Only=3Dipv6-only
+ListenStream=3D0.0.0.0:111
+ListenDatagram=3D0.0.0.0:111
+ListenStream=3D[::]:111
+ListenDatagram=3D[::]:111
+
+[Install]
+WantedBy=3Dsockets.target
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/dGrAAoJEDnsnt1WYoG5bIAP/2OHj6xq9LgeLXSszuiktEMp
b51LCNgMrtAJ7MXmRam1ST5kia+Cl5g566oe+my1JfoNmCEsoXGwasUmw3MFZayz
Hta8iIfNWFFGKAQUlhlFHewxAFHD8NuxszSJup48H9vQQtr0bgJJLYTG/6xkNgDp
ddlLbuSN9tPtzDoC8E678bK6UNiY4xcCKndWRk8wRaYdHBSxnLToMOb3pmt3LOqJ
LQE1esBGatGygLTJTYrV/3FzHYA/+2a+kaniSwWXYIDZSnBfofBAQcbAZcjcVJkC
SZApxePtuFcoYv+BA9gFX60r9ndCYcoxHIRjrXMQR3ixMD33bPFxKm6yr3FRCWkB
/V+VfATD75+l5c8RgkRZSwKNB3ZPW9Htt7uU4KfrvU977Xdf1tpGy+TJIExbFjbn
gFCafGjsDfWfmGZjGYopMFSPEQOwD1ZV8grSAuh9biOikY7YBDXcVCOqKAlVpKXW
PfWzgdweEhdc2l9Hmy1ZDTue2yKr33BJD5p4+pDRWe933aUWKoQXGywDl8ehBT4C
agdp1PXZwS7CE3JVKQB9tzpsqSaYmTk5eC6I9qa9Gs6vwk11B7a3DN8kv2FUkgAw
wRfDSGkp5I5u6/3dQ7zuh6jm19+whluUHyNaSlmwymyRANVVH0l4VwnlyH8ki/t1
toZ/oxk4C2FEMLfWQuzq
=qNcz
-----END PGP SIGNATURE-----
--=-=-=--
