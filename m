Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:43741 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbaHQOoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Aug 2014 10:44:13 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 19EA8340004
	for <linux-nfs@vger.kernel.org>; Sun, 17 Aug 2014 14:44:08 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] start-statd: clean up output when systemd is not installed
Date: Sun, 17 Aug 2014 10:44:08 -0400
Message-Id: <1408286648-19031-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you don't have systemd, then this script dumps:
/usr/sbin/start-statd: line 8: systemctl: command not found

This isn't terribly useful since we ultimately fall back to running
the daemon ourselves, so probe for systemd's existence before we try
to use it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 utils/statd/start-statd | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)
 mode change 100644 => 100755 utils/statd/start-statd

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
old mode 100644
new mode 100755
index dcdaf77..ec9383b
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -1,12 +1,16 @@
-#!/bin/bash -p
+#!/bin/sh
 # nfsmount calls this script when mounting a filesystem with locking
 # enabled, but when statd does not seem to be running (based on
 # /var/run/rpc.statd.pid).
 # It should run statd with whatever flags are apropriate for this
 # site.
 PATH="/sbin:/usr/sbin:/bin:/usr/bin"
-if systemctl start rpc-statd.service
-then :
-else
-    exec rpc.statd --no-notify
+
+# First try systemd if it's installed.
+if systemctl --help >/dev/null 2>&1; then
+    # Quit only if the call worked.
+    systemctl start rpc-statd.service && exit
 fi
+
+# Fall back to launching it ourselves.
+exec rpc.statd --no-notify
-- 
2.0.0

