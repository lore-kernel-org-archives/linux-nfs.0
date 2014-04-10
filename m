Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:35396
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965609AbaDJLA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 07:00:28 -0400
Message-ID: <534679BD.4020201@panasas.com>
Date: Thu, 10 Apr 2014 14:00:13 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        Daniel Gryniewicz <dang@linuxbox.com>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        "Pathak, Santosh" <santoshp@panasas.com>
CC: Benny Halevy <bhalevy@primarydata.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>
Subject: [PATCH 3/3] ore: Support for raid 6
References: <53467667.3010304@panasas.com>
In-Reply-To: <53467667.3010304@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This simple patch adds support for raid6 to the ORE.
Most operations and calculations where already for the general
case. Only things left:
* call async_gen_syndrome() in the case of raid6
  (NOTE that the raid6 math is the one supported by the Linux Kernel
   see: crypto/async_tx/async_pq.c)
* call _ore_add_parity_unit() twice with only last call generating
  the redundancy pages.

* Fix couple BUGS in old code
  a. In reads when parity==2 it can happen that per_dev->length=0
     but per_dev->offset was set and adjusted by _ore_add_sg_seg().
     Don't let it be overwritten.
  b. The all 'cur_comp > starting_dev' thing to determine if:
       "per_dev->offset is in the current stripe number or the
       next one."
     Was a complete raid5/4 *accident*. When parity==2 this is not
     at all true usually. All we need to do is increment si->ob_offset
     once we pass by the first parity device.
     (This also greatly simplifies the code, amen)
  c. Calculation of si->dev rotation can overflow when parity==2.

* Then last enable raid6 in ore_verify_layout()

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/Kconfig.ore |  2 ++
 fs/exofs/ore.c       | 77 ++++++++++++++++++++++++++++++++++++----------------
 fs/exofs/ore_raid.c  | 37 ++++++++++++++++---------
 fs/exofs/ore_raid.h  |  3 +-
 4 files changed, 81 insertions(+), 38 deletions(-)

diff --git a/fs/exofs/Kconfig.ore b/fs/exofs/Kconfig.ore
index 1ca7fb7..2daf232 100644
--- a/fs/exofs/Kconfig.ore
+++ b/fs/exofs/Kconfig.ore
@@ -9,4 +9,6 @@ config ORE
 	tristate
 	depends on EXOFS_FS || PNFS_OBJLAYOUT
 	select ASYNC_XOR
+	select RAID6_PQ
+	select ASYNC_PQ
 	default SCSI_OSD_ULD
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 2de488d..cfc0205 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -58,9 +58,12 @@ int ore_verify_layout(unsigned total_comps, struct ore_layout *layout)
 		layout->parity = 1;
 		break;
 	case PNFS_OSD_RAID_PQ:
+		layout->parity = 2;
+		break;
 	case PNFS_OSD_RAID_4:
 	default:
-		ORE_ERR("Only RAID_0/5 for now\n");
+		ORE_ERR("Only RAID_0/5/6 for now received-enum=%d\n",
+			layout->raid_algorithm);
 		return -EINVAL;
 	}
 	if (0 != (layout->stripe_unit & ~PAGE_MASK)) {
@@ -112,6 +115,8 @@ int ore_verify_layout(unsigned total_comps, struct ore_layout *layout)
 		layout->max_io_length /= stripe_length;
 		layout->max_io_length *= stripe_length;
 	}
+	ORE_DBGMSG("max_io_length=0x%lx\n", layout->max_io_length);
+
 	return 0;
 }
 EXPORT_SYMBOL(ore_verify_layout);
@@ -561,7 +566,8 @@ void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 
 		si->par_dev = (group_width + group_width - parity - RxP) %
 			      group_width + first_dev;
-		si->dev = (group_width + C - RxP) % group_width + first_dev;
+		si->dev = (group_width + group_width + C - RxP) %
+			  group_width + first_dev;
 		si->bytes_in_stripe = U;
 		si->first_stripe_start = M * S + G * T + N * U;
 	} else {
@@ -651,6 +657,43 @@ out:	/* we fail the complete unit on an error eg don't advance
 	return ret;
 }
 
+static int _add_parity_units(struct ore_io_state *ios,
+			     struct ore_striping_info *si,
+			     unsigned dev, unsigned first_dev,
+			     unsigned mirrors_p1, unsigned devs_in_group,
+			     unsigned cur_len)
+{
+	unsigned do_parity;
+	int ret = 0;
+
+	for (do_parity = ios->layout->parity; do_parity; --do_parity) {
+		struct ore_per_dev_state *per_dev;
+
+		per_dev = &ios->per_dev[dev - first_dev];
+		if (!per_dev->length && !per_dev->offset) {
+			/* Only/always the parity unit of the first
+			 * stripe will be empty. So this is a chance to
+			 * initialize the per_dev info.
+			 */
+			per_dev->dev = dev;
+			per_dev->offset = si->obj_offset - si->unit_off;
+		}
+
+		ret = _ore_add_parity_unit(ios, si, per_dev, cur_len,
+					   do_parity == 1);
+		if (unlikely(ret))
+				break;
+
+		if (do_parity != 1) {
+			dev = ((dev + mirrors_p1) % devs_in_group) + first_dev;
+			si->cur_comp = (si->cur_comp + 1) %
+						       ios->layout->group_width;
+		}
+	}
+
+	return ret;
+}
+
 static int _prepare_for_striping(struct ore_io_state *ios)
 {
 	struct ore_striping_info *si = &ios->si;
@@ -660,7 +703,6 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	unsigned devs_in_group = group_width * mirrors_p1;
 	unsigned dev = si->dev;
 	unsigned first_dev = dev - (dev % devs_in_group);
-	unsigned dev_order;
 	unsigned cur_pg = ios->pages_consumed;
 	u64 length = ios->length;
 	int ret = 0;
@@ -672,14 +714,13 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 
 	BUG_ON(length > si->length);
 
-	dev_order = si->cur_comp;
-
 	while (length) {
 		struct ore_per_dev_state *per_dev =
 						&ios->per_dev[dev - first_dev];
 		unsigned cur_len, page_off = 0;
 
-		if (!per_dev->length) {
+		if (!per_dev->length && !per_dev->offset) {
+			/* First time initialize the per_dev info. */
 			per_dev->dev = dev;
 			if (dev == si->dev) {
 				WARN_ON(dev == si->par_dev);
@@ -688,13 +729,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 				page_off = si->unit_off & ~PAGE_MASK;
 				BUG_ON(page_off && (page_off != ios->pgbase));
 			} else {
-				if (si->cur_comp > dev_order)
-					per_dev->offset =
-						si->obj_offset - si->unit_off;
-				else /* si->cur_comp < dev_order */
-					per_dev->offset =
-						si->obj_offset + stripe_unit -
-								   si->unit_off;
+				per_dev->offset = si->obj_offset - si->unit_off;
 				cur_len = stripe_unit;
 			}
 		} else {
@@ -721,21 +756,13 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 				/* If last stripe operate on parity comp */
 				si->cur_comp = group_width - ios->layout->parity;
 			}
-			per_dev = &ios->per_dev[dev - first_dev];
-			if (!per_dev->length) {
-				/* Only/always the parity unit of the first
-				 * stripe will be empty. So this is a chance to
-				 * initialize the per_dev info.
-				 */
-				per_dev->dev = dev;
-				per_dev->offset = si->obj_offset - si->unit_off;
-			}
 
 			/* In writes cur_len just means if it's the
 			 * last one. See _ore_add_parity_unit.
 			 */
-			ret = _ore_add_parity_unit(ios, si, per_dev,
-						   ios->sp2d : length : cur_len);
+			ret = _add_parity_units(ios, si, dev, first_dev,
+						mirrors_p1, devs_in_group,
+						ios->sp2d ? length : cur_len);
 			if (unlikely(ret))
 					goto out;
 
@@ -746,6 +773,8 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 			/* Next stripe, start fresh */
 			si->cur_comp = 0;
 			si->cur_pg = 0;
+			si->obj_offset += cur_len;
+			si->unit_off = 0;
 		}
 	}
 out:
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index d58a952..7f20f25 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -218,20 +218,28 @@ static unsigned _sp2d_max_pg(struct __stripe_pages_2d *sp2d)
 static void _gen_xor_unit(struct __stripe_pages_2d *sp2d)
 {
 	unsigned p;
+	unsigned tx_flags = ASYNC_TX_ACK;
+
+	if (sp2d->parity == 1)
+		tx_flags |= ASYNC_TX_XOR_ZERO_DST;
+
 	for (p = 0; p < sp2d->pages_in_unit; p++) {
 		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
 
 		if (!_1ps->write_count)
 			continue;
 
-		init_async_submit(&_1ps->submit,
-			ASYNC_TX_XOR_ZERO_DST | ASYNC_TX_ACK,
+		init_async_submit(&_1ps->submit, tx_flags,
 			NULL, NULL, NULL, (addr_conv_t *)_1ps->scribble);
 
-		/* TODO: raid6 */
-		_1ps->tx = async_xor(_1ps->pages[sp2d->data_devs], _1ps->pages,
-				     0, sp2d->data_devs, PAGE_SIZE,
-				     &_1ps->submit);
+		if (sp2d->parity == 1)
+			_1ps->tx = async_xor(_1ps->pages[sp2d->data_devs],
+						_1ps->pages, 0, sp2d->data_devs,
+						PAGE_SIZE, &_1ps->submit);
+		else /* parity == 2 */
+			_1ps->tx = async_gen_syndrome(_1ps->pages, 0,
+						sp2d->data_devs + sp2d->parity,
+						PAGE_SIZE, &_1ps->submit);
 	}
 
 	for (p = 0; p < sp2d->pages_in_unit; p++) {
@@ -616,7 +624,7 @@ static int _read_4_write_execute(struct ore_io_state *ios)
 int _ore_add_parity_unit(struct ore_io_state *ios,
 			    struct ore_striping_info *si,
 			    struct ore_per_dev_state *per_dev,
-			    unsigned cur_len)
+			    unsigned cur_len, bool do_xor)
 {
 	if (ios->reading) {
 		if (per_dev->cur_sg >= ios->sgs_per_dev) {
@@ -641,9 +649,11 @@ int _ore_add_parity_unit(struct ore_io_state *ios,
 			/* If first stripe, Read in all read4write pages
 			 * (if needed) before we calculate the first parity.
 			 */
-			_read_4_write_first_stripe(ios);
+			if (do_xor)
+				_read_4_write_first_stripe(ios);
 		}
-		if (!cur_len) /* If last stripe r4w pages of last stripe */
+		if (!cur_len && do_xor)
+			/* If last stripe r4w pages of last stripe */
 			_read_4_write_last_stripe(ios);
 		_read_4_write_execute(ios);
 
@@ -655,7 +665,7 @@ int _ore_add_parity_unit(struct ore_io_state *ios,
 			++(ios->cur_par_page);
 		}
 
-		BUG_ON(si->cur_comp != sp2d->data_devs);
+		BUG_ON(si->cur_comp < sp2d->data_devs);
 		BUG_ON(si->cur_pg + num_pages > sp2d->pages_in_unit);
 
 		ret = _ore_add_stripe_unit(ios,  &array_start, 0, pages,
@@ -663,9 +673,10 @@ int _ore_add_parity_unit(struct ore_io_state *ios,
 		if (unlikely(ret))
 			return ret;
 
-		/* TODO: raid6 if (last_parity_dev) */
-		_gen_xor_unit(sp2d);
-		_sp2d_reset(sp2d, ios->r4w, ios->private);
+		if (do_xor) {
+			_gen_xor_unit(sp2d);
+			_sp2d_reset(sp2d, ios->r4w, ios->private);
+		}
 	}
 	return 0;
 }
diff --git a/fs/exofs/ore_raid.h b/fs/exofs/ore_raid.h
index d365bda..cf6375d 100644
--- a/fs/exofs/ore_raid.h
+++ b/fs/exofs/ore_raid.h
@@ -38,7 +38,8 @@ void _ore_free_raid_stuff(struct ore_io_state *ios);
 void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
 		 bool not_last);
 int _ore_add_parity_unit(struct ore_io_state *ios, struct ore_striping_info *si,
-		     struct ore_per_dev_state *per_dev, unsigned cur_len);
+		     struct ore_per_dev_state *per_dev, unsigned cur_len,
+		     bool do_xor);
 void _ore_add_stripe_page(struct __stripe_pages_2d *sp2d,
 		       struct ore_striping_info *si, struct page *page);
 static inline void _add_stripe_page(struct __stripe_pages_2d *sp2d,
-- 
1.9.0


