Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53275 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR2F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:05 -0400
Date: Tue, 7 Jun 2011 13:28:02 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 19/88] pnfsblock: layout alloc and free
Message-ID: <c7b028d7fd040f0e737125ec31418d09f223fec5.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Allocate the empty list-heads that will hold all the extent data
for the layout.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: move pnfs_layout_type inline in nfs_inode]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   33 ++++++++++++++++++++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h |   25 +++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ebaa48a..677836c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -83,18 +83,49 @@ bl_write_pagelist(struct pnfs_layout_type *lo,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+/* STUB */
+static void
+release_extents(struct pnfs_block_layout *bl,
+		struct nfs4_pnfs_layout_segment *range)
+{
+	return;
+}
+
+/* STUB */
+static void
+release_inval_marks(void)
+{
+	return;
+}
+
+/* Note we are relying on caller locking to prevent nasty races. */
 static void
 bl_free_layout(void *p)
 {
+	struct pnfs_block_layout	*bl = p;
+
 	dprintk("%s enter\n", __func__);
+	release_extents(bl, NULL);
+	release_inval_marks();
+	kfree(bl);
 	return;
 }
 
 static void *
 bl_alloc_layout(struct pnfs_mount_type *mtype, struct inode *inode)
 {
+	struct pnfs_block_layout	*bl;
+
 	dprintk("%s enter\n", __func__);
-	return NULL;
+	bl = kzalloc(sizeof(*bl), GFP_KERNEL);
+	if (!bl)
+		return NULL;
+	spin_lock_init(&bl->bl_ext_lock);
+	INIT_LIST_HEAD(&bl->bl_extents[0]);
+	INIT_LIST_HEAD(&bl->bl_extents[1]);
+	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
+	INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
+	return bl;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index d695f8e..dd25f1a 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -99,6 +99,31 @@ struct pnfs_blk_sig {
 	struct pnfs_blk_sig_comp	si_comps[PNFS_BLOCK_MAX_SIG_COMP];
 };
 
+struct pnfs_inval_markings {
+	/* STUB */
+};
+
+static inline void
+INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
+{
+	/* STUB */
+}
+
+enum extentclass4 {
+	RW_EXTENT	= 0, /* READWRTE and INVAL */
+	RO_EXTENT	= 1, /* READ and NONE */
+	EXTENT_LISTS	= 2,
+};
+
+struct pnfs_block_layout {
+	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
+	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
+	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
+	sector_t		bl_blocksize;  /* Server blocksize in sectors */
+};
+
+#define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
+
 uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 
 #define BLK_READBUF(p, e, nbytes)  do { \
-- 
1.7.4.1

