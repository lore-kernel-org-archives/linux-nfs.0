Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755950Ab0JOGRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/12] RFC: nfs: set layout driver
Date: Sun, 10 Oct 2010 11:22:47 -0400
Message-Id: <1286724173-8493-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Put in the infrastructure that uses information returned from the
server at mount to select a layout driver module.

In this patch, a stub is used that always returns "no driver found".

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/Makefile           |    1 +
 fs/nfs/client.c           |    5 +++
 fs/nfs/pnfs.c             |   84 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   56 ++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h    |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 6 files changed, 148 insertions(+), 0 deletions(-)
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
index 5f01f42..836fc25 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -48,6 +48,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
@@ -900,6 +901,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	set_pnfs_layoutdriver(server, fsinfo->layouttype);
+
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
@@ -937,6 +940,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 	}
 
 	fsinfo.fattr = fattr;
+	fsinfo.layouttype = 0;
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
 		goto out_error;
@@ -1019,6 +1023,7 @@ void nfs_free_server(struct nfs_server *server)
 {
 	dprintk("--> nfs_free_server()\n");
 
+	unset_pnfs_layoutdriver(server);
 	spin_lock(&nfs_client_lock);
 	list_del(&server->client_link);
 	list_del(&server->master_link);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
new file mode 100644
index 0000000..b483026
--- /dev/null
+++ b/fs/nfs/pnfs.c
@@ -0,0 +1,84 @@
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
+find_pnfs_driver(u32 id)
+{
+	return NULL;
+}
+
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
+	if (!(server->nfs_client->cl_exchange_flags &
+		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
+		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
+		       id, server->nfs_client->cl_exchange_flags);
+		goto out_no_driver;
+	}
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
index 0000000..c628ef1
--- /dev/null
+++ b/fs/nfs/pnfs.h
@@ -0,0 +1,56 @@
+/*
+ *  pNFS client data structures.
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
index d929b18..aba3da2 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -615,6 +615,7 @@ nfs_fileid_to_ino_t(u64 fileid)
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

