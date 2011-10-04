Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52019 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab1JDK3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:29:23 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 03/19] ore: Make ore_striping_info and ore_calc_stripe_info public
Date: Tue, 4 Oct 2011 12:29:13 +0200
Message-ID: <1317724153-27385-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The struct ore_striping_info will be used later in other
structures. And ore_calc_stripe_info as well. Rename them
make struct ore_striping_info public. ore_calc_stripe_info
is still static, will be made public on first use.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c         |   24 ++++++++----------------
 include/scsi/osd_ore.h |    8 ++++++++
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 870f85a..c2b0033 100644
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
+static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+				 struct ore_striping_info *si)
 {
 	u32	stripe_unit = layout->stripe_unit;
 	u32	group_width = layout->group_width;
@@ -375,7 +367,7 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 }
 
 static int _prepare_one_group(struct ore_io_state *ios, u64 length,
-			      struct _striping_info *si)
+			      struct ore_striping_info *si)
 {
 	unsigned stripe_unit = ios->layout->stripe_unit;
 	unsigned mirrors_p1 = ios->layout->mirrors_p1;
@@ -434,14 +426,14 @@ static int _prepare_for_striping(struct ore_io_state *ios)
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
 
@@ -455,7 +447,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	}
 
 	while (length) {
-		_calc_stripe_info(ios->layout, offset, &si);
+		ore_calc_stripe_info(ios->layout, offset, &si);
 
 		if (length < si.group_length)
 			si.group_length = length;
@@ -744,7 +736,7 @@ static int _truncate_mirrors(struct ore_io_state *ios, unsigned cur_comp,
 }
 
 struct _trunc_info {
-	struct _striping_info si;
+	struct ore_striping_info si;
 	u64 prev_group_obj_off;
 	u64 next_group_obj_off;
 
@@ -758,7 +750,7 @@ static void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
 {
 	unsigned stripe_unit = layout->stripe_unit;
 
-	_calc_stripe_info(layout, file_offset, &ti->si);
+	ore_calc_stripe_info(layout, file_offset, &ti->si);
 
 	ti->prev_group_obj_off = ti->si.M * stripe_unit;
 	ti->next_group_obj_off = ti->si.M ? (ti->si.M - 1) * stripe_unit : 0;
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index f7fabb4..e4d550f 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -56,6 +56,14 @@ struct ore_components {
 	struct osd_dev	**ods;			/* osd_dev array              */
 };
 
+struct ore_striping_info {
+	u64 obj_offset;
+	u64 group_length;
+	u64 M; /* for truncate */
+	unsigned dev;
+	unsigned unit_off;
+};
+
 struct ore_io_state;
 typedef void (*ore_io_done_fn)(struct ore_io_state *ios, void *private);
 
-- 
1.7.2.3

