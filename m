Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34358 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaA3GZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 01:25:01 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 41981AAD1
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jan 2014 06:25:00 +0000 (UTC)
Date: Thu, 30 Jan 2014 17:24:51 +1100
From: NeilBrown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140130172451.7a354ce4@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/cHmrZrZy.NIkKZWQ/Qw+h6l"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/cHmrZrZy.NIkKZWQ/Qw+h6l
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi all,

 I would really like to see a common set of systemd unit files used for
 nfs-utils by every distribution (that actually uses systemd), and would li=
ke
 those unit files to be in the upstream nfs-utils package.

 To that end I have put together the following collection of unit files whi=
ch
 seem right to me, and appear to work as I think I want them to work.

 I've looked at the unit files in Fedora and borrowed some ideas while
 discarding and changing others.  I won't try to list and justify all the
 changes here, but I'm perfectly willing (possibly even eager) to justify
 anything specific that anyone cares to ask about.

 So:
  1/ Do you agree that a collection of systemd unit files belongs in
     nfs-utils?
  2/ Do you think it reasonable to expect most (systemd using) distros to
     use the one set?  I will certainly try to ensure openSUSE does if
     upstream accepts them.
  3/ Do you have any comments/question about those below?


Thanks,
NeilBrown

diff --git a/systemd/README b/systemd/README
new file mode 100644
index 000000000000..f0fb68825499
--- /dev/null
+++ b/systemd/README
@@ -0,0 +1,50 @@
+
+Notes about systemd unit files for nfs-utils.
+
+The unit files provided here should be sufficient for systemd
+to manage all daemons and related services provides by nfs-utils.
+
+They do *not* include any unit files for separate services such as
+rpc.rquotad (in the 'quota' package) or rpcbind.
+
+There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
+by a suitable 'preset' setting:
+
+ nfs-server.target
+    If enabled, nfs service is started together with dependencies
+    such as mountd, statd, rpc.idmapd
+
+ nfs-client.target
+    If enabled, daemons needs for an nfs client are enabled.
+    This does *not* include rpc.statd.  the rpc-statd.service unit
+    is started by /usr/sbin/start-statd which mount.nfs will run
+    if statd is needed.
+
+ nfs-secure.target
+    If enabled, then rpc.gssd will be run when either -client or
+    -server is started, and rpc.svcgssd will be run when -server
+    is started
+
+ nfs-blkmap.target
+    If enabled, then blkmapd will be run when nfs-client.target is
+    started.
+
+
+It is possible that we should have an nfs-statd.target which can
+selectively enable statd being stared by -server and sm-notify
+being started by -server or -client.  That way it could be disabled
+completely on V4-only configurations.  Currently statd is always
+started on the server and sm-notify is always run if server or
+client is enabled.
+
+Stopping nfs-server will also stop rpc.mountd, and rpc.svcgssd.
+It cannot stop rpc.statd or rpc.gssd as they may be in use by the
+client and systemd cannot specify is two-pronged reverse dependency.
+(i.e. stop this unit if none of these units are running)
+
+Distro specific commandline configuration can be provided by
+installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
+This should write /run/sysconfig/nfs-utils based on configuration
+information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
+It should write to a tmp file and rename to the target to
+avoid parallel units seeing incomplete copies of the file.
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
new file mode 100644
index 000000000000..7319a88661cc
--- /dev/null
+++ b/systemd/nfs-blkmap.service
@@ -0,0 +1,11 @@
+[Unit]
+Description=3DpNFS block layout mapping daemon
+After=3Dvar-lib-nfs-rpc_pipefs.mount
+Requires=3Dvar-lib-nfs-rpc_pipefs.mount
+
+Requisite=3Dnfs-blkmap.target
+After=3Dnfs-blkmap.target
+
+[Service]
+Type=3Dforking
+ExecStart=3D/usr/sbin/blkmapd
diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
new file mode 100644
index 000000000000..fbcc111152ee
--- /dev/null
+++ b/systemd/nfs-blkmap.target
@@ -0,0 +1,8 @@
+[Unit]
+Description=3D PNFS blkmaping enablement.
+# If this target is enabled, then blkmapd will be started
+# as required.  If it is not enabled it won't.
+
+[Install]
+WantedBy=3Dremote-fs.target
+WantedBy=3Dmulti-user.target
\ No newline at end of file
diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
new file mode 100644
index 000000000000..fa591354abf3
--- /dev/null
+++ b/systemd/nfs-client.target
@@ -0,0 +1,13 @@
+[Unit]
+Description=3DNFS client services
+Before=3Dremote-fs-pre.target
+Wants=3Dremote-fs-pre.target
+
+# Note: we don't "Wants=3Drpc-statd.service" as "mount.nfs" will arrange to
+# start that on demand if needed.
+Wants=3Drpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
+Before=3Drpc-gssd.service nfs-blkmap.service
+
+[Install]
+WantedBy=3Dmulti-user.target
+WantedBy=3Dremote-fs.target
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
new file mode 100644
index 000000000000..6c2e1537f064
--- /dev/null
+++ b/systemd/nfs-idmapd.service
@@ -0,0 +1,9 @@
+[Unit]
+Description=3DNFSv4 ID-name mapping service
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Dforking
+ExecStart=3D/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
new file mode 100644
index 000000000000..92e05ca309ee
--- /dev/null
+++ b/systemd/nfs-mountd.service
@@ -0,0 +1,13 @@
+[Unit]
+Description=3DNFS Mount Daemon
+Requires=3Dproc-fs-nfsd.mount
+After=3Dproc-fs-nfsd.mount
+After=3Dnetwork.target
+PartOf=3Dnfs-server.service
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Dforking
+ExecStart=3D/usr/sbin/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
new file mode 100644
index 000000000000..0127fdb07dbd
--- /dev/null
+++ b/systemd/nfs-secure.target
@@ -0,0 +1,8 @@
+[Unit]
+Description=3DSecure NFS client/server services
+# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
+# as required.  If it is not enabled they won't.
+
+[Install]
+WantedBy=3Dremote-fs.target
+WantedBy=3Dmulti-user.target
\ No newline at end of file
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
new file mode 100644
index 000000000000..9812866c66aa
--- /dev/null
+++ b/systemd/nfs-server.service
@@ -0,0 +1,24 @@
+[Unit]
+Description=3DNFS server
+DefaultDependencies=3Dno
+Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
+PartOf=3Dnfs-server.target
+
+After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.servi=
ce
+After=3D nfs-idmapd.service rpc-statd.service
+After=3D rpc-gssd.service rpc-svcgssd.service
+Before=3D rpc-statd-notify.service
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Doneshot
+RemainAfterExit=3Dyes
+ExecStartPre=3D/usr/sbin/exportfs -r
+ExecStart=3D/usr/sbin/rpc.nfsd $RPCNFSDARGS
+ExecStop=3D/usr/sbin/rpc.nfsd 0
+ExecStopPost=3D/usr/sbin/exportfs -au
+ExecStopPost=3D/usr/sbin/exportfs -f
+
+ExecReload=3D/usr/sbin/exportfs -r
diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
new file mode 100644
index 000000000000..a3e629f022a9
--- /dev/null
+++ b/systemd/nfs-server.target
@@ -0,0 +1,8 @@
+[Unit]
+Description=3DNFS server services
+Requires=3Dnfs-server.service nfs-mountd.service
+Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.=
service
+Wants=3Drpc-statd-notify.service
+
+[Install]
+WantedBy=3Dmulti-user.target
diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
new file mode 100644
index 000000000000..f44d52f3d67b
--- /dev/null
+++ b/systemd/proc-fs-nfsd.mount
@@ -0,0 +1,8 @@
+[Unit]
+Description=3DNFSD configuration filesystem
+DefaultDependencies=3Dno
+
+[Mount]
+What=3Dnfsd
+Where=3D/proc/fs/nfsd
+Type=3Dnfsd
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
new file mode 100644
index 000000000000..f0fef007d480
--- /dev/null
+++ b/systemd/rpc-gssd.service
@@ -0,0 +1,14 @@
+[Unit]
+Description=3DRPC security service for NFS client and server
+Requires=3Dvar-lib-nfs-rpc_pipefs.mount
+After=3Dvar-lib-nfs-rpc_pipefs.mount
+
+Requisite=3Dnfs-secure.target
+After=3Dnfs-secure.target
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Dforking
+ExecStart=3D/usr/sbin/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.se=
rvice
new file mode 100644
index 000000000000..9d972fc7753a
--- /dev/null
+++ b/systemd/rpc-statd-notify.service
@@ -0,0 +1,17 @@
+[Unit]
+Description=3DNotify NFS peers of a restart
+DefaultDependencies=3Dno
+Requires=3Dnetwork-online.target
+After=3Dnetwork-online.target nss-lookup.target
+
+# if we run an nfs server, it needs to be running before we
+# tell clients that it has restarted.
+After=3Dnfs-server.service
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Doneshot
+RemainAfterExit=3Dyes
+ExecStart=3D-/usr/sbin/sm-notify -d $SMNOTIFYARGS
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
new file mode 100644
index 000000000000..04962e542fbc
--- /dev/null
+++ b/systemd/rpc-statd.service
@@ -0,0 +1,12 @@
+[Unit]
+Description=3DNFS status monitor for NFSv2/3 locking.
+DefaultDependencies=3Dno
+Requires=3Dnss-lookup.target rpcbind.target
+After=3Dnetwork.target nss-lookup.target rpcbind.target
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Dforking
+ExecStart=3D/usr/sbin/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
new file mode 100644
index 000000000000..f024d40a8f41
--- /dev/null
+++ b/systemd/rpc-svcgssd.service
@@ -0,0 +1,15 @@
+[Unit]
+Description=3DRPC security service for NFS server
+Requires=3Dvar-lib-nfs-rpc_pipefs.mount
+After=3Dvar-lib-nfs-rpc_pipefs.mount
+PartOf=3Dnfs-server.service
+
+Requisite=3Dnfs-secure.target
+After=3Dnfs-secure.target
+
+[Service]
+EnvironmentFile=3D-/run/sysconfig/nfs-utils
+ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
+
+Type=3Dforking
+ExecStart=3D/usr/sbin/rpc.svcgssd $SVCGSSDARGS
diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs-rpc=
_pipefs.mount
new file mode 100644
index 000000000000..cd614cf49f00
--- /dev/null
+++ b/systemd/var-lib-nfs-rpc_pipefs.mount
@@ -0,0 +1,8 @@
+[Unit]
+Description=3DRPC Pipe File System
+DefaultDependencies=3Dno
+
+[Mount]
+What=3Dsunrpc
+Where=3D/var/lib/nfs/rpc_pipefs
+Type=3Drpc_pipefs
diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 1b345a547932..cde3583238e3 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -5,5 +5,8 @@
 # It should run statd with whatever flags are apropriate for this
 # site.
 PATH=3D/sbin:/usr/sbin
-exec rpc.statd --no-notify
-
+if systemctl start statd.service
+then :
+else
+    exec rpc.statd --no-notify
+fi

--Sig_/cHmrZrZy.NIkKZWQ/Qw+h6l
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUunwMznsnt1WYoG5AQK20w/+LaZiQxx2jgp5LUdujc6N9v8eaM92WEHB
if+IIM30i2B1wb+UEZ5RDQxdgTxlalK/ukz4PDv1o9Jxa+AJJxQ/EylbYb2kIVfV
v4z+e3KlTwycxsB2R51U9EJARzubSOnRl+pNFULQa+u/b7wqHd5maerjCOHiFy8J
MxWPYyYRDDBm4V4KlzIkVeuN4PDwVCX0aezjiGVcCQRgL0p8zpukm/HtttE1C6oF
+HOKL6+yuzsI+9xPujtuVHdJ4Oy5dClcWOLu9MvynEQbG9UBOEut6C3zMfhRW+Jj
u0/VWxPpkYKJmhPX4Mbz0W4ggymRkQ37d1irPDJJdImzRgoJEdhJHEluMv+FiSJc
LGZo2IVP746BBjultYXfeNckgcnex6sFKwy+HE60skdSaA43Ke6mxzOEPCHnsVL1
CsR/hPOMXNSyl8ctW+SIBY9CZocl4N46Cf9oPrF88hhZwbYrI6Aq0seWNcPET9f1
Dutsh2WmzeoGDeWppk7QJrSn0dygMISazO+/hRAoMUR63xONnI4vAPPNvbpEphso
V+GofHFCPHmKkrGy8cVLtYhdt7a1xwHlc5st79TekwUFiVxgVqmYiX8nPUed8DKd
enpoBEDDYgWJzyZHRl7O9kee0owxUO0DWiE5iCDCBensxUyDCpXPMTkGu6rhG3zr
75LUNkT+vHo=
=rd9E
-----END PGP SIGNATURE-----

--Sig_/cHmrZrZy.NIkKZWQ/Qw+h6l--
