Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36390 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbbDURke (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 13:40:34 -0400
Received: by igblo3 with SMTP id lo3so92870029igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 10:40:33 -0700 (PDT)
From: Calvin Walton <calvin.walton@kepstin.ca>
To: linux-nfs@vger.kernel.org
Cc: Calvin Walton <calvin.walton@kepstin.ca>
Subject: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
Date: Tue, 21 Apr 2015 13:40:29 -0400
Message-Id: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The systemd unit files now include the correct full paths to the
executables when nfs-utils is configured with an alternate value
for e.g. --prefix or --sbindir

Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
---
 .gitignore                          |  8 ++++++++
 systemd/Makefile.am                 | 31 ++++++++++++++++--------------
 systemd/nfs-blkmap.service          | 17 -----------------
 systemd/nfs-blkmap.service.in       | 17 +++++++++++++++++
 systemd/nfs-idmapd.service          | 15 ---------------
 systemd/nfs-idmapd.service.in       | 15 +++++++++++++++
 systemd/nfs-mountd.service          | 15 ---------------
 systemd/nfs-mountd.service.in       | 15 +++++++++++++++
 systemd/nfs-server.service          | 38 -------------------------------------
 systemd/nfs-server.service.in       | 38 +++++++++++++++++++++++++++++++++++++
 systemd/rpc-gssd.service            | 19 -------------------
 systemd/rpc-gssd.service.in         | 19 +++++++++++++++++++
 systemd/rpc-statd-notify.service    | 19 -------------------
 systemd/rpc-statd-notify.service.in | 19 +++++++++++++++++++
 systemd/rpc-statd.service           | 17 -----------------
 systemd/rpc-statd.service.in        | 17 +++++++++++++++++
 systemd/rpc-svcgssd.service         | 20 -------------------
 systemd/rpc-svcgssd.service.in      | 20 +++++++++++++++++++
 18 files changed, 185 insertions(+), 174 deletions(-)
 delete mode 100644 systemd/nfs-blkmap.service
 create mode 100644 systemd/nfs-blkmap.service.in
 delete mode 100644 systemd/nfs-idmapd.service
 create mode 100644 systemd/nfs-idmapd.service.in
 delete mode 100644 systemd/nfs-mountd.service
 create mode 100644 systemd/nfs-mountd.service.in
 delete mode 100644 systemd/nfs-server.service
 create mode 100644 systemd/nfs-server.service.in
 delete mode 100644 systemd/rpc-gssd.service
 create mode 100644 systemd/rpc-gssd.service.in
 delete mode 100644 systemd/rpc-statd-notify.service
 create mode 100644 systemd/rpc-statd-notify.service.in
 delete mode 100644 systemd/rpc-statd.service
 create mode 100644 systemd/rpc-statd.service.in
 delete mode 100644 systemd/rpc-svcgssd.service
 create mode 100644 systemd/rpc-svcgssd.service.in

diff --git a/.gitignore b/.gitignore
index 5164637..4776b04 100644
--- a/.gitignore
+++ b/.gitignore
@@ -69,6 +69,14 @@ tests/nsm_client/nlm_sm_inter_clnt.c
 tests/nsm_client/nlm_sm_inter_svc.c
 tests/nsm_client/nlm_sm_inter_xdr.c
 utils/nfsidmap/nfsidmap
+systemd/nfs-blkmap.service
+systemd/nfs-idmapd.service
+systemd/nfs-mountd.service
+systemd/nfs-server.service
+systemd/rpc-gssd.service
+systemd/rpc-statd-notify.service
+systemd/rpc-statd.service
+systemd/rpc-svcgssd.service
 # cscope database files
 cscope.*
 # generic editor backup et al
diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index fbcabb1..ec7e09b 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -2,30 +2,33 @@
 
 MAINTAINERCLEANFILES = Makefile.in
 
-unit_files =  \
+if INSTALL_SYSTEMD
+dist_unit_DATA = \
     nfs-client.target \
     \
     auth-rpcgss-module.service \
-    nfs-blkmap.service \
     nfs-config.service \
+    nfs-utils.service \
+    \
+    proc-fs-nfsd.mount \
+    var-lib-nfs-rpc_pipefs.mount
+
+unit_DATA = \
+    nfs-blkmap.service \
     nfs-idmapd.service \
     nfs-mountd.service \
     nfs-server.service \
-    nfs-utils.service \
     rpc-gssd.service \
     rpc-statd-notify.service \
     rpc-statd.service \
-    rpc-svcgssd.service \
-    \
-    proc-fs-nfsd.mount \
-    var-lib-nfs-rpc_pipefs.mount
+    rpc-svcgssd.service
 
-EXTRA_DIST = $(unit_files)
+CLEANFILES = $(unit_DATA)
 
-unit_dir = /usr/lib/systemd/system
-
-if INSTALL_SYSTEMD
-install-data-hook: $(unit_files)
-	mkdir -p $(DESTDIR)/$(unitdir)
-	cp $(unit_files) $(DESTDIR)/$(unitdir)
+EXTRA_DIST = $(unit_DATA:service=.service.in)
 endif
+
+SUFFIXES = .service.in .service
+.service.in.service:
+	$(SED) -e 's,[@]sbindir[@],$(sbindir),g' \
+		< $< > $@
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
deleted file mode 100644
index ddbf4e9..0000000
--- a/systemd/nfs-blkmap.service
+++ /dev/null
@@ -1,17 +0,0 @@
-[Unit]
-Description=pNFS block layout mapping daemon
-DefaultDependencies=no
-Conflicts=umount.target
-After=var-lib-nfs-rpc_pipefs.mount
-Requires=var-lib-nfs-rpc_pipefs.mount
-
-PartOf=nfs-utils.service
-
-[Service]
-Type=forking
-PIDFile=/var/run/blkmapd.pid
-EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
-
-[Install]
-WantedBy=nfs-client.target
diff --git a/systemd/nfs-blkmap.service.in b/systemd/nfs-blkmap.service.in
new file mode 100644
index 0000000..37e843d
--- /dev/null
+++ b/systemd/nfs-blkmap.service.in
@@ -0,0 +1,17 @@
+[Unit]
+Description=pNFS block layout mapping daemon
+DefaultDependencies=no
+Conflicts=umount.target
+After=var-lib-nfs-rpc_pipefs.mount
+Requires=var-lib-nfs-rpc_pipefs.mount
+
+PartOf=nfs-utils.service
+
+[Service]
+Type=forking
+PIDFile=/var/run/blkmapd.pid
+EnvironmentFile=-/run/sysconfig/nfs-utils
+ExecStart=@sbindir@/blkmapd $BLKMAPDARGS
+
+[Install]
+WantedBy=nfs-client.target
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
deleted file mode 100644
index df3dd9d..0000000
--- a/systemd/nfs-idmapd.service
+++ /dev/null
@@ -1,15 +0,0 @@
-[Unit]
-Description=NFSv4 ID-name mapping service
-DefaultDependencies=no
-Requires=var-lib-nfs-rpc_pipefs.mount
-After=var-lib-nfs-rpc_pipefs.mount local-fs.target
-
-BindsTo=nfs-server.service
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-idmapd.service.in b/systemd/nfs-idmapd.service.in
new file mode 100644
index 0000000..c081cc8
--- /dev/null
+++ b/systemd/nfs-idmapd.service.in
@@ -0,0 +1,15 @@
+[Unit]
+Description=NFSv4 ID-name mapping service
+DefaultDependencies=no
+Requires=var-lib-nfs-rpc_pipefs.mount
+After=var-lib-nfs-rpc_pipefs.mount local-fs.target
+
+BindsTo=nfs-server.service
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+Type=forking
+ExecStart=@sbindir@/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
deleted file mode 100644
index 8a39f3e..0000000
--- a/systemd/nfs-mountd.service
+++ /dev/null
@@ -1,15 +0,0 @@
-[Unit]
-Description=NFS Mount Daemon
-DefaultDependencies=no
-Requires=proc-fs-nfsd.mount
-After=proc-fs-nfsd.mount
-After=network.target local-fs.target
-BindsTo=nfs-server.service
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-mountd.service.in b/systemd/nfs-mountd.service.in
new file mode 100644
index 0000000..9b210b4
--- /dev/null
+++ b/systemd/nfs-mountd.service.in
@@ -0,0 +1,15 @@
+[Unit]
+Description=NFS Mount Daemon
+DefaultDependencies=no
+Requires=proc-fs-nfsd.mount
+After=proc-fs-nfsd.mount
+After=network.target local-fs.target
+BindsTo=nfs-server.service
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+Type=forking
+ExecStart=@sbindir@/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
deleted file mode 100644
index db801cb..0000000
--- a/systemd/nfs-server.service
+++ /dev/null
@@ -1,38 +0,0 @@
-[Unit]
-Description=NFS server and services
-DefaultDependencies=no
-Requires= network.target proc-fs-nfsd.mount rpcbind.target
-Requires= nfs-mountd.service
-Wants=rpc-statd.service nfs-idmapd.service
-Wants=rpc-statd-notify.service
-
-After= local-fs.target
-After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
-After= nfs-idmapd.service rpc-statd.service
-Before= rpc-statd-notify.service
-
-# GSS services dependencies and ordering
-Wants=auth-rpcgss-module.service
-After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
-
-# start/stop server before/after client
-Before=remote-fs-pre.target
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-
-Type=oneshot
-RemainAfterExit=yes
-ExecStartPre=/usr/sbin/exportfs -r
-ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
-ExecStop=/usr/sbin/rpc.nfsd 0
-ExecStopPost=/usr/sbin/exportfs -au
-ExecStopPost=/usr/sbin/exportfs -f
-
-ExecReload=/usr/sbin/exportfs -r
-
-[Install]
-WantedBy=multi-user.target
diff --git a/systemd/nfs-server.service.in b/systemd/nfs-server.service.in
new file mode 100644
index 0000000..24239ce
--- /dev/null
+++ b/systemd/nfs-server.service.in
@@ -0,0 +1,38 @@
+[Unit]
+Description=NFS server and services
+DefaultDependencies=no
+Requires= network.target proc-fs-nfsd.mount rpcbind.target
+Requires= nfs-mountd.service
+Wants=rpc-statd.service nfs-idmapd.service
+Wants=rpc-statd-notify.service
+
+After= local-fs.target
+After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
+After= nfs-idmapd.service rpc-statd.service
+Before= rpc-statd-notify.service
+
+# GSS services dependencies and ordering
+Wants=auth-rpcgss-module.service
+After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
+
+# start/stop server before/after client
+Before=remote-fs-pre.target
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+
+Type=oneshot
+RemainAfterExit=yes
+ExecStartPre=@sbindir@/exportfs -r
+ExecStart=@sbindir@/rpc.nfsd $RPCNFSDARGS
+ExecStop=@sbindir@/rpc.nfsd 0
+ExecStopPost=@sbindir@/exportfs -au
+ExecStopPost=@sbindir@/exportfs -f
+
+ExecReload=@sbindir@/exportfs -r
+
+[Install]
+WantedBy=multi-user.target
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
deleted file mode 100644
index d4a3819..0000000
--- a/systemd/rpc-gssd.service
+++ /dev/null
@@ -1,19 +0,0 @@
-[Unit]
-Description=RPC security service for NFS client and server
-DefaultDependencies=no
-Conflicts=umount.target
-Requires=var-lib-nfs-rpc_pipefs.mount
-After=var-lib-nfs-rpc_pipefs.mount
-
-ConditionPathExists=/etc/krb5.keytab
-
-PartOf=nfs-utils.service
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-
-Type=forking
-ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
new file mode 100644
index 0000000..52b2ce9
--- /dev/null
+++ b/systemd/rpc-gssd.service.in
@@ -0,0 +1,19 @@
+[Unit]
+Description=RPC security service for NFS client and server
+DefaultDependencies=no
+Conflicts=umount.target
+Requires=var-lib-nfs-rpc_pipefs.mount
+After=var-lib-nfs-rpc_pipefs.mount
+
+ConditionPathExists=/etc/krb5.keytab
+
+PartOf=nfs-utils.service
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+
+Type=forking
+ExecStart=@sbindir@/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
deleted file mode 100644
index 89ba36c..0000000
--- a/systemd/rpc-statd-notify.service
+++ /dev/null
@@ -1,19 +0,0 @@
-[Unit]
-Description=Notify NFS peers of a restart
-DefaultDependencies=no
-Requires=network.target
-After=local-fs.target network.target nss-lookup.target
-
-# if we run an nfs server, it needs to be running before we
-# tell clients that it has restarted.
-After=nfs-server.service
-
-PartOf=nfs-utils.service
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-ExecStart=-/usr/sbin/sm-notify $SMNOTIFYARGS
diff --git a/systemd/rpc-statd-notify.service.in b/systemd/rpc-statd-notify.service.in
new file mode 100644
index 0000000..81003ec
--- /dev/null
+++ b/systemd/rpc-statd-notify.service.in
@@ -0,0 +1,19 @@
+[Unit]
+Description=Notify NFS peers of a restart
+DefaultDependencies=no
+Requires=network.target
+After=local-fs.target network.target nss-lookup.target
+
+# if we run an nfs server, it needs to be running before we
+# tell clients that it has restarted.
+After=nfs-server.service
+
+PartOf=nfs-utils.service
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+Type=forking
+ExecStart=-@sbindir@/sm-notify $SMNOTIFYARGS
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
deleted file mode 100644
index 14604d7..0000000
--- a/systemd/rpc-statd.service
+++ /dev/null
@@ -1,17 +0,0 @@
-[Unit]
-Description=NFS status monitor for NFSv2/3 locking.
-DefaultDependencies=no
-Conflicts=umount.target
-Requires=nss-lookup.target rpcbind.target
-After=network.target nss-lookup.target rpcbind.target
-
-PartOf=nfs-utils.service
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-PIDFile=/var/run/rpc.statd.pid
-ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-statd.service.in b/systemd/rpc-statd.service.in
new file mode 100644
index 0000000..d76032e
--- /dev/null
+++ b/systemd/rpc-statd.service.in
@@ -0,0 +1,17 @@
+[Unit]
+Description=NFS status monitor for NFSv2/3 locking.
+DefaultDependencies=no
+Conflicts=umount.target
+Requires=nss-lookup.target rpcbind.target
+After=network.target nss-lookup.target rpcbind.target
+
+PartOf=nfs-utils.service
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+Type=forking
+PIDFile=/var/run/rpc.statd.pid
+ExecStart=@sbindir@/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
deleted file mode 100644
index 41177b6..0000000
--- a/systemd/rpc-svcgssd.service
+++ /dev/null
@@ -1,20 +0,0 @@
-[Unit]
-Description=RPC security service for NFS server
-DefaultDependencies=no
-Requires=var-lib-nfs-rpc_pipefs.mount
-After=var-lib-nfs-rpc_pipefs.mount local-fs.target
-PartOf=nfs-server.service
-PartOf=nfs-utils.service
-
-After=gssproxy.service
-ConditionPathExists=|!/run/gssproxy.pid
-ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
-ConditionPathExists=/etc/krb5.keytab
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
diff --git a/systemd/rpc-svcgssd.service.in b/systemd/rpc-svcgssd.service.in
new file mode 100644
index 0000000..cbedc67
--- /dev/null
+++ b/systemd/rpc-svcgssd.service.in
@@ -0,0 +1,20 @@
+[Unit]
+Description=RPC security service for NFS server
+DefaultDependencies=no
+Requires=var-lib-nfs-rpc_pipefs.mount
+After=var-lib-nfs-rpc_pipefs.mount local-fs.target
+PartOf=nfs-server.service
+PartOf=nfs-utils.service
+
+After=gssproxy.service
+ConditionPathExists=|!/run/gssproxy.pid
+ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
+ConditionPathExists=/etc/krb5.keytab
+
+Wants=nfs-config.service
+After=nfs-config.service
+
+[Service]
+EnvironmentFile=-/run/sysconfig/nfs-utils
+Type=forking
+ExecStart=@sbindir@/rpc.svcgssd $SVCGSSDARGS
-- 
2.3.3

