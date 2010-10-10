Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756165Ab0JOGRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:41 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/12] RFC: pnfs: filelayout: introduce minimal file layout driver
Date: Sun, 10 Oct 2010 11:22:49 -0400
Message-Id: <1286724173-8493-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Dean Hildebrand <dhildebz@umich.edu>

This driver just registers itself and supplies trivial mount/umount functions.

Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/Makefile         |    3 ++
 fs/nfs/nfs4filelayout.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h  |    1 +
 3 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/nfs4filelayout.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index bb9e773..08a8889 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -18,3 +18,6 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
+
+obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
+nfs_layout_nfsv41_files-y := nfs4filelayout.o
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
new file mode 100644
index 0000000..696e283
--- /dev/null
+++ b/fs/nfs/nfs4filelayout.c
@@ -0,0 +1,78 @@
+/*
+ *  Module for the pnfs nfs4 file layout driver.
+ *  Defines all I/O and Policy interface operations, plus code
+ *  to register itself with the pNFS client.
+ *
+ *  Copyright (c) 2002
+ *  The Regents of the University of Michigan
+ *  All Rights Reserved
+ *
+ *  Dean Hildebrand <dhildebz@umich.edu>
+ *
+ *  Permission is granted to use, copy, create derivative works, and
+ *  redistribute this software and such derivative works for any purpose,
+ *  so long as the name of the University of Michigan is not used in
+ *  any advertising or publicity pertaining to the use or distribution
+ *  of this software without specific, written prior authorization. If
+ *  the above copyright notice or any other identification of the
+ *  University of Michigan is included in any copy of any portion of
+ *  this software, then the disclaimer below must also be included.
+ *
+ *  This software is provided as is, without representation or warranty
+ *  of any kind either express or implied, including without limitation
+ *  the implied warranties of merchantability, fitness for a particular
+ *  purpose, or noninfringement.  The Regents of the University of
+ *  Michigan shall not be liable for any damages, including special,
+ *  indirect, incidental, or consequential damages, with respect to any
+ *  claim arising out of or in connection with the use of the software,
+ *  even if it has been or is hereafter advised of the possibility of
+ *  such damages.
+ */
+
+#include <linux/nfs_fs.h>
+#include "pnfs.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
+MODULE_DESCRIPTION("The NFSv4 file layout driver");
+
+int
+filelayout_initialize_mountpoint(struct nfs_server *nfss)
+{
+	return 0;
+}
+
+int
+filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
+{
+	dprintk("--> %s\n", __func__);
+
+	return 0;
+}
+
+static struct pnfs_layoutdriver_type filelayout_type = {
+	.id = LAYOUT_NFSV4_1_FILES,
+	.name = "LAYOUT_NFSV4_1_FILES",
+	.owner = THIS_MODULE,
+	.initialize_mountpoint   = filelayout_initialize_mountpoint,
+	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
+};
+
+static int __init nfs4filelayout_init(void)
+{
+	printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering...\n",
+	       __func__);
+	return pnfs_register_layoutdriver(&filelayout_type);
+}
+
+static void __exit nfs4filelayout_exit(void)
+{
+	printk(KERN_INFO "%s: NFSv4 File Layout Driver Unregistering...\n",
+	       __func__);
+	pnfs_unregister_layoutdriver(&filelayout_type);
+}
+
+module_init(nfs4filelayout_init);
+module_exit(nfs4filelayout_exit);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index aba3da2..499872f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -616,6 +616,7 @@ nfs_fileid_to_ino_t(u64 fileid)
 #define NFSDBG_MOUNT		0x0400
 #define NFSDBG_FSCACHE		0x0800
 #define NFSDBG_PNFS		0x1000
+#define NFSDBG_PNFS_LD		0x2000
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__
-- 
1.7.2.1

