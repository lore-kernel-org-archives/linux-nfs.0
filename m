Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50747 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1FGRad (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:33 -0400
Date: Tue, 7 Jun 2011 13:30:31 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 38/88] pnfsblock: merge rw extents
Message-ID: <db938c7aa5574bb8fb106b94ce6f7ab03191d0f6.1307464382.git.rees@umich.edu>
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
 fs/nfs/blocklayout/extents.c |   48 ++++++++++++++++++++++++++++++++++++++---
 1 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 1719a67..a05ee2a 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -773,12 +773,43 @@ _prep_new_extent(struct pnfs_block_extent *new,
 	new->be_inval = orig->be_inval;
 }
 
+/* Tries to merge be with extent in front of it in list.
+ * Frees storage if not used.
+ */
+static struct pnfs_block_extent *
+_front_merge(struct pnfs_block_extent *be, struct list_head *head,
+	     struct pnfs_block_extent *storage)
+{
+	struct pnfs_block_extent *prev;
+
+	if (!storage)
+		goto no_merge;
+	if (&be->be_node == head || be->be_node.prev == head)
+		goto no_merge;
+	prev = list_entry(be->be_node.prev, struct pnfs_block_extent, be_node);
+	if ((prev->be_f_offset + prev->be_length != be->be_f_offset) ||
+	    !extents_consistent(prev, be))
+		goto no_merge;
+	_prep_new_extent(storage, prev, prev->be_f_offset,
+			 prev->be_length + be->be_length, prev->be_state);
+	list_replace(&prev->be_node, &storage->be_node);
+	put_extent(prev);
+	list_del(&be->be_node);
+	put_extent(be);
+	return storage;
+
+ no_merge:
+	kfree(storage);
+	return be;
+}
+
 static u64
 set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 {
-	u64 rv = 0;
+	u64 rv = offset + length;
 	struct pnfs_block_extent *be, *e1, *e2, *e3, *new, *old;
 	struct pnfs_block_extent *children[3];
+	struct pnfs_block_extent *merge1 = NULL, *merge2 = NULL;
 	int i = 0, j;
 
 	dprintk("%s(%llu, %llu)\n", __func__, offset, length);
@@ -792,7 +823,6 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 
 	spin_lock(&bl->bl_ext_lock);
 	be = find_get_extent_locked(bl, offset);
-	print_bl_extent(be);
 	rv = be->be_f_offset + be->be_length;
 	if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
 		spin_unlock(&bl->bl_ext_lock);
@@ -805,13 +835,15 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 				 PNFS_BLOCK_INVALID_DATA);
 		children[i++] = e1;
 		kref_get(&e1->be_refcnt);
+		print_bl_extent(e1);
 	} else
-		kfree(e1);
+		merge1 = e1;
 	_prep_new_extent(e2, be, offset,
 			 min(length, be->be_f_offset + be->be_length - offset),
 			 PNFS_BLOCK_READWRITE_DATA);
 	children[i++] = e2;
 	kref_get(&e2->be_refcnt);
+	print_bl_extent(e2);
 	if (offset + length < be->be_f_offset + be->be_length) {
 		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
 				 be->be_f_offset + be->be_length -
@@ -819,8 +851,9 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 				 PNFS_BLOCK_INVALID_DATA);
 		children[i++] = e3;
 		kref_get(&e3->be_refcnt);
+		print_bl_extent(e3);
 	} else
-		kfree(e3);
+		merge2 = e3;
 
 	/* Remove be from list, and insert the e* */
 	/* We don't get refs on e*, since this list is the base reference
@@ -831,11 +864,18 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 	new = children[0];
 	list_replace(&be->be_node, &new->be_node);
 	put_extent(be);
+	new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge1);
 	for (j = 1; j < i; j++) {
 		old = new;
 		new = children[j];
 		list_add(&new->be_node, &old->be_node);
 	}
+	if (merge2) {
+		/* This is a HACK, should just create a _back_merge function */
+		new = list_entry(new->be_node.next,
+				 struct pnfs_block_extent, be_node);
+		new = _front_merge(new, &bl->bl_extents[RW_EXTENT], merge2);
+	}
 	spin_unlock(&bl->bl_ext_lock);
 
 	/* Since we removed the base reference above, be is now scheduled for
-- 
1.7.4.1

