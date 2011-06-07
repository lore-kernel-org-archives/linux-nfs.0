Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50721 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1FGRa2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:28 -0400
Date: Tue, 7 Jun 2011 13:30:24 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 37/88] pnfsblock: cleanup_layoutcommit
Message-ID: <b56abc270a4cfdb6f59a44d4806d65bd32ecb625.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
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

[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsblock: fix bug setting up layoutcommit.]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
[pnfsblock: cleanup_layoutcommit wants a status parameter]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +
 fs/nfs/blocklayout/blocklayout.h |    3 +
 fs/nfs/blocklayout/extents.c     |  153 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 157 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6132e8e..db008e6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -661,6 +661,8 @@ bl_cleanup_layoutcommit(struct pnfs_layout_type *lo,
 			struct pnfs_layoutcommit_arg *arg, int status)
 {
 	dprintk("%s enter\n", __func__);
+	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), arg, status);
+	kfree(arg->layoutdriver_data);
 }
 
 static void free_blk_mountid(struct block_mount_id *mid)
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 1c110e1..ca36e61 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -266,6 +266,9 @@ int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
 				   const struct pnfs_layoutcommit_arg *arg);
+void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+				   const struct pnfs_layoutcommit_arg *arg,
+				   int status);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 int mark_for_commit(struct pnfs_block_extent *be,
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index b2f8643..1719a67 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -144,7 +144,6 @@ static int _set_range(struct my_tree_t *tree, int32_t tag, u64 s, u64 length)
 	return 0;
 }
 
-
 /* Ensure that future operations on given range of tree will not malloc */
 static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
 {
@@ -681,6 +680,34 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	return ret;
 }
 
+/* Similar to find_get_extent, but called with lock held, and ignores cow */
+static struct pnfs_block_extent *
+find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
+{
+	struct pnfs_block_extent *be, *ret = NULL;
+	int i;
+
+	dprintk("%s enter with isect %llu\n", __func__, (u64)isect);
+	for (i = 0; i < EXTENT_LISTS; i++) {
+		if (ret)
+			break;
+		list_for_each_entry(be, &bl->bl_extents[i], be_node) {
+			if (isect < be->be_f_offset)
+				break;
+			if (isect < be->be_f_offset + be->be_length) {
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
@@ -728,3 +755,127 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	*xdr_start = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
 	return 0;
 }
+
+/* Helper function to set_to_rw that initialize a new extent */
+static void
+_prep_new_extent(struct pnfs_block_extent *new,
+		 struct pnfs_block_extent *orig,
+		 sector_t offset, sector_t length, int state)
+{
+	kref_init(&new->be_refcnt);
+	/* don't need to INIT_LIST_HEAD(&new->be_node) */
+	memcpy(&new->be_devid, &orig->be_devid, sizeof(struct pnfs_deviceid));
+	new->be_mdev = orig->be_mdev;
+	new->be_f_offset = offset;
+	new->be_length = length;
+	new->be_v_offset = orig->be_v_offset - orig->be_f_offset + offset;
+	new->be_state = state;
+	new->be_inval = orig->be_inval;
+}
+
+static u64
+set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
+{
+	u64 rv = 0;
+	struct pnfs_block_extent *be, *e1, *e2, *e3, *new, *old;
+	struct pnfs_block_extent *children[3];
+	int i = 0, j;
+
+	dprintk("%s(%llu, %llu)\n", __func__, offset, length);
+	/* Create storage for up to three new extents e1, e2, e3 */
+	e1 = kmalloc(sizeof(*e1), GFP_KERNEL);
+	e2 = kmalloc(sizeof(*e2), GFP_KERNEL);
+	e3 = kmalloc(sizeof(*e3), GFP_KERNEL);
+	/* BUG - we are ignoring any failure */
+	if (!e1 || !e2 || !e3)
+		goto out_nosplit;
+
+	spin_lock(&bl->bl_ext_lock);
+	be = find_get_extent_locked(bl, offset);
+	print_bl_extent(be);
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
+		kref_get(&e1->be_refcnt);
+	} else
+		kfree(e1);
+	_prep_new_extent(e2, be, offset,
+			 min(length, be->be_f_offset + be->be_length - offset),
+			 PNFS_BLOCK_READWRITE_DATA);
+	children[i++] = e2;
+	kref_get(&e2->be_refcnt);
+	if (offset + length < be->be_f_offset + be->be_length) {
+		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
+				 be->be_f_offset + be->be_length -
+				 offset - length,
+				 PNFS_BLOCK_INVALID_DATA);
+		children[i++] = e3;
+		kref_get(&e3->be_refcnt);
+	} else
+		kfree(e3);
+
+	/* Remove be from list, and insert the e* */
+	/* We don't get refs on e*, since this list is the base reference
+	 * set when init'ed.
+	 */
+	if (i < 3)
+		children[i] = NULL;
+	new = children[0];
+	list_replace(&be->be_node, &new->be_node);
+	put_extent(be);
+	for (j = 1; j < i; j++) {
+		old = new;
+		new = children[j];
+		list_add(&new->be_node, &old->be_node);
+	}
+	spin_unlock(&bl->bl_ext_lock);
+
+	/* Since we removed the base reference above, be is now scheduled for
+	 * destruction.
+	 */
+	put_extent(be);
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
+			      const struct pnfs_layoutcommit_arg *arg,
+			      int status)
+{
+	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
+	struct pnfs_block_short_extent *lce, *save;
+
+	dprintk("%s status %d\n", __func__, status);
+	list_for_each_entry_safe_reverse(lce, save, &bld->ranges, bse_node) {
+		if (likely(!status)) {
+			u64 offset = lce->bse_f_offset;
+			u64 end = offset + lce->bse_length;
+
+			do {
+				offset = set_to_rw(bl, offset, end - offset);
+			} while (offset < end);
+
+			kfree(lce);
+		} else {
+			spin_lock(&bl->bl_ext_lock);
+			add_to_commitlist(bl, lce);
+			spin_unlock(&bl->bl_ext_lock);
+		}
+	}
+}
-- 
1.7.4.1

