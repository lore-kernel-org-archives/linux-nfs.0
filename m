Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33298 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab1JNR1b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:27:31 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 1/6] ore: Make ore_calc_stripe_info EXPORT_SYMBOL
Date: Fri, 14 Oct 2011 19:27:22 +0200
Message-ID: <1318613242-3581-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ore_calc_stripe_info is needed by exofs::export.c
for the layout calculations. Make it exportable

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c         |    8 +++-----
 include/scsi/osd_ore.h |    3 +++
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 3b1cc3a..d92998d 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -57,9 +57,6 @@ MODULE_LICENSE("GPL");
  * 3. Cache some havily used calculations that will be needed by users.
  */
 
-static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
-				 struct ore_striping_info *si);
-
 enum { BIO_MAX_PAGES_KMALLOC =
 		(PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec),};
 
@@ -409,8 +406,8 @@ EXPORT_SYMBOL(ore_check_io);
  *
  *	O = L % stripe_unit + N * stripe_unit + M * group_depth * stripe_unit
  */
-static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
-				 struct ore_striping_info *si)
+void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+			  struct ore_striping_info *si)
 {
 	u32	stripe_unit = layout->stripe_unit;
 	u32	group_width = layout->group_width;
@@ -443,6 +440,7 @@ static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 	si->group_length = T - H;
 	si->M = M;
 }
+EXPORT_SYMBOL(ore_calc_stripe_info);
 
 static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 		unsigned pgbase, struct ore_per_dev_state *per_dev,
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index af2231a..a8e39d1 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -146,6 +146,9 @@ static inline unsigned ore_io_state_size(unsigned numdevs)
 
 /* ore.c */
 int ore_verify_layout(unsigned total_comps, struct ore_layout *layout);
+void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+			  struct ore_striping_info *si);
+
 int ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 		     bool is_reading, u64 offset, u64 length,
 		     struct ore_io_state **ios);
-- 
1.7.2.3

