Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551AbcCLMFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Mar 2016 07:05:50 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id D3136C00356E
	for <linux-nfs@vger.kernel.org>; Sat, 12 Mar 2016 12:05:49 +0000 (UTC)
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] systemd: remove the nfs-config service
Date: Sat, 12 Mar 2016 07:05:48 -0500
Message-Id: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs-config service exists to translate distro-specific startup
configuration into the command line arguments used by systemd to start nfs
utilities.  Unfortunately, it is not clear to most users that this service
must be recycled every time startup configurations have been modified, as
this requirement is a change for at least one distro.

We can get rid of nfs-config by generating the startup arguments in an
ExecStartPre option for each service that needs them.  We'll also have to
break out the EnvironmentFile into a separate file for each service to
avoid races overwriting this file.

A distro taking this change should also modify their
/usr/lib/systemd/scripts/nfs-utils_env.sh script to include the new
EnvironmentFile location for each service.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 systemd/Makefile.am              |    1 -
 systemd/README                   |    8 +++++---
 systemd/nfs-blkmap.service       |    4 +++-
 systemd/nfs-idmapd.service       |    7 +++----
 systemd/nfs-mountd.service       |    7 +++----
 systemd/nfs-server.service       |    7 +++----
 systemd/rpc-gssd.service         |    7 +++----
 systemd/rpc-statd-notify.service |    7 +++----
 systemd/rpc-statd.service        |    7 +++----
 systemd/rpc-svcgssd.service      |    7 +++----
 10 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 03f96e9..6f59dfc 100644
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
index bbd7790..1508ea7 100644
--- a/systemd/README
+++ b/systemd/README
@@ -54,9 +54,11 @@ client and systemd cannot specify is two-pronged reverse dependency.
 
 Distro specific commandline configuration can be provided by
 installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
-This should write /run/sysconfig/nfs-utils based on configuration
-information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
-It is run once by nfs-config.service.
+It will be provided the environment variable SERVICE with the short
+name of the service being started, and should write
+/run/sysconfig/nfs-utils-${SERVICE} based on configuration
+information such as in /etc/sysconfig/nfs or /etc/defaults/nfs. It
+is run just prior to starting each service.
 
 rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
 is present.
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index ddbf4e9..254b005 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -10,7 +10,9 @@ PartOf=nfs-utils.service
 [Service]
 Type=forking
 PIDFile=/var/run/blkmapd.pid
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=blkmapd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-blkmapd
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
 
 [Install]
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index df3dd9d..f58a58d 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -6,10 +6,9 @@ After=var-lib-nfs-rpc_pipefs.mount local-fs.target
 
 BindsTo=nfs-server.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=idmapd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-idmapd
 Type=forking
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 8a39f3e..5392429 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -6,10 +6,9 @@ After=proc-fs-nfsd.mount
 After=network.target local-fs.target
 BindsTo=nfs-server.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=mountd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-mountd
 Type=forking
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 317e5d6..493e41e 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -18,14 +18,13 @@ After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 # start/stop server before/after client
 Before=remote-fs-pre.target
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=nfsd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-nfsd
 
 Type=oneshot
 RemainAfterExit=yes
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStartPre=/usr/sbin/exportfs -r
 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
 ExecStop=/usr/sbin/rpc.nfsd 0
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index d4a3819..f945661 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -9,11 +9,10 @@ ConditionPathExists=/etc/krb5.keytab
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=gssd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-gssd
 
 Type=forking
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index 89ba36c..b33c92e 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -10,10 +10,9 @@ After=nfs-server.service
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=sm-notify"
+EnvironmentFile=-/run/sysconfig/nfs-utils-sm-notify
 Type=forking
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=-/usr/sbin/sm-notify $SMNOTIFYARGS
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index f16ea42..1af3bc8 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -7,11 +7,10 @@ After=network.target nss-lookup.target rpcbind.service
 
 PartOf=nfs-utils.service
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=statd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-statd
 Type=forking
 PIDFile=/var/run/rpc.statd.pid
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 41177b6..ace6ec5 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -11,10 +11,9 @@ ConditionPathExists=|!/run/gssproxy.pid
 ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
 ConditionPathExists=/etc/krb5.keytab
 
-Wants=nfs-config.service
-After=nfs-config.service
-
 [Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
+Environment="SERVICE=svcgssd"
+EnvironmentFile=-/run/sysconfig/nfs-utils-svcgssd
 Type=forking
+ExecStartPre=-/usr/lib/systemd/scripts/nfs-utils_env.sh
 ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
-- 
1.7.1

