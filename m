Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755003Ab0IISKi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 14:10:38 -0400
Received: from localhost.localdomain (surajit-lxp.hq.netapp.com [10.58.50.95] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o89IAW1R002948
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 11:10:37 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/13] RFC: nfs: set layout driver
Date: Thu,  2 Sep 2010 14:00:12 -0400
Message-Id: <1283450419-5648-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Put in the infrastructure that uses information returned from the
server at mount to select a layout driver module.

In this patch, a stub is used that always returns "no driver found".

Signed-off-by: TBD - melding/reorganization of several patches
---
 fs/nfs/Makefile           |    1 +
 fs/nfs/client.c           |    4 ++
 fs/nfs/pnfs.c             |   78 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   36 +++++++++++++++++++++
 include/linux/nfs_fs.h    |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 6 files changed, 121 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/pnfs.c
 create mode 100644 fs/nfs/pnfs.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index da7fda6..bb9e773 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -15,5 +15,6 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
+nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..eed1212 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -48,6 +48,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
@@ -898,6 +899,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	set_pnfs_layoutdriver(server, fsinfo->layouttype);
+
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
@@ -1017,6 +1020,7 @@ void nfs_free_server(struct nfs_server *server)
 {
 	dprintk("--> nfs_free_server()\n");
 
+	unset_pnfs_layoutdriver(server);
 	spin_lock(&nfs_client_lock);
 	list_del(&server->client_link);
 	list_del(&server->master_link);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
new file mode 100644
index 0000000..2e5dba1
--- /dev/null
+++ b/fs/nfs/pnfs.c
@@ -0,0 +1,78 @@
+/*
+ *  pNFS functions to call and manage layout drivers.
+ *
+ *  Copyright (c) 2002 [year of first publication]
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
+#define NFSDBG_FACILITY		NFSDBG_PNFS
+
+/* STUB that returns the equivalent of "no module found" */
+static struct pnfs_layoutdriver_type *
+find_pnfs_driver(u32 id) {
+	return NULL;
+}
+
+/* Unitialize a mountpoint in a layout driver */
+void
+unset_pnfs_layoutdriver(struct nfs_server *nfss)
+{
+	nfss->pnfs_curr_ld = NULL;
+}
+
+/*
+ * Try to set the server's pnfs module to the pnfs layout type specified by id.
+ * Currently only one pNFS layout driver per filesystem is supported.
+ *
+ * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
+ */
+void
+set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
+{
+	struct pnfs_layoutdriver_type *ld_type = NULL;
+
+	if (id == 0)
+		goto out_no_driver;
+	ld_type = find_pnfs_driver(id);
+	if (!ld_type) {
+		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+		ld_type = find_pnfs_driver(id);
+		if (!ld_type) {
+			dprintk("%s: No pNFS module found for %u.\n",
+				__func__, id);
+			goto out_no_driver;
+		}
+	}
+	server->pnfs_curr_ld = ld_type;
+	dprintk("%s: pNFS module for %u set\n", __func__, id);
+	return;
+
+out_no_driver:
+	dprintk("%s: Using NFSv4 I/O\n", __func__);
+	server->pnfs_curr_ld = NULL;
+}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
new file mode 100644
index 0000000..3281fbf
--- /dev/null
+++ b/fs/nfs/pnfs.h
@@ -0,0 +1,36 @@
+/*
+ *  pNFS client data structures.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand   <dhildebz@umich.edu>
+ */
+
+#ifndef FS_NFS_PNFS_H
+#define FS_NFS_PNFS_H
+
+#ifdef CONFIG_NFS_V4_1
+
+#define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
+
+/* Per-layout driver specific registration structure */
+struct pnfs_layoutdriver_type {
+};
+
+void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void unset_pnfs_layoutdriver(struct nfs_server *);
+
+#else  /* CONFIG_NFS_V4_1 */
+
+static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
+{
+}
+
+static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
+{
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
+#endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 508f8cf..042c2bd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -613,6 +613,7 @@ extern void * nfs_root_data(void);
 #define NFSDBG_CLIENT		0x0200
 #define NFSDBG_MOUNT		0x0400
 #define NFSDBG_FSCACHE		0x0800
+#define NFSDBG_PNFS		0x1000
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c82ee7c..29a821d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -144,6 +144,7 @@ struct nfs_server {
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */
+	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 #endif
 	void (*destroy)(struct nfs_server *);
 
-- 
1.7.2.1

