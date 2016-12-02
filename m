Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36597 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753253AbcLBEAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 23:00:12 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:30 +1100
Subject: [PATCH 14/15] systemd: Remove the nfs-config.service
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065111026.28046.13765788515171931087.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have /etc/nfs.conf, a lot of configuration can be
read directly.  So nfs-config isn't really needed any more.

Some distributions allow command-line arguments for various
daemons to be set in an environment file (/etc/sysconfig, /etc/defaults).
Passing these through /etc/nfs.conf is not possible.

Instead, a distro that needs this functionality can create drop-in
files which select the required value.  As no commands are given
default arguments by systemd unit files, the drop-in can just add
distro-specific args.
For example
  /lib/systemd/system/nfs-mountd.service.d/local.conf
   [Service]
   EnvironmentFile=/etc/sysconfig/nfs
   ExecStart=
   ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDOPTS

Note the need for the empty assignment to remove existing definitions
first.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 configure.ac                     |    6 ------
 systemd/Makefile.am              |    1 -
 systemd/README                   |   22 +++++++++++++++-------
 systemd/nfs-blkmap.service       |    3 +--
 systemd/nfs-config.service.in    |   13 -------------
 systemd/nfs-idmapd.service       |    6 +-----
 systemd/nfs-mountd.service       |    6 +-----
 systemd/nfs-server.service       |    7 +------
 systemd/rpc-gssd.service.in      |    7 +------
 systemd/rpc-statd-notify.service |    6 +-----
 systemd/rpc-statd.service        |    6 +-----
 systemd/rpc-svcgssd.service      |    6 +-----
 12 files changed, 23 insertions(+), 66 deletions(-)
 delete mode 100644 systemd/nfs-config.service.in

diff --git a/configure.ac b/configure.ac
index 8a5aa2e5203b..b3388a62fe30 100644
--- a/configure.ac
+++ b/configure.ac
@@ -518,11 +518,6 @@ AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 # Make sure that $ACLOCAL_FLAGS are used during a rebuild
 AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
 
-# make libexecdir available for substituion in config files
-# 2 "evals" needed late to expand variable names.
-AC_SUBST([_libexecdir])
-AC_CONFIG_COMMANDS_PRE([eval eval _libexecdir=$libexecdir])
-
 # make _sysconfdir available for substituion in config files
 # 2 "evals" needed late to expand variable names.
 AC_SUBST([_sysconfdir])
@@ -530,7 +525,6 @@ AC_CONFIG_COMMANDS_PRE([eval eval _sysconfdir=$sysconfdir])
 
 AC_CONFIG_FILES([
 	Makefile
-	systemd/nfs-config.service
 	systemd/rpc-gssd.service
 	linux-nfs/Makefile
 	support/Makefile
diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index b647ef00a0d1..b5ab157d728b 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -5,7 +5,6 @@ MAINTAINERCLEANFILES = Makefile.in
 unit_files =  \
     nfs-client.target \
     \
-    nfs-config.service \
     nfs-mountd.service \
     nfs-server.service \
     nfs-utils.service \
diff --git a/systemd/README b/systemd/README
index 7c43df88438a..da23d6f63a91 100644
--- a/systemd/README
+++ b/systemd/README
@@ -19,8 +19,8 @@ by a suitable 'preset' setting:
     can work (if no type is given, ".service" is assumed).
 
  nfs-client.target
-    If enabled, daemons needs for an nfs client are enabled.
-    This does *not* include rpc.statd.  the rpc-statd.service unit
+    If enabled, daemons needed for an nfs client are enabled.
+    This does *not* include rpc.statd.  The rpc-statd.service unit
     is started by /usr/sbin/start-statd which mount.nfs will run
     if statd is needed.
 
@@ -52,11 +52,19 @@ It cannot stop rpc.statd or rpc.gssd as they may be in use by the
 client and systemd cannot specify is two-pronged reverse dependency.
 (i.e. stop this unit if none of these units are running)
 
-Distro specific commandline configuration can be provided by
-installing a script /usr/libexec/nfs-utils/nfs-utils_env.sh
-This should write /run/sysconfig/nfs-utils based on configuration
-information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
-It is run once by nfs-config.service.
+Distro specific configuration can be included in /etc/nfs.conf, or
+by providing drop-in files which replace the ExecStart line for a given
+service, and possibly add an EnvironmentFile line.
+
+For example, if systemd/system/nfs-mountd.service.d/local.conf
+contained
+  [Service]
+  EnvironmentFile=/etc/sysconfig/nfs
+  ExecStart=
+  ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDOPTS
+
+then the setting of RPCMOUNTDOPTS in /etc/sysconfig/nfs would be
+passed to rpc.mountd.
 
 rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
 is present.
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index ddbf4e91da46..ddc324e70679 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -10,8 +10,7 @@ PartOf=nfs-utils.service
 [Service]
 Type=forking
 PIDFile=/var/run/blkmapd.pid
-EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
+ExecStart=/usr/sbin/blkmapd
 
 [Install]
 WantedBy=nfs-client.target
diff --git a/systemd/nfs-config.service.in b/systemd/nfs-config.service.in
deleted file mode 100644
index e89dc54209aa..000000000000
--- a/systemd/nfs-config.service.in
+++ /dev/null
@@ -1,13 +0,0 @@
-[Unit]
-Description=Preprocess NFS configuration
-After=local-fs.target
-DefaultDependencies=no
-
-[Service]
-Type=oneshot
-# This service needs to run any time any nfs service
-# is started, so changes to local config files get
-# incorporated.  Having "RemainAfterExit=no" (the default)
-# ensures this happens.
-RemainAfterExit=no
-ExecStart=@_libexecdir@/nfs-utils/nfs-utils_env.sh
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index df3dd9d8a856..acca86b683fb 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -6,10 +6,6 @@ After=var-lib-nfs-rpc_pipefs.mount local-fs.target
 
 BindsTo=nfs-server.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
+ExecStart=/usr/sbin/rpc.idmapd
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 8a39f3e21184..15e828bc0d3c 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -6,10 +6,6 @@ After=proc-fs-nfsd.mount
 After=network.target local-fs.target
 BindsTo=nfs-server.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
+ExecStart=/usr/sbin/rpc.mountd
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 196c81849ff4..5be5de65cf8a 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -16,16 +16,11 @@ Before= rpc-statd-notify.service
 Wants=auth-rpcgss-module.service
 After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-
 Type=oneshot
 RemainAfterExit=yes
 ExecStartPre=/usr/sbin/exportfs -r
-ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
+ExecStart=/usr/sbin/rpc.nfsd
 ExecStop=/usr/sbin/rpc.nfsd 0
 ExecStopPost=/usr/sbin/exportfs -au
 ExecStopPost=/usr/sbin/exportfs -f
diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
index 1a7911cb8f50..b35302740e37 100644
--- a/systemd/rpc-gssd.service.in
+++ b/systemd/rpc-gssd.service.in
@@ -9,11 +9,6 @@ ConditionPathExists=@_sysconfdir@/krb5.keytab
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-
 Type=forking
-ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
+ExecStart=/usr/sbin/rpc.gssd
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index 89ba36cf6d61..7bfc9b16d782 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -10,10 +10,6 @@ After=nfs-server.service
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=-/usr/sbin/sm-notify $SMNOTIFYARGS
+ExecStart=-/usr/sbin/sm-notify
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index d5392b7cff4d..60d600f2fae6 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -7,12 +7,8 @@ After=network.target nss-lookup.target rpcbind.socket
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
 Environment=RPC_STATD_NO_NOTIFY=1
-EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
 PIDFile=/var/run/rpc.statd.pid
-ExecStart=/usr/sbin/rpc.statd $STATDARGS
+ExecStart=/usr/sbin/rpc.statd
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 41177b60d141..7187e3c35a41 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -11,10 +11,6 @@ ConditionPathExists=|!/run/gssproxy.pid
 ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
 ConditionPathExists=/etc/krb5.keytab
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
+ExecStart=/usr/sbin/rpc.svcgssd


