Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56935 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab1KIPSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 10:18:01 -0500
Received: by mail-gx0-f174.google.com with SMTP id b2so1813275ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 07:18:01 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH 7/8] pnfsblock: add im_extents to pnfs_inval_markings
Date: Wed,  9 Nov 2011 07:16:05 -0800
Message-Id: <1320851766-1834-8-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It stores a list of short extents for INVAL->RW conversion.
Also add two functions to manipulate them, in preparation to
move malloc logic out of end_io.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |    6 ++++++
 fs/nfs/blocklayout/blocklayout.h |    5 +++++
 fs/nfs/blocklayout/extents.c     |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 815c0c3..cb4ff0f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -706,11 +706,17 @@ static void
 release_inval_marks(struct pnfs_inval_markings *marks)
 {
 	struct pnfs_inval_tracking *pos, *temp;
+	struct pnfs_block_short_extent *se, *stemp;
 
 	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
 		list_del(&pos->it_link);
 		kfree(pos);
 	}
+
+	list_for_each_entry_safe(se, stemp, &marks->im_extents, bse_node) {
+		list_del(&se->bse_node);
+		kfree(se);
+	}
 	return;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 60728ac..df0e0fb 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -70,6 +70,7 @@ struct pnfs_inval_markings {
 	spinlock_t	im_lock;
 	struct my_tree	im_tree;	/* Sectors that need LAYOUTCOMMIT */
 	sector_t	im_block_size;	/* Server blocksize in sectors */
+	struct list_head im_extents;	/* List of short extents for INVAL->RW conversion */
 };
 
 struct pnfs_inval_tracking {
@@ -105,6 +106,7 @@ BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
 	spin_lock_init(&marks->im_lock);
 	INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
+	INIT_LIST_HEAD(&marks->im_extents);
 	marks->im_block_size = blocksize;
 	marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
 					   blocksize);
@@ -200,5 +202,8 @@ int bl_add_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 int bl_mark_for_commit(struct pnfs_block_extent *be,
 			sector_t offset, sector_t length);
+int bl_push_one_short_extent(struct pnfs_inval_markings *marks);
+struct pnfs_block_short_extent*
+bl_pop_short_extent(struct pnfs_inval_markings *marks, int num_to_pop);
 
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 952ea8a..72c7fa1 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -863,3 +863,40 @@ clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		}
 	}
 }
+
+int
+bl_push_one_short_extent(struct pnfs_inval_markings *marks) {
+	struct pnfs_block_short_extent *new;
+
+	new = kmalloc(sizeof(*new), GFP_NOFS);
+	if (unlikely(!new))
+		return -ENOMEM;
+
+	spin_lock(&marks->im_lock);
+	list_add(&new->bse_node, &marks->im_extents);
+	spin_unlock(&marks->im_lock);
+
+	return 0;
+}
+
+struct pnfs_block_short_extent*
+bl_pop_short_extent(struct pnfs_inval_markings *marks, int num_to_pop) {
+	struct pnfs_block_short_extent *rv = NULL;
+
+	if (unlikely(num_to_pop <= 0))
+		return rv;
+
+	spin_lock(&marks->im_lock);
+	while (!list_empty(&marks->im_extents) && num_to_pop-- > 0) {
+		rv = list_entry((&marks->im_extents)->next,
+				struct pnfs_block_short_extent, bse_node);
+		list_del_init(&rv->bse_node);
+		if (num_to_pop)
+			kfree(rv);
+	}
+	spin_unlock(&marks->im_lock);
+
+	BUG_ON(num_to_pop > 0);
+
+	return rv;
+}
-- 
1.7.1.262.g5ef3d

