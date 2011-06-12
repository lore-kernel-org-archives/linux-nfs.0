Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60667 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab1FLXoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:16 -0400
Message-Id: <5be5530d45a60a1667be0b9d6648223e9f2a5359.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:14 -0400
Subject: [PATCH 11/34] pnfs-block: Add block device discovery pipe
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Eric Anderle <eanderle@umich.edu>
Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile                      |    2 +-
 fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 ++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.c                 |    3 +
 fs/nfs/blocklayout/blocklayout.h                 |   14 +++++
 4 files changed, 84 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 6bf49cd..d2bcd81 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o
+blocklayoutdriver-objs := blocklayout.o block-device-discovery-pipe.o
diff --git a/fs/nfs/blocklayout/block-device-discovery-pipe.c b/fs/nfs/blocklayout/block-device-discovery-pipe.c
new file mode 100644
index 0000000..e4c199f
--- /dev/null
+++ b/fs/nfs/blocklayout/block-device-discovery-pipe.c
@@ -0,0 +1,66 @@
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/proc_fs.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/sched.h>
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY NFSDBG_PNFS_LD
+
+struct pipefs_list bl_device_list;
+struct dentry *bl_device_pipe;
+
+ssize_t bl_pipe_downcall(struct file *filp, const char __user *src, size_t len)
+{
+	int err;
+	struct pipefs_hdr *msg;
+
+	dprintk("Entering %s...\n", __func__);
+
+	msg = pipefs_readmsg(filp, src, len);
+	if (IS_ERR(msg)) {
+		dprintk("ERROR: unable to read pipefs message.\n");
+		return PTR_ERR(msg);
+	}
+
+	/* now assign the result, which wakes the blocked thread */
+	err = pipefs_assign_upcall_reply(msg, &bl_device_list);
+	if (err) {
+		dprintk("ERROR: failed to assign upcall with id %u\n",
+			msg->msgid);
+		kfree(msg);
+	}
+	return len;
+}
+
+static const struct rpc_pipe_ops bl_pipe_ops = {
+	.upcall         = pipefs_generic_upcall,
+	.downcall       = bl_pipe_downcall,
+	.destroy_msg    = pipefs_generic_destroy_msg,
+};
+
+int bl_pipe_init(void)
+{
+	dprintk("%s: block_device pipefs registering...\n", __func__);
+	bl_device_pipe = pipefs_mkpipe("bl_device_pipe", &bl_pipe_ops, 1);
+	if (IS_ERR(bl_device_pipe))
+		dprintk("ERROR, unable to make block_device pipe\n");
+
+	if (!bl_device_pipe)
+		dprintk("bl_device_pipe is NULL!\n");
+	else
+	dprintk("bl_device_pipe created!\n");
+	pipefs_init_list(&bl_device_list);
+	return 0;
+}
+
+void bl_pipe_exit(void)
+{
+	dprintk("%s: block_device pipefs unregistering...\n", __func__);
+	if (IS_ERR(bl_device_pipe))
+		return ;
+	pipefs_closepipe(bl_device_pipe);
+	return;
+}
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 8218d54..9932519 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -186,6 +186,8 @@ static int __init nfs4blocklayout_init(void)
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
 	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	if (!ret)
+		bl_pipe_init();
 	return ret;
 }
 
@@ -195,6 +197,7 @@ static void __exit nfs4blocklayout_exit(void)
 	       __func__);
 
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+	bl_pipe_exit();
 }
 
 module_init(nfs4blocklayout_init);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 8ea82b8..2a78462 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -88,4 +88,18 @@ BLK_LO2EXT(struct pnfs_layout_hdr *lo)
         return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+#include <linux/sunrpc/simple_rpc_pipefs.h>
+
+extern struct pipefs_list bl_device_list;
+extern struct dentry *bl_device_pipe;
+
+int bl_pipe_init(void);
+void bl_pipe_exit(void);
+
+#define BL_DEVICE_UMOUNT               0x0 /* Umount--delete devices */
+#define BL_DEVICE_MOUNT                0x1 /* Mount--create devices*/
+#define BL_DEVICE_REQUEST_INIT         0x0 /* Start request */
+#define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds */
+#define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
+
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
-- 
1.7.4.1

