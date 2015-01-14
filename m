Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbbANPq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 10:46:56 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH 3/3] start-statd: Use the canonical to check if systemd is running.
Date: Wed, 14 Jan 2015 10:46:50 -0500
Message-Id: <1421250410-7246-4-git-send-email-steved@redhat.com>
In-Reply-To: <1421250410-7246-1-git-send-email-steved@redhat.com>
References: <1421250410-7246-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the approved way, define in
   http://www.freedesktop.org/software/systemd/man/sd_booted.html

to check if systemd is installed and running

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/statd/start-statd | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index ec9383b..b32b3a5 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -7,7 +7,7 @@
 PATH="/sbin:/usr/sbin:/bin:/usr/bin"
 
 # First try systemd if it's installed.
-if systemctl --help >/dev/null 2>&1; then
+if test -d /run/systemd/system; then
     # Quit only if the call worked.
     systemctl start rpc-statd.service && exit
 fi
-- 
2.1.0

