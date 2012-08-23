Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50320 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab2HWQhF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 12:37:05 -0400
Received: by pbbrr13 with SMTP id rr13so1781864pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 09:37:05 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH-Resend 1/2] blkmapd: allow blocklayoutdriver module to load/unload
Date: Fri, 24 Aug 2012 00:36:31 +0800
Message-Id: <1345739792-2385-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

User may load/unload blocklayoutdriver module dynanmically.
So we handle it by watching the pipe file creation/deletion.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 configure.ac                     |    1 +
 utils/blkmapd/device-discovery.c |  104 ++++++++++++++++++++++++++++++-------
 2 files changed, 85 insertions(+), 20 deletions(-)

diff --git a/configure.ac b/configure.ac
index 18ee11a..a174bf4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -288,6 +288,7 @@ fi
 if test "$enable_nfsv41" = yes; then
   AC_CHECK_LIB([devmapper], [dm_task_create], [LIBDEVMAPPER="-ldevmapper"], AC_MSG_ERROR([libdevmapper needed]))
   AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find devmapper header file libdevmapper.h]))
+  AC_CHECK_HEADER(sys/inotify.h, , AC_MSG_ERROR([Cannot find header file sys/inotify.h]))
 fi
 
 dnl enable nfsidmap when its support by libnfsidmap
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index c21de3e..8eddf50 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -31,6 +31,7 @@
 #include <sys/ioctl.h>
 #include <sys/mount.h>
 #include <sys/select.h>
+#include <sys/inotify.h>
 #include <linux/kdev_t.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
@@ -50,10 +51,16 @@
 
 #include "device-discovery.h"
 
+#define EVENT_SIZE (sizeof(struct inotify_event))
+#define EVENT_BUFSIZE (1024 * EVENT_SIZE)
+
 #define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/nfs/blocklayout"
+#define NFSPIPE_DIR	"/var/lib/nfs/rpc_pipefs/nfs"
+#define RPCPIPE_DIR	"/var/lib/nfs/rpc_pipefs"
 #define PID_FILE	"/var/run/blkmapd.pid"
 
 struct bl_disk *visible_disk_list;
+int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
 
 struct bl_disk_path *bl_get_path(const char *filepath,
 				 struct bl_disk_path *paths)
@@ -262,7 +269,7 @@ int bl_discover_devices(void)
  * return 1: request processed, and more requests waiting;
  * return < 0: error
  */
-int bl_disk_inquiry_process(int fd)
+static int bl_disk_inquiry_process(int fd)
 {
 	int ret = 0;
 	struct bl_pipemsg_hdr head;
@@ -338,23 +345,70 @@ int bl_disk_inquiry_process(int fd)
 	return ret;
 }
 
-/* TODO: set bl_process_stop to 1 in command */
-unsigned int bl_process_stop;
+static void bl_watch_dir(const char* dir, int *wd)
+{
+	*wd = inotify_add_watch(bl_watch_fd, dir, IN_CREATE|IN_DELETE);
+	if (*wd < 0)
+		BL_LOG_ERR("failed to watch %s: %s\n", dir, strerror(errno));
+}
 
-int bl_run_disk_inquiry_process(int fd)
+static void bl_rpcpipe_cb(void)
 {
-	fd_set rset;
-	int ret;
+	int rc, curr_byte = 0;
+	char eventArr[EVENT_BUFSIZE];
+	struct inotify_event *event;
+
+	rc = read(bl_watch_fd, &eventArr, EVENT_BUFSIZE);
+	if (rc < 0)
+		BL_LOG_ERR("read event fail: %s", strerror(errno));
+
+	while (rc > curr_byte) {
+		event = (struct inotify_event *)&eventArr[curr_byte];
+		curr_byte += EVENT_SIZE + event->len;
+		if (event->wd == rpc_pipedir_wfd) {
+			if (strncmp(event->name, "nfs", 3))
+				continue;
+			if (event->mask & IN_CREATE) {
+				BL_LOG_WARNING("nfs pipe dir created\n");
+				bl_watch_dir(NFSPIPE_DIR, &nfs_pipedir_wfd);
+				bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
+			} else if (event->mask & IN_DELETE) {
+				BL_LOG_WARNING("nfs pipe dir deleted\n");
+				inotify_rm_watch(bl_watch_fd, nfs_pipedir_wfd);
+				close(bl_pipe_fd);
+				nfs_pipedir_wfd = -1;
+				bl_pipe_fd = -1;
+			}
+		} else if (event->wd == nfs_pipedir_wfd) {
+			if (strncmp(event->name, "blocklayout", 11))
+				continue;
+			if (event->mask & IN_CREATE) {
+				BL_LOG_WARNING("blocklayout pipe file created\n");
+				bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
+				if (bl_pipe_fd < 0)
+					BL_LOG_ERR("open %s failed: %s\n",
+						event->name, strerror(errno));
+			} else if (event->mask & IN_DELETE) {
+				BL_LOG_WARNING("blocklayout pipe file deleted\n");
+				close(bl_pipe_fd);
+				bl_pipe_fd = -1;
+			}
+		}
+	}
+}
 
-	bl_process_stop = 0;
+static int bl_event_helper(void)
+{
+	fd_set rset;
+	int ret = 0, maxfd;
 
 	for (;;) {
-		if (bl_process_stop)
-			return 1;
 		FD_ZERO(&rset);
-		FD_SET(fd, &rset);
-		ret = 0;
-		switch (select(fd + 1, &rset, NULL, NULL, NULL)) {
+		FD_SET(bl_watch_fd, &rset);
+		if (bl_pipe_fd > 0)
+			FD_SET(bl_pipe_fd, &rset);
+		maxfd = (bl_watch_fd>bl_pipe_fd)?bl_watch_fd:bl_pipe_fd;
+		switch (select(maxfd + 1, &rset, NULL, NULL, NULL)) {
 		case -1:
 			if (errno == EINTR)
 				continue;
@@ -365,8 +419,12 @@ int bl_run_disk_inquiry_process(int fd)
 		case 0:
 			goto out;
 		default:
-			if (FD_ISSET(fd, &rset))
-				ret = bl_disk_inquiry_process(fd);
+			if (FD_ISSET(bl_watch_fd, &rset))
+				bl_rpcpipe_cb();
+			else if (bl_pipe_fd > 0 && FD_ISSET(bl_pipe_fd, &rset))
+				ret = bl_disk_inquiry_process(bl_pipe_fd);
+			if (ret)
+				goto out;
 		}
 	}
  out:
@@ -376,7 +434,7 @@ int bl_run_disk_inquiry_process(int fd)
 /* Daemon */
 int main(int argc, char **argv)
 {
-	int fd, pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
+	int pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
 	struct stat statbuf;
 	char pidbuf[64];
 
@@ -426,18 +484,24 @@ int main(int argc, char **argv)
 		exit(0);
 	}
 
-	/* open pipe file */
-	fd = open(BL_PIPE_FILE, O_RDWR);
-	if (fd < 0) {
-		BL_LOG_ERR("open pipe file %s error\n", BL_PIPE_FILE);
+	if ((bl_watch_fd = inotify_init()) < 0) {
+		BL_LOG_ERR("init inotify failed %s\n", strerror(errno));
 		exit(1);
 	}
 
+	/* open pipe file */
+	bl_watch_dir(RPCPIPE_DIR, &rpc_pipedir_wfd);
+	bl_watch_dir(NFSPIPE_DIR, &nfs_pipedir_wfd);
+
+	bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
+	if (bl_pipe_fd < 0)
+		BL_LOG_ERR("open pipe file %s failed: %s\n", BL_PIPE_FILE, strerror(errno));
+
 	while (1) {
 		/* discover device when needed */
 		bl_discover_devices();
 
-		ret = bl_run_disk_inquiry_process(fd);
+		ret = bl_event_helper();
 		if (ret < 0) {
 			/* what should we do with process error? */
 			BL_LOG_ERR("inquiry process return %d\n", ret);
-- 
1.7.1.262.g5ef3d

