Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932744Ab2AMULT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:19 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 15/44] NFS: Move init_aclclient() into the v4 subdirectory
Date: Fri, 13 Jan 2012 15:10:24 -0500
Message-Id: <1326485453-1350-16-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I move this function into the v4 subdirectory so it can exist in the
future v4 module, instead of the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile      |    3 ++-
 fs/nfs/client.c      |   14 ++------------
 fs/nfs/nfs4/client.c |   12 ++++++++++++
 3 files changed, 16 insertions(+), 13 deletions(-)
 create mode 100644 fs/nfs/nfs4/client.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index d782c47..16e3489 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,7 +12,8 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/delegation.o nfs4/idmap.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
-			   nfs4/callback_proc.o nfs4/namespace.o
+			   nfs4/callback_proc.o nfs4/namespace.o \
+			   nfs4/client.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e24dd90..6c19290 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -42,6 +42,7 @@
 
 #include <asm/system.h>
 
+#include "nfs4/nfs4.h"
 #include "nfs4/nfs4_fs.h"
 #include "nfs4/callback.h"
 #include "nfs4/delegation.h"
@@ -53,8 +54,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
-static void nfs_init_server_aclclient(struct nfs_server *server);
-
 static DEFINE_SPINLOCK(nfs_client_lock);
 static DEFINE_SPINLOCK(nfs_version_lock);
 static LIST_HEAD(nfs_versions);
@@ -137,7 +136,7 @@ static struct nfs_subversion nfs_v4_mod = {
 
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
-	.init_aclclient = nfs_init_server_aclclient,
+	.init_aclclient = nfs4_init_aclclient,
 };
 #endif /* CONFIG_NFS_V4 */
 
@@ -801,15 +800,6 @@ static int nfs_start_lockd(struct nfs_server *server)
 }
 
 /*
- * Initialise an NFSv3 ACL client connection
- */
-static void nfs_init_server_aclclient(struct nfs_server *server)
-{
-	server->flags &= ~NFS_MOUNT_NOACL;
-	server->caps &= ~NFS_CAP_ACLS;
-}
-
-/*
  * Create a general RPC client
  */
 static int nfs_init_server_rpcclient(struct nfs_server *server,
diff --git a/fs/nfs/nfs4/client.c b/fs/nfs/nfs4/client.c
new file mode 100644
index 0000000..bbc415d
--- /dev/null
+++ b/fs/nfs/nfs4/client.c
@@ -0,0 +1,12 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/nfs_mount.h>
+
+void nfs4_init_aclclient(struct nfs_server *server)
+{
+	server->flags &= ~NFS_MOUNT_NOACL;
+	server->flags &= ~NFS_CAP_ACLS;
+}
-- 
1.7.8.3

