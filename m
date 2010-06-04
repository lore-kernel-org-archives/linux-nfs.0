From: sfaibish <sfaibish@emc.com>
Subject: [pnfs][PATCH 3/3] pnfs-blocklayout client: add block device pipe processing based on simple rpc pipefs
Date: Fri, 04 Jun 2010 14:19:22 -0400
Message-ID: <op.vdsfuksdunckof@usensfaibisl2e.eng.emc.com>
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com> <op.vdsfn9iounckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed	delsp=yes
Cc: sfaibish <sfaibish@emc.com>,
	"pnfs@linux-nfs.org" <pnfs@linux-nfs.org>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:18287 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab0FDSTb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jun 2010 14:19:31 -0400
In-Reply-To: <op.vdsfn9iounckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The patch address RPC pipe operations for block device discovery, creation  
and deletion will be
done in user space.

Format for upcall/downcall of block pipe fs.

The mount request will create device list according to device information.
The device information is according to RFC 5663 "Volume Topology"  
definitions.

The mount reply with major and minor deviceid of the created device valid  
when
pipefs_hdr_t->status equals to BL_DEVICE_REQUEST_PROC.

The umount request will remove device with certain major and minor.

The umount reply will remove the device successfully when  
pipefs_hdr_t->status
equals to BL_DEVICE_REQUEST_PROC.

Signed-off-by: Sorin Faibish <sfaibish-Wuw85uim5zDR7s880joybQ@public.gmane.org>
---
  fs/nfs/blocklayout/Makefile                      |    2 +-
  fs/nfs/blocklayout/block-device-discovery-pipe.c |  142  
++++++++++++++++++++++
  2 files changed, 143 insertions(+), 1 deletions(-)
  create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 1e7619f..5a4bf3d 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -3,4 +3,4 @@
  #
  obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
  blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o blocklayoutdm.o \
-			extents.o
+			extents.o block-device-discovery-pipe.o
diff --git a/fs/nfs/blocklayout/block-device-discovery-pipe.c  
b/fs/nfs/blocklayout/block-device-discovery-pipe.c
new file mode 100644
index 0000000..afa5764
--- /dev/null
+++ b/fs/nfs/blocklayout/block-device-discovery-pipe.c
@@ -0,0 +1,142 @@
+/*
+ * linux/fs/nfs/blocklayout/block-device-discovery-pipe.c
+ *
+ * RPC pipe operations for block device discovery, creation and deletion
+ * in user level.
+ *
+ * Copyright (c) 2010 EMC Corporation, all rights reserved.
+ *
+ * Sorin Faibish <sfaibish-Wuw85uim5zDR7s880joybQ@public.gmane.org>
+ *
+ * Drawing on work done by Haiying Tang <tang_haiying@emc.com>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the  
distribution.
+ *  3. Neither the name of the Corporation nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
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
+/* Format for upcall/downcall of block pipe fs.
+ *
+ * mount request: create device according to device information.
+ * 		|-------------|
+ * 		|pipefs_hdr_t |
+ * 		|-------------|
+ * 		| device info |
+ * 		|-------------|
+ * pipefs_hdr_t->type is BL_DEVICE_MOUNT.
+ * device info: refer to RFC 5663 "Volume Topology" for details.
+ *
+ * mount reply:
+ * 		|----------------|
+ * 		|  pipefs_hdr_t  |
+ * 		|----------------|
+ * 		| uint32_t major |
+ * 		|----------------|
+ * 		| uint32_t minor |
+ * 		|----------------|
+ * major and minor of created device is valid when pipefs_hdr_t->status
+ * equals to BL_DEVICE_REQUEST_PROC.
+ *
+ * umount request: revome device with certain major and minor.
+ * 		|----------------|
+ * 		|  pipefs_hdr_t  |
+ * 		|----------------|
+ * 		| uint32_t major |
+ * 		|----------------|
+ * 		| uint32_t minor |
+ * 		|----------------|
+ * pipefs_hdr_t->type is BL_DEVICE_UMOUNT.
+ *
+ * umount reply:
+ * 		|----------------|
+ * 		|  pipefs_hdr_t  |
+ * 		|----------------|
+ * Device is removed successfully when pipefs_hdr_t->status equals to
+ * BL_DEVICE_REQUEST_PROC.
+ */
+
+pipefs_list_t bl_device_list;
+struct dentry *bl_device_pipe;
+
+ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,  
size_t len)
+{
+	int err;
+	pipefs_hdr_t *msg;
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
+const static struct rpc_pipe_ops bl_pipe_ops = {
+	.upcall         = pipefs_generic_upcall,
+	.downcall       = bl_pipe_downcall,
+	.destroy_msg    = pipefs_generic_destroy_msg,
+};
+
+int bl_pipe_init(void)
+{
+	dprintk("%s: block_device pipefs registering...\n", __func__);
+	bl_device_pipe = pipefs_mkpipe("bl_device_pipe", &bl_pipe_ops, 1);
+	if (IS_ERR(bl_device_pipe)) {
+		dprintk("ERROR, unable to make block_device pipe\n");
+		return 0;
+	}
+	else
+		dprintk("bl_device_pipe created!\n");
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
-- 
1.6.6.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

