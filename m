Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.piware.de ([37.120.164.117]:44227 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbbCCPuM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 10:50:12 -0500
Date: Tue, 3 Mar 2015 16:50:10 +0100
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] systemd: Relax dependencies of services
Message-ID: <20150303155010.GC3219@piware.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="DrWhICOqskFTAXiy"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--DrWhICOqskFTAXiy
Content-Type: multipart/mixed; boundary="jousvV0MzM2p6OtC"
Content-Disposition: inline


--jousvV0MzM2p6OtC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello all,

I would like to make NFS start earlier in the boot (i. e. before
basic.target), so that you can do things like put /var/ on NFS, and
rcS SysV init scripts which depend on $remote_fs work.

I tested this on both a server and a client.

Thanks for considering!

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--jousvV0MzM2p6OtC
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-systemd-Relax-dependencies-of-services.patch"
Content-Transfer-Encoding: quoted-printable

=46rom e4eba8124c4efbfa172e5bc0aac632452b97e016 Mon Sep 17 00:00:00 2001
=46rom: Martin Pitt <martin.pitt@ubuntu.com>
Date: Tue, 3 Mar 2015 16:42:28 +0100
Subject: [PATCH] systemd: Relax dependencies of services

Stop depending on basic.target in the daemons which still do; i. e. add
DefaultDependencies=3Dno. This makes it possible to run NFS during early bo=
ot,
and helps if you e. g. have /var on NFS. We don't require much else than
local-fs.
---
 systemd/auth-rpcgss-module.service | 1 +
 systemd/nfs-config.service         | 2 ++
 systemd/nfs-idmapd.service         | 3 ++-
 systemd/nfs-mountd.service         | 3 ++-
 systemd/nfs-server.service         | 2 ++
 systemd/rpc-statd-notify.service   | 3 ++-
 systemd/rpc-svcgssd.service        | 3 ++-
 7 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-modul=
e.service
index 0355e13..5241f7b 100644
--- a/systemd/auth-rpcgss-module.service
+++ b/systemd/auth-rpcgss-module.service
@@ -6,6 +6,7 @@
 # unit will fail.  But that's OK.)
 [Unit]
 Description=3DKernel Module supporting RPCSEC_GSS
+DefaultDependencies=3Dno
 Before=3Dgssproxy.service rpc-svcgssd.service rpc-gssd.service
 Wants=3Dgssproxy.service rpc-svcgssd.service rpc-gssd.service
 ConditionPathExists=3D/etc/krb5.keytab
diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
index 64010e6..7f65305 100644
--- a/systemd/nfs-config.service
+++ b/systemd/nfs-config.service
@@ -1,5 +1,7 @@
 [Unit]
 Description=3DPreprocess NFS configuration
+After=3Dlocal-fs.target
+DefaultDependencies=3Dno
=20
 [Service]
 Type=3Doneshot
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index e84f8c8..df3dd9d 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -1,7 +1,8 @@
 [Unit]
 Description=3DNFSv4 ID-name mapping service
+DefaultDependencies=3Dno
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
-After=3Dvar-lib-nfs-rpc_pipefs.mount
+After=3Dvar-lib-nfs-rpc_pipefs.mount local-fs.target
=20
 BindsTo=3Dnfs-server.service
=20
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index d908afe..8a39f3e 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -1,8 +1,9 @@
 [Unit]
 Description=3DNFS Mount Daemon
+DefaultDependencies=3Dno
 Requires=3Dproc-fs-nfsd.mount
 After=3Dproc-fs-nfsd.mount
-After=3Dnetwork.target
+After=3Dnetwork.target local-fs.target
 BindsTo=3Dnfs-server.service
=20
 Wants=3Dnfs-config.service
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index b35e193..db801cb 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,10 +1,12 @@
 [Unit]
 Description=3DNFS server and services
+DefaultDependencies=3Dno
 Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
 Requires=3D nfs-mountd.service
 Wants=3Drpc-statd.service nfs-idmapd.service
 Wants=3Drpc-statd-notify.service
=20
+After=3D local-fs.target
 After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.servi=
ce
 After=3D nfs-idmapd.service rpc-statd.service
 Before=3D rpc-statd-notify.service
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.se=
rvice
index a655445..a7e2f8e 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -1,7 +1,8 @@
 [Unit]
 Description=3DNotify NFS peers of a restart
+DefaultDependencies=3Dno
 Requires=3Dnetwork-online.target
-After=3Dnetwork.target nss-lookup.target
+After=3Dlocal-fs.target network.target nss-lookup.target
=20
 # if we run an nfs server, it needs to be running before we
 # tell clients that it has restarted.
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index f7424b0..41177b6 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -1,7 +1,8 @@
 [Unit]
 Description=3DRPC security service for NFS server
+DefaultDependencies=3Dno
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
-After=3Dvar-lib-nfs-rpc_pipefs.mount
+After=3Dvar-lib-nfs-rpc_pipefs.mount local-fs.target
 PartOf=3Dnfs-server.service
 PartOf=3Dnfs-utils.service
=20
--=20
2.1.4


--jousvV0MzM2p6OtC--

--DrWhICOqskFTAXiy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJU9dgyAAoJENFO8V2v4RNH7pAP/15G6DnWM4/I2s4ULtZxHD3b
JcWvz659cj0VOLIpwWzA6qlKC0358SZas6n5ov4Lrrn/CRqag07LgExzFqC4nhD0
Fycyo1MBRcrGZJ8hM+Lfh7PGfHsML+w51Ry3VV6A2CqE9CY2JE1YWrS5tHTmhJmt
yxnz98Q5oBZ3hXW1H2i+yR7FSd+eXCP2vizWnEwfLPt9KclNld+4BffIiv+uhqbX
1Gegf6p7ybhZVwjFd1mZjkp9nlc8kkPlpyjotmuM71AxxTvi8RMHVwDXeh/NJeOT
Zy8lsD0tVhyJgPLFHZmtwBXEmHjVh2Ft9LmudHB6FILIXS8dYf2jINVKgcTm7n6b
YPeFehRgtGZW5IzogHqzRktXaOxR6rvxMVXF8JhzR3dz1ojsX643E83O/FL9OuaG
xb5QslPxNVxFI1ZLa+rLUdb+ZrQ9es79WE/JKWu3srhj7YgRdrCl7ifAOO9SUY7d
KeI0yRdPSYXDUPm8n0PRjXuFa9ZpRSGLtidL2Qm2WgmP1SWYybPhZ+Zn8stOvPr4
cUGl34iEMpBbkDt5Q+m+wIWiZt8VCMd/axzWLkSWlNA7G3+M3xoopO9GxYJTgp28
sqVVmhg3VhXJ+gsDs18WM3rjjxvFilAuVgX4q/e2UZ+reZlHtPMORTiInL62NYFn
JwC6YZd19sFBqvJf+mC/
=pS5g
-----END PGP SIGNATURE-----

--DrWhICOqskFTAXiy--
