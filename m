Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932739Ab2AMULS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:18 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 12/44] NFS: Convert NFS v3 into a module
Date: Fri, 13 Jan 2012 15:10:21 -0500
Message-Id: <1326485453-1350-13-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

You need to run `modprobe nfs3` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig          |    2 +-
 fs/nfs/Makefile         |    3 +-
 fs/nfs/client.c         |   43 +----------------------------------
 fs/nfs/dir.c            |   21 -----------------
 fs/nfs/file.c           |   12 ---------
 fs/nfs/nfs3/Makefile    |    6 +++++
 fs/nfs/nfs3/acl.c       |    3 ++
 fs/nfs/nfs3/client.c    |   58 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3/dir.c       |   34 +++++++++++++++++++++++++++
 fs/nfs/nfs3/file.c      |   34 +++++++++++++++++++++++++++
 fs/nfs/nfs3/module.c    |   46 +++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3/nfs3.h      |   32 ++++++++++++++++++++++++++
 fs/nfs/nfs3/proc.c      |    7 +++--
 include/linux/nfs_xdr.h |    3 --
 14 files changed, 220 insertions(+), 84 deletions(-)
 create mode 100644 fs/nfs/nfs3/Makefile
 create mode 100644 fs/nfs/nfs3/client.c
 create mode 100644 fs/nfs/nfs3/dir.c
 create mode 100644 fs/nfs/nfs3/file.c
 create mode 100644 fs/nfs/nfs3/module.c
 create mode 100644 fs/nfs/nfs3/nfs3.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b28e56f..57c4b19 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -39,7 +39,7 @@ config NFS_V2
 	  If unsure, say Y.
 
 config NFS_V3
-	bool "NFS client support for NFS version 3"
+	tristate "NFS client support for NFS version 3"
 	depends on NFS_FS
 	help
 	  This option enables support for version 3 of the NFS protocol
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7d674a0..cfd238e 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3/proc.o nfs3/xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3/acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
@@ -23,5 +21,6 @@ obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
 obj-$(CONFIG_NFS_V2) += nfs2/
+obj-$(CONFIG_NFS_V3) += nfs3/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 20cfc99..ffb5994 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -129,18 +129,6 @@ static void nfs_module_null_function(void)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NFS_V3)
-static struct nfs_subversion nfs_v3_mod = {
-	.version  = 3,
-	.rpc_vers = &nfs_version3,
-	.rpc_ops  = &nfs_v3_clientops,
-
-	.reference = nfs_module_null_function,
-	.unreference = nfs_module_null_function,
-	.init_aclclient = nfs_init_server_aclclient,
-};
-#endif /* CONFIG_NFS_V3 */
-
 #ifdef CONFIG_NFS_V4
 static struct nfs_subversion nfs_v4_mod = {
 	.version  = 4,
@@ -153,21 +141,6 @@ static struct nfs_subversion nfs_v4_mod = {
 };
 #endif /* CONFIG_NFS_V4 */
 
-#ifdef CONFIG_NFS_V3_ACL
-static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static struct rpc_version *	nfsacl_version[] = {
-	[3]			= &nfsacl_version3,
-};
-
-struct rpc_program		nfsacl_program = {
-	.name			= "nfsacl",
-	.number			= NFS_ACL_PROGRAM,
-	.nrvers			= ARRAY_SIZE(nfsacl_version),
-	.version		= nfsacl_version,
-	.stats			= &nfsacl_rpcstat,
-};
-#endif  /* CONFIG_NFS_V3_ACL */
-
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
@@ -238,9 +211,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 void __init nfs_register_versions(void)
 {
-#if IS_ENABLED(CONFIG_NFS_V3)
-	register_nfs_version(&nfs_v3_mod);
-#endif
 #ifdef CONFIG_NFS_V4
 	register_nfs_version(&nfs_v4_mod);
 #endif
@@ -836,18 +806,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 #ifdef CONFIG_NFS_V3_ACL
 static void nfs_init_server_aclclient(struct nfs_server *server)
 {
-	if (server->flags & NFS_MOUNT_NOACL)
-		goto out_noacl;
-
-	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
-	if (IS_ERR(server->client_acl))
-		goto out_noacl;
-
-	/* No errors! Assume that Sun nfsacls are supported */
-	server->caps |= NFS_CAP_ACLS;
-	return;
-
-out_noacl:
+	server->flags &= ~NFS_MOUNT_NOACL;
 	server->caps &= ~NFS_CAP_ACLS;
 }
 #else
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 96bcfa3..41a5161 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -80,27 +80,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#if IS_ENABLED(CONFIG_NFS_V3)
-const struct inode_operations nfs3_dir_inode_operations = {
-	.create		= nfs_create,
-	.lookup		= nfs_lookup,
-	.link		= nfs_link,
-	.unlink		= nfs_unlink,
-	.symlink	= nfs_symlink,
-	.mkdir		= nfs_mkdir,
-	.rmdir		= nfs_rmdir,
-	.mknod		= nfs_mknod,
-	.rename		= nfs_rename,
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_V3 */
-
 #ifdef CONFIG_NFS_V4
 
 static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d11bb90..74c47eb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -44,18 +44,6 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-#if IS_ENABLED(CONFIG_NFS_V3)
-const struct inode_operations nfs3_file_inode_operations = {
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_v3 */
-
 /* Hack for future NFS swap support */
 #ifndef IS_SWAPFILE
 # define IS_SWAPFILE(inode)	(0)
diff --git a/fs/nfs/nfs3/Makefile b/fs/nfs/nfs3/Makefile
new file mode 100644
index 0000000..9b1c539
--- /dev/null
+++ b/fs/nfs/nfs3/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for NFS v3
+#
+obj-$(CONFIG_NFS_V3) += nfs3.o
+nfs3-y := module.o client.o dir.o file.o proc.o xdr.o
+nfs3-$(CONFIG_NFS_V3_ACL) += acl.o
diff --git a/fs/nfs/nfs3/acl.c b/fs/nfs/nfs3/acl.c
index ac589ff..dcf2259 100644
--- a/fs/nfs/nfs3/acl.c
+++ b/fs/nfs/nfs3/acl.c
@@ -1,3 +1,6 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
 #include <linux/fs.h>
 #include <linux/gfp.h>
 #include <linux/nfs.h>
diff --git a/fs/nfs/nfs3/client.c b/fs/nfs/nfs3/client.c
new file mode 100644
index 0000000..9f7e997
--- /dev/null
+++ b/fs/nfs/nfs3/client.c
@@ -0,0 +1,58 @@
+/* client.c: NFS client sharing and management code
+ *
+ * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/nfs_mount.h>
+#include "nfs3.h"
+
+/*
+ * Initialise an NFSv3 ACL client connection
+ */
+#ifdef CONFIG_NFS_V3_ACL
+static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
+static struct rpc_version *nfsacl_version[] = {
+	[3]			= &nfsacl_version3,
+};
+
+struct rpc_program		nfsacl_program = {
+	.name			= "nfsacl",
+	.number			= NFS_ACL_PROGRAM,
+	.nrvers			= ARRAY_SIZE(nfsacl_version),
+	.version		= nfsacl_version,
+	.stats			= &nfsacl_rpcstat,
+};
+
+void nfs3_init_aclclient(struct nfs_server *server)
+{
+	if (server->flags & NFS_MOUNT_NOACL)
+		goto out_noacl;
+
+	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
+	if (IS_ERR(server->client_acl))
+		goto out_noacl;
+
+	/* No errors! Assume that Sun nfsacls are supported */
+	server->caps |= NFS_CAP_ACLS;
+	return;
+
+out_noacl:
+	server->caps &= ~NFS_CAP_ACLS;
+}
+#else
+void nfs3_init_aclclient(struct nfs_server *server)
+{
+	server->flags &= ~NFS_MOUNT_NOACL;
+	server->caps &= ~NFS_CAP_ACLS;
+}
+#endif
+
diff --git a/fs/nfs/nfs3/dir.c b/fs/nfs/nfs3/dir.c
new file mode 100644
index 0000000..99a38f1
--- /dev/null
+++ b/fs/nfs/nfs3/dir.c
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) 1992  Rick Sladkey
+ */
+
+#include "../nfs.h"
+#include "nfs3.h"
+
+const struct inode_operations nfs3_dir_inode_operations = {
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
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
+const struct dentry_operations nfs3_dentry_operations = {
+	.d_revalidate	= nfs_lookup_revalidate,
+	.d_delete	= nfs_dentry_delete,
+	.d_iput		= nfs_dentry_iput,
+	.d_automount	= nfs_d_automount,
+	.d_release	= nfs_d_release,
+};
+
diff --git a/fs/nfs/nfs3/file.c b/fs/nfs/nfs3/file.c
new file mode 100644
index 0000000..8afdaa0
--- /dev/null
+++ b/fs/nfs/nfs3/file.c
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) 1992  Rick Sladkey
+ */
+#include "../nfs.h"
+#include "nfs3.h"
+
+const struct inode_operations nfs3_file_inode_operations = {
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
+const struct file_operations nfs3_file_operations = {
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
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
new file mode 100644
index 0000000..4c097a5
--- /dev/null
+++ b/fs/nfs/nfs3/module.c
@@ -0,0 +1,46 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ *
+ * Initialize the NFS v3 module
+ */
+
+#include <linux/module.h>
+#include "../nfs.h"
+
+#include "nfs3.h"
+
+static void nfs3_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs3_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+struct nfs_subversion nfs_v3 = {
+	.version  = 3,
+	.rpc_vers = &nfs_version3,
+	.rpc_ops  = &nfs_v3_clientops,
+
+	.reference = nfs3_reference,
+	.unreference = nfs3_unreference,
+	.init_aclclient = nfs3_init_aclclient,
+};
+
+static int __init init_nfs_v3(void)
+{
+	register_nfs_version(&nfs_v3);
+	return 0;
+}
+
+static void __exit exit_nfs_v3(void)
+{
+	unregister_nfs_version(&nfs_v3);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v3);
+module_exit(exit_nfs_v3);
diff --git a/fs/nfs/nfs3/nfs3.h b/fs/nfs/nfs3/nfs3.h
new file mode 100644
index 0000000..5ed7efa
--- /dev/null
+++ b/fs/nfs/nfs3/nfs3.h
@@ -0,0 +1,32 @@
+#ifndef __LINUX_FS_NFS_NFS3_H
+#define __LINUX_FS_NFS_NFS3_H
+
+#include <linux/fs.h>
+#include <linux/sunrpc/clnt.h>
+
+extern struct rpc_version nfs_version3;
+extern struct nfs_rpc_ops nfs_v3_clientops;
+
+void nfs3_init_aclclient(struct nfs_server *);
+
+extern const struct inode_operations nfs3_file_inode_operations;
+extern const struct file_operations nfs3_file_operations;
+
+extern const struct inode_operations nfs3_dir_inode_operations;
+extern const struct dentry_operations nfs3_dentry_operations;
+
+#ifdef CONFIG_NFS_V3_ACL
+extern struct rpc_version nfsacl_version3;
+
+ssize_t nfs3_listxattr(struct dentry *, char *, size_t);
+ssize_t nfs3_getxattr(struct dentry *, const char *, void *, size_t);
+int nfs3_setxattr(struct dentry *, const char *, const void *, size_t, int);
+int nfs3_removexattr(struct dentry *, const char *);
+#else
+#define nfs3_listxattr NULL
+#define nfs3_getxattr NULL
+#define nfs3_setxattr NULL
+#define nfs3_removexattr NULL
+#endif /* CONFIG_NFS_V3_ACL */
+
+#endif /* __LINUX_FS_NFS_NFS3_H */
diff --git a/fs/nfs/nfs3/proc.c b/fs/nfs/nfs3/proc.c
index f37ddb9..5118096 100644
--- a/fs/nfs/nfs3/proc.c
+++ b/fs/nfs/nfs3/proc.c
@@ -20,6 +20,7 @@
 
 #include "../iostat.h"
 #include "../internal.h"
+#include "nfs3.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -848,12 +849,12 @@ nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
-const struct nfs_rpc_ops nfs_v3_clientops = {
+struct nfs_rpc_ops nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
-	.dentry_ops	= &nfs_dentry_operations,
+	.dentry_ops	= &nfs3_dentry_operations,
 	.dir_inode_ops	= &nfs3_dir_inode_operations,
 	.file_inode_ops	= &nfs3_file_inode_operations,
-	.file_ops	= &nfs_file_operations,
+	.file_ops	= &nfs3_file_operations,
 	.getroot	= nfs3_proc_get_root,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0ca9f10..afa36f8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1273,12 +1273,9 @@ struct nfs_rpc_ops {
 /*
  * Function vectors etc. for the NFS client
  */
-extern const struct nfs_rpc_ops	nfs_v3_clientops;
 extern const struct nfs_rpc_ops	nfs_v4_clientops;
-extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
 
-extern struct rpc_version	nfsacl_version3;
 extern struct rpc_program	nfsacl_program;
 
 #endif
-- 
1.7.8.3

