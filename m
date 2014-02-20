Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43500 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbaBTG40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:26 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 2/6] systemd units: create nfs-config.service as single
 location to process config.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.61569.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of processing the config information into command lines every
time it might be needed, do it once in a separate service that other
services can Want.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/README                   |    3 +--
 systemd/nfs-config.service       |    7 +++++++
 systemd/nfs-idmapd.service       |    5 +++--
 systemd/nfs-mountd.service       |    5 +++--
 systemd/nfs-server.service       |    4 +++-
 systemd/rpc-gssd.service         |    4 +++-
 systemd/rpc-statd-notify.service |    5 +++--
 systemd/rpc-statd.service        |    5 +++--
 systemd/rpc-svcgssd.service      |    5 +++--
 9 files changed, 29 insertions(+), 14 deletions(-)
 create mode 100644 systemd/nfs-config.service

diff --git a/systemd/README b/systemd/README
index 8359530098f4..a2a5f0634726 100644
--- a/systemd/README
+++ b/systemd/README
@@ -56,8 +56,7 @@ Distro specific commandline configuration can be provided by
 installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
 This should write /run/sysconfig/nfs-utils based on configuration
 information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
-It should write to a tmp file and rename to the target to
-avoid parallel units seeing incomplete copies of the file.
+It is run once by nfs-config.service.
 
 rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
 is present.
diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
new file mode 100644
index 000000000000..4cf2ecc76e4a
--- /dev/null
+++ b/systemd/nfs-config.service
@@ -0,0 +1,7 @@
+[Unit]
+Description=Preprocess NFS configuration
+
+[Service]
+type=oneshot
+RemainAfterExit=yes
+ExecStart=/usr/lib/systemd/scripts/nfs-utils_env.sh
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index 7d0dd84d8a44..11895e234438 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -3,9 +3,10 @@ Description=NFSv4 ID-name mapping service
 
 PartOf=nfs-utils.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
-
 Type=forking
 ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 90746a854b40..7ccc0f72012d 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -6,9 +6,10 @@ After=network.target
 PartOf=nfs-server.service
 PartOf=nfs-utils.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
-
 Type=forking
 ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 5779fd39ed34..2fa7387e1cb9 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -10,9 +10,11 @@ After= nfs-idmapd.service rpc-statd.service
 After= rpc-gssd.service rpc-svcgssd.service
 Before= rpc-statd-notify.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
 
 Type=oneshot
 RemainAfterExit=yes
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index 375792804247..d4a381904de4 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -9,9 +9,11 @@ ConditionPathExists=/etc/krb5.keytab
 
 PartOf=nfs-utils.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
 
 Type=forking
 ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index 7742ac8c5d9a..6b13b323e758 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -9,10 +9,11 @@ After=nfs-server.service
 
 PartOf=nfs-utils.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=/usr/lib/systemd/scritps/nfs-utils_env.sh
-
 Type=oneshot
 RemainAfterExit=yes
 ExecStart=-/usr/sbin/sm-notify -d $SMNOTIFYARGS
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 3f6cda16accd..c5795fd68f96 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -7,9 +7,10 @@ After=network.target nss-lookup.target rpcbind.target
 
 PartOf=nfs-utils.service
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
-
 Type=forking
 ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 6bd45884d991..32b786ec5c7d 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -10,9 +10,10 @@ ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
 ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
 ConditionPathExists=/etc/krb5.keytab
 
+Wants=nfs-config.service
+After=nfs-config.service
+
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
-
 Type=forking
 ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS


