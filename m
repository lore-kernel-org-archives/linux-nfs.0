From: Jim Rees <rees@umich.edu>
Subject: [PATCH v1 12/25] pnfsblock: merge extents
Date: Sun, 17 Jul 2011 19:58:59 -0400
Message-ID: <1310947152-12255-13-git-send-email-rees@umich.edu>
References: <1310947152-12255-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:48957 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab1GQX7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 19:59:35 -0400
In-Reply-To: <1310947152-12255-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Replace a stub, so that extents underlying the layouts are properly
added, merged, or ignored as necessary.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: delete the new node before put it]
Signed-off-by: Mingyang Guo <guomingyang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.h |   13 +++++
 fs/nfs/blocklayout/extents.c     |  106 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 3777abc..d2d564a 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -80,6 +80,14 @@ enum extentclass4 {
 	EXTENT_LISTS    = 2,
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
 	struct pnfs_layout_hdr bl_layout;
 	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
@@ -137,5 +145,10 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 /* blocklayoutdm.c */
 void free_block_dev(struct pnfs_block_dev *bdev);
 
+/* extents.c */
 void bl_put_extent(struct pnfs_block_extent *be);
+struct pnfs_block_extent *alloc_extent(void);
+int bl_add_merge_extent(struct pnfs_block_layout *bl,
+			 struct pnfs_block_extent *new);
+
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 44c3364..d76bb43 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -95,3 +95,109 @@ void print_elist(struct list_head *list)
 	}
 	dprintk("****************\n");
 }
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
+ * See bl_find_get_extent for list constraints.
+ *
+ * Refcount on new is already set.  If end up not using it, or error out,
+ * need to put the reference.
+ *
+ * bl->bl_ext_lock is held by caller.
+ */
+int
+bl_add_merge_extent(struct pnfs_block_layout *bl,
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
+				bl_put_extent(new);
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
+				bl_put_extent(be);
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
+			bl_put_extent(be);
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
+	bl_put_extent(new);
+	return -EIO;
+}
-- 
1.7.4.1

