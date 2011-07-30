From: Jim Rees <rees@umich.edu>
Subject: [PATCH v6 09/26] pnfsblock: add blocklayout Kconfig option, Makefile, and stubs
Date: Sat, 30 Jul 2011 13:08:32 -0400
Message-ID: <1312045729-27554-10-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:56494 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab1G3RJH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:09:07 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Define a configuration variable to enable/disable compilation of the
block driver code.

Add the minimal structure for a pnfs block layout driver, and empty
list-heads that will hold the extent data

[pnfsblock: make NFS_V4_1 select PNFS_BLOCK]
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: move pnfs_layout_type inline in nfs_inode]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[pnfsblock: layout alloc and free]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: move pnfs_layout_type inline in nfs_inode]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[pnfsblock: define module alias]
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/Kconfig                   |    8 ++-
 fs/nfs/Makefile                  |    1 +
 fs/nfs/blocklayout/Makefile      |    5 +
 fs/nfs/blocklayout/blocklayout.c |  175 ++++++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h |   91 ++++++++++++++++++++
 5 files changed, 279 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/blocklayout/Makefile
 create mode 100644 fs/nfs/blocklayout/blocklayout.c
 create mode 100644 fs/nfs/blocklayout/blocklayout.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 2cde5d9..be02077 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -79,15 +79,21 @@ config NFS_V4_1
 	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
 	select SUNRPC_BACKCHANNEL
 	select PNFS_FILE_LAYOUT
+	select PNFS_BLOCK
+	select MD
+	select BLK_DEV_DM
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
-	  (RFC 5661) in the kernel's NFS client.
+	  (RFC 5661 and RFC 5663) in the kernel's NFS client.
 
 	  If unsure, say N.
 
 config PNFS_FILE_LAYOUT
 	tristate
 
+config PNFS_BLOCK
+	tristate
+
 config PNFS_OBJLAYOUT
 	tristate "Provide support for the pNFS Objects Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
 	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 6a34f7d..b58613d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
+obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
new file mode 100644
index 0000000..6bf49cd
--- /dev/null
+++ b/fs/nfs/blocklayout/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the pNFS block layout driver kernel module
+#
+obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
+blocklayoutdriver-objs := blocklayout.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
new file mode 100644
index 0000000..9230f84
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -0,0 +1,175 @@
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
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY	NFSDBG_PNFS_LD
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
+static void bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+
+	dprintk("%s enter\n", __func__);
+	release_extents(bl, NULL);
+	release_inval_marks(&bl->bl_inval);
+	kfree(bl);
+}
+
+static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
+						   gfp_t gfp_flags)
+{
+	struct pnfs_block_layout *bl;
+
+	dprintk("%s enter\n", __func__);
+	bl = kzalloc(sizeof(*bl), gfp_flags);
+	if (!bl)
+		return NULL;
+	spin_lock_init(&bl->bl_ext_lock);
+	INIT_LIST_HEAD(&bl->bl_extents[0]);
+	INIT_LIST_HEAD(&bl->bl_extents[1]);
+	INIT_LIST_HEAD(&bl->bl_commit);
+	INIT_LIST_HEAD(&bl->bl_committing);
+	bl->bl_count = 0;
+	bl->bl_blocksize = NFS_SERVER(inode)->pnfs_blksize >> SECTOR_SHIFT;
+	BL_INIT_INVAL_MARKS(&bl->bl_inval, bl->bl_blocksize);
+	return &bl->bl_layout;
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
+static struct pnfs_layoutdriver_type blocklayout_type = {
+	.id				= LAYOUT_BLOCK_VOLUME,
+	.name				= "LAYOUT_BLOCK_VOLUME",
+	.read_pagelist			= bl_read_pagelist,
+	.write_pagelist			= bl_write_pagelist,
+	.alloc_layout_hdr		= bl_alloc_layout_hdr,
+	.free_layout_hdr		= bl_free_layout_hdr,
+	.alloc_lseg			= bl_alloc_lseg,
+	.free_lseg			= bl_free_lseg,
+	.encode_layoutcommit		= bl_encode_layoutcommit,
+	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
+	.set_layoutdriver		= bl_set_layoutdriver,
+	.clear_layoutdriver		= bl_clear_layoutdriver,
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
+MODULE_ALIAS("nfs-layouttype4-3");
+
+module_init(nfs4blocklayout_init);
+module_exit(nfs4blocklayout_exit);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
new file mode 100644
index 0000000..8bfa466
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
+#include <linux/device-mapper.h>
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
+	struct nfs4_deviceid be_devid;  /* FIXME: could use device cache instead */
+	struct block_device *be_mdev;
+	sector_t	be_f_offset;	/* the starting offset in the file */
+	sector_t	be_length;	/* the size of the extent */
+	sector_t	be_v_offset;	/* the starting offset in the volume */
+	enum exstate4	be_state;	/* the state of this extent */
+	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
+};
+
+static inline void
+BL_INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
+{
+	/* STUB */
+}
+
+enum extentclass4 {
+	RW_EXTENT       = 0, /* READWRTE and INVAL */
+	RO_EXTENT       = 1, /* READ and NONE */
+	EXTENT_LISTS    = 2,
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
+static inline struct pnfs_block_layout *BLK_LO2EXT(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct pnfs_block_layout, bl_layout);
+}
+
+#endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
-- 
1.7.4.1

