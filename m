Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53486 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab1FGR2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:44 -0400
Date: Tue, 7 Jun 2011 13:28:42 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 23/88] pnfsblock: merge extents
Message-ID: <698910d29d0a96738d314a6af69abcf0b9c95428.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Replace a stub, so that extents underlying the layouts are properly
added, merged, or ignored as necessary.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: delete the new node before put it]
Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h    |   10 +++
 fs/nfs/blocklayout/blocklayoutdev.c |   19 +++++-
 fs/nfs/blocklayout/extents.c        |  128 +++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index f91939d..13fc0e2 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -135,6 +135,14 @@ enum extentclass4 {
 	EXTENT_LISTS	= 2,
 };
 
+static inline int choose_list(enum exstate4 state)
+{
+	if (state == PNFS_BLOCK_READ_DATA || state == PNFS_BLOCK_NONE_DATA)
+		return RO_EXTENT;
+	else
+		return RW_EXTENT;
+}
+
 struct pnfs_block_layout {
 	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
@@ -197,4 +205,6 @@ void free_block_dev(struct pnfs_block_dev *bdev);
 /* extents.c */
 void put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
+int add_and_merge_extent(struct pnfs_block_layout *bl,
+			 struct pnfs_block_extent *new);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 77190fd..ac5c117 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -642,7 +642,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 	uint32_t *end = (uint32_t *)((char *)lgr->layout.buf + lgr->layout.len);
 	int i, status = -EIO;
 	uint32_t count;
-	struct pnfs_block_extent *be = NULL;
+	struct pnfs_block_extent *be = NULL, *save;
 	uint64_t tmp; /* Used by READSECTOR */
 	struct layout_verification lv = {
 		.mode = lgr->lseg.iomode,
@@ -706,9 +706,22 @@ nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 	/* Extents decoded properly, now try to merge them in to
 	 * existing layout extents.
 	 */
-	/* STUB - instead we just throw them away */
+	spin_lock(&bl->bl_ext_lock);
+	list_for_each_entry_safe(be, save, &extents, be_node) {
+		list_del(&be->be_node);
+		status = add_and_merge_extent(bl, be);
+		if (status) {
+			spin_unlock(&bl->bl_ext_lock);
+			/* This is a fairly catastrophic error, as the
+			 * entire layout extent lists are now corrupted.
+			 * We should have some way to distinguish this.
+			 */
+			be = NULL;
+			goto out_err;
+		}
+	}
+	spin_unlock(&bl->bl_ext_lock);
 	status = 0;
-	goto out_err;
  out:
 	dprintk("%s returns %i\n", __func__, status);
 	return status;
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index a952d39..ce7b6f7 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -33,6 +33,17 @@
 #include "blocklayout.h"
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+static void print_bl_extent(struct pnfs_block_extent *be)
+{
+	dprintk("PRINT EXTENT extent %p\n", be);
+	if (be) {
+		dprintk("        be_f_offset %llu\n", (u64)be->be_f_offset);
+		dprintk("        be_length   %llu\n", (u64)be->be_length);
+		dprintk("        be_v_offset %llu\n", (u64)be->be_v_offset);
+		dprintk("        be_state    %d\n", be->be_state);
+	}
+}
+
 static void
 destroy_extent(struct kref *kref)
 {
@@ -65,3 +76,120 @@ struct pnfs_block_extent *alloc_extent(void)
 	be->be_inval = NULL;
 	return be;
 }
+
+void print_elist(struct list_head *list)
+{
+	struct pnfs_block_extent *be;
+	dprintk("****************\n");
+	dprintk("Extent list looks like:\n");
+	list_for_each_entry(be, list, be_node) {
+		print_bl_extent(be);
+	}
+	dprintk("****************\n");
+}
+
+static inline int
+extents_consistent(struct pnfs_block_extent *old, struct pnfs_block_extent *new)
+{
+	/* Note this assumes new->be_f_offset >= old->be_f_offset */
+	return (new->be_state == old->be_state) &&
+		((new->be_state == PNFS_BLOCK_NONE_DATA) ||
+		 ((new->be_v_offset - old->be_v_offset ==
+		   new->be_f_offset - old->be_f_offset) &&
+		  new->be_mdev == old->be_mdev));
+}
+
+/* Adds new to appropriate list in bl, modifying new and removing existing
+ * extents as appropriate to deal with overlaps.
+ *
+ * See find_get_extent for list constraints.
+ *
+ * Refcount on new is already set.  If end up not using it, or error out,
+ * need to put the reference.
+ *
+ * Lock is held by caller.
+ */
+int
+add_and_merge_extent(struct pnfs_block_layout *bl,
+		     struct pnfs_block_extent *new)
+{
+	struct pnfs_block_extent *be, *tmp;
+	sector_t end = new->be_f_offset + new->be_length;
+	struct list_head *list;
+
+	dprintk("%s enter with be=%p\n", __func__, new);
+	print_bl_extent(new);
+	list = &bl->bl_extents[choose_list(new->be_state)];
+	print_elist(list);
+
+	/* Scan for proper place to insert, extending new to the left
+	 * as much as possible.
+	 */
+	list_for_each_entry_safe(be, tmp, list, be_node) {
+		if (new->be_f_offset < be->be_f_offset)
+			break;
+		if (end <= be->be_f_offset + be->be_length) {
+			/* new is a subset of existing be*/
+			if (extents_consistent(be, new)) {
+				dprintk("%s: new is subset, ignoring\n",
+					__func__);
+				put_extent(new);
+				return 0;
+			} else
+				goto out_err;
+		} else if (new->be_f_offset <=
+				be->be_f_offset + be->be_length) {
+			/* new overlaps or abuts existing be */
+			if (extents_consistent(be, new)) {
+				/* extend new to fully replace be */
+				new->be_length += new->be_f_offset -
+						  be->be_f_offset;
+				new->be_f_offset = be->be_f_offset;
+				new->be_v_offset = be->be_v_offset;
+				dprintk("%s: removing %p\n", __func__, be);
+				list_del(&be->be_node);
+				put_extent(be);
+			} else if (new->be_f_offset !=
+				   be->be_f_offset + be->be_length)
+				goto out_err;
+		}
+	}
+	/* Note that if we never hit the above break, be will not point to a
+	 * valid extent.  However, in that case &be->be_node==list.
+	 */
+	list_add_tail(&new->be_node, &be->be_node);
+	dprintk("%s: inserting new\n", __func__);
+	print_elist(list);
+	/* Scan forward for overlaps.  If we find any, extend new and
+	 * remove the overlapped extent.
+	 */
+	be = list_prepare_entry(new, list, be_node);
+	list_for_each_entry_safe_continue(be, tmp, list, be_node) {
+		if (end < be->be_f_offset)
+			break;
+		/* new overlaps or abuts existing be */
+		if (extents_consistent(be, new)) {
+			if (end < be->be_f_offset + be->be_length) {
+				/* extend new to fully cover be */
+				end = be->be_f_offset + be->be_length;
+				new->be_length = end - new->be_f_offset;
+			}
+			dprintk("%s: removing %p\n", __func__, be);
+			list_del(&be->be_node);
+			put_extent(be);
+		} else if (end != be->be_f_offset) {
+			list_del(&new->be_node);
+			goto out_err;
+		}
+	}
+	dprintk("%s: after merging\n", __func__);
+	print_elist(list);
+	/* STUB - The per-list consistency checks have all been done,
+	 * should now check cross-list consistency.
+	 */
+	return 0;
+
+ out_err:
+	put_extent(new);
+	return -EIO;
+}
-- 
1.7.4.1

