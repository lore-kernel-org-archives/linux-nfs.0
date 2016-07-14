Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36473 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbcGNCva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2016 22:51:30 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so498645pab.3
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 19:51:30 -0700 (PDT)
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/2] blkmapd: unlink pid file when error out
Message-ID: <90d4ca22-1ec0-3cba-263f-7a3cdd871b28@gmail.com>
Date: Thu, 14 Jul 2016 10:51:22 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix some error out without unlink pid file.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/blkmapd/device-discovery.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 50e2746..8eb3fd0 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -486,13 +486,13 @@ int main(int argc, char **argv)
 	signal(SIGHUP, SIG_IGN);
 
 	if (dflag) {
-		bl_discover_devices();
-		exit(0);
+		ret = bl_discover_devices();
+		goto out;
 	}
 
 	if ((bl_watch_fd = inotify_init()) < 0) {
 		BL_LOG_ERR("init inotify failed %s\n", strerror(errno));
-		exit(1);
+		goto out;
 	}
 
 	/* open pipe file */
@@ -513,7 +513,7 @@ int main(int argc, char **argv)
 			BL_LOG_ERR("inquiry process return %d\n", ret);
 		}
 	}
-
+out:
 	if (pidfd >= 0) {
 		close(pidfd);
 		unlink(PID_FILE);
-- 
2.7.4

