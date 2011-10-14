Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33469 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab1JNRff (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:35:35 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 3/6] ore: RAID5 Write
Date: Fri, 14 Oct 2011 19:35:25 +0200
Message-ID: <1318613725-3776-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is finally the RAID5 Write support.

The bigger part of this patch is not the XOR engine itself, But the
read4write logic, which is a complete mini prepare_for_striping
reading engine that can read scattered pages of a stripe into cache
so it can be used for XOR calculation. That is, if the write was not
stripe aligned.

The main algorithm behind the XOR engine is the 2 dimensional array:
	struct __stripe_pages_2d.
A drawing might save 1000 words
---

__stripe_pages_2d
       |
 n = pages_in_stripe_unit;
 w = group_width - parity;
       |                            pages array presented to the XOR lib
       |                                                |
       V                                                |
 __1_page_stripe[0].pages --> [c0][c1]..[cw][c_par] <---|
       |                                                |
 __1_page_stripe[1].pages --> [c0][c1]..[cw][c_par] <---
       |
...    |                         ...
       |
 __1_page_stripe[n].pages --> [c0][c1]..[cw][c_par]
                               ^
                               |
           data added columns first then row

---
The pages are put on this array columns first. .i.e:
	p0-of-c0, p1-of-c0, ... pn-of-c0, p0-of-c1, ...
So we are doing a corner turn of the pages.

Note that pages will zigzag down and left. but are put sequentially
in growing order. So when the time comes to XOR the stripe, only the
beginning and end of the array need be checked. We scan the array
and any NULL spot will be field by pages-to-be-read.

The FS that wants to support RAID5 needs to supply an
operations-vector that searches a given page in cache, and specifies
if the page is uptodate or need reading. All these pages to be read
are put on a slave ore_io_state and synchronously read. All the pages
of a stripe are read in one IO, using the scatter gather mechanism.

In write we constrain our IO to only be incomplete on a single
stripe. Meaning either the complete IO is within a single stripe so
we might have pages to read from both beginning  or end of the
strip. Or we have some reading to do at beginning but end at strip
boundary. The left over pages are pushed to the next IO by the API
already established by previous work, where an IO offset/length
combination presented to the ORE might get the length truncated and
the user must re-submit the leftover pages. (Both exofs and NFS
support this)

But any ORE user should make it's best effort to align it's IO
before hand and avoid complications. A cached ore_layout->stripe_size
member can be used for that calculation. (NOTE: that ORE demands
that stripe_size may not be bigger then 32bit)

What else? Well read it and tell me.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/Kconfig       |    9 +-
 fs/exofs/ore.c         |   36 +++-
 fs/exofs/ore_raid.c    |  534 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/exofs/ore_raid.h    |   15 ++
 include/scsi/osd_ore.h |    9 +
 5 files changed, 587 insertions(+), 16 deletions(-)

diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
index 70bae41..d58e888 100644
--- a/fs/exofs/Kconfig
+++ b/fs/exofs/Kconfig
@@ -1,10 +1,17 @@
+# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
+# for every ORE user we do it like this. Any user should add itself here
+# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
+# selected here, and we default to "ON". So in effect it is like been
+# selected by any of the users.
 config ORE
 	tristate
+	depends on EXOFS_FS || PNFS_OBJLAYOUT
+	select ASYNC_XOR
+	default m
 
 config EXOFS_FS
 	tristate "exofs: OSD based file system support"
 	depends on SCSI_OSD_ULD
-	select ORE
 	help
 	  EXOFS is a file system that uses an OSD storage device,
 	  as its backing storage.
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index fd6090d..08ee454 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -95,6 +95,14 @@ int ore_verify_layout(unsigned total_comps, struct ore_layout *layout)
 	layout->max_io_length =
 		(BIO_MAX_PAGES_KMALLOC * PAGE_SIZE - layout->stripe_unit) *
 							layout->group_width;
+	if (layout->parity) {
+		unsigned stripe_length =
+				(layout->group_width - layout->parity) *
+				layout->stripe_unit;
+
+		layout->max_io_length /= stripe_length;
+		layout->max_io_length *= stripe_length;
+	}
 	return 0;
 }
 EXPORT_SYMBOL(ore_verify_layout);
@@ -118,7 +126,7 @@ static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 	return ore_comp_dev(ios->oc, index);
 }
 
-static int  _ore_get_io_state(struct ore_layout *layout,
+int  _ore_get_io_state(struct ore_layout *layout,
 			struct ore_components *oc, unsigned numdevs,
 			unsigned sgs_per_dev, unsigned num_par_pages,
 			struct ore_io_state **pios)
@@ -334,7 +342,7 @@ static void _done_io(struct osd_request *or, void *p)
 	kref_put(&ios->kref, _last_io);
 }
 
-static int ore_io_execute(struct ore_io_state *ios)
+int ore_io_execute(struct ore_io_state *ios)
 {
 	DECLARE_COMPLETION_ONSTACK(wait);
 	bool sync = (ios->done == NULL);
@@ -597,6 +605,8 @@ int _ore_add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 			ret = -ENOMEM;
 			goto out;
 		}
+		_add_stripe_page(ios->sp2d, &ios->si, pages[pg]);
+
 		pgbase = 0;
 		++pg;
 	}
@@ -636,6 +646,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 
 	dev_order = _dev_order(devs_in_group, mirrors_p1, si->par_dev, dev);
 	si->cur_comp = dev_order;
+	si->cur_pg = si->unit_off / PAGE_SIZE;
 
 	while (length) {
 		unsigned comp = dev - first_dev;
@@ -677,14 +688,14 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		length -= cur_len;
 
 		si->cur_comp = (si->cur_comp + 1) % group_width;
-		if (unlikely((dev == si->par_dev) ||
-			     (!length && ios->parity_pages))) {
-			if (!length)
+		if (unlikely((dev == si->par_dev) || (!length && ios->sp2d))) {
+			if (!length && ios->sp2d) {
 				/* If we are writing and this is the very last
 				 * stripe. then operate on parity dev.
 				 */
 				dev = si->par_dev;
-			if (ios->reading)
+			}
+			if (ios->sp2d)
 				/* In writes cur_len just means if it's the
 				 * last one. See _ore_add_parity_unit.
 				 */
@@ -709,6 +720,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 				      devs_in_group + first_dev;
 			/* Next stripe, start fresh */
 			si->cur_comp = 0;
+			si->cur_pg = 0;
 		}
 	}
 out:
@@ -873,6 +885,14 @@ int ore_write(struct ore_io_state *ios)
 	int i;
 	int ret;
 
+	if (unlikely(ios->sp2d && !ios->r4w)) {
+		/* A library is attempting a RAID-write without providing
+		 * a pages lock interface.
+		 */
+		WARN_ON_ONCE(1);
+		return -ENOTSUPP;
+	}
+
 	ret = _prepare_for_striping(ios);
 	if (unlikely(ret))
 		return ret;
@@ -888,7 +908,7 @@ int ore_write(struct ore_io_state *ios)
 }
 EXPORT_SYMBOL(ore_write);
 
-static int _read_mirror(struct ore_io_state *ios, unsigned cur_comp)
+int _ore_read_mirror(struct ore_io_state *ios, unsigned cur_comp)
 {
 	struct osd_request *or;
 	struct ore_per_dev_state *per_dev = &ios->per_dev[cur_comp];
@@ -952,7 +972,7 @@ int ore_read(struct ore_io_state *ios)
 		return ret;
 
 	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
-		ret = _read_mirror(ios, i);
+		ret = _ore_read_mirror(ios, i);
 		if (unlikely(ret))
 			return ret;
 	}
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index 8d4b93a..29c47e5 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -14,9 +14,13 @@
  */
 
 #include <linux/gfp.h>
+#include <linux/async_tx.h>
 
 #include "ore_raid.h"
 
+#undef ORE_DBGMSG2
+#define ORE_DBGMSG2 ORE_DBGMSG
+
 struct page *_raid_page_alloc(void)
 {
 	return alloc_page(GFP_KERNEL);
@@ -27,6 +31,236 @@ void _raid_page_free(struct page *p)
 	__free_page(p);
 }
 
+/* This struct is forward declare in ore_io_state, but is private to here.
+ * It is put on ios->sp2d for RAID5/6 writes only. See _gen_xor_unit.
+ *
+ * __stripe_pages_2d is a 2d array of pages, and it is also a corner turn.
+ * Ascending page index access is sp2d(p-minor, c-major). But storage is
+ * sp2d[p-minor][c-major], so it can be properlly presented to the async-xor
+ * API.
+ */
+struct __stripe_pages_2d {
+	/* Cache some hot path repeated calculations */
+	unsigned parity;
+	unsigned data_devs;
+	unsigned pages_in_unit;
+
+	bool needed ;
+
+	/* Array size is pages_in_unit (layout->stripe_unit / PAGE_SIZE) */
+	struct __1_page_stripe {
+		bool alloc;
+		unsigned write_count;
+		struct async_submit_ctl submit;
+		struct dma_async_tx_descriptor *tx;
+
+		/* The size of this array is data_devs + parity */
+		struct page **pages;
+		struct page **scribble;
+		/* bool array, size of this array is data_devs */
+		char *page_is_read;
+	} _1p_stripes[];
+};
+
+/* This can get bigger then a page. So support multiple page allocations
+ * _sp2d_free should be called even if _sp2d_alloc fails (by returning
+ * none-zero).
+ */
+static int _sp2d_alloc(unsigned pages_in_unit, unsigned group_width,
+		       unsigned parity, struct __stripe_pages_2d **psp2d)
+{
+	struct __stripe_pages_2d *sp2d;
+	unsigned data_devs = group_width - parity;
+	struct _alloc_all_bytes {
+		struct __alloc_stripe_pages_2d {
+			struct __stripe_pages_2d sp2d;
+			struct __1_page_stripe _1p_stripes[pages_in_unit];
+		} __asp2d;
+		struct __alloc_1p_arrays {
+			struct page *pages[group_width];
+			struct page *scribble[group_width];
+			char page_is_read[data_devs];
+		} __a1pa[pages_in_unit];
+	} *_aab;
+	struct __alloc_1p_arrays *__a1pa;
+	struct __alloc_1p_arrays *__a1pa_end;
+	const unsigned sizeof__a1pa = sizeof(_aab->__a1pa[0]);
+	unsigned num_a1pa, alloc_size, i;
+
+	/* FIXME: check these numbers in ore_verify_layout */
+	BUG_ON(sizeof(_aab->__asp2d) > PAGE_SIZE);
+	BUG_ON(sizeof__a1pa > PAGE_SIZE);
+
+	if (sizeof(*_aab) > PAGE_SIZE) {
+		num_a1pa = (PAGE_SIZE - sizeof(_aab->__asp2d)) / sizeof__a1pa;
+		alloc_size = sizeof(_aab->__asp2d) + sizeof__a1pa * num_a1pa;
+	} else {
+		num_a1pa = pages_in_unit;
+		alloc_size = sizeof(*_aab);
+	}
+
+	_aab = kzalloc(alloc_size, GFP_KERNEL);
+	if (unlikely(!_aab)) {
+		ORE_DBGMSG("!! Failed to alloc sp2d size=%d\n", alloc_size);
+		return -ENOMEM;
+	}
+
+	sp2d = &_aab->__asp2d.sp2d;
+	*psp2d = sp2d; /* From here Just call _sp2d_free */
+
+	__a1pa = _aab->__a1pa;
+	__a1pa_end = __a1pa + num_a1pa;
+
+	for (i = 0; i < pages_in_unit; ++i) {
+		if (unlikely(__a1pa >= __a1pa_end)) {
+			num_a1pa = min_t(unsigned, PAGE_SIZE / sizeof__a1pa,
+							pages_in_unit - i);
+
+			__a1pa = kzalloc(num_a1pa * sizeof__a1pa, GFP_KERNEL);
+			if (unlikely(!__a1pa)) {
+				ORE_DBGMSG("!! Failed to _alloc_1p_arrays=%d\n",
+					   num_a1pa);
+				return -ENOMEM;
+			}
+			__a1pa_end = __a1pa + num_a1pa;
+			/* First *pages is marked for kfree of the buffer */
+			sp2d->_1p_stripes[i].alloc = true;
+		}
+
+		sp2d->_1p_stripes[i].pages = __a1pa->pages;
+		sp2d->_1p_stripes[i].scribble = __a1pa->scribble ;
+		sp2d->_1p_stripes[i].page_is_read = __a1pa->page_is_read;
+		++__a1pa;
+	}
+
+	sp2d->parity = parity;
+	sp2d->data_devs = data_devs;
+	sp2d->pages_in_unit = pages_in_unit;
+	return 0;
+}
+
+static void _sp2d_reset(struct __stripe_pages_2d *sp2d,
+			const struct _ore_r4w_op *r4w, void *priv)
+{
+	unsigned data_devs = sp2d->data_devs;
+	unsigned group_width = data_devs + sp2d->parity;
+	unsigned p;
+
+	if (!sp2d->needed)
+		return;
+
+	for (p = 0; p < sp2d->pages_in_unit; p++) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+
+		if (_1ps->write_count < group_width) {
+			unsigned c;
+
+			for (c = 0; c < data_devs; c++)
+				if (_1ps->page_is_read[c]) {
+					struct page *page = _1ps->pages[c];
+
+					r4w->put_page(priv, page);
+					_1ps->page_is_read[c] = false;
+				}
+		}
+
+		memset(_1ps->pages, 0, group_width * sizeof(*_1ps->pages));
+		_1ps->write_count = 0;
+		_1ps->tx = NULL;
+	}
+
+	sp2d->needed = false;
+}
+
+static void _sp2d_free(struct __stripe_pages_2d *sp2d)
+{
+	unsigned i;
+
+	if (!sp2d)
+		return;
+
+	for (i = 0; i < sp2d->pages_in_unit; ++i) {
+		if (sp2d->_1p_stripes[i].alloc)
+			kfree(sp2d->_1p_stripes[i].pages);
+	}
+
+	kfree(sp2d);
+}
+
+static unsigned _sp2d_min_pg(struct __stripe_pages_2d *sp2d)
+{
+	unsigned p;
+
+	for (p = 0; p < sp2d->pages_in_unit; p++) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+
+		if (_1ps->write_count)
+			return p;
+	}
+
+	return ~0;
+}
+
+static unsigned _sp2d_max_pg(struct __stripe_pages_2d *sp2d)
+{
+	unsigned p;
+
+	for (p = sp2d->pages_in_unit - 1; p >= 0; --p) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+
+		if (_1ps->write_count)
+			return p;
+	}
+
+	return ~0;
+}
+
+static void _gen_xor_unit(struct __stripe_pages_2d *sp2d)
+{
+	unsigned p;
+	for (p = 0; p < sp2d->pages_in_unit; p++) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+
+		if (!_1ps->write_count)
+			continue;
+
+		init_async_submit(&_1ps->submit,
+			ASYNC_TX_XOR_ZERO_DST | ASYNC_TX_ACK,
+			NULL,
+			NULL, NULL,
+			(addr_conv_t *)_1ps->scribble);
+
+		/* TODO: raid6 */
+		_1ps->tx = async_xor(_1ps->pages[sp2d->data_devs], _1ps->pages,
+				     0, sp2d->data_devs, PAGE_SIZE,
+				     &_1ps->submit);
+	}
+
+	for (p = 0; p < sp2d->pages_in_unit; p++) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+		/* NOTE: We wait for HW synchronously (I don't have such HW
+		 * to test with.) Is parallelism needed with today's multi
+		 * cores?
+		 */
+		async_tx_issue_pending(_1ps->tx);
+	}
+}
+
+void _ore_add_stripe_page(struct __stripe_pages_2d *sp2d,
+		       struct ore_striping_info *si, struct page *page)
+{
+	struct __1_page_stripe *_1ps;
+
+	sp2d->needed = true;
+
+	_1ps = &sp2d->_1p_stripes[si->cur_pg];
+	_1ps->pages[si->cur_comp] = page;
+	++_1ps->write_count;
+
+	si->cur_pg = (si->cur_pg + 1) % sp2d->pages_in_unit;
+	/* si->cur_comp is advanced outside at main loop */
+}
+
 void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
 		     bool not_last)
 {
@@ -76,6 +310,240 @@ void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
 	}
 }
 
+static int _alloc_read_4_write(struct ore_io_state *ios)
+{
+	struct ore_layout *layout = ios->layout;
+	int ret;
+	/* We want to only read those pages not in cache so worst case
+	 * is a stripe populated with every other page
+	 */
+	unsigned sgs_per_dev = ios->sp2d->pages_in_unit + 2;
+
+	ret = _ore_get_io_state(layout, ios->oc,
+				layout->group_width * layout->mirrors_p1,
+				sgs_per_dev, 0, &ios->ios_read_4_write);
+	return ret;
+}
+
+/* @si contains info of the to-be-inserted page. Update of @si should be
+ * maintained by caller. Specificaly si->dev, si->obj_offset, ...
+ */
+static int _add_to_read_4_write(struct ore_io_state *ios,
+				struct ore_striping_info *si, struct page *page)
+{
+	struct request_queue *q;
+	struct ore_per_dev_state *per_dev;
+	struct ore_io_state *read_ios;
+	unsigned first_dev = si->dev - (si->dev %
+			  (ios->layout->group_width * ios->layout->mirrors_p1));
+	unsigned comp = si->dev - first_dev;
+	unsigned added_len;
+
+	if (!ios->ios_read_4_write) {
+		int ret = _alloc_read_4_write(ios);
+
+		if (unlikely(ret))
+			return ret;
+	}
+
+	read_ios = ios->ios_read_4_write;
+	read_ios->numdevs = ios->layout->group_width * ios->layout->mirrors_p1;
+
+	per_dev = &read_ios->per_dev[comp];
+	if (!per_dev->length) {
+		per_dev->bio = bio_kmalloc(GFP_KERNEL,
+					   ios->sp2d->pages_in_unit);
+		if (unlikely(!per_dev->bio)) {
+			ORE_DBGMSG("Failed to allocate BIO size=%u\n",
+				     ios->sp2d->pages_in_unit);
+			return -ENOMEM;
+		}
+		per_dev->offset = si->obj_offset;
+		per_dev->dev = si->dev;
+	} else if (si->obj_offset != (per_dev->offset + per_dev->length)) {
+		u64 gap = si->obj_offset - (per_dev->offset + per_dev->length);
+
+		_ore_add_sg_seg(per_dev, gap, true);
+	}
+	q = osd_request_queue(ore_comp_dev(read_ios->oc, per_dev->dev));
+	added_len = bio_add_pc_page(q, per_dev->bio, page, PAGE_SIZE, 0);
+	if (unlikely(added_len != PAGE_SIZE)) {
+		ORE_DBGMSG("Failed to bio_add_pc_page bi_vcnt=%d\n",
+			      per_dev->bio->bi_vcnt);
+		return -ENOMEM;
+	}
+
+	per_dev->length += PAGE_SIZE;
+	return 0;
+}
+
+static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
+{
+	struct bio_vec *bv;
+	unsigned i, d;
+
+	/* loop on all devices all pages */
+	for (d = 0; d < ios->numdevs; d++) {
+		struct bio *bio = ios->per_dev[d].bio;
+
+		if (!bio)
+			continue;
+
+		__bio_for_each_segment(bv, bio, i, 0) {
+			struct page *page = bv->bv_page;
+
+			SetPageUptodate(page);
+			if (PageError(page))
+				ClearPageError(page);
+		}
+	}
+}
+
+/* read_4_write is hacked to read the start of the first stripe and/or
+ * the end of the last stripe. If needed, with an sg-gap at each device/page.
+ * It is assumed to be called after the to_be_written pages of the first stripe
+ * are populating ios->sp2d[][]
+ *
+ * NOTE: We call ios->r4w->lock_fn for all pages needed for parity calculations
+ * These pages are held at sp2d[p].pages[c] but with
+ * sp2d[p].page_is_read[c] = true. At _sp2d_reset these pages are
+ * ios->r4w->lock_fn(). The ios->r4w->lock_fn might signal that the page is
+ * @uptodate=true, so we don't need to read it, only unlock, after IO.
+ *
+ * TODO: The read_4_write should calc a need_to_read_pages_count, if bigger then
+ * to-be-written count, we should consider the xor-in-place mode.
+ * need_to_read_pages_count is the actual number of pages not present in cache.
+ * maybe "devs_in_group - ios->sp2d[p].write_count" is a good enough
+ * approximation? In this mode the read pages are put in the empty places of
+ * ios->sp2d[p][*], xor is calculated the same way. These pages are
+ * allocated/freed and don't go through cache
+ */
+static int _read_4_write(struct ore_io_state *ios)
+{
+	struct ore_io_state *ios_read;
+	struct ore_striping_info read_si;
+	struct __stripe_pages_2d *sp2d = ios->sp2d;
+	u64 offset = ios->si.first_stripe_start;
+	u64 last_stripe_end;
+	unsigned bytes_in_stripe = ios->si.bytes_in_stripe;
+	unsigned i, c, p, min_p = sp2d->pages_in_unit, max_p = -1;
+	int ret;
+
+	if (offset == ios->offset) /* Go to start collect $200 */
+		goto read_last_stripe;
+
+	min_p = _sp2d_min_pg(sp2d);
+	max_p = _sp2d_max_pg(sp2d);
+
+	for (c = 0; ; c++) {
+		ore_calc_stripe_info(ios->layout, offset, 0, &read_si);
+		read_si.obj_offset += min_p * PAGE_SIZE;
+		offset += min_p * PAGE_SIZE;
+		for (p = min_p; p <= max_p; p++) {
+			struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+			struct page **pp = &_1ps->pages[c];
+			bool uptodate;
+
+			if (*pp)
+				/* to-be-written pages start here */
+				goto read_last_stripe;
+
+			*pp = ios->r4w->get_page(ios->private, offset,
+						 &uptodate);
+			if (unlikely(!*pp))
+				return -ENOMEM;
+
+			if (!uptodate)
+				_add_to_read_4_write(ios, &read_si, *pp);
+
+			/* Mark read-pages to be cache_released */
+			_1ps->page_is_read[c] = true;
+			read_si.obj_offset += PAGE_SIZE;
+			offset += PAGE_SIZE;
+		}
+		offset += (sp2d->pages_in_unit - p) * PAGE_SIZE;
+	}
+
+read_last_stripe:
+	offset = ios->offset + (ios->length + PAGE_SIZE - 1) /
+				PAGE_SIZE * PAGE_SIZE;
+	last_stripe_end = div_u64(offset + bytes_in_stripe - 1, bytes_in_stripe)
+				 * bytes_in_stripe;
+	if (offset == last_stripe_end) /* Optimize for the aligned case */
+		goto read_it;
+
+	ore_calc_stripe_info(ios->layout, offset, 0, &read_si);
+	p = read_si.unit_off / PAGE_SIZE;
+	c = _dev_order(ios->layout->group_width * ios->layout->mirrors_p1,
+		       ios->layout->mirrors_p1, read_si.par_dev, read_si.dev);
+
+	BUG_ON(ios->si.first_stripe_start + bytes_in_stripe != last_stripe_end);
+	/* unaligned IO must be within a single stripe */
+
+	if (min_p == sp2d->pages_in_unit) {
+		/* Didn't do it yet */
+		min_p = _sp2d_min_pg(sp2d);
+		max_p = _sp2d_max_pg(sp2d);
+	}
+
+	while (offset < last_stripe_end) {
+		struct __1_page_stripe *_1ps = &sp2d->_1p_stripes[p];
+
+		if ((min_p <= p) && (p <= max_p)) {
+			struct page *page;
+			bool uptodate;
+
+			BUG_ON(_1ps->pages[c]);
+			page = ios->r4w->get_page(ios->private, offset,
+						  &uptodate);
+			if (unlikely(!page))
+				return -ENOMEM;
+
+			_1ps->pages[c] = page;
+			/* Mark read-pages to be cache_released */
+			_1ps->page_is_read[c] = true;
+			if (!uptodate)
+				_add_to_read_4_write(ios, &read_si, page);
+		}
+
+		offset += PAGE_SIZE;
+		if (p == (sp2d->pages_in_unit - 1)) {
+			++c;
+			p = 0;
+			ore_calc_stripe_info(ios->layout, offset, 0, &read_si);
+		} else {
+			read_si.obj_offset += PAGE_SIZE;
+			++p;
+		}
+	}
+
+read_it:
+	ios_read = ios->ios_read_4_write;
+	if (!ios_read)
+		return 0;
+
+	/* FIXME: Ugly to signal _sbi_read_mirror that we have bio(s). Change
+	 * to check for per_dev->bio
+	 */
+	ios_read->pages = ios->pages;
+
+	/* Now read these devices */
+	for (i = 0; i < ios_read->numdevs; i += ios_read->layout->mirrors_p1) {
+		ret = _ore_read_mirror(ios_read, i);
+		if (unlikely(ret))
+			return ret;
+	}
+
+	ret = ore_io_execute(ios_read); /* Synchronus execution */
+	if (unlikely(ret)) {
+		ORE_DBGMSG("!! ore_io_execute => %d\n", ret);
+		return ret;
+	}
+
+	_mark_read4write_pages_uptodate(ios_read, ret);
+	return 0;
+}
+
 /* In writes @cur_len means length left. .i.e cur_len==0 is the last parity U */
 int _ore_add_parity_unit(struct ore_io_state *ios,
 			    struct ore_striping_info *si,
@@ -86,42 +554,89 @@ int _ore_add_parity_unit(struct ore_io_state *ios,
 		BUG_ON(per_dev->cur_sg >= ios->sgs_per_dev);
 		_ore_add_sg_seg(per_dev, cur_len, true);
 	} else {
+		struct __stripe_pages_2d *sp2d = ios->sp2d;
 		struct page **pages = ios->parity_pages + ios->cur_par_page;
-		unsigned num_pages = ios->layout->stripe_unit / PAGE_SIZE;
+		unsigned num_pages;
 		unsigned array_start = 0;
 		unsigned i;
 		int ret;
 
+		si->cur_pg = _sp2d_min_pg(sp2d);
+		num_pages  = _sp2d_max_pg(sp2d) + 1 - si->cur_pg;
+
+		if (!cur_len) /* If last stripe operate on parity comp */
+			si->cur_comp = sp2d->data_devs;
+
+		if (!per_dev->length) {
+			per_dev->offset += si->cur_pg * PAGE_SIZE;
+			/* If first stripe, Read in all read4write pages
+			 * (if needed) before we calculate the first parity.
+			 */
+			_read_4_write(ios);
+		}
+
 		for (i = 0; i < num_pages; i++) {
 			pages[i] = _raid_page_alloc();
 			if (unlikely(!pages[i]))
 				return -ENOMEM;
 
 			++(ios->cur_par_page);
-			/* TODO: only read support for now */
-			clear_highpage(pages[i]);
 		}
 
-		ORE_DBGMSG("writing dev=%d num_pages=%d cur_par_page=%d",
-			     per_dev->dev, num_pages, ios->cur_par_page);
+		BUG_ON(si->cur_comp != sp2d->data_devs);
+		BUG_ON(si->cur_pg + num_pages > sp2d->pages_in_unit);
 
 		ret = _ore_add_stripe_unit(ios,  &array_start, 0, pages,
 					   per_dev, num_pages * PAGE_SIZE);
 		if (unlikely(ret))
 			return ret;
+
+		/* TODO: raid6 if (last_parity_dev) */
+		_gen_xor_unit(sp2d);
+		_sp2d_reset(sp2d, ios->r4w, ios->private);
 	}
 	return 0;
 }
 
 int _ore_post_alloc_raid_stuff(struct ore_io_state *ios)
 {
-	/*TODO: Only raid writes has stuff to add here */
+	struct ore_layout *layout = ios->layout;
+
+	if (ios->parity_pages) {
+		unsigned pages_in_unit = layout->stripe_unit / PAGE_SIZE;
+		unsigned stripe_size = ios->si.bytes_in_stripe;
+		u64 last_stripe, first_stripe;
+
+		if (_sp2d_alloc(pages_in_unit, layout->group_width,
+				layout->parity, &ios->sp2d)) {
+			return -ENOMEM;
+		}
+
+		BUG_ON(ios->offset % PAGE_SIZE);
+
+		/* Round io down to last full strip */
+		first_stripe = div_u64(ios->offset, stripe_size);
+		last_stripe = div_u64(ios->offset + ios->length, stripe_size);
+
+		/* If an IO spans more then a single stripe it must end at
+		 * a stripe boundary. The reminder at the end is pushed into the
+		 * next IO.
+		 */
+		if (last_stripe != first_stripe) {
+			ios->length = last_stripe * stripe_size - ios->offset;
+
+			BUG_ON(!ios->length);
+			ios->nr_pages = (ios->length + PAGE_SIZE - 1) /
+					PAGE_SIZE;
+			ios->si.length = ios->length; /*make it consistent */
+		}
+	}
 	return 0;
 }
 
 void _ore_free_raid_stuff(struct ore_io_state *ios)
 {
-	if (ios->parity_pages) { /* writing and raid */
+	if (ios->sp2d) { /* writing and raid */
 		unsigned i;
 
 		for (i = 0; i < ios->cur_par_page; i++) {
@@ -132,9 +647,14 @@ void _ore_free_raid_stuff(struct ore_io_state *ios)
 		}
 		if (ios->extra_part_alloc)
 			kfree(ios->parity_pages);
+		/* If IO returned an error pages might need unlocking */
+		_sp2d_reset(ios->sp2d, ios->r4w, ios->private);
+		_sp2d_free(ios->sp2d);
 	} else {
 		/* Will only be set if raid reading && sglist is big */
 		if (ios->extra_part_alloc)
 			kfree(ios->per_dev[0].sglist);
 	}
+	if (ios->ios_read_4_write)
+		ore_put_io_state(ios->ios_read_4_write);
 }
diff --git a/fs/exofs/ore_raid.h b/fs/exofs/ore_raid.h
index c21080b..2ffd2c3 100644
--- a/fs/exofs/ore_raid.h
+++ b/fs/exofs/ore_raid.h
@@ -57,8 +57,23 @@ void _ore_add_sg_seg(struct ore_per_dev_state *per_dev, unsigned cur_len,
 		 bool not_last);
 int _ore_add_parity_unit(struct ore_io_state *ios, struct ore_striping_info *si,
 		     struct ore_per_dev_state *per_dev, unsigned cur_len);
+void _ore_add_stripe_page(struct __stripe_pages_2d *sp2d,
+		       struct ore_striping_info *si, struct page *page);
+static inline void _add_stripe_page(struct __stripe_pages_2d *sp2d,
+				struct ore_striping_info *si, struct page *page)
+{
+	if (!sp2d) /* Inline the fast path */
+		return; /* Hay no raid stuff */
+	_ore_add_stripe_page(sp2d, si, page);
+}
 
 /* ios.c stuff needed by ios_raid.c */
+int  _ore_get_io_state(struct ore_layout *layout,
+			struct ore_components *oc, unsigned numdevs,
+			unsigned sgs_per_dev, unsigned num_par_pages,
+			struct ore_io_state **pios);
 int _ore_add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 		unsigned pgbase, struct page **pages,
 		struct ore_per_dev_state *per_dev, int cur_len);
+int _ore_read_mirror(struct ore_io_state *ios, unsigned cur_comp);
+int ore_io_execute(struct ore_io_state *ios);
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 43821c1..f05fa82 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -99,11 +99,17 @@ struct ore_striping_info {
 	unsigned dev;
 	unsigned par_dev;
 	unsigned unit_off;
+	unsigned cur_pg;
 	unsigned cur_comp;
 };
 
 struct ore_io_state;
 typedef void (*ore_io_done_fn)(struct ore_io_state *ios, void *private);
+struct _ore_r4w_op {
+	/* @Priv given here is passed ios->private */
+	struct page * (*get_page)(void *priv, u64 page_index, bool *uptodate);
+	void (*put_page)(void *priv, struct page *page);
+};
 
 struct ore_io_state {
 	struct kref		kref;
@@ -139,6 +145,9 @@ struct ore_io_state {
 	unsigned		max_par_pages;
 	unsigned		cur_par_page;
 	unsigned		sgs_per_dev;
+	struct __stripe_pages_2d *sp2d;
+	struct ore_io_state	 *ios_read_4_write;
+	const struct _ore_r4w_op *r4w;
 
 	/* Variable array of size numdevs */
 	unsigned numdevs;
-- 
1.7.2.3

