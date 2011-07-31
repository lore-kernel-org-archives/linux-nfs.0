Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:37714 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab1GaAx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 20:53:29 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v7 19/26] pnfsblock: add extent manipulation functions
Date: Sat, 30 Jul 2011 20:52:49 -0400
Message-Id: <1312073576-11024-20-git-send-email-rees@umich.edu>
In-Reply-To: <1312073576-11024-1-git-send-email-rees@umich.edu>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Adds working implementations of various support functions
to handle INVAL extents, needed by writes, such as
bl_mark_sectors_init and bl_is_sector_init.

[pnfsblock: fix 64-bit compiler warnings for extent manipulation]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[Implement release_inval_marks]
Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |    7 +-
 fs/nfs/blocklayout/blocklayout.h |   30 ++++-
 fs/nfs/blocklayout/extents.c     |  253 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 287 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6cd7f4f..8c29a18 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -78,10 +78,15 @@ release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
 	spin_unlock(&bl->bl_ext_lock);
 }
 
-/* STUB */
 static void
 release_inval_marks(struct pnfs_inval_markings *marks)
 {
+	struct pnfs_inval_tracking *pos, *temp;
+
+	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
+		list_del(&pos->it_link);
+		kfree(pos);
+	}
 	return;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 3e1b5fc..fcf47b5 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -38,6 +38,9 @@
 
 #include "../pnfs.h"
 
+#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
+#define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
+
 struct block_mount_id {
 	spinlock_t			bm_lock;    /* protects list */
 	struct list_head		bm_devlist; /* holds pnfs_block_dev */
@@ -56,8 +59,23 @@ enum exstate4 {
 	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
 };
 
+#define MY_MAX_TAGS (15) /* tag bitnums used must be less than this */
+
+struct my_tree {
+	sector_t		mtt_step_size;	/* Internal sector alignment */
+	struct list_head	mtt_stub; /* Should be a radix tree */
+};
+
 struct pnfs_inval_markings {
-	/* STUB */
+	spinlock_t	im_lock;
+	struct my_tree	im_tree;	/* Sectors that need LAYOUTCOMMIT */
+	sector_t	im_block_size;	/* Server blocksize in sectors */
+};
+
+struct pnfs_inval_tracking {
+	struct list_head it_link;
+	int		 it_sector;
+	int		 it_tags;
 };
 
 /* sector_t fields are all in 512-byte sectors */
@@ -76,7 +94,11 @@ struct pnfs_block_extent {
 static inline void
 BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
-	/* STUB */
+	spin_lock_init(&marks->im_lock);
+	INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
+	marks->im_block_size = blocksize;
+	marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
+					   blocksize);
 }
 
 enum extentclass4 {
@@ -156,8 +178,12 @@ void bl_free_block_dev(struct pnfs_block_dev *bdev);
 struct pnfs_block_extent *
 bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 		struct pnfs_block_extent **cow_read);
+int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
+			     sector_t offset, sector_t length,
+			     sector_t **pages);
 void bl_put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *bl_alloc_extent(void);
+int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect);
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 8fa93e2..473faee 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -33,6 +33,259 @@
 #include "blocklayout.h"
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+/* Bit numbers */
+#define EXTENT_INITIALIZED 0
+#define EXTENT_WRITTEN     1
+#define EXTENT_IN_COMMIT   2
+#define INTERNAL_EXISTS    MY_MAX_TAGS
+#define INTERNAL_MASK      ((1 << INTERNAL_EXISTS) - 1)
+
+/* Returns largest t<=s s.t. t%base==0 */
+static inline sector_t normalize(sector_t s, int base)
+{
+	sector_t tmp = s; /* Since do_div modifies its argument */
+	return s - do_div(tmp, base);
+}
+
+static inline sector_t normalize_up(sector_t s, int base)
+{
+	return normalize(s + base - 1, base);
+}
+
+/* Complete stub using list while determine API wanted */
+
+/* Returns tags, or negative */
+static int32_t _find_entry(struct my_tree *tree, u64 s)
+{
+	struct pnfs_inval_tracking *pos;
+
+	dprintk("%s(%llu) enter\n", __func__, s);
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector > s)
+			continue;
+		else if (pos->it_sector == s)
+			return pos->it_tags & INTERNAL_MASK;
+		else
+			break;
+	}
+	return -ENOENT;
+}
+
+static inline
+int _has_tag(struct my_tree *tree, u64 s, int32_t tag)
+{
+	int32_t tags;
+
+	dprintk("%s(%llu, %i) enter\n", __func__, s, tag);
+	s = normalize(s, tree->mtt_step_size);
+	tags = _find_entry(tree, s);
+	if ((tags < 0) || !(tags & (1 << tag)))
+		return 0;
+	else
+		return 1;
+}
+
+/* Creates entry with tag, or if entry already exists, unions tag to it.
+ * If storage is not NULL, newly created entry will use it.
+ * Returns number of entries added, or negative on error.
+ */
+static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
+		      struct pnfs_inval_tracking *storage)
+{
+	int found = 0;
+	struct pnfs_inval_tracking *pos;
+
+	dprintk("%s(%llu, %i, %p) enter\n", __func__, s, tag, storage);
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector > s)
+			continue;
+		else if (pos->it_sector == s) {
+			found = 1;
+			break;
+		} else
+			break;
+	}
+	if (found) {
+		pos->it_tags |= (1 << tag);
+		return 0;
+	} else {
+		struct pnfs_inval_tracking *new;
+		if (storage)
+			new = storage;
+		else {
+			new = kmalloc(sizeof(*new), GFP_NOFS);
+			if (!new)
+				return -ENOMEM;
+		}
+		new->it_sector = s;
+		new->it_tags = (1 << tag);
+		list_add(&new->it_link, &pos->it_link);
+		return 1;
+	}
+}
+
+/* XXXX Really want option to not create */
+/* Over range, unions tag with existing entries, else creates entry with tag */
+static int _set_range(struct my_tree *tree, int32_t tag, u64 s, u64 length)
+{
+	u64 i;
+
+	dprintk("%s(%i, %llu, %llu) enter\n", __func__, tag, s, length);
+	for (i = normalize(s, tree->mtt_step_size); i < s + length;
+	     i += tree->mtt_step_size)
+		if (_add_entry(tree, i, tag, NULL))
+			return -ENOMEM;
+	return 0;
+}
+
+/* Ensure that future operations on given range of tree will not malloc */
+static int _preload_range(struct my_tree *tree, u64 offset, u64 length)
+{
+	u64 start, end, s;
+	int count, i, used = 0, status = -ENOMEM;
+	struct pnfs_inval_tracking **storage;
+
+	dprintk("%s(%llu, %llu) enter\n", __func__, offset, length);
+	start = normalize(offset, tree->mtt_step_size);
+	end = normalize_up(offset + length, tree->mtt_step_size);
+	count = (int)(end - start) / (int)tree->mtt_step_size;
+
+	/* Pre-malloc what memory we might need */
+	storage = kmalloc(sizeof(*storage) * count, GFP_NOFS);
+	if (!storage)
+		return -ENOMEM;
+	for (i = 0; i < count; i++) {
+		storage[i] = kmalloc(sizeof(struct pnfs_inval_tracking),
+				     GFP_NOFS);
+		if (!storage[i])
+			goto out_cleanup;
+	}
+
+	/* Now need lock - HOW??? */
+
+	for (s = start; s < end; s += tree->mtt_step_size)
+		used += _add_entry(tree, s, INTERNAL_EXISTS, storage[used]);
+
+	/* Unlock - HOW??? */
+	status = 0;
+
+ out_cleanup:
+	for (i = used; i < count; i++) {
+		if (!storage[i])
+			break;
+		kfree(storage[i]);
+	}
+	kfree(storage);
+	return status;
+}
+
+static void set_needs_init(sector_t *array, sector_t offset)
+{
+	sector_t *p = array;
+
+	dprintk("%s enter\n", __func__);
+	if (!p)
+		return;
+	while (*p < offset)
+		p++;
+	if (*p == offset)
+		return;
+	else if (*p == ~0) {
+		*p++ = offset;
+		*p = ~0;
+		return;
+	} else {
+		sector_t *save = p;
+		dprintk("%s Adding %llu\n", __func__, (u64)offset);
+		while (*p != ~0)
+			p++;
+		p++;
+		memmove(save + 1, save, (char *)p - (char *)save);
+		*save = offset;
+		return;
+	}
+}
+
+/* We are relying on page lock to serialize this */
+int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect)
+{
+	int rv;
+
+	spin_lock(&marks->im_lock);
+	rv = _has_tag(&marks->im_tree, isect, EXTENT_INITIALIZED);
+	spin_unlock(&marks->im_lock);
+	return rv;
+}
+
+/* Marks sectors in [offest, offset_length) as having been initialized.
+ * All lengths are step-aligned, where step is min(pagesize, blocksize).
+ * Notes where partial block is initialized, and helps prepare it for
+ * complete initialization later.
+ */
+/* Currently assumes offset is page-aligned */
+int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
+			     sector_t offset, sector_t length,
+			     sector_t **pages)
+{
+	sector_t s, start, end;
+	sector_t *array = NULL; /* Pages to mark */
+
+	dprintk("%s(offset=%llu,len=%llu) enter\n",
+		__func__, (u64)offset, (u64)length);
+	s = max((sector_t) 3,
+		2 * (marks->im_block_size / (PAGE_CACHE_SECTORS)));
+	dprintk("%s set max=%llu\n", __func__, (u64)s);
+	if (pages) {
+		array = kmalloc(s * sizeof(sector_t), GFP_NOFS);
+		if (!array)
+			goto outerr;
+		array[0] = ~0;
+	}
+
+	start = normalize(offset, marks->im_block_size);
+	end = normalize_up(offset + length, marks->im_block_size);
+	if (_preload_range(&marks->im_tree, start, end - start))
+		goto outerr;
+
+	spin_lock(&marks->im_lock);
+
+	for (s = normalize_up(start, PAGE_CACHE_SECTORS);
+	     s < offset; s += PAGE_CACHE_SECTORS) {
+		dprintk("%s pre-area pages\n", __func__);
+		/* Portion of used block is not initialized */
+		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
+			set_needs_init(array, s);
+	}
+	if (_set_range(&marks->im_tree, EXTENT_INITIALIZED, offset, length))
+		goto out_unlock;
+	for (s = normalize_up(offset + length, PAGE_CACHE_SECTORS);
+	     s < end; s += PAGE_CACHE_SECTORS) {
+		dprintk("%s post-area pages\n", __func__);
+		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
+			set_needs_init(array, s);
+	}
+
+	spin_unlock(&marks->im_lock);
+
+	if (pages) {
+		if (array[0] == ~0) {
+			kfree(array);
+			*pages = NULL;
+		} else
+			*pages = array;
+	}
+	return 0;
+
+ out_unlock:
+	spin_unlock(&marks->im_lock);
+ outerr:
+	if (pages) {
+		kfree(array);
+		*pages = NULL;
+	}
+	return -ENOMEM;
+}
+
 static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
-- 
1.7.4.1

