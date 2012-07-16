Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2201 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab2GPUj3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:29 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/12] NFS: Move the v4 getroot code to nfs4getroot.c
Date: Mon, 16 Jul 2012 16:39:16 -0400
Message-Id: <1342471161-22452-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile      |  2 +-
 fs/nfs/getroot.c     | 50 --------------------------------------------------
 fs/nfs/nfs4getroot.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 51 deletions(-)
 create mode 100644 fs/nfs/nfs4getroot.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index e882a38..ec13afe 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -15,7 +15,7 @@ nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o nfs4file.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o
+			   nfs4namespace.o nfs4getroot.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 
 ifeq ($(CONFIG_SYSCTL), y)
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index a67990f..4654ced 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -23,21 +23,15 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
-#include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/namei.h>
 #include <linux/security.h>
 
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "delegation.h"
-#include "internal.h"
-
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
@@ -135,47 +129,3 @@ out:
 	nfs_free_fattr(fsinfo.fattr);
 	return ret;
 }
-
-#ifdef CONFIG_NFS_V4
-
-int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
-{
-	struct nfs_fsinfo fsinfo;
-	int ret = -ENOMEM;
-
-	dprintk("--> nfs4_get_rootfh()\n");
-
-	fsinfo.fattr = nfs_alloc_fattr();
-	if (fsinfo.fattr == NULL)
-		goto out;
-
-	/* Start by getting the root filehandle from the server */
-	ret = nfs4_proc_get_rootfh(server, mntfh, &fsinfo);
-	if (ret < 0) {
-		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
-		goto out;
-	}
-
-	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
-			|| !S_ISDIR(fsinfo.fattr->mode)) {
-		printk(KERN_ERR "nfs4_get_rootfh:"
-		       " getroot encountered non-directory\n");
-		ret = -ENOTDIR;
-		goto out;
-	}
-
-	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
-		printk(KERN_ERR "nfs4_get_rootfh:"
-		       " getroot obtained referral\n");
-		ret = -EREMOTE;
-		goto out;
-	}
-
-	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
-out:
-	nfs_free_fattr(fsinfo.fattr);
-	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
-	return ret;
-}
-
-#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
new file mode 100644
index 0000000..6a83780
--- /dev/null
+++ b/fs/nfs/nfs4getroot.c
@@ -0,0 +1,49 @@
+/*
+* Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+* Written by David Howells (dhowells@redhat.com)
+*/
+
+#include <linux/nfs_fs.h>
+#include "nfs4_fs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
+int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
+{
+	struct nfs_fsinfo fsinfo;
+	int ret = -ENOMEM;
+
+	dprintk("--> nfs4_get_rootfh()\n");
+
+	fsinfo.fattr = nfs_alloc_fattr();
+	if (fsinfo.fattr == NULL)
+		goto out;
+
+	/* Start by getting the root filehandle from the server */
+	ret = nfs4_proc_get_rootfh(server, mntfh, &fsinfo);
+	if (ret < 0) {
+		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
+		goto out;
+	}
+
+	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
+			|| !S_ISDIR(fsinfo.fattr->mode)) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
+		       " getroot encountered non-directory\n");
+		ret = -ENOTDIR;
+		goto out;
+	}
+
+	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
+		       " getroot obtained referral\n");
+		ret = -EREMOTE;
+		goto out;
+	}
+
+	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
+out:
+	nfs_free_fattr(fsinfo.fattr);
+	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
+	return ret;
+}
-- 
1.7.11.2

