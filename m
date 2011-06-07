Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53020 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab1FGR1Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:25 -0400
Date: Tue, 7 Jun 2011 13:27:23 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 13/88] pnfsblock: scan scsi devices
Message-ID: <83657c8f7323da3b32fe8785839f36e1aad33d4f.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Scan scsi devices available to map against future GETDEVICEINFO output.

[pnfsblock: use class iteration api]
[pnfsblock: fix oops when using multiple devices]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile         |    2 +-
 fs/nfs/blocklayout/blocklayout.c    |   13 ++-
 fs/nfs/blocklayout/blocklayout.h    |   53 ++++++++
 fs/nfs/blocklayout/blocklayoutdev.c |  231 +++++++++++++++++++++++++++++++++++
 4 files changed, 295 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayout.h
 create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 6bf49cd..36d959f 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o
+blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1312849..9889f27 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -32,9 +32,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
-#include <linux/nfs_fs.h>
-#include <linux/pnfs_xdr.h> /* Needed by nfs4_pnfs.h */
-#include <linux/nfs4_pnfs.h>
+#include "blocklayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -135,10 +133,19 @@ bl_cleanup_layoutcommit(struct pnfs_layout_type *lo,
 	dprintk("%s enter\n", __func__);
 }
 
+/*
+ * This is just a STUB to check the scsi scanning code
+ */
 static struct pnfs_mount_type *
 bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 {
+	LIST_HEAD(scsi_disklist);
+
 	dprintk("%s enter\n", __func__);
+
+	nfs4_blk_create_scsi_disk_list(&scsi_disklist);
+	nfs4_blk_destroy_disk_list(&scsi_disklist);
+
 	return NULL;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
new file mode 100644
index 0000000..5dbb8f2
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -0,0 +1,53 @@
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
+#include <linux/pnfs_xdr.h> /* Needed by nfs4_pnfs.h */
+#include <linux/nfs4_pnfs.h>
+
+extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
+
+/* holds visible disks that can be matched against VOLUME_SIMPLE signatures */
+struct visible_block_device {
+	struct list_head	vi_node;
+	struct block_device	*vi_bdev;
+	int			vi_mapped;
+	int			vi_put_done;
+};
+
+/* blocklayoutdev.c */
+int nfs4_blk_create_scsi_disk_list(struct list_head *);
+void nfs4_blk_destroy_disk_list(struct list_head *);
+
+#endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
new file mode 100644
index 0000000..b4f52fb
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -0,0 +1,231 @@
+/*
+ *  linux/fs/nfs/blocklayout/blocklayoutdev.c
+ *
+ *  Device operations for the pnfs nfs4 file layout driver.
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
+#include <linux/buffer_head.h> /* __bread */
+
+#include <scsi/scsi.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_host.h>
+
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+#define MAX_VOLS  256  /* Maximum number of SCSI disks.  Totally arbitrary */
+
+uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
+{
+	uint32_t *q = p + XDR_QUADLEN(nbytes);
+	if (unlikely(q > end || q < p))
+		return NULL;
+	return p;
+}
+EXPORT_SYMBOL(blk_overflow);
+
+/* Open a block_device by device number. */
+static struct block_device *nfs4_blkdev_get(dev_t dev)
+{
+	struct block_device *bd;
+
+	dprintk("%s enter\n", __func__);
+	bd = open_by_devnum(dev, FMODE_READ);
+	if (IS_ERR(bd))
+		goto fail;
+	return bd;
+fail:
+	dprintk("%s failed to open device : %ld\n",
+			__func__, PTR_ERR(bd));
+	return NULL;
+}
+
+/*
+ * Release the block device
+ */
+static int nfs4_blkdev_put(struct block_device *bdev)
+{
+	dprintk("%s for device %d:%d\n", __func__, MAJOR(bdev->bd_dev),
+			MINOR(bdev->bd_dev));
+	bd_release(bdev);
+	return blkdev_put(bdev, FMODE_READ);
+}
+
+/* Add a visible, claimed (by us!) scsi disk to the device list */
+static int alloc_add_disk(struct block_device *blk_dev, struct list_head *dlist)
+{
+	struct visible_block_device *vis_dev;
+
+	dprintk("%s enter\n", __func__);
+	vis_dev = kmalloc(sizeof(struct visible_block_device), GFP_KERNEL);
+	if (!vis_dev) {
+		dprintk("%s nfs4_get_sig failed\n", __func__);
+		return -ENOMEM;
+	}
+	vis_dev->vi_bdev = blk_dev;
+	vis_dev->vi_mapped = 0;
+	vis_dev->vi_put_done = 0;
+	list_add(&vis_dev->vi_node, dlist);
+	return 0;
+}
+
+/* Walk the list of scsi_devices. Add disks that can be opened and claimed
+ * to the device list
+ */
+static int
+nfs4_blk_add_scsi_disk(struct Scsi_Host *shost,
+		       int index, struct list_head *dlist)
+{
+	static char *claim_ptr = "I belong to pnfs block driver";
+	struct block_device *bdev;
+	struct gendisk *gd;
+	struct scsi_device *sdev;
+	unsigned int major, minor, ret = 0;
+	dev_t dev;
+
+	dprintk("%s enter \n", __func__);
+	if (index >= MAX_VOLS) {
+		dprintk("%s MAX_VOLS hit\n", __func__);
+		return -ENOSPC;
+	}
+	dprintk("%s 1 \n", __func__);
+	index--;
+	shost_for_each_device(sdev, shost) {
+		dprintk("%s 2\n", __func__);
+		/* Need to do this check before bumping index */
+		if (sdev->type != TYPE_DISK)
+			continue;
+		dprintk("%s 3 index %d \n", __func__, index);
+		if (++index >= MAX_VOLS) {
+			scsi_device_put(sdev);
+			break;
+		}
+		major = (!(index >> 4) ? SCSI_DISK0_MAJOR :
+			 SCSI_DISK1_MAJOR-1 + (index  >> 4));
+		minor =  ((index << 4) & 255);
+
+		dprintk("%s SCSI device %d:%d \n", __func__, major, minor);
+
+		dev = MKDEV(major, minor);
+		bdev = nfs4_blkdev_get(dev);
+		if (!bdev) {
+			dprintk("%s: failed to open device %d:%d\n",
+					__func__, major, minor);
+			continue;
+		}
+		gd = bdev->bd_disk;
+
+		dprintk("%s 4\n", __func__);
+
+		if (bd_claim(bdev, claim_ptr)) {
+			dprintk("%s: failed to claim device %d:%d\n",
+				__func__, gd->major, gd->first_minor);
+			blkdev_put(bdev, FMODE_READ);
+			continue;
+		}
+
+		ret = alloc_add_disk(bdev, dlist);
+		if (ret < 0)
+			goto out_err;
+		dprintk("%s ADDED DEVICE capacity %ld, bd_block_size %d\n",
+					__func__,
+					(unsigned long)get_capacity(gd),
+					bdev->bd_block_size);
+
+	}
+	index++;
+	dprintk("%s returns index %d \n", __func__, index);
+	return index;
+
+out_err:
+	dprintk("%s Can't add disk to list. ERROR: %d\n", __func__, ret);
+	nfs4_blkdev_put(bdev);
+	return ret;
+}
+
+/* Destroy the temporary scsi disk list */
+void nfs4_blk_destroy_disk_list(struct list_head *dlist)
+{
+	struct visible_block_device *vis_dev;
+
+	dprintk("%s enter\n", __func__);
+	while (!list_empty(dlist)) {
+		vis_dev = list_first_entry(dlist, struct visible_block_device,
+					   vi_node);
+		dprintk("%s removing device %d:%d\n", __func__,
+				MAJOR(vis_dev->vi_bdev->bd_dev),
+				MINOR(vis_dev->vi_bdev->bd_dev));
+		list_del(&vis_dev->vi_node);
+		if (!vis_dev->vi_put_done)
+			nfs4_blkdev_put(vis_dev->vi_bdev);
+		kfree(vis_dev);
+	}
+}
+
+struct nfs4_blk_scsi_disk_list_ctl {
+	struct list_head *dlist;
+	int index;
+};
+
+static int nfs4_blk_iter_scsi_disk_list(struct device *cdev, void *data)
+{
+	struct Scsi_Host *shost;
+	struct nfs4_blk_scsi_disk_list_ctl *lc = data;
+	int ret;
+
+	dprintk("%s enter\n", __func__);
+	shost = class_to_shost(cdev);
+	ret = nfs4_blk_add_scsi_disk(shost, lc->index, lc->dlist);
+	dprintk("%s 1 ret %d\n", __func__, ret);
+	if (ret >= 0) {
+		lc->index = ret;
+		ret = 0;
+	}
+	return ret;
+}
+
+/*
+ * Create a temporary list of all SCSI disks host can see, and that have not
+ * yet been claimed.
+ * shost_class: list of all registered scsi_hosts
+ * returns -errno on error, and #of devices found on success.
+ * XXX Loosely emulate scsi_host_lookup from scsi/host.c
+*/
+int nfs4_blk_create_scsi_disk_list(struct list_head *dlist)
+{
+	struct nfs4_blk_scsi_disk_list_ctl lc = {
+		.dlist = dlist,
+		.index = 0,
+	};
+
+	dprintk("%s enter\n", __func__);
+	return class_for_each_device(&shost_class, NULL,
+				     &lc, nfs4_blk_iter_scsi_disk_list);
+}
-- 
1.7.4.1

