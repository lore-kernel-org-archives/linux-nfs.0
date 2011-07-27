Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53997 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257Ab1G0SlD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:41:03 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 10/25] pnfsblock: remove device operations
Date: Wed, 27 Jul 2011 14:40:33 -0400
Message-Id: <1311792048-12551-11-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[upcall bugfixes]
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/Makefile        |    2 +-
 fs/nfs/blocklayout/blocklayout.h   |    3 +
 fs/nfs/blocklayout/blocklayoutdm.c |  111 ++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayoutdm.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 5bf3409..d581550 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o extents.o blocklayoutdev.o
+blocklayoutdriver-objs := blocklayout.o extents.o blocklayoutdev.o blocklayoutdm.o
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 3dcc971..9b88918 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -128,5 +128,8 @@ struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
 int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 
+/* blocklayoutdm.c */
+void free_block_dev(struct pnfs_block_dev *bdev);
+
 void bl_put_extent(struct pnfs_block_extent *be);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
new file mode 100644
index 0000000..eab95f3
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -0,0 +1,111 @@
+/*
+ *  linux/fs/nfs/blocklayout/blocklayoutdm.c
+ *
+ *  Module for the NFSv4.1 pNFS block layout driver.
+ *
+ *  Copyright (c) 2007 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Fred Isaman <iisaman@umich.edu>
+ *  Andy Adamson <andros@citi.umich.edu>
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
+#include <linux/genhd.h> /* gendisk - used in a dprintk*/
+#include <linux/sched.h>
+#include <linux/hash.h>
+
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+static void dev_remove(dev_t dev)
+{
+	struct rpc_pipe_msg msg;
+	struct bl_dev_msg bl_umount_request;
+	struct bl_msg_hdr bl_msg = {
+		.type = BL_DEVICE_UMOUNT,
+		.totallen = sizeof(bl_umount_request),
+	};
+	uint8_t *dataptr;
+	DECLARE_WAITQUEUE(wq, current);
+
+	dprintk("Entering %s\n", __func__);
+
+	memset(&msg, 0, sizeof(msg));
+	msg.data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
+	if (!msg.data)
+		goto out;
+
+	memset(&bl_umount_request, 0, sizeof(bl_umount_request));
+	bl_umount_request.major = MAJOR(dev);
+	bl_umount_request.minor = MINOR(dev);
+
+	memcpy(msg.data, &bl_msg, sizeof(bl_msg));
+	dataptr = (uint8_t *) msg.data;
+	memcpy(&dataptr[sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request));
+	msg.len = sizeof(bl_msg) + bl_msg.totallen;
+
+	add_wait_queue(&bl_wq, &wq);
+	if (rpc_queue_upcall(bl_device_pipe->d_inode, &msg) < 0) {
+		remove_wait_queue(&bl_wq, &wq);
+		goto out;
+	}
+
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	__set_current_state(TASK_RUNNING);
+	remove_wait_queue(&bl_wq, &wq);
+
+out:
+	kfree(msg.data);
+}
+
+/*
+ * Release meta device
+ */
+static void nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
+{
+	int rv;
+
+	dprintk("%s Releasing\n", __func__);
+	rv = nfs4_blkdev_put(bdev->bm_mdev);
+	if (rv)
+		printk(KERN_ERR "%s nfs4_blkdev_put returns %d\n",
+				__func__, rv);
+
+	dev_remove(bdev->bm_mdev->bd_dev);
+}
+
+void free_block_dev(struct pnfs_block_dev *bdev)
+{
+	if (bdev) {
+		if (bdev->bm_mdev) {
+			dprintk("%s Removing DM device: %d:%d\n",
+				__func__,
+				MAJOR(bdev->bm_mdev->bd_dev),
+				MINOR(bdev->bm_mdev->bd_dev));
+			nfs4_blk_metadev_release(bdev);
+		}
+		kfree(bdev);
+	}
+}
-- 
1.7.4.1

