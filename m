Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53328 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR2L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:11 -0400
Date: Tue, 7 Jun 2011 13:28:08 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 20/88] pnfsblock: basic extent code
Message-ID: <9a0c7e739fed3870d5d859cd293b9493a8833188.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Adds structures and basic create/delete code for extents.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile      |    3 +-
 fs/nfs/blocklayout/blocklayout.c |   17 ++++++++++-
 fs/nfs/blocklayout/blocklayout.h |   23 +++++++++++++++-
 fs/nfs/blocklayout/extents.c     |   55 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 94 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfs/blocklayout/extents.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 2c4c062..1e7619f 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,5 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o blocklayoutdm.o
+blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o blocklayoutdm.o \
+			extents.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 677836c..fb06f3a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -83,12 +83,25 @@ bl_write_pagelist(struct pnfs_layout_type *lo,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-/* STUB */
+/* FIXME - range ignored */
 static void
 release_extents(struct pnfs_block_layout *bl,
 		struct nfs4_pnfs_layout_segment *range)
 {
-	return;
+	int i;
+	struct pnfs_block_extent *be;
+
+	spin_lock(&bl->bl_ext_lock);
+	for (i = 0; i < EXTENT_LISTS; i++) {
+		while (!list_empty(&bl->bl_extents[i])) {
+			be = list_first_entry(&bl->bl_extents[i],
+					      struct pnfs_block_extent,
+					      be_node);
+			list_del(&be->be_node);
+			put_extent(be);
+		}
+	}
+	spin_unlock(&bl->bl_ext_lock);
 }
 
 /* STUB */
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index dd25f1a..4e6f8fc 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -99,10 +99,30 @@ struct pnfs_blk_sig {
 	struct pnfs_blk_sig_comp	si_comps[PNFS_BLOCK_MAX_SIG_COMP];
 };
 
+enum exstate4 {
+	PNFS_BLOCK_READWRITE_DATA	= 0,
+	PNFS_BLOCK_READ_DATA		= 1,
+	PNFS_BLOCK_INVALID_DATA		= 2, /* mapped, but data is invalid */
+	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
+};
+
 struct pnfs_inval_markings {
 	/* STUB */
 };
 
+/* sector_t fields are all in 512-byte sectors */
+struct pnfs_block_extent {
+	struct kref	be_refcnt;
+	struct list_head be_node;	/* link into lseg list */
+	struct pnfs_deviceid be_devid;  /* STUB - remevable??? */
+	struct block_device *be_mdev;
+	sector_t	be_f_offset;	/* the starting offset in the file */
+	sector_t	be_length;	/* the size of the extent */
+	sector_t	be_v_offset;	/* the starting offset in the volume */
+	enum exstate4	be_state;	/* the state of this extent */
+	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
+};
+
 static inline void
 INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
 {
@@ -170,5 +190,6 @@ struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
 					     struct pnfs_device *dev);
 int nfs4_blk_flatten(struct pnfs_blk_volume *, int, struct pnfs_block_dev *);
 void free_block_dev(struct pnfs_block_dev *bdev);
-
+/* extents.c */
+void put_extent(struct pnfs_block_extent *be);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
new file mode 100644
index 0000000..efdcc08
--- /dev/null
+++ b/fs/nfs/blocklayout/extents.c
@@ -0,0 +1,55 @@
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
+
+#include "blocklayout.h"
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+static void
+destroy_extent(struct kref *kref)
+{
+	struct pnfs_block_extent *be;
+
+	be = container_of(kref, struct pnfs_block_extent, be_refcnt);
+	dprintk("%s be=%p\n", __func__, be);
+	kfree(be);
+}
+
+void
+put_extent(struct pnfs_block_extent *be)
+{
+	if (be) {
+		dprintk("%s enter %p (%i)\n", __func__, be,
+			atomic_read(&be->be_refcnt.refcount));
+		kref_put(&be->be_refcnt, destroy_extent);
+	}
+}
+
-- 
1.7.4.1

