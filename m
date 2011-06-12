Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60676 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab1FLXoT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:19 -0400
Message-Id: <4c028f8c4ebe42c2c39ebbc601c2e3d8b279134d.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:16 -0400
Subject: [PATCH 12/34] pnfsblock: basic extent code
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Adds structures and basic create/delete code for extents.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Zhang Jingwang <Jingwang.Zhang@emc.com>
---
 fs/nfs/blocklayout/Makefile      |    2 +-
 fs/nfs/blocklayout/blocklayout.c |   17 ++++++-
 fs/nfs/blocklayout/blocklayout.h |    1 +
 fs/nfs/blocklayout/extents.c     |   97 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 114 insertions(+), 3 deletions(-)
 create mode 100644 fs/nfs/blocklayout/extents.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index d2bcd81..af39d19 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o block-device-discovery-pipe.o
+blocklayoutdriver-objs := blocklayout.o block-device-discovery-pipe.o extents.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9932519..a245e73 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -53,12 +53,25 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-/* STUB */
+/* FIXME - range ignored */
 static void
 release_extents(struct pnfs_block_layout *bl,
 		struct pnfs_layout_range *range)
 {
-	return;
+        int i;
+        struct pnfs_block_extent *be;
+
+        spin_lock(&bl->bl_ext_lock);
+        for (i = 0; i < EXTENT_LISTS; i++) {
+                while (!list_empty(&bl->bl_extents[i])) {
+                        be = list_first_entry(&bl->bl_extents[i],
+					struct pnfs_block_extent,
+					be_node);
+                        list_del(&be->be_node);
+                        put_extent(be);
+                }
+        }
+        spin_unlock(&bl->bl_ext_lock);
 }
 
 /* STUB */
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 2a78462..ef1e64d 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -102,4 +102,5 @@ void bl_pipe_exit(void);
 #define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds */
 #define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
 
+void put_extent(struct pnfs_block_extent *be);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
new file mode 100644
index 0000000..1283fa9
--- /dev/null
+++ b/fs/nfs/blocklayout/extents.c
@@ -0,0 +1,97 @@
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
+static void print_bl_extent(struct pnfs_block_extent *be)
+{
+	dprintk("PRINT EXTENT extent %p\n", be);
+	if (be) {
+		dprintk("        be_f_offset %llu\n", (u64)be->be_f_offset);
+		dprintk("        be_length   %llu\n", (u64)be->be_length);
+		dprintk("        be_v_offset %llu\n", (u64)be->be_v_offset);
+		dprintk("        be_state    %d\n", be->be_state);
+	}
+}
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
+struct pnfs_block_extent *alloc_extent(void)
+{
+	struct pnfs_block_extent *be;
+
+	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_KERNEL);
+	if (!be)
+		return NULL;
+	INIT_LIST_HEAD(&be->be_node);
+	kref_init(&be->be_refcnt);
+	be->be_inval = NULL;
+	return be;
+}
+
+struct pnfs_block_extent *
+get_extent(struct pnfs_block_extent *be)
+{
+	if (be)
+		kref_get(&be->be_refcnt);
+	return be;
+}
+
+void print_elist(struct list_head *list)
+{
+	struct pnfs_block_extent *be;
+	dprintk("****************\n");
+	dprintk("Extent list looks like:\n");
+	list_for_each_entry(be, list, be_node) {
+		print_bl_extent(be);
+	}
+	dprintk("****************\n");
+}
-- 
1.7.4.1

