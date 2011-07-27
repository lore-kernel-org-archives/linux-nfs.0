Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:34715 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab1G0SlV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:41:21 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 19/25] pnfsblock: cleanup_layoutcommit
Date: Wed, 27 Jul 2011 14:40:42 -0400
Message-Id: <1311792048-12551-20-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
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

[SQUASHME: pnfs: blocklayout: port block layout code]
Signed-off-by: Peng Tao <peng_tao@emc.com>
[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsblock: fix bug setting up layoutcommit.]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
[pnfsblock: cleanup_layoutcommit wants a status parameter]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +
 fs/nfs/blocklayout/blocklayout.h |    3 +
 fs/nfs/blocklayout/extents.c     |  210 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 215 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 0c05f8a..c63296d 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -163,6 +163,8 @@ static void
 bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
 			struct nfs4_layoutcommit_data *lcdata)
 {
+	dprintk("%s enter\n", __func__);
+	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args, lcdata->res.status);
 }
 
 static void free_blk_mountid(struct block_mount_id *mid)
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index de908da..79f564d 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -197,6 +197,9 @@ int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
 				   const struct nfs4_layoutcommit_args *arg);
+void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+				   const struct nfs4_layoutcommit_args *arg,
+				   int status);
 int bl_add_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index b46c8be..a9224a1 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -329,6 +329,73 @@ void print_clist(struct list_head *list, unsigned int count)
 	}
 }
 
+/* Note: In theory, we should do more checking that devid's match between
+ * old and new, but if they don't, the lists are too corrupt to salvage anyway.
+ */
+/* Note this is very similar to bl_add_merge_extent */
+static void add_to_commitlist(struct pnfs_block_layout *bl,
+			      struct pnfs_block_short_extent *new)
+{
+	struct list_head *clist = &bl->bl_commit;
+	struct pnfs_block_short_extent *old, *save;
+	sector_t end = new->bse_f_offset + new->bse_length;
+
+	dprintk("%s enter\n", __func__);
+	print_short_extent(new);
+	print_clist(clist, bl->bl_count);
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
+	dprintk("%s: after merging\n", __func__);
+	print_clist(clist, bl->bl_count);
+}
+
 static void print_bl_extent(struct pnfs_block_extent *be)
 {
 	dprintk("PRINT EXTENT extent %p\n", be);
@@ -547,6 +614,34 @@ bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	return ret;
 }
 
+/* Similar to bl_find_get_extent, but called with lock held, and ignores cow */
+static struct pnfs_block_extent *
+bl_find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
+{
+	struct pnfs_block_extent *be, *ret = NULL;
+	int i;
+
+	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	for (i = 0; i < EXTENT_LISTS; i++) {
+		if (ret)
+			break;
+		list_for_each_entry_reverse(be, &bl->bl_extents[i], be_node) {
+			if (isect >= be->be_f_offset + be->be_length)
+				break;
+			if (isect >= be->be_f_offset) {
+				/* We have found an extent */
+				dprintk("%s Get %p (%i)\n", __func__, be,
+					atomic_read(&be->be_refcnt.refcount));
+				kref_get(&be->be_refcnt);
+				ret = be;
+				break;
+			}
+		}
+	}
+	print_bl_extent(ret);
+	return ret;
+}
+
 int
 encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 			       struct xdr_stream *xdr,
@@ -636,3 +731,118 @@ _front_merge(struct pnfs_block_extent *be, struct list_head *head,
 	kfree(storage);
 	return be;
 }
+
+static u64
+set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
+{
+	u64 rv = offset + length;
+	struct pnfs_block_extent *be, *e1, *e2, *e3, *new, *old;
+	struct pnfs_block_extent *children[3];
+	struct pnfs_block_extent *merge1 = NULL, *merge2 = NULL;
+	int i = 0, j;
+
+	dprintk("%s(%llu, %llu)\n", __func__, offset, length);
+	/* Create storage for up to three new extents e1, e2, e3 */
+	e1 = kmalloc(sizeof(*e1), GFP_ATOMIC);
+	e2 = kmalloc(sizeof(*e2), GFP_ATOMIC);
+	e3 = kmalloc(sizeof(*e3), GFP_ATOMIC);
+	/* BUG - we are ignoring any failure */
+	if (!e1 || !e2 || !e3)
+		goto out_nosplit;
+
+	spin_lock(&bl->bl_ext_lock);
+	be = bl_find_get_extent_locked(bl, offset);
+	rv = be->be_f_offset + be->be_length;
+	if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
+		spin_unlock(&bl->bl_ext_lock);
+		goto out_nosplit;
+	}
+	/* Add e* to children, bumping e*'s krefs */
+	if (be->be_f_offset != offset) {
+		_prep_new_extent(e1, be, be->be_f_offset,
+				 offset - be->be_f_offset,
+				 PNFS_BLOCK_INVALID_DATA);
+		children[i++] = e1;
+		print_bl_extent(e1);
+	} else
+		merge1 = e1;
+	_prep_new_extent(e2, be, offset,
+			 min(length, be->be_f_offset + be->be_length - offset),
+			 PNFS_BLOCK_READWRITE_DATA);
+	children[i++] = e2;
+	print_bl_extent(e2);
+	if (offset + length < be->be_f_offset + be->be_length) {
+		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
+				 be->be_f_offset + be->be_length -
+				 offset - length,
+				 PNFS_BLOCK_INVALID_DATA);
+		children[i++] = e3;
+		print_bl_extent(e3);
+	} else
+		merge2 = e3;
+
+	/* Remove be from list, and insert the e* */
+	/* We don't get refs on e*, since this list is the base reference
+	 * set when init'ed.
+	 */
+	if (i < 3)
+		children[i] = NULL;
+	new = children[0];
+	list_replace(&be->be_node, &new->be_node);
+	bl_put_extent(be);
+	new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge1);
+	for (j = 1; j < i; j++) {
+		old = new;
+		new = children[j];
+		list_add(&new->be_node, &old->be_node);
+	}
+	if (merge2) {
+		/* This is a HACK, should just create a _back_merge function */
+		new = list_entry(new->be_node.next,
+				 struct pnfs_block_extent, be_node);
+		new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge2);
+	}
+	spin_unlock(&bl->bl_ext_lock);
+
+	/* Since we removed the base reference above, be is now scheduled for
+	 * destruction.
+	 */
+	bl_put_extent(be);
+	dprintk("%s returns %llu after split\n", __func__, rv);
+	return rv;
+
+ out_nosplit:
+	kfree(e1);
+	kfree(e2);
+	kfree(e3);
+	dprintk("%s returns %llu without splitting\n", __func__, rv);
+	return rv;
+}
+
+void
+clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+			      const struct nfs4_layoutcommit_args *arg,
+			      int status)
+{
+	struct pnfs_block_short_extent *lce, *save;
+
+	dprintk("%s status %d\n", __func__, status);
+	list_for_each_entry_safe(lce, save, &bl->bl_committing, bse_node) {
+		if (likely(!status)) {
+			u64 offset = lce->bse_f_offset;
+			u64 end = offset + lce->bse_length;
+
+			do {
+				offset = set_to_rw(bl, offset, end - offset);
+			} while (offset < end);
+			list_del(&lce->bse_node);
+
+			kfree(lce);
+		} else {
+			list_del(&lce->bse_node);
+			spin_lock(&bl->bl_ext_lock);
+			add_to_commitlist(bl, lce);
+			spin_unlock(&bl->bl_ext_lock);
+		}
+	}
+}
-- 
1.7.4.1

