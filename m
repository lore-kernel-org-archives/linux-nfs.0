Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0HMVcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:15 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Marc Eshel <eshel@almaden.ibm.com>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 13/50] pnfs_submit: introduce nfs4layoutdriver module
Date: Fri, 13 Aug 2010 17:31:25 -0400
Message-Id: <1281735122-1496-14-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-13-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Basic initialization and unintialization of module and mount point.

Define CONFIG_PNFS_FILE_LAYOUT for conditionally building
the nfslayoutdriver.

[extracted from: pnfs: Initial check-in of pNFS File Layout Driver.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: device destory]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfs: nfs4filelayoutdev.c remove CONFIG_PNFS]
[pnfs: nfs4filelayout.c return CONFIG_PNFS]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfslayout: remove CONFIG_NFS_V4_1 altogether]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Makefile            |    3 +
 fs/nfs/nfs4filelayout.c    |  124 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4filelayout.h    |   19 +++++++
 fs/nfs/nfs4filelayoutdev.c |   60 +++++++++++++++++++++
 include/linux/nfs4.h       |    4 ++
 include/linux/nfs_fs.h     |    1 +
 6 files changed, 211 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/nfs4filelayout.c
 create mode 100644 fs/nfs/nfs4filelayout.h
 create mode 100644 fs/nfs/nfs4filelayoutdev.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index bb9e773..4776ff9 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -18,3 +18,6 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
+
+obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
+nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
new file mode 100644
index 0000000..7039d9d
--- /dev/null
+++ b/fs/nfs/nfs4filelayout.c
@@ -0,0 +1,124 @@
+/*
+ *  linux/fs/nfs/nfs4filelayout.c
+ *
+ *  Module for the pnfs nfs4 file layout driver.
+ *  Defines all I/O and Policy interface operations, plus code
+ *  to register itself with the pNFS client.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand <dhildebz@eecs.umich.edu>
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
+ *  3. Neither the name of the University nor the names of its
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
+#include <linux/init.h>
+
+#include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
+#include <linux/nfs4_pnfs.h>
+
+#include "nfs4filelayout.h"
+#include "nfs4_fs.h"
+#include "internal.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dean Hildebrand <dhildebz@eecs.umich.edu>");
+MODULE_DESCRIPTION("The NFSv4 file layout driver");
+
+/* Callback operations to the pNFS client */
+struct pnfs_client_operations *pnfs_callback_ops;
+
+int
+filelayout_initialize_mountpoint(struct nfs_client *clp)
+{
+	int status = nfs4_alloc_init_deviceid_cache(clp,
+						nfs4_fl_free_deviceid_callback);
+	if (status) {
+		printk(KERN_WARNING "%s: deviceid cache could not be "
+			"initialized\n", __func__);
+		return status;
+	}
+	dprintk("%s: deviceid cache has been initialized successfully\n",
+		__func__);
+	return 0;
+}
+
+/* Uninitialize a mountpoint by destroying its device list */
+int
+filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
+{
+	dprintk("--> %s\n", __func__);
+
+	if (nfss->pnfs_curr_ld && nfss->nfs_client->cl_devid_cache)
+		nfs4_put_deviceid_cache(nfss->nfs_client);
+	return 0;
+}
+
+struct layoutdriver_io_operations filelayout_io_operations = {
+	.initialize_mountpoint   = filelayout_initialize_mountpoint,
+	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
+};
+
+struct layoutdriver_policy_operations filelayout_policy_operations = {
+};
+
+struct pnfs_layoutdriver_type filelayout_type = {
+	.id = LAYOUT_NFSV4_1_FILES,
+	.name = "LAYOUT_NFSV4_1_FILES",
+	.ld_io_ops = &filelayout_io_operations,
+	.ld_policy_ops = &filelayout_policy_operations,
+};
+
+static int __init nfs4filelayout_init(void)
+{
+	printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering...\n",
+	       __func__);
+
+	/*
+	 * Need to register file_operations struct with global list to indicate
+	 * that NFS4 file layout is a possible pNFS I/O module
+	 */
+	pnfs_callback_ops = pnfs_register_layoutdriver(&filelayout_type);
+
+	return 0;
+}
+
+static void __exit nfs4filelayout_exit(void)
+{
+	printk(KERN_INFO "%s: NFSv4 File Layout Driver Unregistering...\n",
+	       __func__);
+
+	/* Unregister NFS4 file layout driver with pNFS client*/
+	pnfs_unregister_layoutdriver(&filelayout_type);
+}
+
+module_init(nfs4filelayout_init);
+module_exit(nfs4filelayout_exit);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
new file mode 100644
index 0000000..4af4c54
--- /dev/null
+++ b/fs/nfs/nfs4filelayout.h
@@ -0,0 +1,19 @@
+/*
+ *  pnfs_nfs4filelayout.h
+ *
+ *  NFSv4 file layout driver data structures.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand   <dhildebz@eecs.umich.edu>
+ */
+
+#ifndef FS_NFS_NFS4FILELAYOUT_H
+#define FS_NFS_NFS4FILELAYOUT_H
+
+extern void nfs4_fl_free_deviceid_callback(struct kref *);
+
+extern struct pnfs_client_operations *pnfs_callback_ops;
+
+#endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
new file mode 100644
index 0000000..0aee56b
--- /dev/null
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -0,0 +1,60 @@
+/*
+ *  linux/fs/nfs/nfs4filelayoutdev.c
+ *
+ *  Device operations for the pnfs nfs4 file layout driver.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand <dhildebz@eecs.umich.edu>
+ *  Garth Goodson   <Garth.Goodson@netapp.com>
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
+ *  3. Neither the name of the University nor the names of its
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
+#include <linux/hash.h>
+
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+
+#include <asm/div64.h>
+
+#include <linux/utsname.h>
+#include <linux/vmalloc.h>
+#include <linux/nfs4_pnfs.h>
+#include <linux/pnfs_xdr.h>
+#include "nfs4filelayout.h"
+#include "internal.h"
+#include "nfs4_fs.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+void
+nfs4_fl_free_deviceid_callback(struct kref *kref)
+{
+}
+
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1598e7b..010c3ba 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -551,6 +551,10 @@ enum state_protect_how4 {
 	SP4_SSV		= 2
 };
 
+enum pnfs_layouttype {
+	LAYOUT_NFSV4_1_FILES  = 1,
+};
+
 #endif
 #endif
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 042c2bd..a0f49a3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -614,6 +614,7 @@ extern void * nfs_root_data(void);
 #define NFSDBG_MOUNT		0x0400
 #define NFSDBG_FSCACHE		0x0800
 #define NFSDBG_PNFS		0x1000
+#define NFSDBG_PNFS_LD		0x2000
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__
-- 
1.6.2.5

