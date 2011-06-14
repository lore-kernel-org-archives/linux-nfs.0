Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51978 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab1FNCcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:22 -0400
Message-Id: <b36099b389b6c762cc4e18deef54412626f89ae5.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 08/33] pnfsblock: blocklayout stub
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:19 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Adds the minimal structure for a pnfs block layout driver,
with all function pointers aimed at stubs.

[pnfsblock: SQUASHME: port block layout code]
Signed-off-by: Peng Tao <peng_tao@emc.com>
[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: move pnfs_layout_type inline in nfs_inode]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile      |    4 +-
 fs/nfs/blocklayout/blocklayout.c |  166 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 168 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayout.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index f214c1c..6bf49cd 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -1,5 +1,5 @@
 #
 # Makefile for the pNFS block layout driver kernel module
 #
-obj-$(CONFIG_PNFS_BLOCK) +=
-blocklayoutdriver-objs :=
+obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
+blocklayoutdriver-objs := blocklayout.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
new file mode 100644
index 0000000..2e0d41a
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -0,0 +1,166 @@
+/*
+ *  linux/fs/nfs/blocklayout/blocklayout.c
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
+#include <linux/module.h>
+#include <linux/init.h>
+
+#include "../pnfs.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
+MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
+
+static enum pnfs_try_status
+bl_read_pagelist(struct nfs_read_data *rdata)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
+static enum pnfs_try_status
+bl_write_pagelist(struct nfs_write_data *wdata,
+		  int sync)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
+static void
+bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+}
+
+static struct pnfs_layout_hdr *
+bl_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
+{
+	return NULL;
+}
+
+static void
+bl_free_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
+static struct pnfs_layout_segment *
+bl_alloc_lseg(struct pnfs_layout_hdr *lo,
+	      struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
+{
+	return NULL;
+}
+
+static void
+bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
+		       const struct nfs4_layoutcommit_args *arg)
+{
+}
+
+static void
+bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
+			struct nfs4_layoutcommit_data *lcdata)
+{
+}
+
+static int
+bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
+{
+	dprintk("%s enter\n", __func__);
+	return 0;
+}
+
+static int
+bl_clear_layoutdriver(struct nfs_server *server)
+{
+	dprintk("%s enter\n", __func__);
+	return 0;
+}
+
+static int
+bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
+	       unsigned count, struct pnfs_fsdata *fsdata)
+{
+	return 0;
+}
+
+static int
+bl_write_end(struct inode *inode, struct page *page, loff_t pos,
+	     unsigned count, unsigned copied, struct pnfs_layout_segment *lseg)
+{
+	return 0;
+}
+
+/* Return any memory allocated to fsdata->private, and take advantage
+ * of no page locks to mark pages noted in write_begin as needing
+ * initialization.
+ */
+static void
+bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
+{
+}
+
+static struct pnfs_layoutdriver_type blocklayout_type = {
+	.id = LAYOUT_BLOCK_VOLUME,
+	.name = "LAYOUT_BLOCK_VOLUME",
+	.read_pagelist			= bl_read_pagelist,
+	.write_pagelist			= bl_write_pagelist,
+	.write_begin			= bl_write_begin,
+	.write_end			= bl_write_end,
+	.write_end_cleanup		= bl_write_end_cleanup,
+	.alloc_layout_hdr		= bl_alloc_layout_hdr,
+	.free_layout_hdr		= bl_free_layout_hdr,
+	.alloc_lseg			= bl_alloc_lseg,
+	.free_lseg			= bl_free_lseg,
+	.encode_layoutcommit		= bl_encode_layoutcommit,
+	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
+	.set_layoutdriver		= bl_set_layoutdriver,
+	.clear_layoutdriver		= bl_clear_layoutdriver,
+	.pg_test                        = pnfs_generic_pg_test,
+};
+
+static int __init nfs4blocklayout_init(void)
+{
+	int ret;
+
+	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
+
+	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	return ret;
+}
+
+static void __exit nfs4blocklayout_exit(void)
+{
+	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
+	       __func__);
+
+	pnfs_unregister_layoutdriver(&blocklayout_type);
+}
+
+module_init(nfs4blocklayout_init);
+module_exit(nfs4blocklayout_exit);
-- 
1.7.4.1

