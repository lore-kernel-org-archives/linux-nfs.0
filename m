Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42706 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbaBEFoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 00:44:04 -0500
Date: Wed, 5 Feb 2014 16:43:51 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140205164351.7a766eff@notabene.brown>
In-Reply-To: <52F130E2.6090308@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<52F130E2.6090308@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/VhANqk8MmgsLYcJE2U4Dmv6"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VhANqk8MmgsLYcJE2U4Dmv6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 04 Feb 2014 13:26:42 -0500 Steve Dickson <SteveD@redhat.com> wrote:


> >=20
> >>
> >> How would these daemons be restart and shutdown? Since this is a=20
> >> target, systemctl restart and system stop don't do anything.
> >=20
> > This is something I haven't completely figured out yet.
> >=20
> > Part of the solution might be the "PartOf" directive.
> > If each service claims to be "PartOf" the main one, then stopping or
> > restarting the main service will propagate to stopping and restarting t=
he
> > individual services.
> > Unfortunately in nfs we have some shared services.  rpc.statd and rpc.g=
ssd
> > are needed by both server and client.  That isn't a big problem for 're=
start',
> > but if you 'systemctl stop nfs-client' and find that the server isn't
> > properly working any more, that would be awkward
> > If could possibly work around that by setting "StopWhenUnneeded" for th=
ose
> > shared services.  Then e.g. rpc.statd would stop when both client and s=
erver
> > are stopped, but not if either one of them is stopped.
> > However I don't know how that interacts with restart.  I suspect that t=
he
> > StopWhenUnneeded services are *not* stopped and restarted when the main
> > service is stopped.  So it would  be  hard to restart all nfs services =
on an
> > upgrade.
> >=20
> > Further research seems needed here.
> Fine... I'll try to digest what you are saying here, but
> would it make it easier if everything was in a service file?

So I did a bit more research and thinking, and I present the two patches
below for consideration.  If you agree and would prefer them in separate
emails I can certainly do that.

The first ensures that we can easily restart all daemons during software
update.  It creates a new 'nfs-utils.service' which exists only to allow th=
at
restart.

The second ensures startup and shutdown work properly (though I haven't
tested much).
Do we need to shutdown nfs-server or nfs-client easily at any time other th=
an
system shutdown?

Thanks,

NeilBrown

=46rom 0d880d8faf4db7189c11fc13854da82074c260ac Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Wed, 5 Feb 2014 16:28:47 +1100
Subject: [PATCH] systemd: add nfs-utils.service which can be used to restart
 everything.

With this patch,
   systemctl restart nfs-utils
will restart any nfs-utils daemons that are currently running, whether
there were started via nfs-server.service, nfs-client.target, or
directly by systemctl.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/systemd/README b/systemd/README
index d697cefbe229..8359530098f4 100644
--- a/systemd/README
+++ b/systemd/README
@@ -28,6 +28,17 @@ by a suitable 'preset' setting:
     If enabled, then blkmapd will be run when nfs-client.target is
     started.
=20
+Another special unit is "nfs-utils.service".  This doesn't really do
+anything, but exists so that other units may declare themselves as
+"PartOf" nfs-utils.service.
+The effect of this is that
+     systemctl restart nfs-utils
+will restart all nfs-utils daemons as maybe be required during
+software update.  It isn't possible to make
+     systemctl try-restart nfs-server nfs-client.target
+do this as some daemon are included in both, and rpc.statd would
+not be restarted if nfs-server were not active (as nfs-client doesn't
+Want it - it is started by mount.nfs running start-statd).
=20
 It is possible that we should have an nfs-statd.target which can
 selectively enable statd being stared by -server and sm-notify
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index 7319a88661cc..80033f2fbcf4 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -6,6 +6,8 @@ Requires=3Dvar-lib-nfs-rpc_pipefs.mount
 Requisite=3Dnfs-blkmap.target
 After=3Dnfs-blkmap.target
=20
+PartOf=3Dnfs-utils.service
+
 [Service]
 Type=3Dforking
 ExecStart=3D/usr/sbin/blkmapd
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index 6c2e1537f064..7d0dd84d8a44 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -1,6 +1,8 @@
 [Unit]
 Description=3DNFSv4 ID-name mapping service
=20
+PartOf=3Dnfs-utils.service
+
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
 ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 92e05ca309ee..90746a854b40 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -4,6 +4,7 @@ Requires=3Dproc-fs-nfsd.mount
 After=3Dproc-fs-nfsd.mount
 After=3Dnetwork.target
 PartOf=3Dnfs-server.service
+PartOf=3Dnfs-utils.service
=20
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
diff --git a/systemd/nfs-utils.service b/systemd/nfs-utils.service
new file mode 100644
index 000000000000..54b6314d8d52
--- /dev/null
+++ b/systemd/nfs-utils.service
@@ -0,0 +1,17 @@
+[Unit]
+Description=3DNFS server and client services
+# This service should never be stopped, only restarted.
+# When it is re-started, all other services which declare
+# themselves to be "PartOf" this service will also be
+# restarted. Thus
+#   systemctl restart nfs-utils
+# will restart all daemons which are part of nfs-utils
+# and which are running.  This is useful after a software
+# update.
+
+# This is a "service" rather than "target" so that we
+# don't need to say "systemctl restart nfs-utils.target".
+[Service]
+Type=3Doneshot
+RemainAfterExit=3Dyes
+ExecStart=3D/bin/true
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index 8778c3ef651b..3982985762ea 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -5,6 +5,8 @@ After=3Dvar-lib-nfs-rpc_pipefs.mount
=20
 ConditionPathExists=3D/etc/krb5.keytab
=20
+PartOf=3Dnfs-utils.service
+
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
 ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.se=
rvice
index 9d972fc7753a..532354d64fa0 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -8,6 +8,8 @@ After=3Dnetwork-online.target nss-lookup.target
 # tell clients that it has restarted.
 After=3Dnfs-server.service
=20
+PartOf=3Dnfs-utils.service
+
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
 ExecStartPre=3D/usr/lib/systemd/scritps/nfs-utils_env.sh
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 04962e542fbc..88d2527cae9d 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -4,6 +4,8 @@ DefaultDependencies=3Dno
 Requires=3Dnss-lookup.target rpcbind.target
 After=3Dnetwork.target nss-lookup.target rpcbind.target
=20
+PartOf=3Dnfs-utils.service
+
 [Service]
 EnvironmentFile=3D-/run/sysconfig/nfs-utils
 ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 036ec579bfc1..6bd45884d991 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -3,6 +3,7 @@ Description=3DRPC security service for NFS server
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
 After=3Dvar-lib-nfs-rpc_pipefs.mount
 PartOf=3Dnfs-server.service
+PartOf=3Dnfs-utils.service
=20
 After=3Dgssproxy.service
 ConditionPathExists=3D|!@localstatedir@/run/gssproxy.pid







=46rom 30b27a718632e9d24c479921b116d2c3958a3fc2 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Wed, 5 Feb 2014 16:36:21 +1100
Subject: [PATCH] systemd: tidy up DefaultDependencies

DefaultDependencies should be "yes" (the default) for things
needed only be the NFS server, as that is a service that doesn't
need to start early.

DefaultDependencies should be "no" for things needed to mount an
NFS filesystem, and filesystems are mounted before basic.target.
To ensure these services are shut down in a timely fashion, they
must Conflict with systemd.umount so they are shutdown when everything
is unmounted.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index 80033f2fbcf4..4b74e9f61454 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -1,5 +1,7 @@
 [Unit]
 Description=3DpNFS block layout mapping daemon
+DefaultDependencies=3Dno
+Conflicts=3Dumount.target
 After=3Dvar-lib-nfs-rpc_pipefs.mount
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
=20
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 6ba2fc0f346e..5779fd39ed34 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,6 +1,5 @@
 [Unit]
 Description=3DNFS server and services
-DefaultDependencies=3Dno
 Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
 Requires=3D nfs-mountd.service
 Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.=
service
diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
index f44d52f3d67b..931a5ceeb055 100644
--- a/systemd/proc-fs-nfsd.mount
+++ b/systemd/proc-fs-nfsd.mount
@@ -1,6 +1,5 @@
 [Unit]
 Description=3DNFSD configuration filesystem
-DefaultDependencies=3Dno
=20
 [Mount]
 What=3Dnfsd
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index 3982985762ea..375792804247 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -1,5 +1,7 @@
 [Unit]
 Description=3DRPC security service for NFS client and server
+DefaultDependencies=3Dno
+Conflicts=3Dumount.target
 Requires=3Dvar-lib-nfs-rpc_pipefs.mount
 After=3Dvar-lib-nfs-rpc_pipefs.mount
=20
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.se=
rvice
index 532354d64fa0..7742ac8c5d9a 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -1,6 +1,5 @@
 [Unit]
 Description=3DNotify NFS peers of a restart
-DefaultDependencies=3Dno
 Requires=3Dnetwork-online.target
 After=3Dnetwork-online.target nss-lookup.target
=20
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 88d2527cae9d..3f6cda16accd 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -1,6 +1,7 @@
 [Unit]
 Description=3DNFS status monitor for NFSv2/3 locking.
 DefaultDependencies=3Dno
+Conflicts=3Dumount.target
 Requires=3Dnss-lookup.target rpcbind.target
 After=3Dnetwork.target nss-lookup.target rpcbind.target
=20
diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs-rpc=
_pipefs.mount
index cd614cf49f00..33c5db65aa38 100644
--- a/systemd/var-lib-nfs-rpc_pipefs.mount
+++ b/systemd/var-lib-nfs-rpc_pipefs.mount
@@ -1,6 +1,7 @@
 [Unit]
 Description=3DRPC Pipe File System
 DefaultDependencies=3Dno
+Conflicts=3Dumount.target
=20
 [Mount]
 What=3Dsunrpc

--Sig_/VhANqk8MmgsLYcJE2U4Dmv6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvHPlznsnt1WYoG5AQKMcxAAs56O06uaQaZ8F9Z2o3/nvLHLCHlNcHg9
UoJb7+CDHbiUPcKC3DV0uAY/28+cFYsJNnLOAPm1k8AgNyN0/MyK+I+/eKnP59XT
wMcUkeGLuttBIhAgZsgRi2zjyCI2wOb3xecyggJxp30bLRXbn2e+l0ZIQ6RrhrF+
DHAz71EqqIzgzedEsWCNlPBFYiKs8Pk1Di2+c9sOPHJRokZi169y4gTNIENNSj2H
O+VpvBQL7D2imEXvQHenpZ35edNZkZ+cjA0IUv6KOgAdKTgRbs3jB7zRJ24f2lyv
UsfsCzCdQMdOmE1FrlG0ZIDxvrVJcsUXgJEWIcXzXPyq35/RVh0vYowMITCs2HMx
APiGSg2w2bGA+XDVlTpPOFUoDQX3EwXwMGPdLSjkXJWwMKB1zrmcFhZC1YdiY5Q7
Ha+tefoJ4mBi/giukoA3RlsLT6KO8c4SO0lHnj4WRscuqSZBHzz3C0pNZLBOXwvY
qXjOBvea7F6/736Khr1GOEQkF2ABQZoUKTLXHHwkyGltiBtV8dIIZKmyPIojaN1+
qaHYpQKFCyPwGbIVrNYdVdTxmQ8JM9Bsvqs6vyWnSMjXcx8NkLcQmCy6phbxgDqO
rLXQfwSnYyEf4HgYZUvj1Y7WKhCPDA6ZgYu2XF8FBeJJHqlj/AbO2KrBBZ5cOycO
uX77EyBH7z0=
=zUIU
-----END PGP SIGNATURE-----

--Sig_/VhANqk8MmgsLYcJE2U4Dmv6--
