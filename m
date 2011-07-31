Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:37680 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab1GaAxS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 20:53:18 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v7 12/26] pnfsblock: add device operations
Date: Sat, 30 Jul 2011 20:52:42 -0400
Message-Id: <1312073576-11024-13-git-send-email-rees@umich.edu>
In-Reply-To: <1312073576-11024-1-git-send-email-rees@umich.edu>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
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
 fs/nfs/blocklayout/Makefile         |    2 +-
 fs/nfs/blocklayout/blocklayout.c    |   42 ++++++++
 fs/nfs/blocklayout/blocklayout.h    |   40 +++++++
 fs/nfs/blocklayout/blocklayoutdev.c |  191 +++++++++++++++++++++++++++++++++++
 fs/nfs/client.c                     |    2 +-
 include/linux/nfs.h                 |    2 +
 6 files changed, 277 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 5cfadf6..5bf3409 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o extents.o
+blocklayoutdriver-objs := blocklayout.o extents.o blocklayoutdev.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 8dde372..c838784 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -31,6 +31,8 @@
  */
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
 
 #include "blocklayout.h"
 
@@ -40,6 +42,9 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
 MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 
+struct dentry *bl_device_pipe;
+wait_queue_head_t bl_wq;
+
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
@@ -176,13 +181,49 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.pg_write_ops			= &bl_pg_write_ops,
 };
 
+static const struct rpc_pipe_ops bl_upcall_ops = {
+	.upcall		= bl_pipe_upcall,
+	.downcall	= bl_pipe_downcall,
+	.destroy_msg	= bl_pipe_destroy_msg,
+};
+
 static int __init nfs4blocklayout_init(void)
 {
+	struct vfsmount *mnt;
+	struct path path;
 	int ret;
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
 	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	if (ret)
+		goto out;
+
+	init_waitqueue_head(&bl_wq);
+
+	mnt = rpc_get_mount();
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto out_remove;
+	}
+
+	ret = vfs_path_lookup(mnt->mnt_root,
+			      mnt,
+			      NFS_PIPE_DIRNAME, 0, &path);
+	if (ret)
+		goto out_remove;
+
+	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
+				    &bl_upcall_ops, 0);
+	if (IS_ERR(bl_device_pipe)) {
+		ret = PTR_ERR(bl_device_pipe);
+		goto out_remove;
+	}
+out:
+	return ret;
+
+out_remove:
+	pnfs_unregister_layoutdriver(&blocklayout_type);
 	return ret;
 }
 
@@ -192,6 +233,7 @@ static void __exit nfs4blocklayout_exit(void)
 	       __func__);
 
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+	rpc_unlink(bl_device_pipe);
 }
 
 MODULE_ALIAS("nfs-layouttype4-3");
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 98e2f60..dd25f1b 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -34,8 +34,16 @@
 
 #include <linux/device-mapper.h>
 #include <linux/nfs_fs.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+
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
@@ -88,5 +96,37 @@ static inline struct pnfs_block_layout *BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 	return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+struct bl_dev_msg {
+	int status;
+	uint32_t major, minor;
+};
+
+struct bl_msg_hdr {
+	u8  type;
+	u16 totallen; /* length of entire message, including hdr itself */
+};
+
+extern struct dentry *bl_device_pipe;
+extern wait_queue_head_t bl_wq;
+
+#define BL_DEVICE_UMOUNT               0x0 /* Umount--delete devices */
+#define BL_DEVICE_MOUNT                0x1 /* Mount--create devices*/
+#define BL_DEVICE_REQUEST_INIT         0x0 /* Start request */
+#define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds */
+#define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
+
+/* blocklayoutdev.c */
+ssize_t bl_pipe_upcall(struct file *, struct rpc_pipe_msg *,
+		       char __user *, size_t);
+ssize_t bl_pipe_downcall(struct file *, const char __user *, size_t);
+void bl_pipe_destroy_msg(struct rpc_pipe_msg *);
+struct block_device *nfs4_blkdev_get(dev_t dev);
+int nfs4_blkdev_put(struct block_device *bdev);
+struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
+						struct pnfs_device *dev,
+						struct list_head *sdlist);
+int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
+
 void bl_put_extent(struct pnfs_block_extent *be);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
new file mode 100644
index 0000000..7e1377f
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -0,0 +1,191 @@
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
+/*
+ * Shouldn't there be a rpc_generic_upcall() to do this for us?
+ */
+ssize_t bl_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
+		       char __user *dst, size_t buflen)
+{
+	char *data = (char *)msg->data + msg->copied;
+	size_t mlen = min(msg->len - msg->copied, buflen);
+	unsigned long left;
+
+	left = copy_to_user(dst, data, mlen);
+	if (left == mlen) {
+		msg->errno = -EFAULT;
+		return -EFAULT;
+	}
+
+	mlen -= left;
+	msg->copied += mlen;
+	msg->errno = 0;
+	return mlen;
+}
+
+static struct bl_dev_msg bl_mount_reply;
+
+ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
+			 size_t mlen)
+{
+	if (mlen != sizeof (struct bl_dev_msg))
+		return -EINVAL;
+
+	if (copy_from_user(&bl_mount_reply, src, mlen) != 0)
+		return -EFAULT;
+
+	wake_up(&bl_wq);
+
+	return mlen;
+}
+
+void bl_pipe_destroy_msg(struct rpc_pipe_msg *msg)
+{
+	if (msg->errno >= 0)
+		return;
+	wake_up(&bl_wq);
+}
+
+/*
+ * Decodes pnfs_block_deviceaddr4 which is XDR encoded in dev->dev_addr_buf.
+ */
+struct pnfs_block_dev *
+nfs4_blk_decode_device(struct nfs_server *server,
+		       struct pnfs_device *dev,
+		       struct list_head *sdlist)
+{
+	struct pnfs_block_dev *rv = NULL;
+	struct block_device *bd = NULL;
+	struct rpc_pipe_msg msg;
+	struct bl_msg_hdr bl_msg = {
+		.type = BL_DEVICE_MOUNT,
+		.totallen = dev->mincount,
+	};
+	uint8_t *dataptr;
+	DECLARE_WAITQUEUE(wq, current);
+	struct bl_dev_msg *reply = &bl_mount_reply;
+
+	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
+	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
+		dev->mincount);
+
+	memset(&msg, 0, sizeof(msg));
+	msg.data = kzalloc(sizeof(bl_msg) + dev->mincount, GFP_NOFS);
+	if (!msg.data) {
+		rv = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	memcpy(msg.data, &bl_msg, sizeof(bl_msg));
+	dataptr = (uint8_t *) msg.data;
+	memcpy(&dataptr[sizeof(bl_msg)], dev->area, dev->mincount);
+	msg.len = sizeof(bl_msg) + dev->mincount;
+
+	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
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
+	if (reply->status != BL_DEVICE_REQUEST_PROC) {
+		dprintk("%s failed to open device: %d\n",
+			__func__, reply->status);
+		rv = ERR_PTR(-EINVAL);
+		goto out;
+	}
+
+	bd = nfs4_blkdev_get(MKDEV(reply->major, reply->minor));
+	if (IS_ERR(bd)) {
+		dprintk("%s failed to open device : %ld\n",
+			__func__, PTR_ERR(bd));
+		goto out;
+	}
+
+	rv = kzalloc(sizeof(*rv), GFP_NOFS);
+	if (!rv) {
+		rv = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	rv->bm_mdev = bd;
+	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct nfs4_deviceid));
+	dprintk("%s Created device %s with bd_block_size %u\n",
+		__func__,
+		bd->bd_disk->disk_name,
+		bd->bd_block_size);
+
+out:
+	kfree(msg.data);
+	return rv;
+}
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index de00a37..5833fbb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -105,7 +105,7 @@ struct rpc_program nfs_program = {
 	.nrvers			= ARRAY_SIZE(nfs_version),
 	.version		= nfs_version,
 	.stats			= &nfs_rpcstat,
-	.pipe_dir_name		= "/nfs",
+	.pipe_dir_name		= NFS_PIPE_DIRNAME,
 };
 
 struct rpc_stat nfs_rpcstat = {
diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index f387919..8c6ee44 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -29,6 +29,8 @@
 #define NFS_MNT_VERSION		1
 #define NFS_MNT3_VERSION	3
 
+#define NFS_PIPE_DIRNAME "/nfs"
+
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
  * a superset of NFSv2 errors (with the exception of NFSERR_WFLUSH which
-- 
1.7.4.1

