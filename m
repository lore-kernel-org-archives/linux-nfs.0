Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:60054 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751254Ab0EJDhq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 May 2010 23:37:46 -0400
Date: Mon, 10 May 2010 11:36:11 +0800
From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com, iisaman@citi.umich.edu
Subject: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Message-ID: <20100510033610.GA5443@MDS-78.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Optimize for sequencial write. Layout infos and tags are organized by
file offset. When appending data to a file whole list will be examined,
which introduce notable performance decrease.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
---
 fs/nfs/blocklayout/extents.c |  126 +++++++++++++++++++++---------------------
 1 files changed, 64 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 3c311f2..514f2cc 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -66,8 +66,8 @@ static int32_t _find_entry(struct my_tree_t *tree, u64 s)
 	struct pnfs_inval_tracking *pos;
 
 	dprintk("%s(%llu) enter\n", __func__, s);
-	list_for_each_entry(pos, &tree->mtt_stub, it_link) {
-		if (pos->it_sector < s)
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector > s)
 			continue;
 		else if (pos->it_sector == s)
 			return pos->it_tags & INTERNAL_MASK;
@@ -102,8 +102,8 @@ static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,
 	struct pnfs_inval_tracking *pos;
 
 	dprintk("%s(%llu, %i, %p) enter\n", __func__, s, tag, storage);
-	list_for_each_entry(pos, &tree->mtt_stub, it_link) {
-		if (pos->it_sector < s)
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector > s)
 			continue;
 		else if (pos->it_sector == s) {
 			found = 1;
@@ -125,7 +125,7 @@ static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,
 		}
 		new->it_sector = s;
 		new->it_tags = (1 << tag);
-		list_add_tail(&new->it_link, &pos->it_link);
+		list_add(&new->it_link, &pos->it_link);
 		return 1;
 	}
 }
@@ -230,14 +230,14 @@ _range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
 	u64 expect = 0;
 
 	dprintk("%s(%llu, %llu, %i) enter\n", __func__, start, end, tag);
-	list_for_each_entry(pos, &tree->mtt_stub, it_link) {
-		if (pos->it_sector < start)
+	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
+		if (pos->it_sector >= end)
 			continue;
 		if (!expect) {
-			if ((pos->it_sector == start) &&
+			if ((pos->it_sector == end - tree->mtt_step_size) &&
 			    (pos->it_tags & (1 << tag))) {
-				expect = start + tree->mtt_step_size;
-				if (expect == end)
+				expect = pos->it_sector - tree->mtt_step_size;
+				if (expect < start)
 					return 1;
 				continue;
 			} else {
@@ -246,8 +246,8 @@ _range_has_tag(struct my_tree_t *tree, u64 start, u64 end, int32_t tag)
 		}
 		if (pos->it_sector != expect || !(pos->it_tags & (1 << tag)))
 			return 0;
-		expect += tree->mtt_step_size;
-		if (expect == end)
+		expect -= tree->mtt_step_size;
+		if (expect < start)
 			return 1;
 	}
 	return 0;
@@ -594,65 +594,67 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
 	/* Scan for proper place to insert, extending new to the left
 	 * as much as possible.
 	 */
-	list_for_each_entry_safe(be, tmp, list, be_node) {
-		if (new->be_f_offset < be->be_f_offset)
+	list_for_each_entry_safe_reverse(be, tmp, list, be_node) {
+		if (new->be_f_offset >= be->be_f_offset + be->be_length)
 			break;
-		if (end <= be->be_f_offset + be->be_length) {
-			/* new is a subset of existing be*/
+		if (new->be_f_offset >= be->be_f_offset) {
+			if (end <= be->be_f_offset + be->be_length) {
+				/* new is a subset of existing be*/
+				if (extents_consistent(be, new)) {
+					dprintk("%s: new is subset, ignoring\n",
+						__func__);
+					put_extent(new);
+					return 0;
+				} else {
+					goto out_err;
+				}
+			} else {
+				/* |<--   be   -->|
+				 *          |<--   new   -->| */
+				if (extents_consistent(be, new)) {
+					/* extend new to fully replace be */
+					new->be_length += new->be_f_offset -
+						be->be_f_offset;
+					new->be_f_offset = be->be_f_offset;
+					new->be_v_offset = be->be_v_offset;
+					dprintk("%s: removing %p\n", __func__, be);
+					list_del(&be->be_node);
+					put_extent(be);
+				} else {
+					goto out_err;
+				}
+			}
+		} else if (end >= be->be_f_offset + be->be_length) {
+			/* new extent overlap existing be */
 			if (extents_consistent(be, new)) {
-				dprintk("%s: new is subset, ignoring\n",
-					__func__);
-				put_extent(new);
-				return 0;
-			} else
+				/* extend new to fully replace be */
+				dprintk("%s: removing %p\n", __func__, be);
+				list_del(&be->be_node);
+				put_extent(be);
+			} else {
 				goto out_err;
-		} else if (new->be_f_offset <=
-				be->be_f_offset + be->be_length) {
-			/* new overlaps or abuts existing be */
-			if (extents_consistent(be, new)) {
+			}
+		} else if (end > be->be_f_offset) {
+			/*           |<--   be   -->|
+			 *|<--   new   -->| */
+			if (extents_consistent(new, be)) {
 				/* extend new to fully replace be */
-				new->be_length += new->be_f_offset -
-						  be->be_f_offset;
-				new->be_f_offset = be->be_f_offset;
-				new->be_v_offset = be->be_v_offset;
+				new->be_length += be->be_f_offset + be->be_length -
+					new->be_f_offset - new->be_length;
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
 				put_extent(be);
-			} else if (new->be_f_offset !=
-				   be->be_f_offset + be->be_length)
+			} else {
 				goto out_err;
+			}
 		}
 	}
 	/* Note that if we never hit the above break, be will not point to a
 	 * valid extent.  However, in that case &be->be_node==list.
 	 */
-	list_add_tail(&new->be_node, &be->be_node);
+	list_add(&new->be_node, &be->be_node);
 	dprintk("%s: inserting new\n", __func__);
 	print_elist(list);
-	/* Scan forward for overlaps.  If we find any, extend new and
-	 * remove the overlapped extent.
-	 */
-	be = list_prepare_entry(new, list, be_node);
-	list_for_each_entry_safe_continue(be, tmp, list, be_node) {
-		if (end < be->be_f_offset)
-			break;
-		/* new overlaps or abuts existing be */
-		if (extents_consistent(be, new)) {
-			if (end < be->be_f_offset + be->be_length) {
-				/* extend new to fully cover be */
-				end = be->be_f_offset + be->be_length;
-				new->be_length = end - new->be_f_offset;
-			}
-			dprintk("%s: removing %p\n", __func__, be);
-			list_del(&be->be_node);
-			put_extent(be);
-		} else if (end != be->be_f_offset) {
-			list_del(&new->be_node);
-			goto out_err;
-		}
-	}
-	dprintk("%s: after merging\n", __func__);
-	print_elist(list);
 	/* STUB - The per-list consistency checks have all been done,
 	 * should now check cross-list consistency.
 	 */
@@ -685,10 +687,10 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 		if (ret &&
 		    (!cow_read || ret->be_state != PNFS_BLOCK_INVALID_DATA))
 			break;
-		list_for_each_entry(be, &bl->bl_extents[i], be_node) {
-			if (isect < be->be_f_offset)
+		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
+			if (isect >= be->be_f_offset + be->be_length)
 				break;
-			if (isect < be->be_f_offset + be->be_length) {
+			if (isect >= be->be_f_offset) {
 				/* We have found an extent */
 				dprintk("%s Get %p (%i)\n", __func__, be,
 					atomic_read(&be->be_refcnt.refcount));
@@ -721,10 +723,10 @@ find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
 	for (i = 0; i < EXTENT_LISTS; i++) {
 		if (ret)
 			break;
-		list_for_each_entry(be, &bl->bl_extents[i], be_node) {
-			if (isect < be->be_f_offset)
+		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
+			if (isect >= be->be_f_offset + be->be_length)
 				break;
-			if (isect < be->be_f_offset + be->be_length) {
+			if (isect >= be->be_f_offset) {
 				/* We have found an extent */
 				dprintk("%s Get %p (%i)\n", __func__, be,
 					atomic_read(&be->be_refcnt.refcount));
-- 
1.6.2.5

