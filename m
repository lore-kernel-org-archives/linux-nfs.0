Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45771 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717Ab1FLXpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:45:07 -0400
Message-Id: <33022790294d4061ab6315b638249c94b5fa982a.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:45:05 -0400
Subject: [PATCH 31/34] pnfsblock: note written INVAL areas for layoutcommit
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

[SQUASHME: pnfs: blocklayout: port block layout code]
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   32 +++++++++++++
 fs/nfs/blocklayout/blocklayout.h |    2 +
 fs/nfs/blocklayout/extents.c     |   95 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 03ce7c3..242c232 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -320,6 +320,30 @@ bl_read_pagelist(struct nfs_read_data *rdata)
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
+		sector_t len;
+		be = find_get_extent(bl, isect, NULL);
+		BUG_ON(!be); /* FIXME */
+		len = min(end, be->be_f_offset + be->be_length) - isect;
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
+			mark_for_commit(be, isect, len); /* What if fails? */
+		isect += len;
+		put_extent(be);
+	}
+}
+
 /* STUB - this needs thought */
 static inline void
 bl_done_with_wpage(struct page *page, const int ok)
@@ -367,6 +391,14 @@ static void bl_write_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
+	if (!wdata->task.tk_status) {
+		/* Marks for LAYOUTCOMMIT */
+		/* BUG - this should be called after each bio, not after
+		 * all finish, unless have some way of storing success/failure
+		 */
+		mark_extents_written(BLK_LSEG2EXT(wdata->lseg),
+				     wdata->args.offset, wdata->args.count);
+	}
 	pnfs_ld_write_done(wdata);
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 3b3e70a..163125c 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -267,6 +267,8 @@ void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   int status);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
+int mark_for_commit(struct pnfs_block_extent *be,
+		    sector_t offset, sector_t length);
 
 #include <linux/sunrpc/simple_rpc_pipefs.h>
 
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 1447bfc..a62d29f 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -217,6 +217,48 @@ int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)
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
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector >= end)
+			continue;
+		if (!expect) {
+			if ((pos->it_sector == end - tree->mtt_step_size) &&
+			    (pos->it_tags & (1 << tag))) {
+				expect = pos->it_sector - tree->mtt_step_size;
+				if (pos->it_sector < tree->mtt_step_size || expect < start)
+					return 1;
+				continue;
+			} else {
+				return 0;
+			}
+		}
+		if (pos->it_sector != expect || !(pos->it_tags & (1 << tag)))
+			return 0;
+		expect -= tree->mtt_step_size;
+		if (expect < start)
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
@@ -394,6 +436,59 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,
 	print_clist(clist, bl->bl_count);
 }
 
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

