Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57786 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab1GGQ0T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:19 -0400
Message-Id: <42c29206c75caa5fcab773d08150e66065e3a192.1310055433.git.rees@umich.edu>
In-Reply-To: <cover.1310055433.git.rees@umich.edu>
References: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 5/6] reindent
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:17 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/extents.c |  107 +++++++++++++++++++++---------------------
 1 files changed, 53 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 56cbe9a..f1b8913 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -43,7 +43,7 @@
 /* Returns largest t<=s s.t. t%base==0 */
 static inline sector_t normalize(sector_t s, int base)
 {
-	sector_t tmp = s; /* Since do_div modifies its argument */
+	sector_t tmp = s;	/* Since do_div modifies its argument */
 	return s - do_div(tmp, base);
 }
 
@@ -71,8 +71,7 @@ static int32_t _find_entry(struct my_tree_t *tree, u64 s)
 	return -ENOENT;
 }
 
-static inline
-int _has_tag(struct my_tree_t *tree, u64 s, int32_t tag)
+static inline int _has_tag(struct my_tree_t *tree, u64 s, int32_t tag)
 {
 	int32_t tags;
 
@@ -169,7 +168,7 @@ static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
 	/* Unlock - HOW??? */
 	status = 0;
 
- out_cleanup:
+out_cleanup:
 	for (i = used; i < count; i++) {
 		if (!storage[i])
 			break;
@@ -179,7 +178,7 @@ static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
 	return status;
 }
 
-static void set_needs_init(sector_t *array, sector_t offset)
+static void set_needs_init(sector_t * array, sector_t offset)
 {
 	sector_t *p = array;
 
@@ -196,7 +195,7 @@ static void set_needs_init(sector_t *array, sector_t offset)
 		return;
 	} else {
 		sector_t *save = p;
-		dprintk("%s Adding %llu\n", __func__, (u64)offset);
+		dprintk("%s Adding %llu\n", __func__, (u64) offset);
 		while (*p != ~0)
 			p++;
 		p++;
@@ -232,7 +231,8 @@ _range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
 			if ((pos->it_sector == end - tree->mtt_step_size) &&
 			    (pos->it_tags & (1 << tag))) {
 				expect = pos->it_sector - tree->mtt_step_size;
-				if (pos->it_sector < tree->mtt_step_size || expect < start)
+				if (pos->it_sector < tree->mtt_step_size
+				    || expect < start)
 					return 1;
 				continue;
 			} else {
@@ -270,13 +270,13 @@ int mark_initialized_sectors(struct pnfs_inval_markings *marks,
 			     sector_t **pages)
 {
 	sector_t s, start, end;
-	sector_t *array = NULL; /* Pages to mark */
+	sector_t *array = NULL;	/* Pages to mark */
 
 	dprintk("%s(offset=%llu,len=%llu) enter\n",
-		__func__, (u64)offset, (u64)length);
+		__func__, (u64) offset, (u64) length);
 	s = max((sector_t) 3,
 		2 * (marks->im_block_size / (PAGE_CACHE_SECTORS)));
-	dprintk("%s set max=%llu\n", __func__, (u64)s);
+	dprintk("%s set max=%llu\n", __func__, (u64) s);
 	if (pages) {
 		array = kmalloc(s * sizeof(sector_t), GFP_KERNEL);
 		if (!array)
@@ -318,9 +318,9 @@ int mark_initialized_sectors(struct pnfs_inval_markings *marks,
 	}
 	return 0;
 
- out_unlock:
+out_unlock:
 	spin_unlock(&marks->im_lock);
- outerr:
+outerr:
 	if (pages) {
 		kfree(array);
 		*pages = NULL;
@@ -337,7 +337,7 @@ int mark_written_sectors(struct pnfs_inval_markings *marks,
 	int status;
 
 	dprintk("%s(offset=%llu,len=%llu) enter\n", __func__,
-		(u64)offset, (u64)length);
+		(u64) offset, (u64) length);
 	spin_lock(&marks->im_lock);
 	status = _set_range(&marks->im_tree, EXTENT_WRITTEN, offset, length);
 	spin_unlock(&marks->im_lock);
@@ -348,8 +348,8 @@ static void print_short_extent(struct pnfs_block_short_extent *be)
 {
 	dprintk("PRINT SHORT EXTENT extent %p\n", be);
 	if (be) {
-		dprintk("        be_f_offset %llu\n", (u64)be->bse_f_offset);
-		dprintk("        be_length   %llu\n", (u64)be->bse_length);
+		dprintk("        be_f_offset %llu\n", (u64) be->bse_f_offset);
+		dprintk("        be_length   %llu\n", (u64) be->bse_length);
 	}
 }
 
@@ -396,12 +396,12 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,
 			kfree(new);
 			return;
 		} else if (new->bse_f_offset <=
-				old->bse_f_offset + old->bse_length) {
+			   old->bse_f_offset + old->bse_length) {
 			/* new overlaps or abuts existing be */
 			if (new->bse_mdev == old->bse_mdev) {
 				/* extend new to fully replace old */
 				new->bse_length += new->bse_f_offset -
-						old->bse_f_offset;
+				    old->bse_f_offset;
 				new->bse_f_offset = old->bse_f_offset;
 				list_del(&old->bse_node);
 				bl->bl_count--;
@@ -493,15 +493,14 @@ static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
 	if (be) {
-		dprintk("        be_f_offset %llu\n", (u64)be->be_f_offset);
-		dprintk("        be_length   %llu\n", (u64)be->be_length);
-		dprintk("        be_v_offset %llu\n", (u64)be->be_v_offset);
+		dprintk("        be_f_offset %llu\n", (u64) be->be_f_offset);
+		dprintk("        be_length   %llu\n", (u64) be->be_length);
+		dprintk("        be_v_offset %llu\n", (u64) be->be_v_offset);
 		dprintk("        be_state    %d\n", be->be_state);
 	}
 }
 
-static void
-destroy_extent(struct kref *kref)
+static void destroy_extent(struct kref *kref)
 {
 	struct pnfs_block_extent *be;
 
@@ -510,8 +509,7 @@ destroy_extent(struct kref *kref)
 	kfree(be);
 }
 
-void
-put_extent(struct pnfs_block_extent *be)
+void put_extent(struct pnfs_block_extent *be)
 {
 	if (be) {
 		dprintk("%s enter %p (%i)\n", __func__, be,
@@ -533,8 +531,7 @@ struct pnfs_block_extent *alloc_extent(void)
 	return be;
 }
 
-struct pnfs_block_extent *
-get_extent(struct pnfs_block_extent *be)
+struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be)
 {
 	if (be)
 		kref_get(&be->be_refcnt);
@@ -557,10 +554,10 @@ extents_consistent(struct pnfs_block_extent *old, struct pnfs_block_extent *new)
 {
 	/* Note this assumes new->be_f_offset >= old->be_f_offset */
 	return (new->be_state == old->be_state) &&
-		((new->be_state == PNFS_BLOCK_NONE_DATA) ||
-		 ((new->be_v_offset - old->be_v_offset ==
-		   new->be_f_offset - old->be_f_offset) &&
-		  new->be_mdev == old->be_mdev));
+	    ((new->be_state == PNFS_BLOCK_NONE_DATA) ||
+	     ((new->be_v_offset - old->be_v_offset ==
+	       new->be_f_offset - old->be_f_offset) &&
+	      new->be_mdev == old->be_mdev));
 }
 
 /* Adds new to appropriate list in bl, modifying new and removing existing
@@ -594,7 +591,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 			break;
 		if (new->be_f_offset >= be->be_f_offset) {
 			if (end <= be->be_f_offset + be->be_length) {
-				/* new is a subset of existing be*/
+				/* new is a subset of existing be */
 				if (extents_consistent(be, new)) {
 					dprintk("%s: new is subset, ignoring\n",
 						__func__);
@@ -609,10 +606,11 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 				if (extents_consistent(be, new)) {
 					/* extend new to fully replace be */
 					new->be_length += new->be_f_offset -
-						be->be_f_offset;
+					    be->be_f_offset;
 					new->be_f_offset = be->be_f_offset;
 					new->be_v_offset = be->be_v_offset;
-					dprintk("%s: removing %p\n", __func__, be);
+					dprintk("%s: removing %p\n", __func__,
+						be);
 					list_del(&be->be_node);
 					put_extent(be);
 				} else {
@@ -634,8 +632,9 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 			 *|<--   new   -->| */
 			if (extents_consistent(new, be)) {
 				/* extend new to fully replace be */
-				new->be_length += be->be_f_offset + be->be_length -
-					new->be_f_offset - new->be_length;
+				new->be_length +=
+				    be->be_f_offset + be->be_length -
+				    new->be_f_offset - new->be_length;
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
 				put_extent(be);
@@ -655,7 +654,7 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 	 */
 	return 0;
 
- out_err:
+out_err:
 	put_extent(new);
 	return -EIO;
 }
@@ -668,14 +667,14 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
  * 1. Extents are ordered by file offset.
  * 2. For any given isect, there is at most one extents that matches.
  */
-struct pnfs_block_extent *
-find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
-	    struct pnfs_block_extent **cow_read)
+struct pnfs_block_extent *find_get_extent(struct pnfs_block_layout *bl,
+					  sector_t isect,
+					  struct pnfs_block_extent **cow_read)
 {
 	struct pnfs_block_extent *be, *cow, *ret;
 	int i;
 
-	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	dprintk("%s enter with isect %llu\n", __func__, (u64) isect);
 	cow = ret = NULL;
 	spin_lock(&bl->bl_ext_lock);
 	for (i = 0; i < EXTENT_LISTS; i++) {
@@ -708,13 +707,13 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 }
 
 /* Similar to find_get_extent, but called with lock held, and ignores cow */
-static struct pnfs_block_extent *
-find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
+static struct pnfs_block_extent *find_get_extent_locked(struct pnfs_block_layout
+							*bl, sector_t isect)
 {
 	struct pnfs_block_extent *be, *ret = NULL;
 	int i;
 
-	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	dprintk("%s enter with isect %llu\n", __func__, (u64) isect);
 	for (i = 0; i < EXTENT_LISTS; i++) {
 		if (ret)
 			break;
@@ -761,7 +760,8 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
 		if (!p)
 			break;
-		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
+		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data,
+					    NFS4_DEVICEID4_SIZE);
 		p = xdr_encode_hyper(p, lce->bse_f_offset << 9);
 		p = xdr_encode_hyper(p, lce->bse_length << 9);
 		p = xdr_encode_hyper(p, 0LL);
@@ -799,9 +799,9 @@ _prep_new_extent(struct pnfs_block_extent *new,
 /* Tries to merge be with extent in front of it in list.
  * Frees storage if not used.
  */
-static struct pnfs_block_extent *
-_front_merge(struct pnfs_block_extent *be, struct list_head *head,
-	     struct pnfs_block_extent *storage)
+static struct pnfs_block_extent *_front_merge(struct pnfs_block_extent *be,
+					      struct list_head *head,
+					      struct pnfs_block_extent *storage)
 {
 	struct pnfs_block_extent *prev;
 
@@ -821,13 +821,12 @@ _front_merge(struct pnfs_block_extent *be, struct list_head *head,
 	put_extent(be);
 	return storage;
 
- no_merge:
+no_merge:
 	kfree(storage);
 	return be;
 }
 
-static u64
-set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
+static u64 set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 {
 	u64 rv = offset + length;
 	struct pnfs_block_extent *be, *e1, *e2, *e3, *new, *old;
@@ -868,8 +867,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 	if (offset + length < be->be_f_offset + be->be_length) {
 		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
 				 be->be_f_offset + be->be_length -
-				 offset - length,
-				 PNFS_BLOCK_INVALID_DATA);
+				 offset - length, PNFS_BLOCK_INVALID_DATA);
 		children[i++] = e3;
 		print_bl_extent(e3);
 	} else
@@ -905,7 +903,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 	dprintk("%s returns %llu after split\n", __func__, rv);
 	return rv;
 
- out_nosplit:
+out_nosplit:
 	kfree(e1);
 	kfree(e2);
 	kfree(e3);
@@ -921,7 +919,8 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	struct pnfs_block_short_extent *lce, *save;
 
 	dprintk("%s status %d\n", __func__, status);
-	list_for_each_entry_safe_reverse(lce, save, &bl->bl_committing, bse_node) {
+	list_for_each_entry_safe_reverse(lce, save, &bl->bl_committing,
+					 bse_node) {
 		if (likely(!status)) {
 			u64 offset = lce->bse_f_offset;
 			u64 end = offset + lce->bse_length;
-- 
1.7.4.1

