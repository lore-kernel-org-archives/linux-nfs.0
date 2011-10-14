Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33414 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab1JNReh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:34:37 -0400
Message-ID: <4E9872A2.2070203@panasas.com>
Date: Fri, 14 Oct 2011 19:34:26 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Welch, Brent" <welch@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: [PATCH 2/6] ore: RAID5 read
References: <4E98703E.7040605@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch introduces the first stage of RAID5 support
mainly the skip-over-raid-units when reading. For
writes it inserts BLANK units, into where XOR blocks
should be calculated and written to.

It introduces the new "general raid maths", and the main
additional parameters and components needed for raid5.

Since at this stage it could corrupt future version that
actually do support raid5. The enablement of raid5
mounting and setting of parity-count > 0 is disabled. So
the raid5 code will never be used. Mounting of raid5 is
only enabled later once the basic XOR write is also in.
But if the patch "enable RAID5" is applied this code has
been tested to be able to properly read raid5 volumes
and is according to standard.

Also it has been tested that the new maths still properly
supports RAID0 and grouping code just as before.
(BTW: I have found more bugs in the pnfs-obj RAID math
 fixed here)

The ore.c file is getting too big, so new ore_raid.[hc]
files are added that will include the special raid stuff
that are not used in striping and mirrors. In future write
support these will get bigger.
When adding the ore_raid.c to Kbuild file I was forced to
rename ore.ko to libore.ko. Is it possible to keep source
file, say ore.c and module file ore.ko the same even if there
are multiple files inside ore.ko?

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/Kbuild        |    3 +-
 fs/exofs/ore.c         |  326 ++++++++++++++++++++++++++++++++++++-----------
 fs/exofs/ore_raid.c    |  140 +++++++++++++++++++++
 fs/exofs/ore_raid.h    |   64 ++++++++++
 include/scsi/osd_ore.h |   21 +++-
 5 files changed, 473 insertions(+), 81 deletions(-)
 create mode 100644 fs/exofs/ore_raid.c
 create mode 100644 fs/exofs/ore_raid.h

diff --git a/fs/exofs/Kbuild b/fs/exofs/Kbuild
index c5a5855..352ba14 100644
--- a/fs/exofs/Kbuild
+++ b/fs/exofs/Kbuild
@@ -13,7 +13,8 @@
 #
 
 # ore module library
-obj-$(CONFIG_ORE) += ore.o
+libore-y := ore.o ore_raid.o
+obj-$(CONFIG_ORE) += libore.o
 
 exofs-y := inode.o file.o symlink.o namei.o dir.o super.o
 obj-$(CONFIG_EXOFS_FS) += exofs.o
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index d92998d..fd6090d 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -24,24 +24,9 @@
 
 #include <linux/slab.h>
 #include <asm/div64.h>
+#include <linux/lcm.h>
 
-#include <scsi/osd_ore.h>
-
-#define ORE_ERR(fmt, a...) printk(KERN_ERR "ore: " fmt, ##a)
-
-#ifdef CONFIG_EXOFS_DEBUG
-#define ORE_DBGMSG(fmt, a...) \
-	printk(KERN_NOTICE "ore @%s:%d: " fmt, __func__, __LINE__, ##a)
-#else
-#define ORE_DBGMSG(fmt, a...) \
-	do { if (0) printk(fmt, ##a); } while (0)
-#endif
-
-/* u64 has problems with printk this will cast it to unsigned long long */
-#define _LLU(x) (unsigned long long)(x)
-
-#define ORE_DBGMSG2(M...) do {} while (0)
-/* #define ORE_DBGMSG2 ORE_DBGMSG */
+#include "ore_raid.h"
 
 MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
 MODULE_DESCRIPTION("Objects Raid Engine ore.ko");
@@ -133,21 +118,81 @@ static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 	return ore_comp_dev(ios->oc, index);
 }
 
-static int  _get_io_state(struct ore_layout *layout,
-			  struct ore_components *oc, unsigned numdevs,
-			  struct ore_io_state **pios)
+static int  _ore_get_io_state(struct ore_layout *layout,
+			struct ore_components *oc, unsigned numdevs,
+			unsigned sgs_per_dev, unsigned num_par_pages,
+			struct ore_io_state **pios)
 {
 	struct ore_io_state *ios;
+	struct page **pages;
+	struct osd_sg_entry *sgilist;
+	struct __alloc_all_io_state {
+		struct ore_io_state ios;
+		struct ore_per_dev_state per_dev[numdevs];
+		union {
+			struct osd_sg_entry sglist[sgs_per_dev * numdevs];
+			struct page *pages[num_par_pages];
+		};
+	} *_aios;
+
+	if (likely(sizeof(*_aios) <= PAGE_SIZE)) {
+		_aios = kzalloc(sizeof(*_aios), GFP_KERNEL);
+		if (unlikely(!_aios)) {
+			ORE_DBGMSG("Failed kzalloc bytes=%zd\n",
+				   sizeof(*_aios));
+			*pios = NULL;
+			return -ENOMEM;
+		}
+		pages = num_par_pages ? _aios->pages : NULL;
+		sgilist = sgs_per_dev ? _aios->sglist : NULL;
+		ios = &_aios->ios;
+	} else {
+		struct __alloc_small_io_state {
+			struct ore_io_state ios;
+			struct ore_per_dev_state per_dev[numdevs];
+		} *_aio_small;
+		union __extra_part {
+			struct osd_sg_entry sglist[sgs_per_dev * numdevs];
+			struct page *pages[num_par_pages];
+		} *extra_part;
+
+		_aio_small = kzalloc(sizeof(*_aio_small), GFP_KERNEL);
+		if (unlikely(!_aio_small)) {
+			ORE_DBGMSG("Failed alloc first part bytes=%zd\n",
+				   sizeof(*_aio_small));
+			*pios = NULL;
+			return -ENOMEM;
+		}
+		extra_part = kzalloc(sizeof(*extra_part), GFP_KERNEL);
+		if (unlikely(!extra_part)) {
+			ORE_DBGMSG("Failed alloc second part bytes=%zd\n",
+				   sizeof(*extra_part));
+			kfree(_aio_small);
+			*pios = NULL;
+			return -ENOMEM;
+		}
 
-	/*TODO: Maybe use kmem_cach per sbi of size
-	 * exofs_io_state_size(layout->s_numdevs)
-	 */
-	ios = kzalloc(ore_io_state_size(numdevs), GFP_KERNEL);
-	if (unlikely(!ios)) {
-		ORE_DBGMSG("Failed kzalloc bytes=%d\n",
-			   ore_io_state_size(numdevs));
-		*pios = NULL;
-		return -ENOMEM;
+		pages = num_par_pages ? extra_part->pages : NULL;
+		sgilist = sgs_per_dev ? extra_part->sglist : NULL;
+		/* In this case the per_dev[0].sgilist holds the pointer to
+		 * be freed
+		 */
+		ios = &_aio_small->ios;
+		ios->extra_part_alloc = true;
+	}
+
+	if (pages) {
+		ios->parity_pages = pages;
+		ios->max_par_pages = num_par_pages;
+	}
+	if (sgilist) {
+		unsigned d;
+
+		for (d = 0; d < numdevs; ++d) {
+			ios->per_dev[d].sglist = sgilist;
+			sgilist += sgs_per_dev;
+		}
+		ios->sgs_per_dev = sgs_per_dev;
 	}
 
 	ios->layout = layout;
@@ -178,9 +223,42 @@ int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
 {
 	struct ore_io_state *ios;
 	unsigned numdevs = layout->group_width * layout->mirrors_p1;
+	unsigned sgs_per_dev = 0, max_par_pages = 0;
 	int ret;
 
-	ret = _get_io_state(layout, oc, numdevs, pios);
+	if (layout->parity && length) {
+		unsigned data_devs = layout->group_width - layout->parity;
+		unsigned stripe_size = layout->stripe_unit * data_devs;
+		unsigned pages_in_unit = layout->stripe_unit / PAGE_SIZE;
+		u32 remainder;
+		u64 num_stripes;
+		u64 num_raid_units;
+
+		num_stripes = div_u64_rem(length, stripe_size, &remainder);
+		if (remainder)
+			++num_stripes;
+
+		num_raid_units =  num_stripes * layout->parity;
+
+		if (is_reading) {
+			/* For reads add per_dev sglist array */
+			/* TODO: Raid 6 we need twice more. Actually:
+			*         num_stripes / LCMdP(W,P);
+			*         if (W%P != 0) num_stripes *= parity;
+			*/
+
+			/* first/last seg is split */
+			num_raid_units += layout->group_width;
+			sgs_per_dev = div_u64(num_raid_units, data_devs);
+		} else {
+			/* For Writes add parity pages array. */
+			max_par_pages = num_raid_units * pages_in_unit *
+						sizeof(struct page *);
+		}
+	}
+
+	ret = _ore_get_io_state(layout, oc, numdevs, sgs_per_dev, max_par_pages,
+				pios);
 	if (unlikely(ret))
 		return ret;
 
@@ -189,10 +267,11 @@ int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
 	ios->offset = offset;
 
 	if (length) {
-		ore_calc_stripe_info(layout, offset, &ios->si);
-		ios->length = (length <= ios->si.group_length) ? length :
-							ios->si.group_length;
+		ore_calc_stripe_info(layout, offset, length, &ios->si);
+		ios->length = ios->si.length;
 		ios->nr_pages = (ios->length + PAGE_SIZE - 1) / PAGE_SIZE;
+		if (layout->parity)
+			_ore_post_alloc_raid_stuff(ios);
 	}
 
 	return 0;
@@ -209,7 +288,7 @@ EXPORT_SYMBOL(ore_get_rw_state);
 int  ore_get_io_state(struct ore_layout *layout, struct ore_components *oc,
 		      struct ore_io_state **pios)
 {
-	return _get_io_state(layout, oc, oc->numdevs, pios);
+	return _ore_get_io_state(layout, oc, oc->numdevs, 0, 0, pios);
 }
 EXPORT_SYMBOL(ore_get_io_state);
 
@@ -227,6 +306,7 @@ void ore_put_io_state(struct ore_io_state *ios)
 				bio_put(per_dev->bio);
 		}
 
+		_ore_free_raid_stuff(ios);
 		kfree(ios);
 	}
 }
@@ -367,53 +447,65 @@ EXPORT_SYMBOL(ore_check_io);
 /*
  * L - logical offset into the file
  *
- * U - The number of bytes in a stripe within a group
+ * D - number of Data devices
+ *	D = group_width - parity
  *
- *	U = stripe_unit * group_width
+ * U - The number of bytes in a stripe within a group
+ *	U =  stripe_unit * D
  *
  * T - The number of bytes striped within a group of component objects
  *     (before advancing to the next group)
- *
- *	T = stripe_unit * group_width * group_depth
+ *	T = U * group_depth
  *
  * S - The number of bytes striped across all component objects
  *     before the pattern repeats
+ *	S = T * group_count
  *
- *	S = stripe_unit * group_width * group_depth * group_count
- *
- * M - The "major" (i.e., across all components) stripe number
- *
+ * M - The "major" (i.e., across all components) cycle number
  *	M = L / S
  *
- * G - Counts the groups from the beginning of the major stripe
- *
+ * G - Counts the groups from the beginning of the major cycle
  *	G = (L - (M * S)) / T	[or (L % S) / T]
  *
  * H - The byte offset within the group
- *
  *	H = (L - (M * S)) % T	[or (L % S) % T]
  *
  * N - The "minor" (i.e., across the group) stripe number
- *
  *	N = H / U
  *
  * C - The component index coresponding to L
  *
- *	C = (H - (N * U)) / stripe_unit + G * group_width
- *	[or (L % U) / stripe_unit + G * group_width]
+ *	C = (H - (N * U)) / stripe_unit + G * D
+ *	[or (L % U) / stripe_unit + G * D]
  *
  * O - The component offset coresponding to L
- *
  *	O = L % stripe_unit + N * stripe_unit + M * group_depth * stripe_unit
+ *
+ * LCMdP – Parity cycle: Lowest Common Multiple of group_width, parity
+ *          divide by parity
+ *	LCMdP = lcm(group_width, parity) / parity
+ *
+ * R - The parity Rotation stripe
+ *     (Note parity cycle always starts at a group's boundary)
+ *	R = N % LCMdP
+ *
+ * I = the first parity device index
+ *	I = (group_width + group_width - R*parity - parity) % group_width
+ *
+ * Craid - The component index Rotated
+ *	Craid = (group_width + C - R*parity) % group_width
+ *      (We add the group_width to avoid negative numbers modulo math)
  */
 void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
-			  struct ore_striping_info *si)
+			  u64 length, struct ore_striping_info *si)
 {
 	u32	stripe_unit = layout->stripe_unit;
 	u32	group_width = layout->group_width;
 	u64	group_depth = layout->group_depth;
+	u32	parity      = layout->parity;
 
-	u32	U = stripe_unit * group_width;
+	u32	D = group_width - parity;
+	u32	U = D * stripe_unit;
 	u64	T = U * group_depth;
 	u64	S = T * layout->group_count;
 	u64	M = div64_u64(file_offset, S);
@@ -429,22 +521,43 @@ void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 	u32	N = div_u64(H, U);
 
 	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
-	si->dev = (u32)(H - (N * U)) / stripe_unit + G * group_width;
-	si->dev *= layout->mirrors_p1;
+	u32	C = (u32)(H - (N * U)) / stripe_unit + G * group_width;
 
 	div_u64_rem(file_offset, stripe_unit, &si->unit_off);
 
 	si->obj_offset = si->unit_off + (N * stripe_unit) +
 				  (M * group_depth * stripe_unit);
 
-	si->group_length = T - H;
+	if (parity) {
+		u32 LCMdP = lcm(group_width, parity) / parity;
+		/* R     = N % LCMdP; */
+		u32 RxP   = (N % LCMdP) * parity;
+		u32 first_dev = C - C % group_width;
+
+		si->par_dev = (group_width + group_width - parity - RxP) %
+			      group_width + first_dev;
+		si->dev = (group_width + C - RxP) % group_width + first_dev;
+		si->bytes_in_stripe = U;
+		si->first_stripe_start = M * S + G * T + N * U;
+	} else {
+		/* Make the math correct see _prepare_one_group */
+		si->par_dev = group_width;
+		si->dev = C;
+	}
+
+	si->dev *= layout->mirrors_p1;
+	si->par_dev *= layout->mirrors_p1;
+	si->offset = file_offset;
+	si->length = T - H;
+	if (si->length > length)
+		si->length = length;
 	si->M = M;
 }
 EXPORT_SYMBOL(ore_calc_stripe_info);
 
-static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
-		unsigned pgbase, struct ore_per_dev_state *per_dev,
-		int cur_len)
+int _ore_add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
+			 unsigned pgbase, struct page **pages,
+			 struct ore_per_dev_state *per_dev, int cur_len)
 {
 	unsigned pg = *cur_pg;
 	struct request_queue *q =
@@ -455,8 +568,11 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 	if (per_dev->bio == NULL) {
 		unsigned pages_in_stripe = ios->layout->group_width *
 					(ios->layout->stripe_unit / PAGE_SIZE);
-		unsigned bio_size = (ios->nr_pages + pages_in_stripe) /
-						ios->layout->group_width;
+		unsigned nr_pages = ios->nr_pages * ios->layout->group_width /
+					(ios->layout->group_width -
+					 ios->layout->parity);
+		unsigned bio_size = (nr_pages + pages_in_stripe) /
+					ios->layout->group_width;
 
 		per_dev->bio = bio_kmalloc(GFP_KERNEL, bio_size);
 		if (unlikely(!per_dev->bio)) {
@@ -471,12 +587,13 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 		unsigned pglen = min_t(unsigned, PAGE_SIZE - pgbase, cur_len);
 		unsigned added_len;
 
-		BUG_ON(ios->nr_pages <= pg);
 		cur_len -= pglen;
 
-		added_len = bio_add_pc_page(q, per_dev->bio, ios->pages[pg],
+		added_len = bio_add_pc_page(q, per_dev->bio, pages[pg],
 					    pglen, pgbase);
 		if (unlikely(pglen != added_len)) {
+			ORE_DBGMSG("Failed bio_add_pc_page bi_vcnt=%u\n",
+				   per_dev->bio->bi_vcnt);
 			ret = -ENOMEM;
 			goto out;
 		}
@@ -501,9 +618,11 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	struct ore_striping_info *si = &ios->si;
 	unsigned stripe_unit = ios->layout->stripe_unit;
 	unsigned mirrors_p1 = ios->layout->mirrors_p1;
-	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
+	unsigned group_width = ios->layout->group_width;
+	unsigned devs_in_group = group_width * mirrors_p1;
 	unsigned dev = si->dev;
 	unsigned first_dev = dev - (dev % devs_in_group);
+	unsigned dev_order;
 	unsigned cur_pg = ios->pages_consumed;
 	u64 length = ios->length;
 	int ret = 0;
@@ -513,7 +632,10 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		return 0;
 	}
 
-	BUG_ON(length > si->group_length);
+	BUG_ON(length > si->length);
+
+	dev_order = _dev_order(devs_in_group, mirrors_p1, si->par_dev, dev);
+	si->cur_comp = dev_order;
 
 	while (length) {
 		unsigned comp = dev - first_dev;
@@ -522,17 +644,20 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 
 		if (!per_dev->length) {
 			per_dev->dev = dev;
-			if (dev < si->dev) {
-				per_dev->offset = si->obj_offset + stripe_unit -
-								   si->unit_off;
-				cur_len = stripe_unit;
-			} else if (dev == si->dev) {
+			if (dev == si->dev) {
+				WARN_ON(dev == si->par_dev);
 				per_dev->offset = si->obj_offset;
 				cur_len = stripe_unit - si->unit_off;
 				page_off = si->unit_off & ~PAGE_MASK;
 				BUG_ON(page_off && (page_off != ios->pgbase));
-			} else { /* dev > si->dev */
-				per_dev->offset = si->obj_offset - si->unit_off;
+			} else {
+				if (si->cur_comp > dev_order)
+					per_dev->offset =
+						si->obj_offset - si->unit_off;
+				else /* si->cur_comp < dev_order */
+					per_dev->offset =
+						si->obj_offset + stripe_unit -
+								   si->unit_off;
 				cur_len = stripe_unit;
 			}
 		} else {
@@ -541,8 +666,8 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		if (cur_len >= length)
 			cur_len = length;
 
-		ret = _add_stripe_unit(ios, &cur_pg, page_off , per_dev,
-				       cur_len);
+		ret = _ore_add_stripe_unit(ios, &cur_pg, page_off, ios->pages,
+					   per_dev, cur_len);
 		if (unlikely(ret))
 			goto out;
 
@@ -550,6 +675,41 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		dev = (dev % devs_in_group) + first_dev;
 
 		length -= cur_len;
+
+		si->cur_comp = (si->cur_comp + 1) % group_width;
+		if (unlikely((dev == si->par_dev) ||
+			     (!length && ios->parity_pages))) {
+			if (!length)
+				/* If we are writing and this is the very last
+				 * stripe. then operate on parity dev.
+				 */
+				dev = si->par_dev;
+			if (ios->reading)
+				/* In writes cur_len just means if it's the
+				 * last one. See _ore_add_parity_unit.
+				 */
+				cur_len = length;
+			per_dev = &ios->per_dev[dev - first_dev];
+			if (!per_dev->length) {
+				/* Only/always the parity unit of the first
+				 * stripe will be empty. So this is a chance to
+				 * initialize the per_dev info.
+				 */
+				per_dev->dev = dev;
+				per_dev->offset = si->obj_offset - si->unit_off;
+			}
+
+			ret = _ore_add_parity_unit(ios, si, per_dev, cur_len);
+			if (unlikely(ret))
+					goto out;
+
+			/* Rotate next par_dev backwards with wraping */
+			si->par_dev = (devs_in_group + si->par_dev -
+				       ios->layout->parity * mirrors_p1) %
+				      devs_in_group + first_dev;
+			/* Next stripe, start fresh */
+			si->cur_comp = 0;
+		}
 	}
 out:
 	ios->numdevs = devs_in_group;
@@ -747,12 +907,24 @@ static int _read_mirror(struct ore_io_state *ios, unsigned cur_comp)
 	per_dev->or = or;
 
 	if (ios->pages) {
-		osd_req_read(or, obj, per_dev->offset,
-				per_dev->bio, per_dev->length);
+		if (per_dev->cur_sg) {
+			/* finalize the last sg_entry */
+			_ore_add_sg_seg(per_dev, 0, false);
+			if (unlikely(!per_dev->cur_sg))
+				return 0; /* Skip parity only device */
+
+			osd_req_read_sg(or, obj, per_dev->bio,
+					per_dev->sglist, per_dev->cur_sg);
+		} else {
+			/* The no raid case */
+			osd_req_read(or, obj, per_dev->offset,
+				     per_dev->bio, per_dev->length);
+		}
+
 		ORE_DBGMSG("read(0x%llx) offset=0x%llx length=0x%llx"
-			     " dev=%d\n", _LLU(obj->id),
+			     " dev=%d sg_len=%d\n", _LLU(obj->id),
 			     _LLU(per_dev->offset), _LLU(per_dev->length),
-			     first_dev);
+			     first_dev, per_dev->cur_sg);
 	} else {
 		BUG_ON(ios->kern_buff);
 
@@ -849,7 +1021,7 @@ static void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
 {
 	unsigned stripe_unit = layout->stripe_unit;
 
-	ore_calc_stripe_info(layout, file_offset, &ti->si);
+	ore_calc_stripe_info(layout, file_offset, 0, &ti->si);
 
 	ti->prev_group_obj_off = ti->si.M * stripe_unit;
 	ti->next_group_obj_off = ti->si.M ? (ti->si.M - 1) * stripe_unit : 0;
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
new file mode 100644
index 0000000..8d4b93a
--- /dev/null
+++ b/fs/exofs/ore_raid.c
@@ -0,0 +1,140 @@
+/*
+ * Copyright (C) 2011
+ * Boaz Harrosh <bharrosh@panasas.com>
+ *
+ * This file is part of the objects raid engine (ore).
+ *
+ * It is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with "ore". If not, write to the Free Software Foundation, Inc:
+ *	"Free Software Foundation <info@fsf.org>"
+ */
+
+#include <linux/gfp.h>
+
+#include "ore_raid.h"
+
+struct page *_raid_page_alloc(void)
+{
+	return alloc_page(GFP_KERNEL);
+}
+
+void _raid_page_free(struct page *p)
+{
+	__free_page(p);
+}
+
+void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
+		     bool not_last)
+{
+	struct osd_sg_entry *sge;
+
+	ORE_DBGMSG("dev=%d cur_len=0x%x not_last=%d cur_sg=%d "
+		     "offset=0x%llx length=0x%x last_sgs_total=0x%x\n",
+		     per_dev->dev, cur_len, not_last, per_dev->cur_sg,
+		     _LLU(per_dev->offset), per_dev->length,
+		     per_dev->last_sgs_total);
+
+	if (!per_dev->cur_sg) {
+		sge = per_dev->sglist;
+
+		/* First time we prepare two entries */
+		if (per_dev->length) {
+			++per_dev->cur_sg;
+			sge->offset = per_dev->offset;
+			sge->len = per_dev->length;
+		} else {
+			/* Here the parity is the first unit of this object.
+			 * This happens every time we reach a parity device on
+			 * the same stripe as the per_dev->offset. We need to
+			 * just skip this unit.
+			 */
+			per_dev->offset += cur_len;
+			return;
+		}
+	} else {
+		/* finalize the last one */
+		sge = &per_dev->sglist[per_dev->cur_sg - 1];
+		sge->len = per_dev->length - per_dev->last_sgs_total;
+	}
+
+	if (not_last) {
+		/* Partly prepare the next one */
+		struct osd_sg_entry *next_sge = sge + 1;
+
+		++per_dev->cur_sg;
+		next_sge->offset = sge->offset + sge->len + cur_len;
+		/* Save cur len so we know how mutch was added next time */
+		per_dev->last_sgs_total = per_dev->length;
+		next_sge->len = 0;
+	} else if (!sge->len) {
+		/* Optimize for when the last unit is a parity */
+		--per_dev->cur_sg;
+	}
+}
+
+/* In writes @cur_len means length left. .i.e cur_len==0 is the last parity U */
+int _ore_add_parity_unit(struct ore_io_state *ios,
+			    struct ore_striping_info *si,
+			    struct ore_per_dev_state *per_dev,
+			    unsigned cur_len)
+{
+	if (ios->reading) {
+		BUG_ON(per_dev->cur_sg >= ios->sgs_per_dev);
+		_ore_add_sg_seg(per_dev, cur_len, true);
+	} else {
+		struct page **pages = ios->parity_pages + ios->cur_par_page;
+		unsigned num_pages = ios->layout->stripe_unit / PAGE_SIZE;
+		unsigned array_start = 0;
+		unsigned i;
+		int ret;
+
+		for (i = 0; i < num_pages; i++) {
+			pages[i] = _raid_page_alloc();
+			if (unlikely(!pages[i]))
+				return -ENOMEM;
+
+			++(ios->cur_par_page);
+			/* TODO: only read support for now */
+			clear_highpage(pages[i]);
+		}
+
+		ORE_DBGMSG("writing dev=%d num_pages=%d cur_par_page=%d",
+			     per_dev->dev, num_pages, ios->cur_par_page);
+
+		ret = _ore_add_stripe_unit(ios,  &array_start, 0, pages,
+					   per_dev, num_pages * PAGE_SIZE);
+		if (unlikely(ret))
+			return ret;
+	}
+	return 0;
+}
+
+int _ore_post_alloc_raid_stuff(struct ore_io_state *ios)
+{
+	/*TODO: Only raid writes has stuff to add here */
+	return 0;
+}
+
+void _ore_free_raid_stuff(struct ore_io_state *ios)
+{
+	if (ios->parity_pages) { /* writing and raid */
+		unsigned i;
+
+		for (i = 0; i < ios->cur_par_page; i++) {
+			struct page *page = ios->parity_pages[i];
+
+			if (page)
+				_raid_page_free(page);
+		}
+		if (ios->extra_part_alloc)
+			kfree(ios->parity_pages);
+	} else {
+		/* Will only be set if raid reading && sglist is big */
+		if (ios->extra_part_alloc)
+			kfree(ios->per_dev[0].sglist);
+	}
+}
diff --git a/fs/exofs/ore_raid.h b/fs/exofs/ore_raid.h
new file mode 100644
index 0000000..c21080b
--- /dev/null
+++ b/fs/exofs/ore_raid.h
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) from 2011
+ * Boaz Harrosh <bharrosh@panasas.com>
+ *
+ * This file is part of the objects raid engine (ore).
+ *
+ * It is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with "ore". If not, write to the Free Software Foundation, Inc:
+ *	"Free Software Foundation <info@fsf.org>"
+ */
+
+#include <scsi/osd_ore.h>
+
+#define ORE_ERR(fmt, a...) printk(KERN_ERR "ore: " fmt, ##a)
+
+#ifdef CONFIG_EXOFS_DEBUG
+#define ORE_DBGMSG(fmt, a...) \
+	printk(KERN_NOTICE "ore @%s:%d: " fmt, __func__, __LINE__, ##a)
+#else
+#define ORE_DBGMSG(fmt, a...) \
+	do { if (0) printk(fmt, ##a); } while (0)
+#endif
+
+/* u64 has problems with printk this will cast it to unsigned long long */
+#define _LLU(x) (unsigned long long)(x)
+
+#define ORE_DBGMSG2(M...) do {} while (0)
+/* #define ORE_DBGMSG2 ORE_DBGMSG */
+
+/* Calculate the component order in a stripe. eg the logical data unit
+ * address within the stripe of @dev given the @par_dev of this stripe.
+ */
+static inline unsigned _dev_order(unsigned devs_in_group, unsigned mirrors_p1,
+				  unsigned par_dev, unsigned dev)
+{
+	unsigned first_dev = dev - dev % devs_in_group;
+
+	dev -= first_dev;
+	par_dev -= first_dev;
+
+	if (devs_in_group == par_dev) /* The raid 0 case */
+		return dev / mirrors_p1;
+	/* raid4/5/6 case */
+	return ((devs_in_group + dev - par_dev - mirrors_p1) % devs_in_group) /
+	       mirrors_p1;
+}
+
+/* ios_raid.c stuff needed by ios.c */
+int _ore_post_alloc_raid_stuff(struct ore_io_state *ios);
+void _ore_free_raid_stuff(struct ore_io_state *ios);
+
+void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
+		 bool not_last);
+int _ore_add_parity_unit(struct ore_io_state *ios, struct ore_striping_info *si,
+		     struct ore_per_dev_state *per_dev, unsigned cur_len);
+
+/* ios.c stuff needed by ios_raid.c */
+int _ore_add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
+		unsigned pgbase, struct page **pages,
+		struct ore_per_dev_state *per_dev, int cur_len);
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index a8e39d1..43821c1 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -40,6 +40,7 @@ struct ore_layout {
 	unsigned mirrors_p1;
 
 	unsigned group_width;
+	unsigned parity;
 	u64	 group_depth;
 	unsigned group_count;
 
@@ -89,11 +90,16 @@ static inline void ore_comp_set_dev(
 }
 
 struct ore_striping_info {
+	u64 offset;
 	u64 obj_offset;
-	u64 group_length;
+	u64 length;
+	u64 first_stripe_start; /* only used in raid writes */
 	u64 M; /* for truncate */
+	unsigned bytes_in_stripe;
 	unsigned dev;
+	unsigned par_dev;
 	unsigned unit_off;
+	unsigned cur_comp;
 };
 
 struct ore_io_state;
@@ -127,6 +133,13 @@ struct ore_io_state {
 
 	bool			reading;
 
+	/* House keeping of Parity pages */
+	bool			extra_part_alloc;
+	struct page		**parity_pages;
+	unsigned		max_par_pages;
+	unsigned		cur_par_page;
+	unsigned		sgs_per_dev;
+
 	/* Variable array of size numdevs */
 	unsigned numdevs;
 	struct ore_per_dev_state {
@@ -134,7 +147,10 @@ struct ore_io_state {
 		struct bio *bio;
 		loff_t offset;
 		unsigned length;
+		unsigned last_sgs_total;
 		unsigned dev;
+		struct osd_sg_entry *sglist;
+		unsigned cur_sg;
 	} per_dev[];
 };
 
@@ -147,8 +163,7 @@ static inline unsigned ore_io_state_size(unsigned numdevs)
 /* ore.c */
 int ore_verify_layout(unsigned total_comps, struct ore_layout *layout);
 void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
-			  struct ore_striping_info *si);
-
+			  u64 length, struct ore_striping_info *si);
 int ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 		     bool is_reading, u64 offset, u64 length,
 		     struct ore_io_state **ios);
-- 
1.7.2.3

