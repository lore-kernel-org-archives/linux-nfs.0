Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41973 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbaBEDSr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 22:18:47 -0500
Date: Wed, 5 Feb 2014 14:18:36 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH nfs-utils/systemd] systemd: convert secure services to start
 without explicit configuration.
Message-ID: <20140205141836.5fc941a9@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/h.avhhdV5EypJ4Tv6dgT97U"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/h.avhhdV5EypJ4Tv6dgT97U
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



This patch removes nfs-secure.target.
Instead, rpc.gssd and rpc.svcgssd start started if they appear to be needed.

For rpc.gssd, this means if the file /etc/krb5.keytab exists.
As the only security mechanism supported is krb5, that file must exist
for rpc.gssd to be useful.  Conversely, if it does exist, it seems very
likely that krb5 is configured on the system an may be used for NFS.

For rpc.svcgssd, it also means checking if gss-proxy might be performing
the equivalent task instead.  So we check if it is running, and if the kern=
el
is able to talk to it.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/systemd/README b/systemd/README
index 00d3e415092e..d697cefbe229 100644
--- a/systemd/README
+++ b/systemd/README
@@ -24,11 +24,6 @@ by a suitable 'preset' setting:
     is started by /usr/sbin/start-statd which mount.nfs will run
     if statd is needed.
=20
- nfs-secure.target
-    If enabled, then rpc.gssd will be run when either -client or
-    -server is started, and rpc.svcgssd will be run when -server
-    is started
-
  nfs-blkmap.target
     If enabled, then blkmapd will be run when nfs-client.target is
     started.
@@ -52,3 +47,15 @@ This should write /run/sysconfig/nfs-utils based on conf=
iguration
 information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
 It should write to a tmp file and rename to the target to
 avoid parallel units seeing incomplete copies of the file.
+
+rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
+is present.
+If a site needs this file present but does not want the gss daemons
+running, it should create
+   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
+and
+   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf
+
+containing
+   [Unit]
+   ConditionNull=3Dfalse
diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
deleted file mode 100644
index 0127fdb07dbd..000000000000
--- a/systemd/nfs-secure.target
+++ /dev/null
@@ -1,8 +0,0 @@
-[Unit]
-Description=3DSecure NFS client/server services
-# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
-# as required.  If it is not enabled they won't.
-
-[Install]
-WantedBy=3Dremote-fs.target
-WantedBy=3Dmulti-user.target
\ No newline at end of file
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index f0fef007d480..8778c3ef651b 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -3,8 +3,7 @@ Description=3DRPC security service for NFS client and server
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
 After=3Dvar-lib-nfs-rpc_pipefs.mount
=20
-Requisite=3Dnfs-secure.target
-After=3Dnfs-secure.target
+ConditionPathExists=3D/etc/krb5.keytab
=20
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index f024d40a8f41..036ec579bfc1 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -4,8 +4,10 @@ Requires=3Dvar-lib-nfs-rpc_pipefs.mount
 After=3Dvar-lib-nfs-rpc_pipefs.mount
 PartOf=3Dnfs-server.service
=20
-Requisite=3Dnfs-secure.target
-After=3Dnfs-secure.target
+After=3Dgssproxy.service
+ConditionPathExists=3D|!@localstatedir@/run/gssproxy.pid
+ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
+ConditionPathExists=3D/etc/krb5.keytab
=20
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils

--Sig_/h.avhhdV5EypJ4Tv6dgT97U
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvGtjDnsnt1WYoG5AQJY3w/5AeraaWxV7UJ/QGMwmA4uo6l3MRhGy3kk
zvUkjlgF7oozDfLzDwqq6R2yPTg/thulQqygaA6IJieAQ6JXH4IYpKQVgDkrqCmZ
+mVFgF02S9shmawomfAku6G0rCZu0w3uvdcsTnCtKg7ef/SbppfaYc87Wfl4BUBk
cvAtOsHX6FlQgVKjkuhQpZxggLdArH9aSyysojX1dVm0rWlZRwgXLlYOAtEc3UrD
E90M5WXW6yqZ83v2RkWQ2Vn47UgRIeIQX5Z0Yf1zsznY5KI1tmKxlGFk64KEPT+m
MD4YCKMHD04liEzfL2E9YAip8Q88T1Z+qlWUg5MciBxmOmYtprq4wEbBKIf4flTH
iFyC8IsIpyIdWU19llVg+DJ8GmJARarQzJ0L5Q28NLvZq1huMMVfZheMYgYtImUA
E2p62/HEfK3Jl69S1Lhjh6WN8oWNeXhsKcmCp2/9crvjP93kmkp+60x61RtKBuJi
ZIEuKG6gKmH5DAJws17/CfpmhBu5lxvWoqvGRjPBFs2Q0ue38Fz8P/k5gvmnJmDG
yGT5lKpM6bOBpsVNsWHago36Xml3ExG+4+LihQfeCvLWB2+wuOR2KXhCTUecG6//
bqYJ8B0Fr9QvdDrqu1D5iaxfG91wEQWFuuf3Ym3bEbkJoJk+8h0H5LwILCDpcvcT
S2XemDOrhXs=
=m6Mq
-----END PGP SIGNATURE-----

--Sig_/h.avhhdV5EypJ4Tv6dgT97U--
