Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53770 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108Ab1G2PzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:55:23 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v5 21/27] pnfsblock: merge rw extents
Date: Fri, 29 Jul 2011 11:54:46 -0400
Message-Id: <1311954892-22038-22-git-send-email-rees@umich.edu>
In-Reply-To: <1311954892-22038-1-git-send-email-rees@umich.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/extents.c |   47 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 3528d36..7beae7c 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -501,3 +501,50 @@ bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
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
+	bl_put_extent(prev);
+	list_del(&be->be_node);
+	bl_put_extent(be);
+	return storage;
+
+ no_merge:
+	kfree(storage);
+	return be;
+}
-- 
1.7.4.1

