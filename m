Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60646 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1FLXoL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:11 -0400
Message-Id: <0e7ea300edf2d551e0ee8682d9f7fd47c08ac630.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:08 -0400
Subject: [PATCH 09/34] pnfsblock: layout alloc and free
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Allocate the empty list-heads that will hold all the extent data
for the layout.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: move pnfs_layout_type inline in nfs_inode]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   39 +++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h |   91 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 128 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayout.h

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 2e0d41a..8218d54 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -32,7 +32,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
-#include "../pnfs.h"
+#include "blocklayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -53,15 +53,50 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+/* STUB */
+static void
+release_extents(struct pnfs_block_layout *bl,
+		struct pnfs_layout_range *range)
+{
+	return;
+}
+
+/* STUB */
+static void
+release_inval_marks(struct pnfs_inval_markings *marks)
+{
+	return;
+}
+
 static void
 bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
 {
+        struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+
+        dprintk("%s enter\n", __func__);
+        release_extents(bl, NULL);
+        release_inval_marks(&bl->bl_inval);
+        kfree(bl);
 }
 
 static struct pnfs_layout_hdr *
 bl_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 {
-	return NULL;
+        struct pnfs_block_layout        *bl;
+
+        dprintk("%s enter\n", __func__);
+        bl = kzalloc(sizeof(*bl), gfp_flags);
+        if (!bl)
+                return NULL;
+        spin_lock_init(&bl->bl_ext_lock);
+        INIT_LIST_HEAD(&bl->bl_extents[0]);
+        INIT_LIST_HEAD(&bl->bl_extents[1]);
+        INIT_LIST_HEAD(&bl->bl_commit);
+        INIT_LIST_HEAD(&bl->bl_committing);
+        bl->bl_count = 0;
+        bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> 9;
+        INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
+        return &bl->bl_layout;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
new file mode 100644
index 0000000..8ea82b8
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -0,0 +1,91 @@
+/*
+ *  linux/fs/nfs/blocklayout/blocklayout.h
+ *
+ *  Module for the NFSv4.1 pNFS block layout driver.
+ *
+ *  Copyright (c) 2006 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@citi.umich.edu>
+ *  Fred Isaman <iisaman@umich.edu>
+ *
+ * permission is granted to use, copy, create derivative works and
+ * redistribute this software and such derivative works for any purpose,
+ * so long as the name of the university of michigan is not used in
+ * any advertising or publicity pertaining to the use or distribution
+ * of this software without specific, written prior authorization.  if
+ * the above copyright notice or any other identification of the
+ * university of michigan is included in any copy of any portion of
+ * this software, then the disclaimer below must also be included.
+ *
+ * this software is provided as is, without representation from the
+ * university of michigan as to its fitness for any purpose, and without
+ * warranty by the university of michigan of any kind, either express
+ * or implied, including without limitation the implied warranties of
+ * merchantability and fitness for a particular purpose.  the regents
+ * of the university of michigan shall not be liable for any damages,
+ * including special, indirect, incidental, or consequential damages,
+ * with respect to any claim arising out or in connection with the use
+ * of the software, even if it has been or is hereafter advised of the
+ * possibility of such damages.
+ */
+#ifndef FS_NFS_NFS4BLOCKLAYOUT_H
+#define FS_NFS_NFS4BLOCKLAYOUT_H
+
+#include <linux/nfs_fs.h>
+#include "../pnfs.h"
+
+enum exstate4 {
+	PNFS_BLOCK_READWRITE_DATA	= 0,
+	PNFS_BLOCK_READ_DATA		= 1,
+	PNFS_BLOCK_INVALID_DATA		= 2, /* mapped, but data is invalid */
+	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
+};
+
+struct pnfs_inval_markings {
+	/* STUB */
+};
+
+/* sector_t fields are all in 512-byte sectors */
+struct pnfs_block_extent {
+	struct kref	be_refcnt;
+	struct list_head be_node;	/* link into lseg list */
+	struct nfs4_deviceid be_devid;  /* STUB - remevable??? */
+	struct block_device *be_mdev;
+	sector_t	be_f_offset;	/* the starting offset in the file */
+	sector_t	be_length;	/* the size of the extent */
+	sector_t	be_v_offset;	/* the starting offset in the volume */
+	enum exstate4	be_state;	/* the state of this extent */
+	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
+};
+
+static inline void
+INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
+{
+	/* STUB */
+}
+
+enum extentclass4 {
+        RW_EXTENT       = 0, /* READWRTE and INVAL */
+        RO_EXTENT       = 1, /* READ and NONE */
+        EXTENT_LISTS    = 2,
+};
+
+struct pnfs_block_layout {
+	struct pnfs_layout_hdr bl_layout;
+	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
+	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
+	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
+	struct list_head	bl_commit;	/* Needs layout commit */
+	struct list_head	bl_committing;	/* Layout committing */
+	unsigned int		bl_count;	/* entries in bl_commit */
+	sector_t		bl_blocksize;  /* Server blocksize in sectors */
+};
+
+static inline struct pnfs_block_layout *
+BLK_LO2EXT(struct pnfs_layout_hdr *lo)
+{
+        return container_of(lo, struct pnfs_block_layout, bl_layout);
+}
+
+#endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
-- 
1.7.4.1

