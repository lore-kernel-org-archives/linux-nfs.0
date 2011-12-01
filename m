Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755422Ab1LAQs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 11:48:29 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC v2 4/4] NFS: Turn NFS v3 into a module
Date: Thu,  1 Dec 2011 11:48:22 -0500
Message-Id: <1322758102-29260-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This will allow users to unmap NFS v3 from the kernel memory if they
don't want to use it.  This will also give us a place to put NFS v3
specific code so it doesn't clutter the generic NFS client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig         |    8 ++++-
 fs/nfs/Makefile        |    3 +-
 fs/nfs/client.c        |    8 ++---
 fs/nfs/dir.c           |   31 --------------------
 fs/nfs/file.c          |   12 -------
 fs/nfs/internal.h      |   10 ++++++
 fs/nfs/nfs3/Makefile   |    7 ++++
 fs/nfs/nfs3/module.c   |   75 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3/nfs3.h     |    7 ++++
 fs/nfs/nfs3/nfs3proc.c |    1 +
 fs/nfs/nfs3/nfs3xdr.c  |    1 +
 11 files changed, 111 insertions(+), 52 deletions(-)
 create mode 100644 fs/nfs/nfs3/Makefile
 create mode 100644 fs/nfs/nfs3/module.c
 create mode 100644 fs/nfs/nfs3/nfs3.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index dbcd821..47195e0 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -29,15 +29,19 @@ config NFS_FS
 
 	  If unsure, say N.
 
-config NFS_V3
-	bool "NFS client support for NFS version 3"
+config NFS_VERSION_3
+	tristate "NFS client support for NFS version 3"
 	depends on NFS_FS
+	select NFS_V3
 	help
 	  This option enables support for version 3 of the NFS protocol
 	  (RFC 1813) in the kernel's NFS client.
 
 	  If unsure, say Y.
 
+config NFS_V3
+	bool
+
 config NFS_V3_ACL
 	bool "NFS client support for the NFSv3 ACL protocol extension"
 	depends on NFS_V3
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index ac0e5df..930913d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3/nfs3proc.o nfs3/nfs3xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3/nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
@@ -22,5 +20,6 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
+obj-$(CONFIG_NFS_VERSION_3) += nfs3/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9e77056..e4cb43b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -97,7 +97,7 @@ static struct nfs_version_ops *nfs_version_ops[5] = {
 
 static struct nfs_rpc_ops *nfs_ops[5] = {
 	[2]	= &nfs_v2_clientops,
-	[3]	= &nfs_v3_clientops,
+	[3]	= NULL,
 	[4]	= &nfs_v4_clientops,
 };
 
@@ -106,9 +106,7 @@ static struct nfs_rpc_ops *nfs_ops[5] = {
  */
 static struct rpc_version *nfs_version[5] = {
 	[2]			= &nfs_version2,
-#ifdef CONFIG_NFS_V3
-	[3]			= &nfs_version3,
-#endif
+	[3]			= NULL,
 #ifdef CONFIG_NFS_V4
 	[4]			= &nfs_version4,
 #endif
@@ -131,7 +129,7 @@ struct rpc_stat nfs_rpcstat = {
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
 static struct rpc_version *	nfsacl_version[] = {
-	[3]			= &nfsacl_version3,
+	[3]			= NULL,
 };
 
 struct rpc_program		nfsacl_program = {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f7cb6b6..25dbc54 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -47,16 +47,6 @@
 static int nfs_opendir(struct inode *, struct file *);
 static int nfs_closedir(struct inode *, struct file *);
 static int nfs_readdir(struct file *, void *, filldir_t);
-struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
-int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
-int nfs_mkdir(struct inode *, struct dentry *, int);
-int nfs_rmdir(struct inode *, struct dentry *);
-int nfs_unlink(struct inode *, struct dentry *);
-int nfs_symlink(struct inode *, struct dentry *, const char *);
-int nfs_link(struct dentry *, struct inode *, struct dentry *);
-int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
-int nfs_rename(struct inode *, struct dentry *,
-		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, loff_t, loff_t, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static void nfs_readdir_clear_array(struct page*);
@@ -89,27 +79,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V3
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
index 90389ca..397e5e0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -49,18 +49,6 @@ const struct inode_operations nfs_file_inode_operations = {
 	.setattr	= nfs_setattr,
 };
 
-#ifdef CONFIG_NFS_V3
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
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 93a0ba2..e6256f9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -83,6 +83,16 @@ void nfs_unregister_version(unsigned int);
 void nfs_version_ref(unsigned int);
 void nfs_version_unref(unsigned int);
 
+struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
+int nfs_mkdir(struct inode *, struct dentry *, int);
+int nfs_rmdir(struct inode *, struct dentry *);
+int nfs_unlink(struct inode *, struct dentry *);
+int nfs_symlink(struct inode *, struct dentry *, const char *);
+int nfs_link(struct dentry *, struct inode *, struct dentry *);
+int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
+int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+
 /*
  * Note: RFC 1813 doesn't limit the number of auth flavors that
  * a server can return, so make something up.
diff --git a/fs/nfs/nfs3/Makefile b/fs/nfs/nfs3/Makefile
new file mode 100644
index 0000000..308123b
--- /dev/null
+++ b/fs/nfs/nfs3/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for NFS v3
+#
+obj-$(CONFIG_NFS_VERSION_3) += nfs3.o
+
+nfs3-y := module.o nfs3proc.o nfs3xdr.o
+nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
new file mode 100644
index 0000000..9c67cd0
--- /dev/null
+++ b/fs/nfs/nfs3/module.c
@@ -0,0 +1,75 @@
+/*
+ * Initialize the NFS v3 module
+ */
+
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+
+#include "../internal.h"
+#include "nfs3.h"
+
+static void nfs_v3_ref(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs_v3_unref(void)
+{
+	module_put(THIS_MODULE);
+}
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
+struct nfs_version_ops nfs_v3_ops = {
+	.nfs_rpc	= &nfs_version3,
+	.nfs_ops	= &nfs_v3_clientops,
+#ifdef CONFIG_NFS_V3_ACL
+	.nfs_acl	= &nfsacl_version3,
+#endif
+	.version_ref	= nfs_v3_ref,
+	.version_unref	= nfs_v3_unref,
+};
+
+static int __init init_nfs_v3(void)
+{
+	nfs_register_version(3, &nfs_v3_ops);
+	return 0;
+}
+
+static void __exit exit_nfs_v3(void)
+{
+	nfs_unregister_version(3);
+}
+
+MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v3);
+module_exit(exit_nfs_v3);
diff --git a/fs/nfs/nfs3/nfs3.h b/fs/nfs/nfs3/nfs3.h
new file mode 100644
index 0000000..c1e7875
--- /dev/null
+++ b/fs/nfs/nfs3/nfs3.h
@@ -0,0 +1,7 @@
+#ifndef _FS_NFS_NFS3_H
+#define _FS_NFS_NFS3_H
+
+const extern struct inode_operations nfs3_file_inode_operations;
+const extern struct inode_operations nfs3_dir_inode_operations;
+
+#endif /* _FS_NFS_NFS3_H */
diff --git a/fs/nfs/nfs3/nfs3proc.c b/fs/nfs/nfs3/nfs3proc.c
index 593a44c..e574e82 100644
--- a/fs/nfs/nfs3/nfs3proc.c
+++ b/fs/nfs/nfs3/nfs3proc.c
@@ -20,6 +20,7 @@
 
 #include "../iostat.h"
 #include "../internal.h"
+#include "nfs3.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
diff --git a/fs/nfs/nfs3/nfs3xdr.c b/fs/nfs/nfs3/nfs3xdr.c
index be27fb8..d59d644 100644
--- a/fs/nfs/nfs3/nfs3xdr.c
+++ b/fs/nfs/nfs3/nfs3xdr.c
@@ -20,6 +20,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
+#include <linux/nfs_xdr.h>
 #include "../internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
-- 
1.7.7.4

