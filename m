Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48155 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1FNCc6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:58 -0400
Message-Id: <b8f14a840bc2da395edbb90c257c580ab5d82b35.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 22/33] pnfsblock: merge rw extents
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:56 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/extents.c |   47 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 3d36f66..43a3601 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -501,3 +501,50 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	print_bl_extent(ret);
 	return ret;
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
+	memcpy(&new->be_devid, &orig->be_devid, sizeof(struct nfs4_deviceid));
+	new->be_mdev = orig->be_mdev;
+	new->be_f_offset = offset;
+	new->be_length = length;
+	new->be_v_offset = orig->be_v_offset - orig->be_f_offset + offset;
+	new->be_state = state;
+	new->be_inval = orig->be_inval;
+}
+
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
-- 
1.7.4.1

