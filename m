Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from kawka.in.waw.pl ([178.63.212.103]:38976 "EHLO kawka.in.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbbCOD5L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Mar 2015 23:57:11 -0400
From: =?UTF-8?q?Zbigniew=20J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: =?UTF-8?q?Zbigniew=20J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
Subject: [PATCH] units: nuke nfs-blkmap.target
Date: Sun, 15 Mar 2015 04:57:05 +0100
Message-Id: <1426391825-9218-1-git-send-email-zbyszek@in.waw.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems that the purpose of nfs-blkmap.target was to enable and
disable nfs-blkmap.service. This can be done directly by adding
an [Install] section in nfs-blkmap.service.

The downside of the previous arrangement, apart from the unnecessary
complexity, was a warning during boot:

 [ INFO ] PNFS blkmaping enablement. is not active.
 [DEPEND] Dependency failed for pNFS block layout mapping daemon.

https://bugzilla.redhat.com/show_bug.cgi?id=1088665

Signed-off-by: Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl>
---
 systemd/Makefile.am        | 1 -
 systemd/README             | 2 +-
 systemd/nfs-blkmap.service | 6 +++---
 systemd/nfs-blkmap.target  | 8 --------
 systemd/nfs-client.target  | 3 +--
 5 files changed, 5 insertions(+), 15 deletions(-)
 delete mode 100644 systemd/nfs-blkmap.target

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 16cf5e667f..fbcabb11e6 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -3,7 +3,6 @@
 MAINTAINERCLEANFILES = Makefile.in
 
 unit_files =  \
-    nfs-blkmap.target \
     nfs-client.target \
     \
     auth-rpcgss-module.service \
diff --git a/systemd/README b/systemd/README
index a2a5f06347..bbd7790ffb 100644
--- a/systemd/README
+++ b/systemd/README
@@ -24,7 +24,7 @@ by a suitable 'preset' setting:
     is started by /usr/sbin/start-statd which mount.nfs will run
     if statd is needed.
 
- nfs-blkmap.target
+ nfs-blkmap.service
     If enabled, then blkmapd will be run when nfs-client.target is
     started.
 
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index f470e3df9d..5b5a06dc98 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -5,12 +5,12 @@ Conflicts=umount.target
 After=var-lib-nfs-rpc_pipefs.mount
 Requires=var-lib-nfs-rpc_pipefs.mount
 
-Requisite=nfs-blkmap.target
-After=nfs-blkmap.target
-
 PartOf=nfs-utils.service
 
 [Service]
 Type=forking
 PIDFile=/var/run/blkmapd.pid
 ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
+
+[Install]
+WantedBy=nfs-client.target
diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
deleted file mode 100644
index fbcc111152..0000000000
--- a/systemd/nfs-blkmap.target
+++ /dev/null
@@ -1,8 +0,0 @@
-[Unit]
-Description= PNFS blkmaping enablement.
-# If this target is enabled, then blkmapd will be started
-# as required.  If it is not enabled it won't.
-
-[Install]
-WantedBy=remote-fs.target
-WantedBy=multi-user.target
\ No newline at end of file
diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
index 9b792a363e..8a8300a1df 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -5,8 +5,7 @@ Wants=remote-fs-pre.target
 
 # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
 # start that on demand if needed.
-Wants=nfs-blkmap.service rpc-statd-notify.service
-After=nfs-blkmap.service
+Wants=rpc-statd-notify.service
 
 # GSS services dependencies and ordering
 Wants=auth-rpcgss-module.service
-- 
2.1.0

