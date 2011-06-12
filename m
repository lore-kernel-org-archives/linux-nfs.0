Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60806 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1FLXor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:47 -0400
Message-Id: <5b1514ce2ecc72efba1628a13e9916f748d9c16b.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:44 -0400
Subject: [PATCH 23/34] pnfsblock: encode_layoutcommit
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

In blocklayout driver. There are two things happening
while layoutcommit/cleanup.
1. the modified extents are encoded.
2. On cleanup the extents are put back on the layout rw
   extents list, for reads.

In the new system where actual xdr encoding is done in
encode_layoutcommit() directly into xdr buffer, these are
the new commit stages:

1. On setup_layoutcommit, the range is adjusted as before
   and a structure is allocated for communication with
   bl_encode_layoutcommit && bl_cleanup_layoutcommit
   (Generic layer provides a void-star to hang it on)

2. bl_encode_layoutcommit is called to do the actual
   encoding directly into xdr. The commit-extent-list is not
   freed and is stored on above structure.
   FIXME: The code is not yet converted to the new XDR cleanup

3. On cleanup the commit-extent-list is put back by a call
   to set_to_rw() as before, but with no need for XDR decoding
   of the list as before. And the commit-extent-list is freed.
   Finally allocated structure is freed.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsblock: fix bug setting up layoutcommit.]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
[pnfsblock: prevent commit list corruption]
[pnfsblock: fix layoutcommit with an empty opaque]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +
 fs/nfs/blocklayout/blocklayout.h |   12 +++
 fs/nfs/blocklayout/extents.c     |  175 ++++++++++++++++++++++++++++----------
 3 files changed, 145 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 36374f4..1c9a5d0 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -156,6 +156,8 @@ static void
 bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
 		       const struct nfs4_layoutcommit_args *arg)
 {
+	dprintk("%s enter\n", __func__);
+	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index a231d49..03d703b 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -135,6 +135,15 @@ struct pnfs_block_extent {
 	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
 };
 
+/* Shortened extent used by LAYOUTCOMMIT */
+struct pnfs_block_short_extent {
+	struct list_head bse_node;
+	struct nfs4_deviceid bse_devid;	/* STUB - removable??? */
+	struct block_device *bse_mdev;
+	sector_t	bse_f_offset;	/* the starting offset in the file */
+	sector_t	bse_length;	/* the size of the extent */
+};
+
 static inline void
 INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
@@ -250,6 +259,9 @@ void put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
 struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
+int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+				   struct xdr_stream *xdr,
+				   const struct nfs4_layoutcommit_args *arg);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 43a3601..e754d32 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -286,6 +286,47 @@ int mark_initialized_sectors(struct pnfs_inval_markings *marks,
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
+static void print_short_extent(struct pnfs_block_short_extent *be)
+{
+	dprintk("PRINT SHORT EXTENT extent %p\n", be);
+	if (be) {
+		dprintk("        be_f_offset %llu\n", (u64)be->bse_f_offset);
+		dprintk("        be_length   %llu\n", (u64)be->bse_length);
+	}
+}
+
+void print_clist(struct list_head *list, unsigned int count)
+{
+	struct pnfs_block_short_extent *be;
+	unsigned int i = 0;
+
+	dprintk("****************\n");
+	dprintk("Extent list looks like:\n");
+	list_for_each_entry(be, list, bse_node) {
+		i++;
+		print_short_extent(be);
+	}
+	if (i != count)
+		dprintk("\n\nExpected %u entries\n\n\n", count);
+	dprintk("****************\n");
+}
+
 static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
@@ -386,65 +427,67 @@ add_and_merge_extent(struct pnfs_block_layout *bl,
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
@@ -502,6 +545,50 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	return ret;
 }
 
+int
+encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+			       struct xdr_stream *xdr,
+			       const struct nfs4_layoutcommit_args *arg)
+{
+	struct pnfs_block_short_extent *lce, *save;
+	unsigned int count = 0;
+	struct list_head *ranges = &bl->bl_committing;
+	__be32 *p, *xdr_start;
+
+	dprintk("%s enter\n", __func__);
+	/* BUG - creation of bl_commit is buggy - need to wait for
+	 * entire block to be marked WRITTEN before it can be added.
+	 */
+	spin_lock(&bl->bl_ext_lock);
+	/* Want to adjust for possible truncate */
+	/* We now want to adjust argument range */
+
+	/* XDR encode the ranges found */
+	xdr_start = xdr_reserve_space(xdr, 8);
+	if (!xdr_start)
+		goto out;
+	list_for_each_entry_safe(lce, save, &bl->bl_commit, bse_node) {
+		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
+		if (!p)
+			break;
+		WRITE_DEVID(&lce->bse_devid);
+		WRITE64(lce->bse_f_offset << 9);
+		WRITE64(lce->bse_length << 9);
+		WRITE64(0LL);
+		WRITE32(PNFS_BLOCK_READWRITE_DATA);
+		list_del(&lce->bse_node);
+		list_add_tail(&lce->bse_node, ranges);
+		bl->bl_count--;
+		count++;
+	}
+	xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
+	xdr_start[1] = cpu_to_be32(count);
+out:
+	spin_unlock(&bl->bl_ext_lock);
+	dprintk("%s found %i ranges\n", __func__, count);
+	return 0;
+}
+
 /* Helper function to set_to_rw that initialize a new extent */
 static void
 _prep_new_extent(struct pnfs_block_extent *new,
-- 
1.7.4.1

