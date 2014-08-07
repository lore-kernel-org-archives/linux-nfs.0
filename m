Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45804 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbaHGHYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:24:31 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XFI3q-0006ze-5e
	for linux-nfs@vger.kernel.org; Thu, 07 Aug 2014 07:24:30 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] blkmapd: fix broken multipath handling
Date: Thu,  7 Aug 2014 09:26:48 +0200
Message-Id: <1407396409-5036-2-git-send-email-hch@lst.de>
In-Reply-To: <1407396409-5036-1-git-send-email-hch@lst.de>
References: <1407396409-5036-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do want to use the dm-multipath device if it exists, which the
code is generally prepared for, except that this check excludes them
early.  In addition this will also add the passive path to the device
list, which is harmless if an active one exists as that or the multipath
device will be preferred, and at least allows us to work if it doesn't.

Also fix up the check if an path needs to be updated to remove the silly
partition check - pNFS block offset are relative to the device so partion
should never match it instead of the full device.  On the other hand the
simplistic check easily creates false positives, e.g. dm-10 is considered
a partition of dm-1.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 utils/blkmapd/device-discovery.c | 27 ++++-----------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index df4627e..bcfb060 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -77,16 +77,6 @@ struct bl_disk_path *bl_get_path(const char *filepath,
 	return tmp;
 }
 
-/* Check whether valid_path is a substring(partition) of path */
-int bl_is_partition(struct bl_disk_path *valid_path, struct bl_disk_path *path)
-{
-	if (!strncmp(valid_path->full_path, path->full_path,
-		     strlen(valid_path->full_path)))
-		return 1;
-
-	return 0;
-}
-
 /*
  * For multipath devices, devices state could be PASSIVE/ACTIVE/PSEUDO,
  * where PSEUDO > ACTIVE > PASSIVE. Device with highest state is used to
@@ -95,19 +85,13 @@ int bl_is_partition(struct bl_disk_path *valid_path, struct bl_disk_path *path)
  * If device-mapper multipath support is a must, pseudo devices should
  * exist for each multipath device. If not, active device path will be
  * chosen for device creation.
- * Treat partition as invalid path.
  */
-int bl_update_path(struct bl_disk_path *path, enum bl_path_state_e state,
-		   struct bl_disk *disk)
+int bl_update_path(enum bl_path_state_e state, struct bl_disk *disk)
 {
 	struct bl_disk_path *valid_path = disk->valid_path;
 
-	if (valid_path) {
-		if (valid_path->state >= state) {
-			if (bl_is_partition(valid_path, path))
-				return 0;
-		}
-	}
+	if (valid_path && valid_path->state >= state)
+		return 0;
 	return 1;
 }
 
@@ -170,9 +154,6 @@ void bl_add_disk(char *filepath)
 		ap_state = bldev_read_ap_state(fd);
 	close(fd);
 
-	if (ap_state != BL_PATH_STATE_ACTIVE)
-		return;
-
 	for (disk = visible_disk_list; disk != NULL; disk = disk->next) {
 		/* Already scanned or a partition?
 		 * XXX: if released each time, maybe not need to compare
@@ -216,7 +197,7 @@ void bl_add_disk(char *filepath)
 		path->next = disk->paths;
 		disk->paths = path;
 		/* check whether we need to update disk info */
-		if (bl_update_path(path, path->state, disk)) {
+		if (bl_update_path(path->state, disk)) {
 			disk->dev = dev;
 			disk->size = size;
 			disk->valid_path = path;
-- 
1.9.1

