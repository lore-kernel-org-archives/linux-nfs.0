Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45806 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591AbaHGHYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:24:32 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XFI3r-0006zj-1O
	for linux-nfs@vger.kernel.org; Thu, 07 Aug 2014 07:24:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] blkmapd: dump useful device information to syslog
Date: Thu,  7 Aug 2014 09:26:49 +0200
Message-Id: <1407396409-5036-3-git-send-email-hch@lst.de>
In-Reply-To: <1407396409-5036-1-git-send-email-hch@lst.de>
References: <1407396409-5036-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dump some information about used devices to syslog so that an admin
can troubleshoot failing blocklayout mounts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 utils/blkmapd/device-discovery.c | 6 +++++-
 utils/blkmapd/device-process.c   | 2 ++
 utils/blkmapd/dm-device.c        | 4 ++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index bcfb060..b52afe2 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -148,7 +148,11 @@ void bl_add_disk(char *filepath)
 
 	dev = sb.st_rdev;
 	serial = bldev_read_serial(fd, filepath);
-	if (dm_is_dm_major(major(dev)))
+	if (!serial) {
+		BL_LOG_ERR("%s: no serial found for %s\n",
+				 __func__, filepath);
+		ap_state = BL_PATH_STATE_PASSIVE;
+	} else if (dm_is_dm_major(major(dev)))
 		ap_state = BL_PATH_STATE_PSEUDO;
 	else
 		ap_state = bldev_read_ap_state(fd);
diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 5fe3dff..f53a616 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -181,6 +181,8 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 		/* FIXME: should we use better algorithm for disk scan? */
 		mapped = verify_sig(disk, sig);
 		if (mapped) {
+			BL_LOG_INFO("%s: using device %s\n",
+					__func__, disk->valid_path->full_path);
 			vol->param.bv_dev = disk->dev;
 			vol->bv_size = disk->size;
 			break;
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index 0f4f148..8ffb19e 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -400,6 +400,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 			}
 			dev = node->bv_vols[0]->param.bv_dev;
 			tmp = table->params;
+			BL_LOG_INFO("%s: major %u minor %u", __func__,
+					MAJOR(dev), MINOR(dev));
 			if (!dm_format_dev(tmp, DM_PARAMS_LEN,
 					   MAJOR(dev), MINOR(dev))) {
 				free(table);
@@ -459,6 +461,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 				strcpy(table->target_type, "linear");
 				tmp = table->params;
 				dev = node->bv_vols[i]->param.bv_dev;
+				BL_LOG_INFO("%s: major %u minor %u", __func__,
+					MAJOR(dev), MINOR(dev));
 				if (!dm_format_dev(tmp, DM_PARAMS_LEN,
 						   MAJOR(dev), MINOR(dev))) {
 					free(table);
-- 
1.9.1

