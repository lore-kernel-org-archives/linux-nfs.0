Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52063 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1JDKa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:30:27 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 05/19] ore: Only IO one group at a time (API change)
Date: Tue, 4 Oct 2011 12:30:15 +0200
Message-ID: <1317724215-27447-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Usually a single IO is confined to one group of devices
(group_width) and at the boundary of a raid group it can
spill into a second group. Current code would allocate a
full device_table size array at each io_state so it can
comply to requests that span two groups. Needless to say
that is very wasteful, specially when device_table count
can get very large (hundreds even thousands), while a
group_width is usually 8 or 10.

* Change ore API to trim on IO that spans two raid groups.
  The user passes offset+length to ore_get_rw_state, the
  ore might trim on that length if spanning a group boundary.
  The user must check ios->length or ios->nrpages to see
  how much IO will be preformed. It is the responsibility
  of the user to re-issue the reminder of the IO.

* Modify exofs To copy spilled pages on to the next IO.
  This means one last kick is needed after all coalescing
  of pages is done.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/inode.c |   95 ++++++++++++++++++++++++++++++++++++++++++--------
 fs/exofs/ore.c   |  103 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 150 insertions(+), 48 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 61b2f7e..14e408b 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -259,6 +259,46 @@ static void _unlock_pcol_pages(struct page_collect *pcol, int ret, int rw)
 	}
 }
 
+static int _maybe_not_all_in_one_io(struct ore_io_state *ios,
+	struct page_collect *pcol_src, struct page_collect *pcol)
+{
+	/* length was wrong or offset was not page aligned */
+	BUG_ON(pcol_src->nr_pages < ios->nr_pages);
+
+	if (pcol_src->nr_pages > ios->nr_pages) {
+		struct page **src_page;
+		unsigned pages_less = pcol_src->nr_pages - ios->nr_pages;
+		unsigned long len_less = pcol_src->length - ios->length;
+		unsigned i;
+		int ret;
+
+		/* This IO was trimmed */
+		pcol_src->nr_pages = ios->nr_pages;
+		pcol_src->length = ios->length;
+
+		/* Left over pages are passed to the next io */
+		pcol->expected_pages += pages_less;
+		pcol->nr_pages = pages_less;
+		pcol->length = len_less;
+		src_page = pcol_src->pages + pcol_src->nr_pages;
+		pcol->pg_first = (*src_page)->index;
+
+		ret = pcol_try_alloc(pcol);
+		if (unlikely(ret))
+			return ret;
+
+		for (i = 0; i < pages_less; ++i)
+			pcol->pages[i] = *src_page++;
+
+		EXOFS_DBGMSG("Length was adjusted nr_pages=0x%x pages_less=%d "
+			"expected_pages=0x%x next_offset=0x%llx "
+			"next_len=0x%lx\n",
+			pcol_src->nr_pages, pages_less, pcol->expected_pages,
+			pcol->pg_first * PAGE_SIZE, pcol->length);
+	}
+	return 0;
+}
+
 static int read_exec(struct page_collect *pcol)
 {
 	struct exofs_i_info *oi = exofs_i(pcol->inode);
@@ -280,7 +320,6 @@ static int read_exec(struct page_collect *pcol)
 
 	ios = pcol->ios;
 	ios->pages = pcol->pages;
-	ios->nr_pages = pcol->nr_pages;
 
 	if (pcol->read_4_write) {
 		ore_read(pcol->ios);
@@ -296,17 +335,23 @@ static int read_exec(struct page_collect *pcol)
 	*pcol_copy = *pcol;
 	ios->done = readpages_done;
 	ios->private = pcol_copy;
+
+	/* pages ownership was passed to pcol_copy */
+	_pcol_reset(pcol);
+
+	ret = _maybe_not_all_in_one_io(ios, pcol_copy, pcol);
+	if (unlikely(ret))
+		goto err;
+
+	EXOFS_DBGMSG2("read_exec(0x%lx) offset=0x%llx length=0x%llx\n",
+		pcol->inode->i_ino, _LLU(ios->offset), _LLU(ios->length));
+
 	ret = ore_read(ios);
 	if (unlikely(ret))
 		goto err;
 
 	atomic_inc(&pcol->sbi->s_curr_pending);
 
-	EXOFS_DBGMSG2("read_exec obj=0x%llx start=0x%llx length=0x%lx\n",
-		  oi->one_comp.obj.id, _LLU(ios->offset), pcol->length);
-
-	/* pages ownership was passed to pcol_copy */
-	_pcol_reset(pcol);
 	return 0;
 
 err:
@@ -429,6 +474,10 @@ static int exofs_readpages(struct file *file, struct address_space *mapping,
 		return ret;
 	}
 
+	ret = read_exec(&pcol);
+	if (unlikely(ret))
+		return ret;
+
 	return read_exec(&pcol);
 }
 
@@ -519,7 +568,6 @@ static int write_exec(struct page_collect *pcol)
 	ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, false,
 				 pcol->pg_first << PAGE_CACHE_SHIFT,
 				 pcol->length, &pcol->ios);
-
 	if (unlikely(ret))
 		goto err;
 
@@ -534,10 +582,19 @@ static int write_exec(struct page_collect *pcol)
 
 	ios = pcol->ios;
 	ios->pages = pcol_copy->pages;
-	ios->nr_pages = pcol_copy->nr_pages;
 	ios->done = writepages_done;
 	ios->private = pcol_copy;
 
+	/* pages ownership was passed to pcol_copy */
+	_pcol_reset(pcol);
+
+	ret = _maybe_not_all_in_one_io(ios, pcol_copy, pcol);
+	if (unlikely(ret))
+		goto err;
+
+	EXOFS_DBGMSG2("write_exec(0x%lx) offset=0x%llx length=0x%llx\n",
+		pcol->inode->i_ino, _LLU(ios->offset), _LLU(ios->length));
+
 	ret = ore_write(ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("write_exec: ore_write() Failed\n");
@@ -545,11 +602,6 @@ static int write_exec(struct page_collect *pcol)
 	}
 
 	atomic_inc(&pcol->sbi->s_curr_pending);
-	EXOFS_DBGMSG2("write_exec(0x%lx, 0x%llx) start=0x%llx length=0x%lx\n",
-		  pcol->inode->i_ino, pcol->pg_first, _LLU(ios->offset),
-		  pcol->length);
-	/* pages ownership was passed to pcol_copy */
-	_pcol_reset(pcol);
 	return 0;
 
 err:
@@ -689,12 +741,25 @@ static int exofs_writepages(struct address_space *mapping,
 	_pcol_init(&pcol, expected_pages, mapping->host);
 
 	ret = write_cache_pages(mapping, wbc, writepage_strip, &pcol);
-	if (ret) {
+	if (unlikely(ret)) {
 		EXOFS_ERR("write_cache_pages => %d\n", ret);
 		return ret;
 	}
 
-	return write_exec(&pcol);
+	ret = write_exec(&pcol);
+	if (unlikely(ret))
+		return ret;
+
+	if (wbc->sync_mode == WB_SYNC_ALL) {
+		return write_exec(&pcol); /* pump the last reminder */
+	} else {/* not SYNC let the reminder join the next writeout */
+		unsigned i;
+
+		for (i = 0; i < pcol.nr_pages; i++)
+			unlock_page(pcol.pages[i]);
+
+		return 0;
+	}
 }
 
 static int exofs_writepage(struct page *page, struct writeback_control *wbc)
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index a7d7925..d54af35 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -47,6 +47,9 @@ MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
 MODULE_DESCRIPTION("Objects Raid Engine ore.ko");
 MODULE_LICENSE("GPL");
 
+static void ore_calc_stripe_info(struct ore_layout *layout, u64 file_offset,
+				 struct ore_striping_info *si);
+
 static u8 *_ios_cred(struct ore_io_state *ios, unsigned index)
 {
 	return ios->oc->comps[index & ios->oc->single_comp].cred;
@@ -62,38 +65,85 @@ static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 	return ore_comp_dev(ios->oc, index);
 }
 
-int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
-		      bool is_reading, u64 offset, u64 length,
-		      struct ore_io_state **pios)
+static int  _get_io_state(struct ore_layout *layout,
+			  struct ore_components *oc, unsigned numdevs,
+			  struct ore_io_state **pios)
 {
 	struct ore_io_state *ios;
 
 	/*TODO: Maybe use kmem_cach per sbi of size
 	 * exofs_io_state_size(layout->s_numdevs)
 	 */
-	ios = kzalloc(ore_io_state_size(oc->numdevs), GFP_KERNEL);
+	ios = kzalloc(ore_io_state_size(numdevs), GFP_KERNEL);
 	if (unlikely(!ios)) {
 		ORE_DBGMSG("Failed kzalloc bytes=%d\n",
-			     ore_io_state_size(oc->numdevs));
+			   ore_io_state_size(numdevs));
 		*pios = NULL;
 		return -ENOMEM;
 	}
 
 	ios->layout = layout;
 	ios->oc = oc;
-	ios->offset = offset;
-	ios->length = length;
+	*pios = ios;
+	return 0;
+}
+
+/* Allocate an io_state for only a single group of devices
+ *
+ * If a user needs to call ore_read/write() this version must be used becase it
+ * allocates extra stuff for striping and raid.
+ * The ore might decide to only IO less then @length bytes do to alignmets
+ * and constrains as follows:
+ * - The IO cannot cross group boundary.
+ * - In raid5/6 The end of the IO must align at end of a stripe eg.
+ *   (@offset + @length) % strip_size == 0. Or the complete range is within a
+ *   single stripe.
+ * - Memory condition only permitted a shorter IO. (A user can use @length=~0
+ *   And check the returned ios->length for max_io_size.)
+ *
+ * The caller must check returned ios->length (and/or ios->nr_pages) and
+ * re-issue these pages that fall outside of ios->length
+ */
+int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
+		      bool is_reading, u64 offset, u64 length,
+		      struct ore_io_state **pios)
+{
+	struct ore_io_state *ios;
+	unsigned numdevs = layout->group_width * layout->mirrors_p1;
+	int ret;
+
+	ret = _get_io_state(layout, oc, numdevs, pios);
+	if (unlikely(ret))
+		return ret;
+
+	ios = *pios;
 	ios->reading = is_reading;
+	ios->offset = offset;
+
+	if (length) {
+		struct ore_striping_info si;
+
+		ore_calc_stripe_info(layout, offset, &si);
+		ios->length = (length <= si.group_length) ? length :
+							si.group_length;
+		ios->nr_pages = (ios->length + PAGE_SIZE - 1) / PAGE_SIZE;
+	}
 
-	*pios = ios;
 	return 0;
 }
 EXPORT_SYMBOL(ore_get_rw_state);
 
+/* Allocate an io_state for all the devices in the comps array
+ *
+ * This version of io_state allocation is used mostly by create/remove
+ * and trunc where we currently need all the devices. The only wastful
+ * bit is the read/write_attributes with no IO. Those sites should
+ * be converted to use ore_get_rw_state() with length=0
+ */
 int  ore_get_io_state(struct ore_layout *layout, struct ore_components *oc,
-		      struct ore_io_state **ios)
+		      struct ore_io_state **pios)
 {
-	return ore_get_rw_state(layout, oc, true, 0, 0, ios);
+	return _get_io_state(layout, oc, oc->numdevs, pios);
 }
 EXPORT_SYMBOL(ore_get_io_state);
 
@@ -379,7 +429,8 @@ static int _prepare_one_group(struct ore_io_state *ios, u64 length,
 	int ret = 0;
 
 	while (length) {
-		struct ore_per_dev_state *per_dev = &ios->per_dev[dev];
+		unsigned comp = dev - first_dev;
+		struct ore_per_dev_state *per_dev = &ios->per_dev[comp];
 		unsigned cur_len, page_off = 0;
 
 		if (!per_dev->length) {
@@ -398,8 +449,8 @@ static int _prepare_one_group(struct ore_io_state *ios, u64 length,
 				cur_len = stripe_unit;
 			}
 
-			if (max_comp < dev)
-				max_comp = dev;
+			if (max_comp < comp)
+				max_comp = comp;
 		} else {
 			cur_len = stripe_unit;
 		}
@@ -424,10 +475,8 @@ out:
 
 static int _prepare_for_striping(struct ore_io_state *ios)
 {
-	u64 length = ios->length;
-	u64 offset = ios->offset;
 	struct ore_striping_info si;
-	int ret = 0;
+	int ret;
 
 	if (!ios->pages) {
 		if (ios->kern_buff) {
@@ -446,21 +495,11 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		return 0;
 	}
 
-	while (length) {
-		ore_calc_stripe_info(ios->layout, offset, &si);
-
-		if (length < si.group_length)
-			si.group_length = length;
+	ore_calc_stripe_info(ios->layout, ios->offset, &si);
 
-		ret = _prepare_one_group(ios, si.group_length, &si);
-		if (unlikely(ret))
-			goto out;
+	BUG_ON(ios->length > si.group_length);
+	ret = _prepare_one_group(ios, ios->length, &si);
 
-		offset += si.group_length;
-		length -= si.group_length;
-	}
-
-out:
 	return ret;
 }
 
@@ -742,7 +781,6 @@ struct _trunc_info {
 
 	unsigned first_group_dev;
 	unsigned nex_group_dev;
-	unsigned max_devs;
 };
 
 static void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
@@ -757,7 +795,6 @@ static void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
 
 	ti->first_group_dev = ti->si.dev - (ti->si.dev % layout->group_width);
 	ti->nex_group_dev = ti->first_group_dev + layout->group_width;
-	ti->max_devs = layout->group_width * layout->group_count;
 }
 
 int ore_truncate(struct ore_layout *layout, struct ore_components *oc,
@@ -777,7 +814,7 @@ int ore_truncate(struct ore_layout *layout, struct ore_components *oc,
 
 	_calc_trunk_info(ios->layout, size, &ti);
 
-	size_attrs = kcalloc(ti.max_devs, sizeof(*size_attrs),
+	size_attrs = kcalloc(ios->oc->numdevs, sizeof(*size_attrs),
 			     GFP_KERNEL);
 	if (unlikely(!size_attrs)) {
 		ret = -ENOMEM;
@@ -786,7 +823,7 @@ int ore_truncate(struct ore_layout *layout, struct ore_components *oc,
 
 	ios->numdevs = ios->oc->numdevs;
 
-	for (i = 0; i < ti.max_devs; ++i) {
+	for (i = 0; i < ios->numdevs; ++i) {
 		struct exofs_trunc_attr *size_attr = &size_attrs[i];
 		u64 obj_size;
 
-- 
1.7.2.3

