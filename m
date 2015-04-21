Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33834 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbbDURns (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 13:43:48 -0400
Received: by iedfl3 with SMTP id fl3so21855478ied.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 10:43:48 -0700 (PDT)
From: Calvin Walton <calvin.walton@kepstin.ca>
To: linux-nfs@vger.kernel.org
Cc: Calvin Walton <calvin.walton@kepstin.ca>
Subject: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
Date: Tue, 21 Apr 2015 13:43:43 -0400
Message-Id: <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
In-Reply-To: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The systemd unit files now include the correct full paths to the
executables when nfs-utils is configured with an alternate value
for e.g. --prefix or --sbindir

Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
---

Resend of the same patch, but this time generated with -M so the diff
includes file moves; this should make it a bit easier to review.

 .gitignore                                         |  8 ++++++
 systemd/Makefile.am                                | 31 ++++++++++++----------
 .../{nfs-blkmap.service => nfs-blkmap.service.in}  |  2 +-
 .../{nfs-idmapd.service => nfs-idmapd.service.in}  |  2 +-
 .../{nfs-mountd.service => nfs-mountd.service.in}  |  2 +-
 .../{nfs-server.service => nfs-server.service.in}  | 12 ++++-----
 systemd/{rpc-gssd.service => rpc-gssd.service.in}  |  2 +-
 ...-notify.service => rpc-statd-notify.service.in} |  2 +-
 .../{rpc-statd.service => rpc-statd.service.in}    |  2 +-
 ...{rpc-svcgssd.service => rpc-svcgssd.service.in} |  2 +-
 10 files changed, 38 insertions(+), 27 deletions(-)
 rename systemd/{nfs-blkmap.service => nfs-blkmap.service.in} (88%)
 rename systemd/{nfs-idmapd.service => nfs-idmapd.service.in} (86%)
 rename systemd/{nfs-mountd.service => nfs-mountd.service.in} (86%)
 rename systemd/{nfs-server.service => nfs-server.service.in} (78%)
 rename systemd/{rpc-gssd.service => rpc-gssd.service.in} (90%)
 rename systemd/{rpc-statd-notify.service => rpc-statd-notify.service.in} (90%)
 rename systemd/{rpc-statd.service => rpc-statd.service.in} (87%)
 rename systemd/{rpc-svcgssd.service => rpc-svcgssd.service.in} (91%)

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
diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service.in
similarity index 88%
rename from systemd/nfs-blkmap.service
rename to systemd/nfs-blkmap.service.in
index ddbf4e9..37e843d 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service.in
@@ -11,7 +11,7 @@ PartOf=nfs-utils.service
 Type=forking
 PIDFile=/var/run/blkmapd.pid
 EnvironmentFile=-/run/sysconfig/nfs-utils
-ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
+ExecStart=@sbindir@/blkmapd $BLKMAPDARGS
 
 [Install]
 WantedBy=nfs-client.target
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service.in
similarity index 86%
rename from systemd/nfs-idmapd.service
rename to systemd/nfs-idmapd.service.in
index df3dd9d..c081cc8 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service.in
@@ -12,4 +12,4 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
+ExecStart=@sbindir@/rpc.idmapd $RPCIDMAPDARGS
diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service.in
similarity index 86%
rename from systemd/nfs-mountd.service
rename to systemd/nfs-mountd.service.in
index 8a39f3e..9b210b4 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service.in
@@ -12,4 +12,4 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
+ExecStart=@sbindir@/rpc.mountd $RPCMOUNTDARGS
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service.in
similarity index 78%
rename from systemd/nfs-server.service
rename to systemd/nfs-server.service.in
index db801cb..24239ce 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service.in
@@ -26,13 +26,13 @@ EnvironmentFile=-/run/sysconfig/nfs-utils
 
 Type=oneshot
 RemainAfterExit=yes
-ExecStartPre=/usr/sbin/exportfs -r
-ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
-ExecStop=/usr/sbin/rpc.nfsd 0
-ExecStopPost=/usr/sbin/exportfs -au
-ExecStopPost=/usr/sbin/exportfs -f
+ExecStartPre=@sbindir@/exportfs -r
+ExecStart=@sbindir@/rpc.nfsd $RPCNFSDARGS
+ExecStop=@sbindir@/rpc.nfsd 0
+ExecStopPost=@sbindir@/exportfs -au
+ExecStopPost=@sbindir@/exportfs -f
 
-ExecReload=/usr/sbin/exportfs -r
+ExecReload=@sbindir@/exportfs -r
 
 [Install]
 WantedBy=multi-user.target
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service.in
similarity index 90%
rename from systemd/rpc-gssd.service
rename to systemd/rpc-gssd.service.in
index d4a3819..52b2ce9 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service.in
@@ -16,4 +16,4 @@ After=nfs-config.service
 EnvironmentFile=-/run/sysconfig/nfs-utils
 
 Type=forking
-ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
+ExecStart=@sbindir@/rpc.gssd $GSSDARGS
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service.in
similarity index 90%
rename from systemd/rpc-statd-notify.service
rename to systemd/rpc-statd-notify.service.in
index 89ba36c..81003ec 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service.in
@@ -16,4 +16,4 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=-/usr/sbin/sm-notify $SMNOTIFYARGS
+ExecStart=-@sbindir@/sm-notify $SMNOTIFYARGS
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service.in
similarity index 87%
rename from systemd/rpc-statd.service
rename to systemd/rpc-statd.service.in
index 14604d7..d76032e 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service.in
@@ -14,4 +14,4 @@ After=nfs-config.service
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
 PIDFile=/var/run/rpc.statd.pid
-ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
+ExecStart=@sbindir@/rpc.statd --no-notify $STATDARGS
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service.in
similarity index 91%
rename from systemd/rpc-svcgssd.service
rename to systemd/rpc-svcgssd.service.in
index 41177b6..cbedc67 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service.in
@@ -17,4 +17,4 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
-ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
+ExecStart=@sbindir@/rpc.svcgssd $SVCGSSDARGS
-- 
2.3.3

