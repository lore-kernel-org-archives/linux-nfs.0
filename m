Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44393 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954Ab1HJVRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 17:17:35 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p7ALHYPJ000927
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:17:34 -0400
Message-ID: <4E42F568.9000301@panasas.com>
Date: Wed, 10 Aug 2011 14:17:28 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 3/4] ore: Make ore_calc_stripe_info EXPORT_SYMBOL
References: <4E42F3E3.8050006@panasas.com>
In-Reply-To: <4E42F3E3.8050006@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The raid math calculations are needed by the layout-export
facility.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c         |   25 +++++++++----------------
 include/scsi/osd_ore.h |   10 ++++++++++
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 25305af..a2c09e7 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -287,16 +287,8 @@ EXPORT_SYMBOL(ore_check_io);
  *
  *	O = L % stripe_unit + N * stripe_unit + M * group_depth * stripe_unit
  */
-struct _striping_info {
-	u64 obj_offset;
-	u64 group_length;
-	u64 M; /* for truncate */
-	unsigned dev;
-	unsigned unit_off;
-};
-
-static void _calc_stripe_info(struct ore_layout *layout, u64 file_offset,
-			      struct _striping_info *si)
+void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+			  struct ore_striping_info *si)
 {
 	u32	stripe_unit = layout->stripe_unit;
 	u32	group_width = layout->group_width;
@@ -329,6 +321,7 @@ static void _calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 	si->group_length = T - H;
 	si->M = M;
 }
+EXPORT_SYMBOL(ore_calc_stripe_info);
 
 static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 		unsigned pgbase, struct ore_per_dev_state *per_dev,
@@ -375,7 +368,7 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 }
 
 static int _prepare_one_group(struct ore_io_state *ios, u64 length,
-			      struct _striping_info *si)
+			      struct ore_striping_info *si)
 {
 	unsigned stripe_unit = ios->layout->stripe_unit;
 	unsigned mirrors_p1 = ios->layout->mirrors_p1;
@@ -434,14 +427,14 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 {
 	u64 length = ios->length;
 	u64 offset = ios->offset;
-	struct _striping_info si;
+	struct ore_striping_info si;
 	int ret = 0;
 
 	if (!ios->pages) {
 		if (ios->kern_buff) {
 			struct ore_per_dev_state *per_dev = &ios->per_dev[0];
 
-			_calc_stripe_info(ios->layout, ios->offset, &si);
+			ore_calc_stripe_info(ios->layout, ios->offset, &si);
 			per_dev->offset = si.obj_offset;
 			per_dev->dev = si.dev;
 
@@ -455,7 +448,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	}
 
 	while (length) {
-		_calc_stripe_info(ios->layout, offset, &si);
+		ore_calc_stripe_info(ios->layout, offset, &si);
 
 		if (length < si.group_length)
 			si.group_length = length;
@@ -744,7 +737,7 @@ static int _truncate_mirrors(struct ore_io_state *ios, unsigned cur_comp,
 }
 
 struct _trunc_info {
-	struct _striping_info si;
+	struct ore_striping_info si;
 	u64 prev_group_obj_off;
 	u64 next_group_obj_off;
 
@@ -758,7 +751,7 @@ void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
 {
 	unsigned stripe_unit = layout->stripe_unit;
 
-	_calc_stripe_info(layout, file_offset, &ti->si);
+	ore_calc_stripe_info(layout, file_offset, &ti->si);
 
 	ti->prev_group_obj_off = ti->si.M * stripe_unit;
 	ti->next_group_obj_off = ti->si.M ? (ti->si.M - 1) * stripe_unit : 0;
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 0ac4931..4779ccc 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -96,6 +96,13 @@ struct ore_io_state {
 		unsigned dev;
 	} per_dev[];
 };
+struct ore_striping_info {
+	u64 obj_offset;
+	u64 group_length;
+	u64 M; /* for truncate */
+	unsigned dev;
+	unsigned unit_off;
+};
 
 static inline unsigned ore_io_state_size(unsigned numdevs)
 {
@@ -104,6 +111,9 @@ static inline unsigned ore_io_state_size(unsigned numdevs)
 }
 
 /* ore.c */
+void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+			  struct ore_striping_info *si);
+
 int ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 		     bool is_reading, u64 offset, u64 length,
 		     struct ore_io_state **ios);
-- 
1.7.6


