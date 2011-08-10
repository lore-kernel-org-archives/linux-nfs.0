Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44346 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970Ab1HJVPJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 17:15:09 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p7ALF8jQ000802
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:15:08 -0400
Message-ID: <4E42F4D6.5080204@panasas.com>
Date: Wed, 10 Aug 2011 14:15:02 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 1/4] exofs: Remove unused data_map member from exofs_sb_info
References: <4E42F3E3.8050006@panasas.com>
In-Reply-To: <4E42F3E3.8050006@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The struct pnfs_osd_data_map data_map member of exofs_sb_info was
never used after mount. In fact all it's members were duplicated
by the ore_layout structure. So just remove the duplicated information.

Also removed some stupid, but perfectly supported, restrictions on
layout parameters. The case where num_devices is not divisible by
mirror_count+1 is perfectly fine since the rotating device view
will eventually use all the devices it can get.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/exofs.h       |    3 --
 fs/exofs/super.c       |   57 ++++++++++++++++++-----------------------------
 include/scsi/osd_ore.h |    2 +
 3 files changed, 24 insertions(+), 38 deletions(-)

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index 21b1c71..474d99f 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -66,9 +66,6 @@ struct exofs_sb_info {
 	u32		s_next_generation;	/* next gen # to use          */
 	atomic_t	s_curr_pending;		/* number of pending commands */
 
-	struct pnfs_osd_data_map data_map;	/* Default raid to use
-						 * FIXME: Needed ?
-						 */
 	struct ore_layout	layout;		/* Default files layout       */
 	struct ore_comp one_comp;		/* id & cred of partition id=0*/
 	struct ore_components comps;		/* comps for the partition    */
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index fbea138..7a45e78 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -481,64 +481,51 @@ static int _read_and_match_data_map(struct exofs_sb_info *sbi, unsigned numdevs,
 {
 	u64 stripe_length;
 
-	sbi->data_map.odm_num_comps   =
-				le32_to_cpu(dt->dt_data_map.cb_num_comps);
-	sbi->data_map.odm_stripe_unit =
+	sbi->layout.stripe_unit =
 				le64_to_cpu(dt->dt_data_map.cb_stripe_unit);
-	sbi->data_map.odm_group_width =
+	sbi->layout.group_width =
 				le32_to_cpu(dt->dt_data_map.cb_group_width);
-	sbi->data_map.odm_group_depth =
+	sbi->layout.group_depth =
 				le32_to_cpu(dt->dt_data_map.cb_group_depth);
-	sbi->data_map.odm_mirror_cnt  =
-				le32_to_cpu(dt->dt_data_map.cb_mirror_cnt);
-	sbi->data_map.odm_raid_algorithm  =
+	sbi->layout.mirrors_p1  =
+				le32_to_cpu(dt->dt_data_map.cb_mirror_cnt) + 1;
+	sbi->layout.raid_algorithm  =
 				le32_to_cpu(dt->dt_data_map.cb_raid_algorithm);
 
 /* FIXME: Only raid0 for now. if not so, do not mount */
-	if (sbi->data_map.odm_num_comps != numdevs) {
-		EXOFS_ERR("odm_num_comps(%u) != numdevs(%u)\n",
-			  sbi->data_map.odm_num_comps, numdevs);
-		return -EINVAL;
-	}
-	if (sbi->data_map.odm_raid_algorithm != PNFS_OSD_RAID_0) {
+	if (sbi->layout.raid_algorithm != PNFS_OSD_RAID_0) {
 		EXOFS_ERR("Only RAID_0 for now\n");
 		return -EINVAL;
 	}
-	if (0 != (numdevs % (sbi->data_map.odm_mirror_cnt + 1))) {
-		EXOFS_ERR("Data Map wrong, numdevs=%d mirrors=%d\n",
-			  numdevs, sbi->data_map.odm_mirror_cnt);
+	if (numdevs < (sbi->layout.group_width * sbi->layout.mirrors_p1)) {
+		EXOFS_ERR("Data Map wrong, "
+			  "numdevs=%d < group_width=%d * mirrors=%d\n",
+			  numdevs, sbi->layout.group_width,
+			  sbi->layout.mirrors_p1);
 		return -EINVAL;
 	}
 
-	if (0 != (sbi->data_map.odm_stripe_unit & ~PAGE_MASK)) {
+	if (0 != (sbi->layout.stripe_unit & ~PAGE_MASK)) {
 		EXOFS_ERR("Stripe Unit(0x%llx)"
 			  " must be Multples of PAGE_SIZE(0x%lx)\n",
-			  _LLU(sbi->data_map.odm_stripe_unit), PAGE_SIZE);
+			  _LLU(sbi->layout.stripe_unit), PAGE_SIZE);
 		return -EINVAL;
 	}
 
-	sbi->layout.stripe_unit = sbi->data_map.odm_stripe_unit;
-	sbi->layout.mirrors_p1 = sbi->data_map.odm_mirror_cnt + 1;
-
-	if (sbi->data_map.odm_group_width) {
-		sbi->layout.group_width = sbi->data_map.odm_group_width;
-		sbi->layout.group_depth = sbi->data_map.odm_group_depth;
+	if (sbi->layout.group_width) {
 		if (!sbi->layout.group_depth) {
 			EXOFS_ERR("group_depth == 0 && group_width != 0\n");
 			return -EINVAL;
 		}
-		sbi->layout.group_count = sbi->data_map.odm_num_comps /
-						sbi->layout.mirrors_p1 /
-						sbi->data_map.odm_group_width;
+		sbi->layout.group_count = numdevs / sbi->layout.mirrors_p1 /
+						sbi->layout.group_width;
 	} else {
-		if (sbi->data_map.odm_group_depth) {
+		if (sbi->layout.group_depth) {
 			printk(KERN_NOTICE "Warning: group_depth ignored "
-				"group_width == 0 && group_depth == %d\n",
-				sbi->data_map.odm_group_depth);
-			sbi->data_map.odm_group_depth = 0;
+				"group_width == 0 && group_depth == %lld\n",
+				_LLU(sbi->layout.group_depth));
 		}
-		sbi->layout.group_width = sbi->data_map.odm_num_comps /
-							sbi->layout.mirrors_p1;
+		sbi->layout.group_width = numdevs / sbi->layout.mirrors_p1;
 		sbi->layout.group_depth = -1;
 		sbi->layout.group_count = 1;
 	}
@@ -558,7 +545,7 @@ static int _read_and_match_data_map(struct exofs_sb_info *sbi, unsigned numdevs,
 		sbi->layout.group_width,
 		_LLU(sbi->layout.group_depth),
 		sbi->layout.mirrors_p1,
-		sbi->data_map.odm_raid_algorithm);
+		sbi->layout.raid_algorithm);
 	return 0;
 }
 
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index c5c5e00..0ac4931 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -34,6 +34,8 @@ struct ore_comp {
 
 struct ore_layout {
 	/* Our way of looking at the data_map */
+	enum pnfs_osd_raid_algorithm4
+		 raid_algorithm;
 	unsigned stripe_unit;
 	unsigned mirrors_p1;
 
-- 
1.7.6


