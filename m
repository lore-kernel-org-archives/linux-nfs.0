From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/1] SQUASHME: pnfs-block: use new alloc/free_layout API
Date: Mon, 12 Jul 2010 21:42:55 +0300
Message-ID: <1278960175-32282-1-git-send-email-bhalevy@panasas.com>
References: <4C3B61FC.90306@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36705 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753891Ab0GLSnA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:43:00 -0400
In-Reply-To: <4C3B61FC.90306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c    |    9 ++++-----
 fs/nfs/blocklayout/blocklayout.h    |   15 +++++++++++++--
 fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 92f0b4b..63d3b5a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -552,18 +552,17 @@ release_inval_marks(struct pnfs_inval_markings *marks)
 
 /* Note we are relying on caller locking to prevent nasty races. */
 static void
-bl_free_layout(void *p)
+bl_free_layout(struct pnfs_layout_type *lo)
 {
-	struct pnfs_block_layout	*bl = p;
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 
 	dprintk("%s enter\n", __func__);
 	release_extents(bl, NULL);
 	release_inval_marks(&bl->bl_inval);
 	kfree(bl);
-	return;
 }
 
-static void *
+static struct pnfs_layout_type *
 bl_alloc_layout(struct inode *inode)
 {
 	struct pnfs_block_layout	*bl;
@@ -579,7 +578,7 @@ bl_alloc_layout(struct inode *inode)
 	bl->bl_count = 0;
 	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
 	INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
-	return bl;
+	return &bl->bl_layout;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 0efed8d..d316b7f 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -177,6 +177,7 @@ static inline int choose_list(enum exstate4 state)
 }
 
 struct pnfs_block_layout {
+	struct pnfs_layout_type bl_layout;
 	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
 	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
@@ -193,8 +194,18 @@ struct bl_layoutupdate_data {
 };
 
 #define BLK_ID(lo) ((struct block_mount_id *)(PNFS_NFS_SERVER(lo)->pnfs_ld_data))
-#define BLK_LSEG2EXT(lseg) ((struct pnfs_block_layout *)lseg->layout->ld_data)
-#define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
+
+static inline struct pnfs_block_layout *
+BLK_LO2EXT(struct pnfs_layout_type *lo)
+{
+	return container_of(lo, struct pnfs_block_layout, bl_layout);
+}
+
+static inline struct pnfs_block_layout *
+BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
+{
+	return BLK_LO2EXT(lseg->layout);
+}
 
 uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index a866f5c..7285d5e 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -620,7 +620,7 @@ int
 nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 			   struct nfs4_pnfs_layoutget_res *lgr)
 {
-	struct pnfs_block_layout *bl = PNFS_LD_DATA(lo);
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 	uint32_t *p = (uint32_t *)lgr->layout.buf;
 	uint32_t *end = (uint32_t *)((char *)lgr->layout.buf + lgr->layout.len);
 	int i, status = -EIO;
-- 
1.7.1.1

