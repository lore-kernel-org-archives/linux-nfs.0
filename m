Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60688 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463Ab1FLXoW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:22 -0400
Message-Id: <6d11b21aa8153819f20173f45e18c4907a16f7ed.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:19 -0400
Subject: [PATCH 13/34] pnfsblock: add device operations
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile         |    2 +-
 fs/nfs/blocklayout/blocklayout.h    |   15 ++++
 fs/nfs/blocklayout/blocklayoutdev.c |  151 +++++++++++++++++++++++++++++++++++
 3 files changed, 167 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index af39d19..bd69aad 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o block-device-discovery-pipe.o extents.o
+blocklayoutdriver-objs := blocklayout.o block-device-discovery-pipe.o extents.o blocklayoutdev.o
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index ef1e64d..6c01d8c 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -35,6 +35,12 @@
 #include <linux/nfs_fs.h>
 #include "../pnfs.h"
 
+struct pnfs_block_dev {
+	struct list_head		bm_node;
+	struct nfs4_deviceid		bm_mdevid;    /* associated devid */
+	struct block_device		*bm_mdev;     /* meta device itself */
+};
+
 enum exstate4 {
 	PNFS_BLOCK_READWRITE_DATA	= 0,
 	PNFS_BLOCK_READ_DATA		= 1,
@@ -88,6 +94,15 @@ BLK_LO2EXT(struct pnfs_layout_hdr *lo)
         return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+/* blocklayoutdev.c */
+struct block_device *nfs4_blkdev_get(dev_t dev);
+int nfs4_blkdev_put(struct block_device *bdev);
+struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
+						struct pnfs_device *dev,
+						struct list_head *sdlist);
+int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
+
 #include <linux/sunrpc/simple_rpc_pipefs.h>
 
 extern struct pipefs_list bl_device_list;
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
new file mode 100644
index 0000000..9a65a66
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -0,0 +1,151 @@
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
+#include <linux/genhd.h>
+#include <linux/blkdev.h>
+#include <linux/hash.h>
+
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
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
+struct block_device *nfs4_blkdev_get(dev_t dev)
+{
+	struct block_device *bd;
+
+	dprintk("%s enter\n", __func__);
+	bd = blkdev_get_by_dev(dev, FMODE_READ, NULL);
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
+int nfs4_blkdev_put(struct block_device *bdev)
+{
+	dprintk("%s for device %d:%d\n", __func__, MAJOR(bdev->bd_dev),
+			MINOR(bdev->bd_dev));
+	return blkdev_put(bdev, FMODE_READ);
+}
+
+/* Decodes pnfs_block_deviceaddr4 (draft-8) which is XDR encoded
+ * in dev->dev_addr_buf.
+ */
+struct pnfs_block_dev *
+nfs4_blk_decode_device(struct nfs_server *server,
+		       struct pnfs_device *dev,
+		       struct list_head *sdlist)
+{
+	struct pnfs_block_dev *rv = NULL;
+	struct block_device *bd = NULL;
+	struct pipefs_hdr *msg = NULL, *reply = NULL;
+	uint32_t major, minor;
+
+	dprintk("%s enter\n", __func__);
+
+	if (IS_ERR(bl_device_pipe))
+		return NULL;
+	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
+	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
+		dev->mincount);
+	msg = pipefs_alloc_init_msg(0, BL_DEVICE_MOUNT, 0, dev->area,
+				    dev->mincount);
+	if (IS_ERR(msg)) {
+		dprintk("ERROR: couldn't make pipefs message.\n");
+		goto out_err;
+	}
+	msg->msgid = hash_ptr(&msg, sizeof(msg->msgid) * 8);
+	msg->status = BL_DEVICE_REQUEST_INIT;
+
+	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
+	reply = pipefs_queue_upcall_waitreply(bl_device_pipe, msg,
+					      &bl_device_list, 0, 0);
+
+	if (IS_ERR(reply)) {
+		dprintk("ERROR: upcall_waitreply failed\n");
+		goto out_err;
+	}
+	if (reply->status != BL_DEVICE_REQUEST_PROC) {
+		dprintk("%s failed to open device: %ld\n",
+			__func__, PTR_ERR(bd));
+		goto out_err;
+	}
+	memcpy(&major, (uint32_t *)(payload_of(reply)), sizeof(uint32_t));
+	memcpy(&minor, (uint32_t *)(payload_of(reply) + sizeof(uint32_t)),
+		sizeof(uint32_t));
+	bd = nfs4_blkdev_get(MKDEV(major, minor));
+	if (IS_ERR(bd)) {
+		dprintk("%s failed to open device : %ld\n",
+			__func__, PTR_ERR(bd));
+		goto out_err;
+	}
+
+	rv = kzalloc(sizeof(*rv), GFP_KERNEL);
+	if (!rv)
+		goto out_err;
+
+	rv->bm_mdev = bd;
+	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct nfs4_deviceid));
+	dprintk("%s Created device %s with bd_block_size %u\n",
+		__func__,
+		bd->bd_disk->disk_name,
+		bd->bd_block_size);
+	kfree(reply);
+	kfree(msg);
+	return rv;
+
+out_err:
+	kfree(rv);
+	if (!IS_ERR(reply))
+		kfree(reply);
+	if (!IS_ERR(msg))
+		kfree(msg);
+	return NULL;
+}
-- 
1.7.4.1

