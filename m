Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759Ab2AMUL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:29 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 29/44] NFS: Create the nfs4/module.c file
Date: Fri, 13 Jan 2012 15:10:38 -0500
Message-Id: <1326485453-1350-30-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v4 isn't a module yet, but this puts the structure in the correct place.
I also modified super.c to call the future module's init and exit
functions.  This will let me gradually fill out the functions with the
necessary code in smaller steps.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile      |    2 +-
 fs/nfs/client.c      |   51 ------------------------------------------------
 fs/nfs/inode.c       |    1 -
 fs/nfs/nfs4/module.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4/nfs4.h   |    3 ++
 fs/nfs/super.c       |   10 +++++++-
 6 files changed, 65 insertions(+), 55 deletions(-)
 create mode 100644 fs/nfs/nfs4/module.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 16e3489..3850b1f 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/delegation.o nfs4/idmap.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
-			   nfs4/client.o
+			   nfs4/client.o nfs4/module.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1b84962..dd6453b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -42,7 +42,6 @@
 
 #include <asm/system.h>
 
-#include "nfs4/nfs4.h"
 #include "nfs4/nfs4_fs.h"
 #include "nfs4/callback.h"
 #include "nfs4/delegation.h"
@@ -113,44 +112,6 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-/*
- * Default function for referencing and unreferencing
- * nfs_version_module structures to prevent dereferencing
- * a null pointer by the framework code.  A functional
- * version will be implemented by individual nfs versions
- * as they are converted into modules.
- *
- * Once everything has been converted this function will
- * be removed.
- */
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
-static void nfs_module_null_function(void)
-{
-}
-#endif
-
-#ifdef CONFIG_NFS_V4
-static struct nfs_subversion nfs_v4_mod = {
-	.version  = 4,
-	.rpc_vers = &nfs_version4,
-	.rpc_ops  = &nfs_v4_clientops,
-
-	.reference = nfs_module_null_function,
-	.unreference = nfs_module_null_function,
-	.validate_mount_data = nfs4_validate_text_mount_data,
-	.init_aclclient = nfs4_init_aclclient,
-	.alloc_client = nfs4_alloc_client,
-	.put_client = nfs4_put_client,
-	.try_mount = nfs4_try_mount,
-	.shutdown_client = nfs4_shutdown_client,
-	.have_delegation = nfs4_have_delegation,
-	.have_delegated_attributes = nfs4_have_delegated_attributes,
-	.return_delegation = nfs4_inode_return_delegation,
-	.do_submount = nfs4_do_submount,
-	.do_clone_mount = nfs4_do_clone_mount,
-};
-#endif /* CONFIG_NFS_V4 */
-
 struct nfs_subversion *get_nfs_version(unsigned int version)
 {
 	struct nfs_subversion *nfs;
@@ -205,18 +166,6 @@ void unregister_nfs_version(struct nfs_subversion *nfs)
 }
 EXPORT_SYMBOL_GPL(unregister_nfs_version);
 
-/*
- * Preload all configured NFS versions during module init.
- * This function should be edited after each protocol is converted,
- * and eventually removed.
- */
-void __init nfs_register_versions(void)
-{
-#ifdef CONFIG_NFS_V4
-	register_nfs_version(&nfs_v4_mod);
-#endif
-}
-
 #ifdef CONFIG_NFS_V4
 int nfs4_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1bea5b7..29673ac 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1635,7 +1635,6 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-	nfs_register_versions();
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/nfs4/module.c b/fs/nfs/nfs4/module.c
new file mode 100644
index 0000000..4ac3069
--- /dev/null
+++ b/fs/nfs/nfs4/module.c
@@ -0,0 +1,53 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc.  All rights reserved.
+ *
+ * Initialize the NFS v4 module
+ */
+
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+
+#include "../nfs.h"
+#include "nfs4.h"
+#include "delegation.h"
+
+static void nfs4_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs4_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+static struct nfs_subversion nfs_v4 = {
+	.version  = 4,
+	.rpc_vers = &nfs_version4,
+	.rpc_ops  = &nfs_v4_clientops,
+
+	.reference = nfs4_reference,
+	.unreference = nfs4_unreference,
+	.validate_mount_data = nfs4_validate_text_mount_data,
+	.init_aclclient = nfs4_init_aclclient,
+	.alloc_client = nfs4_alloc_client,
+	.put_client = nfs4_put_client,
+	.try_mount = nfs4_try_mount,
+	.shutdown_client = nfs4_shutdown_client,
+	.have_delegation = nfs4_have_delegation,
+	.have_delegated_attributes = nfs4_have_delegated_attributes,
+	.return_delegation = nfs4_inode_return_delegation,
+	.do_submount = nfs4_do_submount,
+	.do_clone_mount = nfs4_do_clone_mount,
+};
+
+int __init init_nfs_v4(void)
+{
+	register_nfs_version(&nfs_v4);
+	return 0;
+}
+
+void exit_nfs_v4(void)
+{
+	unregister_nfs_version(&nfs_v4);
+}
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 0b1cf87..227a617 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -3,6 +3,9 @@
 
 #include "../nfs.h"
 
+int init_nfs_v4(void);
+void exit_nfs_v4(void);
+
 void nfs4_init_aclclient(struct nfs_server *);
 void nfs4_shutdown_client(struct nfs_client *);
 struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e1ea351..3306c43 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -397,16 +397,21 @@ int __init register_nfs_fs(void)
 	if (ret < 0)
 		goto error_1;
 #ifdef CONFIG_NFS_V4
-	ret = register_filesystem(&nfs4_fs_type);
+	ret = init_nfs_v4();
 	if (ret < 0)
 		goto error_2;
+	ret = register_filesystem(&nfs4_fs_type);
+	if (ret < 0)
+		goto error_3;
 #endif
 	register_shrinker(&acl_shrinker);
 	return 0;
 
 #ifdef CONFIG_NFS_V4
-error_2:
+error_3:
 	nfs_unregister_sysctl();
+error_2:
+	exit_nfs_v4();
 #endif
 error_1:
 	unregister_filesystem(&nfs_fs_type);
@@ -422,6 +427,7 @@ void __exit unregister_nfs_fs(void)
 	unregister_shrinker(&acl_shrinker);
 #ifdef CONFIG_NFS_V4
 	unregister_filesystem(&nfs4_fs_type);
+	exit_nfs_v4();
 #endif
 	nfs_unregister_sysctl();
 	unregister_filesystem(&nfs_fs_type);
-- 
1.7.8.3

