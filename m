Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab2AMULP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:15 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 07/44] NFS: Convert NFS v2 into a module
Date: Fri, 13 Jan 2012 15:10:16 -0500
Message-Id: <1326485453-1350-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

You need to run `modprobe nfs2` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig          |    2 +-
 fs/nfs/Makefile         |    2 +-
 fs/nfs/client.c         |   15 +--------------
 fs/nfs/file.c           |    6 ------
 fs/nfs/nfs2/Makefile    |    5 +++++
 fs/nfs/nfs2/dir.c       |   30 ++++++++++++++++++++++++++++++
 fs/nfs/nfs2/file.c      |   32 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs2/module.c    |   45 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs2/nfs2.h      |   17 +++++++++++++++++
 fs/nfs/nfs2/proc.c      |    1 +
 include/linux/nfs_xdr.h |    3 +--
 11 files changed, 134 insertions(+), 24 deletions(-)
 create mode 100644 fs/nfs/nfs2/Makefile
 create mode 100644 fs/nfs/nfs2/dir.c
 create mode 100644 fs/nfs/nfs2/file.c
 create mode 100644 fs/nfs/nfs2/module.c
 create mode 100644 fs/nfs/nfs2/nfs2.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 5419166..b28e56f 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -30,7 +30,7 @@ config NFS_FS
 	  If unsure, say N.
 
 config NFS_V2
-	bool "NFS client support for NFS version 2"
+	tristate "NFS client support for NFS version 2"
 	depends on NFS_FS
 	help
 	  This option enables support for version 2 of the NFS protocol
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 44db87d..5733451 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= nfs2/proc.o nfs2/xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
@@ -23,5 +22,6 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
+obj-$(CONFIG_NFS_V2) += nfs2/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 168b469..20d1708 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -121,22 +121,12 @@ struct rpc_stat nfs_rpcstat = {
  * Once everything has been converted this function will
  * be removed.
  */
-#if defined(CONFIG_NFS_V2) || defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void nfs_module_null_function(void)
 {
 }
 #endif
 
-#ifdef CONFIG_NFS_V2
-static struct nfs_subversion nfs_v2_mod = {
-	.version  = 2,
-	.rpc_vers = &nfs_version2,
-	.rpc_ops  = &nfs_v2_clientops,
-	.reference = nfs_module_null_function,
-	.unreference = nfs_module_null_function,
-};
-#endif /* CONFIG_NFS_V2 */
-
 #ifdef CONFIG_NFS_V3
 static struct nfs_subversion nfs_v3_mod = {
 	.version  = 3,
@@ -242,9 +232,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 void __init nfs_register_versions(void)
 {
-#ifdef CONFIG_NFS_V2
-	register_nfs_version(&nfs_v2_mod);
-#endif
 #ifdef CONFIG_NFS_V3
 	register_nfs_version(&nfs_v3_mod);
 #endif
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 227694e..4ac4dae 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -44,12 +44,6 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-const struct inode_operations nfs_file_inode_operations = {
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-};
-
 #ifdef CONFIG_NFS_V3
 const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
diff --git a/fs/nfs/nfs2/Makefile b/fs/nfs/nfs2/Makefile
new file mode 100644
index 0000000..0ca3b59
--- /dev/null
+++ b/fs/nfs/nfs2/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for NFS v2
+#
+obj-$(CONFIG_NFS_V2) += nfs2.o
+nfs2-y := module.o dir.o file.o proc.o xdr.o
diff --git a/fs/nfs/nfs2/dir.c b/fs/nfs/nfs2/dir.c
new file mode 100644
index 0000000..64e2154
--- /dev/null
+++ b/fs/nfs/nfs2/dir.c
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 1992  Rick Sladkey
+ */
+#include <linux/fs.h>
+
+#include "../nfs.h"
+#include "nfs2.h"
+
+const struct inode_operations nfs_dir_inode_operations = {
+	.create		= nfs_create,
+	.lookup		= nfs_lookup,
+	.link		= nfs_link,
+	.unlink		= nfs_unlink,
+	.symlink	= nfs_symlink,
+	.mkdir		= nfs_mkdir,
+	.rmdir		= nfs_rmdir,
+	.mknod		= nfs_mknod,
+	.rename		= nfs_rename,
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+};
+
+const struct dentry_operations nfs_dentry_operations = {
+	.d_revalidate	= nfs_lookup_revalidate,
+	.d_delete	= nfs_dentry_delete,
+	.d_iput		= nfs_dentry_iput,
+	.d_automount	= nfs_d_automount,
+	.d_release	= nfs_d_release,
+};
diff --git a/fs/nfs/nfs2/file.c b/fs/nfs/nfs2/file.c
new file mode 100644
index 0000000..bfe6412
--- /dev/null
+++ b/fs/nfs/nfs2/file.c
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 1992  Rick Sladkey
+ */
+#include <linux/fs.h>
+
+#include "../nfs.h"
+#include "nfs2.h"
+
+const struct inode_operations nfs_file_inode_operations = {
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+};
+
+const struct file_operations nfs_file_operations = {
+	.llseek		= nfs_file_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= nfs_file_read,
+	.aio_write	= nfs_file_write,
+	.mmap		= nfs_file_mmap,
+	.open		= nfs_file_open,
+	.flush		= nfs_file_flush,
+	.release	= nfs_file_release,
+	.fsync		= nfs_file_fsync,
+	.lock		= nfs_lock,
+	.flock		= nfs_flock,
+	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
+	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
+};
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
new file mode 100644
index 0000000..04d415a
--- /dev/null
+++ b/fs/nfs/nfs2/module.c
@@ -0,0 +1,45 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ *
+ * Initialize the NFS v2 module
+ */
+
+#include <linux/module.h>
+#include "../nfs.h"
+
+#include "nfs2.h"
+
+static void nfs2_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs2_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+struct nfs_subversion nfs_v2 = {
+	.version  = 2,
+	.rpc_vers = &nfs_version2,
+	.rpc_ops  = &nfs_v2_clientops,
+
+	.reference = nfs2_reference,
+	.unreference = nfs2_unreference,
+};
+
+static int __init init_nfs_v2(void)
+{
+	register_nfs_version(&nfs_v2);
+	return 0;
+}
+
+static void __exit exit_nfs_v2(void)
+{
+	unregister_nfs_version(&nfs_v2);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v2);
+module_exit(exit_nfs_v2);
diff --git a/fs/nfs/nfs2/nfs2.h b/fs/nfs/nfs2/nfs2.h
new file mode 100644
index 0000000..6274821
--- /dev/null
+++ b/fs/nfs/nfs2/nfs2.h
@@ -0,0 +1,17 @@
+#ifndef __LINUX_FS_NFS_NFS2_H
+#define __LINUX_FS_NFS_NFS2_H
+
+#include <linux/fs.h>
+#include <linux/sunrpc/clnt.h>
+
+extern struct rpc_version nfs_version2;
+extern const struct nfs_rpc_ops nfs_v2_clientops;
+
+extern const struct inode_operations nfs_file_inode_operations;
+extern const struct file_operations nfs_file_operations;
+
+extern const struct inode_operations nfs_dir_inode_operations;
+extern const struct file_operations nfs_dir_operations;
+extern const struct dentry_operations nfs_dentry_operations;
+
+#endif /* __LINUX_FS_NFS_NFS2_H */
diff --git a/fs/nfs/nfs2/proc.c b/fs/nfs/nfs2/proc.c
index 65eafa3..6590fc7 100644
--- a/fs/nfs/nfs2/proc.c
+++ b/fs/nfs/nfs2/proc.c
@@ -42,6 +42,7 @@
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
 #include "../internal.h"
+#include "nfs2.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a764cef..0ca9f10 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -3,6 +3,7 @@
 
 #include <linux/nfsacl.h>
 #include <linux/nfs3.h>
+#include <linux/nfs4.h>
 #include <linux/sunrpc/gss_api.h>
 
 /*
@@ -1272,10 +1273,8 @@ struct nfs_rpc_ops {
 /*
  * Function vectors etc. for the NFS client
  */
-extern const struct nfs_rpc_ops	nfs_v2_clientops;
 extern const struct nfs_rpc_ops	nfs_v3_clientops;
 extern const struct nfs_rpc_ops	nfs_v4_clientops;
-extern struct rpc_version	nfs_version2;
 extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
 
-- 
1.7.8.3

