Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:64316 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736Ab2HMOmh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 10:42:37 -0400
Received: by ghrr11 with SMTP id r11so3059993ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 07:42:36 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 2/2] blkmapd: proper signal handling
Date: Mon, 13 Aug 2012 22:41:55 +0800
Message-Id: <1344868915-1813-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344868915-1813-1-git-send-email-bergwolf@gmail.com>
References: <1344868915-1813-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 utils/blkmapd/device-discovery.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 8eddf50..df4627e 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -36,6 +36,7 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
 #include <scsi/sg.h>
+#include <signal.h>
 
 #include <stdlib.h>
 #include <stdio.h>
@@ -61,6 +62,7 @@
 
 struct bl_disk *visible_disk_list;
 int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
+int    pidfd = -1;
 
 struct bl_disk_path *bl_get_path(const char *filepath,
 				 struct bl_disk_path *paths)
@@ -431,10 +433,20 @@ static int bl_event_helper(void)
 	return ret;
 }
 
+void sig_die(int signal)
+{
+	if (pidfd >= 0) {
+		close(pidfd);
+		unlink(PID_FILE);
+	}
+	BL_LOG_ERR("exit on signal(%d)\n", signal);
+	exit(1);
+}
+
 /* Daemon */
 int main(int argc, char **argv)
 {
-	int pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
+	int opt, dflag = 0, fg = 0, ret = 1;
 	struct stat statbuf;
 	char pidbuf[64];
 
@@ -479,6 +491,10 @@ int main(int argc, char **argv)
 		write(pidfd, pidbuf, strlen(pidbuf));
 	}
 
+	signal(SIGINT, sig_die);
+	signal(SIGTERM, sig_die);
+	signal(SIGHUP, SIG_IGN);
+
 	if (dflag) {
 		bl_discover_devices();
 		exit(0);
-- 
1.7.1.262.g5ef3d

