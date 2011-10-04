Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52101 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1JDKbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:31:05 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 06/19] ore: cleanup: Embed an ore_striping_info inside ore_io_state
Date: Tue, 4 Oct 2011 12:30:56 +0200
Message-ID: <1317724256-27480-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now that each ore_io_state covers only a single raid group.
A single striping_info math is needed. Embed one inside
ore_io_state to cache the calculation results and eliminate
an extra call.

Also the outer _prepare_for_striping is removed since it does nothing.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c         |   61 +++++++++++++++++++-----------------------------
 include/scsi/osd_ore.h |    1 +
 2 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index d54af35..43a53ba 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -121,11 +121,9 @@ int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
 	ios->offset = offset;
 
 	if (length) {
-		struct ore_striping_info si;
-
-		ore_calc_stripe_info(layout, offset, &si);
-		ios->length = (length <= si.group_length) ? length :
-							si.group_length;
+		ore_calc_stripe_info(layout, offset, &ios->si);
+		ios->length = (length <= ios->si.group_length) ? length :
+							ios->si.group_length;
 		ios->nr_pages = (ios->length + PAGE_SIZE - 1) / PAGE_SIZE;
 	}
 
@@ -416,9 +414,9 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 	return 0;
 }
 
-static int _prepare_one_group(struct ore_io_state *ios, u64 length,
-			      struct ore_striping_info *si)
+static int _prepare_for_striping(struct ore_io_state *ios)
 {
+	struct ore_striping_info *si = &ios->si;
 	unsigned stripe_unit = ios->layout->stripe_unit;
 	unsigned mirrors_p1 = ios->layout->mirrors_p1;
 	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
@@ -426,8 +424,27 @@ static int _prepare_one_group(struct ore_io_state *ios, u64 length,
 	unsigned first_dev = dev - (dev % devs_in_group);
 	unsigned max_comp = ios->numdevs ? ios->numdevs - mirrors_p1 : 0;
 	unsigned cur_pg = ios->pages_consumed;
+	u64 length = ios->length;
 	int ret = 0;
 
+	if (!ios->pages) {
+		if (ios->kern_buff) {
+			struct ore_per_dev_state *per_dev = &ios->per_dev[0];
+
+			per_dev->offset = si->obj_offset;
+			per_dev->dev = si->dev;
+
+			/* no cross device without page array */
+			BUG_ON((ios->layout->group_width > 1) &&
+			       (si->unit_off + ios->length >
+				ios->layout->stripe_unit));
+		}
+		ios->numdevs = ios->layout->mirrors_p1;
+		return 0;
+	}
+
+	BUG_ON(length > si->group_length);
+
 	while (length) {
 		unsigned comp = dev - first_dev;
 		struct ore_per_dev_state *per_dev = &ios->per_dev[comp];
@@ -473,36 +490,6 @@ out:
 	return ret;
 }
 
-static int _prepare_for_striping(struct ore_io_state *ios)
-{
-	struct ore_striping_info si;
-	int ret;
-
-	if (!ios->pages) {
-		if (ios->kern_buff) {
-			struct ore_per_dev_state *per_dev = &ios->per_dev[0];
-
-			ore_calc_stripe_info(ios->layout, ios->offset, &si);
-			per_dev->offset = si.obj_offset;
-			per_dev->dev = si.dev;
-
-			/* no cross device without page array */
-			BUG_ON((ios->layout->group_width > 1) &&
-			       (si.unit_off + ios->length >
-				ios->layout->stripe_unit));
-		}
-		ios->numdevs = ios->layout->mirrors_p1;
-		return 0;
-	}
-
-	ore_calc_stripe_info(ios->layout, ios->offset, &si);
-
-	BUG_ON(ios->length > si.group_length);
-	ret = _prepare_one_group(ios, ios->length, &si);
-
-	return ret;
-}
-
 int ore_create(struct ore_io_state *ios)
 {
 	int i, ret;
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 8fefdfb..baeef02 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -93,6 +93,7 @@ typedef void (*ore_io_done_fn)(struct ore_io_state *ios, void *private);
 
 struct ore_io_state {
 	struct kref		kref;
+	struct ore_striping_info si;
 
 	void			*private;
 	ore_io_done_fn	done;
-- 
1.7.2.3

