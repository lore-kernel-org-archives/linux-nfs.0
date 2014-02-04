Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42181 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbaBDBKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Feb 2014 20:10:08 -0500
Date: Tue, 4 Feb 2014 12:09:57 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] systemd units: merge nfs-server.service and
 nfs-server.target
Message-ID: <20140204120957.7bb0375a@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ShwoQj=G8upaVgjWbO_yDpI"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ShwoQj=G8upaVgjWbO_yDpI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


With systemd, a 'service' should run a single server while a 'target'
can be used to group services.
As nfs service is really a group of services a 'target' makes more sense.
However that means that we need commands like
   systemctl start nfs-server.target
rather than the more simple
   systemctl start nfs-server

As the target/service separate doesn't bring any gain except a minor aesthe=
tic,
and does bring a practical inconvenience, this patch merges nfs-server.targ=
et
into nfs-server.service.

Reported-by: Steve Dickson <SteveD@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/systemd/README b/systemd/README
index f0fb68825499..00d3e415092e 100644
--- a/systemd/README
+++ b/systemd/README
@@ -10,9 +10,13 @@ rpc.rquotad (in the 'quota' package) or rpcbind.
 There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
 by a suitable 'preset' setting:
=20
- nfs-server.target
+ nfs-server.service
     If enabled, nfs service is started together with dependencies
     such as mountd, statd, rpc.idmapd
+    This is a "service" file rather than a "target" (which is the
+    normal grouping construct) so that
+        systemctl start nfs-server
+    can work (if no type is given, ".service" is assumed).
=20
  nfs-client.target
     If enabled, daemons needs for an nfs client are enabled.
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 9812866c66aa..6ba2fc0f346e 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,8 +1,10 @@
 [Unit]
-Description=3DNFS server
+Description=3DNFS server and services
 DefaultDependencies=3Dno
 Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
-PartOf=3Dnfs-server.target
+Requires=3D nfs-mountd.service
+Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.=
service
+Wants=3Drpc-statd-notify.service
=20
 After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.servi=
ce
 After=3D nfs-idmapd.service rpc-statd.service
@@ -22,3 +24,6 @@ ExecStopPost=3D/usr/sbin/exportfs -au
 ExecStopPost=3D/usr/sbin/exportfs -f
=20
 ExecReload=3D/usr/sbin/exportfs -r
+
+[Install]
+WantedBy=3Dmulti-user.target
diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
deleted file mode 100644
index a3e629f022a9..000000000000
--- a/systemd/nfs-server.target
+++ /dev/null
@@ -1,8 +0,0 @@
-[Unit]
-Description=3DNFS server services
-Requires=3Dnfs-server.service nfs-mountd.service
-Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.=
service
-Wants=3Drpc-statd-notify.service
-
-[Install]
-WantedBy=3Dmulti-user.target

--Sig_/ShwoQj=G8upaVgjWbO_yDpI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvA95Tnsnt1WYoG5AQJGgw//eK3DkAQel4MEWTuTS/Xg5cSF5Mj15rlt
wx/rk1dlx9Bj3rUr/NtSBQG4qBwYiHApQqQtBkQgWkd9AwSgqTbCdpkpszRg4L6V
wr5yRsGEBc6iU3/zwYnDhZ5Mp003j+RIyXR5Szd2N85je/o149WnQGtawelvxv2d
4ej42XiQl+hrUfMJM0oPWACFT0qykvT586lulHO5Kc0I6TuV1LF17IPfghnCtBuS
NKosj0AxgPGrWpQEKSXIMfGTt95iOdFesu5n/VuNkmnSewcKpxU8F2nHPAWPy4l5
g1e17tDP0FHfhcOOeP8kn79cxuZ4wkpZEXSKJxFkIxlAAXeHKhSinySLwMJywHjH
LedabVaOBqOGdwbyF4DVEWbYuzwvwwDKfXK8/Gn7eL+AKdVyMmlezso2qsH1BWQa
YxbCYPTNO1p7k6I0voj2mvP1/LnInC1u5tKqoa23ud32kWOR0yBskQGpgRHJys5P
WLKNADkY8vX9Omk3/e/mQ05ta7R6QEvTtzfhaaIgiL0iNtLUAgtFBwbCE+wsUj3v
LxExCVu2IthdkzARHjbB4ib4l7rmHqsl9xUTKk4D4q5P5SswouVPLgNHunocCVwv
i0X+UF15PxoaCf55+7e497X/SpXD576uRU+lqTIuImCm7Hh3ti7mSDBlvGvaAm2x
5EvMkRmhH5s=
=gdUn
-----END PGP SIGNATURE-----

--Sig_/ShwoQj=G8upaVgjWbO_yDpI--
