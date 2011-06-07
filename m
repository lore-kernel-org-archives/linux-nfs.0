Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51751 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab1FGRdU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:20 -0400
Date: Tue, 7 Jun 2011 13:33:17 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 61/88] SQUASHME: pnfs-block: use new alloc/free_layout API
Message-ID: <761739026ec4e77bd7b7db1d23ddbd66a813cd4b.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.4.1

