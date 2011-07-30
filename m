From: Jim Rees <rees@umich.edu>
Subject: [PATCH v6 11/26] pnfsblock: basic extent code
Date: Sat, 30 Jul 2011 13:08:34 -0400
Message-ID: <1312045729-27554-12-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:49575 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab1G3RJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:09:10 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Adds structures and basic create/delete code for extents.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Zhang Jingwang <Jingwang.Zhang@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/Makefile      |    2 +-
 fs/nfs/blocklayout/blocklayout.c |   20 +++++++--
 fs/nfs/blocklayout/blocklayout.h |    1 +
 fs/nfs/blocklayout/extents.c     |   89 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 107 insertions(+), 5 deletions(-)
 create mode 100644 fs/nfs/blocklayout/extents.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 6bf49cd..5cfadf6 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o
+blocklayoutdriver-objs := blocklayout.o extents.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index c6beb15..fd4fdb5a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -53,12 +53,24 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-/* STUB */
+/* FIXME - range ignored */
 static void
-release_extents(struct pnfs_block_layout *bl,
-		struct pnfs_layout_range *range)
+release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
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
+			bl_put_extent(be);
+		}
+	}
+	spin_unlock(&bl->bl_ext_lock);
 }
 
 /* STUB */
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 8bfa466..98e2f60 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -88,4 +88,5 @@ static inline struct pnfs_block_layout *BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 	return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+void bl_put_extent(struct pnfs_block_extent *be);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
new file mode 100644
index 0000000..d0ca760
--- /dev/null
+++ b/fs/nfs/blocklayout/extents.c
@@ -0,0 +1,89 @@
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
+bl_put_extent(struct pnfs_block_extent *be)
+{
+	if (be) {
+		dprintk("%s enter %p (%i)\n", __func__, be,
+			atomic_read(&be->be_refcnt.refcount));
+		kref_put(&be->be_refcnt, destroy_extent);
+	}
+}
+
+struct pnfs_block_extent *bl_alloc_extent(void)
+{
+	struct pnfs_block_extent *be;
+
+	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
+	if (!be)
+		return NULL;
+	INIT_LIST_HEAD(&be->be_node);
+	kref_init(&be->be_refcnt);
+	be->be_inval = NULL;
+	return be;
+}
+
+static void print_elist(struct list_head *list)
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

