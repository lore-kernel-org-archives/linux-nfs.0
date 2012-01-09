Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:37807 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932153Ab2AIQDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 11:03:36 -0500
Received: by obcwo16 with SMTP id wo16so4262234obc.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 08:03:35 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 1/9] pnfsblock: cleanup bl_mark_sectors_init
Date: Tue, 10 Jan 2012 00:02:11 +0800
Message-Id: <1326124939-2152-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
References: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It does not need to manipulate on partial initialized blocks.
Writeback code takes care of it.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |    6 +--
 fs/nfs/blocklayout/blocklayout.h |    3 +-
 fs/nfs/blocklayout/extents.c     |   76 ++-----------------------------------
 3 files changed, 8 insertions(+), 77 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 281ae95..4ced0b0 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -571,8 +571,7 @@ fill_invalid_ext:
 			unlock_page(page);
 
 			ret = bl_mark_sectors_init(be->be_inval, isect,
-						       PAGE_CACHE_SECTORS,
-						       NULL);
+						       PAGE_CACHE_SECTORS);
 			if (unlikely(ret)) {
 				dprintk("%s bl_mark_sectors_init fail %d\n",
 					__func__, ret);
@@ -621,8 +620,7 @@ next_page:
 		}
 		if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
 			ret = bl_mark_sectors_init(be->be_inval, isect,
-						       PAGE_CACHE_SECTORS,
-						       NULL);
+						       PAGE_CACHE_SECTORS);
 			if (unlikely(ret)) {
 				dprintk("%s bl_mark_sectors_init fail %d\n",
 					__func__, ret);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 42acf7e..60728ac 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -186,8 +186,7 @@ struct pnfs_block_extent *
 bl_find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 		struct pnfs_block_extent **cow_read);
 int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
-			     sector_t offset, sector_t length,
-			     sector_t **pages);
+			     sector_t offset, sector_t length);
 void bl_put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *bl_alloc_extent(void);
 int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect);
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 19fa7b0..0fc1321 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -179,33 +179,6 @@ static int _preload_range(struct my_tree *tree, u64 offset, u64 length)
 	return status;
 }
 
-static void set_needs_init(sector_t *array, sector_t offset)
-{
-	sector_t *p = array;
-
-	dprintk("%s enter\n", __func__);
-	if (!p)
-		return;
-	while (*p < offset)
-		p++;
-	if (*p == offset)
-		return;
-	else if (*p == ~0) {
-		*p++ = offset;
-		*p = ~0;
-		return;
-	} else {
-		sector_t *save = p;
-		dprintk("%s Adding %llu\n", __func__, (u64)offset);
-		while (*p != ~0)
-			p++;
-		p++;
-		memmove(save + 1, save, (char *)p - (char *)save);
-		*save = offset;
-		return;
-	}
-}
-
 /* We are relying on page lock to serialize this */
 int bl_is_sector_init(struct pnfs_inval_markings *marks, sector_t isect)
 {
@@ -261,28 +234,15 @@ static int is_range_written(struct pnfs_inval_markings *marks,
 
 /* Marks sectors in [offest, offset_length) as having been initialized.
  * All lengths are step-aligned, where step is min(pagesize, blocksize).
- * Notes where partial block is initialized, and helps prepare it for
- * complete initialization later.
+ * Currently assumes offset is page-aligned
  */
-/* Currently assumes offset is page-aligned */
 int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
-			     sector_t offset, sector_t length,
-			     sector_t **pages)
+			     sector_t offset, sector_t length)
 {
-	sector_t s, start, end;
-	sector_t *array = NULL; /* Pages to mark */
+	sector_t start, end;
 
 	dprintk("%s(offset=%llu,len=%llu) enter\n",
 		__func__, (u64)offset, (u64)length);
-	s = max((sector_t) 3,
-		2 * (marks->im_block_size / (PAGE_CACHE_SECTORS)));
-	dprintk("%s set max=%llu\n", __func__, (u64)s);
-	if (pages) {
-		array = kmalloc(s * sizeof(sector_t), GFP_NOFS);
-		if (!array)
-			goto outerr;
-		array[0] = ~0;
-	}
 
 	start = normalize(offset, marks->im_block_size);
 	end = normalize_up(offset + length, marks->im_block_size);
@@ -290,41 +250,15 @@ int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
 		goto outerr;
 
 	spin_lock(&marks->im_lock);
-
-	for (s = normalize_up(start, PAGE_CACHE_SECTORS);
-	     s < offset; s += PAGE_CACHE_SECTORS) {
-		dprintk("%s pre-area pages\n", __func__);
-		/* Portion of used block is not initialized */
-		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
-			set_needs_init(array, s);
-	}
 	if (_set_range(&marks->im_tree, EXTENT_INITIALIZED, offset, length))
 		goto out_unlock;
-	for (s = normalize_up(offset + length, PAGE_CACHE_SECTORS);
-	     s < end; s += PAGE_CACHE_SECTORS) {
-		dprintk("%s post-area pages\n", __func__);
-		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
-			set_needs_init(array, s);
-	}
-
 	spin_unlock(&marks->im_lock);
 
-	if (pages) {
-		if (array[0] == ~0) {
-			kfree(array);
-			*pages = NULL;
-		} else
-			*pages = array;
-	}
 	return 0;
 
- out_unlock:
+out_unlock:
 	spin_unlock(&marks->im_lock);
- outerr:
-	if (pages) {
-		kfree(array);
-		*pages = NULL;
-	}
+outerr:
 	return -ENOMEM;
 }
 
-- 
1.7.1.262.g5ef3d

