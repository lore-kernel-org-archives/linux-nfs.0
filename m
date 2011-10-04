Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52166 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594Ab1JDKeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:34:23 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 11/19] ore/exofs: Define new ore_verify_layout
Date: Tue, 4 Oct 2011 12:34:12 +0200
Message-ID: <1317724452-27641-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

All users of the ore will need to check if current code
supports the given layout. For example RAID5/6 is not
currently supported.

So move all the checks from exofs/super.c to a new
ore_verify_layout() to be used by ore users.

Note that any new layout should be passed through the
ore_verify_layout() because the ore engine will prepare
and verify some internal members of ore_layout, and
assumes it's called.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/inode.c       |    9 +-----
 fs/exofs/ore.c         |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/exofs/super.c       |   49 ++---------------------------------
 include/scsi/osd_ore.h |    8 +++++
 4 files changed, 80 insertions(+), 53 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 0afe761..7b1a4ba 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -37,11 +37,7 @@
 
 #define EXOFS_DBGMSG2(M...) do {} while (0)
 
-enum { BIO_MAX_PAGES_KMALLOC =
-		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),
-	MAX_PAGES_KMALLOC =
-		PAGE_SIZE / sizeof(struct page *),
-};
+enum {MAX_PAGES_KMALLOC = PAGE_SIZE / sizeof(struct page *), };
 
 unsigned exofs_max_io_pages(struct ore_layout *layout,
 			    unsigned expected_pages)
@@ -49,8 +45,7 @@ unsigned exofs_max_io_pages(struct ore_layout *layout,
 	unsigned pages = min_t(unsigned, expected_pages, MAX_PAGES_KMALLOC);
 
 	/* TODO: easily support bio chaining */
-	pages =  min_t(unsigned, pages,
-		       layout->group_width * BIO_MAX_PAGES_KMALLOC);
+	pages =  min_t(unsigned, pages, layout->max_io_length / PAGE_SIZE);
 	return pages;
 }
 
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 7913168..14a9100 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -47,9 +47,76 @@ MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
 MODULE_DESCRIPTION("Objects Raid Engine ore.ko");
 MODULE_LICENSE("GPL");
 
+/* ore_verify_layout does a couple of things:
+ * 1. Given a minimum number of needed parameters fixes up the rest of the
+ *    members to be operatonals for the ore. The needed parameters are those
+ *    that are defined by the pnfs-objects layout STD.
+ * 2. Check to see if the current ore code actually supports these parameters
+ *    for example stripe_unit must be a multple of the system PAGE_SIZE,
+ *    and etc...
+ * 3. Cache some havily used calculations that will be needed by users.
+ */
+
 static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 				 struct ore_striping_info *si);
 
+enum { BIO_MAX_PAGES_KMALLOC =
+		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),};
+
+int ore_verify_layout(unsigned total_comps, struct ore_layout *layout)
+{
+	u64 stripe_length;
+
+/* FIXME: Only raid0 is supported for now. */
+	if (layout->raid_algorithm != PNFS_OSD_RAID_0) {
+		ORE_ERR("Only RAID_0 for now\n");
+		return -EINVAL;
+	}
+	if (0 != (layout->stripe_unit & ~PAGE_MASK)) {
+		ORE_ERR("Stripe Unit(0x%llx)"
+			  " must be Multples of PAGE_SIZE(0x%lx)\n",
+			  _LLU(layout->stripe_unit), PAGE_SIZE);
+		return -EINVAL;
+	}
+	if (layout->group_width) {
+		if (!layout->group_depth) {
+			ORE_ERR("group_depth == 0 && group_width != 0\n");
+			return -EINVAL;
+		}
+		if (total_comps < (layout->group_width * layout->mirrors_p1)) {
+			ORE_ERR("Data Map wrong, "
+				"numdevs=%d < group_width=%d * mirrors=%d\n",
+				total_comps, layout->group_width,
+				layout->mirrors_p1);
+			return -EINVAL;
+		}
+		layout->group_count = total_comps / layout->mirrors_p1 /
+						layout->group_width;
+	} else {
+		if (layout->group_depth) {
+			printk(KERN_NOTICE "Warning: group_depth ignored "
+				"group_width == 0 && group_depth == %lld\n",
+				_LLU(layout->group_depth));
+		}
+		layout->group_width = total_comps / layout->mirrors_p1;
+		layout->group_depth = -1;
+		layout->group_count = 1;
+	}
+
+	stripe_length = (u64)layout->group_width * layout->stripe_unit;
+	if (stripe_length >= (1ULL << 32)) {
+		ORE_ERR("Stripe_length(0x%llx) >= 32bit is not supported\n",
+			_LLU(stripe_length));
+		return -EINVAL;
+	}
+
+	layout->max_io_length =
+		(BIO_MAX_PAGES_KMALLOC * PAGE_SIZE - layout->stripe_unit) *
+							layout->group_width;
+	return 0;
+}
+EXPORT_SYMBOL(ore_verify_layout);
+
 static u8 *_ios_cred(struct ore_io_state *ios, unsigned index)
 {
 	return ios->oc->comps[index & ios->oc->single_comp].cred;
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index bce3686..057b237 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -480,7 +480,7 @@ static void exofs_put_super(struct super_block *sb)
 static int _read_and_match_data_map(struct exofs_sb_info *sbi, unsigned numdevs,
 				    struct exofs_device_table *dt)
 {
-	u64 stripe_length;
+	int ret;
 
 	sbi->layout.stripe_unit =
 				le64_to_cpu(dt->dt_data_map.cb_stripe_unit);
@@ -493,50 +493,7 @@ static int _read_and_match_data_map(struct exofs_sb_info *sbi, unsigned numdevs,
 	sbi->layout.raid_algorithm  =
 				le32_to_cpu(dt->dt_data_map.cb_raid_algorithm);
 
-/* FIXME: Only raid0 for now. if not so, do not mount */
-	if (sbi->layout.raid_algorithm != PNFS_OSD_RAID_0) {
-		EXOFS_ERR("Only RAID_0 for now\n");
-		return -EINVAL;
-	}
-	if (numdevs < (sbi->layout.group_width * sbi->layout.mirrors_p1)) {
-		EXOFS_ERR("Data Map wrong, "
-			  "numdevs=%d < group_width=%d * mirrors=%d\n",
-			  numdevs, sbi->layout.group_width,
-			  sbi->layout.mirrors_p1);
-		return -EINVAL;
-	}
-
-	if (0 != (sbi->layout.stripe_unit & ~PAGE_MASK)) {
-		EXOFS_ERR("Stripe Unit(0x%llx)"
-			  " must be Multples of PAGE_SIZE(0x%lx)\n",
-			  _LLU(sbi->layout.stripe_unit), PAGE_SIZE);
-		return -EINVAL;
-	}
-
-	if (sbi->layout.group_width) {
-		if (!sbi->layout.group_depth) {
-			EXOFS_ERR("group_depth == 0 && group_width != 0\n");
-			return -EINVAL;
-		}
-		sbi->layout.group_count = numdevs / sbi->layout.mirrors_p1 /
-						sbi->layout.group_width;
-	} else {
-		if (sbi->layout.group_depth) {
-			printk(KERN_NOTICE "Warning: group_depth ignored "
-				"group_width == 0 && group_depth == %lld\n",
-				_LLU(sbi->layout.group_depth));
-		}
-		sbi->layout.group_width = numdevs / sbi->layout.mirrors_p1;
-		sbi->layout.group_depth = -1;
-		sbi->layout.group_count = 1;
-	}
-
-	stripe_length = (u64)sbi->layout.group_width * sbi->layout.stripe_unit;
-	if (stripe_length >= (1ULL << 32)) {
-		EXOFS_ERR("Total Stripe length(0x%llx)"
-			  " >= 32bit is not supported\n", _LLU(stripe_length));
-		return -EINVAL;
-	}
+	ret = ore_verify_layout(numdevs, &sbi->layout);
 
 	EXOFS_DBGMSG("exofs: layout: "
 		"num_comps=%u stripe_unit=0x%x group_width=%u "
@@ -547,7 +504,7 @@ static int _read_and_match_data_map(struct exofs_sb_info *sbi, unsigned numdevs,
 		_LLU(sbi->layout.group_depth),
 		sbi->layout.mirrors_p1,
 		sbi->layout.raid_algorithm);
-	return 0;
+	return ret;
 }
 
 static unsigned __ra_pages(struct ore_layout *layout)
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 492b70d..716dbea 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -42,6 +42,13 @@ struct ore_layout {
 	unsigned group_width;
 	u64	 group_depth;
 	unsigned group_count;
+
+	/* Cached often needed calculations filled in by
+	 * ore_verify_layout
+	 */
+	unsigned long max_io_length;	/* Max length that should be passed to
+					 * ore_get_rw_state
+					 */
 };
 
 struct ore_dev {
@@ -138,6 +145,7 @@ static inline unsigned ore_io_state_size(unsigned numdevs)
 }
 
 /* ore.c */
+int ore_verify_layout(unsigned total_comps, struct ore_layout *layout);
 int ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 		     bool is_reading, u64 offset, u64 length,
 		     struct ore_io_state **ios);
-- 
1.7.2.3

