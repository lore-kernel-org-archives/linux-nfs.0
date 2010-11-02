Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:45939 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab0KBUKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:10:13 -0400
Date: Tue, 2 Nov 2010 16:09:35 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 2/6] blkmapd: don't rescan periodically
Message-ID: <13bf26e754c4a6c923c360f131f05a6ef858e99e.1288726186.git.rees@umich.edu>
References: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Periodic device rescanning is always going to be wrong, since the interval
will either be too long and miss an important change, or too short and waste
resources.  It's not even needed in the normal case, only when the devices
change during the life of a layout.  For now, just rescan when the kernel
asks for a layout.  A later patch will re-introduce rescanning during the
life of a layout, but will be triggered by configuration change
notifications from udev, rather than by expiration of an arbitrary time
interval.

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/blkmapd/device-discovery.c |   14 ++++++++++----
 utils/blkmapd/device-discovery.h |    2 --
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 0fc8fd3..71b4d48 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -308,6 +308,15 @@ int bl_disk_inquiry_process(int fd)
 	head->status = BL_DEVICE_REQUEST_PROC;
 	switch (head->type) {
 	case BL_DEVICE_MOUNT:
+		/*
+		 * It shouldn't be necessary to discover devices here, since
+		 * process_deviceinfo() will re-discover if it can't find
+		 * the devices it needs.  But in the case of multipath
+		 * devices (ones that appear more than once, for example an
+		 * active and a standby LUN), this will re-order them in the
+		 * correct priority.
+		 */
+		bl_discover_devices();
 		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
 			head->status = BL_DEVICE_REQUEST_ERR;
 			goto out;
@@ -329,7 +338,6 @@ int bl_disk_inquiry_process(int fd)
 	case BL_DEVICE_UMOUNT:
 		if (!dm_device_remove_all((uint64_t *) buf))
 			head->status = BL_DEVICE_REQUEST_ERR;
-		bl_discover_devices();
 		break;
 	default:
 		head->status = BL_DEVICE_REQUEST_ERR;
@@ -357,7 +365,6 @@ unsigned int bl_process_stop;
 int bl_run_disk_inquiry_process(int fd)
 {
 	fd_set rset;
-	struct timeval tv;
 	int ret;
 
 	bl_process_stop = 0;
@@ -368,8 +375,7 @@ int bl_run_disk_inquiry_process(int fd)
 		FD_ZERO(&rset);
 		FD_SET(fd, &rset);
 		ret = 0;
-		tv.tv_sec = BL_DEVICE_DISCOVERY_INTERVAL;
-		switch (select(fd + 1, &rset, NULL, NULL, &tv)) {
+		switch (select(fd + 1, &rset, NULL, NULL, NULL)) {
 		case -1:
 			if (errno == EINTR)
 				continue;
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index 71c0748..b8d26a6 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -27,8 +27,6 @@
 #ifndef BL_DEVICE_DISCOVERY_H
 #define BL_DEVICE_DISCOVERY_H
 
-#define BL_DEVICE_DISCOVERY_INTERVAL 60
-
 #include <stdint.h>
 #include <syslog.h>
 
-- 
1.7.1

