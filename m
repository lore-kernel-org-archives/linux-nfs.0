Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:57783
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752402AbaEVNJI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 09:09:08 -0400
Message-ID: <537DF6E8.8070004@panasas.com>
Date: Thu, 22 May 2014 16:08:56 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        Daniel Gryniewicz <dang@linuxbox.com>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        "Pathak, Santosh" <santoshp@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Benny Halevy <bhalevy@primarydata.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>
Subject: [PATCH 2/3] ore: Remove redundant dev_order(), more cleanups
References: <537DF5B4.4070001@panasas.com>
In-Reply-To: <537DF5B4.4070001@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Two cleanups:
* si->cur_comp, si->cur_pg where always calculated after
  the call to ore_calc_stripe_info() with the help of
  _dev_order(...). But these are already calculated by
  ore_calc_stripe_info() and can be just set there.
  (This is left over from the time that si->cur_comp, si->cur_pg
   were only used by raid code, but now the main loop manages
   them anyway even though they are ultimately not used in
   none raid code)

* si->cur_comp - For the very last stripe case, was set inside
  _ore_add_parity_unit(). This is not clear and will be wrong
  for coming raid6 so move this to only caller. Now si->cur_comp
  is only manipulated within _prepare_for_striping(), always next
  to the manipulation of cur_dev.
  Which is much easier to understand and follow.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c      | 10 ++++++----
 fs/exofs/ore_raid.c | 13 ++++---------
 fs/exofs/ore_raid.h | 18 ------------------
 3 files changed, 10 insertions(+), 31 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 92157b6..0e2a835 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -545,17 +545,19 @@ void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
 
 	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
 	u32	C = (u32)(H - (N * U)) / stripe_unit + G * group_width;
+	u32 first_dev = C - C % group_width;
 
 	div_u64_rem(file_offset, stripe_unit, &si->unit_off);
 
 	si->obj_offset = si->unit_off + (N * stripe_unit) +
 				  (M * group_depth * stripe_unit);
+	si->cur_comp = C - first_dev;
+	si->cur_pg = si->unit_off / PAGE_SIZE;
 
 	if (parity) {
 		u32 LCMdP = lcm(group_width, parity) / parity;
 		/* R     = N % LCMdP; */
 		u32 RxP   = (N % LCMdP) * parity;
-		u32 first_dev = C - C % group_width;
 
 		si->par_dev = (group_width + group_width - parity - RxP) %
 			      group_width + first_dev;
@@ -670,9 +672,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 
 	BUG_ON(length > si->length);
 
-	dev_order = _dev_order(devs_in_group, mirrors_p1, si->par_dev, dev);
-	si->cur_comp = dev_order;
-	si->cur_pg = si->unit_off / PAGE_SIZE;
+	dev_order = si->cur_comp;
 
 	while (length) {
 		struct ore_per_dev_state *per_dev =
@@ -718,6 +718,8 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 				 * stripe. then operate on parity dev.
 				 */
 				dev = si->par_dev;
+				/* If last stripe operate on parity comp */
+				si->cur_comp = group_width - ios->layout->parity;
 			}
 			per_dev = &ios->per_dev[dev - first_dev];
 			if (!per_dev->length) {
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index af417d3..d58a952 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -402,9 +402,8 @@ static int _add_to_r4w_last_page(struct ore_io_state *ios, u64 *offset)
 
 	ore_calc_stripe_info(ios->layout, *offset, 0, &si);
 
-	p = si.unit_off / PAGE_SIZE;
-	c = _dev_order(ios->layout->group_width * ios->layout->mirrors_p1,
-		       ios->layout->mirrors_p1, si.par_dev, si.dev);
+	p = si.cur_pg;
+	c = si.cur_comp;
 	page = ios->sp2d->_1p_stripes[p].pages[c];
 
 	pg_len = PAGE_SIZE - (si.unit_off % PAGE_SIZE);
@@ -532,9 +531,8 @@ static int _read_4_write_last_stripe(struct ore_io_state *ios)
 		goto read_it;
 
 	ore_calc_stripe_info(ios->layout, offset, 0, &read_si);
-	p = read_si.unit_off / PAGE_SIZE;
-	c = _dev_order(ios->layout->group_width * ios->layout->mirrors_p1,
-		       ios->layout->mirrors_p1, read_si.par_dev, read_si.dev);
+	p = read_si.cur_pg;
+	c = read_si.cur_comp;
 
 	if (min_p == sp2d->pages_in_unit) {
 		/* Didn't do it yet */
@@ -638,9 +636,6 @@ int _ore_add_parity_unit(struct ore_io_state *ios,
 		si->cur_pg = _sp2d_min_pg(sp2d);
 		num_pages  = _sp2d_max_pg(sp2d) + 1 - si->cur_pg;
 
-		if (!cur_len) /* If last stripe operate on parity comp */
-			si->cur_comp = sp2d->data_devs;
-
 		if (!per_dev->length) {
 			per_dev->offset += si->cur_pg * PAGE_SIZE;
 			/* If first stripe, Read in all read4write pages
diff --git a/fs/exofs/ore_raid.h b/fs/exofs/ore_raid.h
index 2ffd2c3..d365bda 100644
--- a/fs/exofs/ore_raid.h
+++ b/fs/exofs/ore_raid.h
@@ -31,24 +31,6 @@
 #define ORE_DBGMSG2(M...) do {} while (0)
 /* #define ORE_DBGMSG2 ORE_DBGMSG */
 
-/* Calculate the component order in a stripe. eg the logical data unit
- * address within the stripe of @dev given the @par_dev of this stripe.
- */
-static inline unsigned _dev_order(unsigned devs_in_group, unsigned mirrors_p1,
-				  unsigned par_dev, unsigned dev)
-{
-	unsigned first_dev = dev - dev % devs_in_group;
-
-	dev -= first_dev;
-	par_dev -= first_dev;
-
-	if (devs_in_group == par_dev) /* The raid 0 case */
-		return dev / mirrors_p1;
-	/* raid4/5/6 case */
-	return ((devs_in_group + dev - par_dev - mirrors_p1) % devs_in_group) /
-	       mirrors_p1;
-}
-
 /* ios_raid.c stuff needed by ios.c */
 int _ore_post_alloc_raid_stuff(struct ore_io_state *ios);
 void _ore_free_raid_stuff(struct ore_io_state *ios);
-- 
1.9.0


