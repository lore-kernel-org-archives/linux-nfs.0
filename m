Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60316 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab0K3TOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 14:14:24 -0500
Date: Tue, 30 Nov 2010 14:14:22 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 5/5] device mapping fixes
Message-ID: <dcdb459e391a3e4bfef08ed3d56f6449eb5c7f87.1291142529.git.rees@umich.edu>
References: <cover.1291142529.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1291142529.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Use dm_is_dm_major() to detect pseudo devices, and don't add them

If mapped device already exists, possibly from a previous run, increment
device number and try again

plug fd leak in verify_sig

fix null name in dm_device_remove_byname()

small fixes and debug info

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.c |   16 +++++------
 utils/blkmapd/device-discovery.h |    2 +-
 utils/blkmapd/device-process.c   |   39 ++++++++++++--------------
 utils/blkmapd/dm-device.c        |   55 +++++++++++++++++++++++++------------
 4 files changed, 63 insertions(+), 49 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index c2675b8..5656be3 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -46,6 +46,7 @@
 #include <unistd.h>
 #include <libgen.h>
 #include <errno.h>
+#include <libdevmapper.h>
 
 #include "device-discovery.h"
 
@@ -154,10 +155,13 @@ void bl_add_disk(char *filepath)
 
 	dev = sb.st_rdev;
 	serial = bldev_read_serial(fd, filepath);
-	ap_state = bldev_read_ap_state(fd);
+	if (dm_is_dm_major(major(dev)))
+		ap_state = BL_PATH_STATE_PSEUDO;
+	else
+		ap_state = bldev_read_ap_state(fd);
 	close(fd);
 
-	if (ap_state == BL_PATH_STATE_PASSIVE)
+	if (ap_state != BL_PATH_STATE_ACTIVE)
 		return;
 
 	for (disk = visible_disk_list; disk != NULL; disk = disk->next) {
@@ -176,13 +180,6 @@ void bl_add_disk(char *filepath)
 
 	BL_LOG_INFO("%s: %s\n", __func__, filepath);
 
-	/*
-	 * Not sure how to identify a pseudo device created by
-	 * device-mapper, so leave /dev/mapper for now.
-	 */
-	if (strncmp(filepath, "/dev/mapper", 11) == 0)
-		ap_state = BL_PATH_STATE_PSEUDO;
-
 	/* add path */
 	path = malloc(sizeof(struct bl_disk_path));
 	if (!path) {
@@ -308,6 +305,7 @@ int bl_disk_inquiry_process(int fd)
 	}
 
 	head->status = BL_DEVICE_REQUEST_PROC;
+
 	switch (head->type) {
 	case BL_DEVICE_MOUNT:
 		/*
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index a0937b1..8fe3b29 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -106,7 +106,7 @@ struct pipefs_hdr {
 	uint32_t msgid;
 	uint8_t type;
 	uint8_t flags;
-	uint16_t totallen;		/* length of entire message, including hdr */
+	uint16_t totallen;		/* length of message including hdr */
 	uint32_t status;
 };
 
diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 4ce47e1..0c5060b 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -52,10 +52,10 @@
 static char *pretty_sig(char *sig, uint32_t siglen)
 {
 	static char rs[100];
-	unsigned long i;
+	unsigned long i = 0;
 
 	if (siglen <= sizeof i) {
-		memcpy(&i, sig, sizeof i);
+		memcpy(&i, sig, siglen);
 		sprintf(rs, "0x%0lx", i);
 	} else {
 		if (siglen > sizeof rs - 1)
@@ -75,7 +75,7 @@ uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
 	return p;
 }
 
-static int decode_blk_signature(uint32_t ** pp, uint32_t * end,
+static int decode_blk_signature(uint32_t **pp, uint32_t * end,
 				struct bl_sig *sig)
 {
 	int i;
@@ -164,25 +164,27 @@ read_cmp_blk_sig(struct bl_disk *disk, int fd, struct bl_sig_comp *comp)
 static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
 {
 	const char *dev_name = disk->valid_path->full_path;
-	struct bl_sig_comp *comp;
-	int fd, i, ret;
+	int fd, i, rv;
 
 	fd = open(dev_name, O_RDONLY | O_LARGEFILE);
 	if (fd < 0) {
-		BL_LOG_ERR("%s could not be opened for read\n", dev_name);
+		BL_LOG_ERR("%s: %s could not be opened for read\n", __func__,
+			   dev_name);
 		return 0;
 	}
 
+	rv = 1;
+
 	for (i = 0; i < sig->si_num_comps; i++) {
-		comp = &sig->si_comps[i];
-		ret = read_cmp_blk_sig(disk, fd, comp);
-		if (ret)
-			return 0;
+		if (read_cmp_blk_sig(disk, fd, &sig->si_comps[i])) {
+			rv = 0;
+			break;
+		}
 	}
 
 	if (fd >= 0)
 		close(fd);
-	return 1;
+	return rv;
 }
 
 /*
@@ -197,13 +199,6 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 	int mapped = 0;
 	struct bl_disk *disk = visible_disk_list;
 	char *filepath = 0;
-	struct bl_disk *lolDisk = disk;
-
-	while (lolDisk) {
-		BL_LOG_INFO("%s: visible_disk_list: %s\n", __func__,
-			   lolDisk->valid_path->full_path);
-		lolDisk = lolDisk->next;
-	}
 
 	/* scan disk list to find out match device */
 	while (disk) {
@@ -267,6 +262,8 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
 
 	BLK_READBUF(p, end, 4);
 	READ32(vol->bv_type);
+	BL_LOG_INFO("%s: bv_type %d\n", __func__, vol->bv_type);
+
 	switch (vol->bv_type) {
 	case BLOCK_VOLUME_SIMPLE:
 		*array_cnt = 0;
@@ -347,13 +344,13 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 
 	p = (uint32_t *) dev_addr_buf;
 	end = (uint32_t *) ((char *)p + dev_addr_len);
+
 	/* Decode block volume */
 	BLK_READBUF(p, end, 4);
 	READ32(num_vols);
-	if (num_vols <= 0) {
-		BL_LOG_ERR("Error: number of vols: %d\n", num_vols);
+	BL_LOG_INFO("%s: %d vols\n", __func__, num_vols);
+	if (num_vols <= 0)
 		goto out_err;
-	}
 
 	vols = (struct bl_volume *)malloc(num_vols * sizeof(struct bl_volume));
 	if (!vols) {
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index 5a9f5ec..d720086 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -31,6 +31,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <unistd.h>
 #include <string.h>
 #include <syslog.h>
 #include <fcntl.h>
@@ -46,8 +47,6 @@
 #endif
 
 #define DM_PARAMS_LEN		512	/* XXX: is this enough for target? */
-#define DM_DIR			"/dev/mapper"
-#define DM_DIR_LEN12
 #define TYPE_HAS_DEV(type)	((type == BLOCK_VOLUME_SIMPLE) || \
 			 (type == BLOCK_VOLUME_PSEUDO))
 
@@ -65,6 +64,10 @@ struct bl_dm_tree {
 	struct bl_dm_tree *next;
 };
 
+static const char dm_name[] = "pnfs_vol_%u";
+
+static unsigned int dev_count;
+
 static inline struct bl_dm_table *bl_dm_table_alloc(void)
 {
 	return (struct bl_dm_table *)calloc(1, sizeof(struct bl_dm_table));
@@ -104,7 +107,7 @@ static struct bl_dm_tree *find_bl_dm_tree(uint64_t dev)
 
 	for (p = bl_tree_head; p; p = p->next) {
 		if (p->dev == dev)
-		    break;
+			break;
 	}
 	return p;
 }
@@ -146,7 +149,7 @@ static void add_to_bl_dm_tree(struct bl_dm_tree *tree)
  * return dev no for created device
  */
 static uint64_t
-dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
+dm_device_create_mapped(const char *dev_name, struct bl_dm_table *p)
 {
 	struct dm_task *dmt;
 	struct dm_info dminfo;
@@ -162,20 +165,23 @@ dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
 		goto err_out;
 
 	while (p) {
-		ret = dm_task_add_target(dmt, p->offset, p->size,
-					 p->target_type, p->params);
+		ret =
+		    dm_task_add_target(dmt, p->offset, p->size, p->target_type,
+				       p->params);
 		if (!ret)
 			goto err_out;
 		p = p->next;
 	}
 
-	ret = dm_task_run(dmt) &&
-	    dm_task_get_info(dmt, &dminfo) && dminfo.exists;
+	ret = dm_task_run(dmt) && dm_task_get_info(dmt, &dminfo)
+	    && dminfo.exists;
 
 	if (!ret)
 		goto err_out;
 
 	dm_task_update_nodes();
+	BL_LOG_ERR("%s: %s %d/%d\n", __func__, dev_name,
+		   (int)dminfo.major, (int)dminfo.minor);
 
  err_out:
 	dm_task_destroy(dmt);
@@ -192,6 +198,8 @@ static int dm_device_remove_byname(const char *dev_name)
 	struct dm_task *dmt;
 	int ret = 0;
 
+	BL_LOG_INFO("%s: %s\n", __func__, dev_name);
+
 	dmt = dm_task_create(DM_DEVICE_REMOVE);
 	if (!dmt)
 		return 0;
@@ -234,7 +242,7 @@ int dm_device_remove(uint64_t dev)
 
 	while (dmnames) {
 		if (dmnames->dev == dev) {
-			name = dmnames->name;
+			name = strdup(dmnames->name);
 			break;
 		}
 		dmnames = (void *)dmnames + dmnames->next;
@@ -252,24 +260,24 @@ int dm_device_remove(uint64_t dev)
 		dm_task_destroy(dmt);
 
 	/* Start to remove device */
-	if (name)
+	if (name) {
 		ret = dm_device_remove_byname(name);
+		free(name);
+	}
 
 	return ret;
 }
 
-static unsigned long dev_count;
-
-static void dm_devicelist_remove(unsigned long start, unsigned long end)
+static void dm_devicelist_remove(unsigned int start, unsigned int end)
 {
 	char dev_name[DM_DEV_NAME_LEN];
-	unsigned long count;
+	unsigned int count;
 
 	if (start >= dev_count || end <= 1 || start >= end - 1)
 		return;
 
 	for (count = end - 1; count > start; count--) {
-		sprintf(dev_name, "pnfs_vol_%lu", count - 1);
+		snprintf(dev_name, sizeof dev_name, dm_name, count - 1);
 		dm_device_remove_byname(dev_name);
 	}
 
@@ -352,11 +360,19 @@ int dm_device_remove_all(uint64_t *dev)
 	return ret;
 }
 
+static int dm_device_exists(char *dev_name)
+{
+	char fullname[DM_DEV_NAME_LEN];
+
+	snprintf(fullname, sizeof fullname, "/dev/mapper/%s", dev_name);
+	return (access(fullname, F_OK) >= 0);
+}
+
 /* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
 uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 {
 	uint64_t size, dev = 0;
-	unsigned long count = dev_count;
+	unsigned int count = dev_count;
 	int volnum, i, pos;
 	struct bl_volume *node;
 	char *tmp;
@@ -466,9 +482,12 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 			BL_LOG_ERR("%s: Out of memory\n", __func__);
 			goto out;
 		}
-		sprintf(dev_name, "pnfs_vol_%lu", dev_count++);
+		do {
+			snprintf(dev_name, DM_DEV_NAME_LEN, dm_name,
+				 dev_count++);
+		} while (dm_device_exists(dev_name));
 
-		dev = dm_single_device_create(dev_name, bl_table_head);
+		dev = dm_device_create_mapped(dev_name, bl_table_head);
 		if (!dev) {
 			/* Delete previous temporary devices */
 			dm_devicelist_remove(count, dev_count);
-- 
1.7.1

