Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:52068 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486Ab1AUQyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 11:54:11 -0500
Date: Fri, 21 Jan 2011 11:54:09 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/3] Various improvements to comments and syslog messages
Message-ID: <cd1954f041538a6439fdb27e6ae47cf19f27c4c1.1295627825.git.rees@umich.edu>
References: <cover.1295627825.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1295627825.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Minor reformat and eliminate unneeded code, no functional changes

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.c |    2 -
 utils/blkmapd/device-discovery.h |    2 +-
 utils/blkmapd/device-process.c   |   50 +++++++++++++++++++------------------
 utils/blkmapd/dm-device.c        |    4 +-
 4 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 5656be3..b4cb8a4 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -178,8 +178,6 @@ void bl_add_disk(char *filepath)
 	if (disk && diskpath)
 		return;
 
-	BL_LOG_INFO("%s: %s\n", __func__, filepath);
-
 	/* add path */
 	path = malloc(sizeof(struct bl_disk_path));
 	if (!path) {
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index a55ccfe..e25dd44 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -89,7 +89,7 @@ struct bl_disk {
 	struct bl_disk *next;
 	struct bl_serial *serial;
 	dev_t dev;
-	off_t size;
+	off_t size;			/* in 512-byte sectors */
 	struct bl_disk_path *valid_path;
 	struct bl_disk_path *paths;
 };
diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 91b0afc..b709b48 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -154,7 +154,8 @@ read_cmp_blk_sig(struct bl_disk *disk, int fd, struct bl_sig_comp *comp)
 	ret = memcmp(sig, comp->bs_string, siglen);
 	if (!ret)
 		BL_LOG_INFO("%s: %s sig %s at %lld\n", __func__, dev_name,
-			    pretty_sig(sig, siglen), (long long)bs_offset);
+			    pretty_sig(sig, siglen),
+			    (long long)comp->bs_offset);
 
  out:
 	if (sig)
@@ -202,11 +203,11 @@ static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
 static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 {
 	int mapped = 0;
-	struct bl_disk *disk = visible_disk_list;
+	struct bl_disk *disk;
 	char *filepath = 0;
 
 	/* scan disk list to find out match device */
-	while (disk) {
+	for (disk = visible_disk_list; disk; disk = disk->next) {
 		/* FIXME: should we use better algorithm for disk scan? */
 		mapped = verify_sig(disk, sig);
 		if (mapped) {
@@ -215,7 +216,6 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 			vol->bv_size = disk->size;
 			break;
 		}
-		disk = disk->next;
 	}
 	return mapped;
 }
@@ -230,6 +230,7 @@ static int set_vol_array(uint32_t **pp, uint32_t *end,
 	int i, index;
 	uint32_t *p = *pp;
 	struct bl_volume **array = vols[working].bv_vols;
+
 	for (i = 0; i < vols[working].bv_vol_n; i++) {
 		BLK_READBUF(p, end, 4);
 		READ32(index);
@@ -250,24 +251,24 @@ static uint64_t sum_subvolume_sizes(struct bl_volume *vol)
 {
 	int i;
 	uint64_t sum = 0;
+
 	for (i = 0; i < vol->bv_vol_n; i++)
 		sum += vol->bv_vols[i]->bv_size;
 	return sum;
 }
 
-static int decode_blk_volume(uint32_t **pp, uint32_t *end,
-			     struct bl_volume *vols, int i, int *array_cnt)
+static int
+decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln,
+		  int *array_cnt)
 {
 	int status = 0, j;
 	struct bl_sig sig;
 	uint32_t *p = *pp;
-	struct bl_volume *vol = &vols[i];
-	uint64_t tmp, tmp_size;
-	div_t d;
+	struct bl_volume *vol = &vols[voln];
+	uint64_t tmp;
 
 	BLK_READBUF(p, end, 4);
 	READ32(vol->bv_type);
-	BL_LOG_INFO("%s: bv_type %d\n", __func__, vol->bv_type);
 
 	switch (vol->bv_type) {
 	case BLOCK_VOLUME_SIMPLE:
@@ -280,6 +281,7 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
 			BL_LOG_ERR("Could not find disk for device\n");
 			return -ENXIO;
 		}
+		BL_LOG_INFO("%s: simple %d\n", __func__, voln);
 		status = 0;
 		break;
 	case BLOCK_VOLUME_SLICE:
@@ -287,22 +289,25 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
 		READ_SECTOR(vol->param.bv_offset);
 		READ_SECTOR(vol->bv_size);
 		*array_cnt = vol->bv_vol_n = 1;
-		status = set_vol_array(&p, end, vols, i);
+		BL_LOG_INFO("%s: slice %d\n", __func__, voln);
+		status = set_vol_array(&p, end, vols, voln);
 		break;
 	case BLOCK_VOLUME_STRIPE:
 		BLK_READBUF(p, end, 8);
 		READ_SECTOR(vol->param.bv_stripe_unit);
 		off_t chunksize = vol->param.bv_stripe_unit;
-		if ((chunksize == 0) ||
-		    ((chunksize & (chunksize - 1)) != 0) ||
-		    (chunksize < (off_t)(PAGE_SIZE >> 9)))
+		/* Check limitations imposed by device-mapper */
+		if ((chunksize & (chunksize - 1)) != 0
+		    || chunksize < (off_t) (PAGE_SIZE >> 9))
 			return -EIO;
 		BLK_READBUF(p, end, 4);
 		READ32(vol->bv_vol_n);
 		if (!vol->bv_vol_n)
 			return -EIO;
 		*array_cnt = vol->bv_vol_n;
-		status = set_vol_array(&p, end, vols, i);
+		BL_LOG_INFO("%s: stripe %d nvols=%d unit=%ld\n", __func__, voln,
+			    vol->bv_vol_n, (long)chunksize);
+		status = set_vol_array(&p, end, vols, voln);
 		if (status)
 			return status;
 		for (j = 1; j < vol->bv_vol_n; j++) {
@@ -312,11 +317,8 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
 				return -EIO;
 			}
 		}
-		/* Make sure total size only includes addressable areas */
-		tmp_size = vol->bv_vols[0]->bv_size;
-		d = div(tmp_size, (uint32_t) vol->param.bv_stripe_unit);
-		tmp_size = d.quot;
-		vol->bv_size = tmp_size * vol->param.bv_stripe_unit;
+		/* Truncate size to a stripe unit boundary */
+		vol->bv_size = vol->bv_vols[0]->bv_size & ~(chunksize - 1);
 		break;
 	case BLOCK_VOLUME_CONCAT:
 		BLK_READBUF(p, end, 4);
@@ -324,7 +326,9 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
 		if (!vol->bv_vol_n)
 			return -EIO;
 		*array_cnt = vol->bv_vol_n;
-		status = set_vol_array(&p, end, vols, i);
+		BL_LOG_INFO("%s: concat %d %d\n", __func__, voln,
+			    vol->bv_vol_n);
+		status = set_vol_array(&p, end, vols, voln);
 		if (status)
 			return status;
 		vol->bv_size = sum_subvolume_sizes(vol);
@@ -370,7 +374,7 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 	 * referenced again, the volume arrays are guaranteed to fit
 	 * in the suprisingly small space allocated.
 	 */
-	arrays =
+	arrays_ptr = arrays =
 	    (struct bl_volume **)malloc(num_vols * 2 *
 					sizeof(struct bl_volume *));
 	if (!arrays) {
@@ -378,8 +382,6 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 		goto out_err;
 	}
 
-	arrays_ptr = arrays;
-
 	for (i = 0; i < num_vols; i++) {
 		vols[i].bv_vols = arrays_ptr;
 		status = decode_blk_volume(&p, end, vols, i, &count);
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index ee7d787..2e87db8 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -180,8 +180,6 @@ dm_device_create_mapped(const char *dev_name, struct bl_dm_table *p)
 		goto err_out;
 
 	dm_task_update_nodes();
-	BL_LOG_ERR("%s: %s %d/%d\n", __func__, dev_name,
-		   (int)dminfo.major, (int)dminfo.minor);
 
  err_out:
 	dm_task_destroy(dmt);
@@ -502,6 +500,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 		} while (dm_device_exists(dev_name));
 
 		dev = dm_device_create_mapped(dev_name, bl_table_head);
+		BL_LOG_INFO("%s: %d %s %d:%d\n", __func__, volnum, dev_name,
+			    (int) MAJOR(dev), (int) MINOR(dev));
 		if (!dev) {
 			/* Delete previous temporary devices */
 			dm_devicelist_remove(count, dev_count);
-- 
1.7.1

