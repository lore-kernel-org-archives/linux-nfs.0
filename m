Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:43920 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab0KBUKp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:10:45 -0400
Date: Tue, 2 Nov 2010 16:10:42 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 5/6] add "-d" option to just do discovery then exit
Message-ID: <162b681df7912e12c89948261775da5bf5b67a89.1288726186.git.rees@umich.edu>
References: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.c |   69 +++++++++++++++++++++----------------
 1 files changed, 39 insertions(+), 30 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index c8bd39c..6b1f942 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -398,54 +398,63 @@ int bl_run_disk_inquiry_process(int fd)
 /* Daemon */
 int main(int argc, char **argv)
 {
-	int fd, opt, fg = 0, ret = 1;
+	int fd = -1, opt, dflag = 0, fg = 0, ret = 1;
 	struct stat statbuf;
 	char pidbuf[64];
 
-	while ((opt = getopt(argc, argv, "f")) != -1) {
+	while ((opt = getopt(argc, argv, "df")) != -1) {
 		switch (opt) {
+		case 'd':
+			dflag = 1;
+			break;
 		case 'f':
 			fg = 1;
 			break;
 		}
 	}
 
-	if (!stat(PID_FILE, &statbuf)) {
-		fprintf(stderr, "Pid file already existed\n");
-		return -1;
-	}
+	if (fg) {
+		openlog("blkmapd", LOG_PERROR, 0);
+	} else {
+		if (!stat(PID_FILE, &statbuf)) {
+			fprintf(stderr, "Pid file already existed\n");
+			return -1;
+		}
 
-	if (!fg && daemon(0, 0) != 0) {
-		fprintf(stderr, "Daemonize failed\n");
-		return -1;
-	}
+		if (daemon(0, 0) != 0) {
+			fprintf(stderr, "Daemonize failed\n");
+			return -1;
+		}
 
-	openlog("blkmapd", LOG_PID, 0);
-	fd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
-	if (fd < 0) {
-		BL_LOG_ERR("Create pid file failed\n");
-		return -1;
-	}
+		openlog("blkmapd", LOG_PID, 0);
+		fd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
+		if (fd < 0) {
+			BL_LOG_ERR("Create pid file failed\n");
+			return -1;
+		}
 
-	if (lockf(fd, F_TLOCK, 0) < 0) {
-		BL_LOG_ERR("Lock pid file failed\n");
-		close(fd);
-		return -1;
-	}
-	ftruncate(fd, 0);
-	sprintf(pidbuf, "%d\n", getpid());
-	write(fd, pidbuf, strlen(pidbuf));
-
-	/* open pipe file */
-	fd = open(BL_PIPE_FILE, O_RDWR);
-	if (fd < 0) {
-		BL_LOG_ERR("open pipe file error\n");
-		return -1;
+		if (lockf(fd, F_TLOCK, 0) < 0) {
+			BL_LOG_ERR("Lock pid file failed\n");
+			close(fd);
+			return -1;
+		}
+		ftruncate(fd, 0);
+		sprintf(pidbuf, "%d\n", getpid());
+		write(fd, pidbuf, strlen(pidbuf));
+
+		/* open pipe file */
+		fd = open(BL_PIPE_FILE, O_RDWR);
+		if (fd < 0) {
+			BL_LOG_ERR("open pipe file error\n");
+			return -1;
+		}
 	}
 
 	while (1) {
 		/* discover device when needed */
 		bl_discover_devices();
+		if (dflag)
+			break;
 
 		ret = bl_run_disk_inquiry_process(fd);
 		if (ret < 0) {
-- 
1.7.1

