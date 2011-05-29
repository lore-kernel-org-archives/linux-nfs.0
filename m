Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50839 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111Ab1E2SVo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:21:44 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 13/32] pnfs-obj: objlayoutdriver module skeleton
Date: Sun, 29 May 2011 21:21:32 +0300
Message-Id: <1306693292-8072-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

* Define the PNFS_OBJLAYOUT Kconfig option in the nfs
  master Kconfig file.
* Add the objlayout driver to the Kernel's Kbuild system.
* Add the fs/nfs/objlayout/Kbuild file for building the
  objlayoutdriver.ko driver
* Define fs/nfs/objlayout/objio_osd.c, register the driver on module
  initialization and unregister on exit.

[pnfs-obj: remove of CONFIG_PNFS fallout]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[added "unsure" clause]
[depend on NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig               |   10 +++++
 fs/nfs/Makefile              |    2 +
 fs/nfs/objlayout/Kbuild      |    5 +++
 fs/nfs/objlayout/objio_osd.c |   76 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 93 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/objlayout/Kbuild
 create mode 100644 fs/nfs/objlayout/objio_osd.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index ba30665..8151554 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -87,6 +87,16 @@ config NFS_V4_1
 config PNFS_FILE_LAYOUT
 	tristate
 
+config PNFS_OBJLAYOUT
+	tristate "Provide support for the pNFS Objects Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
+	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
+	help
+	  Say M here if you want your pNFS client to support the Objects Layout Driver.
+	  Requires the SCSI osd initiator library (SCSI_OSD_INITIATOR) and
+	  upper level driver (SCSI_OSD_ULD).
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7516a8a..6a34f7d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -21,3 +21,5 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
+
+obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
new file mode 100644
index 0000000..2e5b9a4
--- /dev/null
+++ b/fs/nfs/objlayout/Kbuild
@@ -0,0 +1,5 @@
+#
+# Makefile for the pNFS Objects Layout Driver kernel module
+#
+objlayoutdriver-y := objio_osd.o
+obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
new file mode 100644
index 0000000..379595f
--- /dev/null
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -0,0 +1,76 @@
+/*
+ *  pNFS Objects layout implementation over open-osd initiator library
+ *
+ *  Copyright (C) 2009 Panasas Inc. [year of first publication]
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
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
+
+#include <linux/module.h>
+#include "../pnfs.h"
+
+static struct pnfs_layoutdriver_type objlayout_type = {
+	.id = LAYOUT_OSD2_OBJECTS,
+	.name = "LAYOUT_OSD2_OBJECTS",
+};
+
+MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
+MODULE_AUTHOR("Benny Halevy <bhalevy@panasas.com>");
+MODULE_LICENSE("GPL");
+
+static int __init
+objlayout_init(void)
+{
+	int ret = pnfs_register_layoutdriver(&objlayout_type);
+
+	if (ret)
+		printk(KERN_INFO
+			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
+			__func__, ret);
+	else
+		printk(KERN_INFO "%s: Registered OSD pNFS Layout Driver\n",
+			__func__);
+	return ret;
+}
+
+static void __exit
+objlayout_exit(void)
+{
+	pnfs_unregister_layoutdriver(&objlayout_type);
+	printk(KERN_INFO "%s: Unregistered OSD pNFS Layout Driver\n",
+	       __func__);
+}
+
+module_init(objlayout_init);
+module_exit(objlayout_exit);
-- 
1.7.2.3

