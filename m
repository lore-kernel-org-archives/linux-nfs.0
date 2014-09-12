Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:53704 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaILRjS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Sep 2014 13:39:18 -0400
Received: by mail-ig0-f179.google.com with SMTP id r10so926003igi.12
        for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2014 10:39:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] pNFS/blocklayout: Remove a couple of unused variables
Date: Fri, 12 Sep 2014 13:39:16 -0400
Message-Id: <1410543556-83988-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 +--
 fs/nfs/blocklayout/extent_tree.c | 2 --
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index c41a718854e3..5228f201d3d5 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -694,7 +694,6 @@ bl_return_range(struct pnfs_layout_hdr *lo,
 {
 	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 	sector_t offset = range->offset >> SECTOR_SHIFT, end;
-	int err;
 
 	if (range->offset % 8) {
 		dprintk("%s: offset %lld not block size aligned\n",
@@ -714,7 +713,7 @@ bl_return_range(struct pnfs_layout_hdr *lo,
 		end = round_down(NFS4_MAX_UINT64, PAGE_SIZE);
 	}
 
-	err = ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
+	ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
 }
 
 static int
diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 1b6009ee75ce..93193616205a 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -165,7 +165,6 @@ __ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
 {
 	struct pnfs_block_extent *be;
 	sector_t len1 = 0, len2 = 0;
-	sector_t orig_f_offset;
 	sector_t orig_v_offset;
 	sector_t orig_len;
 
@@ -175,7 +174,6 @@ __ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
 	if (be->be_f_offset >= end)
 		return 0;
 
-	orig_f_offset = be->be_f_offset;
 	orig_v_offset = be->be_v_offset;
 	orig_len = be->be_length;
 
-- 
1.9.3

