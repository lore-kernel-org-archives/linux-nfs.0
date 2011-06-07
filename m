Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53844 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1FGR3z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:55 -0400
Date: Tue, 7 Jun 2011 13:29:53 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 34/88] pnfsblock: note written INVAL areas for layoutcommit
Message-ID: <e9640b73303a3bf73ad5ff38d36d1842dfabf56c.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   37 ++++++++
 fs/nfs/blocklayout/blocklayout.h |   13 +++
 fs/nfs/blocklayout/extents.c     |  173 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 223 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index df0cfe4..d4396d6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -335,6 +335,33 @@ bl_read_pagelist(struct pnfs_layout_type *lo,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static void mark_extents_written(struct pnfs_block_layout *bl,
+				 __u64 offset, __u32 count)
+{
+	sector_t isect, end;
+	struct pnfs_block_extent *be;
+
+	dprintk("%s(%llu, %u)\n", __func__, offset, count);
+	if (count == 0)
+		return;
+	isect = (offset & (long)(PAGE_CACHE_MASK)) >> 9;
+	end = (offset + count + PAGE_CACHE_SIZE - 1) & (long)(PAGE_CACHE_MASK);
+	end >>= 9;
+	while (isect < end) {
+		be = find_get_extent(bl, isect, NULL);
+		BUG_ON(!be); /* FIXME */
+		if (be->be_state != PNFS_BLOCK_INVALID_DATA)
+			isect += be->be_length;
+		else {
+			sector_t len;
+			len = min(end, be->be_f_offset + be->be_length) - isect;
+			mark_for_commit(be, isect, len); /* What if fails? */
+			isect += len;
+		}
+		put_extent(be);
+	}
+}
+
 /* STUB - this needs thought */
 static inline void
 bl_done_with_wpage(struct page *page, const int ok)
@@ -382,6 +409,14 @@ static void bl_write_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
+	if (!wdata->task.tk_status) {
+		/* Marks for LAYOUTCOMMIT */
+		/* BUG - this should be called after each bio, not after
+		 * all finish, unless have some way of storing success/failure
+		 */
+		mark_extents_written(BLK_LSEG2EXT(wdata->pdata.lseg),
+				     wdata->args.offset, wdata->args.count);
+	}
 	pnfs_callback_ops->nfs_writelist_complete(wdata);
 }
 
@@ -538,6 +573,8 @@ bl_alloc_layout(struct pnfs_mount_type *mtype, struct inode *inode)
 	spin_lock_init(&bl->bl_ext_lock);
 	INIT_LIST_HEAD(&bl->bl_extents[0]);
 	INIT_LIST_HEAD(&bl->bl_extents[1]);
+	INIT_LIST_HEAD(&bl->bl_commit);
+	bl->bl_count = 0;
 	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
 	INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
 	return bl;
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index c4b7b40..1ec9bff 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -139,6 +139,15 @@ struct pnfs_block_extent {
 	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
 };
 
+/* Shortened extent used by LAYOUTCOMMIT */
+struct pnfs_block_short_extent {
+	struct list_head bse_node;
+	struct pnfs_deviceid bse_devid;	/* STUB - removable??? */
+	struct block_device *bse_mdev;
+	sector_t	bse_f_offset;	/* the starting offset in the file */
+	sector_t	bse_length;	/* the size of the extent */
+};
+
 static inline void
 INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
@@ -167,6 +176,8 @@ struct pnfs_block_layout {
 	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
 	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
+	struct list_head	bl_commit;	/* Needs layout commit */
+	unsigned int		bl_count;	/* entries in bl_commit */
 	sector_t		bl_blocksize;  /* Server blocksize in sectors */
 };
 
@@ -235,4 +246,6 @@ struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
+int mark_for_commit(struct pnfs_block_extent *be,
+		    sector_t offset, sector_t length);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index ef8a5b7..d4e4a92 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -223,6 +223,48 @@ int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)
 	return rv;
 }
 
+/* Assume start, end already sector aligned */
+static int
+_range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
+{
+	struct pnfs_inval_tracking *pos;
+	u64 expect = 0;
+
+	dprintk("%s(%llu, %llu, %i) enter\n", __func__, start, end, tag);
+	list_for_each_entry(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector < start)
+			continue;
+		if (!expect) {
+			if ((pos->it_sector == start) &&
+			    (pos->it_tags & (1 << tag))) {
+				expect = start + tree->mtt_step_size;
+				if (expect == end)
+					return 1;
+				continue;
+			} else {
+				return 0;
+			}
+		}
+		if (pos->it_sector != expect || !(pos->it_tags & (1 << tag)))
+			return 0;
+		expect += tree->mtt_step_size;
+		if (expect == end)
+			return 1;
+	}
+	return 0;
+}
+
+static int is_range_written(struct pnfs_inval_markings *marks,
+			    sector_t start, sector_t end)
+{
+	int rv;
+
+	spin_lock(&marks->im_lock);
+	rv = _range_has_tag(&marks->im_tree, start, end, EXTENT_WRITTEN);
+	spin_unlock(&marks->im_lock);
+	return rv;
+}
+
 /* Marks sectors in [offest, offset_length) as having been initialized.
  * All lengths are step-aligned, where step is min(pagesize, blocksize).
  * Notes where partial block is initialized, and helps prepare it for
@@ -292,6 +334,137 @@ int mark_initialized_sectors(struct pnfs_inval_markings *marks,
 	return -ENOMEM;
 }
 
+/* Marks sectors in [offest, offset+length) as having been written to disk.
+ * All lengths should be block aligned.
+ */
+int mark_written_sectors(struct pnfs_inval_markings *marks,
+			 sector_t offset, sector_t length)
+{
+	int status;
+
+	dprintk("%s(offset=%llu,len=%llu) enter\n", __func__,
+		(u64)offset, (u64)length);
+	spin_lock(&marks->im_lock);
+	status = _set_range(&marks->im_tree, EXTENT_WRITTEN, offset, length);
+	spin_unlock(&marks->im_lock);
+	return status;
+}
+
+/* Note: In theory, we should do more checking that devid's match between
+ * old and new, but if they don't, the lists are too corrupt to salvage anyway.
+ */
+/* Note this is very similar to add_and_merge_extent */
+static void add_to_commitlist(struct pnfs_block_layout *bl,
+			      struct pnfs_block_short_extent *new)
+{
+	struct list_head *clist = &bl->bl_commit;
+	struct pnfs_block_short_extent *old, *save;
+	sector_t end = new->bse_f_offset + new->bse_length;
+
+	bl->bl_count++;
+	/* Scan for proper place to insert, extending new to the left
+	 * as much as possible.
+	 */
+	list_for_each_entry_safe(old, save, clist, bse_node) {
+		if (new->bse_f_offset < old->bse_f_offset)
+			break;
+		if (end <= old->bse_f_offset + old->bse_length) {
+			/* Range is already in list */
+			bl->bl_count--;
+			kfree(new);
+			return;
+		} else if (new->bse_f_offset <=
+				old->bse_f_offset + old->bse_length) {
+			/* new overlaps or abuts existing be */
+			if (new->bse_mdev == old->bse_mdev) {
+				/* extend new to fully replace old */
+				new->bse_length += new->bse_f_offset -
+						old->bse_f_offset;
+				new->bse_f_offset = old->bse_f_offset;
+				list_del(&old->bse_node);
+				bl->bl_count--;
+				kfree(old);
+			}
+		}
+	}
+	/* Note that if we never hit the above break, old will not point to a
+	 * valid extent.  However, in that case &old->bse_node==list.
+	 */
+	list_add_tail(&new->bse_node, &old->bse_node);
+	/* Scan forward for overlaps.  If we find any, extend new and
+	 * remove the overlapped extent.
+	 */
+	old = list_prepare_entry(new, clist, bse_node);
+	list_for_each_entry_safe_continue(old, save, clist, bse_node) {
+		if (end < old->bse_f_offset)
+			break;
+		/* new overlaps or abuts old */
+		if (new->bse_mdev == old->bse_mdev) {
+			if (end < old->bse_f_offset + old->bse_length) {
+				/* extend new to fully cover old */
+				end = old->bse_f_offset + old->bse_length;
+				new->bse_length = end - new->bse_f_offset;
+			}
+			list_del(&old->bse_node);
+			bl->bl_count--;
+			kfree(old);
+		}
+	}
+}
+
+/* Note the range described by offset, length is guaranteed to be contained
+ * within be.
+ */
+int mark_for_commit(struct pnfs_block_extent *be,
+		    sector_t offset, sector_t length)
+{
+	sector_t new_end, end = offset + length;
+	struct pnfs_block_short_extent *new;
+	struct pnfs_block_layout *bl = container_of(be->be_inval,
+						    struct pnfs_block_layout,
+						    bl_inval);
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	mark_written_sectors(be->be_inval, offset, length);
+	/* We want to add the range to commit list, but it must be
+	 * block-normalized, and verified that the normalized range has
+	 * been entirely written to disk.
+	 */
+	new->bse_f_offset = offset;
+	offset = normalize(offset, bl->bl_blocksize);
+	if (offset < new->bse_f_offset) {
+		if (is_range_written(be->be_inval, offset, new->bse_f_offset))
+			new->bse_f_offset = offset;
+		else
+			new->bse_f_offset = offset + bl->bl_blocksize;
+	}
+	new_end = normalize_up(end, bl->bl_blocksize);
+	if (end < new_end) {
+		if (is_range_written(be->be_inval, end, new_end))
+			end = new_end;
+		else
+			end = new_end - bl->bl_blocksize;
+	}
+	if (end <= new->bse_f_offset) {
+		kfree(new);
+		return 0;
+	}
+	new->bse_length = end - new->bse_f_offset;
+	new->bse_devid = be->be_devid;
+	new->bse_mdev = be->be_mdev;
+
+	spin_lock(&bl->bl_ext_lock);
+	/* new will be freed, either by add_to_commitlist if it decides not
+	 * to use it, or after LAYOUTCOMMIT uses it in the commitlist.
+	 */
+	add_to_commitlist(bl, new);
+	spin_unlock(&bl->bl_ext_lock);
+	return 0;
+}
+
 static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
-- 
1.7.4.1

