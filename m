Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 20.mo6.mail-out.ovh.net ([178.32.124.17]:47086 "EHLO
	20.mo6.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbGUJ3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2015 05:29:25 -0400
Received: from mail407.ha.ovh.net (gw6.ovh.net [213.251.189.206])
	by mo6.mail-out.ovh.net (Postfix) with SMTP id ED5AFFFCC87
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2015 23:41:38 +0200 (CEST)
From: =?UTF-8?q?Aur=C3=A9lien=20Chabot?= <aurelien@chabot.fr>
To: linux-nfs@vger.kernel.org
Cc: =?UTF-8?q?Aur=C3=A9lien=20Chabot?= <aurelien@chabot.fr>
Subject: [PATCH] Install only needed systemd unit file
Date: Mon, 20 Jul 2015 23:41:20 +0200
Message-Id: <1437428480-22951-1-git-send-email-aurelien@chabot.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aurélien Chabot <aurelien@chabot.fr>
---
 systemd/Makefile.am | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index fbcabb1..0331926 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -5,21 +5,33 @@ MAINTAINERCLEANFILES = Makefile.in
 unit_files =  \
     nfs-client.target \
     \
-    auth-rpcgss-module.service \
-    nfs-blkmap.service \
     nfs-config.service \
-    nfs-idmapd.service \
     nfs-mountd.service \
     nfs-server.service \
     nfs-utils.service \
-    rpc-gssd.service \
     rpc-statd-notify.service \
     rpc-statd.service \
-    rpc-svcgssd.service \
     \
     proc-fs-nfsd.mount \
     var-lib-nfs-rpc_pipefs.mount
 
+if CONFIG_NFSV4
+unit_files += \
+    nfs-idmapd.service
+endif
+
+if CONFIG_NFSV41
+unit_files += \
+    nfs-blkmap.service
+endif
+
+if CONFIG_GSS
+unit_files += \
+    auth-rpcgss-module.service \
+    rpc-gssd.service \
+    rpc-svcgssd.service
+endif
+
 EXTRA_DIST = $(unit_files)
 
 unit_dir = /usr/lib/systemd/system
-- 
2.4.6

