Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423084AbcFMRmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 13:42:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH V2] pnfs/blocklayout: put deviceid node after releasing bl_ext_lock
Date: Mon, 13 Jun 2016 13:42:08 -0400
Message-Id: <21b196752b7a1f492e0ec680eba86286aa1e98d6.1465839321.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The last put of deviceid nodes for SCSI layouts may sleep, so we shouldn't
hold any spinlocks.  Make sure we put them outside the bl_ext_lock.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/extent_tree.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 720b3ff55fa9..7bf575b404ec 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -121,6 +121,16 @@ ext_try_to_merge_right(struct rb_root *root, struct pnfs_block_extent *be)
 	return be;
 }
 
+static void ext_put_deviceids(struct list_head *head)
+{
+	struct pnfs_block_extent *be, *tmp;
+
+	list_for_each_entry_safe(be, tmp, head, be_list) {
+		nfs4_put_deviceid_node(be->be_device);
+		kfree(be);
+	}
+}
+
 static void
 __ext_tree_insert(struct rb_root *root,
 		struct pnfs_block_extent *new, bool merge_ok)
@@ -163,7 +173,8 @@ free_new:
 }
 
 static int
-__ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
+__ext_tree_remove(struct rb_root *root,
+		sector_t start, sector_t end, struct list_head *to_free)
 {
 	struct pnfs_block_extent *be;
 	sector_t len1 = 0, len2 = 0;
@@ -223,8 +234,7 @@ __ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
 			struct pnfs_block_extent *next = ext_tree_next(be);
 
 			rb_erase(&be->be_node, root);
-			nfs4_put_deviceid_node(be->be_device);
-			kfree(be);
+			list_add_tail(&be->be_list, to_free);
 			be = next;
 		}
 
@@ -350,16 +360,18 @@ int ext_tree_remove(struct pnfs_block_layout *bl, bool rw,
 		sector_t start, sector_t end)
 {
 	int err, err2;
+	LIST_HEAD(to_free);
 
 	spin_lock(&bl->bl_ext_lock);
-	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
+	err = __ext_tree_remove(&bl->bl_ext_ro, start, end, &to_free);
 	if (rw) {
-		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end);
+		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end, &to_free);
 		if (!err)
 			err = err2;
 	}
 	spin_unlock(&bl->bl_ext_lock);
 
+	ext_put_deviceids(&to_free);
 	return err;
 }
 
@@ -396,12 +408,13 @@ ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
 	sector_t end = start + len;
 	struct pnfs_block_extent *be;
 	int err = 0;
+	LIST_HEAD(to_free);
 
 	spin_lock(&bl->bl_ext_lock);
 	/*
 	 * First remove all COW extents or holes from written to range.
 	 */
-	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
+	err = __ext_tree_remove(&bl->bl_ext_ro, start, end, &to_free);
 	if (err)
 		goto out;
 
@@ -459,6 +472,8 @@ ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
 	}
 out:
 	spin_unlock(&bl->bl_ext_lock);
+
+	ext_put_deviceids(&to_free);
 	return err;
 }
 
-- 
2.5.5

